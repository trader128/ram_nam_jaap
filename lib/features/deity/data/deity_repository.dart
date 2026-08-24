import '../../../core/constants/hive_keys.dart';
import '../../../core/storage/hive_storage.dart';
import '../domain/deity_catalog.dart';
import '../domain/deity_pack.dart';

class DeityRepository {
  DeityPack loadSelected() {
    final id = HiveStorage.settingsBox.get(HiveKeys.selectedDeity) as String?;
    return DeityCatalog.byId(id);
  }

  Future<void> saveSelected(DeityPack deity) async {
    await HiveStorage.settingsBox.put(HiveKeys.selectedDeity, deity.id);
  }
}
