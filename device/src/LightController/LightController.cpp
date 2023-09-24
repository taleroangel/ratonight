#include "LightController.hxx"
#ifdef DEBUG
#include <Logger.h>
#endif

void LightController::set_color(const hsv_color_int_type binary)
{
	// Store current color
	struct hsv_color_mask current_color;

	// Dump binary contents into struct
	std::memcpy(
		static_cast<void *>(&current_color),
		static_cast<const void *>(&binary),
		sizeof(hsv_color_int_type));

#ifdef DEBUG
	Logger.log<LoggingLevel::I>("COLOR", "Color values changed");
	Logger.log<LoggingLevel::D>("MASK", current_color.mask);
	Logger.log<LoggingLevel::D>("HUE", current_color.hue);
	Logger.log<LoggingLevel::D>("SAT", current_color.saturation);
	Logger.log<LoggingLevel::D>("VAL", current_color.value);
#endif

	// Iterate over each LED
	for (size_t i = 0; i < n_leds; i++)
	{
		// Check if LED is enabled or 'global' is enabled
		if (((current_color.mask >> i) & 1U) ||
			(current_color.mask & 0x80U))
		{
			// Set the LED color
			values[i] = CHSV(
				current_color.hue,
				current_color.saturation,
				current_color.value);

			/// Set the value
			leds[i] = values[i];
		}
	}

	// Show Color
	FastLED.show();
}

void LightController::set_color(const uint8_t p[LIGHT_COLOR_BYTES_SIZE])
{
	// Copy memory contents into CHSV
	std::memcpy(
		static_cast<void *>(&values),
		static_cast<const void *>(p),
		LIGHT_COLOR_BYTES_SIZE);

	// Copy CHSV to CRGB
	for (std::size_t ii = 0; ii < n_leds; ii++)
		leds[ii] = values[ii];

	// Show colors
	FastLED.show();
}

void LightController::get_color(uint8_t *store) const
{
	// Copy memory from leds into store
	std::memcpy(static_cast<void *>(store),
				static_cast<const void *>(this->values),
				LIGHT_COLOR_BYTES_SIZE);
}