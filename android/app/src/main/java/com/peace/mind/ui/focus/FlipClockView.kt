package com.peace.mind.ui.focus

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import android.view.Gravity
import android.view.View
import android.widget.LinearLayout

/**
 * Responsive container holding Mechanical 3D Flip Digit pairs (HH:MM:SS or MM:SS)
 * with mechanical colon dots between pairs.
 */
class FlipClockView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private val digitViews = mutableListOf<FlipDigitView>()
    private var isHoursVisible = false

    init {
        orientation = HORIZONTAL
        gravity = Gravity.CENTER
    }

    /**
     * Set remaining or elapsed seconds and update digit views accordingly.
     */
    fun setTimeSeconds(totalSeconds: Long, animate: Boolean = true) {
        val hours = (totalSeconds / 3600).toInt()
        val minutes = ((totalSeconds % 3600) / 60).toInt()
        val seconds = (totalSeconds % 60).toInt()

        val needsHours = hours > 0
        if (needsHours != isHoursVisible || digitViews.isEmpty()) {
            isHoursVisible = needsHours
            rebuildClockLayout()
        }

        val digits = if (isHoursVisible) {
            intArrayOf(
                hours / 10, hours % 10,
                minutes / 10, minutes % 10,
                seconds / 10, seconds % 10
            )
        } else {
            intArrayOf(
                minutes / 10, minutes % 10,
                seconds / 10, seconds % 10
            )
        }

        for (i in digits.indices) {
            if (i < digitViews.size) {
                digitViews[i].setDigit(digits[i], animate)
            }
        }
    }

    private fun rebuildClockLayout() {
        removeAllViews()
        digitViews.clear()

        val displayMetrics = resources.displayMetrics
        val screenWidth = displayMetrics.widthPixels
        val pairCount = if (isHoursVisible) 3 else 2

        // Dynamically compute responsive card size based on screen width
        val availableWidth = screenWidth * 0.85f
        val cardWidth = ((availableWidth / (pairCount * 2 + (pairCount - 1) * 0.5f))).toInt().coerceIn(70, 220)
        val cardHeight = (cardWidth * 1.5f).toInt()
        val marginSmall = (cardWidth * 0.08f).toInt().coerceAtLeast(4)
        val marginColon = (cardWidth * 0.2f).toInt().coerceAtLeast(8)

        fun createDigitView(): FlipDigitView {
            val digit = FlipDigitView(context)
            val params = LayoutParams(cardWidth, cardHeight).apply {
                setMargins(marginSmall, 0, marginSmall, 0)
            }
            digit.layoutParams = params
            digitViews.add(digit)
            return digit
        }

        fun createColonView(): View {
            val colon = ColonView(context)
            val params = LayoutParams((cardWidth * 0.35f).toInt(), cardHeight).apply {
                setMargins(marginColon, 0, marginColon, 0)
            }
            colon.layoutParams = params
            return colon
        }

        if (isHoursVisible) {
            addView(createDigitView())
            addView(createDigitView())
            addView(createColonView())
        }

        addView(createDigitView())
        addView(createDigitView())
        addView(createColonView())

        addView(createDigitView())
        addView(createDigitView())
    }

    private class ColonView(context: Context) : View(context) {
        private val dotPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#B0B0C0")
            style = Paint.Style.FILL
        }

        override fun onDraw(canvas: Canvas) {
            super.onDraw(canvas)
            val cx = width / 2f
            val dotRadius = width * 0.18f
            canvas.drawCircle(cx, height * 0.35f, dotRadius, dotPaint)
            canvas.drawCircle(cx, height * 0.65f, dotRadius, dotPaint)
        }
    }
}
