import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/pages/register.dart';

class LoginView extends StatefulWidget {
  final String email;

  const LoginView({Key? key, required this.email}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String? errorMessage = '';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      await AuthService().signInWithEmailAndPassword(
        email: _emailController.text, 
        password: _passwordController.text
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title(){
    return const Padding(
      padding: EdgeInsets.all(30.0),
      child: Text(
        "Logge dich mit\nE-Mail und Passwort ein!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  } 

  Widget _errorMessage(){
    return Text(
      errorMessage == '' ?  '' : 'Humm ? $errorMessage',
      style: const TextStyle(
        color: Colors.red
      ),
    );
  }

  Widget _signInButton(){
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).buttonTheme.colorScheme!.primary),
      ),
      onPressed: () {
        signInWithEmailAndPassword().then((value) => {
          if (AuthService().currentUser != null) {
            Navigator.pop(context) // use .pop() to go back to InsertEmailView() and be in StreamBuilder environment again
          }
        });
      },
      child: Text(
        "Weiter",
        style: TextStyle(
          color: Theme.of(context).textTheme.labelLarge!.color,
        ),
      ),
    );
  }

  Widget _switchToRegister(){
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).buttonTheme.colorScheme!.primary),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterView(email: _emailController.text),));
      },
      child: Text(
        "Doch registrieren?",
        style: TextStyle(
          color: Theme.of(context).textTheme.labelLarge!.color,
        ),
      ),
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
            entryField(
              context,
              MediaQuery.of(context).size.width-80,
              MediaQuery.of(context).size.height*0.06, 
              const EdgeInsets.all(0), 
              "E-Mail", 
              _emailController,
              1,
              innerPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5)
            ),
            const SizedBox(height: 16),
            entryField(
              context,
              MediaQuery.of(context).size.width-80,
              MediaQuery.of(context).size.height*0.06, 
              const EdgeInsets.all(0), 
              "Passwort", 
              _passwordController,
              1,
              innerPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              obscureText: true
            ),
            const SizedBox(height: 16),
            _errorMessage(),
            const SizedBox(height: 16),
            _signInButton(),
            const SizedBox(height: 16),
            _switchToRegister()
          ],
        ),
      ),
    );
  }
}
