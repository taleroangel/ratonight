#include <environment.h>
#include "BluetoothProfile.hxx"

using namespace Bluetooth;

Profile::Profile(std::unique_ptr<BLEServer> &pServer)
	: // Ambience service creation
	  ambience_service{pServer->createService(ENV_SERVICES_AMBIENCE_UUID)},

	  // Ambiente temperature
	  ambience_temperature{ambience_service->createCharacteristic(
		  ENV_SERVICES_AMBIENCE_TEMPERATURE_UUID,
		  BLECharacteristic::PROPERTY_READ)},
	  ambience_temperature_description{new BLE2904()},

	  // Ambience humidity
	  ambience_humidity{ambience_service->createCharacteristic(
		  ENV_SERVICES_AMBIENCE_HUMIDITY_UUID,
		  BLECharacteristic::PROPERTY_READ)},
	  ambience_humidity_description{new BLE2904()},

	  // Light service
	  light_service{pServer->createService(ENV_SERVICES_LIGHT_UUID)},

	  light_push{light_service->createCharacteristic(
		  ENV_SERVICES_LIGHT_PUSH_UUID,
		  BLECharacteristic::PROPERTY_WRITE)},
	  light_push_description{new BLE2904()},

	  light_pull{light_service->createCharacteristic(
		  ENV_SERVICES_LIGHT_PULL_UUID,
		  BLECharacteristic::PROPERTY_READ)},
	  light_pull_description{new BLE2904()}

#ifdef DEBUG
	  ,
	  debug_service{pServer->createService(ENV_SERVICES_DEBUG_UUID)},
	  debug_free_heap{debug_service->createCharacteristic(
		  ENV_SERVICES_DEBUG_FREE_HEAP_UUID,
		  BLECharacteristic::PROPERTY_READ)},
	  debug_free_heap_description{new BLE2904()},

	  debug_min_heap{debug_service->createCharacteristic(
		  ENV_SERVICES_DEBUG_MIN_HEAP_UUID,
		  BLECharacteristic::PROPERTY_READ)},
	  debug_min_heap_description{new BLE2904()}
#endif
{
	/* -- 1. Ambience service -- */
	// Start the service
	ambience_service->start();

	/* -- 1.1 Temperature  -- */
	// Temperature in degrees Celsius
	ambience_temperature_description->setUnit(TEMP_UNIT_CELSIUS);
	ambience_temperature_description->setFormat(BLE2904::FORMAT_FLOAT32);
	ambience_temperature->addDescriptor(ambience_temperature_description.get());

	/* -- 1.2 Humidity  -- */
	// Humidity in percentage
	ambience_humidity_description->setUnit(HUMD_UNIT_PERCENTAGE);
	ambience_humidity_description->setFormat(BLE2904::FORMAT_FLOAT32);
	ambience_humidity->addDescriptor(ambience_humidity_description.get());

	/* -- 2. Light service -- */
	light_service->start();

	light_push_description->setUnit(NO_UNIT);
	light_push_description->setFormat(BLE2904::FORMAT_UINT32);
	light_push->addDescriptor(light_push_description.get());

	light_pull_description->setUnit(NO_UNIT);
	light_pull_description->setFormat(BLE2904::FORMAT_UINT8);
	light_pull->addDescriptor(light_pull_description.get());

#ifdef DEBUG
	debug_service->start();

	debug_free_heap_description->setUnit(NO_UNIT);
	debug_free_heap_description->setFormat(BLE2904::FORMAT_UINT32);
	debug_free_heap->addDescriptor(debug_free_heap_description.get());

	debug_min_heap_description->setUnit(NO_UNIT);
	debug_min_heap_description->setFormat(BLE2904::FORMAT_UINT32);
	debug_min_heap->addDescriptor(debug_min_heap_description.get());
#endif
}

void Profile::set_temperature_callback(BLECharacteristicCallbacks *callback)
{
	return this->ambience_temperature->setCallbacks(callback);
}

void Profile::set_humidity_callback(BLECharacteristicCallbacks *callback)
{
	return this->ambience_humidity->setCallbacks(callback);
}

void Profile::set_light_push_callback(BLECharacteristicCallbacks *callback)
{
	return this->light_push->setCallbacks(callback);
}

void Profile::set_light_pull_callback(BLECharacteristicCallbacks *callback)
{
	return this->light_pull->setCallbacks(callback);
}

#ifdef DEBUG
void Profile::set_free_heap_callback(BLECharacteristicCallbacks *callback)
{
	return this->debug_free_heap->setCallbacks(callback);
}

void Profile::set_min_heap_callback(BLECharacteristicCallbacks *callback)
{
	return this->debug_min_heap->setCallbacks(callback);
}
#endif
