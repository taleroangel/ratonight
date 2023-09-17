#ifndef __LIGHT_CONTROLLER_HXX__
#define __LIGHT_CONTROLLER_HXX__

#include <FastLED.h>

#include <cstdint>
#include <cstring>

#define LED_TYPE WS2812
#define N_LEDS 7

template <const uint8_t led_pin>
class LightController
{
public:
	/** Number of leds in strip constant */
	static constexpr uint8_t n_leds = N_LEDS;

	/**
	 * LED strip selection bit mask
	 * turn on/off individual LED's with this mask
	 * LSB represents led 0,
	 * If MSB is set, all leds are treated equally ('global')
	 */
	using led_mask = uint8_t;

	/**
	 * hsv_color struct representation type
	 */
	using hsv_color_int_type = uint32_t;

private:
	/** Inner color representation */
	CRGB leds[n_leds];

	/** Current shown color representation */
	struct hsv_color
	{
		led_mask mask = 0;
		uint8_t hue = 0;
		uint8_t saturation = 0;
		uint8_t value = 0;
	} current_color;

public:
	inline LightController()
	{
		FastLED.addLeds<WS2812, led_pin>(leds, n_leds);
	}

	inline void set_color(const hsv_color_int_type binary)
	{
		// Dump binary contents into struct
		std::memcpy(
			static_cast<void *>(&current_color),
			static_cast<const void *>(&binary),
			sizeof(hsv_color_int_type));

		// Iterate over each LED
		for (size_t i = 0; i < n_leds; i++)
		{
			// Check if LED is enabled or 'global' is enabled
			if (((current_color.mask >> i) & 1U) ||
				(current_color.mask & 0x80U))
			{
				// Set the LED color
				leds[i] = CHSV(
					current_color.hue,
					current_color.saturation,
					current_color.value);
			}
		}

		// Show Color
		FastLED.show();
	}

	inline hsv_color_int_type get_color() const
	{
		return static_cast<hsv_color_int_type>(current_color);
	}
};

#endif