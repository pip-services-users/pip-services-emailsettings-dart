import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../../src/data/version1/EmailSettingsV1Schema.dart';
import '../../src/logic/IEmailSettingsController.dart';
import '../../src/data/version1/EmailSettingsV1.dart';

class EmailSettingsCommandSet extends CommandSet {
  IEmailSettingsController _controller;

  EmailSettingsCommandSet(IEmailSettingsController controller) : super() {
    _controller = controller;

    addCommand(_makeGetSettingsByIdsCommand());
    addCommand(_makeGetSettingsByIdCommand());
    addCommand(_makeGetSettingsByEmailCommand());
    addCommand(_makeSetSettingsCommand());
    addCommand(_makeSetVerifiedSettingsCommand());
    addCommand(_makeSetRecipientCommand());
    addCommand(_makeSetSubscriptionsCommand());
    addCommand(_makeDeleteSettingsByIdCommand());
    addCommand(_makeResendVerificationCommand());
    addCommand(_makeVerifyEmailCommand());
  }

  ICommand _makeGetSettingsByIdsCommand() {
    return Command(
        'get_settings_by_ids',
        ObjectSchema(true).withRequiredProperty(
            'recipient_ids', ArraySchema(TypeCode.String)),
        (String correlationId, Parameters args) {
      var recipientIds = List<String>.from(args.get('recipient_ids'));
      return _controller.getSettingsByIds(correlationId, recipientIds);
    });
  }

  ICommand _makeGetSettingsByIdCommand() {
    return Command(
        'get_settings_by_id',
        ObjectSchema(true)
            .withRequiredProperty('recipient_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var recipientId = args.getAsNullableString('recipient_id');
      return _controller.getSettingsById(correlationId, recipientId);
    });
  }

  ICommand _makeGetSettingsByEmailCommand() {
    return Command('get_settings_by_email',
        ObjectSchema(true).withRequiredProperty('email', TypeCode.String),
        (String correlationId, Parameters args) {
      var email = args.getAsString('email');
      return _controller.getSettingsByEmail(correlationId, email);
    });
  }

  ICommand _makeSetSettingsCommand() {
    return Command(
        'set_settings',
        ObjectSchema(true)
            .withRequiredProperty('settings', EmailSettingsV1Schema()),
        (String correlationId, Parameters args) {
      var settings = EmailSettingsV1();
      settings.fromJson(args.get('settings'));
      return _controller.setSettings(correlationId, settings);
    });
  }

  ICommand _makeSetVerifiedSettingsCommand() {
    return Command(
        'set_verified_settings',
        ObjectSchema(true)
            .withRequiredProperty('settings', EmailSettingsV1Schema()),
        (String correlationId, Parameters args) {
      var settings = EmailSettingsV1();
      settings.fromJson(args.get('settings'));
      return _controller.setVerifiedSettings(correlationId, settings);
    });
  }

  ICommand _makeSetRecipientCommand() {
    return Command(
        'set_recipient',
        ObjectSchema(true)
            .withRequiredProperty('recipient_id', TypeCode.String)
            .withOptionalProperty('name', TypeCode.String)
            .withOptionalProperty('email', TypeCode.String)
            .withOptionalProperty('language', TypeCode.String),
        (String correlationId, Parameters args) {
      var recipientId = args.getAsString('recipient_id');
      var name = args.getAsString('name');
      var email = args.getAsString('email');
      var language = args.getAsString('language');
      return _controller.setRecipient(
          correlationId, recipientId, name, email, language);
    });
  }

  ICommand _makeSetSubscriptionsCommand() {
    return Command(
        'set_subscriptions',
        ObjectSchema(true)
            .withRequiredProperty('recipient_id', TypeCode.String)
            .withRequiredProperty('subscriptions', TypeCode.Map),
        (String correlationId, Parameters args) {
      var recipientId = args.getAsString('recipient_id');
      var subscriptions = args.get('subscriptions');
      return _controller.setSubscriptions(
          correlationId, recipientId, subscriptions);
    });
  }

  ICommand _makeDeleteSettingsByIdCommand() {
    return Command(
        'delete_settings_by_id',
        ObjectSchema(true)
            .withRequiredProperty('recipient_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var recipientId = args.getAsNullableString('recipient_id');
      return _controller.deleteSettingsById(correlationId, recipientId);
    });
  }

  ICommand _makeResendVerificationCommand() {
    return Command('resend_verification', ObjectSchema(),
        (String correlationId, Parameters args) {
      var recipientId = args.getAsString('recipient_id');
      return _controller.resendVerification(correlationId, recipientId);
    });
  }

  ICommand _makeVerifyEmailCommand() {
    return Command(
        'verify_email',
        ObjectSchema(true)
            .withRequiredProperty('recipient_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var recipientId = args.getAsString('recipient_id');
      var code = args.getAsString('code');
      return _controller.verifyEmail(correlationId, recipientId, code);
    });
  }
}
