import 'package:flutter/material.dart';
import 'package:sai_sangha_app/screens/login_screen.dart';
import 'package:sai_sangha_app/services/auth_service.dart';
import 'package:sai_sangha_app/screens/dashboard_screen.dart';

void main() {
  runApp(const SaiSanghaApp());
}

class SaiSanghaApp extends StatelessWidget {
  const SaiSanghaApp({super.key});

 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaiSangha App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data == true) {
            return DashboardScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
