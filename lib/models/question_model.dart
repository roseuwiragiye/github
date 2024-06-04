class Question {
  final String id;
  final String title;
  late final Map<String, bool> options;
  Question({
    required this.id,
    required this.title,
    required this.options, required int correctAnswerIndex,
  });
  
  // @override
  // String toString() {
  //   return 'Question(id: $id, title: $title, options: $options)';
  // }
}
