# Mini Project 1

## Goal

Use the [iceBlinkPico](https://github.com/bminch/iceBlinkPico/) FPGA dev board to change the colors of a set of RGB LEDs to cycles through 60 degree intervals of the colors on the HSV color wheel.

## Implementations
I created three different implementations

- `rgb_cycle.sv`: uses a chain of if statements and a counter so everytime the clock cycle reaches a multiple of 2000000 (0.2x of a sec), the color changes
- `rgb_cycle_fsm.sv`: uses a finite state machine to change the combined LED color every 2000000 clock cycles (0.2x of a sec) and uses sequential logic
- `rgb_cycle_fsm_comb.sv`: also uses a finite state machine using the same principle but does so also using combinational logic

## Video
`rgb_cycle_fsm_comb_demo.mp4`: The demo video shows a few LED cycles going through the six different colors. The last two seconds of the video are in slow motion so the individual colors can more clearly be seen


