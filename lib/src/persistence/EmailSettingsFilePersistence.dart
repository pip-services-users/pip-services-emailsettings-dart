import 'package:pip_services3_data/pip_services3_data.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../data/version1/EmailSettingsV1.dart';
import './EmailSettingsMemoryPersistence.dart';

class EmailSettingsFilePersistence extends EmailSettingsMemoryPersistence {
  JsonFilePersister<EmailSettingsV1> persister;

  EmailSettingsFilePersistence([String path]) : super() {
    persister = JsonFilePersister<EmailSettingsV1>(path);
    loader = persister;
    saver = persister;
  }
  @override
  void configure(ConfigParams config) {
    super.configure(config);
    persister.configure(config);
  }
}
