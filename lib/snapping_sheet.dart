import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/AuthRepository.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'SnapContent.dart';
import 'SuggestionManager.dart';

class Snapp extends StatefulWidget {
  @override
  _SnappState createState() => _SnappState();
}

class _SnappState extends State<Snapp> {
  final SnappingSheetController _scrollController = SnappingSheetController();

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final auth = Provider.of<AuthRepository>(context);
    var pos1 = SnappingPosition.factor(
      positionFactor: 0.0,
      grabbingContentOffset: GrabbingContentOffset.top,
    );

    var pos2 = SnappingPosition.factor(
      snappingCurve: Curves.elasticOut,
      snappingDuration: Duration(milliseconds: 800),
      positionFactor: 0.6,
      grabbingContentOffset: GrabbingContentOffset.top,
    );

    return SnappingSheet(
      lockOverflowDrag: true,
      controller: _scrollController,
      snappingPositions: [pos1, pos2],
      initialSnappingPosition: pos1,
      grabbingHeight: auth.isAuthenticated
          ? (MediaQuery.of(context).size.height * 0.08)
          : 0,
      grabbing: InkWell(
        child: ListTile(
          tileColor: Colors.grey,
          trailing: Icon(
            Icons.arrow_upward,
            color: Colors.black,
          ),
          title: Text(
            "Welcome back,${auth.user!.email}",
            style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
          ),
        ),
        onTap: () => setState(() {
          {
            SnappingPosition next =
                _scrollController.currentSnappingPosition == pos1 ? pos2 : pos1;
            _scrollController.snapToPosition(next);
          }
        }),
      ),
      child: _buildSuggestions(),
      sheetBelow: SnappingSheetContent(child: SnapContent(), draggable: true),
    );
  }

  // need to add image instead here

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

  Widget _buildRow(WordPair pair) {
    final Manager = Provider.of<SuggestionManager>(context, listen: false);
    final auth = Provider.of<AuthRepository>(
      context,
    );
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
}
