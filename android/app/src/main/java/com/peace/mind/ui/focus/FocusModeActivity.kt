package com.peace.mind.ui.focus

import android.animation.AnimatorListenerAdapter
import android.app.Activity
import android.os.Bundle
import android.os.Handler
import android.os.Looper

import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.peace.mind.R
import com.peace.mind.helpers.storage.SharedPrefsHelper
import kotlin.math.max

/**
 * Full-screen, native Android Focus Mode activity with 3D mechanical flip clock.
 * Implements immersive edge-to-edge layout, absolute timestamp timer engine,
 * screen stay awake management, tap-to-reveal minimal controls with auto-hide,
 * and completion states.
 */
class FocusModeActivity : AppCompatActivity() {

    private lateinit var flipClockView: FlipClockView
    private lateinit var tvFocusLabel: TextView
    private lateinit var tvStatusText: TextView
    private lateinit var layoutControls: LinearLayout
    private lateinit var btnPauseResume: Button
    private lateinit var btnRestart: Button
    private lateinit var btnExit: Button

    private var startTimeMsEpoch: Long = 0L
    private var durationSecs: Int = 0
    private var isFiniteSession: Boolean = true
    private var isPaused: Boolean = false
    private var pauseStartTimeMs: Long = 0L
    private var totalPausedDurationMs: Long = 0L
    private var isCompleted: Boolean = false

    private val handler = Handler(Looper.getMainLooper())
    private val hideControlsRunnable = Runnable { hideControls() }

    private val timerRunnable = object : Runnable {
        override fun run() {
            if (!isPaused && !isCompleted) {
                updateTimerDisplay()
                handler.postDelayed(this, 1000L)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate()

        // Handle uncaught exceptions
        Thread.setDefaultUncaughtExceptionHandler { _, exception ->
            SharedPrefsHelper.insertCrashLogToPrefs(this, exception)
        }

        // Enable edge-to-edge immersive presentation
        WindowCompat.setDecorFitsSystemWindows(window, false)
        hideSystemUI()

        setContentView(R.layout.activity_focus_mode)

        // Read intent extras
        startTimeMsEpoch = intent.getLongExtra(EXTRA_START_TIME_EPOCH, System.currentTimeMillis())
        durationSecs = intent.getIntExtra(EXTRA_DURATION_SECS, 1500) // Default 25 min
        isFiniteSession = durationSecs > 0

        initViews()
        setupListeners()

        // Start timer update loop
        handler.post(timerRunnable)

        // Keep screen awake while active Focus Mode is running
        setScreenStayAwake(true)
    }

    private fun initViews() {
        flipClockView = findViewById(R.id.flipClockView)
        tvFocusLabel = findViewById(R.id.tvFocusLabel)
        tvStatusText = findViewById(R.id.tvStatusText)
        layoutControls = findViewById(R.id.layoutControls)
        btnPauseResume = findViewById(R.id.btnPauseResume)
        btnRestart = findViewById(R.id.btnRestart)
        btnExit = findViewById(R.id.btnExit)

        updateTimerDisplay()
    }

    private fun setupListeners() {
        // Tap screen to reveal controls
        findViewById<View>(R.id.rootFocusLayout).setOnClickListener {
            showControlsWithTimeout()
        }

        btnPauseResume.setOnClickListener {
            togglePauseResume()
            showControlsWithTimeout()
        }

        btnRestart.setOnClickListener {
            restartSession()
            showControlsWithTimeout()
        }

        btnExit.setOnClickListener {
            finishFocusMode()
        }
    }

    private fun updateTimerDisplay() {
        val now = System.currentTimeMillis()

        if (isFiniteSession) {
            val elapsedMs = (now - startTimeMsEpoch - totalPausedDurationMs)
            val remainingSecs = max(0L, durationSecs - (elapsedMs / 1000L))

            flipClockView.setTimeSeconds(remainingSecs, animate = true)

            if (remainingSecs <= 0L && !isCompleted) {
                onSessionComplete()
            }
        } else {
            val elapsedSecs = max(0L, (now - startTimeMsEpoch - totalPausedDurationMs) / 1000L)
            flipClockView.setTimeSeconds(elapsedSecs, animate = true)
        }
    }

    private fun togglePauseResume() {
        if (isCompleted) return

        if (!isPaused) {
            isPaused = true
            pauseStartTimeMs = System.currentTimeMillis()
            btnPauseResume.text = getString(R.string.focus_mode_resume)
            tvStatusText.visibility = View.VISIBLE
            tvStatusText.text = getString(R.string.focus_mode_paused)
            handler.removeCallbacks(timerRunnable)
            setScreenStayAwake(false)
        } else {
            isPaused = false
            totalPausedDurationMs += (System.currentTimeMillis() - pauseStartTimeMs)
            btnPauseResume.text = getString(R.string.focus_mode_pause)
            tvStatusText.visibility = View.GONE
            handler.post(timerRunnable)
            setScreenStayAwake(true)
        }
    }

    private fun restartSession() {
        startTimeMsEpoch = System.currentTimeMillis()
        totalPausedDurationMs = 0L
        isPaused = false
        isCompleted = false

        btnPauseResume.text = getString(R.string.focus_mode_pause)
        tvStatusText.visibility = View.GONE
        btnPauseResume.visibility = View.VISIBLE

        updateTimerDisplay()
        handler.removeCallbacks(timerRunnable)
        handler.post(timerRunnable)
        setScreenStayAwake(true)
    }

    private fun onSessionComplete() {
        isCompleted = true
        handler.removeCallbacks(timerRunnable)
        setScreenStayAwake(false)

        tvStatusText.visibility = View.VISIBLE
        tvStatusText.text = getString(R.string.focus_mode_session_complete)

        btnPauseResume.visibility = View.GONE
        btnRestart.text = getString(R.string.focus_mode_start_again)
        showControlsPermanently()
    }

    private fun showControlsWithTimeout() {
        handler.removeCallbacks(hideControlsRunnable)
        layoutControls.visibility = View.VISIBLE
        layoutControls.animate().alpha(1.0f).setDuration(200L).start()

        if (!isCompleted && !isPaused) {
            handler.postDelayed(hideControlsRunnable, 3000L)
        }
    }

    private fun showControlsPermanently() {
        handler.removeCallbacks(hideControlsRunnable)
        layoutControls.visibility = View.VISIBLE
        layoutControls.animate().alpha(1.0f).setDuration(200L).start()
    }

    private fun hideControls() {
        layoutControls.animate()
            .alpha(0.0f)
            .setDuration(200L)
            .withEndAction { layoutControls.visibility = View.GONE }
            .start()
    }

    private fun setScreenStayAwake(keepAwake: Boolean) {
        if (keepAwake) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }
    }

    private fun hideSystemUI() {
        val windowInsetsController = WindowCompat.getInsetsController(window, window.decorView)
        windowInsetsController.systemBarsBehavior =
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        windowInsetsController.hide(WindowInsetsCompat.Type.systemBars())
    }

    private fun finishFocusMode() {
        setScreenStayAwake(false)
        handler.removeCallbacksAndMessages(null)
        finish()
    }

    override fun onDestroy() {
        setScreenStayAwake(false)
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }

    companion object {
        const val EXTRA_START_TIME_EPOCH = "extra_start_time_epoch"
        const val EXTRA_DURATION_SECS = "extra_duration_secs"
    }
}
