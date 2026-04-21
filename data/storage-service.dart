class StorageService {
  final storage = FirebaseStorage.instance;

  Future<String> upload(File file) async {
    final ref = storage.ref().child('products/${DateTime.now()}');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}