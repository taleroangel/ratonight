#ifndef __PINOUT_HXX__
#define __PINOUT_HXX__

#include <cstdint>
#include <esp32-hal-gpio.h>

/// @brief Define the pinout of the microcontroller
namespace pinout {

/// @brief GPIO pin data type
using pin_t = uint8_t;

/// @brief DHT11 Sensor data pin connected in parallel with a 10kO resistor to VND
constexpr pin_t dht_data = GPIO_NUM_4;

/// @brief HW159 (NEOPIXEL) data pin connected with a 10kO resistor
constexpr pin_t hw_159_data = GPIO_NUM_5;

}

#endif // __PINOUT_HXX__
