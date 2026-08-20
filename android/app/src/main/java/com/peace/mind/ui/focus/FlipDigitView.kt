package com.peace.mind.ui.focus

import android.animation.Animator
import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Camera
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.provider.Settings
import android.util.AttributeSet
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import kotlin.math.min

/**
 * A custom 3D mechanical split-flap flip digit view.
 * Renders upper and lower flip panels, center divider, dark dimensional surface,
 * subtle bevels/shadows, and realistic 3D perspective rotation using android.graphics.Camera.
 */
class FlipDigitView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {

    var currentDigit: Int = 0
        private set

    private var targetDigit: Int = 0
    private var animationProgress: Float = 0f
    private var isAnimating: Boolean = false

    // Paints
    private val cardBackgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#1C1C22")
        style = Paint.Style.FILL
    }

    private val cardBorderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#2C2C36")
        style = Paint.Style.STROKE
        strokeWidth = 3f
    }

    private val dividerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#0A0A0D")
        style = Paint.Style.FILL
    }

    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#F0F0F5")
        typeface = Typeface.MONOSPACE
        textAlign = Paint.Align.CENTER
        isFakeBoldText = true
    }

    private val shadowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#80000000")
        style = Paint.Style.FILL
    }

    private val camera = Camera()
    private val matrix3d = Matrix()
    private val animator = ValueAnimator.ofFloat(0f, 1f).apply {
        duration = 450L
        interpolator = AccelerateDecelerateInterpolator()
        addUpdateListener { animation ->
            animationProgress = animation.animatedValue as Float
            invalidate()
        }
        addListener(object : Animator.AnimatorListener {
            override fun onAnimationStart(animation: Animator) { isAnimating = true }
            override fun onAnimationEnd(animation: Animator) {
                currentDigit = targetDigit
                animationProgress = 0f
                isAnimating = false
                invalidate()
            }
            override fun onAnimationCancel(animation: Animator) {
                currentDigit = targetDigit
                animationProgress = 0f
                isAnimating = false
                invalidate()
            }
            override fun onAnimationRepeat(animation: Animator) {}
        })
    }

    /**
     * Set the digit to display. If changed, triggers 3D flip animation.
     */
    fun setDigit(digit: Int, animate: Boolean = true) {
        if (digit == currentDigit && !isAnimating) return
        targetDigit = digit

        val animatorDurationScale = Settings.Global.getFloat(
            context.contentResolver,
            Settings.Global.TRANSITION_ANIMATION_SCALE,
            1.0f
        )

        if (!animate || animatorDurationScale == 0f) {
            currentDigit = digit
            animationProgress = 0f
            invalidate()
        } else {
            if (animator.isRunning) animator.cancel()
            animator.start()
        }
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        val w = width.toFloat()
        val h = height.toFloat()
        if (w <= 0 || h <= 0) return

        textPaint.textSize = h * 0.65f
        val textY = (h / 2f) - ((textPaint.descent() + textPaint.ascent()) / 2f)

        val cardBounds = RectF(0f, 0f, w, h)
        val topHalfBounds = RectF(0f, 0f, w, h / 2f)
        val bottomHalfBounds = RectF(0f, h / 2f, w, h)

        if (!isAnimating || animationProgress == 0f) {
            drawFullCard(canvas, cardBounds, currentDigit, textY, w, h)
            return
        }

        // --- ANIMATING STATE ---
        // 1. Draw static top half (showing target digit)
        canvas.save()
        canvas.clipRect(topHalfBounds)
        drawCardBase(canvas, cardBounds)
        canvas.drawText(targetDigit.toString(), w / 2f, textY, textPaint)
        canvas.restore()

        // 2. Draw static bottom half (showing current digit)
        canvas.save()
        canvas.clipRect(bottomHalfBounds)
        drawCardBase(canvas, cardBounds)
        canvas.drawText(currentDigit.toString(), w / 2f, textY, textPaint)
        canvas.restore()

        // 3. Draw 3D Flipping Flap
        if (animationProgress <= 0.5f) {
            // Top flap flipping downwards (from 0 to -90 deg)
            val rotationAngle = -animationProgress * 2f * 90f
            canvas.save()
            canvas.clipRect(topHalfBounds)

            camera.save()
            camera.rotateX(rotationAngle)
            camera.getMatrix(matrix3d)
            camera.restore()

            matrix3d.preTranslate(-w / 2f, -h / 2f)
            matrix3d.postTranslate(w / 2f, h / 2f)
            canvas.concat(matrix3d)

            drawCardBase(canvas, cardBounds)
            canvas.drawText(currentDigit.toString(), w / 2f, textY, textPaint)

            // Subtle drop shadow on top flap
            shadowPaint.alpha = (animationProgress * 2f * 120).toInt().coerceIn(0, 255)
            canvas.drawRect(topHalfBounds, shadowPaint)
            canvas.restore()
        } else {
            // Bottom flap revealing new digit (from 90 to 0 deg)
            val rotationAngle = 90f - (animationProgress - 0.5f) * 2f * 90f
            canvas.save()
            canvas.clipRect(bottomHalfBounds)

            camera.save()
            camera.rotateX(rotationAngle)
            camera.getMatrix(matrix3d)
            camera.restore()

            matrix3d.preTranslate(-w / 2f, -h / 2f)
            matrix3d.postTranslate(w / 2f, h / 2f)
            canvas.concat(matrix3d)

            drawCardBase(canvas, cardBounds)
            canvas.drawText(targetDigit.toString(), w / 2f, textY, textPaint)

            // Shadow fading out
            shadowPaint.alpha = ((1f - (animationProgress - 0.5f) * 2f) * 120).toInt().coerceIn(0, 255)
            canvas.drawRect(bottomHalfBounds, shadowPaint)
            canvas.restore()
        }

        // Draw Center Horizontal Seam Divider
        canvas.drawRect(0f, (h / 2f) - 2f, w, (h / 2f) + 2f, dividerPaint)
    }

    private fun drawFullCard(canvas: Canvas, bounds: RectF, digit: Int, textY: Float, w: Float, h: Float) {
        drawCardBase(canvas, bounds)
        canvas.drawText(digit.toString(), w / 2f, textY, textPaint)
        // Center divider line
        canvas.drawRect(0f, (h / 2f) - 2f, w, (h / 2f) + 2f, dividerPaint)
    }

    private fun drawCardBase(canvas: Canvas, bounds: RectF) {
        val cornerRadius = 12f
        canvas.drawRoundRect(bounds, cornerRadius, cornerRadius, cardBackgroundPaint)
        canvas.drawRoundRect(bounds, cornerRadius, cornerRadius, cardBorderPaint)
    }
}
