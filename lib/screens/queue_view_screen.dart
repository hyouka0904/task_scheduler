// lib/screens/queue_view_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'task_widget.dart';

class QueueViewScreen extends StatelessWidget {
  final int queueIndex;

  const QueueViewScreen({required this.queueIndex});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    List<Task> queue = [];
    if (queueIndex == 0) {
      queue = taskProvider.queue1;
    } else if (queueIndex == 1) {
      queue = taskProvider.queue2;
    } else if (queueIndex == 2) {
      queue = taskProvider.queue3;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Queue ${queueIndex + 1}'),
      ),
      body: ListView.builder(
        itemCount: queue.length,
        itemBuilder: (context, index) {
          return TaskWidget(task: queue[index]);
        },
      ),
    );
  }
}
