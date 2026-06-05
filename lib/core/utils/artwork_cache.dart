import 'dart:typed_data';

class ArtworkCache {
  static final ArtworkCache instance = ArtworkCache._();
  ArtworkCache._();

  final _cache = <String, Uint8List?>{};
  static const _maxSize = 50;

  Uint8List? get(String key) {
    if (!_cache.containsKey(key)) return null;
    final value = _cache.remove(key);
    _cache[key] = value;
    return value;
  }

  void put(String key, Uint8List? value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  bool has(String key) => _cache.containsKey(key);

  void clear() => _cache.clear();
}
