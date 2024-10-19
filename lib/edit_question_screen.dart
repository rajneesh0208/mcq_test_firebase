import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mcq_test/question_model.dart';

class EditQuestionScreen extends StatefulWidget {
  final Question question;
  final String docId;

  const EditQuestionScreen({
    super.key,
    required this.question,
    required this.docId,
  });

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  String _questionText = "";
  List<String> _options = [];
  String _selectedAnswer = "";

  final questionController = TextEditingController();
  final o1Controller = TextEditingController();
  final o2Controller = TextEditingController();
  final o3Controller = TextEditingController();
  final o4Controller = TextEditingController();
  final ansController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _questionText = widget.question.qText;
    _options = widget.question.option;
    _selectedAnswer = widget.question.answer;
    questionController.text = _questionText;
    o1Controller.text = _options[0];
    o2Controller.text = _options[1];
    o3Controller.text = _options[2];
    o4Controller.text = _options[3];
    ansController.text = _selectedAnswer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Question"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: questionController,
              decoration: InputDecoration(
                hintText: _questionText,
                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xFFD9E2EC).withOpacity(0.3),
              ),
              // onTap: () {
              //   questionController.selection = TextSelection.fromPosition(
              //     TextPosition(offset: questionController.text.length),
              //   );
              // },
              onChanged: (value) {
                _questionText = value;
              },
            ),
            SizedBox(height: 10,),
            TextField(
              controller: o1Controller,
              decoration: InputDecoration(
                hintText: _options[0],
                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xFFD9E2EC).withOpacity(0.3),
              ),
              onChanged: (value) {
                _options[0] = value;
              },
            ),
            SizedBox(height: 10,),
            TextField(
              controller: o2Controller,
              decoration: InputDecoration(
                hintText: _options[1],
                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xFFD9E2EC).withOpacity(0.3),
              ),
              onChanged: (value) {
                _options[1] = value;
              },
            ),
            SizedBox(height: 10,),
            TextField(
              controller: o3Controller,
              decoration: InputDecoration(
                hintText: _options[2],

                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xFFD9E2EC).withOpacity(0.3),
              ),
              onChanged: (value) {
                _options[2] = value;
              },
            ),
            SizedBox(height: 10,),
            TextField(
              controller: o4Controller,
              decoration: InputDecoration(
                hintText: _options[3],

                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xFFD9E2EC).withOpacity(0.3),
              ),
              onChanged: (value) {
                _options[3] = value;
              },
            ),
            SizedBox(height: 10,),
            TextField(
              controller: ansController,
              decoration: InputDecoration(
                hintText: _selectedAnswer,
                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xFFD9E2EC).withOpacity(0.3),
              ),
              onChanged: (value) {
                _selectedAnswer = value;
              },
            ),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: () {
              if (_isValidate()) {
                List<String> opt = [];
                opt.add(o1Controller.text);
                opt.add(o2Controller.text);
                opt.add(o3Controller.text);
                opt.add(o4Controller.text);
                FirebaseFirestore.instance
                    .collection('questions')
                    .doc(widget.docId)
                    .set({
                  'qText': questionController.text,
                  'option': opt,
                  'answer': ansController.text,
                }, SetOptions(merge: true));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "Question Updated!"),
                ));
                Navigator.pop(context);
              }
            }, child: const Text("Update"))
          ],
        ),
      ),
    );
  }

  bool _isValidate() {
    if (questionController.text.isEmpty) {
      return false;
    }
    else if (o1Controller.text.isEmpty || o2Controller.text.isEmpty ||
        o3Controller.text.isEmpty || o4Controller.text.isEmpty) {
      return false;
    }
    else if(ansController.text.isEmpty){
      return false;
    }
    return true;
  }
}
