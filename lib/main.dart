import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/timmer_model.dart';
import 'package:untitled3/ui/session_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open the box
  await Hive.initFlutter();
  await Hive.openBox('timeBox'); // Open a Hive box to store the time data

  runApp(
    ChangeNotifierProvider(
      create: (context) => TimerModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer App',
      home: TimerScreen(),
    );
  }
}

class TimerScreen extends StatelessWidget {
  final TextEditingController workTimeController = TextEditingController();
  final TextEditingController breakTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final timerModel = Provider.of<TimerModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Timer App'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SessionHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Work Timer Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Work Time: ${timerModel.formattedTotalTime}',
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                      Text(
                        'Break Time: ${timerModel.formattedBreakTime}',
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: timerModel.totalDuration.inSeconds /
                        timerModel.workTimeLimit.inSeconds,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 10,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        child: Icon(Icons.timer),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final timerModel = Provider.of<TimerModel>(context, listen: false);
        return Container(
          height: 450,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextField(
                controller: workTimeController,
                decoration: InputDecoration(
                  labelText: 'Work Time Limit (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: breakTimeController,
                decoration: InputDecoration(
                  labelText: 'Break Time Limit (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () {
                  int workTimeLimit =
                      int.tryParse(workTimeController.text) ?? 30;
                  int breakTimeLimit =
                      int.tryParse(breakTimeController.text) ?? 5;
                  timerModel.setTimeLimits(
                    Duration(minutes: workTimeLimit),
                    Duration(minutes: breakTimeLimit),
                  );
                  Navigator.pop(context);
                },
                child: Text('Set Time Limits'),
              ),
              ElevatedButton(
                onPressed: () {
                  timerModel.startTimer();
                  Navigator.pop(context);
                },
                child: Text('Start'),
              ),
              ElevatedButton(
                onPressed: () {
                  timerModel.startBreak();
                  Navigator.pop(context);
                },
                child: Text('Break'),
              ),
              ElevatedButton(
                onPressed: () {
                  timerModel.endBreak();
                  Navigator.pop(context);
                },
                child: Text('End Break'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (timerModel.totalDuration >= timerModel.workTimeLimit) {
                    timerModel.resetTimers();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "Cannot clock out. Work time less than limit!")),
                    );
                  }
                },
                child: Text('Clock Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
