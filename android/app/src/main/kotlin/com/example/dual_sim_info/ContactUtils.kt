// ContactUtils.kt

package com.example.dual_sim_info

import android.content.Context
import android.database.Cursor
import android.provider.ContactsContract
import android.util.Log

object ContactUtils {

    private const val TAG = "ContactUtils"

    fun getContacts(context: Context): List<Map<String, String>> {
        val contactsList = mutableListOf<Map<String, String>>()
        val cursor: Cursor? = context.contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            null,
            null,
            null,
            null
        )

        cursor?.use {
            while (it.moveToNext()) {
                val contactName =
                    it.getString(it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME))
                val phoneNumber =
                    it.getString(it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER))

                val contactMap = mapOf("name" to contactName, "phone" to phoneNumber)
                contactsList.add(contactMap)
            }
        }

        return contactsList
    }
}
