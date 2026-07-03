package com.hardaltanesi.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Ana ekran widget'ı ("Günün Ayeti" kartı).
 *
 * Flutter tarafında [WidgetService] (lib/features/home/data/widget_service.dart)
 * tarafından yazılan verileri (verse_id, verse_text, verse_reference,
 * hijri_date, moon_phase) okuyup gösterir. Widget'a dokununca uygulamayı
 * "io.supabase.mustardseed://verse-detail?id=..." linkiyle açar —
 * main.dart'taki AppLinks dinleyicisi bunu yakalayıp Ayet Açıklaması
 * ekranına yönlendiriyor.
 */
class VerseWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val verseId = widgetData.getString("verse_id", "")
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

                val uri = Uri.parse("io.supabase.mustardseed://verse-detail?id=$verseId")
                val intent = Intent(Intent.ACTION_VIEW, uri)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    widgetId,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}