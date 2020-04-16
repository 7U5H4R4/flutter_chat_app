import 'dart:io';

import 'package:flutterchatapp/providers/StorageProvider.dart';
import 'package:flutterchatapp/repositories/BaseRepository.dart';

class StorageRepository extends BaseRepository{
  StorageProvider storageProvider = StorageProvider();
  Future<String> uploadFile(File file, String path) => storageProvider.uploadFile(file, path);

  @override
  void dispose() {
storageProvider.dispose();
  }
}