import 'package:flutter_test/flutter_test.dart';
import 'package:notisaver/data/models/saved_notification.dart';

void main() {
  group('SavedNotification', () {
    test('normalized trims fields and computes a stable content key', () {
      final notification = SavedNotification(
        appName: '  WhatsApp  ',
        packageName: '  com.whatsapp  ',
        title: '  Alice  ',
        message: '  Hello there  ',
        subText: '  2 new messages  ',
        timestamp: DateTime.fromMillisecondsSinceEpoch(1),
        notificationKey: '  key-1  ',
        category: '  msg  ',
      ).normalized();

      expect(notification.appName, 'WhatsApp');
      expect(notification.packageName, 'com.whatsapp');
      expect(notification.title, 'Alice');
      expect(notification.message, 'Hello there');
      expect(notification.subText, '2 new messages');
      expect(notification.notificationKey, 'key-1');
      expect(notification.category, 'msg');
      expect(
        notification.contentKey,
        'com.whatsapp|alice|hello there|2 new messages|msg',
      );
    });

    test('content key ignores casing differences after normalization', () {
      final a = SavedNotification(
        appName: 'Messenger',
        packageName: 'com.facebook.orca',
        title: 'Bob',
        message: 'See you soon',
        subText: '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(10),
        notificationKey: 'first',
        category: 'msg',
      ).normalized();

      final b = SavedNotification(
        appName: 'MESSENGER',
        packageName: 'COM.FACEBOOK.ORCA',
        title: ' bob ',
        message: ' SEE YOU SOON ',
        subText: ' ',
        timestamp: DateTime.fromMillisecondsSinceEpoch(20),
        notificationKey: 'second',
        category: ' MSG ',
      ).normalized();

      expect(a.contentKey, b.contentKey);
    });
  });
}
