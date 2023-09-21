#include "LightController.hxx"

void LightController::set_color(const hsv_color_int_type binary)
{
	// Store current color
	struct hsv_color_mask current_color;

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

void LightController::set_color(const uint8_t p[LIGHT_COLOR_BYTES_SIZE])
{
	// Copy memory contents into CRGB
	std::memcpy(
		static_cast<void *>(&leds),
		static_cast<const void *>(p),
		LIGHT_COLOR_BYTES_SIZE);

	// Show colors
	FastLED.show();
}

void LightController::get_color(uint8_t *store) const
{
	// Copy memory from leds into store
	std::memcpy(static_cast<void *>(store),
				static_cast<const void *>(this->leds),
				LIGHT_COLOR_BYTES_SIZE);
}