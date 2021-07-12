import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'AuthRepository.dart';
import 'SuggestionManager.dart';
import 'package:provider/provider.dart';


class SavedSuggestions extends StatefulWidget {
  @override
  _SavedSuggestionsState createState() => _SavedSuggestionsState();
}

class _SavedSuggestionsState extends State<SavedSuggestions> {

  final TextStyle _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    var  s =77;
    final provmanager = Provider.of<SuggestionManager>(context);
    final auth = Provider.of<AuthRepository>(context,);

    if(provmanager.saved.isEmpty)
      {
        return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),));
      }

    final tiles = provmanager.saved.map(

          (WordPair pair) {
        return ListTile(
          title: Text(
            pair.asPascalCase,
            style: _biggerFont,
          ),
          trailing: Builder(
            builder: (BuildContext context) {
              return IconButton(
                  icon: const Icon (
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {


                    provmanager.DeleteSuggestionOntap( auth,pair);

                   // provmanager.DeleteSuggestionOntap(pair);
                  }
              );
            },
          ),
        );
      },
    );
    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
      return Scaffold(
        appBar: AppBar(
          title: Text('Saved Suggestions'),
        ),
        body:
        ListView(children: divided),
      );
    }
  }
