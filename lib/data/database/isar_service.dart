import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zylos/data/database/collections/song_collection.dart';

class IsarService {
  static late Isar _isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([SongCollectionSchema], directory: dir.path);
  }

  static Isar get instance => _isar;
}
