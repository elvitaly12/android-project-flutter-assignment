// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/AuthRepository.dart';
import 'package:hello_me/SuggestionManager.dart';
import 'package:hello_me/login.dart';
import 'package:hello_me/savedSugg.dart';
import 'package:hello_me/snapping_sheet.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthRepository>(
          create: (_) => AuthRepository.instance(),
        ),
        ChangeNotifierProxyProvider<AuthRepository, SuggestionManager>(
          create: (_) => SuggestionManager(),
          update: (_, auth, sm) => sm!..update(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          // Add the 3 lines from here...
          primaryColor: Colors.red,
        ), // ... to here.
        home: RandomWords(),
      ),
    );
  }
}

// #docregion _RandomWordsState, RWS-class-only
class _RandomWordsState extends State<RandomWords> with ChangeNotifier {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
          Consumer<AuthRepository>(builder: (context, auth, _) {
            return auth.isAuthenticated ?
            IconButton(icon: Icon(Icons.exit_to_app), onPressed: _pressexit) :
            IconButton(icon: Icon(Icons.login), onPressed: _presslog);
          }),


        ],
      ),
      body:Consumer<AuthRepository>(builder: (context, auth, _)
          {
            return auth.isAuthenticated?Snapp():
          _buildSuggestions();
          },));
  }

  void _pushSaved() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      // NEW lines from here...
        builder: (BuildContext context) {
          return SavedSuggestions();
        }));
  }

  void _presslog() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return LoginPage();
    }));
  }

  void _pressexit() {
    Provider.of<AuthRepository>(context, listen: false).signOut();
    SnackBar snackmess = SnackBar(content: Text(
        "                      “logged out"));
    ScaffoldMessenger.of(context).showSnackBar(snackmess);
    // Navigator.pop(context);
  }

  Widget _buildRow(WordPair pair) {
    final Manager = Provider.of<SuggestionManager>(context, listen: false);
    final auth = Provider.of<AuthRepository>(context,);
    final alreadySaved = Manager.saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: TextStyle(fontSize: 18.0),
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        // NEW lines from here...
        setState(() {
          if (alreadySaved) {
            Manager.DeleteSuggestionOntap(auth, pair);
          } else {
            Manager.AddSuggOntap(auth, pair);
          }
        });
      }, // ... to here.
    );
  }

  Widget _buildSuggestions() {

    return ListView.builder(

        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          final Manager = Provider.of<SuggestionManager>(context);
          // Add a one-pixel-high divider widget before each row
          // in the ListView.
          if (i.isOdd) {
            return Divider();
          }
          final int index = i ~/ 2;
          if (index >= Manager.suggestions.length) {

            Manager.suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(Manager.suggestions[index]);
        });
  }
}

// #enddocregion _RandomWordsState, RWS-class-only

// #docregion RandomWords
class RandomWords extends StatefulWidget {
  @override
  State<RandomWords> createState() => _RandomWordsState();
}
