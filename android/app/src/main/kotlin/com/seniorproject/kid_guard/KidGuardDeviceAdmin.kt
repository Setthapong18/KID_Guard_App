package com.seniorproject.kid_guard

// ==================== KidGuardDeviceAdmin ====================
// Device Admin Receiver สำหรับป้องกันการถอนการติดตั้งแอป
//
// เมื่อ activate แล้ว:
// - ปุ่ม Uninstall ในหน้า App Info จะเป็นสีเทา กดไม่ได้
// - ต้องปิด Device Admin ก่อนจึงจะลบแอปได้
// - การปิด Device Admin ต้องผ่าน PIN ผู้ปกครองในแอป

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent

class KidGuardDeviceAdmin : DeviceAdminReceiver() {

    /** แสดงข้อความเตือนเมื่อมีคนพยายามปิด Device Admin */
    override fun onDisableRequested(context: Context, intent: Intent): CharSequence {
        return "การปิดการป้องกันจะทำให้สามารถลบแอป KidGuard ได้ กรุณาปิดผ่านแอป KidGuard เท่านั้น"
    }

    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        SecurityLogger.info(context, "Device Admin enabled", null)
    }

    override fun onDisabled(context: Context, intent: Intent) {
        super.onDisabled(context, intent)
        SecurityLogger.info(context, "Device Admin disabled", null)
    }
}
