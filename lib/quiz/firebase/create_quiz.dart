import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateQuizScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  CreateQuizScreen({Key? key}) : super(key: key);

  // Function to add a new quiz to Firestore
  Future<void> addQuiz(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('quizzes').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        // Add other quiz details as needed
      });
      Navigator.pop(context); // Go back to the previous screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Quiz'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            //SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            //SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => addQuiz(context),
              child: Text('Save Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
