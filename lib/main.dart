import 'package:camera/camera.dart';
import 'package:chat_bot_gemini/screens/camera_screen.dart';
import 'package:chat_bot_gemini/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:io';
import 'constants/static_values.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
    print("Cameras available: $cameras");
  } catch (e) {
    print("Error getting cameras: $e");
  }

  try {
    await Gemini.init(apiKey: StaticValues.geminiApiKey);
    print("Gemini SDK initialized");
  } catch (e) {
    print("Error initializing Gemini SDK: $e");
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "OpenSans",
        primaryColor: const Color(0xFF0474ea),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFec8630),
        ),
      ),
      home: const IndividualPage(),
    );
  }
}