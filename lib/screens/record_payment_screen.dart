import 'package:flutter/material.dart';

class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  _RecordPaymentScreenState createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  List<Map<String, dynamic>> items = [];
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
      appBar: AppBar(title: const Text("Record a Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Item Name"),
                          onChanged: (value) {
                            items[index]['name'] = value;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Quantity"),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            items[index]['quantity'] = int.tryParse(value) ?? 1;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: "Price"),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            items[index]['price'] =
                                double.tryParse(value) ?? 0.0;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeItem(index),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: addItem,
              child: const Text("Add Another Item"),
            ),
            const SizedBox(height: 10),
            Text("Grand Total: £${calculateTotal().toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Done"),
            ),
          ],
        ),
      ),
    );
  }
}
