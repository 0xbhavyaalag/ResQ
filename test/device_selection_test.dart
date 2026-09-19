import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resq/core/constants/device_data.dart';
import 'package:resq/services/storage_service.dart';
import 'package:resq/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().init();
  });

  group('DeviceData Catalog Tests', () {
    test('Contains all 10 required brands', () {
      final expectedBrands = [
        'Samsung',
        'Apple',
        'Realme',
        'OnePlus',
        'Xiaomi',
        'Redmi',
        'Vivo',
        'Oppo',
        'Motorola',
        'Google Pixel',
      ];

      for (final brand in expectedBrands) {
        expect(DeviceData.brands.contains(brand), isTrue, reason: 'Missing brand: $brand');
        expect(DeviceData.getModels(brand).isNotEmpty, isTrue, reason: 'Empty model list for: $brand');
      }
    });

    test('Samsung contains Galaxy S25 and other models', () {
      final samsungModels = DeviceData.getModels('Samsung');
      expect(samsungModels.contains('Galaxy S25'), isTrue);
      expect(samsungModels.contains('Galaxy S24'), isTrue);
      expect(samsungModels.contains('Galaxy A54'), isTrue);
    });

    test('Apple contains iPhone models', () {
      final appleModels = DeviceData.getModels('Apple');
      expect(appleModels.contains('iPhone 15'), isTrue);
      expect(appleModels.contains('iPhone 16'), isTrue);
    });

    test('Realme contains Realme models', () {
      final realmeModels = DeviceData.getModels('Realme');
      expect(realmeModels.contains('Realme 12'), isTrue);
      expect(realmeModels.contains('Realme GT'), isTrue);
    });
  });

  group('StorageService & AppStateProvider Device Selection Tests', () {
    test('Persists and retrieves selected brand and model', () async {
      final storage = StorageService();
      expect(storage.getSelectedBrand(), isNull);
      expect(storage.getSelectedModel(), isNull);

      await storage.saveSelectedDevice('Samsung', 'Galaxy S25');
      expect(storage.getSelectedBrand(), 'Samsung');
      expect(storage.getSelectedModel(), 'Galaxy S25');

      await storage.clearSelectedDevice();
      expect(storage.getSelectedBrand(), isNull);
      expect(storage.getSelectedModel(), isNull);
    });

    test('AppStateProvider manages selected device state and notifies listeners', () async {
      final appState = AppStateProvider();
      expect(appState.selectedDevice, isNull);

      bool notified = false;
      appState.addListener(() {
        notified = true;
      });

      await appState.setSelectedDevice('Samsung', 'Galaxy S25');

      expect(notified, isTrue);
      expect(appState.selectedBrand, 'Samsung');
      expect(appState.selectedModel, 'Galaxy S25');
      expect(appState.selectedDevice, 'Samsung Galaxy S25');

      // Verify persistence was updated
      final storage = StorageService();
      expect(storage.getSelectedBrand(), 'Samsung');
      expect(storage.getSelectedModel(), 'Galaxy S25');

      // Test changing device
      await appState.setSelectedDevice('Apple', 'iPhone 16');
      expect(appState.selectedDevice, 'Apple iPhone 16');
    });
  });
}
