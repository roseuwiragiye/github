import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:github/screens/question_screen.dart';

class ChooseQuizScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choose Quiz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 81, 189, 243), // Change app bar color
        elevation: 0, // Remove app bar elevation
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0), // Adjust padding
              children: snapshot.data!.docs.map((doc) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(10), // Add rounded corners to the card
                    child: InkWell(
                      onTap: () {
                        // Navigate to quiz screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(quizId: doc.id),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              doc['description'],
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
