import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateQuizScreen extends StatefulWidget {
  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> questions = []; // List to store questions and their answers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Quiz'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Add question with empty answer list to the questions list
                setState(() {
                  questions.add({
                    'question': '',
                    'answers': [],
                  });
                });
              },
              child: Text('Add Question'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onChanged: (text) {
                          questions[index]['question'] = text;
                        },
                        decoration: InputDecoration(labelText: 'Question ${index + 1}'),
                      ),
                      SizedBox(height: 8.0),
                      ..._buildAnswerFields(index),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          // Add empty answer field
                          setState(() {
                            questions[index]['answers'].add('');
                          });
                        },
                        child: Text('Add Answer'),
                      ),
                      SizedBox(height: 16.0),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Save quiz with questions
                saveQuiz();
              },
              child: Text('Save Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnswerFields(int index) {
    List<Widget> answerFields = [];
    List<String> answers = questions[index]['answers'];

    for (int i = 0; i < answers.length; i++) {
      answerFields.add(
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (text) {
                  questions[index]['answers'][i] = text;
                },
                decoration: InputDecoration(labelText: 'Answer ${i + 1}'),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Remove answer field
                setState(() {
                  questions[index]['answers'].removeAt(i);
                });
              },
            ),
          ],
        ),
      );
    }
    return answerFields;
  }

  void saveQuiz() async {
    try {
      String title = _titleController.text;
      String description = _descriptionController.text;

      // Add quiz to Firestore
      DocumentReference quizRef = await FirebaseFirestore.instance.collection('quizzes').add({
        'title': title,
        'description': description,
      });

      // Add questions to the subcollection under the quiz document
      for (Map<String, dynamic> questionData in questions) {
        List<String> answers = List<String>.from(questionData['answers']);
        await quizRef.collection('questions').add({
          'question': questionData['question'],
          'answers': answers,
        });
      }

      // Navigate back or show confirmation
      Navigator.pop(context);
    } catch (e) {
      print('Failed to save quiz: $e');
      // Handle error
    }
  }
}

class AddQuestionScreen extends StatefulWidget {
  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _option1Controller = TextEditingController();
  final TextEditingController _option2Controller = TextEditingController();
  final TextEditingController _option3Controller = TextEditingController();
  final TextEditingController _option4Controller = TextEditingController();
  int _correctAnswerIndex = -1;

  // Function to add a new multiple-choice question to Firestore
  Future<void> addQuestion() async {
    try {
      await FirebaseFirestore.instance.collection('multiple_choice_questions').add({
        'question': _questionController.text,
        'options': [
          _option1Controller.text,
          _option2Controller.text,
          _option3Controller.text,
          _option4Controller.text
        ],
        'correctAnswerIndex': _correctAnswerIndex,
      });
      Navigator.pop(context); // Go back to the previous screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add question')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert Question'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _questionController,
                decoration: InputDecoration(labelText: 'Question'),
              ),
              //SizedBox(height: 8.0),
              TextField(
                controller: _option1Controller,
                decoration: InputDecoration(labelText: 'Insert an Option '),
              ),
              //SizedBox(height: 8.0),
              TextField(
                controller: _option2Controller,
                decoration: InputDecoration(labelText: 'Insert an Option'),
              ),
              //SizedBox(height: 8.0),
              TextField(
                controller: _option3Controller,
                decoration: InputDecoration(labelText: 'Insert an Option'),
              ),
              //SizedBox(height: 8.0),
              TextField(
                controller: _option4Controller,
                decoration: InputDecoration(labelText: 'Option 4'),
              ),
              //SizedBox(height: 8.0),
              Text(
                'Select Correct Answer:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Column(
                children: [
                  RadioListTile<int>(
                    title: Text('Insert an Option'),
                    value: 0,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) {
                      setState(() {
                        _correctAnswerIndex = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Insert an Option'),
                    value: 1,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) {
                      setState(() {
                        _correctAnswerIndex = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Insert an Option'),
                    value: 2,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) {
                      setState(() {
                        _correctAnswerIndex = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('Insert an Option'),
                    value: 3,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) {
                      setState(() {
                        _correctAnswerIndex = value!;
                      });
                    },
                  ),
                ],
              ),
              //SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: addQuestion,
                child: Text('Insert Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
