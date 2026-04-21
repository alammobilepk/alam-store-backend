class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;

  ProductRepositoryImpl(this.remote);

  @override
  Stream<List<ProductEntity>> getProducts() {
    return remote.getProducts();
  }

  @override
  Future<void> addToCart(ProductEntity product) async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(product.id)
        .set({
      'title': product.title,
      'price': product.price,
      'image': product.image,
    });
  }
}