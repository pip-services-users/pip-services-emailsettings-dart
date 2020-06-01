# HTTP REST Protocol (version 1) <br> Email Settings Microservice

Email settings microservice implements a REST compatible API, that can be accessed on configured port.
All input and output data is serialized in JSON format. Errors are returned in [standard format]().

* [EmailSettingsV1 class](#class1)
* [POST /email_settings/get_settings_by_id](#operation1)
* [POST /email_settings/get_settings_by_email](#operation2)
* [POST /email_settings/set_settings](#operation3)
* [POST /email_settings/set_recipient](#operation4)
* [POST /email_settings/set_subscriptions](#operation5)
* [POST /email_settings/delete_settings_by_id](#operation6)
* [POST /email_settings/resend_verification](#operation7)
* [POST /email_settings/verify_email](#operation8)

## Data types

### <a name="class1"></a> EmailSettingsV1 class

Represents a user email settings with his ID, primary email and key settings.

**Properties:**
- id: string - unique user id
- name: string - user full name
- email: string - primary user email
- language: string - user preferred language
- verified: boolean - true if email was verified
- ver_code: - email verification code that was sent in email message to the user
- ver\_expire\_time: Date - expiration time for email verification code
- subscriptions: Object - subscriptions to enable or disable certain types of email messages
- custom_hdr: Object - custom data summary that is always returned (in list and details)
- custom_dat: Object - custom data details that is returned only when a single object is returned (details)

## Operations

### <a name="operation1"></a> Method: 'POST', route '/email\_settings/get\_settings\_by_id'

Retrieves email settings by recipient unique id. 

**Request body:** 
- recipient_id: string - unique receipient id

**Response body:**
Retrieved EmailSettingsV1 object or error

### <a name="operation2"></a> Method: 'POST', route '/email\_settings/get\_settings\_by_email'

Retrieves email settings by recipient email. 

**Request body:** 
- email: string - email address

**Response body:**
Retrieved EmailSettingsV1 object or error

### <a name="operation3"></a> Method: 'POST', route '/email\_settings/set_settings'

Sets recipient email settings

**Request body:** 
- settings: EmailSettingsV1 -  email settings to be set

**Response body:**
Set EmailSettingsV1 object or error

### <a name="operation4"></a> Method: 'POST', route '/email\_settings/set_recipient'

Sets recipient information into email settings.
If some properties are not set, they keep their old values.

**Request body:** 
- recipient_id: string - recipient unique id
- name: string - recipient full name
- email: string - recipient email address
- language: string - recipient preferred language

**Response body:**
Set EmailSettingsV1 object or error

### <a name="operation5"></a> Method: 'POST', route '/email\_settings/set_subscriptions'

Sets subscriptions to specific email types.

**Request body:** 
- recipient_id: string - recipient unique id
- subscriptions: any - subscriptions hashmap where email types are enabled or disabled

**Response body:**
Set EmailSettingsV1 object or error

### <a name="operation6"></a> Method: 'POST', route '/email\_settings/delete\_settings\_by_id'

Deletes email settings from the system (use it carefully!)

**Request body:** 
- recipient_id: string - recipient unique id

**Response body:**
Error or null for success

### <a name="operation6"></a> Method: 'POST', route '/email\_settings/resend\_verification'

Generates a new email verification code and sends it to recipient via email message.
Initial verification code is send in welcome message during user registration.

**Request body:** 
- recipient_id: string - recipient unique id

**Response body:**
Error or null for success

### <a name="operation7"></a> Method: 'POST', route '/email\_settings/verify'

Confirms (verifies) primary email address using verification code.

**Request body:** 
- recipient_id: string - recipient unique id
- code: string - password recovery code

**Response body:**
Error or null for success
