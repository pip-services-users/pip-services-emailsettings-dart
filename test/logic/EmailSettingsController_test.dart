import 'package:pip_clients_email/pip_clients_email.dart';
import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services_emailsettings/pip_services_emailsettings.dart';

final SETTINGS = EmailSettingsV1(
    id: '1',
    name: 'User 1',
    email: 'user1@conceptual.vision',
    language: 'en',
    verified: false);
final SETTINGS2 = EmailSettingsV1(
    id: '2',
    name: 'User 2',
    email: 'user2@conceptual.vision',
    language: 'en',
    verified: false);

void main() {
  group('EmailSettingsController', () {
    EmailSettingsMemoryPersistence persistence;
    EmailSettingsController controller;

    setUp(() async {
      persistence = EmailSettingsMemoryPersistence();
      persistence.configure(ConfigParams());

      controller = EmailSettingsController();
      controller.configure(ConfigParams());

      var references = References.fromTuples([
        Descriptor('pip-services-emailsettings', 'persistence', 'memory',
            'default', '1.0'),
        persistence,
        Descriptor('pip-services-emailsettings', 'controller', 'default',
            'default', '1.0'),
        controller,
        Descriptor('pip-services-email', 'client', 'null', 'default', '1.0'),
        EmailNullClientV1()
      ]);

      controller.setReferences(references);

      await persistence.open(null);
    });

    tearDown(() async {
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      EmailSettingsV1 settings1;

      // Create email settings
      var settings = await controller.setSettings(null, SETTINGS);
      expect(settings, isNotNull);
      expect(SETTINGS.id, settings.id);
      expect(SETTINGS.email, settings.email);
      expect(settings.verified, isFalse);

      settings1 = settings;

      // Update the settings
      settings1.subscriptions = {'engagement': true};

      settings = await controller.setSettings(null, settings1);
      expect(settings, isNotNull);
      expect(settings1.id, settings.id);
      expect(settings.subscriptions['engagement'], isTrue);

      // Get settings
      var list = await controller.getSettingsByIds(null, [settings1.id]);
      expect(list, isNotNull);
      expect(list.length, 1);

      // Delete the settings
      settings = await controller.deleteSettingsById(null, settings1.id);
      expect(settings, isNotNull);
      expect(settings1.id, settings.id);

      // Try to get deleted settings
      settings = await controller.getSettingsById(null, settings1.id);
      expect(settings, isNull);
    });

    test('Verify Email', () async {
      EmailSettingsV1 settings1;

      // Create new settings
      settings1 = SETTINGS;
      settings1.ver_code = '123';
      settings1.verified = false;
      settings1.ver_expire_time = DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch + 10000);

      var settings = await persistence.set(null, settings1);
      expect(settings, isNotNull);
      expect(settings1.id, settings.id);
      expect(settings.verified, isFalse);
      expect(settings.ver_code, isNotNull);

      // Verify email
      await controller.verifyEmail(null, settings1.id, settings1.ver_code);

      // Check settings
      settings = await controller.getSettingsById(null, settings1.id);
      expect(settings, isNotNull);
      expect(SETTINGS.id, settings.id);
      expect(settings.verified, isTrue);
      expect(settings.ver_code, isNull);
    });

    test('Resend Verification Email', () async {
      EmailSettingsV1 settings1;

      // Create new settings
      var settings = await persistence.set(null, SETTINGS2);
      expect(settings, isNotNull);
      expect(SETTINGS2.id, settings.id);
      expect(settings.verified, isFalse);
      expect(settings.ver_code, isNull);

      settings1 = settings;

      // Verify email
      await controller.resendVerification(null, settings1.id);

      // Check settings
      settings = await controller.getSettingsById(null, settings1.id);
      expect(settings, isNotNull);
      expect(settings1.id, settings.id);
      expect(settings.verified, isFalse);
      expect(settings.ver_code, isNull);
    });
  });
}
