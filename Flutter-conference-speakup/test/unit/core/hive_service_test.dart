import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Tests for Hive caching patterns — uses raw Hive (no initFlutter) so
/// path_provider is not needed and tests run as pure Dart.
void main() {
  late Box dataBox;
  late Box ttlBox;
  late Directory tmpDir;

  setUp(() async {
    tmpDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tmpDir.path);
    dataBox = await Hive.openBox('test_data');
    ttlBox = await Hive.openBox('test_ttl');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
  });

  group('Hive caching patterns', () {
    test('open box stores & retrieves values', () async {
      await dataBox.put('key', {'name': 'Test'});
      final result = dataBox.get('key');
      expect(result, isA<Map>());
      expect(result['name'], 'Test');
    });

    test('putWithTTL pattern stores value and expiry', () async {
      const key = 'ttl_key';
      await dataBox.put(key, 'value');
      await ttlBox.put(
        '${dataBox.name}:$key',
        DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
      );
      expect(dataBox.get(key), 'value');
      expect(ttlBox.get('${dataBox.name}:$key'), isA<String>());
    });

    test('getIfFresh returns value when not expired', () async {
      const key = 'fresh';
      await dataBox.put(key, {'data': 'still good'});
      await ttlBox.put(
        '${dataBox.name}:$key',
        DateTime.now().add(const Duration(minutes: 60)).toIso8601String(),
      );

      // Simulate getIfFresh logic
      final expiryStr = ttlBox.get('${dataBox.name}:$key') as String?;
      dynamic result;
      if (expiryStr != null) {
        final expiry = DateTime.tryParse(expiryStr);
        if (expiry != null && DateTime.now().isBefore(expiry)) {
          result = dataBox.get(key);
        }
      }
      expect(result, isNotNull);
      expect(result['data'], 'still good');
    });

    test('getIfFresh returns null when expired', () async {
      const key = 'stale';
      await dataBox.put(key, 'old');
      await ttlBox.put(
        '${dataBox.name}:$key',
        DateTime.now().subtract(const Duration(minutes: 1)).toIso8601String(),
      );

      final expiryStr = ttlBox.get('${dataBox.name}:$key') as String?;
      dynamic result;
      if (expiryStr != null) {
        final expiry = DateTime.tryParse(expiryStr);
        if (expiry == null || DateTime.now().isAfter(expiry)) {
          result = null; // Expired
        } else {
          result = dataBox.get(key);
        }
      }
      expect(result, isNull);
    });

    test('clear removes all entries', () async {
      await dataBox.put('a', 1);
      await dataBox.put('b', 2);
      await dataBox.clear();
      expect(dataBox.isEmpty, true);
    });

    test('delete removes a single key', () async {
      await dataBox.put('x', 'y');
      await dataBox.delete('x');
      expect(dataBox.get('x'), isNull);
    });
  });
}
