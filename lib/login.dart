import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/AuthRepository.dart';
import 'package:hello_me/SuggestionManager.dart';
import 'package:hello_me/login.dart';
import 'package:hello_me/savedSugg.dart';
import 'package:provider/provider.dart';



class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _biggerFont = TextStyle(fontSize: 18.0);
  final auth = AuthRepository.instance();
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();
  TextEditingController _pass_confirm = TextEditingController();
  bool _valid = true;


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthRepository>(context);
    return auth.status == Status.Authenticating ?
    Consumer<AuthRepository>(builder: (context, AuthRepository, _) {
        return Scaffold(
          body: CircularProgressIndicator
            (
            backgroundColor: Colors.blue,
            strokeWidth: 40,



          ),
          bottomSheet: Text("Signing in", style: TextStyle(fontSize:40,color: Colors.black),

        ),

        );
    },)

        : Consumer<AuthRepository>(builder: (context, AuthRepository, _) {
      return Scaffold(

          appBar: AppBar(
            title: Text('                     Login'),)
          , body: Column(
          children: [
            Text(' \n\n  Welcome to startup Names Generator,  please   ',
              style: _biggerFont,),
            Text('log in below',
              style: _biggerFont,),
            TextField(
              decoration: InputDecoration(
                  hintText: 'Email'
              ),
              controller: _email,),
            TextField(
              decoration: InputDecoration(
                  hintText: 'Passoword'),
              controller: _pass,),

            Padding(padding: EdgeInsets.all(12.0)),
            Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.red,
                child:
                MaterialButton(
                    minWidth: MediaQuery
                        .of(context)
                        .size
                        .width,
                    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    onPressed: ()  async {
                      // ignore: unrelated_type_equality_checks
                      if ( await auth.signIn(_email.text,_pass.text) == false)
                      {
                        SnackBar snackmess = SnackBar(content: Text(
                            "                      “There was an error logging into the app”"));
                        ScaffoldMessenger.of(context).showSnackBar(snackmess);
                      }
                      else
                        {
                        Navigator.pop(context);
                        }
                    },

                    child: Text("Log  in",
                      textAlign: TextAlign.center,))),
            Padding(padding: EdgeInsets.all(2.0)),
            Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.teal,
                child:
                MaterialButton(
                    minWidth: MediaQuery
                        .of(context)
                        .size
                        .width,
                    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      // ignore: unrelated_type_equality_checks
                    child: Text("New User? Click to sign up",
                      textAlign: TextAlign.center,
                    ),
                  onPressed: ()
                  {
                    showModalBottomSheet<void>(
                        isScrollControlled: true,
                        context: context,
                        builder: (context){
                          return Container(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height * 0.25,
                            child:Column(
                                children: [
                                  Text(  "Please confirm your password",
                                    style: TextStyle(fontSize: 18,fontStyle: FontStyle.normal),),

                                  Divider(),
                                  TextField(
                                    decoration: InputDecoration(
                                        labelText: 'Password',fillColor: Colors.red,
                                        errorText: _valid ? null : 'Passwords must match'),
                                    controller: _pass_confirm,),
                                  Divider(),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.teal,),

                                    child: TextButton(
                                      child: Text("Confirm",
                                          style: TextStyle(fontSize: 16.0,color: Colors.white)),
                                      onPressed: () async
                                      {
                                        if(_email.text.isNotEmpty   &&_pass_confirm.text.isNotEmpty && _pass_confirm.text.compareTo(_pass.text)==0)
                                        {
                                         var connect_res =  await auth.signUp(_email.text, _pass.text);
                                         if (connect_res!=null)  // return to the main page in case of success
                                           {
                                             Navigator.pop(context);
                                             Navigator.pop(context);
                                           }
                                        }
                                        else
                                          {
                                          setState(() => _valid = false);
                                          }
                                      },

                                    ),),]
                            ),);});


                  },
                )),
          ]));
    });
  }



















}
