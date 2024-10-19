import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginProvider with ChangeNotifier{
  GoogleSignInAccount? loginUser;


  googleLoginUser(user){
    loginUser = user;
    notifyListeners();
  }

}