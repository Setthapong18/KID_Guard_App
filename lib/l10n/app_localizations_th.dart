// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Kid Guard';

  @override
  String get goodMorning => 'สวัสดีตอนเช้า';

  @override
  String get goodAfternoon => 'สวัสดีตอนบ่าย';

  @override
  String get goodEvening => 'สวัสดีตอนเย็น';

  @override
  String get myChildren => 'ลูกหลานของฉัน';

  @override
  String get addChild => 'เพิ่มลูกหลาน';

  @override
  String get seeAll => 'ดูทั้งหมด';

  @override
  String get quickActions => 'เมนูด่วน';

  @override
  String get notifications => 'การแจ้งเตือน';

  @override
  String get profile => 'โปรไฟล์';

  @override
  String get settings => 'การตั้งค่า';

  @override
  String get language => 'ภาษา';

  @override
  String get appearance => 'การแสดงผล';

  @override
  String get appearanceSubtitle => 'ธีมและสี';

  @override
  String get connection => 'การเชื่อมต่อ';

  @override
  String get general => 'ทั่วไป';

  @override
  String get support => 'ช่วยเหลือ';

  @override
  String get account => 'บัญชี';

  @override
  String get helpCenter => 'ศูนย์ช่วยเหลือ';

  @override
  String get sendFeedback => 'ส่งข้อเสนอแนะ';

  @override
  String get about => 'เกี่ยวกับ';

  @override
  String get signOut => 'ออกจากระบบ';

  @override
  String get points => 'แต้ม';

  @override
  String get quickAdd => 'เพิ่มแต้มด่วน';

  @override
  String get redeemRewards => 'แลกของรางวัล';

  @override
  String get pointHistory => 'ประวัติแต้ม';

  @override
  String get noActivity => 'ไม่มีกิจกรรมในวันนี้';

  @override
  String get homework => 'การบ้าน';

  @override
  String get chores => 'งานบ้าน';

  @override
  String get goodBehavior => 'ความประพฤติดี';

  @override
  String get exercise => 'ออกกำลังกาย';

  @override
  String get iceCream => 'ไอศกรีม';

  @override
  String get gameTime => 'เวลาเล่นเกม';

  @override
  String get movie => 'ดูหนัง';

  @override
  String get newToy => 'ของเล่นใหม่';

  @override
  String get stayUp => 'นอนดึกได้';

  @override
  String get parkTrip => 'ไปสวนสาธารณะ';

  @override
  String needMorePoints(Object amount) {
    return 'ต้องการอีก $amount แต้ม';
  }

  @override
  String get redeem => 'แลก';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String redeemConfirm(Object reward) {
    return 'แลก $reward?';
  }

  @override
  String redeemCost(Object cost) {
    return 'ใช้ $cost แต้ม';
  }

  @override
  String get redeemNow => 'แลกเลย';

  @override
  String get success => 'สำเร็จ!';

  @override
  String earnedReward(Object child, Object reward) {
    return '$child ได้รับ $reward';
  }

  @override
  String get close => 'ปิด';

  @override
  String pointsEarned(Object amount, Object reason) {
    return '+$amount แต้ม สำหรับ $reason';
  }

  @override
  String redeemed(Object reward) {
    return 'แลก: $reward';
  }

  @override
  String get editChildProfile => 'แก้ไขโปรไฟล์บุตรหลาน';

  @override
  String get addChildProfile => 'เพิ่มโปรไฟล์บุตรหลาน';

  @override
  String get updateProfileDesc => 'อัปเดตการตั้งค่าโปรไฟล์ของบุตรหลาน';

  @override
  String get createProfileDesc => 'สร้างโปรไฟล์เพื่อจัดการการใช้งานอุปกรณ์';

  @override
  String get childName => 'ชื่อบุตรหลาน';

  @override
  String get childAge => 'อายุ';

  @override
  String get dailyTimeLimit => 'จำกัดเวลาต่อวัน';

  @override
  String get unlimited => 'ไม่จำกัด';

  @override
  String get hours => 'ชั่วโมง';

  @override
  String get selectMode => 'เลือกโหมด';

  @override
  String get strictMode => 'โหมดเข้มงวด';

  @override
  String get strictModeDesc => 'บล็อกทุกแอพยกเว้นที่อนุญาต';

  @override
  String get flexibleMode => 'โหมดยืดหยุ่น';

  @override
  String get flexibleModeDesc => 'อนุญาตทุกแอพยกเว้นที่บล็อก';

  @override
  String get saveChanges => 'บันทึกการเปลี่ยนแปลง';

  @override
  String get createProfile => 'สร้างโปรไฟล์';

  @override
  String get fillAllFields => 'กรุณากรอกข้อมูลให้ครบถ้วน';

  @override
  String get enterValidAge => 'กรุณากรอกอายุที่ถูกต้อง';

  @override
  String get profileUpdated => 'อัปเดตโปรไฟล์เรียบร้อยแล้ว!';

  @override
  String profileCreated(Object name) {
    return 'สร้างโปรไฟล์สำหรับ $name เรียบร้อยแล้ว!';
  }

  @override
  String errorSavingProfile(Object error) {
    return 'เกิดข้อผิดพลาดในการบันทึก: $error';
  }

  @override
  String get accountProfile => 'บัญชีของฉัน';

  @override
  String get displayName => 'ชื่อที่แสดง';

  @override
  String get displayNameDesc => 'ชื่อที่จะแสดงในแอป';

  @override
  String get email => 'อีเมล';

  @override
  String get cannotBeChanged => 'ไม่สามารถเปลี่ยนได้';

  @override
  String get verified => 'ยืนยันแล้ว';

  @override
  String get password => 'รหัสผ่าน';

  @override
  String get changePasswordDesc => 'เปลี่ยนรหัสผ่านของคุณ';

  @override
  String get change => 'เปลี่ยน';

  @override
  String get currentPassword => 'รหัสผ่านปัจจุบัน';

  @override
  String get newPassword => 'รหัสผ่านใหม่';

  @override
  String get confirmNewPassword => 'ยืนยันรหัสผ่านใหม่';

  @override
  String get save => 'บันทึก';

  @override
  String get notSet => 'ยังไม่ได้ตั้งชื่อ';

  @override
  String get enterDisplayName => 'กรุณากรอกชื่อที่แสดง';

  @override
  String get nameLengthError => 'ชื่อต้องมีอย่างน้อย 2 ตัวอักษร';

  @override
  String displayNameChanged(Object name) {
    return 'ชื่อที่แสดงของคุณเปลี่ยนเป็น \"$name\".';
  }

  @override
  String get updateSuccess => 'อัปเดตเรียบร้อยแล้ว';

  @override
  String get updateError => 'เกิดข้อผิดพลาด กรุณาลองใหม่';

  @override
  String get enterCurrentPassword => 'กรุณากรอกรหัสผ่านปัจจุบัน';

  @override
  String get passwordLengthError => 'รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร';

  @override
  String get passwordMismatchError => 'รหัสผ่านไม่ตรงกัน';

  @override
  String get securityAlert => 'แจ้งเตือนความปลอดภัย';

  @override
  String get passwordChangedSuccess => 'เปลี่ยนรหัสผ่านเรียบร้อยแล้ว';

  @override
  String get passwordChangeSuccessMsg => 'เปลี่ยนรหัสผ่านเรียบร้อยแล้ว';

  @override
  String get currentPasswordIncorrect => 'รหัสผ่านปัจจุบันไม่ถูกต้อง';

  @override
  String get parentAccount => 'บัญชีผู้ปกครอง';

  @override
  String get edit => 'แก้ไข';

  @override
  String get childAddedTitle => 'เพิ่มบุตรหลานแล้ว';

  @override
  String childAddedMessage(Object name) {
    return 'เพิ่ม $name เข้ามาในครอบครัวของคุณแล้ว';
  }

  @override
  String get profileUpdatedTitle => 'อัปเดตโปรไฟล์แล้ว';

  @override
  String profileUpdatedMessage(Object name) {
    return 'โปรไฟล์ของ $name ได้รับการอัปเดตเรียบร้อยแล้ว';
  }

  @override
  String get online => 'ออนไลน์';

  @override
  String get offline => 'ออฟไลน์';

  @override
  String get noNotifications => 'ยังไม่มีการแจ้งเตือน';

  @override
  String get notificationDismissed => 'ลบการแจ้งเตือนแล้ว';

  @override
  String get markAllRead => 'อ่านทั้งหมด';

  @override
  String get justNow => 'เมื่อสักครู่';

  @override
  String get themeChangedTitle => 'เปลี่ยนธีมแล้ว';

  @override
  String themeChangedMessage(Object theme) {
    return 'ธีมของแอปถูกเปลี่ยนเป็น $theme เรียบร้อยแล้ว';
  }

  @override
  String get languageChangedTitle => 'เปลี่ยนภาษาแล้ว';

  @override
  String languageChangedMessage(Object language) {
    return 'ภาษาของแอปถูกเปลี่ยนเป็น $language เรียบร้อยแล้ว';
  }

  @override
  String get settingsUpdatedTitle => 'อัปเดตการตั้งค่าแล้ว';

  @override
  String get settingsUpdatedMessage => 'บันทึกการตั้งค่าของคุณเรียบร้อยแล้ว';

  @override
  String get feedbackSentTitle => 'ส่งความคิดเห็นแล้ว';

  @override
  String get feedbackSentMessage => 'ขอบคุณสำหรับความคิดเห็นของคุณ!';

  @override
  String get customRewards => 'รางวัลส่วนตัว';

  @override
  String get addReward => 'เพิ่มรางวัล';

  @override
  String get editReward => 'แก้ไขรางวัล';

  @override
  String get deleteReward => 'ลบรางวัล';

  @override
  String get rewardName => 'ชื่อรางวัล';

  @override
  String get rewardCost => 'คะแนนที่ต้องใช้';

  @override
  String get selectIcon => 'เลือกไอคอน';

  @override
  String get rewardAdded => 'เพิ่มรางวัลแล้ว!';

  @override
  String get rewardUpdated => 'อัปเดตรางวัลแล้ว!';

  @override
  String get rewardDeleted => 'ลบรางวัลแล้ว';

  @override
  String get deleteRewardConfirm => 'ลบรางวัลนี้?';

  @override
  String get noRewardsYet => 'ยังไม่มีรางวัล กด + เพื่อเพิ่ม!';

  @override
  String get enterRewardName => 'กรุณากรอกชื่อรางวัล';

  @override
  String get enterValidCost => 'กรุณากรอกคะแนนที่ถูกต้อง';

  @override
  String get defaultRewards => 'รางวัลแนะนำ';

  @override
  String get myRewards => 'รางวัลของฉัน';

  @override
  String get homeTab => 'หน้าหลัก';

  @override
  String get activityTab => 'กิจกรรม';

  @override
  String get settingsTab => 'ตั้งค่า';

  @override
  String get manageAlerts => 'จัดการการแจ้งเตือน';

  @override
  String get howToUse => 'วิธีใช้งาน';

  @override
  String get viewTutorialAgain => 'ดูคู่มือใช้งานอีกครั้ง';

  @override
  String get faqAndGuides => 'ถามตอบ และคู่มือ';

  @override
  String get reportIssues => 'รายงานปัญหา';

  @override
  String get appInformation => 'ข้อมูลแอปพลิเคชัน';

  @override
  String get connectionPin => 'รหัสเชื่อมต่อ';

  @override
  String get linkChildDevicesDesc => 'ใช้เพื่อเชื่อมต่ออุปกรณ์ของบุตรหลาน';

  @override
  String get copyPin => 'คัดลอกรหัส';

  @override
  String get pinCopied => 'คัดลอกรหัสแล้ว';

  @override
  String get logOutOfYourAccount => 'ออกจากระบบบัญชีของคุณ';

  @override
  String get activityTitle => 'กิจกรรม';

  @override
  String get activitySubtitle => 'เวลาหน้าจอและการใช้งานแอป';

  @override
  String get thisWeek => 'สัปดาห์นี้';

  @override
  String get weeklyOverview => 'ภาพรวมรายสัปดาห์';

  @override
  String appUsed(Object count) {
    return 'ใช้ไป $count แอป';
  }

  @override
  String get noAppUsageData => 'ไม่มีข้อมูลการใช้งานแอป';

  @override
  String get noAppUsageDataDesc =>
      'การใช้งานแอปจะแสดงขึ้น\nหลังจากที่เด็กใช้งานในวันนี้';

  @override
  String get showLess => 'แสดงน้อยลง';

  @override
  String showMore(Object count) {
    return 'แสดงอีก $count แอป';
  }

  @override
  String get mostUsed => 'ใช้บ่อยสุด';

  @override
  String get todayLabel => 'วันนี้';

  @override
  String get noChildrenAddedYet => 'ยังไม่ได้เพิ่มบุตรหลาน';

  @override
  String get addChildToSeeActivityData => 'เพิ่มบุตรหลานเพื่อดูผลกิจกรรม';

  @override
  String get errorLoadingData => 'เกิดข้อผิดพลาดในการโหลดข้อมูล';

  @override
  String get unlockRequestSent => 'ส่งคำขอปลดล็อกแล้ว';

  @override
  String failedToSendUnlockRequest(Object error) {
    return 'การส่งคำขอปลดล็อกล้มเหลว: $error';
  }

  @override
  String get timeLimit => 'จำกัดเวลา';

  @override
  String get setLimits => 'ตั้งค่าลิมิต';

  @override
  String get appBlock => 'บล็อกแอป';

  @override
  String get manage => 'จัดการ';

  @override
  String get location => 'ตำแหน่ง';

  @override
  String get track => 'ติดตาม';

  @override
  String get schedule => 'ตารางเวลา';

  @override
  String get plan => 'วางแผน';

  @override
  String get instantPause => 'พักด่วน';

  @override
  String get rewards => 'รางวัล';

  @override
  String get appControl => 'บล็อกแอป';

  @override
  String appControlWithChild(Object name) {
    return 'บล็อกแอป - $name';
  }

  @override
  String get searchApps => 'ค้นหาแอป...';

  @override
  String get totalApps => 'แอปทั้งหมด';

  @override
  String get blocked => 'บล็อกแล้ว';

  @override
  String get allowed => 'อนุญาตแล้ว';

  @override
  String get faq1Question => 'วิธีเชื่อมต่อกับเครื่องลูก?';

  @override
  String get faq1Answer =>
      '1. เปิดแอพบนเครื่องลูกแล้วเลือก \"เด็ก\"\n2. กรอก PIN 6 หลักจากหน้า Settings ของผู้ปกครอง\n3. เลือกโปรไฟล์เด็กหรือสร้างใหม่\n4. เปิดใช้งาน Child Mode';

  @override
  String get faq2Question => 'ทำไมแอพที่ถูกบล็อกยังเปิดได้?';

  @override
  String get faq2Answer =>
      'ตรวจสอบว่า:\n• Accessibility Service เปิดอยู่\n• Child Mode เปิดใช้งานอยู่\n• แอพ Kid Guard ยังทำงานอยู่ในพื้นหลัง\n\nถ้ายังไม่ได้ผล ลอง Force Stop แอพ Kid Guard แล้วเปิดใหม่';

  @override
  String get faq3Question => 'วิธีตั้งเวลาจำกัดการใช้งาน?';

  @override
  String get faq3Answer =>
      '1. ไปที่ Dashboard > Time Limit\n2. เลือกโปรไฟล์เด็ก\n3. ตั้งเวลาที่ต้องการ (ชั่วโมง:นาที)\n4. กด Save\n\nเมื่อถึงเวลาที่กำหนด หน้าจอเด็กจะถูกล็อค';

  @override
  String get faq4Question => 'วิธีดูตำแหน่งของลูก?';

  @override
  String get faq4Answer =>
      '1. ไปที่ Dashboard > Location\n2. เลือกโปรไฟล์เด็ก\n3. ตำแหน่งจะแสดงบนแผนที่\n\nหมายเหตุ: ต้องเปิด Location Permission บนเครื่องเด็ก';

  @override
  String get faq5Question => 'PIN หายทำอย่างไร?';

  @override
  String get faq5Answer =>
      '1. ไปที่ Settings > Connection\n2. กด \"Regenerate\" เพื่อสร้าง PIN ใหม่\n3. ใช้ PIN ใหม่ในการเชื่อมต่อ\n\nหมายเหตุ: เครื่องเด็กที่เชื่อมต่อแล้วไม่ต้องใส่ PIN ใหม่';

  @override
  String get faq6Question => 'วิธีลบโปรไฟล์เด็ก?';

  @override
  String get faq6Answer =>
      '1. เปิดแอพบนเครื่องเด็ก\n2. เลือก \"เชื่อมต่อกับผู้ปกครอง\"\n3. กดค้างที่โปรไฟล์ที่ต้องการลบ\n4. ยืนยันการลบ';

  @override
  String get faq7Question => 'ระบบของรางวัลทำงานอย่างไร?';

  @override
  String get faq7Answer =>
      'คุณสามารถให้คะแนนลูกสำหรับการทำการบ้านหรืองานบ้าน และใช้คะแนนเหล่านั้นเพื่อแลกของรางวัลที่คุณตั้งค่าไว้ (เช่น เวลาเล่นเกมเพิ่ม) ในหน้า Rewards';

  @override
  String get helpCenterTitle => 'ศูนย์ช่วยเหลือ';

  @override
  String get helpCenterSubtitle => 'คำถามที่พบบ่อยและวิธีใช้งาน';

  @override
  String get faqTitle => 'คำถามที่พบบ่อย';

  @override
  String get contactSupportTitle => 'ยังมีคำถามเพิ่มเติม?';

  @override
  String get contactSupportSubtitle => 'ติดต่อเราได้ที่ support@kidguard.app';

  @override
  String get security => 'ความปลอดภัย';

  @override
  String get appProtection => 'การป้องกันแอป';

  @override
  String get appProtectionDesc => 'ป้องกันการถอนการติดตั้งแอป';

  @override
  String get appProtectionEnabled => 'เปิดป้องกัน';

  @override
  String get appProtectionDisabled => 'ยังไม่ได้เปิด';

  @override
  String get enableAppProtection => 'เปิดการป้องกัน';

  @override
  String get enableAppProtectionDesc =>
      'เปิดเพื่อป้องกันไม่ให้เด็กลบแอป KidGuard';

  @override
  String get disableAppProtection => 'ปิดการป้องกัน';

  @override
  String get enterPinToDisable => 'กรอก PIN ผู้ปกครองเพื่อปิดการป้องกัน';

  @override
  String get incorrectPin => 'PIN ไม่ถูกต้อง';

  @override
  String get appProtectionActivated => 'เปิดการป้องกันแอปเรียบร้อยแล้ว';

  @override
  String get appProtectionDeactivated => 'ปิดการป้องกันแอปเรียบร้อยแล้ว';

  @override
  String get confirm => 'ยืนยัน';

  @override
  String get enterPin => 'กรอก PIN';
}
