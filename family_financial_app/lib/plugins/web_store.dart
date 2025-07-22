import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/constants/storage_key.dart';
import 'package:localstorage/localstorage.dart';

class WebStore extends Store {
  @override
  Future<void> delete(String key) async {
    await Future.sync(() {
      localStorage.removeItem(StorageKey.user);
    });
  }

  @override
  T get<T>(String key) {
    // TODO: implement getData
    throw UnimplementedError();
  }

  @override
  void set(String key, value) {
    // TODO: implement saveData
  }
  // Web-specific implementation of the store
}
