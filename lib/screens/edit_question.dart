// import 'package:flutter/material.dart';
// import '../models/question_model.dart';
// import '../models/db_connect.dart';

// class EditQuestionPage extends StatefulWidget {
//   final Question question;

//   const EditQuestionPage({Key? key, required this.question}) : super(key: key);

//   @override
//   _EditQuestionPageState createState() => _EditQuestionPageState();
// }

// class _EditQuestionPageState extends State<EditQuestionPage> {
//   late DBconnect db;
//   late TextEditingController questionController;
//   late TextEditingController option1Controller;
//   late TextEditingController option2Controller;
//   late TextEditingController option3Controller;
//   late TextEditingController option4Controller;
//   late String correctOption;

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
// @override
// void initState() {
//   super.initState();
//   db = DBconnect(); // Initialize the db instance
//   questionController = TextEditingController(text: widget.question.title);
//   option1Controller = TextEditingController(
//       text: widget.question.options.keys.firstWhere((key) => widget.question.options[key] == true, orElse: () => 'Option 1'));
//   option2Controller = TextEditingController(
//       text: widget.question.options.keys.firstWhere((key) => widget.question.options[key] == true, orElse: () => 'Option 2'));
//   option3Controller = TextEditingController(
//       text: widget.question.options.keys.firstWhere((key) => widget.question.options[key] == true, orElse: () => 'Option 3'));
//   option4Controller = TextEditingController(
//       text: widget.question.options.keys.firstWhere((key) => widget.question.options[key] == true, orElse: () => 'Option 4'));
//   correctOption = widget.question.options.keys.firstWhere((key) => widget.question.options[key] == true, orElse: () => 'Option 1');
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Question'),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               // Delete the question
//               final DBconnect db = DBconnect();
//               await db.deleteQuestionById(widget.question);

//               // Show a success message
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Question deleted successfully!'),
//                 ),
//               );

//               // Navigate back to the previous screen
//               Navigator.pop(context);
//             },
//             icon: const Icon(Icons.delete),
//           ),
//         ],
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
//                     // Update the question object
//                     Question updatedQuestion = Question(
//   id: widget.question.id,
//   title: questionController.text,
//   options: {
//     option1Controller.text: option1Controller.text.toLowerCase() == 'true',
//     option2Controller.text: option2Controller.text.toLowerCase() == 'true',
//     option3Controller.text: option3Controller.text.toLowerCase() == 'true',
//     option4Controller.text: option4Controller.text.toLowerCase() == 'true',
//   },
// );

// // Save the updated question to the database
// await db.updateQuestion(updatedQuestion);

//                     // Show a success message
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Question updated successfully!'),
//                       ),
//                     );

//                     // Navigate back to the previous screen
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: const Text('Update Question'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildOptionFormField(
//   TextEditingController controller,
//   String label,
//   String optionNumber,
// ) {
//   return Row(
//     children: [
//       Radio<String>(
//         value: label, // Use the label as the value
//         groupValue: correctOption,
//         onChanged: (String? value) {
//           setState(() {
//             correctOption = value ?? ''; // Use the selected option as the correct option
//           });
//         },
//       ),
//       Expanded(
//         child: TextFormField(
//           controller: controller,
//           decoration: InputDecoration(labelText: label),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter $label.';
//             }
//             return null;
//           },
//         ),
//       ),
//     ],
//   );
// }


// }
