import 'dart:async';
import 'package:flutter/material.dart';

class TimerModel extends ChangeNotifier {
  Duration totalDuration = Duration();
  Duration breakDuration = Duration();
  Duration workTimeLimit = Duration(minutes: 30); // Default work time limit
  Duration breakTimeLimit = Duration(minutes: 5); // Default break time limit
  Timer? timer;
  bool isRunning = false;
  bool isOnBreak = false; // Track whether the timer is on a break

  void startTimer() {
    if (!isRunning && !isOnBreak) {
      isRunning = true;
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        totalDuration += Duration(seconds: 1);
        notifyListeners();
      });
    }
  }

  void setTimeLimits(Duration workLimit, Duration breakLimit) {
    workTimeLimit = workLimit;
    breakTimeLimit = breakLimit;
    notifyListeners();
  }

  void pauseTimer() {
    if (isRunning) {
      isRunning = false;
      timer?.cancel();
      notifyListeners();
    }
  }

  void startBreak() {
    if (!isOnBreak && isRunning) {
      pauseTimer();
      isOnBreak = true;
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        breakDuration += Duration(seconds: 1);
        notifyListeners();
      });
    }
  }

  void endBreak() {
    if (isOnBreak) {
      timer?.cancel(); // Stop the break timer
      isOnBreak = false;
      startTimer(); // Resume the total timer
      notifyListeners();
    }
  }

  void reset() {
    totalDuration = Duration();
    breakDuration = Duration();
    pauseTimer();
    notifyListeners();
  }

  void resetTimers() {
    totalDuration = Duration.zero;
    breakDuration = Duration.zero;
    notifyListeners();
  }

  String get formattedTotalTime {
    return totalDuration.toString().split('.').first.padLeft(8, '0');
  }

  String get formattedBreakTime {
    return breakDuration.toString().split('.').first.padLeft(8, '0');
  }
}
