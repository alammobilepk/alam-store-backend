import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text("My Account", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, backgroundColor: Color(0xFF004AAD), child: Icon(Icons.person, size: 50, color: Colors.white)),
                  const SizedBox(height: 15),
                  const Text("Alam User", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("user@alamenterprises.com", style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildMenuTile(Icons.shopping_bag_outlined, "My Orders"),
            _buildMenuTile(Icons.location_on_outlined, "Shipping Addresses"),
            _buildMenuTile(Icons.payment_outlined, "Payment Methods"),
            _buildMenuTile(Icons.notifications_outlined, "Notifications"),
            const SizedBox(height: 20),
            _buildMenuTile(Icons.logout, "Logout", isRed: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {bool isRed = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: isRed ? Colors.red : const Color(0xFF004AAD)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isRed ? Colors.red : Colors.black)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}