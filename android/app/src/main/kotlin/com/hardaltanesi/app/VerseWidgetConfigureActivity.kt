package com.hardaltanesi.app

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.RadioGroup

/**
 * Widget ana ekrana eklenirken kullanıcıya stil seçtiren ekran.
 * Seçim, widget ID'sine özel SharedPreferences'a yazılır (bir kullanıcı
 * birden fazla widget eklerse her biri kendi stilini hatırlar).
 *
 * NOT: AppCompatActivity YERİNE düz Activity kullanılıyor — Flutter
 * projelerinin varsayılan temaları Theme.AppCompat soyundan gelmediği
 * için AppCompatActivity burada anında çöküyordu (widget eklenir
 * eklenmez kayboluyordu). Bu ekran basit (RadioGroup + Button) olduğu
 * için AppCompat'a hiç ihtiyaç yok.
 */
class VerseWidgetConfigureActivity : Activity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    companion object {
        private const val PREFS_NAME = "com.hardaltanesi.app.widget.VerseWidgetProvider"
        private const val PREF_PREFIX_KEY = "verse_widget_style_"

        fun getStyle(context: Context, appWidgetId: Int): String {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            return prefs.getString(PREF_PREFIX_KEY + appWidgetId, "moon") ?: "moon"
        }

        fun saveStyle(context: Context, appWidgetId: Int, style: String) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().putString(PREF_PREFIX_KEY + appWidgetId, style).apply()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setResult(RESULT_CANCELED)
        setContentView(R.layout.widget_configure)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        val radioGroup = findViewById<RadioGroup>(R.id.style_radio_group)
        findViewById<android.widget.Button>(R.id.confirm_button).setOnClickListener {
            val style = when (radioGroup.checkedRadioButtonId) {
                R.id.style_minimal -> "minimal"
                R.id.style_photo -> "photo"
                else -> "moon"
            }
            saveStyle(this, appWidgetId, style)

            val appWidgetManager = AppWidgetManager.getInstance(this)
            VerseWidgetProvider.updateWidgetStatic(this, appWidgetManager, appWidgetId)

            val resultValue = Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            setResult(RESULT_OK, resultValue)
            finish()
        }
    }
}