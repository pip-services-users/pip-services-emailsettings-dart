import 'dart:async';
import '../data/version1/EmailSettingsV1.dart';

abstract class IEmailSettingsPersistence {
  Future<List<EmailSettingsV1>> getListByIds(
      String correlationId, List<String> ids);

  Future<EmailSettingsV1> getOneById(String correlationId, String id);

  Future<EmailSettingsV1> getOneByEmail(String correlationId, String email);

  Future<EmailSettingsV1> set(String correlationId, EmailSettingsV1 item);

  Future<EmailSettingsV1> deleteById(String correlationId, String id);
}
