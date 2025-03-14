import 'package:flutter/material.dart';

class BillReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> structuredData;

  const BillReceiptScreen({super.key, required this.structuredData});

  @override
  Widget build(BuildContext context) {
    // Extract items and total amount from structuredData
    List<dynamic> items = structuredData['items'] ?? [];
    double totalAmount = (structuredData['totalAmount'] is num)
        ? structuredData['totalAmount'].toDouble()
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Bill Processed Successfully",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Header row for the receipt
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: const Row(
                children: [
                  Expanded(
                      child: Text("Item",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text("Quantity",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text("Price",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text("Category",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300))),
                    child: Row(
                      children: [
                        Expanded(child: Text(item['name'] ?? '')),
                        Expanded(child: Text(item['quantity'].toString())),
                        Expanded(child: Text("\$${item['price']}")),
                        Expanded(child: Text(item['category'] ?? '')),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text("Total: \$${totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
