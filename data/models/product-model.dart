class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.image,
    required super.category,
  });

  factory ProductModel.fromFirestore(doc) {
    final data = doc.data();

    return ProductModel(
      id: doc.id,
      title: data['title'],
      price: (data['price'] as num).toDouble(),
      image: data['image'],
      category: data['category'],
    );
  }
}