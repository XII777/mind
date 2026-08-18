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

import android.content.Intent
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.IBinder
import android.os.ParcelFileDescriptor
import android.util.Log
import com.peace.mind.AppConstants
import com.peace.mind.R
import com.peace.mind.generics.ServiceBinder
import com.peace.mind.helpers.device.NotificationHelper
import com.peace.mind.helpers.storage.SharedPrefsHelper
import java.io.IOException
import java.net.InetSocketAddress
import java.net.SocketAddress
import java.net.SocketException
import java.nio.channels.DatagramChannel
import java.util.concurrent.atomic.AtomicReference


/**
 * A VPN service with two independent, mutually-exclusive modes:
 *
 * 1. **Internet Blocker** (default, unchanged from earlier versions):
 *    fully blocks internet access for a specific set of apps by routing
 *    only their traffic into a tunnel that never forwards anything.
 *
 * 2. **VPN website filter**: filters DNS (website) lookups system-wide
 *    against a domain blocklist, via [DnsFilterEngine]. See that class
 *    for the safety rationale behind why this only touches DNS traffic.
 *
 * Because Android only allows a single active [VpnService] tunnel at a
 * time, only one of these two modes can be active at once. If the DNS
 * website filter is enabled, it takes priority over the per-app
 * internet blocker while both are configured.
 */
class MindfulVpnService : VpnService() {
    companion object {
        private const val TAG = "Mindful.VpnService"
    }

    private val mBinder = ServiceBinder(this@MindfulVpnService)
    private val mAtomicVpnThread = AtomicReference<Thread?>(null)
    private var mBlockedApps: Set<String> = HashSet(0)
    private var mBlockedDomains: Set<String> = HashSet(0)
    private var mDnsFilterEnabled: Boolean = false
    private var mVpnInterface: ParcelFileDescriptor? = null
    private var mIsServiceRunning = false
    private var mDnsFilterEngine: DnsFilterEngine? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        if (intent?.action == ServiceBinder.ACTION_START_MINDFUL_SERVICE) {
            startFgService()
            return START_STICKY
        }

