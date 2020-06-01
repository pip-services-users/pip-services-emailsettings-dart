# Configuration Guide <br> Email Settings Microservice

Configuration structure used by this module follows the 
[standard configuration] https://github.com/pip-services/pip-services/blob/master/usage/Configuration.md 
structure.

Example **config.yml** file:

```yaml
---
# Container descriptor
- descriptor: "pip-services:context-info:default:default:1.0"
  name: "pip-services-emailsettings"
  description: "Email settings microservice for pip-services"

# Console logger
- descriptor: "pip-services:logger:console:default:1.0"
  level: "trace"

# Performance counters that posts values to log
- descriptor: "pip-services:counters:log:default:1.0"
  level: "trace"

{{#MEMORY_ENABLED}}
# In-memory persistence. Use only for testing!
- descriptor: "pip-services-emailsettings:persistence:memory:default:1.0"
{{/MEMORY_ENABLED}}

{{#FILE_ENABLED}}
# File persistence. Use it for testing of for simple standalone deployments
- descriptor: "pip-services-emailsettings:persistence:file:default:1.0"
  path: {{FILE_PATH}}{{^FILE_PATH}}"./data/email_settings.json"{{/FILE_PATH}}
{{/FILE_ENABLED}}

{{#MONGO_ENABLED}}
# MongoDB Persistence
- descriptor: "pip-services-emailsettings:persistence:mongodb:default:1.0"
  collection: {{MONGO_COLLECTION}}{{^MONGO_COLLECTION}}emailsettings{{/MONGO_COLLECTION}}
  connection:
    uri: {{{MONGO_SERVICE_URI}}}
    host: {{{MONGO_SERVICE_HOST}}}{{^MONGO_SERVICE_HOST}}localhost{{/MONGO_SERVICE_HOST}}
    port: {{MONGO_SERVICE_PORT}}{{^MONGO_SERVICE_PORT}}27017{{/MONGO_SERVICE_PORT}}
    database: {{MONGO_DB}}{{#^MONGO_DB}}app{{/^MONGO_DB}}
  credential:
    username: {{MONGO_USER}}
    password: {{MONGO_PASS}}
{{/MONGO_ENABLED}}

{{^MEMORY_ENABLED}}{{^FILE_ENABLED}}{{^MONGO_ENABLED}}
# Default in-memory persistence
- descriptor: "pip-services-emailsettings:persistence:memory:default:1.0"
{{/MONGO_ENABLED}}{{/FILE_ENABLED}}{{/MEMORY_ENABLED}}

{{#EMAIL_ENABLED}}
# Email client
- descriptor: "pip-services-email:client:http:default:1.0"
  connection:
    protocol: "http"
    host: {{EMAIL_SERVICE_HOST}}
    port: {{EMAIL_SERVICE_PORT}}
{{/EMAIL_ENABLED}}    

{{#ACTIVITIES_ENABLED}}
# Activities client
- descriptor: "pip-services-activities:client:http:default:1.0"
  connection:
    protocol: "http"
    host: {{ACTIVITIES_SERVICE_HOST}}
    port: {{ACTIVITIES_SERVICE_PORT}}
{{/ACTIVITIES_ENABLED}}

{{#MESSAGE_TEMPLATES_ENABLED}}
# Message templates client
- descriptor: "pip-services-msgtemplates:client:http:default:1.0"
  connection:
    protocol: "http"
    host: {{MESSAGE_TEMPLATES_SERVICE_HOST}}
    port: {{MESSAGE_TEMPLATES_SERVICE_PORT}}
{{/MESSAGE_TEMPLATES_ENABLED}}

# Default controller
- descriptor: "pip-services-emailsettings:controller:default:default:1.0"
  options:
    magic_code: {{MAGIC_CODE}}{{#^MAGIC_CODE}}'123'{{/^MAGIC_CODE}}
    verify_on_create: {{VERIFY_ON_CREATE}}{{#^VERIFY_ON_CREATE}}true{{/^VERIFY_ON_CREATE}}
    verify_on_update: {{VERIFY_ON_UPDATE}}{{#^VERIFY_ON_UPDATE}}true{{/^VERIFY_ON_UPDATE}}

# Common HTTP endpoint
- descriptor: "pip-services:endpoint:http:default:1.0"
  connection:
    protocol: "http"
    host: "0.0.0.0"
    port: 8080

# HTTP endpoint version 1.0
- descriptor: "pip-services-emailsettings:service:http:default:1.0"

# Heartbeat service
- descriptor: "pip-services:heartbeat-service:http:default:1.0"

# Status service
- descriptor: "pip-services:status-service:http:default:1.0"