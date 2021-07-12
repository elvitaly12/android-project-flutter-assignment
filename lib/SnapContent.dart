
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'AuthRepository.dart';

class SnapContent extends StatefulWidget {
  @override
  _SnapContentState createState() => _SnapContentState();
}

class _SnapContentState extends State<SnapContent>
{

  @override
  Widget build(BuildContext context)
  {
    final auth = Provider.of<AuthRepository>(context);

     return
       Container(
       color: Colors.white,
       child:
       SingleChildScrollView(child:
       Column(
           children: [
       Row(
       children: [


       CircleAvatar(
            radius: MediaQuery.of(context).size.height*0.07,
           backgroundImage:auth.image_url!=""? NetworkImage(auth.image_url):null,),
         Padding(padding: EdgeInsets.all(24.0)),
           Text("${auth.user!.email}", style: TextStyle(
            fontSize: 18,
             fontWeight: FontWeight.bold,
             fontStyle: FontStyle.italic,
             color: Colors.black,),),
       ],),

       Container(
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(10),
             color: Colors.teal,),
        width: 140,
         height: 50,
        child: TextButton(
        child: Text("Change Avatar", style: TextStyle(
        color: Colors.white,
        fontSize: 16,
         fontStyle: FontStyle.italic),),
         onPressed: () async
          {
            FirebaseStorage storage =  await FirebaseStorage.instance;
            PickedFile? file = await ImagePicker().getImage(source: ImageSource.gallery);

            if(file!=null)
              {
                 await storage.ref().child(auth.user!.uid).putFile(File(file.path));
                  auth.GetImageUrl();

              }
            else
              {
                SnackBar snackmess = SnackBar(content: Text(
                    "                      “No image selected"));
                ScaffoldMessenger.of(context).showSnackBar(snackmess);
              }

          }
          ,))])));

  }



}