        stopAndDisposeService()
        return START_NOT_STICKY
    }


    private fun startFgService() {
        if (mIsServiceRunning) return
        try {
            startForeground(
                AppConstants.VPN_SERVICE_NOTIFICATION_ID,
                NotificationHelper.buildFgServiceNotification(
                    this,
                    getString(R.string.internet_blocker_running_notification_info)
                )
            )
            mIsServiceRunning = true
            Log.d(TAG, "startFgService: VPN service started successfully")
        } catch (e: Exception) {
            Log.e(TAG, "startFgService: Failed to start VPN service", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this, e)
            stopAndDisposeService()
        }
    }

    /**
     * Restarts the VPN connection by disconnecting and then reconnecting the VPN.
     */
    private fun reconnectVpn() {
        disconnectVpn()
        connectVpn()
        Log.d(TAG, "reconnectVpn: VPN reconnected successfully")
    }

    /**
     * Establishes a VPN connection based on the active mode (DNS website
     * filter takes priority if enabled, otherwise per-app internet
     * blocking). If neither has anything configured, the service stops.
     */
    private fun connectVpn() {
        if (!mDnsFilterEnabled && mBlockedApps.isEmpty()) {
            Log.w(TAG, "connectVpn: Nothing to do (no blocked apps, DNS filter off), Exiting")
            stopAndDisposeService()
            return
        }

        val newThread = Thread(vpnThread, TAG)
        setVpnThread(newThread)
        newThread.start()
    }

    /**
     * Disconnects the VPN connection if established.
     */
    private fun disconnectVpn() {
        try {
            mDnsFilterEngine?.stop()
            mDnsFilterEngine = null

            if (mVpnInterface != null) {
                mVpnInterface!!.close()
                mVpnInterface = null
                setVpnThread(null)
                Log.d(TAG, "disconnectVpn: VPN disconnected successfully")
            }
        } catch (e: IOException) {
            Log.e(TAG, "disconnectVpn: Failed to disconnect VPN", e)
        }
    }

    /**
     * Stops the foreground service and disconnects the VPN.
     */
    private fun stopAndDisposeService() {
        disconnectVpn()
        stopSelf()
    }

    /**
     * Returns a Runnable that configures and establishes the VPN connection
     * for whichever mode is currently active.
     */
    private val vpnThread: Runnable
        get() = Runnable {
            if (mDnsFilterEnabled) {
                connectDnsFilterVpn()
            } else {
                connectAppBlockerVpn()
            }
        }

    /**
     * Mode 1: per-app internet blocker (original behavior, unchanged).
     * Routes only the blocked apps' traffic into a tunnel that never
     * forwards any packets, effectively cutting off their internet.
     */
    private fun connectAppBlockerVpn() {
        try {
            DatagramChannel.open().use { tunnel ->
                check(this@MindfulVpnService.protect(tunnel.socket())) { "Cannot protect the vpn socket tunnel" }
                val serverAddress: SocketAddress = InetSocketAddress("localhost", 0)
                tunnel.connect(serverAddress)
                tunnel.configureBlocking(false)

                val builder = this@MindfulVpnService.Builder()
                builder.addAddress("192.168.0.0", 24)
                builder.addRoute("0.0.0.0", 0)

                // Add blocked app's packages
                for (packageName in mBlockedApps) {
                    try {
                        builder.addAllowedApplication(packageName)
                    } catch (e: PackageManager.NameNotFoundException) {
                        Log.w(TAG, "connectAppBlockerVpn: Cannot find app with package $packageName")
                    }
                }
                synchronized(this@MindfulVpnService) {
                    mVpnInterface = builder.establish()
                    Log.d(TAG, "connectAppBlockerVpn: VPN connected successfully")
                }
            }
        } catch (e: SocketException) {
            Log.e(TAG, "connectAppBlockerVpn: Cannot use socket for VPN", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        } catch (e: IOException) {
            Log.e(TAG, "connectAppBlockerVpn: VPN connection failed, exiting", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        } catch (e: IllegalArgumentException) {
            Log.e(TAG, "connectAppBlockerVpn: VPN connection failed, exiting", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        } catch (e: Exception) {
            Log.e(TAG, "connectAppBlockerVpn: Something went wrong", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        }
    }

    /**
     * Mode 2: system-wide DNS website filter. Routes ONLY a single
     * virtual DNS-server address through the tunnel (see
     * [DnsFilterEngine.VIRTUAL_DNS_ADDRESS]) - all other traffic bypasses
     * the VPN entirely. See [DnsFilterEngine] for full rationale.
     */
    private fun connectDnsFilterVpn() {
        try {
            val builder = this@MindfulVpnService.Builder()
            builder.addAddress(DnsFilterEngine.VIRTUAL_DNS_ADDRESS, 32)
            builder.addDnsServer(DnsFilterEngine.VIRTUAL_DNS_ADDRESS)
            builder.addRoute(DnsFilterEngine.VIRTUAL_DNS_ADDRESS, 32)

            synchronized(this@MindfulVpnService) {
                val vpnInterface = builder.establish()
                if (vpnInterface == null) {
                    Log.e(TAG, "connectDnsFilterVpn: Failed to establish VPN interface")
                    stopAndDisposeService()
                    return
                }

                mVpnInterface = vpnInterface
                val engine = DnsFilterEngine(this@MindfulVpnService)
                engine.blockedDomains = mBlockedDomains
                mDnsFilterEngine = engine
                engine.start(vpnInterface)

                Log.d(TAG, "connectDnsFilterVpn: DNS website filter VPN connected successfully")
            }
        } catch (e: IOException) {
            Log.e(TAG, "connectDnsFilterVpn: VPN connection failed, exiting", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        } catch (e: IllegalArgumentException) {
            Log.e(TAG, "connectDnsFilterVpn: VPN connection failed, exiting", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        } catch (e: Exception) {
            Log.e(TAG, "connectDnsFilterVpn: Something went wrong", e)
            SharedPrefsHelper.insertCrashLogToPrefs(this@MindfulVpnService, e)
            stopAndDisposeService()
        }
    }

    /**
     * Sets the current VPN thread, interrupting the previous thread if necessary.
     *
     * @param thread The new thread to be set.
     */
    private fun setVpnThread(thread: Thread?) {
        val oldThread = mAtomicVpnThread.getAndSet(thread)
        oldThread?.interrupt()
    }

    /**
     * Updates the list of blocked apps and restarts the VPN service if needed.
     * Has no effect while the DNS website filter mode is active - the two
     * modes are mutually exclusive since only one VPN tunnel can run at once.
     */
    fun updateBlockedApps(blockedApps: Set<String>) {
        mBlockedApps = blockedApps
        Log.d(TAG, "updateBlockedApps: Internet blocked apps updated successfully")
        if (mDnsFilterEnabled) return
        if (mBlockedApps.isEmpty()) stopAndDisposeService()
        else reconnectVpn()
    }

    /**
     * Enables or disables the system-wide DNS website filter and/or
     * updates its domain blocklist. When enabling with a non-empty
     * domain set, this takes over the VPN tunnel from the per-app
     * internet blocker (if that was active). When disabling, control
     * reverts to whatever the per-app blocker's current configuration is.
     */
    fun updateDnsWebsiteFilter(enabled: Boolean, blockedDomains: Set<String>) {
        mBlockedDomains = blockedDomains
        mDnsFilterEnabled = enabled && blockedDomains.isNotEmpty()

        Log.d(TAG, "updateDnsWebsiteFilter: enabled=$mDnsFilterEnabled, domains=${blockedDomains.size}")

        if (mDnsFilterEnabled) {
            reconnectVpn()
        } else {
            /// Fall back to app-blocker mode (or stop entirely if that
            /// has nothing configured either).
            if (mBlockedApps.isEmpty()) {
                stopAndDisposeService()
            } else {
                reconnectVpn()
            }
        }

        /// If already running in DNS filter mode, push the updated
        /// domain set to the live engine without a full reconnect.
        mDnsFilterEngine?.blockedDomains = mBlockedDomains
    }

    override fun onDestroy() {
        disconnectVpn()
        stopForeground(STOP_FOREGROUND_REMOVE)
        Log.d(TAG, "onDestroy: VPN service destroyed successfully")
        super.onDestroy()
    }

    override fun onBind(intent: Intent): IBinder? {
        return if (intent.action == ServiceBinder.ACTION_BIND_TO_MINDFUL) mBinder else null
    }
}
