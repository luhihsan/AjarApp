class QuestionModel {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  String? userAnswer;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.userAnswer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}