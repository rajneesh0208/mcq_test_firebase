import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcq_test/home_page_screen.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  String result = "";
  String name = "";

  Future<String> getStoredResults() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String userId = user.uid;
        setState(() {
          name = user.displayName.toString();
        });
        // Retrieve the user's results document
        final DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        // Extract the user's answers from the document
        if (doc.exists) {
          setState(() {
            result = doc['score'];
          });

          return result;
        } else {
          print('No results found for this user.');
          return "";
        }
      } else {
        print('User is not authenticated.');
        return "";
      }
    } catch (error) {
      print('Error retrieving results: $error');
      return "";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getStoredResults();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        backgroundColor: Colors.purple.shade50,
        centerTitle: true,
      ),
      body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome Back ${name.toUpperCase()}",
                style: TextStyle(
                    color: Colors.blueAccent.shade200,
                    fontSize: 25,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 100,
              ),
              result.isNotEmpty
                  ? Text("Your previous Result Score is : $result")
                  : const SizedBox(),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: const Text('Proceed With Assessment'),
              ),
            ],
          )),
    );
  }
}
