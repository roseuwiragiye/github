import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

ThemeData _appTheme = ThemeData(
  fontFamily: 'Roboto',
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: _appTheme,
      home: ViewQuizzesScreen(),
    );
  }
}

class ViewQuizzesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View '),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['title'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            //SizedBox(height: 8),
                            Text(
                              doc['description'],
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildAnimatedIconButton(
                              icon: Icons.edit_note_rounded,
                              description: 'Edit ',
                              color: Color.fromARGB(255, 96, 180, 173),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditQuizScreen(quizId: doc.id),
                                  ),
                                );
                              },
                            ),
                            //SizedBox(width: 8),
                            _buildAnimatedIconButton(
                              icon: Icons.edit,
                              description: 'Edit ',
                              color: Color.fromARGB(255, 221, 184, 115),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditQuestionListScreen(quizId: doc.id),
                                  ),
                                );
                              },
                            ),
                            //SizedBox(width: 8),
                            _buildAnimatedIconButton(
                              icon: Icons.delete,
                              description: 'Delete ',
                              color: Color.fromARGB(255, 223, 151, 64),
                              onPressed: () {
                                _showDeleteConfirmationDialog(context, doc.id);
                              },
                            ),
                          ],
                        ),
                      ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateQuizScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnimatedIconButton({
    required IconData icon,
    required String description,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Color.fromARGB(255, 242, 237, 212),
            ),
          ),
          //SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String quizId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this quiz?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                deleteQuiz(quizId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteQuiz(String quizId) async {
    try {
      // Delete all questions under the quiz document
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      // Delete the quiz document itself
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .delete();
    } catch (e) {
      print('Failed to delete quiz: $e');
    }
  }
}


class EditQuizScreen extends StatelessWidget {
  final String quizId;

  const EditQuizScreen({required this.quizId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit '),
      ),
      body: EditQuizForm(quizId: quizId),
    );
  }
}

class EditQuizForm extends StatefulWidget {
  final String quizId;

  const EditQuizForm({required this.quizId});

  @override
  _EditQuizFormState createState() => _EditQuizFormState();
}

class _EditQuizFormState extends State<EditQuizForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchQuizDetails();
  }

  Future<void> fetchQuizDetails() async {
    try {
      DocumentSnapshot quizSnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();
      _titleController.text = quizSnapshot['title'];
      _descriptionController.text = quizSnapshot['description'];
    } catch (e) {
      print('Failed to fetch quiz details: $e');
    }
  }

  Future<void> updateQuiz() async {
    try {
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .update({
        'title': _titleController.text,
        'description': _descriptionController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' updated successfully')),
      );
      Navigator.pop(context); // Return to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quiz')),
      );
      print('Failed to update quiz: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            onPressed: updateQuiz,
            child: Text('Update Quiz'),
          ),
        ],
      ),
    );
  }
}

