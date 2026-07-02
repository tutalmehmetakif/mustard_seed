package com.example.mustard_seed

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Ana ekran widget'ı ("Günün Ayeti" kartı).
 *
 * Flutter tarafında [WidgetService] (lib/features/home/data/widget_service.dart)
 * tarafından yazılan verileri (verse_text, verse_reference, hijri_date,
 * moon_phase) okuyup gösterir. `home_widget` paketi bu SharedPreferences
 * köprüsünü otomatik kuruyor, biz sadece [onUpdate] içinde okuyup
 * RemoteViews'a basıyoruz.
 *
 * NOT: `es.antonborri.home_widget` paketi `home_widget` eklentisinin
 * kendi Android tarafıdır — `flutter pub get` sonrası bu import'un
 * çözülmediğini görürsen, `home_widget` paketinin yüklü sürümünde
 * paket adı değişmiş olabilir; o zaman `~/.pub-cache` içindeki
 * `home_widget` Android kaynağına bakıp gerçek paket adını buraya
 * yazman gerekir.
 */
class VerseWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val verseText = widgetData.getString(
                "verse_text",
                "Bir ayet gününüzü değiştirebilir.",
            )
            val verseReference = widgetData.getString("verse_reference", "")
            val hijriDate = widgetData.getString("hijri_date", "")
            val moonPhase = widgetData.getString("moon_phase", "Hilal")

            val views = RemoteViews(context.packageName, R.layout.verse_widget).apply {
                setTextViewText(R.id.verse_text, "\u201c$verseText\u201d")
                setTextViewText(R.id.verse_reference, verseReference)
                setTextViewText(R.id.hijri_date, hijriDate)
                setTextViewText(R.id.moon_phase, moonPhase)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}