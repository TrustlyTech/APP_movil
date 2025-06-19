import 'package:flutter/material.dart';
import 'package:facelab/views/screens/presentation_screen.dart';
import 'package:facelab/views/screens/login_screen.dart';
import 'package:facelab/views/screens/register_screen.dart';
import 'package:facelab/views/screens/face_verification_screen.dart';
import 'package:facelab/views/screens/requisitoriados_screen.dart';


void main() {
  runApp(FaceLabApp());
}

class FaceLabApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaceLab',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => PresentationScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/face_verification': (context) => FaceVerificationScreen(),
        '/requisitoriados': (context) => RequisitoriadosScreen(), // Cambia
      
        },
    );
  }
}
