import 'package:pip_services_emailsettings/pip_services_emailsettings.dart';

void main(List<String> argument) {
  try {
    var proc = EmailSettingsProcess();
    proc.configPath = './config/config.yml';
    proc.run(argument);
  } catch (ex) {
    print(ex);
  }
}
