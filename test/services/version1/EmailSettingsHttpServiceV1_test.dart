import 'dart:convert';
import 'package:pip_clients_email/pip_clients_email.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services_emailsettings/pip_services_emailsettings.dart';

final SETTINGS = EmailSettingsV1(
    id: '1',
    name: 'User 1',
    email: 'user1@conceptual.vision',
    language: 'en',
    verified: false);

var httpConfig = ConfigParams.fromTuples([
  'connection.protocol',
  'http',
  'connection.host',
  'localhost',
  'connection.port',
  3000
]);

void main() {
  group('EmailSettingsHttpServiceV1', () {
    EmailSettingsMemoryPersistence persistence;
    EmailSettingsController controller;
    EmailSettingsHttpServiceV1 service;
    http.Client rest;
    String url;

    setUp(() async {
      url = 'http://localhost:3000';
      rest = http.Client();

      persistence = EmailSettingsMemoryPersistence();
      persistence.configure(ConfigParams());

      controller = EmailSettingsController();
      controller.configure(ConfigParams());

      service = EmailSettingsHttpServiceV1();
      service.configure(httpConfig);

      var references = References.fromTuples([
        Descriptor('pip-services-emailsettings', 'persistence', 'memory',
            'default', '1.0'),
        persistence,
        Descriptor('pip-services-emailsettings', 'controller', 'default',
            'default', '1.0'),
        controller,
        Descriptor('pip-services-email', 'client', 'null', 'default', '1.0'),
        EmailNullClientV1(),
        Descriptor(
            'pip-services-emailsettings', 'service', 'http', 'default', '1.0'),
        service
      ]);

      controller.setReferences(references);
      service.setReferences(references);

      await persistence.open(null);
      await service.open(null);
    });

    tearDown(() async {
      await service.close(null);
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      EmailSettingsV1 settings1;

      // Create email settings
      var resp = await rest.post(url + '/v1/email_settings/set_settings',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'settings': SETTINGS}));
      var settings = EmailSettingsV1();
      settings.fromJson(json.decode(resp.body));
      expect(settings, isNotNull);
      expect(SETTINGS.id, settings.id);
      expect(SETTINGS.email, settings.email);
      expect(settings.verified, isFalse);

      settings1 = settings;

      // Update the settings
      settings1.subscriptions = {'engagement': true};

      resp = await rest.post(url + '/v1/email_settings/set_settings',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'settings': settings1}));
      settings = EmailSettingsV1();
      settings.fromJson(json.decode(resp.body));
      expect(settings, isNotNull);
      expect(settings1.id, settings.id);
      expect(settings.subscriptions['engagement'], isTrue);

      // Get settings
      resp = await rest.post(url + '/v1/email_settings/get_settings_by_ids',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'recipient_ids': [settings1.id]}));
      var list = List<EmailSettingsV1>.from(json.decode(resp.body).map((itemsJson) => EmailSettingsV1.fromJson(itemsJson)));
      expect(list, isNotNull);
      expect(list.length, 1);

      // Delete the settings
      resp = await rest.post(url + '/v1/email_settings/delete_settings_by_id',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'recipient_id': settings1.id}));
      settings = EmailSettingsV1();
      settings.fromJson(json.decode(resp.body));
      expect(settings, isNotNull);
      expect(settings1.id, settings.id);

      // Try to get deleted settings
      resp = await rest.post(url + '/v1/email_settings/get_settings_by_id',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'recipient_id': settings1.id}));
      expect(resp.body, isEmpty);
    });
  });
}
