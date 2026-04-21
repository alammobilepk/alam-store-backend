import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // BACKEND LOGIC: Order placing function
  Future<void> _processCheckout(BuildContext context, List<Map<String, dynamic>> items) async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    try {
      // 1. Calculate Total
      double total = items.fold(0, (sum, item) => sum + double.parse(item['price'].toString()));
      
      // 2. Generate Order Doc in Firestore
      DocumentReference orderRef = await FirebaseFirestore.instance.collection('orders').add({
        'buyerId': 'current_user_id', // Replace with FirebaseAuth.instance.currentUser!.uid
        'totalAmount': total,
        'items': items,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Trigger Email System
      // Yahan hum Firestore mein 'mail' collection mein data daltay hain. 
      // Firebase "Trigger Email" extension isko read karke automatically seller ko email bhej dega.
      for (var item in items) {
        String sellerEmail = item['sellerEmail'] ?? 'admin@alamenterprises.com'; 
        
        await FirebaseFirestore.instance.collection('mail').add({
          'to': sellerEmail,
          'message': {
            'subject': 'Naya Order Recieve Hua Hai! - ED DUKAAN',
            'html': 'Hello Seller, aapki product <b>${item['name']}</b> ka order place hua hai. Please delivery process shuru karein. Order ID: ${orderRef.id}',
          }
        });
      }

      Navigator.pop(context); // Close loader
      globalCartNotifier.value = []; // Clear Cart
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Successfully Placed! Sellers Notified."), backgroundColor: Colors.green));
      Navigator.pop(context); // Go back to Home
      
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        title: const Text("Your Cart", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF004AAD)), onPressed: () => Navigator.pop(context)),
      ),
      
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: globalCartNotifier,
        builder: (context, cartItems, child) {
          if (cartItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text("Your Cart is currently empty", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: item['imageUrl'] ?? '',
                              width: 70, height: 70, fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 5),
                                Text("Rs ${item['price']}", style: const TextStyle(color: Color(0xFF00D261), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              List<Map<String, dynamic>> updatedList = List.from(globalCartNotifier.value);
                              updatedList.removeAt(index);
                              globalCartNotifier.value = updatedList;
                            },
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              // CHECKOUT BOTTOM SECTION
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Amount:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text(
                          "Rs ${cartItems.fold(0, (sum, item) => sum + int.parse(item['price'].toString()))}",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF004AAD))
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D261),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5
                        ),
                        onPressed: () => _processCheckout(context, cartItems),
                        child: const Text("PROCEED TO BUY", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}