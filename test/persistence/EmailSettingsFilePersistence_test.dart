import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services_emailsettings/pip_services_emailsettings.dart';
import './EmailSettingsPersistenceFixture.dart';

void main() {
  group('EmailSettingsFilePersistence', () {
    EmailSettingsFilePersistence persistence;
    EmailSettingsPersistenceFixture fixture;

    setUp(() async {
      persistence =
          EmailSettingsFilePersistence('data/email_settings.test.json');
      persistence.configure(ConfigParams());

      fixture = EmailSettingsPersistenceFixture(persistence);

      await persistence.open(null);
      await persistence.clear(null);
    });

    tearDown(() async {
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      await fixture.testCrudOperations();
    });
  });
}
