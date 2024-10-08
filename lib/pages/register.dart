import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/pages/select_user_location.dart';
import 'package:flutter/services.dart';

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

  /// register user with email and password, set error string if necessary
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

  /// check if username is already in use, set error string if necessary
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

  // registration title
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

  /// description func to give user input advice
  Widget _description(String text){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// error message field
  Widget _errorMessage(String errorMessage){
    return Text(
      errorMessage,
      style: const TextStyle(
        color: Colors.red
      ),
    );
  }

  /// button used to sign in the user
  Widget _signInButton(){
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).buttonTheme.colorScheme!.primary),
      ),
      onPressed: () async {
        if (await isUsernameInUse(_usernameController.text)) {
          return;
        }else{        
          try{
            await registerWithEmailAndPassword(_emailController.text, _passwordController.text).then((value) {
              UserDataManager().saveUser(_emailController.text, _usernameController.text);
              if (loginDataError == null){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectUserLocationView())
                );
              }
            });
          } on FirebaseException catch (e) {
            setState(() {
              loginDataError = e.message;
            });
          }
        }
      },
      child: Text(
        "Registrieren",
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
            _description("Wähle einen einzigartigen Benutzername"),
            entryField(
              context, 
              MediaQuery.of(context).size.width-80,
              MediaQuery.of(context).size.height*0.06,
              const EdgeInsets.all(8), 
              "Benutzername", 
              _usernameController,
              1,
              innerPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp('[\\ ]')), 
                LengthLimitingTextInputFormatter(10), 
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return TextEditingValue(
                    text: newValue.text.toLowerCase(),
                    selection: newValue.selection,
                  );
                })
              ]
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
              1,
              innerPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5)
            ),
            entryField(
              context, 
              MediaQuery.of(context).size.width-80,
              MediaQuery.of(context).size.height*0.06,
              const EdgeInsets.all(8), 
              "Passwort", 
              _passwordController,
              1,
              innerPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              obscureText: true
            ),
            if (loginDataError != null) _errorMessage(loginDataError!),
            _signInButton()
          ],
        ),
      ),
    );
  }
}
