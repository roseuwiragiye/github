import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class QuizResultsScreen extends StatefulWidget {
  @override
  _QuizResultsScreenState createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  bool _isDescending = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Score'),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              setState(() {
                _isDescending = !_isDescending;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('user_scores')
            .orderBy('userEmail', descending: _isDescending) // Sort by userEmail
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final users = snapshot.data!.docs;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final userData = users[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text('User: ${userData['userEmail']}'),
                  subtitle: Text('Score: ${userData['score']}'),
                  onTap: () {
                    // Navigate to a new screen to show detailed quiz results
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserQuizDetailsScreen(
                          userId: userData['userId'], // Pass userId here
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}


class UserQuizDetailsScreen extends StatelessWidget {
  final String userId;

  const UserQuizDetailsScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Quiz Details'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('user_scores')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final attempts = snapshot.data!.docs
                .where((doc) => doc['userId'] == userId)
                .toList();

            // Sort the attempts by timestamp and __name__
            attempts.sort((a, b) {
              Timestamp timestampA = a['timestamp'];
              Timestamp timestampB = b['timestamp'];
              int comparison = timestampB.compareTo(timestampA); // Descending order
              if (comparison == 0) {
                return b.id.compareTo(a.id); // Secondary sorting by __name__
              }
              return comparison;
            });

            return ListView.builder(
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                final attemptData = attempts[index].data() as Map<String, dynamic>;
                // Format timestamp into a readable date and time
                DateTime dateTime = attemptData['timestamp'].toDate();
                String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
                return ListTile(
                  title: Text('Quiz Title: ${attemptData['quizTitle']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Email: ${attemptData['userEmail']}'),
                      // Text('Quiz ID: ${attemptData['quizId']}'),
                      Text('Score: ${attemptData['score']}'),
                      Text('Timestamp: $formattedDateTime'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
