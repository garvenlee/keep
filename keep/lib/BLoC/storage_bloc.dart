import 'dart:async';
import 'package:keep/data/repository/storage_repository.dart';
import 'package:keep/models/storageUrl.dart';

class CollectionBloc {
  final _collectionRepository = CollectionRepository();

  final _collectionController = StreamController<List<StorageUrl>>.broadcast();

  get collections => _collectionController.stream;

  CollectionBloc() {
    getCollections();
  }

  getCollections({String whereString, String query}) async {
    _collectionController.sink.add(await _collectionRepository
        .getAllCollections(whereString: whereString, query: query));
  }

  addCollection(StorageUrl collection) async {
    await _collectionRepository.insertCollection(collection);
    getCollections();
  }

  Future<bool> getCollectionByURL(String url) async {
    return await _collectionRepository.getItemByURL(url);
  }

  deleteCollection(int createAt) async {
    _collectionRepository.deleteCollection(createAt);
    getCollections();
  }

  dispose() {
    _collectionController.close();
  }
}
