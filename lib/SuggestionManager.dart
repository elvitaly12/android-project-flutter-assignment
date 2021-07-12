import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hello_me/AuthRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class SuggestionManager with ChangeNotifier {


  final saved = <WordPair>{};
  final suggestions = <WordPair>[];
  late WordPair pair;

  String ConvertWordPairToString(WordPair word) {
    return word.join(" ");
  }
  
  WordPair ConvertStrinToWordPair (String s)
  {

    return WordPair(s.split(" ")[0], s.split(" ")[1]);
  }

  void DeleteSuggestionOntap(AuthRepository auth, WordPair pair)
  {
    saved.remove(pair);
    if (auth.isAuthenticated == true) // need to  delete from the cloud as well
        {
      CollectionReference savedsuggestion =
      FirebaseFirestore.instance.collection('saved');
      savedsuggestion.doc(auth.user!.uid).update({'words':
      FieldValue.arrayRemove([ConvertWordPairToString(pair)])});
    }
    notifyListeners();
  }

  void AddSuggOntap(AuthRepository auth, WordPair pair) {
    saved.add(pair);
    if (auth.isAuthenticated == true) // need to  add to the cloud as well
        {
      CollectionReference savedsuggestion =
      FirebaseFirestore.instance.collection('saved');
      savedsuggestion.doc(auth.user!.uid).update({'words':
      FieldValue.arrayUnion([ConvertWordPairToString(pair)])});
    }
    notifyListeners();
  }


  void update(AuthRepository auth) {
    if (auth.status == Status.Unauthenticated) {
      saved.clear();
      notifyListeners();
    }
    else if (auth.status == Status.Authenticated)
    {
      saved.forEach((element) {AddSuggOntap(auth,element); }); // add to the cloud
      CollectionReference savedsuggestion = FirebaseFirestore.instance.collection('saved');

      savedsuggestion.doc(auth.user!.uid).get().then((document) =>  // get all saved from the cloud
          {

              List<String>.from(document['words']).forEach((element) {
                saved.add(ConvertStrinToWordPair(element));
              })
          }).whenComplete(() =>notifyListeners() );
    }
  }
}


























