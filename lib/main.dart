import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ExpenseHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  File? _image;
  String _displayedText = '';
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90, // High quality improves OCR accuracy
      );

      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
        await _extractTextFromImage(File(pickedFile.path));
      } else {
        setState(() => _displayedText = '❌ No image selected.');
      }
    } catch (e) {
      setState(() => _displayedText = '❌ Error picking image: $e');
    }
  }

  Map<String, dynamic> parseReceiptText(String text) {
    final lines = text.split('\n');
    final Map<String, String> items = {};
    String? total;

    final itemRegex = RegExp(r'^(.*?)\s+(?:£|GBP)?\s*(\d+\.\d{2})\$');
    final totalRegex = RegExp(
      r'(TOTAL|AMOUNT DUE|GRAND TOTAL|BALANCE DUE)[^\d]*(\d+\.\d{2})',
      caseSensitive: false,
    );

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Extract total amount
      if (total == null) {
        final totalMatch = totalRegex.firstMatch(line);
        if (totalMatch != null) {
          total = totalMatch.group(2)?.trim();
        } else if ((line.toLowerCase().contains('total') ||
                line.toLowerCase().contains('amount due')) &&
            i + 1 < lines.length) {
          final nextLine = lines[i + 1].trim();
          final nextLineMatch =
              RegExp(r'(?:£|GBP)?\s*(\d+\.\d{2})').firstMatch(nextLine);
          if (nextLineMatch != null) total = nextLineMatch.group(1)?.trim();
        }
      }

      // Extract item and price pairs
      final itemMatch = itemRegex.firstMatch(line);
      if (itemMatch != null) {
        final item =
            itemMatch.group(1)?.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim();
        final price = itemMatch.group(2);

        if (item != null && price != null && item.isNotEmpty) {
          items[item] = '£$price';
        }
      }
    }

    return {
      'items': items,
      'total': total ?? 'Not found',
    };
  }

  Future<void> _extractTextFromImage(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      if (recognizedText.text.trim().isEmpty) {
        setState(() => _displayedText = '❌ No text recognized.');
        return;
      }

      // Debug: Print raw OCR output to console for verification
      print('🔍 OCR Extracted Text:\n${recognizedText.text}');

      final parsedData = parseReceiptText(recognizedText.text);
      final items = parsedData['items'] as Map<String, String>;
      final itemList = items.isNotEmpty
          ? items.entries.map((e) => "• ${e.key}: ${e.value}").join("\n")
          : 'No items found.';

      setState(() {
        _displayedText =
            "Identified Items and Prices:\n$itemList\n\nTotal: £${parsedData['total']}";
      });

      await textRecognizer.close();
    } catch (e) {
      setState(() => _displayedText = '❌ Error during text recognition: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Capture from Camera',
            onPressed: () => _pickImage(ImageSource.camera),
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: 'Select from Gallery',
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(child: Text('No Image Selected')),
                  ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _displayedText.isEmpty
                      ? 'No text recognized yet.'
                      : _displayedText,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
