import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

// Imports
import 'cart_page.dart';
import 'product_detail.dart';
import 'sell_page.dart';
import 'messages_page.dart';
import 'account_page.dart';
import 'jobs_page.dart';
import 'upload_product.dart';
import 'cart_state.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  
  int _currentPage = 0;
  String selectedCategory = "All";
  String searchQuery = "";
  late Timer _bannerTimer;
  
  // BACKEND FIX: Stream ko variable mein store kiya takay infinite rebuild na ho
  late Stream<QuerySnapshot> _productsStream;

  final List<Map<String, dynamic>> flashSaleItems = [
    {"name": "AirPods Pro 2", "price": 45000, "old": 55000, "image": Icons.headphones, "discount": "-18%"},
    {"name": "Xiaomi Watch", "price": 12500, "old": 15000, "image": Icons.watch, "discount": "-15%"},
    {"name": "Gaming Mouse", "price": 4500, "old": 6000, "image": Icons.mouse, "discount": "-25%"},
  ];

  @override
  void initState() {
    super.initState();
    // OPTIMIZED: Stream initialization only once
    _productsStream = FirebaseFirestore.instance.collection('products').snapshots();
    
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage > 2) nextPage = 0;
        _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _productsStream = FirebaseFirestore.instance.collection('products').snapshots();
    }); 
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
        title: Column(
          children: const [
            Text("ED ELECTRONIC DUKAAN", style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2)),
            Text("By Alam Enterprises", style: TextStyle(color: Color(0xFF00D261), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
        centerTitle: true,
        actions: [
          // PRO FEATURE: Live Cart Counter Connected Successfully
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: globalCartNotifier,
            builder: (context, cart, child) {
              return IconButton(
                icon: Badge(
                  label: Text(cart.length.toString()),
                  isLabelVisible: cart.isNotEmpty,
                  child: const Icon(Icons.shopping_bag_outlined, size: 26),
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
              );
            }
          ),
          const SizedBox(width: 10),
        ],
      ),

      drawer: _buildDrawer(),

      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF004AAD),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              _buildBanners(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => _buildDot(index == _currentPage)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 15, 16, 5),
                child: Text("Top Brands", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
              _buildTopBrandsRow(),
              const SizedBox(height: 15),
              _buildCategorySelector(),
              const FlashSaleHeader(),
              _buildFlashSaleHorizontalList(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 25, 16, 10),
                child: Text("Just For You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
              
              // BACKEND OPTIMIZED STREAM
              StreamBuilder<QuerySnapshot>(
                stream: _productsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(padding: EdgeInsets.all(50.0), child: Center(child: CircularProgressIndicator(color: Color(0xFF004AAD))));
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Backend Connection Error!", style: TextStyle(color: Colors.red)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(padding: EdgeInsets.all(40), child: Center(child: Text("No products found!", style: TextStyle(color: Colors.grey))));
                  }

                  var allProducts = snapshot.data!.docs;
                  var filteredList = allProducts.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String cat = data['category'] ?? data['cat'] ?? 'Other'; 
                    String name = data['name'] ?? '';
                    bool matchCat = selectedCategory == "All" || cat == selectedCategory;
                    bool matchSearch = name.toLowerCase().contains(searchQuery.toLowerCase());
                    return matchCat && matchSearch;
                  }).toList();

                  if (filteredList.isEmpty) {
                     return const Padding(padding: EdgeInsets.all(40), child: Center(child: Text("Item not found!", style: TextStyle(color: Colors.grey))));
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      childAspectRatio: 0.60, // FIX: Adjusted for image height constraints
                      crossAxisSpacing: 15, 
                      mainAxisSpacing: 15
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (_, i) {
                      var p = filteredList[i].data() as Map<String, dynamic>;
                      p['id'] = filteredList[i].id; 
                      return _buildFirebaseProductCard(p);
                    },
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00D261),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UploadProductPage()));
        },
        child: const Icon(Icons.add_business, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ============== HELPER METHODS ==============

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF004AAD), Color(0xFF0075FF)])),
            accountName: Text("Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text("admin@alamenterprises.com"),
            currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Color(0xFF004AAD))),
          ),
          ListTile(leading: const Icon(Icons.work_rounded, color: Colors.orange), title: const Text("Jobs & Gigs", style: TextStyle(fontWeight: FontWeight.bold)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobsPage()))),
          ListTile(leading: const Icon(Icons.history, color: Colors.blue), title: const Text("My Orders"), onTap: () {}),
          ListTile(leading: const Icon(Icons.settings, color: Colors.grey), title: const Text("Settings"), onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: const InputDecoration(hintText: "Search mobiles, laptops & more...", hintStyle: TextStyle(color: Colors.grey, fontSize: 14), border: InputBorder.none, icon: Icon(Icons.search, color: Color(0xFF004AAD))),
        ),
      ),
    );
  }

  Widget _buildBanners() {
    return SizedBox(
      height: 170,
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          _buildBanner("UP TO 50% OFF\nOn Audio Devices", const Color(0xFF004AAD)), 
          _buildBanner("NEW ARRIVALS\nSamsung S24 Series", const Color(0xFF00D261)),
          _buildBanner("MEGA SALE\nED Exclusive", Colors.deepOrangeAccent),
        ],
      ),
    );
  }

  Widget _buildBanner(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), 
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.3)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Text("Shop Now", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(color: isActive ? const Color(0xFF004AAD) : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildTopBrandsRow() {
    List<Map<String, dynamic>> brands = [
      {"icon": Icons.apple, "name": "Apple", "color": Colors.black},
      {"icon": Icons.android, "name": "Samsung", "color": Colors.blue},
      {"icon": Icons.gamepad, "name": "Sony", "color": Colors.indigo},
      {"icon": Icons.laptop_mac, "name": "HP", "color": Colors.lightBlue},
      {"icon": Icons.speaker, "name": "JBL", "color": Colors.deepOrange},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                CircleAvatar(radius: 25, backgroundColor: Colors.white, child: Icon(brands[index]['icon'], color: brands[index]['color'], size: 30)),
                const SizedBox(height: 5),
                Text(brands[index]['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: ["All", "Mobiles", "Audio", "Watch", "Accessories", "Laptops"].map((cat) {
          bool isSelected = selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF004AAD) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF004AAD).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Center(child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 13))),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFlashSaleHorizontalList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: flashSaleItems.length,
        itemBuilder: (context, index) {
          var item = flashSaleItems[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5, offset: const Offset(0, 3))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
                      child: Icon(item['image'], size: 50, color: Colors.grey),
                    ),
                    Positioned(
                      top: 5, right: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
                        child: Text(item['discount'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Text("Rs ${item['old']}", style: const TextStyle(color: Colors.grey, fontSize: 10, decoration: TextDecoration.lineThrough)),
                      Text("Rs ${item['price']}", style: const TextStyle(color: Color(0xFF00D261), fontWeight: FontWeight.w900, fontSize: 13)),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFirebaseProductCard(Map<String, dynamic> p) {
    String name = p['name'] ?? 'Unknown Product';
    String price = p['price']?.toString() ?? '0';
    String oldPrice = p['oldPrice']?.toString() ?? p['old']?.toString() ?? '0';
    String imageUrl = p['imageUrl'] ?? '';
    String badge = p['badge'] ?? 'HOT';
    String rating = p['rating']?.toString() ?? '4.5';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(product: p))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      // FIX: Image Crash Solved by bounding the Box Fit
                      child: imageUrl.isNotEmpty 
                        ? CachedNetworkImage(
                            imageUrl: imageUrl, 
                            fit: BoxFit.cover, // Yahan BoxFit zaroori tha
                            width: double.infinity,
                            placeholder: (context, url) => const Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2))),
                            errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          )
                        : const Icon(Icons.devices_other_rounded, size: 60, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                      child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  if(oldPrice != '0' && oldPrice != price)
                    Text("Rs $oldPrice", style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Rs $price", style: const TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.w900, fontSize: 15)),
                      
                      // ADD TO CART BACKEND LOGIC IMPROVED
                      GestureDetector(
                        onTap: () {
                          List<Map<String, dynamic>> currentCart = List.from(globalCartNotifier.value);
                          // Check if item exists to avoid duplicate entries, just increase qty if you implement quantity logic
                          bool exists = currentCart.any((item) => item['id'] == p['id']);
                          if(!exists){
                            p['quantity'] = 1;
                            currentCart.add(p);
                            globalCartNotifier.value = currentCart;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name added to cart!"), backgroundColor: const Color(0xFF00D261), duration: const Duration(seconds: 1)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item already in cart!"), backgroundColor: Colors.orange, duration: Duration(seconds: 1)));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Color(0xFF00D261), shape: BoxShape.circle),
                          child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 20,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _navIcon(Icons.home_filled, "Home", true, () {}),
                _navIcon(Icons.work_rounded, "Jobs", false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobsPage()))),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _navIcon(Icons.chat_bubble_rounded, "Chats", false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesPage()))),
                _navIcon(Icons.person_rounded, "Account", false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountPage()))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, String label, bool active, VoidCallback onTap) {
    return MaterialButton(
      minWidth: 70,
      onPressed: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? const Color(0xFF004AAD) : Colors.grey, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? const Color(0xFF004AAD) : Colors.grey)),
        ],
      ),
    );
  }
}

class FlashSaleHeader extends StatefulWidget {
  const FlashSaleHeader({Key? key}) : super(key: key);
  @override
  _FlashSaleHeaderState createState() => _FlashSaleHeaderState();
}

class _FlashSaleHeaderState extends State<FlashSaleHeader> {
  Duration flashSaleDuration = const Duration(hours: 4, minutes: 20, seconds: 0);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && flashSaleDuration.inSeconds > 0) {
        setState(() => flashSaleDuration -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get formattedTime {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(flashSaleDuration.inHours)} : ${twoDigits(flashSaleDuration.inMinutes.remainder(60))} : ${twoDigits(flashSaleDuration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 25, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text("Flash Sale", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(formattedTime, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
          const Text("See All", style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}