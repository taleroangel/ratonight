/// Re-maps a number from one range to another.
num mapValues(num value, num fromMin, num fromMax, num toMin, num toMax) =>
    (value - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin;
