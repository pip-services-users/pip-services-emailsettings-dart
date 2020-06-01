import 'dart:async';
import '../../src/data/version1/EmailSettingsV1.dart';

abstract class IEmailSettingsController {
  /// Gets a list of email settings retrieved by a ids.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [recipientIds]            a recipient ids to get settings
  /// Return         Future that receives a data list
  /// Throws error.
  Future<List<EmailSettingsV1>> getSettingsByIds(
      String correlationId, List<String> recipientIds);

  /// Gets an email settings by recipient id.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of settings to be retrieved.
  /// Return         Future that receives email settings or error.
  Future<EmailSettingsV1> getSettingsById(
      String correlationId, String recipientId);

  /// Gets an email settings by its email.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [email]                an email of email settings to be retrieved.
  /// Return         Future that receives email settings or error.
  Future<EmailSettingsV1> getSettingsByEmail(
      String correlationId, String email);

  /// Sets an email settings.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [settings]              an email settings to be set.
  /// Return         (optional) Future that receives set email settings or error.
  Future<EmailSettingsV1> setSettings(
      String correlationId, EmailSettingsV1 settings);

  /// Sets a verified email settings.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [settings]              an email settings to be set.
  /// Return         (optional) Future that receives set verified email settings or error.
  Future<EmailSettingsV1> setVerifiedSettings(
      String correlationId, EmailSettingsV1 settings);

  /// Sets a recipient info into email settings.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of settings to be retrieved.
  /// - [name]                a recipient name of settings to be set.
  /// - [email]                a recipient email of settings to be set.
  /// - [language]                a recipient language of settings to be set.
  /// Return         (optional) Future that receives updated email settings
  /// Throws error.
  Future<EmailSettingsV1> setRecipient(String correlationId, String recipientId,
      String name, String email, String language);

  /// Sets a subscriptions into email settings.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of settings to be retrieved.
  /// - [subscriptions]                a subscriptions to be set.
  /// Return         (optional) Future that receives updated email settings
  /// Throws error.
  Future<EmailSettingsV1> setSubscriptions(
      String correlationId, String recipientId, dynamic subscriptions);

  /// Deleted an email settings by recipient id.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of the email settings to be deleted
  /// Return                Future that receives deleted email settings
  /// Throws error.
  Future<EmailSettingsV1> deleteSettingsById(
      String correlationId, String recipientId);

  /// Resends verification.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of the email settings to be resend verification
  /// Return                Future that receives null for success.
  /// Throws error.
  Future resendVerification(String correlationId, String recipientId);

  /// Verifies an email.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of the email settings to be verified email
  /// - [code]                a verification code for verifying email
  /// Return                Future that receives null for success.
  /// Throws error.
  Future verifyEmail(String correlationId, String recipientId, String code);
}
