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
      Provider.of<TaskProvider>(context, listen: false)
          .resetOldTasks(); // 確保重置舊任務
    });
  }

  // 新增方法：顯示使用說明彈窗
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('使用說明'),
        content: SingleChildScrollView(
          child: Text(_usageInstructions),
        ),
        actions: [
          TextButton(
            child: Text('關閉'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // 使用說明內容
  final String _usageInstructions = '''
使用說明：

1. 創建任務
   - 點擊右下角的「+」按鈕。
   - 輸入任務名稱，選擇期限，並選擇是否為日常任務。
   - 點擊「創建」完成任務的新增。

2. 查看任務隊列
   - 左側有三個隊列（Queue 1、Queue 2、Queue 3）。
   - 點擊不同的隊列以查看該隊列中的任務。

3. 編輯或刪除任務
   - 在任務列表中，向左滑動任務條目。
   - 點擊「編輯」圖標以修改任務內容。
   - 點擊「刪除」圖標以移除任務。

4. 執行任務
   - 點擊任務條目以開始計時。
   - 計時結束後，選擇將任務移至下一個隊列或標記為完成。
   - 對於日常任務，完成後會自動重置以供第二天使用。

5. 任務排序
   - 隊列中的任務會根據「最早截止日期優先」進行排序。

6. 日常任務重置
   - 每天啟動應用時，已完成的日常任務會自動重置，重新加入到第一個隊列。

7. 超過72小時未執行的任務
   - 如果任務在執行後超過72小時未被重新執行，系統會自動將其移回到第一個隊列。

''';

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
                // 有色彩的方塊，並在右上角新增資訊按鈕
                Container(
                  height: 50,
                  color: _queueColors[_selectedQueueIndex],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Queue ${_selectedQueueIndex + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.info, color: Colors.white),
                        onPressed: _showInfoDialog,
                        tooltip: '使用說明',
                      ),
                    ],
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
        tooltip: '創建任務',
      ),
    );
  }
}
