import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:github/quiz/firebase/firebase_edit.dart';


class QuizManagementScreen extends StatelessWidget {
  // Function to delete a question
  Future<void> deleteQuestion(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('multiple_choice_questions')
          .doc(id)
          .delete();
    } catch (e) {
      print('delete Failed : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizes'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('multiple_choice_questions')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return ListTile(
                  title: Text(doc['question']),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Navigate to the edit question screen
                          // Pass the document ID to the edit question screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditQuestionScreen(docId: doc.id),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Function to delete the question
                          deleteQuestion(doc.id);
                        },
                      ),
                    ],
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
