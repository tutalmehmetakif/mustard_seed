package com.hardaltanesi.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.Rect
import android.graphics.RectF
import android.net.Uri
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Ana ekran widget'ı ("Günün Ayeti" kartı).
 *
 * "Fotoğraflı" stilinde, kullanıcı kendi fotoğrafını seçmediyse: o
 * günün GERÇEK ay evresine ait NASA fotoğrafı (30 günlük yerel set,
 * res/drawable-nodpi/moon_day_0..29) hem bulanık/karartılmış arka plan
 * hem de dairesel, net bir "madalyon" olarak gösteriliyor. Widget
 * genişliğine göre (küçük/geniş) farklı layout kullanılıyor — Android'de
 * iOS'taki gibi otomatik "family" ayrımı olmadığı için bunu
 * AppWidgetManager'ın verdiği boyut bilgisiyle (OPTION_APPWIDGET_MIN_WIDTH)
 * kendimiz belirliyoruz.
 */
class VerseWidgetProvider : HomeWidgetProvider() {

    companion object {

        private const val SMALL_WIDTH_THRESHOLD_DP = 200

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

           // Widget artık yapılandırma ekranı sunmuyor — kullanıcı ekler eklemez
// direkt "Fotoğraflı" stili (gerçek ay fotoğrafı ya da kullanıcının
// kendi fotoğrafı) gösteriliyor.
renderPhoto(context, appWidgetManager, widgetId, widgetData, verseText, verseReference, verseId)
        }

        private fun renderMinimal(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int,
            verseText: String?,
            verseReference: String?,
        ) {
            val views = RemoteViews(context.packageName, R.layout.verse_widget_minimal).apply {
                setTextViewText(R.id.verse_text, "\u201c$verseText\u201d")
                setTextViewText(R.id.verse_reference, verseReference)
            }
            attachClickIntent(context, views, widgetId, "")
            appWidgetManager.updateAppWidget(widgetId, views)
        }

        private fun renderMoonPhase(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int,
            verseText: String?,
            verseReference: String?,
            hijriDate: String?,
            moonPhase: String?,
            verseId: String?,
        ) {
            val views = RemoteViews(context.packageName, R.layout.verse_widget_moon).apply {
                setTextViewText(R.id.verse_text, "\u201c$verseText\u201d")
                setTextViewText(R.id.verse_reference, verseReference)
                setTextViewText(R.id.hijri_date, hijriDate)
                setTextViewText(R.id.moon_phase, moonPhase)
            }
            attachClickIntent(context, views, widgetId, verseId ?: "")
            appWidgetManager.updateAppWidget(widgetId, views)
        }

        private fun renderPhoto(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int,
            widgetData: SharedPreferences,
            verseText: String?,
            verseReference: String?,
            verseId: String?,
        ) {
            val userPhotoPath = widgetData.getString("user_photo_path", null)

            if (!userPhotoPath.isNullOrEmpty()) {
                // Kullanıcı kendi fotoğrafını seçtiyse: eski davranış,
                // tam ekran doldurulmuş fotoğraf.
                val views = RemoteViews(context.packageName, R.layout.verse_widget_photo).apply {
                    setTextViewText(R.id.verse_text, "\u201c$verseText\u201d")
                    setTextViewText(R.id.verse_reference, verseReference)
                    val bitmap = decodeSampledBitmap(userPhotoPath, 400, 300)
                    if (bitmap != null) {
                        setImageViewBitmap(R.id.user_photo, bitmap)
                    }
                }
                attachClickIntent(context, views, widgetId, verseId ?: "")
                appWidgetManager.updateAppWidget(widgetId, views)
                return
            }

            // Kullanıcı fotoğraf seçmediyse: o günün gerçek NASA ay
            // fotoğrafı, widget genişliğine göre küçük/geniş layout ile.
            val moonDay = (widgetData.getString("moon_day", "15") ?: "15")
                .toIntOrNull()?.coerceIn(0, 29) ?: 15

            val minWidthDp = appWidgetManager
                .getAppWidgetOptions(widgetId)
                .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 260)
            val isSmall = minWidthDp < SMALL_WIDTH_THRESHOLD_DP

