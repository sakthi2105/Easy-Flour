import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    
    String title = 'Namma Maavu';
    if (location == '/dashboard') title = 'Overview';
    else if (location == '/rice-stock') title = 'Rice Stock';
    else if (location == '/plant-stock') title = 'Plant Stock';
    else if (location == '/production') title = 'Production';
    else if (location == '/shop-sales') title = 'Shop Sales';
    else if (location == '/other-sales') title = 'Other Sales';
    else if (location == '/expenses') title = 'Expenses';

    final isDashboard = location == '/dashboard';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDashboard ? const Color(0xFF1E3A8A) : Colors.blue.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
        ),
        actions: isDashboard ? [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, size: 22, color: Color(0xFF1E3A8A)),
            ),
          )
        ] : null,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 20, left: 24, right: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.storefront, size: 32, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Namma Maavu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Admin Portal',
                    style: TextStyle(
                      color: Colors.blue.shade200,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Overview',
                    isSelected: location == '/dashboard',
                    onTap: () {
                      context.go('/dashboard');
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.inventory_2_rounded,
                    title: 'Rice Stock',
                    isSelected: location == '/rice-stock',
                    onTap: () {
                      context.go('/rice-stock');
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.eco_rounded,
                    title: 'Plant Stock',
                    isSelected: location == '/plant-stock',
                    onTap: () {
                      context.go('/plant-stock');
                      Navigator.pop(context);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Divider(height: 1),
                  ),
                  _buildDrawerItem(
                    icon: Icons.precision_manufacturing_rounded,
                    title: 'Production',
                    isSelected: location == '/production',
                    onTap: () {
                      context.go('/production');
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.store_rounded,
                    title: 'Shop Sales',
                    isSelected: location == '/shop-sales',
                    onTap: () {
                      context.go('/shop-sales');
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.shopping_bag_rounded,
                    title: 'Other Sales',
                    isSelected: location == '/other-sales',
                    onTap: () {
                      context.go('/other-sales');
                      Navigator.pop(context);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Divider(height: 1),
                  ),
                  _buildDrawerItem(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Expenses',
                    isSelected: location == '/expenses',
                    onTap: () {
                      context.go('/expenses');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildDrawerItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                isSelected: false,
                onTap: () {
                  context.go('/login');
                },
              ),
            ),
          ],
        ),
      ),
      body: child,
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E3A8A).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade600,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade800,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
        onTap: onTap,
      ),
    );
  }
}
