# Development Guide

## Quick Start

### Setup
```bash
# Clone repository
git clone <repository-url>
cd qibla_compass_offline

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Development Commands

```bash
# Run app in debug mode
flutter run

# Run with specific device
flutter run -d <device-id>

# Hot reload (press 'r' in terminal)
# Hot restart (press 'R' in terminal)

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .

# Clean build
flutter clean
flutter pub get
```

## Project Architecture

### GetX Pattern
This project uses GetX for:
- **State Management**: Controllers manage app state
- **Dependency Injection**: Bindings provide dependencies
- **Routing**: Declarative routing with GetX

### Folder Structure

```
lib/
├── core/              # Shared core functionality
├── constants/         # App constants
├── models/           # Data models
├── controllers/      # Business logic (GetX)
├── services/         # External services
├── views/            # UI screens
├── widgets/          # Reusable widgets
├── routes/           # App routing
├── bindings/         # Dependency injection
├── utils/            # Utility functions
└── main.dart         # Entry point
```

## Creating New Features

### 1. Create Model (if needed)
```dart
// lib/models/feature_model.dart
class FeatureModel {
  final String id;
  final String name;
  
  FeatureModel({required this.id, required this.name});
  
  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: json['id'],
      name: json['name'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

### 2. Create Service (if needed)
```dart
// lib/services/feature_service.dart
class FeatureService {
  static final FeatureService _instance = FeatureService._internal();
  factory FeatureService() => _instance;
  FeatureService._internal();
  
  Future<List<FeatureModel>> fetchData() async {
    // Implementation
  }
}
```

### 3. Create Controller
```dart
// lib/controllers/feature_controller.dart
import 'package:get/get.dart';

class FeatureController extends GetxController {
  final _isLoading = false.obs;
  final _data = <FeatureModel>[].obs;
  
  bool get isLoading => _isLoading.value;
  List<FeatureModel> get data => _data;
  
  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  
  Future<void> loadData() async {
    try {
      _isLoading.value = true;
      final result = await FeatureService().fetchData();
      _data.value = result;
    } catch (e) {
      Logger.error('Failed to load data', error: e);
    } finally {
      _isLoading.value = false;
    }
  }
}
```

### 4. Create View
```dart
// lib/views/feature_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeatureScreen extends GetView<FeatureController> {
  const FeatureScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature')),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return ListView.builder(
          itemCount: controller.data.length,
          itemBuilder: (context, index) {
            final item = controller.data[index];
            return ListTile(title: Text(item.name));
          },
        );
      }),
    );
  }
}
```

### 5. Create Binding
```dart
// lib/bindings/feature_binding.dart
import 'package:get/get.dart';

class FeatureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeatureController>(() => FeatureController());
  }
}
```

### 6. Add Route
```dart
// lib/routes/app_pages.dart
class Routes {
  static const FEATURE = '/feature';
}

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.FEATURE,
      page: () => const FeatureScreen(),
      binding: FeatureBinding(),
    ),
  ];
}
```

## Best Practices

### State Management
- Use `.obs` for reactive variables
- Use `Obx()` or `GetX()` widgets for reactive UI
- Keep business logic in controllers
- Use `Get.find()` to access controllers

### Error Handling
```dart
try {
  // Your code
} catch (e, stackTrace) {
  Logger.error('Error message', error: e, stackTrace: stackTrace);
  Get.snackbar('Error', 'Something went wrong');
}
```

### Loading States
```dart
final _isLoading = false.obs;

Future<void> loadData() async {
  _isLoading.value = true;
  try {
    // Load data
  } finally {
    _isLoading.value = false;
  }
}
```

### Navigation
```dart
// Navigate to screen
Get.toNamed(Routes.FEATURE);

// Navigate with arguments
Get.toNamed(Routes.FEATURE, arguments: {'id': '123'});

// Get arguments
final args = Get.arguments;

// Go back
Get.back();

// Go back with result
Get.back(result: data);
```

### Dependency Injection
```dart
// Register dependency
Get.put(MyController());

// Lazy registration
Get.lazyPut(() => MyController());

// Find dependency
final controller = Get.find<MyController>();
```

### Dialogs & Snackbars
```dart
// Show snackbar
Get.snackbar('Title', 'Message');

// Show dialog
Get.dialog(AlertDialog(
  title: const Text('Title'),
  content: const Text('Message'),
));

// Show bottom sheet
Get.bottomSheet(Container(
  child: const Text('Bottom Sheet'),
));
```

## Testing

### Unit Tests
```dart
// test/controllers/feature_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late FeatureController controller;
  
  setUp(() {
    controller = FeatureController();
  });
  
  test('Initial state', () {
    expect(controller.isLoading, false);
    expect(controller.data, isEmpty);
  });
  
  test('Load data', () async {
    await controller.loadData();
    expect(controller.data, isNotEmpty);
  });
}
```

### Widget Tests
```dart
// test/widgets/feature_widget_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Feature widget test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Feature'), findsOneWidget);
  });
}
```

## Debugging

### Print Debugging
Use Logger instead of print:
```dart
Logger.log('Debug message');
Logger.error('Error message', error: e);
Logger.warning('Warning message');
Logger.info('Info message');
```

### Flutter DevTools
```bash
# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Common Issues

**Hot reload not working:**
- Try hot restart (R)
- Check for syntax errors
- Restart the app

**Build errors:**
```bash
flutter clean
flutter pub get
flutter run
```

**Import errors:**
- Check import paths
- Run `flutter pub get`
- Restart IDE

## Performance Tips

1. **Use const constructors** where possible
2. **Avoid rebuilding entire widget tree** - use Obx() for specific widgets
3. **Lazy load data** - don't load everything at once
4. **Cache images and data** - use cached_network_image
5. **Dispose controllers** - clean up resources in onClose()
6. **Use ListView.builder** for long lists
7. **Optimize images** - compress and resize
8. **Profile your app** - use Flutter DevTools

## Code Quality

### Before Committing
```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Check for unused dependencies
flutter pub deps
```

### Code Review Checklist
- [ ] Code follows project structure
- [ ] No analyzer warnings
- [ ] Proper error handling
- [ ] Loading states implemented
- [ ] Offline support considered
- [ ] Performance optimized
- [ ] Tested on Android and iOS
- [ ] Documentation added

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [GetX Documentation](https://pub.dev/packages/get)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Material Design 3](https://m3.material.io/)

## Getting Help

- Check existing issues
- Read documentation
- Ask in pull request comments
- Open a new issue with details
