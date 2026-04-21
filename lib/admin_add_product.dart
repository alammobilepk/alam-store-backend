import 'dart:io'; // File ke liye zaroori hai
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Storage ke liye
import 'package:image_picker/image_picker.dart'; // Image pick karne ke liye

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  File? _selectedImage; // Image store karne ke liye variable
  bool _isUploading = false; // Loading show karne ke liye

  // 1. Gallery se image uthane ka function
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 2. Firebase mein data aur image bhejne ka function
  Future<void> uploadProduct() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bhai, pehle photo to select kar lo!")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Pehle Storage mein image upload hogi
      String fileName = 'products/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      
      UploadTask uploadTask = storageRef.putFile(_selectedImage!);
      TaskSnapshot snapshot = await uploadTask;
      
      // Image ka link nikalna
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Ab Firestore mein sara data save hoga
      await FirebaseFirestore.instance.collection('products').add({
        'name': nameController.text,
        'price': priceController.text,
        'description': descController.text,
        'imageUrl': downloadUrl, // Image ka link yahan save ho raha hai
        'createdAt': Timestamp.now(),
      });

      print("Product Added Successfully!");
      
      // Sab clear kar dena
      nameController.clear();
      priceController.clear();
      descController.clear();
      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Product Uploaded!")),
      );
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ED Admin - Add Product")),
      body: SingleChildScrollView( // Scroll add kiya hai taake keyboard se error na aaye
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image Preview area
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
              ),
            ),
            SizedBox(height: 10),
            Text("Click above to select image"),
            
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            
            _isUploading 
              ? CircularProgressIndicator() // Uploading ke waqt spinner dikhega
              : ElevatedButton(
                  onPressed: uploadProduct,
                  child: Text("Upload Product"),
                ),
          ],
        ),
      ),
    );
  }
}