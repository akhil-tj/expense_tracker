import 'package:flutter/material.dart';

class EditReceiptScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const EditReceiptScreen({super.key, required this.items});

  @override
  _EditReceiptScreenState createState() => _EditReceiptScreenState();
}

class _EditReceiptScreenState extends State<EditReceiptScreen> {
  late List<Map<String, dynamic>> editableItems;
  double discount = 10.0;

  @override
  void initState() {
    super.initState();
    editableItems = List.from(widget.items);
  }

  void updateTotal() {
    setState(() {});
  }

  void addItem() {
    setState(() {
      editableItems.add({"name": "", "quantity": 1, "price": 0.0});
    });
  }

  void removeItem(int index) {
    setState(() {
      editableItems.removeAt(index);
    });
  }

  double calculateTotal() {
    double total = editableItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
    return total - (total * (discount / 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Receipt")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: editableItems.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: editableItems[index]['name'],
                          decoration:
                              const InputDecoration(labelText: "Item Name"),
                          onChanged: (value) {
                            editableItems[index]['name'] = value;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          initialValue:
                              editableItems[index]['quantity'].toString(),
                          decoration:
                              const InputDecoration(labelText: "Quantity"),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            editableItems[index]['quantity'] =
                                int.tryParse(value) ?? 1;
                            updateTotal();
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          initialValue:
                              editableItems[index]['price'].toString(),
                          decoration: const InputDecoration(labelText: "Price"),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            editableItems[index]['price'] =
                                double.tryParse(value) ?? 0.0;
                            updateTotal();
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
            Text("Total: £${calculateTotal().toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: addItem,
              child: const Text("Add an Item"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, editableItems);
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
