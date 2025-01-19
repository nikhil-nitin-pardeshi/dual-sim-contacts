// SimUtils.kt

package com.example.dual_sim_info

import android.content.Context
import android.os.Build
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import android.util.Log
import androidx.annotation.RequiresApi

object SimUtils {

    private const val TAG = "SimUtils"

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP_MR1)
    fun getSimDetails(context: Context): List<Map<String, String>> {
        val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

        val simDetails = mutableListOf<Map<String, String>>()

        val subscriptionInfoList = subscriptionManager.activeSubscriptionInfoList
        Log.d(TAG, "Subscription Info List Size: ${subscriptionInfoList?.size ?: 0}")

        subscriptionInfoList?.forEach { subscriptionInfo ->
            val simInfo = mutableMapOf<String, String>()
            simInfo["subscriptionInfo"] = subscriptionInfo.toString()
            simInfo["carrierName"] = subscriptionInfo.carrierName?.toString() ?: ""
            simInfo["countryIso"] = subscriptionInfo.countryIso ?: ""
            simInfo["iccid"] = subscriptionInfo.iccId ?: ""

            val phoneNumber = getPhoneNumber(context, subscriptionInfo)
            simInfo["number"] = phoneNumber ?: "N/A"

            simDetails.add(simInfo)
            Log.d(TAG, "SIM Info: $simInfo")
        }

        return simDetails
    }

    private fun getPhoneNumber(context: Context, subscriptionInfo: SubscriptionInfo): String? {
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        return try {
            val phoneNumber = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                telephonyManager.createForSubscriptionId(subscriptionInfo.subscriptionId).line1Number
            } else {
                telephonyManager.line1Number
            }
            phoneNumber?.takeLast(10)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting phone number", e)
            null
        }
    }
}
