// lib/models/task.dart
import 'package:hive/hive.dart';

part 'task.g.dart'; // 生成的適配器

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime deadline;

  @HiveField(3)
  bool isDaily;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime? completedDate;

  Task({
    required this.id,
    required this.name,
    required this.deadline,
    this.isDaily = false,
    this.isCompleted = false,
    this.completedDate,
  });
}
