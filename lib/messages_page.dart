import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
      ),
      body: ListView.separated(
        itemCount: 5,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: CircleAvatar(backgroundColor: Colors.blue.shade100, child: const Icon(Icons.person, color: Color(0xFF004AAD))),
            title: const Text("Customer Support", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Aapka order ship ho chuka hai!"),
            trailing: const Text("10:45 AM", style: TextStyle(color: Colors.grey, fontSize: 12)),
            onTap: () {},
          );
        },
      ),
    );
  }
}