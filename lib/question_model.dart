class Question {
  String qText;
  List<String> option;
  String answer;

  Question({required this.qText, required this.option, required this.answer});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      qText: json['qText'],
      option: json['option'].cast<String>(),
      answer: json['answer'],
    );
  }
}
