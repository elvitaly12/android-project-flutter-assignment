import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }
enum LogStat {In , Out}

class AuthRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User? _user;
  Status _status = Status.Uninitialized;
  bool logged = false;
  String image_url = "";


  AuthRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
    _onAuthStateChanged(_user);
  }

  Status get status => _status;


  User? get user => _user;

  bool get isAuthenticated => status == Status.Authenticated;

  bool get isUninitialized => status == Status.Uninitialized;



  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e);
      _status = Status.Unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      logged=true;
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      logged=false;
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    logged=false;
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.Unauthenticated;


    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
      await GetImageUrl();
    }
    notifyListeners();
  }

  Future<void> GetImageUrl () async
  {
    try
    {
      FirebaseStorage storage =  await FirebaseStorage.instance;
      String user_id = user!.uid;
      image_url  =   await storage.ref().child(user_id).getDownloadURL();
      notifyListeners();
    }
    catch(e)
    {
      image_url="";
    }


  }



















}