            val layoutId = if (isSmall) {
                R.layout.verse_widget_photo_moon_small
            } else {
                R.layout.verse_widget_photo_moon_medium
            }

            val views = RemoteViews(context.packageName, layoutId).apply {
                setTextViewText(R.id.verse_text, "\u201c$verseText\u201d")
                setTextViewText(R.id.verse_reference, verseReference)

                val rawBitmap = loadMoonDayBitmap(context, moonDay)
                if (rawBitmap != null) {
                    setImageViewBitmap(R.id.moon_background, darkenBitmap(rawBitmap))
                    setImageViewBitmap(R.id.moon_circle, circularBitmap(rawBitmap))
                }
            }
            attachClickIntent(context, views, widgetId, verseId ?: "")
            appWidgetManager.updateAppWidget(widgetId, views)
        }

        private fun attachClickIntent(
            context: Context,
            views: RemoteViews,
            widgetId: Int,
            verseId: String,
        ) {
            val uri = Uri.parse("io.supabase.mustardseed://verse-detail?id=$verseId")
            val intent = Intent(Intent.ACTION_VIEW, uri)
            val pendingIntent = PendingIntent.getActivity(
                context,
                widgetId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
        }

        /// "moon_day_<N>" adındaki drawable kaynağını, kayıp/eksik olma
        /// ihtimaline karşı güvenli şekilde yükler.
        private fun loadMoonDayBitmap(context: Context, day: Int): Bitmap? {
            val resName = "moon_day_$day"
            val resId = context.resources.getIdentifier(
                resName, "drawable", context.packageName,
            )
            if (resId == 0) return null
            return try {
                val options = BitmapFactory.Options().apply { inSampleSize = 2 }
                BitmapFactory.decodeResource(context.resources, resId, options)
            } catch (e: Exception) {
                null
            }
        }

        /// Görseli, widget'ın koyu temasına uygun karartılmış (bulanık
        /// blur yerine, tüm Android sürümlerinde güvenilir çalışan bir
        /// yarı saydam siyah katman) hâline çevirir — arka plan için.
        private fun darkenBitmap(source: Bitmap, alpha: Int = 165): Bitmap {
            val output = source.copy(Bitmap.Config.ARGB_8888, true)
            val canvas = Canvas(output)
            val paint = Paint().apply { color = Color.argb(alpha, 0, 0, 0) }
            canvas.drawRect(0f, 0f, output.width.toFloat(), output.height.toFloat(), paint)
            return output
        }

        /// Görseli, ince altın kenarlıklı bir daire içine kırpar — iOS'taki
        /// `.clipShape(Circle())` karşılığı. RemoteViews'te XML üzerinden
        /// dairesel kırpma desteklenmediği için bitmap Canvas ile elle
        /// çiziliyor.
        private fun circularBitmap(
            source: Bitmap,
            borderColor: Int = Color.parseColor("#66C9A227"),
        ): Bitmap {
            val size = minOf(source.width, source.height)
            val output = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(output)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)
            val srcRect = Rect(
                (source.width - size) / 2,
                (source.height - size) / 2,
                (source.width - size) / 2 + size,
                (source.height - size) / 2 + size,
            )
            val dstRect = Rect(0, 0, size, size)
            val rectF = RectF(0f, 0f, size.toFloat(), size.toFloat())

            canvas.drawOval(rectF, paint)
            paint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)
            canvas.drawBitmap(source, srcRect, dstRect, paint)

            paint.xfermode = null
            paint.style = Paint.Style.STROKE
            paint.strokeWidth = size * 0.02f
            paint.color = borderColor
            canvas.drawOval(rectF, paint)

            return output
        }

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

    /// Kullanıcı widget'ı ana ekranda büyütüp/küçülttüğünde sistem bunu
    /// çağırır — küçük/geniş layout arasında ANINDA (bir sonraki
    /// zamanlı güncellemeyi beklemeden) geçiş yapılmasını sağlar.
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateWidgetStatic(context, appWidgetManager, appWidgetId)
    }
}