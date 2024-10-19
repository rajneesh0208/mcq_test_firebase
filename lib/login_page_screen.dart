import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mcq_test/login_provider.dart';
import 'package:provider/provider.dart';

import 'first_screen.dart';
import 'home_page_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoogleSignInAccount? _currentUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
    checkUserCredential(); // Automatically sign in if already signed in
  }

  bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    if (googleUser != null) {
      LoginProvider loginProvider =  Provider.of<LoginProvider>(context, listen: false);
      await loginProvider.googleLoginUser(googleUser);

      await storeUserData(googleUser);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FirstScreen()),
      );
    }

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> storeUserData(GoogleSignInAccount googleUser) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final CollectionReference users = FirebaseFirestore.instance.collection('users');

      if (user != null) {
        final String userId = user.uid;

        // Check if the user already exists
        final DocumentSnapshot doc = await users.doc(userId).get();
        if (!doc.exists) {
          // Store user data if they don't exist
          await users.doc(userId).set({
            'email': googleUser.email,
            'name': googleUser.displayName,
            'uniqueId':googleUser.id,
            'score':""
          });
          print('User data stored successfully!');
        } else {
          print('User already exists.');
        }
      } else {
        print('User is not authenticated.');
      }
    } catch (error) {
      print('Error storing user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome to ABC",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.7)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            SizedBox(
              child: FlutterLogo(
                size: 90,
                textColor: Colors.blueAccent,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            ElevatedButton(
              onPressed: signInWithGoogle,
              child: Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }

   checkUserCredential() async {

     final GoogleSignInAccount? user = _currentUser;

    // var isLogin = isAuthenticated();
    if (user != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const FirstScreen()));
    }
  }
}
