// import 'package:flutter/material.dart';
// import '../models/question_model.dart';
// import '../models/db_connect.dart';

// class AddQuestionPage extends StatefulWidget {
//   const AddQuestionPage({Key? key}) : super(key: key);

//   @override
//   _AddQuestionPageState createState() => _AddQuestionPageState();
// }

// class _AddQuestionPageState extends State<AddQuestionPage> {
//   final TextEditingController questionController = TextEditingController();
//   final TextEditingController option1Controller = TextEditingController();
//   final TextEditingController option2Controller = TextEditingController();
//   final TextEditingController option3Controller = TextEditingController();
//   final TextEditingController option4Controller = TextEditingController();

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   String correctOption = '1'; // Default to the first option

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Question'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextFormField(
//                 controller: questionController,
//                 decoration: const InputDecoration(labelText: 'Question'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a question.';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16.0),
//               buildOptionFormField(option1Controller, 'Option 1', option1Controller.text),
//               const SizedBox(height: 16.0),
//               buildOptionFormField(option2Controller, 'Option 2', option2Controller.text),
//               const SizedBox(height: 16.0),
//               buildOptionFormField(option3Controller, 'Option 3', option3Controller.text),
//               const SizedBox(height: 16.0),
//               buildOptionFormField(option4Controller, 'Option 4', option4Controller.text),
//               const SizedBox(height: 32.0),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState?.validate() ?? false) {
//                     // Form is valid, create a Question object
//                     final Question newQuestion = Question(
//                       id: DateTime.now().toString(),
//                       title: questionController.text,
//                       options: {
//                         option1Controller.text: false,
//                         option2Controller.text: false,
//                         option3Controller.text: false,
//                         option4Controller.text: false,
//                       },
//                     );

//                     // Set the correct option based on user selection
//                     newQuestion.options[correctOption] = true;

//                     // Save the question to the database
//                     final DBconnect db = DBconnect();
//                     await db.addQuestion(newQuestion);

//                     // Clear the form
//                     questionController.clear();
//                     option1Controller.clear();
//                     option2Controller.clear();
//                     option3Controller.clear();
//                     option4Controller.clear();

//                     // Show a success message or navigate to a different page
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Question added successfully!'),
//                       ),
//                     );
//                   }
//                 },
//                 child: const Text('Save Question'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildOptionFormField(
//     TextEditingController controller,
//     String label,
//     String optionNumber,
//   ) {
//     return Row(
//       children: [
//         Radio<String>(
//           value: optionNumber,
//           groupValue: correctOption,
//           onChanged: (String? value) {
//             setState(() {
//               correctOption = value ?? '1'; // Default to the first option if null
//             });
//           },
//         ),
//         Expanded(
//           child: TextFormField(
//             controller: controller,
//             decoration: InputDecoration(labelText: label),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter $label.';
//               }
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
