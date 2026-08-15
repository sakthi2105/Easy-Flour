import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';
import '../core/constants/api_constants.dart';

class ShopSalesEntry {
  final String id;
  final String shopName;
  final int pocketCount;
  final double pocketPrice;
  final double totalAmount;
  final double collectionReceived;
  final double pendingAmount;
  final DateTime date;

  ShopSalesEntry({
    required this.id,
    required this.shopName,
    required this.pocketCount,
    required this.pocketPrice,
    required this.totalAmount,
    required this.collectionReceived,
    required this.pendingAmount,
    required this.date,
  });

  factory ShopSalesEntry.fromJson(Map<String, dynamic> json) {
    return ShopSalesEntry(
      id: json['_id'] ?? '',
      shopName: json['shopName'] ?? '',
      pocketCount: json['pocketCount'] ?? 0,
      pocketPrice: (json['pocketPrice'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      collectionReceived: (json['collectionReceived'] ?? 0).toDouble(),
      pendingAmount: (json['pendingAmount'] ?? 0).toDouble(),
      date: json['salesDate'] != null ? DateTime.parse(json['salesDate']).toLocal() : DateTime.now(),
    );
  }
}

class ShopSalesScreen extends StatefulWidget {
  const ShopSalesScreen({super.key});

  @override
  State<ShopSalesScreen> createState() => _ShopSalesScreenState();
}

class _ShopSalesScreenState extends State<ShopSalesScreen> {
  final List<ShopSalesEntry> _entries = [];
  bool _isLoading = true;
  final Dio _dio = Dio();
  
  String? _selectedShop;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.shopSales}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _entries.clear();
          _entries.addAll(data.map((e) => ShopSalesEntry.fromJson(e)).toList());
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

  Future<void> _saveEntry(String shopName, int count, double price, double received) async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.shopSales}',
        data: {
          'shopName': shopName,
          'pocketCount': count,
          'pocketPrice': price,
          'collectionReceived': received,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        final newEntry = ShopSalesEntry.fromJson(response.data);
        setState(() {
          _entries.insert(0, newEntry);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale recorded successfully', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save data: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _updatePayment(ShopSalesEntry entry, double newCollection) async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final totalCollection = entry.collectionReceived + newCollection;
      
      final response = await _dio.put(
        '${ApiConstants.baseUrl}${ApiConstants.shopSales}/${entry.id}',
        data: {
          'shopName': entry.shopName,
          'pocketCount': entry.pocketCount,
          'pocketPrice': entry.pocketPrice,
          'collectionReceived': totalCollection,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final updatedEntry = ShopSalesEntry.fromJson(response.data);
        setState(() {
          final index = _entries.indexWhere((e) => e.id == entry.id);
          if (index != -1) {
            _entries[index] = updatedEntry;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update payment: $e'), backgroundColor: Colors.red));
      }
      rethrow;
    }
  }

  Future<void> _processBulkPayment(String shopName, double bulkAmount) async {
    setState(() => _isLoading = true);
    try {
      // Get pending sales for this shop, oldest first
      final pendingSales = _entries
          .where((e) => e.shopName == shopName && e.pendingAmount > 0)
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      double remainingPayment = bulkAmount;

      for (var sale in pendingSales) {
        if (remainingPayment <= 0) break;

        final amountToApply = remainingPayment > sale.pendingAmount 
            ? sale.pendingAmount 
            : remainingPayment;

        await _updatePayment(sale, amountToApply);
        remainingPayment -= amountToApply;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bulk payment applied successfully', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      }
    } catch (e) {
      // Errors handled in _updatePayment
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double get _totalRevenue => _entries.fold(0, (sum, item) => sum + item.totalAmount);
  double get _totalPending => _entries.fold(0, (sum, item) => sum + item.pendingAmount);

  Map<String, Map<String, dynamic>> _getGroupedShops() {
    final Map<String, Map<String, dynamic>> grouped = {};
    for (var entry in _entries) {
      if (!grouped.containsKey(entry.shopName)) {
        grouped[entry.shopName] = {
          'totalSales': 0.0,
          'totalPending': 0.0,
          'saleCount': 0,
          'lastSaleDate': entry.date,
        };
      }
      grouped[entry.shopName]!['totalSales'] += entry.totalAmount;
      grouped[entry.shopName]!['totalPending'] += entry.pendingAmount;
      grouped[entry.shopName]!['saleCount'] += 1;
      
      if (entry.date.isAfter(grouped[entry.shopName]!['lastSaleDate'])) {
        grouped[entry.shopName]!['lastSaleDate'] = entry.date;
      }
    }
    return grouped;
  }

  void _showPaymentDialog(ShopSalesEntry entry) {
    final amountController = TextEditingController();

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Collect Payment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pending Balance: ₹${entry.pendingAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: amountController,
                style: const TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Amount Received (₹)',
                  labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.normal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 24),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text) ?? 0.0;
                    if (amount > 0 && amount <= entry.pendingAmount) {
                      Navigator.pop(context);
                      setState(() => _isLoading = true);
                      try {
                        await _updatePayment(entry, amount);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded successfully', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    } else if (amount > entry.pendingAmount) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Amount cannot exceed pending balance'), backgroundColor: Colors.red));
                    }
                  }, 
                  child: const Text('Confirm Payment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBulkPaymentDialog(String shopName, double totalPending) {
    final amountController = TextEditingController();

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Overall Collection', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total Shop Pending: ₹${totalPending.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
              const SizedBox(height: 8),
              Text(
                'Payment will be applied to the oldest pending sales first.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: amountController,
                style: const TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Lump Sum Received (₹)',
                  labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.normal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 24),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0.0;
                    if (amount > 0 && amount <= totalPending) {
                      Navigator.pop(context);
                      _processBulkPayment(shopName, amount);
                    } else if (amount > totalPending) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Amount cannot exceed total pending balance'), backgroundColor: Colors.red));
                    }
                  }, 
                  child: const Text('Apply Bulk Payment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final countController = TextEditingController();
    final priceController = TextEditingController();
    final totalController = TextEditingController();
    final receivedController = TextEditingController();
    final pendingController = TextEditingController();

    void updateCalculations() {
      final count = int.tryParse(countController.text) ?? 0;
      final price = double.tryParse(priceController.text) ?? 0.0;
      final received = double.tryParse(receivedController.text) ?? 0.0;
      
      final total = count * price;
      final pending = total - received;

      totalController.text = total > 0 ? total.toStringAsFixed(2) : '';
      pendingController.text = pending != 0 ? pending.toStringAsFixed(2) : '';
    }

    countController.addListener(updateCalculations);
    priceController.addListener(updateCalculations);
    receivedController.addListener(updateCalculations);

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
                    const Text('Add Shop Sale', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
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
                    labelText: 'Shop Name',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.storefront, color: Colors.grey.shade700),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: countController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Pockets Count',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.shopping_bag, color: Colors.grey.shade700),
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
                          labelText: 'Price/Pocket (₹)',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.sell, color: Colors.grey.shade700),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: receivedController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Received (₹)',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.payments, color: Colors.green.shade700),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: pendingController,
                        readOnly: true,
                        style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Pending (₹)',
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.pending_actions, color: Colors.deepOrange),
                          filled: true,
                          fillColor: Colors.orange.shade50,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
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
                      final count = int.tryParse(countController.text) ?? 0;
                      final price = double.tryParse(priceController.text) ?? 0.0;
                      final received = double.tryParse(receivedController.text) ?? 0.0;

                      if (name.isNotEmpty && count > 0 && price > 0) {
                        Navigator.pop(context);
                        _saveEntry(name, count, price, received);
                      }
                    }, 
                    child: const Text('Record Sale', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                      if (_selectedShop == null) _buildSummaryCards(),
                      const SizedBox(height: 24),
                      if (_selectedShop == null) ...[
                        const Text(
                          'Shop Directory',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                        ),
                        const SizedBox(height: 16),
                        _buildGroupedList(),
                      ] else ...[
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A8A)),
                              onPressed: () => setState(() => _selectedShop = null),
                            ),
                            Expanded(
                              child: Text(
                                '$_selectedShop Sales',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildShopDetailsList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF1E3A8A),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('New Sale', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            title: 'Total Sales Revenue',
            value: '₹${_totalRevenue.toStringAsFixed(2)}',
            icon: Icons.store,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(
            title: 'Pending Collections',
            value: '₹${_totalPending.toStringAsFixed(2)}',
            icon: Icons.warning_amber_rounded,
            color: Colors.deepOrange.shade700,
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
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildGroupedList() {
    final grouped = _getGroupedShops();
    
    if (grouped.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.storefront, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No Shop Sales entries found.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    final shopNames = grouped.keys.toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shopNames.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final shopName = shopNames[index];
        final data = grouped[shopName]!;
        
        return InkWell(
          onTap: () {
            setState(() {
              _selectedShop = shopName;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
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
                  child: Icon(Icons.storefront, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopName, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data['saleCount']} Sales Recorded', 
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${data['totalSales'].toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    if (data['totalPending'] > 0) 
                      Text(
                        'Pending: ₹${data['totalPending'].toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.deepOrange, fontSize: 13, fontWeight: FontWeight.bold),
                      )
                    else
                      const Text(
                        'Settled',
                        style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopDetailsList() {
    final shopEntries = _entries.where((e) => e.shopName == _selectedShop).toList();
    final totalShopPending = shopEntries.fold(0.0, (sum, item) => sum + item.pendingAmount);

    return Column(
      children: [
        if (totalShopPending > 0) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Total Pending Balance',
                  style: TextStyle(color: Colors.deepOrange.shade700, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${totalShopPending.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.deepOrange, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showBulkPaymentDialog(_selectedShop!, totalShopPending),
                    icon: const Icon(Icons.payments, color: Colors.white),
                    label: const Text('Collect Overall Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shopEntries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final entry = shopEntries[index];
            final dateStr = '${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}/${entry.date.year}';
            final isPending = entry.pendingAmount > 0;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isPending ? Border.all(color: Colors.orange.shade200, width: 1.5) : null,
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr, 
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '₹${entry.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${entry.pocketCount} Pkts @ ₹${entry.pocketPrice}',
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                      ),
                      if (isPending)
                        Text(
                          'Pending: ₹${entry.pendingAmount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.deepOrange, fontSize: 14, fontWeight: FontWeight.bold),
                        )
                      else
                        const Text(
                          'Fully Paid',
                          style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  if (isPending) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showPaymentDialog(entry),
                        icon: const Icon(Icons.payments, color: Colors.deepOrange, size: 20),
                        label: const Text('Collect Individual Payment', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
