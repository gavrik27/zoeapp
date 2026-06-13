package com.example.zoeapp

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast

class KioskAccessibilityService : AccessibilityService() {

    companion object {
        private const val PREFS_NAME = "KioskPrefs"
        private const val KEY_IS_ACTIVE = "isKioskActive"
        private const val TAG = "KioskService"

        fun isKioskModeActive(context: Context): Boolean {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            return prefs.getBoolean(KEY_IS_ACTIVE, false)
        }

        fun setKioskModeState(context: Context, active: Boolean) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().putBoolean(KEY_IS_ACTIVE, active).apply()
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Toast.makeText(this, "✅ SERVICIO ACTIVADO", Toast.LENGTH_LONG).show()
        Log.e(TAG, "========== SERVICIO CONECTADO ==========")

        // FORZAR a recibir eventos de cambio de ventana
        val info = AccessibilityServiceInfo()
        info.eventTypes = AccessibilityEvent.TYPES_ALL_MASK
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
        info.flags = AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        info.notificationTimeout = 50
        setServiceInfo(info)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        Log.e(TAG, "📢 EVENTO RECIBIDO: ${event?.eventType}")

        if (!isKioskModeActive(this)) {
            Log.e(TAG, "Modo kiosko NO activo, ignorando")
            return
        }

        val currentPackage = event?.packageName?.toString()
        Log.e(TAG, "Paquete actual: $currentPackage")
        Log.e(TAG, "Mi paquete: ${this.packageName}")

        if (currentPackage != null && currentPackage != this.packageName) {
            Log.e(TAG, "🚫 BLOQUEANDO SALIDA A: $currentPackage")

            val intent = packageManager.getLaunchIntentForPackage(this.packageName)
            intent?.let {
                it.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                startActivity(it)
                Log.e(TAG, "✅ FORZADO REGRESO A LA APP")
            }
        }
    }

    override fun onInterrupt() {
        Log.e(TAG, "⚠️ SERVICIO INTERRUMPIDO")
    }
}