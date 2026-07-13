package com.hardaltanesi.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Ana ekran widget'ı ("Günün Ayeti" kartı).
 *
 * Flutter tarafında [WidgetService] (lib/features/home/data/widget_service.dart)
 * tarafından yazılan verileri (verse_id, verse_text, verse_reference,
 * hijri_date, moon_phase, user_photo_path) okuyup gösterir. Widget'a
 * dokununca uygulamayı "io.supabase.mustardseed://verse-detail?id=..."
 * linkiyle açar — main.dart'taki AppLinks dinleyicisi bunu yakalayıp
 * Ayet Açıklaması ekranına yönlendiriyor.
 *
 * Görsel STİL (Minimal / Ay Evreli / Fotoğraflı) kullanıcı tarafından
 * [VerseWidgetConfigureActivity] üzerinden seçilir ve widget ID'sine özel
 * ayrı bir SharedPreferences'ta saklanır.
 */
class VerseWidgetProvider : HomeWidgetProvider() {

    companion object {

        /**
         * Configure Activity'den de çağrılabilmesi için static bir
         * güncelleme fonksiyonu.
         */
        fun updateWidgetStatic(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)
            renderWidget(context, appWidgetManager, appWidgetId, widgetData)
        }

        private fun renderWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int,
            widgetData: SharedPreferences,
        ) {
            val verseId = widgetData.getString("verse_id", "")
            val verseText = widgetData.getString(
                "verse_text",
                "Bir ayet gününüzü değiştirebilir.",
            )
            val verseReference = widgetData.getString("verse_reference", "")
            val hijriDate = widgetData.getString("hijri_date", "")
            val moonPhase = widgetData.getString("moon_phase", "Hilal")

            val style = VerseWidgetConfigureActivity.getStyle(context, widgetId)
            val layoutId = when (style) {
                "minimal" -> R.layout.verse_widget_minimal
                "photo" -> R.layout.verse_widget_photo
                else -> R.layout.verse_widget_moon
            }

            val views = RemoteViews(context.packageName, layoutId).apply {
                setTextViewText(R.id.verse_text, "\u201c$verseText\u201d")
                setTextViewText(R.id.verse_reference, verseReference)

                if (style == "moon") {
                    setTextViewText(R.id.hijri_date, hijriDate)
                    setTextViewText(R.id.moon_phase, moonPhase)
                }

                if (style == "photo") {
    val photoPath = widgetData.getString("user_photo_path", null)
    if (!photoPath.isNullOrEmpty()) {
        val bitmap = decodeSampledBitmap(photoPath, 400, 300)
        if (bitmap != null) {
            setImageViewBitmap(R.id.user_photo, bitmap)
        } else {
            setImageViewResource(R.id.user_photo, pickDefaultBackgroundResId())
        }
    } else {
        setImageViewResource(R.id.user_photo, pickDefaultBackgroundResId())
    }
}

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

        private val defaultBackgroundResIds = listOf(
    R.drawable.widget_default_bg_1,
    R.drawable.widget_default_bg_2,
    R.drawable.widget_default_bg_3,
    R.drawable.widget_default_bg_4,
    R.drawable.widget_default_bg_5,
)

/**
 * Kullanıcı henüz kendi fotoğrafını seçmediyse, güne göre (yılın kaçıncı
 * günü) döngüsel olarak hazır görsellerden birini seçer — böylece
 * "Fotoğraflı" stil boş/karartma-only görünmez, her gün ayetle birlikte
 * arka plan da değişir.
 */
private fun pickDefaultBackgroundResId(): Int {
    val dayOfYear = java.util.Calendar.getInstance()
        .get(java.util.Calendar.DAY_OF_YEAR)
    return defaultBackgroundResIds[dayOfYear % defaultBackgroundResIds.size]
}

        /**
         * Fotoğrafı widget'a göndermeden önce küçültür. RemoteViews üzerinden
         * (IPC/Binder ile) taşınan veri ~1MB ile sınırlı — image_picker'dan
         * gelen orijinal çözünürlüklü (birkaç MB'lık) fotoğrafı doğrudan
         * göndermek "TransactionTooLargeException" ile widget host'un/
         * uygulamanın sessizce çökmesine yol açıyordu. Bu fonksiyon, dosyayı
         * önce boyutlarını okuyup (decode etmeden), gereken oranda
         * küçültülmüş halde tekrar decode ediyor.
         */
        private fun decodeSampledBitmap(
            path: String,
            reqWidth: Int,
            reqHeight: Int,
        ): Bitmap? {
            return try {
                val boundsOptions = BitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                }
                BitmapFactory.decodeFile(path, boundsOptions)

                var inSampleSize = 1
                val height = boundsOptions.outHeight
                val width = boundsOptions.outWidth
                if (height > reqHeight || width > reqWidth) {
                    val halfHeight = height / 2
                    val halfWidth = width / 2
                    while ((halfHeight / inSampleSize) >= reqHeight &&
                        (halfWidth / inSampleSize) >= reqWidth
                    ) {
                        inSampleSize *= 2
                    }
                }

                val finalOptions = BitmapFactory.Options().apply {
                    this.inSampleSize = inSampleSize
                }
                BitmapFactory.decodeFile(path, finalOptions)
            } catch (e: Exception) {
                null
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            renderWidget(context, appWidgetManager, widgetId, widgetData)
        }
    }
}