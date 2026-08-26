import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProductImage(File imageFile, String fileName) async {
    final ref = _storage.ref().child('products/$fileName.jpg');

    await ref.putFile(imageFile);

    return await ref.getDownloadURL();
  }
}
