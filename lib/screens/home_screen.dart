// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'create_task_screen.dart';
import 'task_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedQueueIndex = 0; // 默認選擇隊列1

  // 定義不同隊列的背景顏色
  final List<Color> _queueColors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
  ];

  @override
  void initState() {
    super.initState();
    // 檢查日常任務是否需要重置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).resetDailyTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    List<Task> currentQueue = taskProvider.getQueue(_selectedQueueIndex);

    return Scaffold(
      body: Row(
        children: [
          // 左側欄
          NavigationRail(
            selectedIndex: _selectedQueueIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedQueueIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.queue, color: _queueColors[0]),
                label: Text('Queue 1'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.queue, color: _queueColors[1]),
                label: Text('Queue 2'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.queue, color: _queueColors[2]),
                label: Text('Queue 3'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          // 主內容
          Expanded(
            child: Column(
              children: [
                // 有色彩的方塊
                Container(
                  height: 50,
                  color: _queueColors[_selectedQueueIndex],
                  child: Center(
                    child: Text(
                      'Queue ${_selectedQueueIndex + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: currentQueue.isEmpty
                      ? Center(child: Text('沒有任務'))
                      : ListView.builder(
                          itemCount: currentQueue.length,
                          itemBuilder: (context, index) {
                            return TaskWidget(task: currentQueue[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 打開創建任務的彈窗
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTaskScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
