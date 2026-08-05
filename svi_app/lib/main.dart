import 'package:flutter/material.dart';

import 'features/auth/presentation/screens/register_screen.dart';

void main() {
  runApp(const SviApp());
}

class SviApp extends StatelessWidget {
  const SviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SVI Recruitment',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const RegisterScreen(),
    );
  }
}