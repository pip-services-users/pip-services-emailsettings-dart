import 'package:test/test.dart';
import 'package:pip_services_emailsettings/pip_services_emailsettings.dart';

final SETTINGS1 = EmailSettingsV1(
    id: '1',
    name: 'User 1',
    email: 'user1@conceptual.vision',
    language: 'en',
    verified: false,
    ver_code: null,
    subscriptions: { 'notifications': true, 'ads': false });
final SETTINGS2 = EmailSettingsV1(
    id: '2',
    name: 'User 2',
    email: 'user2@conceptual.vision',
    language: 'en',
    verified: false,
    ver_code: null,
    subscriptions: { 'notifications': true, 'ads': true });
final SETTINGS3 = EmailSettingsV1(
    id: '3',
    name: 'User 3',
    email: 'user3@conceptual.vision',
    language: 'en',
    verified: false,
    ver_code: null,
    subscriptions: { 'notifications': false, 'ads': false });

class EmailSettingsPersistenceFixture {
  IEmailSettingsPersistence _persistence;

  EmailSettingsPersistenceFixture(IEmailSettingsPersistence persistence) {
    expect(persistence, isNotNull);
    _persistence = persistence;
  }

  void testCrudOperations() async {
    EmailSettingsV1 settings1;

    // Create items
    var settings = await _persistence.set(null, SETTINGS1);

    expect(settings, isNotNull);
    expect(SETTINGS1.id, settings.id);
    expect(SETTINGS1.email, settings.email);
    expect(SETTINGS1.name, settings.name);
    expect(settings.verified, isFalse);
    expect(settings.ver_code, isNull);

    // Get settings by email
    settings = await _persistence.getOneByEmail(
        null, SETTINGS1.email);
    expect(settings, isNotNull);
    expect(SETTINGS1.id, settings.id);
    expect(SETTINGS1.email, settings.email);

    settings1 = settings;

    // Update the settings
    settings1.email = 'newuser@conceptual.vision';

    settings = await _persistence.set(null, settings1);
    expect(settings, isNotNull);
    expect(settings1.id, settings.id);
    expect(settings.verified, isFalse);
    expect('newuser@conceptual.vision', settings.email);

    // Get list of settings by ids
    var list = await _persistence.getListByIds(null, [SETTINGS1.id]);
    expect(list, isNotNull);
    expect(list.length, 1);

    // Delete the settings
    settings = await _persistence.deleteById(null, settings1.id);
    expect(settings, isNotNull);
    expect(settings1.id, settings.id);

    // Try to get deleted settings
    settings = await _persistence.getOneById(null, settings1.id);
    expect(settings, isNull);
  }
}
