import 'dart:async';
import 'package:pip_services3_data/pip_services3_data.dart';
import '../data/version1/EmailSettingsV1.dart';
import './IEmailSettingsPersistence.dart';

class EmailSettingsMemoryPersistence
    extends IdentifiableMemoryPersistence<EmailSettingsV1, String>
    implements IEmailSettingsPersistence {
  EmailSettingsMemoryPersistence() : super() {
    maxPageSize = 1000;
  }

  @override
  Future<EmailSettingsV1> getOneByEmail(String correlationId, String email) async {
    var item =
        items.isNotEmpty ? items.where((item) => item.email == email) : null;

    if (item != null && item.isNotEmpty && item.first != null) {
      logger.trace(correlationId, 'Found EmailSettings by %s', [email]);
    } else {
      logger.trace(correlationId, 'Cannot find EmailSettings by %s', [email]);
    }

    if (item != null && item.isNotEmpty && item.first != null) {
      return item.first;
    } else {
      return null;
    }
  }
}
