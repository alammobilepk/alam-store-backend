import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User; 
import 'package:firebase_auth/firebase_auth.dart';

class UploadProductPage extends StatefulWidget {
  const UploadProductPage({super.key});

  @override
  State<UploadProductPage> createState() => _UploadProductPageState();
}

class _UploadProductPageState extends State<UploadProductPage> {
  final _formKey = GlobalKey<FormState>();
  
  // --- Controllers (Purany + Naye) ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _oldPriceController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _colorController = TextEditingController(); 
  final TextEditingController _stockController = TextEditingController(text: "1");
  final TextEditingController _warrantyController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _specsController = TextEditingController(); // Naya: Tech Specs

  String _selectedCategory = "Mobiles";
  final List<String> _categories = ["Mobiles", "Audio", "Watch", "Accessories", "Laptops", "Home Appliances", "Gaming", "Cameras"];
  
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  bool _isUploading = false;
  double _uploadProgress = 0;
  bool _isFeatured = false; // Naya Feature
  bool _isFlashSale = false; // Naya Feature

  // Unique SKU Generator
  String _generateSKU() {
    var rng = Random();
    String code = List.generate(6, (_) => rng.nextInt(10)).join();
    return "ED-${_selectedCategory.substring(0, 3).toUpperCase()}-$code";
  }

