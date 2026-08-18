/*
 *
 *  *
 *  *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *  *
 *  *  * This source code is licensed under the GPL-2.0 license license found in the
 *  *  * LICENSE file in the root directory of this source tree.
 *  *
 *
 */
package com.peace.mind.services.vpn

import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.nio.ByteBuffer
import java.util.concurrent.atomic.AtomicBoolean

/**
 * A minimal, safety-scoped DNS filtering engine used by [MindfulVpnService]
 * when "VPN website filter" is enabled.
 *
 * Design notes (important - read before modifying):
 * - This engine ONLY intercepts DNS (UDP port 53) traffic. It does NOT do
 *   general IP packet forwarding. The VPN [android.net.VpnService.Builder]
 *   is configured to route just a single virtual DNS-server address
 *   through the tunnel (see [VIRTUAL_DNS_ADDRESS]), while all other
 *   traffic (actual web/app content) bypasses the VPN entirely and goes
 *   directly over the device's normal network connection.
 * - This drastically limits the "blast radius" of any bug here: at worst,
 *   DNS resolution for a single query might fail (apps handle that
 *   gracefully as a normal DNS error), rather than risking the device's
 *   overall internet connectivity like a full packet-forwarding VPN would.
 * - Because this filters at the DNS level system-wide (there is no
 *   reliable, safe way to attribute a raw IP packet to a specific app
 *   without significant additional OS-level plumbing), this filter
 *   applies to ALL apps on the device while active, not just specific
 *   ones. It is intentionally a separate, simpler feature from the
 *   existing per-app "Internet Blocker" (which fully cuts off internet
 *   for specific apps) - the two are mutually exclusive since Android
 *   only allows one active VPN tunnel at a time.
 */
