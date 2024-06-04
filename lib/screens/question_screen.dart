import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Question {
  final String title;
  final List<String>? options;
  final int correctAnswerIndex;

  Question({
    required this.title,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class QuizScreen extends StatefulWidget {
  final String quizId;

  QuizScreen({required this.quizId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questionsFuture;
  int _currentIndex = 0;
  int _score = 0;
  late Timer _timer; // Declare the timer variable
  int _secondsRemaining = 10; // Set the initial time for each question

  @override
  void initState() {
    super.initState();
    _questionsFuture = fetchQuestions(widget.quizId);
    _startTimer(); // Start the timer when the widget initializes
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _nextQuestion(false); // Automatically move to the next question when the timer runs out
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  void _nextQuestion(bool isCorrectAnswer) {
    setState(() {
      if (isCorrectAnswer) {
        _score++;
      }
      _currentIndex++;
      _secondsRemaining = 10; // Reset the timer for the next question
    });
  }

  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      // Prevent going back while the quiz is in progress
      return false;
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Question> questions = snapshot.data!;
            if (questions.isEmpty) {
              return Center(child: Text('No questions available.'));
            }
            return _currentIndex < questions.length
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Question ${_currentIndex + 1}/${questions.length}',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Time Remaining: $_secondsRemaining seconds', // Display the remaining time
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        questions[_currentIndex].title,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 16),
                      ...questions[_currentIndex].options!.map((option) {
                        return ElevatedButton(
                          onPressed: () {
                            _nextQuestion(
                              questions[_currentIndex].options!.indexOf(option) == questions[_currentIndex].correctAnswerIndex,
                            );
                          },
                          child: Text('Option ${questions[_currentIndex].options!.indexOf(option) + 1}: $option'),
                        );
                      }).toList(),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Quiz completed!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Your Score: $_score / ${questions.length}',
                        style: TextStyle(fontSize: 18),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _quizCompleted(_score);
                          Navigator.pop(context);
                        },
                        child: Text('Satisfied with Quiz!'),
                      ),
                    ],
                  );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    ),
  );
}


  void _quizCompleted(int score) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    final userEmail = user?.email;
    final quizId = widget.quizId;

    if (userId != null && quizId != null) {
      await saveUserScore(userId, quizId, userEmail, score);
      Navigator.pop(context);
    }
  }

  Future<void> saveUserScore(String userId, String quizId, String? userEmail, int score) async {
    try {
      DocumentSnapshot quizSnapshot = await FirebaseFirestore.instance.collection('quizzes').doc(quizId).get();
      String quizTitle = quizSnapshot['title'];

      await FirebaseFirestore.instance.collection('user_scores').add({
        'userId': userId,
        'quizId': quizId,
        'quizTitle': quizTitle,
        'userEmail': userEmail,
        'score': score,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to save user score: $e');
    }
  }

  Future<List<Question>> fetchQuestions(String quizId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('quizzes').doc(quizId).collection('questions').get();
      List<Question> questions = [];
      querySnapshot.docs.forEach((doc) {
        List<String>? options = List<String>.from(doc['answers']);
        int correctAnswerIndex = doc['correctAnswerIndex'];
        questions.add(Question(
          title: doc['question'],
          options: options,
          correctAnswerIndex: correctAnswerIndex,
        ));
      });
      return questions;
    } catch (e) {
      throw Exception('Failed to fetch questions: $e');
    }
  }
}