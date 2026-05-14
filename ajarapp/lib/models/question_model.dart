class QuestionModel {
  final String type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  String? userAnswer;
  
  int earnedScore; 
  String aiFeedback;

  QuestionModel({
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.userAnswer,
    this.earnedScore = 0,
    this.aiFeedback = "", 
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      type: json['type'] ?? 'mcq',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}