#include "setup.hxx"

void setup()
{
	// Serial on debug mode
#ifdef DEBUG
	Serial.begin(SERIAL_BAUD_RATE);
	Logger.begin(&Serial, LoggingLevel::ALL);
	Logger.log<LoggingLevel::I>("LOGGER", "Logger is Running (DEBUG is ON)");
#endif
	/* 0. Peripheral initialization */
	// Initialize the memory
	Peripherals::preferences.begin(ENV_DEVICE_NAME);
	// Initialize DHT11 Peripheral
	Peripherals::dht_sensor.begin();
	Peripherals::light_control.set_color(
		Peripherals::preferences.getULong(LIGHT_STORE_NAME, INIT_VALUE));

	/* 1. BLE Initialization */
	// Initialize the Bluetooth device
	BLEDevice::init(ENV_DEVICE_NAME);

	// Create the Bluetooth server
	Bluetooth::server = std::unique_ptr<BLEServer>{BLEDevice::createServer()};
	Bluetooth::server->setCallbacks(&BluetoothCallback::on_server_callback);

	// Create the Bluetooth Profile
	Bluetooth::profile = std::unique_ptr<Bluetooth::Profile>{new Bluetooth::Profile{Bluetooth::server}};
	Bluetooth::profile->set_temperature_callback(&BluetoothCallback::on_ambience_temperature_callback);
	Bluetooth::profile->set_humidity_callback(&BluetoothCallback::on_ambience_humidity_callback);
	Bluetooth::profile->set_light_push_callback(&BluetoothCallback::on_light_push_callback);
	Bluetooth::profile->set_light_pull_callback(&BluetoothCallback::on_light_pull_callback);
#ifdef DEBUG
	Bluetooth::profile->set_free_heap_callback(&BluetoothCallback::on_debug_free_heap_callback);
	Bluetooth::profile->set_min_heap_callback(&BluetoothCallback::on_debug_min_heap_callback);
	Logger.log<LoggingLevel::D>("SETUP", "DEBUG property callback initialized");
#endif
	// Fill advertising data
	// Create the advertiser
	Bluetooth::advertising = std::unique_ptr<BLEAdvertising>{BLEDevice::getAdvertising()};
	// Register service into advertiser
	Bluetooth::advertising->setAppearance(Bluetooth::LIGHT_FIXTURE_CATEGORY);
	Bluetooth::advertising->addServiceUUID(ENV_DEVICE_UUID);

	// Start the advertisement
	BLEDevice::startAdvertising();

#ifdef DEBUG
	Logger.log<LoggingLevel::D>("SETUP", "Finished device initialization");
#endif
}

void loop()
{
}