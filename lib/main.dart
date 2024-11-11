// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive
  await Hive.initFlutter();

  // 註冊適配器
  Hive.registerAdapter(TaskAdapter());

  // 打開盒子
  await Hive.openBox<Task>('tasks');

  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: WorkManagerApp(),
    ),
  );
}

class WorkManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Work Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
