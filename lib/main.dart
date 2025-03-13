import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/budget_options_screen.dart';
import 'screens/upload_bill_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/budget': (context) => const BudgetScreen(),
        '/budget-options': (context) => const BudgetOptionsScreen(),
        '/upload-receipt': (context) => const UploadReceiptScreen(),
        // '/manual-payment': (context) => const ManualPaymentScreen(),
      },
    );
  }
}
