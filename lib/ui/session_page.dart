import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SessionHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session History'),
      ),
      body: FutureBuilder(
        future: Hive.openBox('sessionBox'), // Use the session box
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final sessionBox = Hive.box('sessionBox'); // Changed to 'sessionBox'
          if (sessionBox.isEmpty) {
            return Center(child: Text('No sessions found.'));
          }

          return ListView.builder(
            itemCount: sessionBox.length,
            itemBuilder: (context, index) {
              // Ensure correct type when retrieving session data
              final session = sessionBox.getAt(index) as Map<String, dynamic>;
              final date = DateTime.parse(session['date']);
              final workTime = Duration(seconds: session['workTime']);
              final breakTime = Duration(seconds: session['breakTime']);

              return ListTile(
                title: Text(
                  'Date: ${date.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Work Time: ${_formatDuration(workTime)}\nBreak Time: ${_formatDuration(breakTime)}',
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, '0');
  }
}
