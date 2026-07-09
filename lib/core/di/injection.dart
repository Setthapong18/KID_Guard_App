// ==================== Dependency Injection ====================
// ตั้งค่า Service Locator ด้วย get_it
//
// Clean Architecture DI ใน KID Guard:
//
// Layer 1 — Services (Data Sources):
//   SecurityService, AuthService
//
// Layer 2 — Repositories (Business Logic Contracts):
//   AuthRepository  → AuthRepositoryImpl  → AuthService
//   RewardsRepository → RewardsRepositoryImpl → Firestore
//   ChildRepository → ChildRepositoryImpl → Firestore
//
// Layer 3 — Providers (UI State):
//   AuthProvider ใช้ AuthRepository (ไม่ใช้ AuthService โดยตรง)
//   RewardsProvider ใช้ RewardsRepository
//
// วิธีใช้:
// ```dart
// // ใน main() ก่อน runApp()
// await initDependencies();
//
// // ดึง instance
// final authRepo = sl<AuthRepository>();
// final rewardsRepo = sl<RewardsRepository>();
// ```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '../../data/services/security_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/rewards_repository.dart';
import '../../data/repositories/child_repository.dart';
import '../../data/repositories/impl/auth_repository_impl.dart';
import '../../data/repositories/impl/rewards_repository_impl.dart';
import '../../data/repositories/impl/child_repository_impl.dart';

/// Global service locator instance
/// ใช้ `sl<T>()` แทน `GetIt.instance<T>()` เพื่อความสั้นกระชับ
final GetIt sl = GetIt.instance;

/// Initialize ทุก Dependencies ตาม Clean Architecture layers
/// เรียกใน main() ก่อน runApp()
Future<void> initDependencies() async {
  // ==================== Layer 1: Services ====================
  // Services เป็น Singleton — สร้างครั้งเดียว ใช้ตลอด

  if (!sl.isRegistered<SecurityService>()) {
    sl.registerLazySingleton<SecurityService>(() => SecurityService());
  }

  if (!sl.isRegistered<AuthService>()) {
    sl.registerLazySingleton<AuthService>(() => AuthService());
  }

  // ==================== Layer 2: Repositories ====================
  // Register Interface → Implementation mapping
  // ทำให้ Provider ขึ้นกับ Interface ไม่ใช่ Implementation
  // → ง่ายต่อการ Mock ใน Unit Tests

  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthService>()),
    );
  }

  if (!sl.isRegistered<RewardsRepository>()) {
    sl.registerLazySingleton<RewardsRepository>(
      () => RewardsRepositoryImpl(FirebaseFirestore.instance),
    );
  }

  if (!sl.isRegistered<ChildRepository>()) {
    sl.registerLazySingleton<ChildRepository>(
      () => ChildRepositoryImpl(FirebaseFirestore.instance),
    );
  }
}
