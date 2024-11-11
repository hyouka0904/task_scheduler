// lib/screens/edit_task_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({required this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late DateTime _deadline;
  late bool _isDaily;

  @override
  void initState() {
    super.initState();
    _name = widget.task.name;
    _deadline = widget.task.deadline;
    _isDaily = widget.task.isDaily;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('編輯任務'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 任務名稱
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: '名稱'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入名稱';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              // 任務期限
              ListTile(
                title: Text('期限: ${_deadline.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDeadline,
              ),
              // 是否為日常任務
              SwitchListTile(
                title: const Text('日常任務'),
                value: _isDaily,
                onChanged: (bool value) {
                  setState(() {
                    _isDaily = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedTask = Task(
        id: widget.task.id,
        name: _name,
        deadline: _deadline,
        isDaily: _isDaily,
        isCompleted: widget.task.isCompleted,
        completedDate: widget.task.completedDate,
      );
      Provider.of<TaskProvider>(context, listen: false).editTask(updatedTask);
      Navigator.pop(context);
    }
  }
}
