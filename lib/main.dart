import 'package:flutter/material.dart';
import 'package:mundo/pages/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:mundo/theme/theme_provider.dart';

/// function that initializes the app with Firebase services and sets the theme
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MiMundo(),
  ));
}

/// main app widget including theme provider and widget tree (decides at which page the app starts)
class MiMundo extends StatelessWidget {
  const MiMundo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData, // TODO: Collision of Theme with general smartphone theme
      home: const WidgetTree(),
    );
  }
}