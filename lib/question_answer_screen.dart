import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mcq_test/first_screen.dart';
import 'package:mcq_test/question_model.dart';

import 'edit_question_screen.dart';

class QuestionAnswerWidget extends StatefulWidget {
  @override
  _QuestionAnswerWidgetState createState() => _QuestionAnswerWidgetState();
}

class _QuestionAnswerWidgetState extends State<QuestionAnswerWidget> {
  // final Map<String, List<String>> questionAnswers = {
  //   "What is the capital of France?": ["Paris", "London", "Berlin", "Rome"],
  //   "Who developed Flutter?": ["Google", "Microsoft", "Apple", "Facebook"],
  // };

  // int _currentQuestionIndex = 0; // Tracks current question index
  String? _selectedAnswer; // Tracks the selected answer
  int _currentIndex = 0; // Use a nullable String for the selected answer
  bool _showNextButton = false;
  List<Question> _questions = [];
  int _score = 0;

  final Stream<QuerySnapshot> _questionsStream =
      FirebaseFirestore.instance.collection('questions').snapshots();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get current question and answers
    // String currentQuestion =
    //     questionAnswers.keys.elementAt(_currentQuestionIndex);
    // List<String> currentAnswers = questionAnswers[currentQuestion]!;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: /*Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentQuestion,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...currentAnswers.map((answer) => RadioListTile(
                title: Text(answer),
                value: answer,
                groupValue: _selectedAnswer,
                // Radio button is selected based on this value
                onChanged: (value) {
                  setState(() {
                    _selectedAnswer = value; // Update selected answer
                  });
                },
              )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selectedAnswer == null
                ? null // Disable button if no answer is selected
                : () {
                    setState(() {
                      // Move to the next question if available
                      if (_currentQuestionIndex < questionAnswers.length - 1) {
                        _currentQuestionIndex++;
                        _selectedAnswer =
                            null; // Reset answer for the next question
                      } else {
                        // Show completion or results
                        submitResult(20, context);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('You have completed the quiz!'),
                        ));
                      }
                    });
                  },
            child: Text(_currentQuestionIndex < questionAnswers.length - 1
                ? "Next"
                : "Finish"),
          ),
        ],
      ),*/

          StreamBuilder<QuerySnapshot>(
        stream: _questionsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error: Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          debugPrint(snapshot.data!.docs.toString());
          _questions = snapshot.data!.docs
              .map((doc) =>
                  Question.fromJson(doc.data() as Map<String, dynamic>))
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_currentIndex + 1}.",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Text(
                            _questions[_currentIndex].qText,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditQuestionScreen(
                                  question: _questions[_currentIndex],
                                  docId: snapshot
                                      .data!.docs[_currentIndex].reference.id),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit))
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // Display options using RadioListTile
              Column(
                children: _questions[_currentIndex]
                    .option
                    .map((answer) => RadioListTile(
                          title: Text(answer),
                          value: answer,
                          groupValue:
                              _selectedAnswer, // Use the selected answer
                          onChanged: (value) {
                            setState(() {
                              _selectedAnswer =
                                  value as String?; // Cast to nullable String
                              _showNextButton =
                                  true; // Enable "Next" button after selection
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: _selectedAnswer == null
                    ? null // Disable button if no answer is selected
                    : () {
                        setState(() {
                          if (_selectedAnswer ==
                              _questions[_currentIndex].answer) {
                            // Increment the score if the answer is correct
                            _score += 10;
                          }
                          // Move to the next question if available
                          if (_currentIndex < _questions.length - 1) {
                            _currentIndex++;
                            _selectedAnswer =
                                null; // Reset answer for the next question
                          } else {
                            if (_currentIndex < _questions.length - 1) {}
                            // Show completion or results
                            submitResult(_score, context);

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "You have completed the quiz! ${_score.toString()}"),
                            ));
                          }
                        });
                      },
                child: Text(
                    _currentIndex < _questions.length - 1 ? "Next" : "Finish"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> submitResult(int marks, context) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String userId = user.uid;

        // Create a document for the user's results
        final DocumentReference docRef =
            FirebaseFirestore.instance.collection('users').doc(userId);

        // Store the user's answers as a list
        await docRef.set({
          'email': user.email,
          'name': user.displayName,
          'uniqueId': user.uid,
          'score': marks.toString()
        });

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const FirstScreen()));

        print('Results stored successfully!');
      } else {
        print('User is not authenticated.');
      }
    } catch (error) {
      print('Error storing results: $error');
    }
  }
}
