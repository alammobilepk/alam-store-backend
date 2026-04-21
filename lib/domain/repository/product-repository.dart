abstract class ProductRepository {
  Stream<List<ProductEntity>> getProducts();
  Future<void> addToCart(ProductEntity product);
}