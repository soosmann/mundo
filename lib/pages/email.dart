import 'package:flutter/material.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';

class InsertEmailView extends StatefulWidget {
  final Function(String) onEmailSubmitted;

  const InsertEmailView({super.key, required this.onEmailSubmitted});

  @override
  State<InsertEmailView> createState() => _InsertEmailViewState();
}

class _InsertEmailViewState extends State<InsertEmailView> {
  final TextEditingController _emailController = TextEditingController();

  // triggers redirection to sign in or register
  void checkRegisterOrSignIn(String email){
    widget.onEmailSubmitted(email);
  }

  // title text
  Widget _title(){
    return const Padding(
      padding: EdgeInsets.all(60.0),
      child: Text(
        "Willkommen bei MiMundo",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ) 
    );
  } 

  /// continue button
  Widget _submitButton(){
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).buttonTheme.colorScheme!.primary),
      ),
      onPressed: () => checkRegisterOrSignIn(_emailController.text),
      child: Text(
        "Weiter",
        style: TextStyle(
          color: Theme.of(context).textTheme.labelLarge!.color,
        ),
      )
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
              MediaQuery.of(context).size.width-60,
              MediaQuery.of(context).size.height*0.06, 
              const EdgeInsets.all(0), 
              "E-Mail", 
              _emailController, 
              1,
              innerPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5)
            ),
            const SizedBox(height: 50),
            _submitButton(),
          ],
        ),
      ),
    );
  }
}
