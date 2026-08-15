import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';
import '../core/constants/api_constants.dart';

class RiceStockEntry {
  final String id;
  final String customerName;
  final double riceKg;
  final double pricePerKg;
  final double totalAmount;
  final DateTime date;

  RiceStockEntry({
    required this.id,
    required this.customerName,
    required this.riceKg,
    required this.pricePerKg,
    required this.totalAmount,
    required this.date,
  });

  factory RiceStockEntry.fromJson(Map<String, dynamic> json) {
    return RiceStockEntry(
      id: json['_id'] ?? '',
      customerName: json['customerName'] ?? '',
      riceKg: (json['riceKg'] ?? 0).toDouble(),
      pricePerKg: (json['pricePerKg'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date']).toLocal() : DateTime.now(),
    );
  }
}

class RiceStockScreen extends StatefulWidget {
  const RiceStockScreen({super.key});

  @override
  State<RiceStockScreen> createState() => _RiceStockScreenState();
}

class _RiceStockScreenState extends State<RiceStockScreen> {
  final List<RiceStockEntry> _entries = [];
  bool _isLoading = true;
  final Dio _dio = Dio();

  double _trueTotalRiceKg = 0.0;

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
          '${ApiConstants.baseUrl}${ApiConstants.riceStock}',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
        _dio.get(
          '${ApiConstants.baseUrl}${ApiConstants.revenue}',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
      ]);

      final riceResponse = responses[0];
      final revenueResponse = responses[1];

      if (riceResponse.statusCode == 200) {
        final List<dynamic> data = riceResponse.data;
        setState(() {
          _entries.clear();
          _entries.addAll(data.map((e) => RiceStockEntry.fromJson(e)).toList());
        });
      }
      
      if (revenueResponse.statusCode == 200) {
        setState(() {
          _trueTotalRiceKg = (revenueResponse.data['stock']['totalRiceKg'] ?? 0).toDouble();
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

  Future<void> _saveEntry(String name, double kg, double price, double total) async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.riceStock}',
        data: {
          'customerName': name,
          'riceKg': kg,
          'pricePerKg': price,
          'totalAmount': total,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        final newEntry = RiceStockEntry.fromJson(response.data);
        setState(() {
          _entries.insert(0, newEntry);
          _trueTotalRiceKg += kg; // Optimistic update
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock added successfully', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
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
    final nameController = TextEditingController();
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
                    const Text('Add Rice Stock', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Customer/Donor Name',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade700),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: kgController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Rice (Kg)',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.scale, color: Colors.grey.shade700),
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
                      final name = nameController.text.trim();
                      final kg = double.tryParse(kgController.text) ?? 0.0;
                      final price = double.tryParse(priceController.text) ?? 0.0;
                      final total = double.tryParse(totalController.text) ?? 0.0;

                      if (name.isNotEmpty && kg > 0) {
                        Navigator.pop(context);
                        _saveEntry(name, kg, price, total);
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
                        'Recent Donors / Additions',
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
        label: const Text('Add Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            title: 'Available Rice Stock',
            value: '${_trueTotalRiceKg.toStringAsFixed(1)} Kg',
            icon: Icons.inventory_2,
            color: Colors.blue.shade700,
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
              Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No Rice Stock entries found.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
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
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.customerName, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
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
                    '${entry.riceKg} Kg @ ₹${entry.pricePerKg}/kg',
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
