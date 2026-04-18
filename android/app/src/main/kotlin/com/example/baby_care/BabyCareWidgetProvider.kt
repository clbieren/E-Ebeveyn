package com.example.baby_care

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class BabyCareWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.widget_home).apply {
                
                // Set default text values from shared preferences saved by Flutter
                val title = widgetData.getString("widget_title_text", "Bebeğim'in Durumu")
                setTextViewText(R.id.widget_title, title)

                val insight = widgetData.getString("ai_insight", "Yükleniyor...")
                setTextViewText(R.id.text_insight, insight)
                
                val sleepBtnText = widgetData.getString("sleep_btn_text", "💤 Uyut")
                setTextViewText(R.id.button_sleep, sleepBtnText)

                val childId = widgetData.getString("child_id", "") ?: ""

                // Background intent for Breast Milk (Süt)
                val breastIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("babycare://log_feed?type=breast_milk&child_id=$childId")
                )
                setOnClickPendingIntent(R.id.button_sut, breastIntent)
                
                // Background intent for Formula (Mama)
                val formulaIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("babycare://log_feed?type=formula&child_id=$childId")
                )
                setOnClickPendingIntent(R.id.button_mama, formulaIntent)

                // Background intent for Sleep Toggle
                val sleepIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("babycare://toggle_sleep?child_id=$childId")
                )
                setOnClickPendingIntent(R.id.button_sleep, sleepIntent)

                // App Launch Intent on Widget Click (Open App)
                val launchIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_title, launchIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
