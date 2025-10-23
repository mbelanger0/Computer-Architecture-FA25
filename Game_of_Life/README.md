# Game of Life Implementation

This project implements Conway's Game of Life on the iceBlinkPico and displays it on an 8×8 WS2812 LED matrix. I created three main implementations in my process. Two of these were able to be uploaded to the iceBlinkPico. `top` is the only module that changes amount the implementations so below are descriptions of the modules that don't change. In general the top level modules don't differ that much but they do result in different effects.

The three implementations are as follow:
- `single color`: this is just a simple one color single game implementation that I used to get the overall mechanics of the game worked. I iterated from here
- `rainbow`: plays a single game on the LED grid but cycles the colors through the HSV color wheel as the game is played
- `three colors attempt 1`: an attempt at getting three games to play at once, one on each color channel.

## Architecture Overview

The design combines a Game of Life cellular automaton engine with a WS2812 LED driver and control logic to play the game on the LED grid.

## Module Descriptions

### `controller.sv`
**Purpose:** Orchestrates per-pixel transmission timing and inter-frame synchronization for the WS2812 LED matrix. This module is almost identical to the provided `led_matrix`. The only change I made was outputting when the module is in an idle state. This gets used in `top` to ensure proper updating.

### `game_of_life.sv`
**Purpose:** Computes the next generation of an 8×8 Conway's Game of Life grid with wrap-around topology given the current state of the cells.

**Algorithm:**
  - Living cell with 2 or 3 neighbors -> stays alive
  - Dead cell with exactly 3 neighbors -> becomes alive
  - All other cases -> cell dies

The algorithms use several nested `for` loops and `if` statements to check and count the alive neighbors of each cell. This implementation is very resource intensive and created problems for me when I tried to implement three games at once. Modular division is used to account for wrap around effects. The overall design is simple and allows everything to happen during one rising edge when its time to update the board but doing it on one clock edge required a lot of logic devices. A better implementation may be to allow the game states to be calculated and stored over several clock edges


### `memory.sv`
**Purpose:** Synchronous ROM/RAM with optional hex file initialization (not currently used in this project). This is identical to the module in the `led_matrix` example.

**Features:**

### `ws2812b.sv`
**Purpose:** Generates WS2812-compatible bit waveforms with precise timing control. This is identical to the module in the `led_matrix` example.

### `top.sv`
**Purpose:** Top-level integration bringing together all components control logic and Game of Life updates.



**Game of Life Integration:**

**Data Flow:**
1. Controller specifies which pixel to send via `pixel[5:0]`
2. On `load_sreg`, `data_reg` is loaded from frame buffer
3. `shift_reg[23:0]` is populated with GRB data based on current color
4. WS2812 module shifts out bits while controller holds `transmit_pixel` high
5. After all 64 pixels, controller enters idle period
6. During idle, if an update is pending, frame buffer is updated from Game of Life results


### `top_tb.sv`
**Purpose:** Simulation testbench for the top module.

**Test Sequence:**
