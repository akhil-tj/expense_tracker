import 'package:expense_tracker/screens/budget_options_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  _RecordPaymentScreenState createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  List<Map<String, dynamic>> items = [
    {"name": "", "quantity": 1, "price": 0.0}
  ];
  double discount = 0.0;

  void addItem() {
    setState(() {
      items.add({"name": "", "quantity": 1, "price": 0.0});
    });
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  double calculateTotal() {
    double total =
        items.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
    return total - (total * (discount / 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 64),
            Text(
              "Record a Payment",
              style: GoogleFonts.poppins(
                  fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child:
                        Text("Items", style: GoogleFonts.poppins(fontSize: 16)),
                  ),
                  Expanded(
                    child: Text(
                      "  Price",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Column(
              children: items.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          style: GoogleFonts.poppins(fontSize: 16),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            hintText: "Item Name",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          initialValue: item['name'],
                          onChanged: (value) {
                            setState(() {
                              items[index]['name'] = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(fontSize: 16),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            hintText: "Price",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          initialValue: item['price'].toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              items[index]['price'] =
                                  double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: TextButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: addItem,
                child: Text(
                  "Add Another Item",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8E5AF7),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Grand Total",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "£${calculateTotal().toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF8E5AF7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, BudgetOptionsScreen());
                },
                child: Text(
                  "Done",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
