#ifndef __BLUETOOTH_PROFILE_HXX__
#define __BLUETOOTH_PROFILE_HXX__

#include <memory>
#include <cstdint>

#include <BLEServer.h>
#include <BLEService.h>
#include <BLECharacteristic.h>
#include <BLE2904.h>

/**
 * Bluetooth LE configuration and definitions
 */
namespace Bluetooth
{
	constexpr uint16_t TEMP_UNIT_CELSIUS = 0x272FU;
	constexpr uint16_t HUMD_UNIT_PERCENTAGE = 0x27ADU;
	constexpr uint16_t LIGHT_FIXTURE_CATEGORY = 0x016U;
	constexpr uint16_t NO_UNIT = 0x2700U;

	/**
	 * @brief Bluetooth LE Profile configuration, defines an Ambience Service
	 * which provides Temperature and Humidity readings
	 */
	class Profile
	{
	private:
		/**
		 * The "Ambience Service" will be responsible for exposing the "Temperature"
		 * and "Humidity" characteristics
		 */
		std::unique_ptr<BLEService> ambience_service;

		/**
		 * "Ambience Temperature" is a characteristic belonging to "Ambience Service"
		 */
		std::unique_ptr<BLECharacteristic> ambience_temperature;
		std::unique_ptr<BLE2904> ambience_temperature_description;

		/**
		 * "Ambience Huidity" is a characteristic belonging to "Ambience Service"
		 */
		std::unique_ptr<BLECharacteristic> ambience_humidity;
		std::unique_ptr<BLE2904> ambience_humidity_description;

		/**
		 * The light service will be reponsible for managing light control
		 */
		std::unique_ptr<BLEService> light_service;
		std::unique_ptr<BLECharacteristic> light_value;
		std::unique_ptr<BLE2904> light_value_description;

#ifdef DEBUG
		std::unique_ptr<BLEService> debug_service;
		std::unique_ptr<BLECharacteristic> debug_free_heap;
		std::unique_ptr<BLE2904> debug_free_heap_description;
#endif

	public:
		Profile(std::unique_ptr<BLEServer> &);
		void set_temperature_callback(BLECharacteristicCallbacks *);
		void set_humidity_callback(BLECharacteristicCallbacks *);
		void set_light_callback(BLECharacteristicCallbacks *);

#ifdef DEBUG
		void set_free_heap_callback(BLECharacteristicCallbacks *);
#endif
	};
}

#endif