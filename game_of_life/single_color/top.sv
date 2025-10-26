`include "ws2812b.sv"
`include "controller.sv"
`include "game_of_life.sv"

module top(
    input logic clk,
    output logic _48b,
    output logic _45a
);


    logic [7:0] data_reg;

    logic [5:0] pixel;
    logic [4:0] frame;
    logic [10:0] address;

    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;
    logic ctrl_idle;

    localparam clock_rate = 12000000;

    assign address = { frame, pixel };

    logic [7:0] frame_buffer [0:63];
  
    always_ff @(posedge clk) begin
        if (load_sreg) begin
            data_reg <= frame_buffer[address];
        end
    end

    // LED driver instantiation
    ws2812b u_ws (
        .clk                (clk),
        .serial_in          (shift_reg[23]),
        .transmit           (transmit_pixel),
        .ws2812b_out        (ws2812b_out),
        .shift              (shift)
    );

    // Controller instantiation
    controller u_ctrl (
        .clk                (clk),
        .load_sreg          (load_sreg),
        .transmit_pixel     (transmit_pixel),
        .pixel              (pixel),
        .frame              (frame),
        .idle               (ctrl_idle)
    );

    // Update cell alive/dead states every 800,000 clock cycles
    localparam UPDATE_CYCLES = 800000;

    // Reduced brightness because the LEDs are blindingly bright
    // at full brightness  
    localparam logic [7:0] BRIGHTNESS = 8'h05;

    // Storage for current and next state of cells
    logic [63:0] frame_bits;
    logic [63:0] next_bits;

    // Logic to signal game_of_life module to compute the next
    // iteration of the game  
    logic auto_update_sig = 1'b0;

    // Continuously load the frame butter with the current state of
    // the game
    always_comb begin
        for (int i = 0; i < 64; i++) begin
            frame_bits[i] = frame_buffer[i];
        end
    end

    // Game instantiation
    game_of_life u_gol (
        .clk            (clk),
        .update         (auto_update_sig),
        .current_bits   (frame_bits),
        .next_bits      (next_bits)
    );

    initial begin
        // Fill the frame buffer with zeros initially
        for (int i = 0; i < 64; i++) begin
            frame_buffer[i] = 8'h00;
        end

        // Set the starting pattern

        // Glider pattern positions
        // (1,2), (2,3), (3,1),(3,2),(3,3)
        frame_buffer[1*8 + 2] = BRIGHTNESS;
        frame_buffer[2*8 + 3] = BRIGHTNESS;
        frame_buffer[3*8 + 1] = BRIGHTNESS;
        frame_buffer[3*8 + 2] = BRIGHTNESS;
        frame_buffer[3*8 + 3] = BRIGHTNESS;


    //     // center vertical blinker
    //     // (3,3),(4,3),(5,3)
    //     frame_buffer[3*8 + 3] = BRIGHTNESS;
    //     frame_buffer[4*8 + 3] = BRIGHTNESS;
    //     frame_buffer[5*8 + 3] = BRIGHTNESS;

    end

    // Counter for sending game update signals
    logic [$clog2(clock_rate) - 1:0] copy_counter = 0;

    logic update_pending = 1'b0;

    always_ff @(posedge clk) begin
        if (UPDATE_CYCLES != 0) begin
            if (copy_counter == UPDATE_CYCLES - 1) begin
                copy_counter <= 0;
                auto_update_sig <= 1'b1;
                update_pending <= 1'b1;
            end else begin
                copy_counter <= copy_counter + 1;
                auto_update_sig <= 1'b0;
            end
        end else begin
            auto_update_sig <= 1'b0;
        end

        // Only fill the frame buffer with the next game state
        // if the update signals is sent and if the controller
        // is in an idle state
        if (update_pending && ctrl_idle) begin
            update_pending <= 1'b0;
            for (int i = 0; i < 64; i++) begin
                frame_buffer[i] <= next_bits[i] ? BRIGHTNESS : 8'h00;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (load_sreg) begin
            // Send data to just the green color channel
            shift_reg <= { data_reg, 16'b0 };
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
        end
    end

    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule
