# Input Device Configuration for FT5x06 capacitive touchscreen
# Keep touch enabled even when display viewport is inactive (for touch-to-wake)

touch.deviceType = touchScreen
touch.orientationAware = 1
touch.enableForInactiveViewport = 1

# Wake the device on an initial finger-down (touch-to-wake). Internal touch
# panels do not wake by default; TouchInputMapper reads touch.wake to enable it.
touch.wake = 1
