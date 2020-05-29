import 'dart:async';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_clients_activities/pip_clients_activities.dart';
import 'package:pip_services_activities/pip_services_activities.dart';

import '../../src/data/version1/EmailSettingsV1.dart';
import '../../src/data/version1/EmailSettingsActivityTypeV1.dart';
import '../../src/persistence/IEmailSettingsPersistence.dart';
import './IEmailSettingsController.dart';
import './EmailSettingsCommandSet.dart';

class EmailSettingsController
    implements
        IEmailSettingsController,
        IConfigurable,
        IReferenceable,
        ICommandable {
  static final RegExp _emailRegex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  static final ConfigParams _defaultConfig = ConfigParams.fromTuples([
        'dependencies.persistence', 'pip-services-emailsettings:persistence:*:*:1.0',
        'dependencies.activities', 'pip-services-activities:client:*:*:1.0',
        'dependencies.msgtemplates', 'pip-services-msgtemplates:client:*:*:1.0',
        'dependencies.emaildelivery', 'pip-services-email:client:*:*:1.0',
        
        'message_templates.verify_email.subject', 'Verify email',
        'message_templates.verify_email.text', 'Verification code for {{email}} is {{ code }}.',

        'options.magic_code', null,
        'options.signature_length', 100,
        'options.verify_on_create', true,
        'options.verify_on_update', true
  ]);

  bool _verifyOnCreate = true;
  bool _verifyOnUpdate = true;
  num _expireTimeout = 24 * 60; // in minutes
  String _magicCode = '';
  ConfigParams _config = ConfigParams();

  DependencyResolver dependencyResolver =
      DependencyResolver(EmailSettingsController._defaultConfig);
  //MessageTemplatesResolverV1 _templatesResolver = MessageTemplatesResolverV1();
  final CompositeLogger _logger = CompositeLogger();
  IActivitiesClientV1 _activitiesClient;
  //IEmailClientV1 _emailClient;
  IEmailSettingsPersistence persistence;
  EmailSettingsCommandSet commandSet;

  /// Configures component by passing configuration parameters.
  ///
  /// - [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    config = config.setDefaults(EmailSettingsController._defaultConfig);
    dependencyResolver.configure(config);

    //_templatesResolver.configure(config);
    _logger.configure(config);

    _verifyOnCreate = config.getAsBooleanWithDefault('options.verify_on_create', _verifyOnCreate);
    _verifyOnUpdate = config.getAsBooleanWithDefault('options.verify_on_update', _verifyOnUpdate);
    _expireTimeout = config.getAsIntegerWithDefault('options.verify_expire_timeout', _expireTimeout);
    _magicCode = config.getAsStringWithDefault('options.magic_code', _magicCode);
        
    _config = config;    
  }

  /// Set references to component.
  ///
  /// - [references]    references parameters to be set.
  @override
  void setReferences(IReferences references) {
    _logger.setReferences(references);
    dependencyResolver.setReferences(references);
    //_templatesResolver.setReferences(references);

    persistence =
        dependencyResolver.getOneRequired<IEmailSettingsPersistence>('persistence');
    _activitiesClient =
        dependencyResolver.getOneOptional<IActivitiesClientV1>('activities');
    //_emailClient = this._dependencyResolver.getOneOptional<IEmailClientV1>('emaildelivery');        
  }

  /// Gets a command set.
  ///
  /// Return Command set
  @override
  CommandSet getCommandSet() {
    commandSet ??= EmailSettingsCommandSet(this);
    return commandSet;
  }

  EmailSettingsV1 _settingsToPublic(EmailSettingsV1 settings) {
    if (settings == null) return null;

    settings.ver_code = null;
    settings.ver_expire_time = null;
    return settings;
  }

  @override
  Future<List<EmailSettingsV1>> getSettingsByIds(
      String correlationId, List<String> recipientIds) async {
    var settings = await persistence.getListByIds(correlationId, recipientIds);
    var result;
    if (settings != null) {
      result = settings.map((s) => _settingsToPublic(s)).toList();
    }
    return result;
  }

  @override
  Future<EmailSettingsV1> getSettingsById(String correlationId, String recipientId) async {
    var settings = await persistence.getOneById(correlationId, recipientId);
    return _settingsToPublic(settings);
  }

  @override
  Future<EmailSettingsV1> getSettingsByEmail(String correlationId, String email) async {
    var settings = await persistence.getOneByEmail(correlationId, email);
    return _settingsToPublic(settings);
  }

  Future<EmailSettingsV1> _verifyAndSaveSettings(String correlationId, EmailSettingsV1 oldSettings, EmailSettingsV1 newSettings) async {
    var verify = false;

    // Check if verification is needed
    verify = (oldSettings == null && _verifyOnCreate) || (oldSettings.email != newSettings.email && _verifyOnUpdate);
    if (verify) {
      newSettings.verified = false;
      newSettings.ver_code = IdGenerator.nextShort();
      newSettings.ver_expire_time = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + _expireTimeout * 60000);
    }

    // Set new settings
    var data = await persistence.set(correlationId, newSettings);

    // Send verification if needed
    // Send verification message and do not wait
    if (verify) {
      _sendVerificationMessage(correlationId, newSettings);
    }
    
    return data;
  }

  void _sendVerificationMessage(String correlationId, EmailSettingsV1 newSettings) {
    // var template = _templatesResolver.resolve('verify_email');
    // var err;
    // if (template == null) {
    //   err = ConfigException(
    //                 correlationId, 
    //                 'MISSING_VERIFY_EMAIL',
    //                 'Message template "verify_email" is missing'
    //             );
    // }

    // if (err != null) {
    //   _logger.error(correlationId, err, 'Cannot find verify_email message template');
    //   return;
    // }

    // var message = EmailMessageV1(
    //   subject: template.subject,
    //   text: template.text,
    //   html: template.html
    // );

    // var recipient = EmailRecipientV1(
    //   id: newSettings.id,
    //   name: newSettings.name,
    //   email: newSettings.email,
    //   language: newSettings.language      
    // );

    // var parameters = ConfigParams.fromTuples([
    //             'code', newSettings.ver_code,
    //             'email', newSettings.email
    // ]);

    // if (_emailClient != null) {
    //   _emailClient.sendMessageToRecipient(correlationId, recipient, message, parameters);
    // }
  }

  void _logActivity(
      String correlationId, EmailSettingsV1 settings, String activityType) {
    if (_activitiesClient != null) {
      var activity = _activitiesClient.logPartyActivity(
          correlationId,
          PartyActivityV1(
              id: null,
              type: activityType,
              party: ReferenceV1(
                  id: settings.id, type: 'account', name: settings.name)));
      if (activity == null) {
        var err = BadRequestException(
            correlationId, 'NULL_ACTIVITY', 'Failed logPartyActivity');
        _logger.error(correlationId, err, 'Failed to log user activity');
      }
    }
  }

  @override
  Future<EmailSettingsV1> setSettings(
      String correlationId, EmailSettingsV1 settings) async {
    if (settings.id == null) {
      throw BadRequestException(correlationId, 'NO_RECIPIENT_ID', 'Missing recipient id');
    }

    if (settings.email == null) {
      throw BadRequestException(correlationId, 'NO_EMAIL', 'Missing email');
    }

    if (!EmailSettingsController._emailRegex.hasMatch(settings.email)) {
      var err = BadRequestException(correlationId, 'WRONG_EMAIL',
              'Invalid email ' + settings.email)
          .withDetails('login', settings.email);
      _logger.trace(correlationId, 'Settings is not valid %s', [err]);
      return null;
    }

    var newSettings = settings;
    newSettings.verified = false;
    newSettings.ver_code = null;
    newSettings.ver_expire_time = null;
    newSettings.subscriptions = newSettings.subscriptions ?? {};

    var oldSettings = EmailSettingsV1();
    oldSettings = await persistence.getOneById(correlationId, newSettings.id);

    // Override
    newSettings.verified = oldSettings.verified;
    newSettings.ver_code = oldSettings.ver_code;
    newSettings.ver_expire_time = oldSettings.ver_expire_time;

    // Verify and save settings
    return _verifyAndSaveSettings(correlationId, oldSettings, newSettings);
  }

  @override
  Future<EmailSettingsV1> setVerifiedSettings(
      String correlationId, EmailSettingsV1 settings) {
    if (settings.id == null) {
      throw BadRequestException(correlationId, 'NO_RECIPIENT_ID', 'Missing recipient id');
    }

    if (settings.email == null) {
      throw BadRequestException(correlationId, 'NO_EMAIL', 'Missing email');
    }

    if (!EmailSettingsController._emailRegex.hasMatch(settings.email)) {
      var err = BadRequestException(correlationId, 'WRONG_EMAIL',
              'Invalid email ' + settings.email)
          .withDetails('login', settings.email);
      _logger.trace(correlationId, 'Settings is not valid %s', [err]);
      return null;
    }

    var newSettings = settings;
    newSettings.verified = true;
    newSettings.ver_code = null;
    newSettings.ver_expire_time = null;
    newSettings.subscriptions = newSettings.subscriptions ?? {};

    return persistence.set(correlationId, newSettings);
  }

  @override
  Future<EmailSettingsV1> setRecipient(
      String correlationId, String recipientId, String name, String email, String language) async {
    if (recipientId == null) {
      throw BadRequestException(correlationId, 'NO_RECIPIENT_ID', 'Missing recipient id');
    }

    if (email == null) {
      throw BadRequestException(correlationId, 'NO_EMAIL', 'Missing email');
    }

    if (email != null && !EmailSettingsController._emailRegex.hasMatch(email)) {
      var err = BadRequestException(correlationId, 'WRONG_EMAIL',
              'Invalid email ' + email)
          .withDetails('login', email);
      _logger.trace(correlationId, 'Email is not valid %s', [err]);
      return null;
    }

    var oldSettings = EmailSettingsV1();
    var newSettings = EmailSettingsV1();

    // Get existing settings
    var data = await persistence.getOneById(correlationId, recipientId);
    if (data != null) {
      // Copy and modify existing settings
      oldSettings = data;
      newSettings = data;
      newSettings.name = name ?? data.name;
      newSettings.email = email ?? data.email;
      newSettings.language = language ?? data.language;
    }
    else {
      // Create new settings if they are not exist
      oldSettings = null;
      newSettings = EmailSettingsV1(
        id: recipientId,
        name: name,
        email: email,
        language: language
      );
    }

    // Verify and save settings
    return _verifyAndSaveSettings(correlationId, oldSettings, newSettings);
  }

  @override
  Future<EmailSettingsV1> setSubscriptions(
      String correlationId, String recipientId, dynamic subscriptions) async {
    if (recipientId == null) {
      throw BadRequestException(correlationId, 'NO_RECIPIENT_ID', 'Missing recipient id');
    }

    var oldSettings = EmailSettingsV1();
    var newSettings = EmailSettingsV1();

    // Get existing settings
    var data = await persistence.getOneById(correlationId, recipientId);
    if (data != null) {
      // Copy and modify existing settings
      oldSettings = data;
      newSettings = data;
      newSettings.subscriptions = subscriptions ?? data.subscriptions;
    }
    else {
      // Create new settings if they are not exist
      oldSettings = null;
      newSettings = EmailSettingsV1(
        id: recipientId,
        name: null,
        email: null,
        language: null,
        subscriptions: subscriptions
      );
    }

    // Verify and save settings
    return _verifyAndSaveSettings(correlationId, oldSettings, newSettings);
  }  

  @override
  Future<EmailSettingsV1> deleteSettingsById(String correlationId, String recipientId) {
    return persistence.deleteById(correlationId, recipientId);
  }

  @override
  Future resendVerification(
      String correlationId, String recipientId) async {
    if (recipientId == null) {
      throw BadRequestException(correlationId, 'NO_RECIPIENT_ID', 'Missing recipient id');
    }

    var settings = EmailSettingsV1();

    // Get existing settings
    var data = await persistence.getOneById(correlationId, recipientId);
    if (data == null) {
      throw NotFoundException(
                            correlationId, 
                            'RECIPIENT_NOT_FOUND', 
                            'Recipient ' + recipientId + ' was not found'
                        )
                        .withDetails('recipient_id', recipientId);
    }

    settings = data;
    // Check if verification is needed
    settings.verified = false;
    settings.ver_code = IdGenerator.nextShort();
    settings.ver_expire_time = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + _expireTimeout * 60000);

    // Set new settings
    data = await persistence.set(correlationId, settings);
    
    // Send verification
    _sendVerificationMessage(correlationId, settings);
  }

  @override
  Future verifyEmail(
      String correlationId, String recipientId, String code) async {

    var settings = EmailSettingsV1();

    // Get existing settings
    var data = await persistence.getOneById(correlationId, recipientId);
    if (data == null) {
      throw NotFoundException(
                            correlationId, 
                            'RECIPIENT_NOT_FOUND', 
                            'Recipient ' + recipientId + ' was not found'
                        )
                        .withDetails('recipient_id', recipientId);
    }

    settings = data;
    
    // Check and update verification code
    var verified = settings.ver_code == code;
    verified = verified || (_magicCode != null && code == _magicCode);
    verified = verified && DateTime.now().millisecondsSinceEpoch < DateTime.fromMillisecondsSinceEpoch(settings.ver_expire_time.millisecondsSinceEpoch).millisecondsSinceEpoch;

    if (!verified) {
      throw BadRequestException(
                            correlationId,
                            'INVALID_CODE',
                            'Invalid email verification code ' + code
                        )
                        .withDetails('recipient_id', recipientId)
                        .withDetails('code', code);
    }

    settings.verified = true;
    settings.ver_code = null;
    settings.ver_expire_time = null;

    // Save user
    data = await persistence.set(correlationId, settings);
    
    // Asynchronous post-processing
    _logActivity(
                    correlationId,
                    settings,
                    EmailSettingsActivityTypeV1.EmailVerified
                );
  }    
}
