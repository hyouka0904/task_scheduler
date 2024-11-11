// lib/providers/task_provider.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  late Box<Task> _taskBox;

  // 三個 Queue
  List<Task> queue1 = [];
  List<Task> queue2 = [];
  List<Task> queue3 = [];

  TaskProvider() {
    _init();
  }

  Future<void> _init() async {
    _taskBox = Hive.box<Task>('tasks');
    _loadTasks();
    resetDailyTasks(); // 重置日常任務
    resetOldTasks(); // 新增的功能：重置超過72小時未執行的任務
  }

  void _loadTasks() {
    // 將所有任務從 Hive 讀取並分配到各個 Queue
    for (var task in _taskBox.values) {
      if (queue1.contains(task) ||
          queue2.contains(task) ||
          queue3.contains(task)) {
        // 已經在某個隊列中，跳過
        continue;
      }
      // 根據隊列分配邏輯將任務添加到對應的隊列中
      // 假設所有新任務最初都在 Queue1
      queue1.add(task);
    }
    sortAllQueues();
    notifyListeners();
  }

  // 添加任務到第一個 queue
  void addTask(Task task) {
    queue1.add(task);
    _taskBox.put(task.id, task);
    sortQueue(queue1);
    notifyListeners();
  }

  // 刪除任務
  void deleteTask(String id) {
    Task? task = _taskBox.get(id);
    if (task != null) {
      queue1.remove(task);
      queue2.remove(task);
      queue3.remove(task);
      _taskBox.delete(id);
      notifyListeners();
    }
  }

  // 編輯任務
  void editTask(Task updatedTask) {
    deleteTask(updatedTask.id);
    addTask(updatedTask);
  }

  // 移動任務到下一個 queue 或完成
  void moveToNextQueue(Task task) {
    if (queue1.contains(task)) {
      queue1.remove(task);
      queue2.add(task);
      sortQueue(queue2);
    } else if (queue2.contains(task)) {
      queue2.remove(task);
      queue3.add(task);
      sortQueue(queue3);
    } else if (queue3.contains(task)) {
      queue3.remove(task);
      // 完成
      if (task.isDaily) {
        // 對於日常任務，將其標記為已完成，稍後會重新加入
        task.isCompleted = true;
        task.completedDate = DateTime.now();
        _taskBox.put(task.id, task);
      } else {
        deleteTask(task.id);
      }
    }
    notifyListeners();
  }

  // 排序所有隊列
  void sortAllQueues() {
    sortQueue(queue1);
    sortQueue(queue2);
    sortQueue(queue3);
  }

  // 排序使用 Early Deadline First
  void sortQueue(List<Task> queue) {
    queue.sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  // 重新加入日常任務
  void resetDailyTasks() {
    DateTime today = DateTime.now();
    for (var task in _taskBox.values) {
      if (task.isDaily && task.isCompleted) {
        if (task.completedDate == null ||
            !isSameDay(task.completedDate!, today)) {
          task.isCompleted = false;
          task.completedDate = null;
          if (!queue1.contains(task)) {
            // 移除其他隊列中的任務
            queue2.remove(task);
            queue3.remove(task);
            queue1.add(task);
            _taskBox.put(task.id, task);
          }
        }
      }
    }
    sortQueue(queue1);
    notifyListeners();
  }

  // 新增方法：重置超過72小時未執行的任務
  void resetOldTasks() {
    DateTime now = DateTime.now();
    Duration threshold = Duration(hours: 72);

    for (var task in _taskBox.values) {
      if (task.completedDate != null) {
        Duration diff = now.difference(task.completedDate!);
        if (diff > threshold) {
          // 如果任務不在 Queue1 中，則移動到 Queue1
          if (!queue1.contains(task)) {
            queue2.remove(task);
            queue3.remove(task);
            queue1.add(task);
            _taskBox.put(task.id, task);
          }
        }
      }
    }
    sortQueue(queue1);
    notifyListeners();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 獲取某個隊列的任務
  List<Task> getQueue(int index) {
    if (index == 0) return queue1;
    if (index == 1) return queue2;
    return queue3;
  }
}
