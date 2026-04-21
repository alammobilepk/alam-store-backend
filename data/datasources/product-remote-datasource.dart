class ProductRemoteDataSource {
  final db = FirebaseFirestore.instance;

  Stream<List<ProductModel>> getProducts() {
    return db.collection('products').snapshots().map(
        (snap) => snap.docs.map((e) => ProductModel.fromFirestore(e)).toList());
  }
}