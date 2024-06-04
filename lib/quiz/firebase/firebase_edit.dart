import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class EditQuestionScreen extends StatefulWidget {
  final String docId;

  EditQuestionScreen({required this.docId});

  @override
  _EditQuestionScreenState createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final TextEditingController _questionTextController = TextEditingController();
  final TextEditingController _option1Controller = TextEditingController();
  final TextEditingController _option2Controller = TextEditingController();
  final TextEditingController _option3Controller = TextEditingController();
  final TextEditingController _option4Controller = TextEditingController();
  int _correctAnswerIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch the existing question data and populate the text fields
    fetchQuestionData();
  }

  Future<void> fetchQuestionData() async {
    try {
      DocumentSnapshot questionSnapshot = await FirebaseFirestore.instance
          .collection('multiple_choice_questions')
          .doc(widget.docId)
          .get();

      setState(() {
        _questionTextController.text = questionSnapshot['question'];
        _option1Controller.text = questionSnapshot['options'][0];
        _option2Controller.text = questionSnapshot['options'][1];
        _option3Controller.text = questionSnapshot['options'][2];
        _option4Controller.text = questionSnapshot['options'][3];
        _correctAnswerIndex = questionSnapshot['correctAnswerIndex'];
      });
    } catch (e) {
      print('Failed to fetch question data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Question'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Question Text:'),
              TextField(
                controller: _questionTextController,
                decoration: InputDecoration(labelText: 'Question Text'),
              ),
              SizedBox(height: 16.0),
              Text('Options:'),
              buildOptionTextField(_option1Controller, 0),
              buildOptionTextField(_option2Controller, 1),
              buildOptionTextField(_option3Controller, 2),
              buildOptionTextField(_option4Controller, 3),
              SizedBox(height: 16.0),
              Text('Correct Answer:'),
              DropdownButton<int>(
                value: _correctAnswerIndex,
                onChanged: (value) {
                  setState(() {
                    _correctAnswerIndex = value!;
                  });
                },
                items: [
                  DropdownMenuItem(value: 0, child: Text('Option 1')),
                  DropdownMenuItem(value: 1, child: Text('Option 2')),
                  DropdownMenuItem(value: 2, child: Text('Option 3')),
                  DropdownMenuItem(value: 3, child: Text('Option 4')),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateQuestion,
                child: Text('Edit Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOptionTextField(
      TextEditingController controller, int optionIndex) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: 'Option ${optionIndex + 1}'),
    );
  }

  Future<void> _updateQuestion() async {
    try {
      await FirebaseFirestore.instance
          .collection('multiple_choice_questions')
          .doc(widget.docId)
          .update({
        'question': _questionTextController.text,
        'options': [
          _option1Controller.text,
          _option2Controller.text,
          _option3Controller.text,
          _option4Controller.text,
        ],
        'correctAnswerIndex': _correctAnswerIndex,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('updated successfully')),
      );

      // Navigate back to the quiz management screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('update Failed ')),
      );
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    super.dispose();
  }
}