class CreateQuizScreen extends StatefulWidget {
  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> questions =
      []; // List to store questions and their answers

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
            //SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            //SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Add question with empty answer list to the questions list
                setState(() {
                  questions.add({
                    'question': '',
                    'answers': [],
                    'correctAnswerIndex': -1,
                  });
                });
              },
              child: Text('Insert Question'),
            ),
            //SizedBox(height: 16.0),
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
                        decoration:
                            InputDecoration(labelText: 'Question ${index + 1}'),
                      ),
                      //SizedBox(height: 8.0),
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
            //SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Save quiz with questions
                saveQuiz();
              },
              child: Text('Save '),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnswerFields(int index) {
    List<Widget> answerFields = [];
    List<String> answers = List<String>.from(questions[index]['answers'] ?? []);

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
            Radio<int>(
              value: i,
              groupValue: questions[index]['correctAnswerIndex'],
              onChanged: (value) {
                setState(() {
                  questions[index]['correctAnswerIndex'] = value!;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Remove answer field
                setState(() {
                  questions[index]['answers'].removeAt(i);
                  // Adjust correct answer index if needed
                  if (questions[index]['correctAnswerIndex'] == i) {
                    questions[index]['correctAnswerIndex'] = -1;
                  } else if (questions[index]['correctAnswerIndex'] > i) {
                    questions[index]['correctAnswerIndex']--;
                  }
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
      DocumentReference quizRef =
          await FirebaseFirestore.instance.collection('quizzes').add({
        'title': title,
        'description': description,
      });

      // Add questions to the subcollection under the quiz document
      for (Map<String, dynamic> questionData in questions) {
        List<String> answers = List<String>.from(questionData['answers']);
        await quizRef.collection('questions').add({
          'question': questionData['question'],
          'answers': answers,
          'correctAnswerIndex': questionData[
              'correctAnswerIndex'], // Include correct answer index
        });
      }

      // Navigate back or show confirmation
      Navigator.pop(context);
    } catch (e) {
      print('save Failed: $e');
      // Handle error
    }
  }
}

class EditQuestionScreen extends StatefulWidget {
  final String quizId;
  final String questionId;

  const EditQuestionScreen({required this.quizId, required this.questionId});

  @override
  _EditQuestionScreenState createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(), // For option 1
    TextEditingController(), // For option 2
    TextEditingController(), // For option 3
    TextEditingController(), // For option 4
  ];
  int _correctAnswerIndex = -1;
  int _numOptions = 4;

  @override
  void initState() {
    super.initState();
    fetchQuestionDetails();
  }

  Future<void> fetchQuestionDetails() async {
    try {
      DocumentSnapshot questionSnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .collection('questions')
          .doc(widget.questionId)
          .get();
      Map<String, dynamic> questionData =
          questionSnapshot.data() as Map<String, dynamic>;
      _questionController.text = questionData['question'];
      List<dynamic> options = questionData['answers'];
      for (int i = 0; i < options.length; i++) {
        _optionControllers[i].text = options[i];
      }
      _correctAnswerIndex = questionData['correctAnswerIndex'];
      _numOptions = options.length;
    } catch (e) {
      print('Failed to fetch question details: $e');
    }
  }

  void _addOption() {
    setState(() {
      if (_numOptions < 4) {
        _optionControllers[_numOptions].clear();
        _numOptions++;
      }
    });
  }

  void _removeOption() {
    setState(() {
      if (_numOptions > 2) {
        _numOptions--;
      }
    });
  }

  Future<void> updateQuestion() async {
    try {
      List<String> options = [];
      for (int i = 0; i < _numOptions; i++) {
        options.add(_optionControllers[i].text);
      }

      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .collection('questions')
          .doc(widget.questionId)
          .update({
        'question': _questionController.text,
        'answers': options,
        'correctAnswerIndex': _correctAnswerIndex,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question updated successfully')),
      );
      Navigator.pop(context); // Return to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update question')),
      );
      print('Failed to update question: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Question'),
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
              SizedBox(height: 16.0),
              for (int i = 0; i < _numOptions; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _optionControllers[i],
                          decoration:
                              InputDecoration(labelText: 'Option ${i + 1}'),
                        ),
                      ),
                      Radio<int>(
                        value: i,
                        groupValue: _correctAnswerIndex,
                        onChanged: (value) {
                          setState(() {
                            _correctAnswerIndex = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _addOption,
                    child: Text('Add Option'),
                  ),
                  ElevatedButton(
                    onPressed: _removeOption,
                    child: Text('Remove Option'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: updateQuestion,
                child: Text('Update Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditQuestionListScreen extends StatelessWidget {
  final String quizId;

  const EditQuestionListScreen({required this.quizId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Questions'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .doc(quizId)
            .collection('questions')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return ListTile(
                  title: Text(doc['question']),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to edit question screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditQuestionScreen(
                            quizId: quizId,
                            questionId: doc.id,
                          ),
                        ),
                      );
                    },
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