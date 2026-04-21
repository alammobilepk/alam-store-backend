import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentImageIndex = 0;
  String _selectedColor = "";
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Default color set karna
    if (widget.product['colors'] != null && (widget.product['colors'] as List).isNotEmpty) {
      _selectedColor = widget.product['colors'][0];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data Extraction & Fallbacks
    List<dynamic> images = widget.product['images'] ?? [widget.product['imageUrl'] ?? ''];
    String name = widget.product['name'] ?? 'Unknown Product';
    double price = (widget.product['price'] ?? 0).toDouble();
    double oldPrice = (widget.product['oldPrice'] ?? 0).toDouble();
    String description = widget.product['description'] ?? 'No description available for this premium product.';
    String caption = widget.product['caption'] ?? 'Top Rated';
    List<dynamic> colors = widget.product['colors'] ?? ['Standard'];
    String rating = widget.product['rating']?.toString() ?? '4.8';

    // Discount Calculation
    int discountPercent = 0;
    if (oldPrice > price) {
      discountPercent = ((oldPrice - price) / oldPrice * 100).round();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light premium background
      
      // 1. APP BAR (Transparent & Floating)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.8),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: const Icon(Icons.share_outlined, color: Colors.black87, size: 22),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.black87,
                size: 22,
              ),
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          const SizedBox(width: 10),
        ],
      ),
      extendBodyBehindAppBar: true,

      // 2. BOTTOM NAVIGATION BAR (Add to Cart & Buy Now with Total)
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            // Dynamic Total Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Total Price", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(
                  "Rs ${(price * _quantity).toStringAsFixed(0)}", 
                  style: const TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ],
            ),
            const Spacer(),
            // Fixed Add to Cart Button (onIcon ki jagah icon)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                side: const BorderSide(color: Color(0xFF004AAD), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF004AAD), size: 20),
              label: const Text("Cart", style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to Cart!"), backgroundColor: Colors.green));
              },
            ),
            const SizedBox(width: 10),
            // Buy Now Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D261),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
              onPressed: () {
                // Checkout Page Logic
              },
              child: const Text("Buy Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),

      // 3. MAIN BODY
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE SLIDER SECTION ---
            Container(
              color: Colors.white,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: 450,
                    child: PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (index) => setState(() => _currentImageIndex = index),
                      itemBuilder: (context, index) {
                        return Hero(
                          tag: widget.product['imageUrl'] ?? 'hero_image',
                          child: images[index].isNotEmpty
                              ? Image.network(images[index], fit: BoxFit.cover)
                              : const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  // Discount Badge Overlay
                  if (discountPercent > 0)
                    Positioned(
                      bottom: 40, left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                        child: Text("-$discountPercent% OFF", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  // Image Dots
                  Positioned(
                    bottom: 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentImageIndex == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index ? const Color(0xFF004AAD) : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                  )
                ],
              ),
            ),

            // --- DETAILS SECTION ---
            Container(
              transform: Matrix4.translationValues(0, -20, 0),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption & Stock Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(caption.toUpperCase(), style: const TextStyle(color: Color(0xFF00D261), fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                        child: const Text("✓ In Stock", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Product Name
                  Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87, height: 1.2)),
                  const SizedBox(height: 10),

                  // Ratings & Reviews Row
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 5),
                      Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 10),
                      const Text("|", style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 10),
                      const Text("124 Reviews", style: TextStyle(color: Colors.blueGrey, decoration: TextDecoration.underline)),
                      const Spacer(),
                      const Text("1k+ Sold", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const Divider(height: 30, thickness: 1, color: Colors.white),

                  // Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Rs ${price.toStringAsFixed(0)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF004AAD))),
                      const SizedBox(width: 15),
                      if (oldPrice > price)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text("Rs ${oldPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- COLORS & QUANTITY ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Colors Selector
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Color", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: colors.map((color) {
                                  bool isSelected = _selectedColor == color;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedColor = color.toString()),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF004AAD) : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                                      ),
                                      child: Text(color.toString(), style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quantity Selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Quantity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: () {
                                    if (_quantity > 1) setState(() => _quantity--);
                                  },
                                ),
                                Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: () => setState(() => _quantity++),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // --- DELIVERY & WARRANTY CARDS ---
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                          child: const Row(
                            children: [
                              Icon(Icons.local_shipping_outlined, color: Color(0xFF004AAD)),
                              SizedBox(width: 8),
                              Expanded(child: Text("Free Delivery\nNext Day", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user_outlined, color: Color(0xFF00D261)),
                              SizedBox(width: 8),
                              Expanded(child: Text("1 Year\nWarranty", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // --- SELLER INFO ---
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        const CircleAvatar(backgroundColor: Color(0xFF004AAD), child: Icon(Icons.storefront, color: Colors.white)),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Sold by", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text("Alam Enterprises", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF004AAD))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: const Text("View Store", style: TextStyle(color: Color(0xFF004AAD), fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- DESCRIPTION ---
                  const Text("Product Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                    child: Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- SIMILAR PRODUCTS (UI Placeholder) ---
                  const Text("You Might Also Like", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            children: [
                              Container(
                                height: 90,
                                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
                                child: const Center(child: Icon(Icons.devices, color: Colors.grey)),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Smart Item", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20), // Bottom spacing
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}