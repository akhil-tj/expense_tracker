import 'dart:convert';
import 'dart:io';
import 'package:expense_tracker/screens/bill_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _image;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // Opens the camera to take a picture
  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadReceipt(); // Call separately after UI update
    }
  }

  // Uploads the captured image as a bill to the backend
  Future<void> _uploadReceipt() async {
    print("Checking if uploading the captured image is working"); // Debugging
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image selected.")),
      );
      return;
    }
    setState(() {
      _isUploading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated.")),
      );
      setState(() {
        _isUploading = false;
      });
      return;
    }

    final url = Uri.parse('$backendBaseUrl/process-bill');
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token';

    // Attach the image file with key 'bill'
    request.files.add(await http.MultipartFile.fromPath('bill', _image!.path));

    try {
      print("Checking if responseData is triggered"); // Debugging
      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final responseData = jsonDecode(responseString);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Receipt uploaded successfully.")),
        );

        // If structuredData exists, navigate to BillReceiptScreen
        if (responseData['structuredData'] != null) {
          print("Naviation to BillReceiptScreen"); // Debugging
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BillReceiptScreen(
                structuredData: responseData['structuredData'],
              ),
            ),
          );
          print("Success"); // Debugging
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseData['message'] ?? "Failed to upload receipt.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading receipt: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

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
        _isLoading = false; // Ensure this is set
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
          _errorMessage = null; // Reset error if successful
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch budget details';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching budget details: $error';
      });
    } finally {
      setState(() {
        _isLoading = false; // Ensure loading state is reset in all cases
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
              onPressed: _takePicture,
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
                // Navigator.pushNamed(context, '/manual-payment');
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
