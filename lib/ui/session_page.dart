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
              // Correctly retrieve session data as a dynamic map
              final session = sessionBox.getAt(index) as Map<dynamic, dynamic>;

              // Safely access keys
              final date = DateTime.parse(session['date']);
              final workTime = Duration(seconds: session['workTime'] as int);
              final breakTime = Duration(seconds: session['breakTime'] as int);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: ListTile(
                  title: Text(
                    'Date: ${date.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Work Time: ${_formatDuration(workTime)}\nBreak Time: ${_formatDuration(breakTime)}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, sessionBox, index);
                    },
                  ),
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

  void _showDeleteConfirmationDialog(
      BuildContext context, Box sessionBox, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Session'),
          content: Text('Are you sure you want to delete this session?'),
          actions: [
            TextButton(
              onPressed: () {
                // Delete the session
                sessionBox.deleteAt(index);
                Navigator.of(context).pop();
              },
              child: Text('Yes, delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
