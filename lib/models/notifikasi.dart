import 'package:hive/hive.dart';
part 'notifikasi.g.dart';

@HiveType(typeId: 1)
class NotificationItem extends HiveObject {
  @HiveField(0)
  final String content;
  @HiveField(1)
  final DateTime timestamp;
  @HiveField(2)
  final String transactions;

  NotificationItem({
    required this.content,
    required this.timestamp,
    required this.transactions,
  });
}
