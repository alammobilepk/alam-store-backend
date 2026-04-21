import 'package:flutter/material.dart';

class SellPage extends StatelessWidget {
  const SellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Post Your Ad", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF004AAD), width: 1, style: BorderStyle.solid),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: Color(0xFF004AAD)),
                  SizedBox(height: 10),
                  Text("Add Product Photos", style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text("Ad Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(decoration: InputDecoration(hintText: "e.g. iPhone 13 Pro Max", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            
            const SizedBox(height: 20),
            const Text("Price (Rs)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(keyboardType: TextInputType.number, decoration: InputDecoration(hintText: "Enter your selling price", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            
            const SizedBox(height: 20),
            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(maxLines: 4, decoration: InputDecoration(hintText: "Describe your product condition, warranty, etc.", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D261), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ad Posted Successfully!")));
              Navigator.pop(context);
            },
            child: const Text("POST NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5)),
          ),
        ),
      ),
    );
  }
}