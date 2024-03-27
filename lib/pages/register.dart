import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/models/user_data_manager.dart';

class RegisterView extends StatefulWidget {
  final String email;

  const RegisterView({Key? key, required this.email}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  String? usernameError;
  String? loginDataError;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try {
      await AuthService().createUserWithEmailAndPassword(
        email: email, 
        password: password
      ).then((value) {
        setState(() {
          loginDataError = null;
        });
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        loginDataError = e.message;
      });
    }
  }

  Future<bool> isUsernameInUse(String username) async {
    try{
      return await UserDataManager().getIsUsernameInUse(username).then((result) {
        if (result) {
          setState(() {
            usernameError = "Benutzername bereits vergeben";
          });
          return true;
        } else {
          setState(() {
            usernameError = null;
          });
          return false;
        }
      });
    } on FirebaseException catch (e) {
      setState(() {
        usernameError = e.message;
      });
      return true;
    }
  }

  Widget _title(){
    return const Padding(
      padding: EdgeInsets.all(30.0),
      child: Text(
        "Registration",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _description(String text){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _errorMessage(String errorMessage){
    return Text(
      errorMessage,
      style: const TextStyle(
        color: Colors.red
      ),
    );
  }

  Widget _signInButton(){
    return ElevatedButton(
      onPressed: () async {
        if (await isUsernameInUse(_usernameController.text)) {
          return;
        }else{        
          try{
            await registerWithEmailAndPassword(_emailController.text, _passwordController.text).then((value) {
              UserDataManager().saveUser(_emailController.text, _usernameController.text);
              if (loginDataError == null){
                Navigator.pop(context);
              }
            });
          } on FirebaseException catch (e) {
            setState(() {
              loginDataError = e.message;
            });
          }
        }
      },
      child: const Text("Registrieren"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _title(),
            _description("Wähle einen einzigartigen Benutzername"),
            entryField(
              context, 
              MediaQuery.of(context).size.width-80,
              MediaQuery.of(context).size.height*0.06,
              const EdgeInsets.all(8), 
              "Benutzername", 
              _usernameController,
              1
            ),
            if (usernameError != null) _errorMessage(usernameError!),
            const SizedBox(height: 40),
            _description("Gib deine E-Mail-Adresse und ein Passwort ein"),
            entryField(
              context, 
              MediaQuery.of(context).size.width-80,
              MediaQuery.of(context).size.height*0.06,
              const EdgeInsets.all(8), 
              "E-Mail", 
              _emailController,
              1
            ),
            entryField(
              context, 
              MediaQuery.of(context).size.width-80,
              MediaQuery.of(context).size.height*0.06,
              const EdgeInsets.all(8), 
              "Passwort", 
              _passwordController,
              1
            ),
            if (loginDataError != null) _errorMessage(loginDataError!),
            _signInButton()
          ],
        ),
      ),
    );
  }
}
