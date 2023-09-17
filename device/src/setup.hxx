#ifndef __SETUP_HXX__
#define __SETUP_HXX__

/* --------- Imports --------- */

// Project Imports
#include "BluetoothProfile/BluetoothProfile.hxx"
#include "LightController/LightController.hxx"

// Global Imports
#include <environment.h>
#include <settings.h>

// Libraries
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEAdvertising.h>
#include <Preferences.h>
#include <Ticker.h>
#include <DHT.h>

#ifdef DEBUG
#include <Logger.h>
#endif

// C++ STD
#include <memory>
#include <cstdint>

#define LIGHT_STORE_NAME "light"

/* --------- Global Variables --------- */

namespace Peripherals
{
	/// @brief Across reboots preferences
	Preferences preferences;
	/// @brief  DHT11 Sensor peripheral
	DHT dht_sensor{GPIO_NUM_4, DHT11};
	/// @brief	FastLED control of LEDs
	LightController<GPIO_NUM_5> light_control{};
}

namespace Bluetooth
{
	std::unique_ptr<BLEServer> server;
	std::unique_ptr<BLEAdvertising> advertising;
	std::unique_ptr<Profile> profile;
}

namespace BluetoothCallback
{
	/**
	 * Server connection callback
	 */
	class OnServerCallback : public BLEServerCallbacks
	{
		void onConnect(BLEServer *pServer) override
		{
#ifdef DEBUG
			Logger.log<LoggingLevel::I>("BLE", "Device connected");
#endif
		};

		void onDisconnect(BLEServer *pServer) override
		{
			pServer->startAdvertising();
			Peripherals::preferences.putULong(
				LIGHT_STORE_NAME,
				static_cast<uint32_t>(Peripherals::light_control.get_color()));
#ifdef DEBUG
			Logger.log<LoggingLevel::I>("BLE", "Device disconnected");
			Logger.log<LoggingLevel::I>("PREFERENCES", "Stored new value");
#endif
		}
	} on_server_callback;

	/**
	 * Callback to call when temperature is checked
	 */
	class OnAmbienceTemperatureCallback : public BLECharacteristicCallbacks
	{
		void onRead(BLECharacteristic *pCharacteristic) override
		{
			float temperature = Peripherals::dht_sensor.readTemperature();
			pCharacteristic->setValue(temperature);
#ifdef DEBUG
			Logger.log<LoggingLevel::D>("AMBIENCE", "Requested temperature value read");
			Logger.log<LoggingLevel::I>("AMBIENCE", temperature);
#endif
		}
	} on_ambience_temperature_callback;

	/**
	 * Callback to call when humidity is checked
	 */
	class OnAmbienceHumidityCallback : public BLECharacteristicCallbacks
	{
		void onRead(BLECharacteristic *pCharacteristic) override
		{
			float humidity = Peripherals::dht_sensor.readHumidity();
			pCharacteristic->setValue(humidity);
#ifdef DEBUG
			Logger.log<LoggingLevel::D>("AMBIENCE", "Requested humidity value read");
			Logger.log<LoggingLevel::I>("AMBIENCE", humidity);
#endif
		}
	} on_ambience_humidity_callback;

	/**
	 * Callback to call when a Light value is pushed
	 */
	class OnLightCallback : public BLECharacteristicCallbacks
	{
		void onWrite(BLECharacteristic *pCharacteristic) override
		{
			// Interpret the data into color
			uint32_t data_value = 0U;
			for (size_t i = 0; i < pCharacteristic->getLength(); i++)
				data_value |= pCharacteristic->getData()[i] << (8 * i);
#ifdef DEBUG
			Logger.log<LoggingLevel::D>("LIGHT", "Pushed value");
			Logger.log<LoggingLevel::I>("LIGHT", data_value);
#endif
			// Set the color data
			Peripherals::light_control.set_color(data_value);
		}
	} on_light_callback;

#ifdef DEBUG
	class OnDebugFreeHeapCallback : public BLECharacteristicCallbacks
	{
		void onRead(BLECharacteristic *pCharacteristic) override
		{
			// Read minimum free heap
			uint32_t free_heap = ESP.getMinFreeHeap();
			// Store the value
			pCharacteristic->setValue(free_heap);
			// Logger value
			Logger.log<LoggingLevel::D>("MIN_FREE_HEAP", free_heap);
		}
	} on_debug_free_heap_callback;
#endif
}

#endif