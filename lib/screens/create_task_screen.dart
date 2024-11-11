// lib/screens/create_task_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class CreateTaskScreen extends StatefulWidget {
  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  DateTime _deadline = DateTime.now().add(Duration(days: 1));
  String _deadlineText =
      DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1)));
  bool _isDaily = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('創建任務'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 任務名稱
              TextFormField(
                decoration: InputDecoration(labelText: '名稱'),
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
              SizedBox(height: 20),
              // 任務期限選擇
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blueAccent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '期限: $_deadlineText',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: _pickDeadline,
                  ),
                ],
              ),
              // 是否為日常任務
              SwitchListTile(
                title: Text('日常任務'),
                value: _isDaily,
                onChanged: (bool value) {
                  setState(() {
                    _isDaily = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('創建'),
                onPressed: _submit,
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
        _deadlineText = DateFormat('yyyy-MM-dd').format(_deadline);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newTask = Task(
        id: Uuid().v4(),
        name: _name,
        deadline: _deadline,
        isDaily: _isDaily,
      );
      Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
      Navigator.pop(context);
    }
  }
}
