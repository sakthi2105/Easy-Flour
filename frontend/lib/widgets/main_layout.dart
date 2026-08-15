import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Namma Maavu'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF2E7D32),
              ),
              child: Text(
                'Namma Maavu Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                context.go('/dashboard');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.rice_bowl),
              title: const Text('Rice Stock'),
              onTap: () {
                context.go('/rice-stock');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.grass),
              title: const Text('Plant Stock'),
              onTap: () {
                context.go('/plant-stock');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.factory),
              title: const Text('Production'),
              onTap: () {
                context.go('/production');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Shop Sales'),
              onTap: () {
                context.go('/shop-sales');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Other Sales'),
              onTap: () {
                context.go('/other-sales');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.money_off),
              title: const Text('Expenses'),
              onTap: () {
                context.go('/expenses');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
