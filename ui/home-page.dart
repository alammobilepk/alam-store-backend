Consumer(
  builder: (context, ref, _) {
    final asyncProducts = ref.watch(productProvider);

    return asyncProducts.when(
      data: (products) => GridView.builder(
        itemCount: products.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (_, i) {
          final product = products[i];

          return ProductCard(product: product);
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text("Error"),
    );
  },
)