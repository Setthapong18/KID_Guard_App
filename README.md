<p align="center">
  <img src="assets/icons/Kid_Guard.png" alt="KidGuard Logo" width="120" height="120" style="border-radius: 20px;" />
</p>

<h1 align="center">🛡️ KidGuard</h1>

<p align="center">
  <strong>แอปพลิเคชันจัดการการใช้งานอุปกรณ์ของเด็ก สำหรับผู้ปกครองยุคดิจิทัล</strong><br/>
  <em>A parental control app for managing children's digital device usage</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/Version-1.0.0-green" alt="Version" />
  <img src="https://img.shields.io/badge/License-Academic-blue" alt="License" />
</p>

---

## 📖 สารบัญ (Table of Contents)

- [📖 สารบัญ (Table of Contents)](#-สารบัญ-table-of-contents)
- [🎯 เกี่ยวกับโปรเจค (About)](#-เกี่ยวกับโปรเจค-about)
  - [🎓 โปรเจคจบการศึกษา (Graduation Project)](#-โปรเจคจบการศึกษา-graduation-project)
- [✨ ฟีเจอร์หลัก (Key Features)](#-ฟีเจอร์หลัก-key-features)
  - [👨‍👩‍👧 โหมดผู้ปกครอง (Parent Mode)](#-โหมดผู้ปกครอง-parent-mode)
  - [👶 โหมดเด็ก (Child Mode)](#-โหมดเด็ก-child-mode)
  - [🔧 ฟีเจอร์ระบบ (System Features)](#-ฟีเจอร์ระบบ-system-features)
- [🏗️ สถาปัตยกรรม (Architecture)](#️-สถาปัตยกรรม-architecture)
  - [State Management](#state-management)
- [🛠️ เทคโนโลยีที่ใช้ (Tech Stack)](#️-เทคโนโลยีที่ใช้-tech-stack)
  - [Core](#core)
  - [UI/UX](#uiux)
  - [Services \& Utilities](#services--utilities)
- [📁 โครงสร้างโปรเจค (Project Structure)](#-โครงสร้างโปรเจค-project-structure)
- [⚙️ การติดตั้ง (Installation)](#️-การติดตั้ง-installation)
  - [ข้อกำหนดเบื้องต้น (Prerequisites)](#ข้อกำหนดเบื้องต้น-prerequisites)
  - [ขั้นตอนการติดตั้ง (Steps)](#ขั้นตอนการติดตั้ง-steps)
    - [1. Clone Repository](#1-clone-repository)
    - [2. ติดตั้ง Dependencies](#2-ติดตั้ง-dependencies)
    - [3. ตั้งค่า Firebase](#3-ตั้งค่า-firebase)
    - [4. Generate Localization Files](#4-generate-localization-files)
    - [5. Generate App Icons \& Splash Screen](#5-generate-app-icons--splash-screen)
    - [6. รันแอป](#6-รันแอป)
- [🚀 การใช้งาน (Usage)](#-การใช้งาน-usage)
  - [ขั้นตอนเริ่มต้น (Getting Started)](#ขั้นตอนเริ่มต้น-getting-started)
  - [สำหรับผู้ปกครอง (For Parents)](#สำหรับผู้ปกครอง-for-parents)
  - [สำหรับเด็ก (For Children)](#สำหรับเด็ก-for-children)
- [🔐 ระบบความปลอดภัย (Security)](#-ระบบความปลอดภัย-security)
- [🌐 รองรับหลายภาษา (Internationalization)](#-รองรับหลายภาษา-internationalization)
- [🧪 การทดสอบ (Testing)](#-การทดสอบ-testing)
  - [รันทดสอบ](#รันทดสอบ)
  - [โครงสร้างไฟล์ทดสอบ](#โครงสร้างไฟล์ทดสอบ)
- [📦 Dependencies](#-dependencies)
  - [Production Dependencies](#production-dependencies)
  - [Dev Dependencies](#dev-dependencies)
- [🗄️ โครงสร้างฐานข้อมูล (Database Schema)](#️-โครงสร้างฐานข้อมูล-database-schema)
- [📊 Data Models](#-data-models)
- [🎨 Design System](#-design-system)
- [👥 ผู้พัฒนา (Contributors)](#-ผู้พัฒนา-contributors)
- [📄 สิทธิ์การใช้งาน (License)](#-สิทธิ์การใช้งาน-license)

---

## 🎯 เกี่ยวกับโปรเจค (About)

**KidGuard** คือแอปพลิเคชัน Flutter สำหรับ **ผู้ปกครอง** ที่ต้องการดูแลและจัดการการใช้งานอุปกรณ์มือถือของ **บุตรหลาน** อย่างมีประสิทธิภาพ ออกแบบมาในรูปแบบ **Dual-Role Architecture** ที่รองรับทั้งโหมดผู้ปกครอง (Parent Mode) และโหมดเด็ก (Child Mode) ภายในแอปเดียวกัน

**KidGuard** is a Flutter application designed for **parents** who want to effectively monitor and manage their **children's** mobile device usage. Built with a **Dual-Role Architecture**, it supports both Parent Mode and Child Mode within a single app.

### 🎓 โปรเจคจบการศึกษา (Graduation Project)

โปรเจคนี้เป็นส่วนหนึ่งของโปรเจคจบการศึกษา (Senior Project) พัฒนาเพื่อแก้ปัญหาการใช้งานอุปกรณ์ดิจิทัลอย่างไม่เหมาะสมของเด็กในยุคปัจจุบัน

---

## ✨ ฟีเจอร์หลัก (Key Features)

### 👨‍👩‍👧 โหมดผู้ปกครอง (Parent Mode)

| ฟีเจอร์ | รายละเอียด |
|---------|-----------|
| 🏠 **Dashboard** | แสดงข้อมูลสรุปของเด็กทุกคนในหน้าเดียว พร้อมสถานะออนไลน์/ออฟไลน์ |
| ⏰ **จำกัดเวลาใช้งาน (Time Limit)** | ตั้งค่าเวลาใช้งานรายวัน ล็อคอุปกรณ์อัตโนมัติเมื่อหมดเวลา |
| 📱 **ควบคุมแอป (App Control)** | บล็อค/อนุญาตแอปที่ติดตั้งบนอุปกรณ์ของเด็ก |
| 📍 **ติดตามตำแหน่ง (Location Tracking)** | ดูตำแหน่งปัจจุบันของเด็กแบบ Real-time บนแผนที่ |
| 📊 **รายงานกิจกรรม (Activity Report)** | กราฟแสดงสถิติการใช้งานรายสัปดาห์ พร้อมเปรียบเทียบ |
| 📅 **ตารางเวลา (Schedule)** | ตั้งเวลา Quiet Hours / Sleep Time ล็อคอุปกรณ์ตามช่วงเวลา |
| 🏆 **ระบบรางวัล (Rewards)** | ให้คะแนนเด็กเมื่อใช้งานอย่างเหมาะสม แลกรางวัลได้ |
| 👤 **จัดการรายชื่อ (Contacts)** | ดูและจัดการรายชื่อผู้ติดต่อบนอุปกรณ์เด็ก |
| 🔔 **การแจ้งเตือน (Notifications)** | แจ้งเตือนเมื่อเด็กใช้งานเกินเวลา หรือมีเหตุการณ์สำคัญ |
| ⚙️ **ตั้งค่า (Settings)** | การแจ้งเตือน, ภาษา, ศูนย์ช่วยเหลือ, Feedback, เกี่ยวกับแอป |

### 👶 โหมดเด็ก (Child Mode)

| ฟีเจอร์ | รายละเอียด |
|---------|-----------|
| 🏠 **หน้าหลักเด็ก (Child Home)** | แสดงเวลาที่เหลือ, คะแนนสะสม, สถานะการใช้งาน |
| 🔒 **หน้าจอล็อค (Friendly Lock Screen)** | หน้าจอล็อคที่เป็นมิตรกับเด็ก พร้อมข้อความให้กำลังใจ |
| 🔐 **ระบบ PIN** | PIN สำหรับเข้าโหมดเด็ก ป้องกันการออกจากโหมด |
| 📊 **ดูสถิติ** | เด็กสามารถดูเวลาที่ใช้ไป และเวลาที่เหลือได้ |
| 🏆 **คะแนนและรางวัล** | ดูคะแนนสะสม แลกรางวัลที่ผู้ปกครองตั้งไว้ |

### 🔧 ฟีเจอร์ระบบ (System Features)

- **🔄 Background Service** — ทำงานเบื้องหลังเพื่อติดตามและซิงค์ข้อมูลอัตโนมัติ
- **📡 Real-time Sync** — ซิงค์ข้อมูลแบบ Real-time ผ่าน Cloud Firestore
- **🔐 Security Checks** — ตรวจจับ Root, Emulator, Debugger อัตโนมัติ
- **🌙 Auto Lock** — ล็อคอุปกรณ์อัตโนมัติตามเวลาที่ตั้งไว้
- **💾 Offline Support** — ข้อมูลบางส่วนเก็บใน Local Storage (SharedPreferences)
- **📱 Native Settings Sync** — ซิงค์ค่าตั้งระหว่าง Flutter และ Native Android

---

## 🏗️ สถาปัตยกรรม (Architecture)

โปรเจคใช้สถาปัตยกรรมแบบ **Layered Architecture** แยกชั้นชัดเจน:

```
┌─────────────────────────────────────────────┐
│              Presentation Layer             │
│  (Screens, Widgets - UI Components)         │
├─────────────────────────────────────────────┤
│                Logic Layer                  │
│  (Providers, Services - Business Logic)     │
├─────────────────────────────────────────────┤
│                 Data Layer                  │
│  (Models, Services - Data Access)           │
├─────────────────────────────────────────────┤
│                Core Layer                   │
│  (Utils, Constants - Shared Utilities)      │
├─────────────────────────────────────────────┤
│               Config Layer                  │
│  (Theme, Routes - App Configuration)        │
└─────────────────────────────────────────────┘
```

### State Management

ใช้ **Provider** เป็น State Management หลัก:

| Provider | หน้าที่ |
|----------|--------|
| `AuthProvider` | จัดการ Authentication, User/Children data |
| `RewardsProvider` | จัดการระบบรางวัลและคะแนน |
| `ScheduleProvider` | จัดการตารางเวลา (Quiet Hours, Sleep Time) |
| `TimeLimitProvider` | จัดการการจำกัดเวลาใช้งาน |
| `OnboardingProvider` | จัดการขั้นตอน Onboarding |
| `LocaleProvider` | จัดการภาษา (Thai / English) |

---

## 🛠️ เทคโนโลยีที่ใช้ (Tech Stack)

### Core

| เทคโนโลยี | เวอร์ชัน | การใช้งาน |
|-----------|---------|----------|
| **Flutter** | 3.10+ | UI Framework |
| **Dart** | ^3.10.1 | Programming Language |
| **Firebase Auth** | ^6.1.2 | Authentication (Email / Google Sign-In) |
| **Cloud Firestore** | ^6.1.0 | Real-time Database |
| **Provider** | ^6.1.5 | State Management |

### UI/UX

| Package | การใช้งาน |
|---------|----------|
| `google_fonts` | Typography |
| `fl_chart` | กราฟสถิติการใช้งาน |
| `table_calendar` | ปฏิทินตารางเวลา |
| `flutter_map` + `latlong2` | แผนที่ติดตามตำแหน่ง |
| `cupertino_icons` | iOS-style icons |

### Services & Utilities

| Package | การใช้งาน |
|---------|----------|
| `geolocator` | GPS Location Service |
| `device_apps` | จัดการแอปบนอุปกรณ์ |
| `usage_stats` | สถิติการใช้แอป |
| `permission_handler` | จัดการ Permissions |
| `workmanager` | Background Tasks |
| `flutter_local_notifications` | การแจ้งเตือน |
| `shared_preferences` | Local Storage |
| `flutter_contacts` | Contact Access |
| `android_intent_plus` | Android System Intents |
| `url_launcher` | เปิด URL ภายนอก |
| `device_info_plus` | ข้อมูลอุปกรณ์ |
| `package_info_plus` | ข้อมูลแอป |
| `path_provider` | File System Paths |

---

## 📁 โครงสร้างโปรเจค (Project Structure)

```
lib/
├── main.dart                          # Entry point
├── config/                            # 🔧 App Configuration
│   ├── app_theme.dart                 #   - Theme & Design System
│   └── routes.dart                    #   - Route Definitions
│
├── core/                              # 🧱 Core Utilities
│   └── utils/
│       ├── security_logger.dart       #   - Security Event Logger
│       └── ...
│
├── data/                              # 💾 Data Layer
│   ├── local/                         #   - Local Storage
│   ├── models/                        #   - Data Models
│   │   ├── child_model.dart           #     - Child Profile
│   │   ├── user_model.dart            #     - Parent/User Profile
│   │   ├── device_model.dart          #     - Device Information
│   │   ├── contact_model.dart         #     - Contact Data
│   │   ├── reward_model.dart          #     - Reward Item
│   │   ├── schedule_period_model.dart #     - Schedule Time Period
│   │   ├── notification_model.dart    #     - Notification Data
│   │   └── app_info_model.dart        #     - Installed App Info
│   └── services/                      #   - Data Services (Firebase)
│       ├── auth_service.dart          #     - Authentication
│       ├── app_service.dart           #     - App Management
│       ├── device_service.dart        #     - Device Management
│       ├── contact_service.dart       #     - Contact Sync
│       ├── notification_service.dart  #     - Notification CRUD
│       ├── local_notification_service.dart # - Local Notifications
│       └── security_service.dart      #     - Security Checks
│
├── logic/                             # 🧠 Business Logic
│   ├── background_worker.dart         #   - WorkManager Dispatcher
│   ├── providers/                     #   - State Management
│   │   ├── auth_provider.dart         #     - Auth State
│   │   ├── rewards_provider.dart      #     - Rewards State
│   │   ├── schedule_provider.dart     #     - Schedule State
│   │   ├── time_limit_provider.dart   #     - Time Limit State
│   │   ├── onboarding_provider.dart   #     - Onboarding State
│   │   └── locale_provider.dart       #     - Language State
│   └── services/                      #   - Logic Services
│       ├── background_service.dart    #     - Background Monitoring
│       ├── child_mode_service.dart    #     - Child Mode Management
│       ├── location_service.dart      #     - Location Tracking
│       ├── native_settings_sync.dart  #     - Native Bridge
│       └── overlay_service.dart       #     - System Overlay
│
├── presentation/                      # 🎨 UI Layer
│   ├── auth/                          #   - Authentication Screens
│   │   └── login_screen.dart
│   ├── onboarding/                    #   - Onboarding Flow
│   │   ├── select_user_screen.dart    #     - Role Selection (Parent/Child)
│   │   └── onboarding_screen.dart
│   ├── shared/                        #   - Shared Components
│   │   └── parent_shell.dart          #     - Parent Navigation Shell
│   ├── parent/                        #   - Parent Screens
│   │   ├── parent_home_screen.dart    #     - Dashboard
│   │   ├── time_limit_screen.dart     #     - Time Limit Settings
│   │   ├── schedule_screen.dart       #     - Schedule Management
│   │   ├── parent_rewards_screen.dart #     - Rewards System
│   │   ├── parent_activity_screen.dart#     - Activity Reports
│   │   ├── child_location_screen.dart #     - Location Map
│   │   ├── child_setup_screen.dart    #     - Add/Edit Child
│   │   ├── all_children_screen.dart   #     - Children List
│   │   ├── account_profile_screen.dart#     - Parent Profile
│   │   ├── parent_settings_screen.dart#     - Settings
│   │   ├── apps/                      #     - App Control
│   │   ├── contacts/                  #     - Contact Management
│   │   ├── activity/                  #     - Activity Widgets
│   │   ├── home/                      #     - Home Widgets
│   │   └── settings/                  #     - Settings Sub-screens
│   └── child/                         #   - Child Screens
│       ├── child_home_screen.dart     #     - Child Dashboard
│       ├── child_mode_activation_screen.dart # - Activate Child Mode
│       ├── child_pin_screen.dart      #     - PIN Entry
│       ├── child_profile_setup_screen.dart  # - Profile Setup
│       ├── child_selection_screen.dart#     - Select Child Profile
│       ├── friendly_lock_screen.dart  #     - Friendly Lock Screen
│       └── widgets/                   #     - Child Widgets
│
├── l10n/                              # 🌐 Localization
│   ├── app_en.arb                     #   - English Strings
│   ├── app_th.arb                     #   - Thai Strings
│   ├── app_localizations.dart         #   - Generated Localizations
│   ├── app_localizations_en.dart      #   - Generated EN
│   └── app_localizations_th.dart      #   - Generated TH
│
assets/
├── icons/                             # App Icons
│   ├── Kid_Guard.png                  #   - Main App Icon
│   └── Kid_Guard_Foreground.png       #   - Foreground Icon (Splash)
├── avatars/                           # Child Avatars
│   ├── boy_1.png ~ boy_4.png
│   └── girl_2.png ~ girl_7.png
└── fonts/
    └── Itim-Regular.ttf              # Custom Thai Font
```

---

## ⚙️ การติดตั้ง (Installation)

### ข้อกำหนดเบื้องต้น (Prerequisites)

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.10 ขึ้นไป
- [Android Studio](https://developer.android.com/studio) พร้อม Android SDK
- [Firebase CLI](https://firebase.google.com/docs/cli) (สำหรับตั้งค่า Firebase)
- อุปกรณ์ Android จริง (แนะนำ) หรือ Emulator

### ขั้นตอนการติดตั้ง (Steps)

#### 1. Clone Repository

```bash
git clone https://github.com/your-username/KID_Guard_App.git
cd KID_Guard_App
```

#### 2. ติดตั้ง Dependencies

```bash
flutter pub get
```

#### 3. ตั้งค่า Firebase

1. สร้างโปรเจค Firebase ใหม่ที่ [Firebase Console](https://console.firebase.google.com/)
2. เปิดใช้งาน **Authentication** (Email/Password + Google Sign-In)
3. เปิดใช้งาน **Cloud Firestore**
4. ดาวน์โหลด `google-services.json` และวางใน `android/app/`
5. ตั้งค่า Firestore Security Rules ตามที่ต้องการ

#### 4. Generate Localization Files

```bash
flutter gen-l10n
```

#### 5. Generate App Icons & Splash Screen

```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

#### 6. รันแอป

```bash
flutter run
```

---

## 🚀 การใช้งาน (Usage)

### ขั้นตอนเริ่มต้น (Getting Started)

```
1️⃣ เปิดแอป → เลือกบทบาท (ผู้ปกครอง / เด็ก)
2️⃣ ผู้ปกครอง: ลงทะเบียน / เข้าสู่ระบบ → เพิ่มโปรไฟล์เด็ก
3️⃣ เด็ก: เลือกโปรไฟล์ → ใส่ PIN → เข้าสู่โหมดเด็ก
```

### สำหรับผู้ปกครอง (For Parents)

1. **สร้างบัญชี** — ลงทะเบียนด้วย Email หรือ Google Account
2. **เพิ่มเด็ก** — สร้างโปรไฟล์เด็ก (ชื่อ, อายุ, อวาตาร์)
3. **ตั้งค่า** — กำหนดเวลาใช้งาน, ตารางเวลา, แอปที่อนุญาต
4. **ติดตาม** — ดู Dashboard, รายงานกิจกรรม, ตำแหน่ง GPS

### สำหรับเด็ก (For Children)

1. **เลือกโปรไฟล์** — เลือกชื่อของตัวเอง
2. **ใส่ PIN** — ใส่ PIN ที่ผู้ปกครองตั้งไว้
3. **ใช้งาน** — ใช้อุปกรณ์ภายในกรอบเวลาที่ตั้งไว้
4. **รับรางวัล** — สะสมคะแนนจากการใช้งานอย่างเหมาะสม

---

## 🔐 ระบบความปลอดภัย (Security)

KidGuard มีระบบตรวจสอบความปลอดภัยหลายชั้น:

| การตรวจสอบ | รายละเอียด |
|-----------|-----------|
| 🔍 **Root Detection** | ตรวจจับอุปกรณ์ที่ถูก Root/Jailbreak |
| 🖥️ **Emulator Detection** | ตรวจจับการรันบน Emulator |
| 🐛 **Debugger Detection** | ตรวจจับการ Debug แอป |
| 📊 **Risk Assessment** | ประเมินระดับความเสี่ยง (%) |
| 📝 **Security Logging** | บันทึก Log เหตุการณ์ด้านความปลอดภัย |
| ⚠️ **Warning Dialog** | แจ้งเตือนผู้ใช้เมื่อพบความเสี่ยง |

```dart
// Security check runs automatically on app startup
SecurityService → performSecurityCheck()
  ├── isRooted?       → Root detection
  ├── isEmulator?     → Emulator detection
  ├── isDebugged?     → Debugger detection
  └── riskLevel (%)   → Risk assessment score
```

---

## 🌐 รองรับหลายภาษา (Internationalization)

แอปรองรับ **2 ภาษา** ด้วยระบบ Flutter Localization:

| ภาษา | ไฟล์ | สถานะ |
|------|------|-------|
| 🇹🇭 ไทย (Thai) | `l10n/app_th.arb` | ✅ เต็มรูปแบบ |
| 🇬🇧 English | `l10n/app_en.arb` | ✅ เต็มรูปแบบ |

ผู้ใช้สามารถเปลี่ยนภาษาได้แบบ Real-time ผ่าน Settings → Language

---

## 🧪 การทดสอบ (Testing)

### รันทดสอบ

```bash
# Unit Tests
flutter test

# Run specific test file
flutter test test/data/services/auth_service_test.dart

# Run with coverage
flutter test --coverage
```

### โครงสร้างไฟล์ทดสอบ

```
test/
├── core/           # Core utilities tests
├── data/           # Data layer tests (services, models)
├── helpers/        # Test helpers & mocks
└── logic/          # Business logic tests (providers)
```

---

## 📦 Dependencies

<details>
<summary>📋 รายการ Dependencies ทั้งหมด (Click to expand)</summary>

### Production Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^4.2.1 | Firebase initialization |
| `firebase_auth` | ^6.1.2 | User authentication |
| `cloud_firestore` | ^6.1.0 | Cloud database |
| `provider` | ^6.1.5 | State management |
| `google_fonts` | ^6.3.2 | Custom typography |
| `fl_chart` | ^1.1.1 | Charts & graphs |
| `shared_preferences` | ^2.5.3 | Local key-value storage |
| `flutter_local_notifications` | ^19.5.0 | Device notifications |
| `android_intent_plus` | ^6.0.0 | Android system intents |
| `usage_stats` | ^1.3.1 | App usage statistics |
| `google_sign_in` | ^6.3.0 | Google OAuth |
| `flutter_contacts` | ^1.1.9 | Contact access |
| `permission_handler` | ^11.3.1 | Runtime permissions |
| `device_apps` | ^2.2.0 | Installed apps |
| `geolocator` | ^13.0.0 | GPS location |
| `flutter_map` | ^7.0.0 | Map display |
| `latlong2` | ^0.9.1 | Geographic coordinates |
| `workmanager` | ^0.6.0 | Background tasks |
| `package_info_plus` | ^9.0.0 | App package info |
| `path_provider` | ^2.1.5 | File system paths |
| `table_calendar` | ^3.1.0 | Calendar widget |
| `intl` | ^0.20.2 | Internationalization |
| `device_info_plus` | ^10.1.0 | Device info |
| `url_launcher` | ^6.3.2 | URL launching |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Testing framework |
| `flutter_lints` | ^6.0.0 | Linting rules |
| `flutter_native_splash` | ^2.4.7 | Splash screen generator |

</details>

---

## 🗄️ โครงสร้างฐานข้อมูล (Database Schema)

ใช้ **Cloud Firestore** (NoSQL) กับ Collections หลัก:

```
Firestore
├── users/                    # ข้อมูลผู้ปกครอง
│   └── {userId}/
│       ├── name, email, ...
│       └── children/         # Sub-collection
│           └── {childId}/
│               ├── name, age, avatar
│               ├── screenTime, limitUsedTime
│               ├── dailyTimeLimit
│               ├── isLocked, isOnline
│               ├── isChildModeActive
│               ├── points
│               ├── lockReason
│               ├── devices/          # อุปกรณ์ของเด็ก
│               ├── contacts/         # รายชื่อผู้ติดต่อ
│               ├── apps/             # แอปที่ติดตั้ง
│               ├── rewards/          # รางวัล
│               ├── schedulePeriods/   # ตารางเวลา
│               └── notifications/    # การแจ้งเตือน
```

---

## 📊 Data Models

| Model | ฟิลด์หลัก | หน้าที่ |
|-------|----------|--------|
| `UserModel` | id, name, email | ข้อมูลผู้ปกครอง |
| `ChildModel` | name, age, screenTime, dailyTimeLimit, isLocked, points | โปรไฟล์เด็ก |
| `DeviceModel` | deviceName, platform, lastSeen | อุปกรณ์ที่ลงทะเบียน |
| `ContactModel` | name, phone, isAllowed | รายชื่อผู้ติดต่อ |
| `RewardModel` | name, emoji, cost | รางวัลที่แลกได้ |
| `SchedulePeriodModel` | startTime, endTime, days, type | ช่วงเวลาตาราง |
| `NotificationModel` | title, body, type, timestamp | การแจ้งเตือน |
| `AppInfoModel` | packageName, appName, isBlocked | แอปที่ติดตั้ง |

---

## 🎨 Design System

- **Primary Color**: `#779C85` (Sage Green — สีเขียวอ่อนที่สื่อถึงความปลอดภัย)
- **Font**: `Itim-Regular` (ฟอนต์ไทยที่เป็นมิตร อ่านง่าย)
- **Theme**: Material Design 3 (Light Theme)
- **Icons**: Cupertino Icons + Material Icons

---

## 👥 ผู้พัฒนา (Contributors)

โปรเจคนี้พัฒนาโดยนักศึกษาเป็นส่วนหนึ่งของโปรเจคจบการศึกษา

---

## 📄 สิทธิ์การใช้งาน (License)

โปรเจคนี้เป็นโปรเจคเพื่อการศึกษา (Academic Project) สงวนลิขสิทธิ์ทั้งหมด

---

<p align="center">
  <strong>🛡️ KidGuard — ปกป้องลูกน้อยในโลกดิจิทัล</strong><br/>
  <em>Protecting children in the digital world</em>
</p>
