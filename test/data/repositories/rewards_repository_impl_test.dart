// ==================== RewardsRepositoryImpl Tests ====================
// ทดสอบ Repository layer โดยใช้ FakeFirebaseFirestore (in-memory)
//
// ไม่ต้องการ network / Firebase emulator จริง
// FakeFirebaseFirestore จำลอง Firestore API ครบ พร้อม subcollections
//
// ครอบคลุม:
// - addPoints(): atomic batch write (points + history)
// - redeemReward(): หักแต้ม + เช็ค insufficient points
// - getPointHistory(): ดึงประวัติแต้ม
// - Custom Rewards CRUD: add, update, delete, get
//
// วิธีรัน:
//   flutter test test/data/repositories/rewards_repository_impl_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidguard/data/repositories/impl/rewards_repository_impl.dart';

void main() {
  group('RewardsRepositoryImpl', () {
    late FakeFirebaseFirestore fakeFirestore;
    late RewardsRepositoryImpl repository;

    // ==================== Constants ====================
    const parentUid = 'parent-test-uid';
    const childId = 'child-test-id';

    // ==================== Helpers ====================
    /// สร้าง child document ด้วย initial points
    Future<void> seedChildPoints(int points) async {
      await fakeFirestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .doc(childId)
          .set({'points': points});
    }

    /// ดึง points ปัจจุบันจาก Firestore
    Future<int> getCurrentPoints() async {
      final snap = await fakeFirestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .doc(childId)
          .get();
      return (snap.data()?['points'] as int?) ?? 0;
    }

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = RewardsRepositoryImpl(fakeFirestore);
    });

    // ==================== addPoints() ====================
    group('addPoints()', () {
      test('increases points by given amount', () async {
        await seedChildPoints(100);

        final result = await repository.addPoints(
          parentUid: parentUid,
          childId: childId,
          amount: 50,
          reason: 'ทำการบ้านเสร็จ',
          date: DateTime.now(),
        );

        expect(result, isTrue);
        expect(await getCurrentPoints(), 150); // 100 + 50 = 150
      });

      test('returns true on success', () async {
        await seedChildPoints(0);

        final result = await repository.addPoints(
          parentUid: parentUid,
          childId: childId,
          amount: 20,
          reason: 'ล้างจาน',
          date: DateTime.now(),
        );

        expect(result, isTrue);
      });

      test('writes history record with correct type', () async {
        await seedChildPoints(0);
        final date = DateTime(2024, 5, 10);

        await repository.addPoints(
          parentUid: parentUid,
          childId: childId,
          amount: 30,
          reason: 'ออกกำลังกาย',
          date: date,
        );

        final historySnap = await fakeFirestore
            .collection('users')
            .doc(parentUid)
            .collection('children')
            .doc(childId)
            .collection('point_history')
            .get();

        expect(historySnap.docs.length, 1);
        final data = historySnap.docs.first.data();
        expect(data['type'], 'earn');
        expect(data['amount'], 30);
        expect(data['reason'], 'ออกกำลังกาย');
      });

      test('starts from 0 when child document has no points field', () async {
        // ไม่ได้ seed points → ไม่มี field 'points'
        await fakeFirestore
            .collection('users')
            .doc(parentUid)
            .collection('children')
            .doc(childId)
            .set({'name': 'มิ้นท์'}); // ไม่มี points field

        final result = await repository.addPoints(
          parentUid: parentUid,
          childId: childId,
          amount: 10,
          reason: 'test',
          date: DateTime.now(),
        );

        expect(result, isTrue);
        expect(await getCurrentPoints(), 10);
      });
    });

    // ==================== redeemReward() ====================
    group('redeemReward()', () {
      test('deducts points on successful redeem', () async {
        await seedChildPoints(200);

        await repository.redeemReward(
          parentUid: parentUid,
          childId: childId,
          cost: 50,
          rewardName: 'ไอศกรีม',
        );

        expect(await getCurrentPoints(), 150);
      });

      test('returns true when points are sufficient', () async {
        await seedChildPoints(100);

        final result = await repository.redeemReward(
          parentUid: parentUid,
          childId: childId,
          cost: 100,
          rewardName: 'เวลาเล่นเกม',
        );

        expect(result, isTrue);
      });

      test('returns false when points are insufficient', () async {
        await seedChildPoints(30); // ไม่พอ

        final result = await repository.redeemReward(
          parentUid: parentUid,
          childId: childId,
          cost: 50, // ต้องการ 50 แต่มี 30
          rewardName: 'ของเล่น',
        );

        expect(result, isFalse);
      });

      test('does not deduct points when insufficient', () async {
        await seedChildPoints(30);

        await repository.redeemReward(
          parentUid: parentUid,
          childId: childId,
          cost: 100,
          rewardName: 'ของเล่น',
        );

        // points ต้องไม่เปลี่ยน
        expect(await getCurrentPoints(), 30);
      });

      test('writes history record with type=redeem', () async {
        await seedChildPoints(500);

        await repository.redeemReward(
          parentUid: parentUid,
          childId: childId,
          cost: 150,
          rewardName: 'ดูหนัง',
        );

        final historySnap = await fakeFirestore
            .collection('users')
            .doc(parentUid)
            .collection('children')
            .doc(childId)
            .collection('point_history')
            .get();

        expect(historySnap.docs.isNotEmpty, isTrue);
        final data = historySnap.docs.first.data();
        expect(data['type'], 'redeem');
        expect(data['amount'], 150);
        expect(data['reason'], 'ดูหนัง');
      });
    });

    // ==================== getPointHistory() ====================
    group('getPointHistory()', () {
      test('returns empty list when no history', () async {
        await seedChildPoints(0);

        final history = await repository.getPointHistory(
          parentUid: parentUid,
          childId: childId,
        );

        expect(history, isEmpty);
      });

      test('returns history after adding points', () async {
        await seedChildPoints(0);
        await repository.addPoints(
          parentUid: parentUid,
          childId: childId,
          amount: 10,
          reason: 'test',
          date: DateTime.now(),
        );

        final history = await repository.getPointHistory(
          parentUid: parentUid,
          childId: childId,
        );

        expect(history.length, 1);
        expect(history.first['amount'], 10);
        expect(history.first['type'], 'earn');
      });
    });

    // ==================== Custom Rewards CRUD ====================
    group('Custom Rewards', () {
      group('addCustomReward()', () {
        test('adds reward to Firestore', () async {
          final result = await repository.addCustomReward(
            parentUid: parentUid,
            name: 'เวลาเล่น iPad',
            emoji: '📱',
            cost: 80,
          );

          expect(result, isTrue);

          final snap = await fakeFirestore
              .collection('users')
              .doc(parentUid)
              .collection('custom_rewards')
              .get();

          expect(snap.docs.length, 1);
          expect(snap.docs.first.data()['name'], 'เวลาเล่น iPad');
          expect(snap.docs.first.data()['emoji'], '📱');
          expect(snap.docs.first.data()['cost'], 80);
        });
      });

      group('getCustomRewards()', () {
        test('returns empty list when no custom rewards', () async {
          final rewards = await repository.getCustomRewards(parentUid);
          expect(rewards, isEmpty);
        });

        test('returns all custom rewards after adding', () async {
          await repository.addCustomReward(
            parentUid: parentUid,
            name: 'ดูหนัง',
            emoji: '🎬',
            cost: 100,
          );
          await repository.addCustomReward(
            parentUid: parentUid,
            name: 'ไอศกรีม',
            emoji: '🍦',
            cost: 50,
          );

          final rewards = await repository.getCustomRewards(parentUid);
          expect(rewards.length, 2);
        });
      });

      group('updateCustomReward()', () {
        test('updates reward fields correctly', () async {
          // เพิ่มก่อน
          await fakeFirestore
              .collection('users')
              .doc(parentUid)
              .collection('custom_rewards')
              .doc('reward-1')
              .set({'name': 'เก่า', 'emoji': '⭐', 'cost': 50});

          final result = await repository.updateCustomReward(
            parentUid: parentUid,
            rewardId: 'reward-1',
            name: 'ใหม่',
            emoji: '🎁',
            cost: 75,
          );

          expect(result, isTrue);

          final snap = await fakeFirestore
              .collection('users')
              .doc(parentUid)
              .collection('custom_rewards')
              .doc('reward-1')
              .get();

          expect(snap.data()!['name'], 'ใหม่');
          expect(snap.data()!['emoji'], '🎁');
          expect(snap.data()!['cost'], 75);
        });
      });

      group('deleteCustomReward()', () {
        test('removes reward from Firestore', () async {
          await fakeFirestore
              .collection('users')
              .doc(parentUid)
              .collection('custom_rewards')
              .doc('reward-to-delete')
              .set({'name': 'ลบได้', 'emoji': '🗑️', 'cost': 10});

          final result = await repository.deleteCustomReward(
            parentUid: parentUid,
            rewardId: 'reward-to-delete',
          );

          expect(result, isTrue);

          final snap = await fakeFirestore
              .collection('users')
              .doc(parentUid)
              .collection('custom_rewards')
              .doc('reward-to-delete')
              .get();

          expect(snap.exists, isFalse);
        });
      });
    });
  });
}
