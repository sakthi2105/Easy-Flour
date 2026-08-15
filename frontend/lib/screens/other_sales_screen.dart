import 'package:flutter/material.dart';

class OtherSalesScreen extends StatelessWidget {
  const OtherSalesScreen({super.key});

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Other Sale'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(decoration: const InputDecoration(labelText: 'Pocket Count'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(decoration: const InputDecoration(labelText: 'Pocket Price'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(decoration: const InputDecoration(labelText: 'Total Amount'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(decoration: const InputDecoration(labelText: 'Pending Amount'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Center(child: Text('No Other Sales entries found.')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
