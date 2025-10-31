import 'package:dummy/pages/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IITR Hospital Login',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const LoginPage(),
    );
  }
}
