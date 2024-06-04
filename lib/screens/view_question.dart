// import 'package:flutter/material.dart';
// import '../models/question_model.dart';
// import '../models/db_connect.dart';

// class ViewQuestionsPage extends StatefulWidget {
//   @override
//   _ViewQuestionsPageState createState() => _ViewQuestionsPageState();
// }

// class _ViewQuestionsPageState extends State<ViewQuestionsPage> {
//   late DBconnect db;
//   late List<Question> questions;

//   @override
//   void initState() {
//     super.initState();
//     db = DBconnect();
//     questions = [];
//     fetchQuestions();
//   }

//   Future<void> fetchQuestions() async {
//     try {
//       List<Question> fetchedQuestions = await db.fetchQuestions();
//       setState(() {
//         questions = fetchedQuestions;
//       });
//     } catch (e) {
//       print('Error fetching questions: $e');
//       // Show an error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to fetch questions.'),
//         ),
//       );
//     }
//   }

//  Future<void> deleteQuestion(Question question) async {
//   try {
//     await db.deleteQuestionById(question); // Pass the question ID
//     // Show a success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Question deleted successfully!'),
//       ),
//     );
//     // Refresh the list of questions
//     fetchQuestions();
//   } catch (e) {
//     print('Error deleting question: $e');
//     // Show an error message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Failed to delete question.'),
//       ),
//     );
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Quiz Questions'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView.builder(
//           itemCount: questions.length,
//           itemBuilder: (context, index) {
//             return ListTile(
//               title: Text(questions[index].title),
//               subtitle: Text('Options: ${questions[index].options.keys.join(", ")}'),
//               // You can customize the display of other question details as needed
//               trailing: IconButton(
//                 icon: const Icon(Icons.delete),
//                 onPressed: () {
//                   // Confirm deletion before proceeding
//                   showDialog(
//                     context: context,
//                     builder: (context) {
//                       return AlertDialog(
//                         title: const Text('Delete Question'),
//                         content: const Text('Are you sure you want to delete this question?'),
//                         actions: [
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             child: const Text('Cancel'),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               // Delete the question and dismiss the dialog
//                               deleteQuestion(questions[index]);
//                               Navigator.pop(context);
//                             },
//                             child: const Text('Delete'),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 },
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
