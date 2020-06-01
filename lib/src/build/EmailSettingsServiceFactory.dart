import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../persistence/EmailSettingsMemoryPersistence.dart';
import '../persistence/EmailSettingsFilePersistence.dart';
import '../persistence/EmailSettingsMongoDbPersistence.dart';
import '../logic/EmailSettingsController.dart';
import '../services/version1/EmailSettingsHttpServiceV1.dart';

class EmailSettingsServiceFactory extends Factory {
  static final MemoryPersistenceDescriptor = Descriptor(
      'pip-services-emailsettings', 'persistence', 'memory', '*', '1.0');
  static final FilePersistenceDescriptor = Descriptor(
      'pip-services-emailsettings', 'persistence', 'file', '*', '1.0');
  static final MongoDbPersistenceDescriptor = Descriptor(
      'pip-services-emailsettings', 'persistence', 'mongodb', '*', '1.0');
  static final ControllerDescriptor = Descriptor(
      'pip-services-emailsettings', 'controller', 'default', '*', '1.0');
  static final HttpServiceDescriptor =
      Descriptor('pip-services-emailsettings', 'service', 'http', '*', '1.0');

  EmailSettingsServiceFactory() : super() {
    registerAsType(EmailSettingsServiceFactory.MemoryPersistenceDescriptor,
        EmailSettingsMemoryPersistence);
    registerAsType(EmailSettingsServiceFactory.FilePersistenceDescriptor,
        EmailSettingsFilePersistence);
    registerAsType(EmailSettingsServiceFactory.MongoDbPersistenceDescriptor,
        EmailSettingsMongoDbPersistence);
    registerAsType(EmailSettingsServiceFactory.ControllerDescriptor,
        EmailSettingsController);
    registerAsType(EmailSettingsServiceFactory.HttpServiceDescriptor,
        EmailSettingsHttpServiceV1);
  }
}
