import 'package:http/http.dart' as http;
import 'dart:convert';
import './question_model.dart';

class DBconnect {
  final url = Uri.parse(
      'https://signin-78484-default-rtdb.firebaseio.com/google-services.json');

  Future<void> addQuestion(Question question) async {
    await http.post(
      url,
      body: json.encode({
        'title': question.title,
        'options': question.options,
      }),
    );
  }

//   Future<List<Question>> fetchQuestions() async {
//   try {
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);

//       List<Question> newQuestions = [];

//       data.forEach((key, value) {
//         print('Fetched question ID: $key');

//         var newQuestion = Question(
//           id: key,
//           title: value['title'],
//           options: Map.castFrom(value['options']),
//         );

//         newQuestions.add(newQuestion);
//       });

//       return newQuestions;
//     } else {
//       throw Exception('Failed to fetch questions');
//     }
//   } catch (e) {
//     print('Error fetching questions: $e');
//     throw Exception('Failed to fetch questions');
//   }
// }


  Future<void> updateQuestion(Question question) async {
    await http.patch(
      Uri.parse('$url/${question.id}.json'),
      body: json.encode({
        'title': question.title,
        'options': question.options,
      }),
    );
  }

  Future<void> deleteQuestionById(Question questionId) async {
  try {
    await http.delete(
      Uri.parse('$url/$questionId.json'),
    );
  } catch (e) {
    print('Error deleting question: $e');
    throw Exception('Failed to delete question');
  }
}
}
