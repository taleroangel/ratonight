#ifndef __LIGHT_CONTROLLER_HXX__
#define __LIGHT_CONTROLLER_HXX__

#include <FastLED.h>

#include <cstdint>
#include <cstring>

#define LIGHT_CONTROLLER_N_LIGHTS 7U
#define LIGHT_CONTROLLER_BYTES_LIGHT 3U
#define LIGHT_COLOR_BYTES_SIZE (LIGHT_CONTROLLER_BYTES_LIGHT * LIGHT_CONTROLLER_N_LIGHTS)
#define INIT_VALUE 0x80000080U

class LightController
{
public:
	/** Number of leds in strip constant */
	static constexpr uint8_t n_leds = LIGHT_CONTROLLER_N_LIGHTS;

	/**
	 * LED strip selection bit mask
	 * turn on/off individual LED's with this mask
	 * LSB represents led 0,
	 * If MSB is set, all leds are treated equally ('global')
	 */
	using led_mask = uint8_t;

	/**
	 * hsv_color_mask struct representation type
	 */
	using hsv_color_int_type = uint32_t;

	/** Current shown color representation */
	struct hsv_color_mask
	{
		led_mask mask = 0;
		uint8_t hue = 0;
		uint8_t saturation = 0;
		uint8_t value = 0;
	};

private:
	/** Inner color representation */
	CRGB leds[n_leds];

public:
	LightController() = default;

	template <const uint8_t pin>
	inline void init()
	{
		FastLED.addLeds<WS2812, pin>(leds, n_leds);
	}

	void set_color(const hsv_color_int_type binary);
	void set_color(const uint8_t p[LIGHT_COLOR_BYTES_SIZE]);
	void get_color(uint8_t *p) const;
};

#endif