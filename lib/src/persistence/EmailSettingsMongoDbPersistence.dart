import 'dart:async';
import 'package:mongo_dart_query/mongo_dart_query.dart' as mngquery;
import 'package:pip_services3_mongodb/pip_services3_mongodb.dart';

import '../data/version1/EmailSettingsV1.dart';
import './IEmailSettingsPersistence.dart';

class EmailSettingsMongoDbPersistence
    extends IdentifiableMongoDbPersistence<EmailSettingsV1, String>
    implements IEmailSettingsPersistence {
  EmailSettingsMongoDbPersistence() : super('email_settings') {
    maxPageSize = 1000;
  }

  @override
  Future<EmailSettingsV1> getOneByEmail(String correlationId, String email) async {
    var filter = {'email': email};
    var query = mngquery.SelectorBuilder();
    var selector = <String, dynamic>{};
    if (filter != null && filter.isNotEmpty) {
      selector[r'$query'] = filter;
    }
    query.raw(selector);

    var item = await collection.findOne(filter);

    if (item == null) {
      logger.trace(correlationId, 'Nothing found from %s with login = %s',
          [collectionName, email]);
      return null;
    }
    logger.trace(correlationId, 'Retrieved from %s with login = %s',
        [collectionName, email]);
    return convertToPublic(item);
  }
}
