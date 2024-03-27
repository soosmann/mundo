import 'package:flutter/material.dart';
import 'package:mundo/pages/home.dart';
import 'package:mundo/pages/email.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/pages/login.dart';
import 'package:mundo/pages/register.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WidgetTree extends StatefulWidget{
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree>{
  AuthService authservice = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authservice.authStateChanges, 
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting){
          return const CircularProgressIndicator();
        } else if (snapshot.hasData){
          return const HomeView();
        } else {
          return InsertEmailView(onEmailSubmitted: (email) {
            authservice.isEmailInUse(email).then((isEmailInUse) {
              if (isEmailInUse){
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => LoginView(email: email)
                  )
                );
              } else {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => RegisterView(email: email)
                  )
                );
              }
            },);
          });
        }
      }
    );
  }
}