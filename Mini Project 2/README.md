# Mini Project 2
The goal of Mini Project 2 is to to drive the RGB LEDs on the [iceBlinkPico](https://github.com/bminch/iceBlinkPico/) so that they smoothly cycle through the colors on the HSV color wheel.

## Implementation
My implementation is adapted from the [fade](https://github.com/bminch/iceBlinkPico/tree/main/examples/fade) example for the iceBlinkPico. As with the example, the main implementation contains three files:
- `top.sv` - adapted from example
- `fade.sv` - adapted from example
- `pwm.sv` - adapted from example with minor change

### `fade.sv`
The fade module controls the brightness of an LED by generating a PWM value that changes over time. It uses two counters: one to determine when to update the brightness (`INC_DEC_INTERVAL`), and another to track the number of steps in a fade cycle (`INC_DEC_MAX`). These are from the iceBlinkPico `fade` example and are largely unchanged Different from the example, this module responds to a 2-bit `current_state` input which selects one of four behaviors:

- Incrementing (`PWM_INC`): Gradually increases the PWM value making the LED brighter
- Decrementing (`PWM_DEC`): Gradually decreases the PWM value dimming the LED
- High Hold (`HIGH_HOLD`): Holds the PWM value at its maximum keeping the LED fully on
- Low Hold (`LOW_HOLD`): Holds the PWM value at zero turning the LED off

Rather than being handled in this module like the example, state transitions are handled in `top.sv`. This allows for easier control of all the states of all the LEDs at once.

The step size for each increment or decrement is set by `INC_DEC_VAL`, calculated from the total PWM range and the number of steps. The module updates the PWM value only at intervals defined by the counters. This allows for precise control over fade timing and brightness levels making it suitable for smooth color mixing.

### `top.sv`
The `top` module coordinates the color fading of the RGB LEDs by cycling through intervals on the HSV color wheel. It uses two enums: one for the current state of each LED (incrementing, decrementing, high hold, low hold), and one for the current interval of the HSV cycle (six segments, each representing 60 degrees).

A timer counts clock cycles to determine when to advance to the next HSV interval (every 0.2 seconds). For each interval, a combinational state machine sets the state of the red, green, and blue LEDs, controlling whether each channel is fading up, fading down, held high, or held low. This mapping creates smooth color transitions as the module cycles through the HSV wheel. The state machine also sets the next HSV interval.

Each color channel instantiates a fade module (to generate a PWM value based on its state) and a pwm module (to convert the PWM value into an on/off signal for the LED). The outputs are inverted before being assigned to the RGB LED pins to account for the active-low LED operation.

Overall, the top module orchestrates the timing and state transitions needed for continuous color fading across the HSV color wheel spectrum.

## Simulation
The below simulation results show the changing duty cycle of for each LED. It creates a trapezoid wave similar to the wave created by plotting the HSV color wheel.

![simulation result](top_sim.png)

## Video
The video `rgb_fade.mp4` shows several cycles of the LEDs fading and shows colors across the HSV spectrum.
