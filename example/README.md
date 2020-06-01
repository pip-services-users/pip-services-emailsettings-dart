# Examples for Email Settings Microservice

This is a email settings microservice from Pip.Services library. 
This microservice keeps settings of email recipients.

Define configuration parameters that match the configuration of the microservice's external API
```dart
// Service/Client configuration
var httpConfig = ConfigParams.fromTuples(
	"connection.protocol", "http",
	"connection.host", "localhost",
	"connection.port", 8080
);
```

Instantiate the service
```dart
persistence = EmailSettingsMemoryPersistence();
persistence.configure(ConfigParams());

controller = EmailSettingsController();
controller.configure(ConfigParams());

service = EmailSettingsHttpServiceV1();
service.configure(httpConfig);

var references = References.fromTuples([
    Descriptor('pip-services-emailsettings', 'persistence', 'memory',
        'default', '1.0'),
    persistence,
    Descriptor('pip-services-emailsettings', 'controller', 'default',
        'default', '1.0'),
    controller,
    Descriptor(
        'pip-services-emailsettings', 'service', 'http', 'default', '1.0'),
    service
]);

controller.setReferences(references);
service.setReferences(references);

await persistence.open(null);
await service.open(null);
```

Instantiate the client and open connection to the microservice
```dart
// Create the client instance
var client = EmailSettingsHttpClientV1(config);

// Configure the client
client.configure(httpConfig);

// Connect to the microservice
try{
  await client.open(null)
}catch() {
  // Error handling...
}       
// Work with the microservice
// ...
```

Now the client is ready to perform operations
```dart
// Create a new settings
final SETTINGS = EmailSettingsV1(
    id: '1',
    name: 'User 1',
    email: 'somebody@somewhere.com',
    language: 'en',
    verified: false);

    // Create the settings
    try {
      var settings = await client.setSettings('123', SETTINGS);
      // Do something with the returned settings...
    } catch(err) {
      // Error handling...     
    }
```

```dart
// Get the settings
try {
var settings = await client.getSettingsByEmail(
    null,
    'somebody@somewhere.com');
    // Do something with settings...

    } catch(err) { // Error handling}
```

```dart
// Verify an email
try {
    settings1 = SETTINGS;
    settings1.ver_code = '123';  
    await controller.verifyEmail(null, '1', '123');

    var settings = await client.getSettingsByEmail(
    null,
    'somebody@somewhere.com');
    // Do something with settings...

    } catch(err) { // Error handling}
``` 

In the help for each class there is a general example of its use. Also one of the quality sources
are the source code for the [**tests**](https://github.com/pip-services-users/pip-services-emailsettings-dart/tree/master/test).
