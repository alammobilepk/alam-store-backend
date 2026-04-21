class GetProducts {
  final ProductRepository repo;

  GetProducts(this.repo);

  Stream<List<ProductEntity>> call() {
    return repo.getProducts();
  }
}