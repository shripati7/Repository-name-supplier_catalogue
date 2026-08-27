import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProductImage(File imageFile, String fileName) async {
    try {
      debugPrint('UPLOAD START');

      final ref = _storage.ref().child('products/$fileName.jpg');

      await ref.putFile(imageFile);

      debugPrint('UPLOAD COMPLETE');

      final url = await ref.getDownloadURL();

      debugPrint('URL = $url');

      return url;
    } catch (e) {
      debugPrint('STORAGE ERROR = $e');
      rethrow;
    }
  }
}
