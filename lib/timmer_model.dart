import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TimerModel extends ChangeNotifier {
  Duration totalDuration = Duration.zero;
  Duration breakDuration = Duration.zero;
  Duration workTimeLimit = Duration(minutes: 30); // Default work time limit
  Duration breakTimeLimit = Duration(minutes: 5); // Default break time limit
  Timer? timer;
  bool isOnBreak = false; // Single flag to track break status

  late Box _timeBox;
  late Box _sessionBox;

  TimerModel() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _timeBox = await Hive.openBox('timeBox');
    totalDuration = _getDurationFromHive('totalDuration');
    breakDuration = _getDurationFromHive('breakDuration');
    notifyListeners();
  }

  void _saveSession() {
    final session = {
      'date': DateTime.now().toIso8601String(),
      'workTime': totalDuration.inSeconds,
      'breakTime': breakDuration.inSeconds,
    };
    _sessionBox.add(session); // Save each session to Hive
  }

  Duration _getDurationFromHive(String key) {
    final seconds = _timeBox.get(key, defaultValue: 0);
    return Duration(seconds: seconds);
  }

  void _saveDurationToHive(String key, Duration duration) {
    _timeBox.put(key, duration.inSeconds);
  }

  void startTimer() {
    if (timer == null && !isOnBreak) {
      // Timer should start only if not already running and not on break
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        totalDuration += Duration(seconds: 1);
        _saveDurationToHive('totalDuration', totalDuration);
        notifyListeners();

        // Stop the timer if it exceeds work time limit
        if (totalDuration >= workTimeLimit) {
          stopTimer();
          _saveSession(); // Save session data when the work timer ends
        }
      });
    }
  }

  void setTimeLimits(Duration workLimit, Duration breakLimit) {
    workTimeLimit = workLimit;
    breakTimeLimit = breakLimit;
    notifyListeners();
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
    notifyListeners();
  }

  void startBreak() {
    if (!isOnBreak && timer != null) {
      stopTimer(); // Stop work timer first
      isOnBreak = true;
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        breakDuration += Duration(seconds: 1);
        _saveDurationToHive('breakDuration', breakDuration);
        notifyListeners();

        // Stop break timer if it exceeds break time limit
        if (breakDuration >= breakTimeLimit) {
          endBreak();
        }
      });
    }
  }

  void endBreak() {
    if (isOnBreak) {
      stopTimer(); // Stop the break timer
      isOnBreak = false;
      startTimer(); // Resume the work timer
    }
  }

  void resetTimers() {
    totalDuration = Duration.zero;
    breakDuration = Duration.zero;
    _saveDurationToHive('totalDuration', totalDuration);
    _saveDurationToHive('breakDuration', breakDuration);
    stopTimer();
    notifyListeners();
  }

  String get formattedTotalTime {
    return totalDuration.toString().split('.').first.padLeft(8, '0');
  }

  String get formattedBreakTime {
    return breakDuration.toString().split('.').first.padLeft(8, '0');
  }
}
