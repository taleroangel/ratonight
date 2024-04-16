#ifndef __SETUP_HXX__
#define __SETUP_HXX__

/* --------- Imports --------- */

// Project Imports
#include "BluetoothProfile/BluetoothProfile.hxx"
#include "LightController/LightController.hxx"

// Global Imports
#include <environment.h>
#include <settings.h>
#include <pinout.hxx>

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
	DHT dht_sensor{pinout::dht_data, DHT11};
	/// @brief	FastLED control of LEDs
	LightController light_control{};
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
			Logger.log<Level::I>("BLE", "Device connected");
#endif
		};

		void onDisconnect(BLEServer *pServer) override
		{
			pServer->startAdvertising();
#ifdef DEBUG
			Logger.log<Level::I>("BLE", "Device disconnected");
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
			Logger.log<Level::D>("AMBIENCE", "Requested temperature value read");
			Logger.log<Level::I>("AMBIENCE", temperature);
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
			Logger.log<Level::D>("AMBIENCE", "Requested humidity value read");
			Logger.log<Level::I>("AMBIENCE", humidity);
#endif
		}
	} on_ambience_humidity_callback;

	/**
	 * Callback to call when a Light value is pushed
	 */
	class OnLightPushCallback : public BLECharacteristicCallbacks
	{
		void onWrite(BLECharacteristic *pCharacteristic) override
		{
			// Interpret the data into color
			uint32_t data_value = 0U;
			for (size_t i = 0; i < pCharacteristic->getLength(); i++)
				data_value |= pCharacteristic->getData()[i] << (8 * i);
#ifdef DEBUG
			Logger.log<Level::D>("LIGHT", "Pushed value");
			Logger.log<Level::I>("LIGHT", data_value);
			Logger.log<Level::I>("PREFERENCES", "Stored new value");
#endif
			// Set the color data
			Peripherals::light_control.set_color(data_value);

			// Store contents in preferences
			uint8_t colors[LIGHT_COLOR_BYTES_SIZE];
			Peripherals::light_control.get_color(colors);
			Peripherals::preferences.putBytes(
				LIGHT_STORE_NAME,
				static_cast<const void *>(colors),
				LIGHT_COLOR_BYTES_SIZE);
		}
	} on_light_push_callback;

	/**
	 * Callback to call when a Light value is pulled
	 */
	class OnLightPullCallback : public BLECharacteristicCallbacks
	{
		void onRead(BLECharacteristic *pCharacteristic) override
		{
			// Grab the color
			uint8_t colors[LIGHT_COLOR_BYTES_SIZE];
			Peripherals::light_control.get_color(colors);
#ifdef DEBUG
			Logger.log<Level::D>("LIGHT", "Pulled value");
#endif
			// Set the color data
			pCharacteristic->setValue(colors, LIGHT_COLOR_BYTES_SIZE);
		}
	} on_light_pull_callback;

#ifdef DEBUG
	class OnDebugFreeHeapCallback : public BLECharacteristicCallbacks
	{
		void onRead(BLECharacteristic *pCharacteristic) override
		{
			// Read minimum free heap
			uint32_t free_heap = ESP.getFreeHeap();
			// Store the value
			pCharacteristic->setValue(free_heap);
			// Logger value
			Logger.log<Level::D>("FREE_HEAP", free_heap);
		}
	} on_debug_free_heap_callback;

	class OnDebugMinHeapCallback : public BLECharacteristicCallbacks
	{
		void onRead(BLECharacteristic *pCharacteristic) override
		{
			// Read minimum free heap
			uint32_t min_heap = ESP.getMinFreeHeap();
			// Store the value
			pCharacteristic->setValue(min_heap);
			// Logger value
			Logger.log<Level::D>("MIN_HEAP", min_heap);
		}
	} on_debug_min_heap_callback;
#endif
}

#endif