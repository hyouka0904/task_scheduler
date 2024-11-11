// lib/screens/task_timer_dialog.dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'dart:async';

class TaskTimerDialog extends StatefulWidget {
  final Task task;

  TaskTimerDialog({required this.task});

  @override
  _TaskTimerDialogState createState() => _TaskTimerDialogState();
}

class _TaskTimerDialogState extends State<TaskTimerDialog> {
  Timer? _timer;
  int _seconds = 3600; // 1 小時
  double _percent = 0.0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_seconds <= 0) {
        timer.cancel();
        _showCompletionOptions();
      } else {
        setState(() {
          _seconds--;
          _percent = (3600 - _seconds) / 3600;
        });
      }
    });
  }

  void _showCompletionOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('任務完成'),
        content: Text('選擇下一步操作'),
        actions: [
          TextButton(
            child: Text('移至下一個 Queue'),
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false)
                  .moveToNextQueue(widget.task);
              Navigator.pop(context); // 關閉選項對話框
              Navigator.pop(context); // 關閉計時對話框
            },
          ),
          TextButton(
            child: Text('完成'),
            onPressed: () {
              // 完成任務
              if (widget.task.isDaily) {
                widget.task.isCompleted = true;
                widget.task.completedDate = DateTime.now();
                Provider.of<TaskProvider>(context, listen: false)
                    .moveToNextQueue(widget.task);
              } else {
                Provider.of<TaskProvider>(context, listen: false)
                    .deleteTask(widget.task.id);
              }
              Navigator.pop(context); // 關閉選項對話框
              Navigator.pop(context); // 關閉計時對話框
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int hrs = seconds ~/ 3600;
    int mins = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('執行中: ${widget.task.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 10.0,
            percent: _percent,
            center: Text(_formatTime(_seconds)),
            progressColor: Colors.green,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('完成'),
          onPressed: () {
            _timer?.cancel();
            if (widget.task.isDaily) {
              widget.task.isCompleted = true;
              widget.task.completedDate = DateTime.now();
              Provider.of<TaskProvider>(context, listen: false)
                  .moveToNextQueue(widget.task);
            } else {
              Provider.of<TaskProvider>(context, listen: false)
                  .deleteTask(widget.task.id);
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
