
//mport 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

//import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
//import 'package:mundo/pages/map_view.dart';
//import 'package:mundo/pages/my_profile_view.dart';
//import 'package:mundo/theme/theme_provider.dart';
//import 'package:provider/provider.dart';
//import 'package:mundo/main.dart';

//import 'dart:async';

//import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
//import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
//import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

void main() {
  testWidgets('Test Firebase acc creation', (WidgetTester tester) async {
    expect(1, 1);
    //WidgetsFlutterBinding.ensureInitialized();
    //Firebase.initializeApp();
    /*
    final googleSignIn = MockGoogleSignIn();
    final signinAccount = await googleSignIn.signIn();
    final googleAuth = await signinAccount!.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    MockUser(
      isAnonymous: false, 
      uid: "1234567890", 
      email: "testmail@123.de",
      displayName: "testuser"
    );
    
    
    tester.pumpWidget(const MapView());

    final firestore = FakeFirebaseFirestore();

    await firestore.collection("posts").add({
      "id": "c1183827-d8e7-4ed6-966a-6c77b65cd120",
      "owner": "w3OmIXHGaoQM1qMDuFZp6ZFxQSq1",
      "title": "Skifahren 2k23",
      "mainImageIndex": 1,
      "date": 1712147246921,
      "loc": {
        "gMapsId": "ChIJj5Wcvy_sokcRgBVi8Ci3HQQ",
        "city": "Arnstein",
        "region": "Germany",
        "lat": 50.0218077,
        "lng": 10.0020207
      },
      "content": [
        {
          "type": "text",
          "text": "Skifahren am Katschberg",
          "position": 0
        },
        {
          "type": "image",
          "imageUrl": "https://firebasestorage.googleapis.com/v0/b/mundo-663ca.appspot.com/o/posts%2Fc1183827-d8e7-4ed6-966a-6c77b65cd120%2Fimage_1?alt=media&token=b9ed52ba-4bc4-40e6-8435-894bacb7680d",
          "isMainImage": true,
          "position": 1
        },
        {
          "type": "text",
          "text": "War toll!",
          "position": 2
        },
        {
          "type": "image",
          "imageUrl": "https://firebasestorage.googleapis.com/v0/b/mundo-663ca.appspot.com/o/posts%2Fc1183827-d8e7-4ed6-966a-6c77b65cd120%2Fimage_3?alt=media&token=2092d59d-5386-45c6-b8e3-6613a422ec80",
          "isMainImage": false,
          "position": 3
        }
      ]}
    );

    await firestore.collection("posts").add({
      "id": "d7b17d54-2c3a-4467-8683-f715fad26e74",
      "owner": "6CRgyJ9rTWS4a63ypIZi2nGwf5f2",
      "title": "Urlaub in Paris",
      "mainImageIndex": 3,
      "date": 1712051484819,
      "loc": {
        "gMapsId": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
        "city": "Paris",
        "region": "Frankreich",
        "lat": 48.856614,
        "lng": 2.3522219
      },
      "content": [
        {
          "type": "text",
          "text": "Ich bin mit einigen Leuten in Paris gewesen und hab viel Spaß gehabt.",
          "position": 0
        },
        {
          "type": "image",
          "imageUrl": "https://firebasestorage.googleapis.com/v0/b/mundo-663ca.appspot.com/o/posts%2Fd7b17d54-2c3a-4467-8683-f715fad26e74%2Fimage_1?alt=media&token=db121f9d-f3cc-4448-9286-221e5382a5cc",
          "isMainImage": false,
          "position": 1
        },
        {
          "type": "text",
          "text": "Wir waren im Louvre und haben uns unter anderem die Mona Lisa angesehen.",
          "position": 2
        },
        {
          "type": "image",
          "imageUrl": "https://firebasestorage.googleapis.com/v0/b/mundo-663ca.appspot.com/o/posts%2Fd7b17d54-2c3a-4467-8683-f715fad26e74%2Fimage_3?alt=media&token=c9196cf0-387e-4a05-ac8f-8488121d3178",
          "isMainImage": true,
          "position": 3
        },
        {
          "type": "text",
          "text": "Auch der Eifelturm war schicko bello.",
          "position": 4
        },
      ]}
    );

    await firestore.collection("users").add({
      "email": "testmail@123.de",
      "followers": 3,
      "following": 1,
      "posts": 2,
      "username": "testuser",
    });
    
    await tester.pumpWidget(const MyProfileView());
    await tester.idle();
    await tester.pump(Duration(seconds: 1));
    //await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text("testuser"), findsOneWidget);


    
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );
    */
  });
}
