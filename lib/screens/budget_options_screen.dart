import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart'; // Ensure this file defines your backendBaseUrl

class BudgetOptionsScreen extends StatefulWidget {
  const BudgetOptionsScreen({Key? key}) : super(key: key);

  @override
  _BudgetOptionsScreenState createState() => _BudgetOptionsScreenState();
}

class _BudgetOptionsScreenState extends State<BudgetOptionsScreen> {
  bool isExpanded = false; // Tracks whether FAB is expanded
  bool _isLoading = false;
  double? _budget;
  String? _currency;
  // int? _month;
  // int? _year;
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
          // _month = responseData['month'] as int?;
          // _year = responseData['year'] as int?;
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 48),
                      if (_budget != null && _currency != null)
                        Text(
                          "$_currency $_budget Left",
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Meter full! Awesome, you haven’t spend for anything this month.",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isExpanded) ...[
            FloatingActionButton.extended(
              elevation: 6,
              onPressed: () {
                // Navigate to the Upload Receipt screen (to be implemented)
                Navigator.pushNamed(context, '/upload-receipt');
                print("Scan a Bill");
              },
              label: Text(
                "Scan a Bill",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF8E5AF7),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 20), // Space between buttons
            FloatingActionButton.extended(
              elevation: 6,
              onPressed: () {
                // Navigate to the Manual Payment screen (to be implemented)
                Navigator.pushNamed(context, '/manual-payment');
                print("Manually Record a Payment");
              },
              label: Text(
                "Manually Record a Payment",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF8E5AF7),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 20), // Space before the main FAB
          ],
          FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200),
            ),
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded; // Toggle expansion
              });
            },
            backgroundColor: const Color(0xFF8E5AF7),
            child: Icon(
              isExpanded ? Icons.close : Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