  Future<void> _pickImages() async {
    // Quality 70% rakhi hai taake upload fast ho (Ultra Pro logic)
    final List<XFile> selectedImages = await _picker.pickMultiImage(imageQuality: 70);
    if (selectedImages.isNotEmpty) {
      setState(() {
        _images.addAll(selectedImages);
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  String _calculateDiscount() {
    if (_oldPriceController.text.isEmpty || _priceController.text.isEmpty) return "0";
    double oldP = double.tryParse(_oldPriceController.text) ?? 0;
    double newP = double.tryParse(_priceController.text) ?? 0;
    if (oldP > newP) {
      return (((oldP - newP) / oldP) * 100).toStringAsFixed(0);
    }
    return "0";
  }

  Future<void> _uploadProduct() async {
    if (_images.length < 5) {
      _showSnackBar("Bhai, 5 images ke baghair professional nahi lagta. Add karein!", Colors.orange);
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0;
      });

      try {
        List<String> imageUrls = [];
        
        // Supabase Upload Logic for 'edukaan' bucket
        for (var i = 0; i < _images.length; i++) {
          final file = File(_images[i].path);
          // Professional path naming
          final String fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          
          await Supabase.instance.client.storage
              .from('edukaan') 
              .uploadBinary(fileName, await file.readAsBytes());

          final String publicUrl = Supabase.instance.client.storage
              .from('edukaan')
              .getPublicUrl(fileName);
          
          imageUrls.add(publicUrl);
          setState(() => _uploadProgress = (i + 1) / _images.length);
        }

        // Firestore Ultra Pro Schema
        await FirebaseFirestore.instance.collection('products').add({
          'productId': _generateSKU(),
          'name': _nameController.text.trim(),
          'brand': _brandController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'oldPrice': _oldPriceController.text.isNotEmpty ? double.parse(_oldPriceController.text.trim()) : 0,
          'discount': _calculateDiscount(),
          'caption': _captionController.text.trim(),
          'description': _descriptionController.text.trim(),
          'specifications': _specsController.text.trim(), // Tech specs
          'colors': _colorController.text.split(',').map((e) => e.trim()).toList(),
          'tags': _tagsController.text.split(',').map((e) => e.trim()).toList(),
          'category': _selectedCategory,
          'stock': int.parse(_stockController.text.trim()),
          'warranty': _warrantyController.text.trim(),
          'images': imageUrls,
          'mainImage': imageUrls[0],
          'isFeatured': _isFeatured,
          'isFlashSale': _isFlashSale,
          'rating': 5.0,
          'reviewsCount': 0,
          'seller': 'Alam Enterprises',
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() => _isUploading = false);
          _showSuccessDialog();
        }
      } catch (e) {
        setState(() => _isUploading = false);
        _showSnackBar("Error: $e", Colors.red);
      }
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("UPLOADED!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
            const SizedBox(height: 10),
            const Text("Aapka product ab 'ED ELECTRONIC DUKAAN' par live hai.", textAlign: TextAlign.center),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AAD), minimumSize: const Size(200, 45)),
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text("CLOSE", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("ULTRA PRO ADMIN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF004AAD),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline))],
      ),
      body: _isUploading 
        ? _loadingUI()
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerText("GALLERY (SELECT 5+)"),
                  _imageGallery(),
                  
                  const SizedBox(height: 25),
                  _headerText("IDENTIFICATION"),
                  _buildModernField(_nameController, "Product Full Name", Icons.title),
                  _buildModernField(_brandController, "Brand Name", Icons.verified),

                  const SizedBox(height: 15),
                  _headerText("PRICING & PROMOTION"),
                  Row(
                    children: [
                      Expanded(child: _buildModernField(_priceController, "Sale Price", Icons.payments, isNum: true)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildModernField(_oldPriceController, "Old Price", Icons.money_off, isNum: true, isReq: false)),
                    ],
                  ),
                  
                  // Featured Toggles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildToggle("Mark as Featured", _isFeatured, (v) => setState(() => _isFeatured = v)),
                      _buildToggle("Flash Sale", _isFlashSale, (v) => setState(() => _isFlashSale = v)),
                    ],
                  ),

                  const SizedBox(height: 15),
                  _headerText("INVENTORY & WARRANTY"),
                  Row(
                    children: [
                      Expanded(child: _buildModernField(_stockController, "In Stock", Icons.inventory, isNum: true)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildModernField(_warrantyController, "Warranty Info", Icons.shield, isReq: false)),
                    ],
                  ),

                  const SizedBox(height: 15),
                  _headerText("CATEGORIZATION"),
                  _categoryPicker(),
                  const SizedBox(height: 15),
                  _buildModernField(_tagsController, "Search Tags (comma separated)", Icons.search, isReq: false),
                  
                  const SizedBox(height: 15),
                  _headerText("DETAILED SPECS"),
                  _buildModernField(_colorController, "Available Colors", Icons.palette),
                  _buildModernField(_specsController, "Key Specs (e.g. 8GB RAM, 5000mAh)", Icons.settings_input_component, isReq: false),
                  _buildModernField(_descriptionController, "Full Product Description", Icons.description, lines: 6),

                  const SizedBox(height: 40),
                  _publishButton(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
    );
  }

  // --- UI Components ---

  Widget _loadingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 150, width: 150,
            child: CircularProgressIndicator(value: _uploadProgress, strokeWidth: 8, color: const Color(0xFF004AAD), backgroundColor: Colors.grey.shade200),
          ),
          const SizedBox(height: 30),
          const Text("SECURING DATA...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text("${(_uploadProgress * 100).toInt()}% Transmitted", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _headerText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.blueGrey, letterSpacing: 1.5)),
    );
  }

  Widget _imageGallery() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length + 1,
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 110,
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.shade100)),
                child: const Icon(Icons.add_a_photo, color: Color(0xFF004AAD), size: 30),
              ),
            );
          }
          return Container(
            width: 110, margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: FileImage(File(_images[index].path)), fit: BoxFit.cover)),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(onPressed: () => _removeImage(index), icon: const CircleAvatar(radius: 12, backgroundColor: Colors.white, child: Icon(Icons.close, size: 14, color: Colors.red))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        Switch(value: value, activeColor: const Color(0xFF004AAD), onChanged: onChanged),
      ],
    );
  }

  Widget _categoryPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
        ),
      ),
    );
  }

  Widget _publishButton() {
    return Container(
      width: double.infinity, height: 60,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: const Color(0xFF004AAD).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AAD), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: _uploadProduct,
        child: const Text("PUBLISH TO ED STORE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildModernField(TextEditingController ctrl, String hint, IconData icon, {bool isNum = false, bool isReq = true, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        maxLines: lines,
        validator: isReq ? (v) => v!.isEmpty ? "$hint is required" : null : null,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF004AAD)),
          filled: true, fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade100)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF004AAD), width: 1.5)),
        ),
      ),
    );
  }
}