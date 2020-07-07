import 'package:keep/data/dao/storage_dao.dart';
import 'package:keep/models/storageUrl.dart';

class CollectionRepository {
  final collectionDao = StorageUrlDao();

  Future getAllCollections({String whereString, String query}) =>
      collectionDao.getStorageUrls(whereString: whereString, query: query);

  Future<bool> getItemByURL(String url) => collectionDao.getOneItem(url);

  Future insertCollection(StorageUrl msg) =>
      collectionDao.createStorageUrl(msg);

  Future deleteCollection(int createAt) =>
      collectionDao.deleteStorageUrl(createAt);

  //We are not going to use this in the demo
  Future deleteAllCollections() => collectionDao.deleteAllStorageUrls();
}
