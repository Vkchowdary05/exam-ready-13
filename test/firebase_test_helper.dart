import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Firebase test helper to initialize Firebase for testing
class FirebaseTestHelper {
  static bool _initialized = false;

  /// Initialize Firebase for testing
  static Future<void> initializeFirebase() async {
    if (_initialized) return;

    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock Firebase for testing
    setupFirebaseCoreMocks();

    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
      ),
    );

    _initialized = true;
  }

  /// Setup Firebase core mocks
  static void setupFirebaseCoreMocks() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/firebase_core'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'Firebase#initializeCore') {
              return [
                {
                  'name': '[DEFAULT]',
                  'options': {
                    'apiKey': 'test-api-key',
                    'appId': 'test-app-id',
                    'messagingSenderId': 'test-sender-id',
                    'projectId': 'test-project-id',
                  },
                  'pluginConstants': <String, dynamic>{},
                },
              ];
            }
            if (methodCall.method == 'Firebase#initializeApp') {
              return {
                'name': '[DEFAULT]',
                'options': {
                  'apiKey': 'test-api-key',
                  'appId': 'test-app-id',
                  'messagingSenderId': 'test-sender-id',
                  'projectId': 'test-project-id',
                },
                'pluginConstants': <String, dynamic>{},
              };
            }
            return null;
          },
        );
  }
}
