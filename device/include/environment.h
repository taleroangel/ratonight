#ifndef _ENVIRONMENT_H_
#define _ENVIRONMENT_H_

#ifndef ENV_OK
#error "environment.ini file variables have not been imported!"
#endif

#ifndef ENV_DEVICE_NAME
#define ENV_DEVICE_NAME "MISSING-ENV"
#error "Missing environment variable ENV_DEVICE_NAME"
#endif

#ifndef ENV_SERVICES_AMBIENCE_UUID
#define ENV_SERVICES_AMBIENCE_UUID "MISSING-ENV"
#error "Missing environment variable ENV_SERVICES_AMBIENCE_UUID"
#endif

#ifndef ENV_SERVICES_AMBIENCE_TEMPERATURE_UUID
#define ENV_SERVICES_AMBIENCE_TEMPERATURE_UUID "MISSING-ENV"
#error "Missing environment variable ENV_SERVICES_AMBIENCE_TEMPERATURE_UUID"
#endif

#ifndef ENV_SERVICES_AMBIENCE_HUMIDITY_UUID
#define ENV_SERVICES_AMBIENCE_HUMIDITY_UUID "MISSING-ENV"
#error "Missing environment variable ENV_SERVICES_AMBIENCE_HUMIDITY_UUID"
#endif

#ifndef ENV_SERVICES_LIGHT_UUID
#define ENV_SERVICES_LIGHT_UUID "MISSING-ENV"
#error "Missing environment variable ENV_SERVICES_LIGHT_UUID"
#endif

#ifndef ENV_SERVICES_LIGHT_VALUE_UUID
#define ENV_SERVICES_LIGHT_VALUE_UUID "MISSING-ENV"
#error "Missing environment variable ENV_SERVICES_LIGHT_VALUE_UUID"
#endif

#ifndef ENV_SERVICES_DEBUG_UUID
#define ENV_SERVICES_DEBUG_UUID "MISSING-ENV"
#error "Missing environment variable ENV_SERVICES_DEBUG_UUID"
#endif

#ifndef ENV_SERVICES_DEBUG_FREE_HEAP_UUID
#define ENV_SERVICES_DEBUG_FREE_HEAP_UUID "MISSING-ENV"
#error "Missing environment variable ENV_SERVICES_DEBUG_FREE_HEAP_UUID"
#endif

#endif