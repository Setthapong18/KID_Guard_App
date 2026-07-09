// ==================== ChildModel Tests ====================
// ทดสอบ ChildModel: constructor, fromMap(), toMap(), copyWith()
//
// ครอบคลุม:
// - fromMap(): parsing Firestore data รวม Timestamp → DateTime
// - fromMap(): fallback values สำหรับ field ที่หายไป
// - toMap(): serialize กลับ → Firestore
// - copyWith(): immutable update ทีละ field
//
// วิธีรัน:
//   flutter test test/data/models/child_model_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidguard/data/models/child_model.dart';

void main() {
  group('ChildModel', () {
    // ==================== Fixtures ====================
    late Map<String, dynamic> validMap;

    setUp(() {
      validMap = {
        'parentId': 'parent-123',
        'name': 'น้องมิ้นท์',
        'age': 8,
        'avatar': 'bear',
        'screenTime': 1200,
        'limitUsedTime': 900,
        'isLocked': false,
        'isOnline': true,
        'lastActive': Timestamp.fromDate(DateTime(2024, 1, 15)),
        'sessionStartTime': null,
        'dailyTimeLimit': 3600,
        'isChildModeActive': false,
        'unlockRequested': false,
        'timeLimitDisabledUntil': null,
        'lockReason': '',
        'points': 150,
        'linkedDeviceId': 'device-abc',
      };
    });

    // ==================== Constructor defaults ====================
    group('constructor', () {
      test('has sensible defaults for optional fields', () {
        final child = ChildModel(
          id: 'c1',
          parentId: 'p1',
          name: 'มิ้นท์',
          age: 8,
        );

        expect(child.screenTime, 0);
        expect(child.limitUsedTime, 0);
        expect(child.isLocked, isFalse);
        expect(child.isOnline, isFalse);
        expect(child.dailyTimeLimit, 0);
        expect(child.isChildModeActive, isFalse);
        expect(child.unlockRequested, isFalse);
        expect(child.lockReason, '');
        expect(child.points, 0);
        expect(child.avatar, isNull);
        expect(child.linkedDeviceId, isNull);
      });
    });

    // ==================== fromMap() ====================
    group('fromMap()', () {
      test('creates ChildModel with full data', () {
        final now = DateTime(2026, 2, 25, 12);
        final sessionStart = DateTime(2026, 2, 25, 8);
        final disabledUntil = DateTime(2026, 2, 25, 18);

        final map = {
          'parentId': 'parent-001',
          'name': 'Som',
          'age': 8,
          'avatar': 'boy_1',
          'screenTime': 3600,
          'limitUsedTime': 1800,
          'isLocked': true,
          'isOnline': true,
          'lastActive': Timestamp.fromDate(now),
          'sessionStartTime': Timestamp.fromDate(sessionStart),
          'dailyTimeLimit': 7200,
          'isChildModeActive': true,
          'unlockRequested': true,
          'timeLimitDisabledUntil': Timestamp.fromDate(disabledUntil),
          'lockReason': 'time_limit',
          'points': 50,
        };

        final child = ChildModel.fromMap(map, 'child-001');

        expect(child.id, 'child-001');
        expect(child.parentId, 'parent-001');
        expect(child.name, 'Som');
        expect(child.age, 8);
        expect(child.avatar, 'boy_1');
        expect(child.screenTime, 3600);
        expect(child.limitUsedTime, 1800);
        expect(child.isLocked, isTrue);
        expect(child.isOnline, isTrue);
        expect(child.lastActive, now);
        expect(child.sessionStartTime, sessionStart);
        expect(child.dailyTimeLimit, 7200);
        expect(child.isChildModeActive, isTrue);
        expect(child.unlockRequested, isTrue);
        expect(child.timeLimitDisabledUntil, disabledUntil);
        expect(child.lockReason, 'time_limit');
        expect(child.points, 50);
      });

      test('uses screenTime as fallback when limitUsedTime is missing', () {
        final map = {...validMap}..remove('limitUsedTime');
        final child = ChildModel.fromMap(map, 'c1');

        expect(child.limitUsedTime, map['screenTime']);
      });

      test(
        'uses 0 as fallback when both limitUsedTime and screenTime missing',
        () {
          final map = {...validMap}
            ..remove('limitUsedTime')
            ..remove('screenTime');
          final child = ChildModel.fromMap(map, 'c1');

          expect(child.limitUsedTime, 0);
          expect(child.screenTime, 0);
        },
      );

      test('handles minimal map gracefully', () {
        final minimalMap = {'parentId': 'p1', 'name': 'มิ้นท์', 'age': 8};

        expect(() => ChildModel.fromMap(minimalMap, 'c1'), returnsNormally);
        final child = ChildModel.fromMap(minimalMap, 'c1');
        expect(child.name, 'มิ้นท์');
        expect(child.points, 0);
        expect(child.avatar, isNull);
      });

      test('parses Timestamp lastActive to DateTime', () {
        final ts = Timestamp.fromDate(DateTime(2024, 6, 1, 10, 30));
        final map = {...validMap, 'lastActive': ts};
        final child = ChildModel.fromMap(map, 'c1');

        expect(child.lastActive, DateTime(2024, 6, 1, 10, 30));
      });

      test('handles null lastActive', () {
        final map = {...validMap, 'lastActive': null};
        final child = ChildModel.fromMap(map, 'c1');

        expect(child.lastActive, isNull);
      });

      test('creates ChildModel with minimal data using defaults', () {
        final child = ChildModel(id: 'c2', parentId: 'p2', name: 'Min', age: 6);

        expect(child.screenTime, 0);
        expect(child.isLocked, isFalse);
        expect(child.points, 0);
      });
    });

    // ==================== toMap() ====================
    group('toMap()', () {
      test('serializes all fields correctly', () {
        final child = ChildModel.fromMap(validMap, 'child-id-1');
        final map = child.toMap();

        expect(map['parentId'], 'parent-123');
        expect(map['name'], 'น้องมิ้นท์');
        expect(map['age'], 8);
        expect(map['avatar'], 'bear');
        expect(map['screenTime'], 1200);
        expect(map['limitUsedTime'], 900);
        expect(map['isLocked'], false);
        expect(map['isOnline'], true);
        expect(map['dailyTimeLimit'], 3600);
        expect(map['points'], 150);
        expect(map['linkedDeviceId'], 'device-abc');
      });

      test('does not include id field', () {
        final child = ChildModel.fromMap(validMap, 'child-id-1');
        final map = child.toMap();

        expect(map.containsKey('id'), isFalse);
      });
    });

    // ==================== copyWith() ====================
    group('copyWith()', () {
      late ChildModel base;

      setUp(() {
        base = ChildModel.fromMap(validMap, 'child-id-1');
      });

      test('returns new instance preserving all values when no args given', () {
        final copy = base.copyWith();

        expect(copy.id, base.id);
        expect(copy.name, base.name);
        expect(copy.points, base.points);
        expect(copy.isLocked, base.isLocked);
        expect(identical(copy, base), isFalse);
      });

      test('overrides isLocked field only', () {
        final locked = base.copyWith(isLocked: true);

        expect(locked.isLocked, isTrue);
        expect(locked.id, base.id);
        expect(locked.name, base.name);
        expect(locked.points, base.points);
      });

      test('overrides points field only', () {
        final updated = base.copyWith(points: 999);

        expect(updated.points, 999);
        expect(updated.isLocked, base.isLocked);
        expect(updated.name, base.name);
      });

      test('overrides lockReason and isLocked together', () {
        final locked = base.copyWith(isLocked: true, lockReason: 'time_limit');

        expect(locked.isLocked, isTrue);
        expect(locked.lockReason, 'time_limit');
      });

      test('overrides name field', () {
        final renamed = base.copyWith(name: 'น้องปลา');

        expect(renamed.name, 'น้องปลา');
        expect(renamed.parentId, base.parentId);
      });

      test('overrides multiple fields simultaneously', () {
        final updated = base.copyWith(
          isLocked: true,
          lockReason: 'sleep',
          isOnline: false,
          points: 200,
        );

        expect(updated.isLocked, isTrue);
        expect(updated.lockReason, 'sleep');
        expect(updated.isOnline, isFalse);
        expect(updated.points, 200);
        // ค่าที่ไม่ได้ override ต้องเป็นเดิม
        expect(updated.name, base.name);
        expect(updated.age, base.age);
        expect(updated.parentId, base.parentId);
      });

      test('original instance is not mutated', () {
        final originalName = base.name;
        final originalPoints = base.points;

        base.copyWith(name: 'New Name', points: 0);

        expect(base.name, originalName);
        expect(base.points, originalPoints);
      });

      test('overrides dailyTimeLimit', () {
        final updated = base.copyWith(dailyTimeLimit: 7200);

        expect(updated.dailyTimeLimit, 7200);
        expect(base.dailyTimeLimit, 3600); // base ไม่เปลี่ยน
      });
    });
  });
}
