import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';
import '../core/constants/api_constants.dart';

class ProductionEntry {
  final String id;
  final double riceUsedKg;
  final double plantUsedKg;
  final double flourProducedKg;
  final String? remarks;
  final DateTime date;

  ProductionEntry({
    required this.id,
    required this.riceUsedKg,
    required this.plantUsedKg,
    required this.flourProducedKg,
    this.remarks,
    required this.date,
  });

  factory ProductionEntry.fromJson(Map<String, dynamic> json) {
    return ProductionEntry(
      id: json['_id'] ?? '',
      riceUsedKg: (json['riceUsedKg'] ?? 0).toDouble(),
      plantUsedKg: (json['plantUsedKg'] ?? 0).toDouble(),
      flourProducedKg: (json['flourProducedKg'] ?? 0).toDouble(),
      remarks: json['remarks'],
      date: json['productionDate'] != null ? DateTime.parse(json['productionDate']).toLocal() : DateTime.now(),
    );
  }
}

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  final List<ProductionEntry> _entries = [];
  bool _isLoading = true;
  final Dio _dio = Dio();

  double _trueTotalFlourKg = 0.0;

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
          '${ApiConstants.baseUrl}${ApiConstants.production}',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
        _dio.get(
          '${ApiConstants.baseUrl}${ApiConstants.revenue}',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
      ]);

      final productionResponse = responses[0];
      final revenueResponse = responses[1];

      if (productionResponse.statusCode == 200) {
        final List<dynamic> data = productionResponse.data;
        setState(() {
          _entries.clear();
          _entries.addAll(data.map((e) => ProductionEntry.fromJson(e)).toList());
        });
      }
      
      if (revenueResponse.statusCode == 200) {
        setState(() {
          _trueTotalFlourKg = (revenueResponse.data['stock']['totalFlourKg'] ?? 0).toDouble();
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

  Future<void> _saveEntry(double rice, double plant, double flour, String remarks) async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.production}',
        data: {
          'riceUsedKg': rice,
          'plantUsedKg': plant,
          'flourProducedKg': flour,
          'remarks': remarks,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        final newEntry = ProductionEntry.fromJson(response.data);
        setState(() {
          _entries.insert(0, newEntry);
          _trueTotalFlourKg += flour;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Production logged successfully', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save data: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _showAddDialog() {
    final riceController = TextEditingController();
    final plantController = TextEditingController();
    final flourController = TextEditingController();
    final remarksController = TextEditingController();

    void updateCalculate() {
      final rice = double.tryParse(riceController.text) ?? 0.0;
      final plant = double.tryParse(plantController.text) ?? 0.0;
      final total = rice + plant;
      flourController.text = total > 0 ? total.toStringAsFixed(1) : '';
    }

    riceController.addListener(updateCalculate);
    plantController.addListener(updateCalculate);

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
                    const Text('Log Production', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
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
                        controller: riceController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Rice Used (Kg)',
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
                        controller: plantController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Plant Used (Kg)',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.grass, color: Colors.grey.shade700),
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
                  controller: flourController,
                  readOnly: true,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Calculated Flour (Kg)',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.inventory_2, color: Color(0xFF1E3A8A)),
                    fillColor: Colors.blue.shade50,
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: remarksController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Remarks (Optional)',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.note, color: Colors.grey.shade700),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
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
                      final rice = double.tryParse(riceController.text) ?? 0.0;
                      final plant = double.tryParse(plantController.text) ?? 0.0;
                      final flour = double.tryParse(flourController.text) ?? 0.0;
                      final remarks = remarksController.text.trim();

                      if (flour > 0) {
                        Navigator.pop(context);
                        _saveEntry(rice, plant, flour, remarks);
                      }
                    }, 
                    child: const Text('Save Production', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                        'Production History',
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
        label: const Text('Log Production', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            title: 'Available Flour Stock',
            value: '${_trueTotalFlourKg.toStringAsFixed(1)} Kg',
            icon: Icons.inventory_2,
            color: Colors.deepPurple.shade700,
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
              Icon(Icons.factory, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No Production entries found.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
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
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.factory, color: Colors.deepPurple.shade700),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Production Log', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr, 
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                    if (entry.remarks != null && entry.remarks!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.remarks!,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${entry.flourProducedKg.toStringAsFixed(1)} Kg',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.riceUsedKg} Rice + ${entry.plantUsedKg} Plant',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
