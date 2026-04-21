final productProvider = StreamProvider((ref) {
  final repo = ref.watch(productRepoProvider);
  return repo.getProducts();
});
final productRepoProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ProductRemoteDataSource());
});