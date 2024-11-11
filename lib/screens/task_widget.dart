// lib/screens/task_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'task_timer_dialog.dart';
import 'edit_task_screen.dart';

class TaskWidget extends StatelessWidget {
  final Task task;

  const TaskWidget({required this.task});

  @override
  Widget build(BuildContext context) {
    final deadlineText = DateFormat('yyyy-MM-dd').format(task.deadline);

    return Slidable(
      key: Key(task.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              // 編輯任務
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTaskScreen(task: task),
                ),
              );
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: '編輯',
          ),
          SlidableAction(
            onPressed: (_) {
              // 刪除任務
              Provider.of<TaskProvider>(context, listen: false)
                  .deleteTask(task.id);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '刪除',
          ),
        ],
      ),
      child: ListTile(
        title: Text(task.name),
        subtitle: Text('期限: $deadlineText'),
        trailing:
            task.isDaily ? const Icon(Icons.repeat, color: Colors.green) : null,
        onTap: () {
          // 開始執行任務
          showDialog(
            context: context,
            builder: (context) => TaskTimerDialog(task: task),
          );
        },
      ),
    );
  }
}
