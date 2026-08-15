import 'package:flutter/material.dart';

class ProductionScreen extends StatelessWidget {
  const ProductionScreen({super.key});

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Production'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(decoration: const InputDecoration(labelText: 'Rice Used (Kg)'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(decoration: const InputDecoration(labelText: 'Plant Used (Kg)'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(decoration: const InputDecoration(labelText: 'Flour Produced (Kg)'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(decoration: const InputDecoration(labelText: 'Remarks')),
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
          Center(child: Text('No Production entries found.')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