class DnsFilterEngine(
    private val vpnService: VpnService,
    private val upstreamDnsHost: String = "1.1.1.1",
) {
    companion object {
        private const val TAG = "Mindful.DnsFilterEngine"
        const val VIRTUAL_DNS_ADDRESS = "10.111.222.1"
        private const val DNS_PORT = 53
        private const val UPSTREAM_TIMEOUT_MS = 4000
        private const val MAX_PACKET_SIZE = 32767
    }

    @Volatile
    var blockedDomains: Set<String> = emptySet()

    private val isRunning = AtomicBoolean(false)
    private var readerThread: Thread? = null

    /** Starts the DNS-filter read loop against the given VPN tunnel fd. */
    fun start(vpnInterface: ParcelFileDescriptor) {
        if (isRunning.getAndSet(true)) return

        val thread = Thread({
            runReadLoop(vpnInterface)
        }, TAG)
        readerThread = thread
        thread.start()
    }

    fun stop() {
        isRunning.set(false)
        readerThread?.interrupt()
        readerThread = null
    }

    private fun isDomainBlocked(domain: String): Boolean {
        val lower = domain.lowercase().trimEnd('.')
        if (blockedDomains.contains(lower)) return true

        /// Also match subdomains of a blocked domain, e.g. blocking
        /// "example.com" should also block "m.example.com".
        var idx = lower.indexOf('.')
        while (idx != -1) {
            val parent = lower.substring(idx + 1)
            if (blockedDomains.contains(parent)) return true
            idx = lower.indexOf('.', idx + 1)
        }
        return false
    }

    private fun runReadLoop(vpnInterface: ParcelFileDescriptor) {
        val input = FileInputStream(vpnInterface.fileDescriptor)
        val output = FileOutputStream(vpnInterface.fileDescriptor)
        val buffer = ByteArray(MAX_PACKET_SIZE)

        Log.d(TAG, "runReadLoop: DNS filter engine started")

        while (isRunning.get() && !Thread.currentThread().isInterrupted) {
            try {
                val length = input.read(buffer)
                if (length <= 0) continue

                val packet = ByteBuffer.wrap(buffer, 0, length)
                handleIpPacket(packet, length, output)
            } catch (e: Exception) {
                if (isRunning.get()) {
                    Log.w(TAG, "runReadLoop: error processing packet", e)
                }
                /// Keep looping - a single malformed/unexpected packet
                /// should never take down the whole filter.
            }
        }

        Log.d(TAG, "runReadLoop: DNS filter engine stopped")
    }

    /** Parses a raw IPv4 packet and, if it's a UDP/53 DNS query destined
     * for our virtual DNS address, handles it; otherwise the packet is
     * ignored (nothing else should reach this tunnel given the narrow
     * route we configure). */
    private fun handleIpPacket(packet: ByteBuffer, length: Int, output: FileOutputStream) {
        if (length < 20) return // shorter than a minimal IPv4 header

        val versionAndIhl = packet.get(0).toInt() and 0xFF
        val version = versionAndIhl shr 4
        if (version != 4) return // only IPv4 supported by this minimal engine

        val ihl = (versionAndIhl and 0x0F) * 4
        if (ihl < 20 || length < ihl + 8) return

        val protocol = packet.get(9).toInt() and 0xFF
        if (protocol != 17) return // not UDP

        val udpStart = ihl
        val srcPort = ((packet.get(udpStart).toInt() and 0xFF) shl 8) or
                (packet.get(udpStart + 1).toInt() and 0xFF)
        val dstPort = ((packet.get(udpStart + 2).toInt() and 0xFF) shl 8) or
                (packet.get(udpStart + 3).toInt() and 0xFF)

        if (dstPort != DNS_PORT) return

        val udpLength = ((packet.get(udpStart + 4).toInt() and 0xFF) shl 8) or
                (packet.get(udpStart + 5).toInt() and 0xFF)
        val dnsStart = udpStart + 8
        val dnsLength = udpLength - 8
        if (dnsLength <= 0 || dnsStart + dnsLength > length) return

        val dnsQuery = ByteArray(dnsLength)
        packet.position(dnsStart)
        packet.get(dnsQuery)

        val queriedDomain = parseDnsQuestionName(dnsQuery) ?: return

        /// Extract source IP (the tun-side address of whoever sent this
        /// query) so we can address our response back to them.
        val srcIpBytes = ByteArray(4)
        packet.position(12)
        packet.get(srcIpBytes)
        val srcIp = InetAddress.getByAddress(srcIpBytes)

        if (isDomainBlocked(queriedDomain)) {
            val response = buildBlockedDnsResponse(dnsQuery)
            writeUdpResponsePacket(
                output, srcIp, srcPort, response,
            )
        } else {
            forwardToUpstream(dnsQuery) { response ->
                if (response != null) {
                    writeUdpResponsePacket(output, srcIp, srcPort, response)
                }
            }
        }
    }

    /** Minimal DNS question-name parser: reads the QNAME of the first
     * question in a DNS query message (labels prefixed by length byte,
     * terminated by a zero-length label). Returns null if the message is
     * too short/malformed to safely parse. */
    private fun parseDnsQuestionName(dns: ByteArray): String? {
        if (dns.size < 12) return null // DNS header is 12 bytes
        val qdCount = ((dns[4].toInt() and 0xFF) shl 8) or (dns[5].toInt() and 0xFF)
        if (qdCount < 1) return null

        val sb = StringBuilder()
        var pos = 12
        while (pos < dns.size) {
            val labelLen = dns[pos].toInt() and 0xFF
            if (labelLen == 0) break
            pos += 1
            if (pos + labelLen > dns.size) return null
            if (sb.isNotEmpty()) sb.append('.')
            sb.append(String(dns, pos, labelLen, Charsets.US_ASCII))
            pos += labelLen
        }
        return if (sb.isEmpty()) null else sb.toString()
    }

    /** Builds a synthetic NXDOMAIN DNS response for a blocked query,
     * preserving the original transaction ID and question section so
     * the requesting app accepts it as a valid (if empty) answer. */
    private fun buildBlockedDnsResponse(query: ByteArray): ByteArray {
        val response = query.copyOf()

        /// Flags: QR=1 (response), Opcode from query, RD copied, RA=0,
        /// RCODE=3 (NXDOMAIN)
        response[2] = (0x81).toByte() // QR=1, Opcode=0, AA=0, TC=0, RD=1
        response[3] = (0x83).toByte() // RA=0, Z=0, RCODE=3 (NXDOMAIN)

        /// Zero out answer/authority/additional counts - we return no
        /// records, just an authoritative "not found".
        response[6] = 0; response[7] = 0
        response[8] = 0; response[9] = 0
        response[10] = 0; response[11] = 0

        return response
    }

    /** Forwards an allowed DNS query to a real upstream resolver over a
     * VPN-protected UDP socket (so the forwarding socket itself doesn't
     * get routed back into our own tunnel), then invokes [onResult] with
     * the raw response bytes, or null on failure/timeout. */
    private fun forwardToUpstream(query: ByteArray, onResult: (ByteArray?) -> Unit) {
        var socket: DatagramSocket? = null
        try {
            socket = DatagramSocket()
            vpnService.protect(socket)
            socket.soTimeout = UPSTREAM_TIMEOUT_MS

            val upstreamAddr = InetAddress.getByName(upstreamDnsHost)
            val outPacket = DatagramPacket(query, query.size, upstreamAddr, DNS_PORT)
            socket.send(outPacket)

            val responseBuffer = ByteArray(MAX_PACKET_SIZE)
            val inPacket = DatagramPacket(responseBuffer, responseBuffer.size)
            socket.receive(inPacket)

            onResult(inPacket.data.copyOf(inPacket.length))
        } catch (e: Exception) {
            Log.w(TAG, "forwardToUpstream: failed to resolve via upstream", e)
            onResult(null)
        } finally {
            socket?.close()
        }
    }

    /** Wraps a raw DNS response into an IPv4/UDP packet addressed back to
     * the original querying app (via the tun interface's virtual address
     * space) and writes it to the tun fd. */
    private fun writeUdpResponsePacket(
        output: FileOutputStream,
        destIp: InetAddress,
        destPort: Int,
        dnsPayload: ByteArray,
    ) {
        try {
            val udpLength = 8 + dnsPayload.size
            val totalLength = 20 + udpLength
            val packet = ByteBuffer.allocate(totalLength)

            /// --- IPv4 header ---
            packet.put(0x45.toByte()) // version=4, IHL=5 (20 bytes, no options)
            packet.put(0x00.toByte()) // DSCP/ECN
            packet.putShort(totalLength.toShort())
            packet.putShort(0) // identification
            packet.putShort(0x4000.toShort()) // flags=DF, fragment offset=0
            packet.put(64.toByte()) // TTL
            packet.put(17.toByte()) // protocol = UDP
            packet.putShort(0) // checksum placeholder, filled below

            val srcIpBytes = InetAddress.getByName(VIRTUAL_DNS_ADDRESS).address
            packet.put(srcIpBytes)
            packet.put(destIp.address)

            /// --- UDP header ---
            packet.putShort(DNS_PORT.toShort())
            packet.putShort(destPort.toShort())
            packet.putShort(udpLength.toShort())
            packet.putShort(0) // UDP checksum - 0 is valid (optional over IPv4)

            /// --- DNS payload ---
            packet.put(dnsPayload)

            /// Fill in IPv4 header checksum (bytes 10-11)
            val ipChecksum = computeIpChecksum(packet.array(), 0, 20)
            packet.putShort(10, ipChecksum.toShort())

            output.write(packet.array(), 0, totalLength)
        } catch (e: Exception) {
            Log.w(TAG, "writeUdpResponsePacket: failed to write response", e)
        }
    }

    private fun computeIpChecksum(data: ByteArray, offset: Int, length: Int): Int {
        var sum = 0
        var i = offset
        while (i < offset + length) {
            val word = ((data[i].toInt() and 0xFF) shl 8) or
                    (if (i + 1 < offset + length) (data[i + 1].toInt() and 0xFF) else 0)
            sum += word
            i += 2
        }
        while (sum shr 16 != 0) {
            sum = (sum and 0xFFFF) + (sum shr 16)
        }
        return sum.inv() and 0xFFFF
    }
}
