import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';
import '../core/constants/api_constants.dart';

class PlantStockEntry {
  final String id;
  final double plantKg;
  final double pricePerKg;
  final double totalAmount;
  final DateTime date;

  PlantStockEntry({
    required this.id,
    required this.plantKg,
    required this.pricePerKg,
    required this.totalAmount,
    required this.date,
  });

  factory PlantStockEntry.fromJson(Map<String, dynamic> json) {
    return PlantStockEntry(
      id: json['_id'] ?? '',
      plantKg: (json['plantKg'] ?? 0).toDouble(),
      pricePerKg: (json['pricePerKg'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date']).toLocal() : DateTime.now(),
    );
  }
}

class PlantStockScreen extends StatefulWidget {
  const PlantStockScreen({super.key});

  @override
  State<PlantStockScreen> createState() => _PlantStockScreenState();
}

class _PlantStockScreenState extends State<PlantStockScreen> {
  final List<PlantStockEntry> _entries = [];
  bool _isLoading = true;
  final Dio _dio = Dio();

  double _trueTotalPlantKg = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      
      final responses = await Future.wait([
        _dio.get(
          '${ApiConstants.baseUrl}${ApiConstants.plantStock}',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
        _dio.get(
          '${ApiConstants.baseUrl}${ApiConstants.revenue}',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
      ]);

      final plantResponse = responses[0];
      final revenueResponse = responses[1];

      if (plantResponse.statusCode == 200) {
        final List<dynamic> data = plantResponse.data;
        setState(() {
          _entries.clear();
          _entries.addAll(data.map((e) => PlantStockEntry.fromJson(e)).toList());
        });
      }
      
      if (revenueResponse.statusCode == 200) {
        setState(() {
          _trueTotalPlantKg = (revenueResponse.data['stock']['totalPlantKg'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveEntry(double kg, double price, double total) async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.plantStock}',
        data: {
          'plantKg': kg,
          'pricePerKg': price,
          'totalAmount': total,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        final newEntry = PlantStockEntry.fromJson(response.data);
        setState(() {
          _entries.insert(0, newEntry);
          _trueTotalPlantKg += kg;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plant Stock added successfully', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save data: $e'), backgroundColor: Colors.red));
      }
    }
  }

  double get _totalValue => _entries.fold(0, (sum, item) => sum + item.totalAmount);

  void _showAddDialog() {
    final kgController = TextEditingController();
    final priceController = TextEditingController();
    final totalController = TextEditingController();

    void updateCalculate() {
      final kg = double.tryParse(kgController.text) ?? 0.0;
      final price = double.tryParse(priceController.text) ?? 0.0;
      final total = kg * price;
      totalController.text = total > 0 ? total.toStringAsFixed(2) : '';
    }

    kgController.addListener(updateCalculate);
    priceController.addListener(updateCalculate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add Plant Stock', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: kgController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Plant (Kg)',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.grass, color: Colors.grey.shade700),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Price/Kg (₹)',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.currency_rupee, color: Colors.grey.shade700),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: totalController,
                  readOnly: true,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Total Amount (₹)',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.functions, color: Color(0xFF1E3A8A)),
                    fillColor: Colors.blue.shade50,
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      final kg = double.tryParse(kgController.text) ?? 0.0;
                      final price = double.tryParse(priceController.text) ?? 0.0;
                      final total = double.tryParse(totalController.text) ?? 0.0;

                      if (kg > 0) {
                        Navigator.pop(context);
                        _saveEntry(kg, price, total);
                      }
                    }, 
                    child: const Text('Save Entry', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
        : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(),
                      const SizedBox(height: 24),
                      const Text(
                        'Recent Plant Stock Entries',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                      ),
                      const SizedBox(height: 16),
                      _buildDataTable(),
                    ],
                  ),
                ),
              ),
            ],
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF1E3A8A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Plant Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            title: 'Available Plant Stock',
            value: '${_trueTotalPlantKg.toStringAsFixed(1)} Kg',
            icon: Icons.grass,
            color: Colors.teal.shade700,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(
            title: 'Total Additions Value',
            value: '₹${_totalValue.toStringAsFixed(2)}',
            icon: Icons.account_balance_wallet,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    if (_entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.grass, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No Plant Stock entries found.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final dateStr = '${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}/${entry.date.year}';
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.grass, color: Colors.teal),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plant Stock Added', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr, 
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${entry.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.plantKg} Kg @ ₹${entry.pricePerKg}/kg',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
