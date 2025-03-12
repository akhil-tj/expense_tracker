import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart'; // Ensure this file defines your backendBaseUrl

class BudgetOptionsScreen extends StatefulWidget {
  const BudgetOptionsScreen({Key? key}) : super(key: key);

  @override
  _BudgetOptionsScreenState createState() => _BudgetOptionsScreenState();
}

class _BudgetOptionsScreenState extends State<BudgetOptionsScreen> {
  bool _isLoading = false;
  double? _budget;
  String? _currency;
  int? _month;
  int? _year;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBudget();
  }

  Future<void> _fetchBudget() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _errorMessage = 'User is not authenticated';
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('$backendBaseUrl/budget');
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _budget = (responseData['budget'] as num?)?.toDouble();
          _currency = responseData['currency'] as String?;
          _month = responseData['month'] as int?;
          _year = responseData['year'] as int?;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch budget details';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching budget details';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Options"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_budget != null && _currency != null)
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Your budget for $_month/$_year is $_budget $_currency",
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the Upload Receipt screen (to be implemented)
                          Navigator.pushNamed(context, '/upload-receipt');
                        },
                        child: const Text("Upload Receipt"),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the Manual Payment screen (to be implemented)
                          Navigator.pushNamed(context, '/manual-payment');
                        },
                        child: const Text("Manually Record a Payment"),
                      ),
                    ],
                  ),
      ),
    );
  }
}
