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
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-blueviolet" alt="Clean Architecture" />
  <img src="https://img.shields.io/badge/Tests-50%20passing-brightgreen?logo=flutter" alt="Tests 50 passing" />
  <img src="https://img.shields.io/badge/Security-Keystore%20%2B%20Obfuscation-red?logo=android" alt="Security" />
</p>

---

## 📖 สารบัญ (Table of Contents)

- [🎯 เกี่ยวกับโปรเจค](#-เกี่ยวกับโปรเจค-about)
- [✨ ฟีเจอร์หลัก](#-ฟีเจอร์หลัก-key-features)
- [🏗️ สถาปัตยกรรม (Clean Architecture)](#️-สถาปัตยกรรม-clean-architecture)
- [🛠️ Tech Stack](#️-tech-stack)
- [🔐 ระบบความปลอดภัย](#-ระบบความปลอดภัย-security)
- [🧪 Unit Tests](#-unit-tests)
- [📁 โครงสร้างโปรเจค](#-โครงสร้างโปรเจค-project-structure)
- [⚙️ การติดตั้ง](#️-การติดตั้ง-installation)
- [🗄️ โครงสร้างฐานข้อมูล](#️-โครงสร้างฐานข้อมูล-database-schema)
- [👥 ผู้พัฒนา](#-ผู้พัฒนา)

---

## 🎯 เกี่ยวกับโปรเจค (About)

**KidGuard** คือแอป Flutter สำหรับ **ผู้ปกครอง** ที่ต้องการดูแลการใช้งานมือถือของ **เด็ก** ออกแบบเป็น **Dual-Role Architecture** รองรับทั้ง Parent Mode และ Child Mode ในแอปเดียว

พัฒนาเป็น **Senior Project** โดยใช้ **Clean Architecture** เต็มรูปแบบ — แยก Presentation / Domain / Data layer ชัดเจน พร้อม Dependency Injection, Unit Tests, Firebase Crashlytics และ Security Layer

---

## ✨ ฟีเจอร์หลัก (Key Features)

### 👨‍👩‍👧 โหมดผู้ปกครอง (Parent Mode)

| ฟีเจอร์ | รายละเอียด |
|---------|-----------|
| 🏠 **Dashboard** | สรุปข้อมูลเด็กทุกคน พร้อมสถานะ online/offline แบบ real-time |
| ⏰ **Time Limit** | จำกัดเวลาใช้งานรายวัน ล็อคอัตโนมัติเมื่อหมดเวลา |
| 📱 **App Control** | บล็อก/อนุญาตแอปแต่ละตัวบนอุปกรณ์เด็ก |
| 📍 **Location Tracking** | ดูตำแหน่ง GPS ของเด็กแบบ real-time บนแผนที่ |
| 📅 **Schedule** | ตั้ง Quiet Hours / Sleep Time ล็อคอุปกรณ์ตามช่วงเวลา |
| 🏆 **Rewards System** | ให้คะแนนเด็ก แลกรางวัลที่ตั้งเองได้ |
| 📊 **Activity Report** | กราฟแสดงสถิติการใช้งานรายสัปดาห์ |
| 🔔 **Notifications** | แจ้งเตือนเมื่อเด็กใช้เกินเวลา หรือมีเหตุการณ์สำคัญ |

### 👶 โหมดเด็ก (Child Mode)

| ฟีเจอร์ | รายละเอียด |
|---------|-----------|
| 🏠 **Child Dashboard** | แสดงเวลาที่เหลือ, คะแนนสะสม, สถานะปัจจุบัน |
| 🔒 **Friendly Lock Screen** | หน้าจอล็อคที่เป็นมิตรกับเด็ก |
| 🔐 **PIN System** | PIN ป้องกันการออกจาก Child Mode |
| 🏆 **คะแนนและรางวัล** | ดูและแลกรางวัลที่ผู้ปกครองตั้งไว้ |

### 🔧 ฟีเจอร์ระบบ (System Features)

- **Background Service** — ติดตามและซิงค์ข้อมูลอัตโนมัติตลอดเวลา
- **Offline Support** — Firestore Local Cache ทำให้แอปยังใช้งานได้เมื่อเน็ตหลุด
- **Real-time Sync** — ซิงค์ข้อมูลแบบ real-time ผ่าน Cloud Firestore
- **Security Checks** — ตรวจจับ Root / Emulator / Debugger อัตโนมัติตอนเปิดแอป

---

## 🏗️ สถาปัตยกรรม (Clean Architecture)

โปรเจคใช้ **Clean Architecture** เต็มรูปแบบ แยก layer ชัดเจน:

```
┌──────────────────────────────────────────────────────┐
│                 Presentation Layer                    │
│  Screens + Widgets  →  ใช้แค่ Provider ไม่แตะ Data   │
├──────────────────────────────────────────────────────┤
│                    Logic Layer                        │
│  Providers (State)  →  เรียกผ่าน Repository เท่านั้น │
├──────────────────────────────────────────────────────┤
│                  Domain Layer                         │
│  Repository Interfaces  →  กำหนด contract ของ Data   │
├──────────────────────────────────────────────────────┤
│                    Data Layer                         │
│  Repository Impl + Services  →  Firestore / Storage  │
├──────────────────────────────────────────────────────┤
│                    Core Layer                         │
│  DI (get_it) · AppException · Utils · Security       │
└──────────────────────────────────────────────────────┘
```

### Dependency Injection — `get_it`

```dart
// injection.dart — ลงทะเบียนทุก dependency ที่นี่ที่เดียว
sl.registerLazySingleton<RewardsRepository>(
  () => RewardsRepositoryImpl(firestore: sl()),
);
```

### State Management — Provider

| Provider | หน้าที่ |
|----------|--------|
| `AuthProvider` | Authentication, User/Children data |
| `RewardsProvider` | ระบบรางวัลและคะแนน |
| `ScheduleProvider` | Quiet Hours, Sleep Time |
| `TimeLimitProvider` | จำกัดเวลาใช้งาน |
| `LocaleProvider` | ภาษา (Thai / English) |

### Error Handling — `AppException`

```dart
// ทุก error ผ่าน AppException → message ภาษาไทยอัตโนมัติ
throw AppException.fromFirebaseAuth(firebaseEx);
// → "ไม่พบบัญชีผู้ใช้ กรุณาตรวจสอบ email"
```

---

## 🛠️ Tech Stack

### Core

| เทคโนโลยี | เวอร์ชัน | การใช้งาน |
|-----------|---------|----------|
| **Flutter** | 3.10+ | UI Framework |
| **Dart** | ^3.10.1 | Programming Language |
| **Firebase Auth** | ^6.1.2 | Authentication (Email / Google) |
| **Cloud Firestore** | ^6.1.0 | Real-time Database + Offline Cache |
| **Firebase Crashlytics** | ^5.0.5 | Crash monitoring อัตโนมัติ |
| **Provider** | ^6.1.5 | State Management |
| **get_it** | latest | Dependency Injection |

### Security

| Package | การใช้งาน |
|---------|----------|
| `flutter_secure_storage` | เก็บ PIN + UIDs ใน Android Keystore (AES encrypted) |
| Code Obfuscation | `--obfuscate --split-debug-info` ป้องกัน reverse engineering |
| Root / Emulator Detection | ตรวจสอบความปลอดภัยของอุปกรณ์ทุกครั้งที่เปิดแอป |

### UI/UX

| Package | การใช้งาน |
|---------|----------|
| `google_fonts` | Typography |
| `fl_chart` | กราฟสถิติการใช้งาน |
| `flutter_map` + `latlong2` | แผนที่ติดตามตำแหน่ง |
| Shimmer Loading | Skeleton loading แทน spinner |

### Services & Utilities

| Package | การใช้งาน |
|---------|----------|
| `geolocator` | GPS Location Service |
| `device_apps` | จัดการแอปบนอุปกรณ์ |
| `usage_stats` | สถิติการใช้แอป |
| `workmanager` | Background Tasks (sync blocklist ทุก 15 นาที) |
| `flutter_local_notifications` | การแจ้งเตือน |
| `permission_handler` | Runtime Permissions |

---

## 🔐 ระบบความปลอดภัย (Security)

KidGuard มีระบบความปลอดภัยหลายชั้น:

| ชั้น | รายละเอียด |
|-----|-----------|
| 🔑 **Android Keystore** | PIN และ session IDs เก็บแบบ AES encrypted ผ่าน `flutter_secure_storage` |
| 🔒 **Code Obfuscation** | Build ด้วย `--obfuscate` ทำให้ชื่อ class/method อ่านไม่ออกใน APK |
| 🔍 **Root Detection** | ตรวจจับอุปกรณ์ที่ถูก Root |
| 🖥️ **Emulator Detection** | ตรวจจับการรันบน Emulator |
| 📊 **Risk Assessment** | ประเมินระดับความเสี่ยง (%) และแสดง warning ถ้า risk ≥ 30% |
| 💥 **Crashlytics** | รายงาน crash อัตโนมัติพร้อม user context ไปยัง Firebase |
| 📝 **Security Logging** | บันทึก log ทุกเหตุการณ์ด้านความปลอดภัย |

```
ข้อมูลที่เก็บใน Keystore (Secure Storage):
├── activeParentPin      → PIN ผู้ปกครอง
├── activeParentUid      → Firebase UID
├── activeChildId        → Child document ID
├── current_child_id     → Background worker session
└── current_parent_uid   → Background worker session

ข้อมูลที่เก็บใน SharedPreferences (non-sensitive):
├── isChildModeActive    → session flag
├── notif_*              → notification on/off
└── app_locale           → ภาษา
```

---

## 🧪 Unit Tests

เขียน unit tests ครอบคลุม **50 test cases** ด้วย `mockito` และ `fake_cloud_firestore`:

| ไฟล์ | จำนวน test | ครอบคลุม |
|------|-----------|---------|
| `app_exception_test.dart` | 16 | Error mapping ทุก Firebase error code |
| `child_model_test.dart` | 18 | fromMap / toMap / copyWith / edge cases |
| `rewards_repository_impl_test.dart` | 16 | addPoints / redeemReward / history / CRUD |

```bash
# รัน tests ทั้งหมด
flutter test

# รันพร้อม coverage report
flutter test --coverage
```

---

## 📁 โครงสร้างโปรเจค (Project Structure)

```
lib/
├── main.dart                          # Entry point + Firebase + Crashlytics init
├── config/                            # Theme, Routes
├── core/                              # 🧱 Core Layer
│   ├── di/
│   │   └── injection.dart             #   Dependency Injection (get_it)
│   ├── error/
│   │   └── app_exception.dart         #   Centralized error handling
│   └── utils/                         #   Security logger, responsive helper
│
├── data/                              # 💾 Data Layer
│   ├── models/                        #   Data Models (Child, User, Reward, ...)
│   ├── repositories/                  #   Repository Interfaces + Implementations
│   │   ├── rewards_repository.dart    #     Interface (contract)
│   │   └── impl/
│   │       └── rewards_repository_impl.dart  # Firestore implementation
│   └── services/                      #   Firebase / Device Services
│       ├── crashlytics_service.dart   #     Crash reporting
│       └── secure_storage_service.dart#     Android Keystore wrapper
│
├── logic/                             # 🧠 Business Logic
│   ├── providers/                     #   State Management (Provider)
│   └── services/                      #   Background monitoring, location
│
└── presentation/                      # 🎨 UI Layer
    ├── parent/                        #   Parent Mode screens
    └── child/                         #   Child Mode screens

test/
├── core/error/app_exception_test.dart
├── data/models/child_model_test.dart
└── data/repositories/rewards_repository_impl_test.dart
```

---

## ⚙️ การติดตั้ง (Installation)

### Prerequisites

- Flutter SDK 3.10+
- Android Studio พร้อม Android SDK
- Firebase CLI
- อุปกรณ์ Android จริง (แนะนำ) หรือ Emulator

### Steps

```bash
# 1. Clone
git clone https://github.com/Setthapong18/KID_Guard_App.git
cd KID_Guard_App

# 2. ติดตั้ง dependencies
flutter pub get

# 3. วาง google-services.json จาก Firebase Console ไว้ที่ android/app/

# 4. Generate localization files
flutter gen-l10n

# 5. รัน
flutter run
```

---

## 🗄️ โครงสร้างฐานข้อมูล (Database Schema)

```
Firestore
├── users/{userId}
│   ├── name, email, pin
│   └── children/{childId}
│       ├── name, age, avatar
│       ├── screenTime, limitUsedTime, dailyTimeLimit
│       ├── isLocked, isOnline, points
│       ├── apps/           → แอปที่ติดตั้ง (isBlocked)
│       ├── rewards/        → รางวัล (name, cost, emoji)
│       ├── schedulePeriods/→ ช่วงเวลา (Quiet/Sleep)
│       └── notifications/  → การแจ้งเตือน
```

---

## 👥 ผู้พัฒนา

พัฒนาโดยนักศึกษาเป็นส่วนหนึ่งของโปรเจคจบการศึกษา (Senior Project)

---

<p align="center">
  <strong>🛡️ KidGuard — ปกป้องลูกน้อยในโลกดิจิทัล</strong><br/>
  <em>Protecting children in the digital world</em>
</p>
