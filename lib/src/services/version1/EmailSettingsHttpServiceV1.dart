import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

class EmailSettingsHttpServiceV1 extends CommandableHttpService {
  EmailSettingsHttpServiceV1() : super('v1/email_settings') {
    dependencyResolver.put(
        'controller',
        Descriptor(
            'pip-services-emailsettings', 'controller', '*', '*', '1.0'));
  }
}
