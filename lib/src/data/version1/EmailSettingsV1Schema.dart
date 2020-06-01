import 'package:pip_services3_commons/pip_services3_commons.dart';

class EmailSettingsV1Schema extends ObjectSchema {
  EmailSettingsV1Schema() : super() {
    withRequiredProperty('id', TypeCode.String);
    withOptionalProperty('name', TypeCode.String);
    withOptionalProperty('email', TypeCode.String);
    withOptionalProperty('language', TypeCode.String);
    withOptionalProperty('subscriptions', TypeCode.Map);
    withOptionalProperty('verified', TypeCode.Boolean);
    withOptionalProperty('ver_code', TypeCode.String);
    withOptionalProperty('ver_expire_time', null); //TypeCode.DateTime
    withOptionalProperty('custom_hdr', null);
    withOptionalProperty('custom_dat', null);
  }
}
