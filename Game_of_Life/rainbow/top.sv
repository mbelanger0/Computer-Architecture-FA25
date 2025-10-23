`include "memory.sv"
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

    ws2812b u_ws (
        .clk                (clk),
        .serial_in          (shift_reg[23]),
        .transmit           (transmit_pixel),
        .ws2812b_out        (ws2812b_out),
        .shift              (shift)
    );

    controller u_ctrl (
        .clk                (clk),
        .load_sreg          (load_sreg),
        .transmit_pixel     (transmit_pixel),
        .pixel              (pixel),
        .frame              (frame),
        .idle               (ctrl_idle)
    );

    localparam UPDATE_CYCLES = 800000;

    localparam logic [7:0] BRIGHTNESS = 8'h05;

    logic [63:0] frame_bits;
    logic [63:0] next_bits;

    logic auto_update_sig = 1'b0;

    always_comb begin
        for (int i = 0; i < 64; i++) begin
            frame_bits[i] = frame_buffer[i];
        end
    end

        game_of_life u_gol_G (
        .clk            (clk),
        .update         (auto_update_sig),
        .current_bits   (frame_bits),
        .next_bits      (next_bits)
    );

    initial begin
        for (int i = 0; i < 64; i++) begin
            frame_buffer[i] = 8'h00;
        end

        // Glider pattern positions
        // (1,2), (2,3), (3,1),(3,2),(3,3)
        frame_buffer[1*8 + 2] = BRIGHTNESS;
        frame_buffer[2*8 + 3] = BRIGHTNESS;
        frame_buffer[3*8 + 1] = BRIGHTNESS;
        frame_buffer[3*8 + 2] = BRIGHTNESS;
        frame_buffer[3*8 + 3] = BRIGHTNESS;
    end

    // initial begin
    //     for (int i = 0; i < 64; i++) begin
    //         frame_buffer[i] = 8'h00;
    //     end
    //     // center vertical blinker at (3,3),(4,3),(5,3)
    //     frame_buffer[3*8 + 3] = BRIGHTNESS;
    //     frame_buffer[4*8 + 3] = BRIGHTNESS;
    //     frame_buffer[5*8 + 3] = BRIGHTNESS;
    // end


    // initial begin
    //     for (int i = 0; i < 64; i++) frame_buffer[i] = 8'h00;
    //     // top and bottom rows
    //     for (int x = 0; x < 8; x++) begin
    //         frame_buffer[x*8 + 0] = BRIGHTNESS;
    //         frame_buffer[x*8 + 7] = BRIGHTNESS;
    //     end
    //     // left and right columns
    //     for (int y = 1; y < 7; y++) begin
    //         frame_buffer[0*8 + y] = BRIGHTNESS;
    //         frame_buffer[7*8 + y] = BRIGHTNESS;
    //     end
    // end

    // initial begin
    //     for (int i = 0; i < 64; i++) frame_buffer[i] = 8'h00;
    //     frame_buffer[1*8 + 2] = BRIGHTNESS;
    //     frame_buffer[2*8 + 2] = BRIGHTNESS;
    //     frame_buffer[1*8 + 3] = BRIGHTNESS;
    //     frame_buffer[2*8 + 3] = BRIGHTNESS;
    //     frame_buffer[5*8 + 2] = BRIGHTNESS;
    //     frame_buffer[6*8 + 3] = BRIGHTNESS;
    //     frame_buffer[6*8 + 4] = BRIGHTNESS;
    // end

    // // Beehive
    // initial begin
    //     for (int i = 0; i < 64; i++) frame_buffer[i] = 8'h00;
    //     // coordinates (2,3),(3,2),(4,2),(5,3),(4,4),(3,4)
    //     frame_buffer[2*8 + 3] = BRIGHTNESS;
    //     frame_buffer[3*8 + 2] = BRIGHTNESS;
    //     frame_buffer[4*8 + 2] = BRIGHTNESS;
    //     frame_buffer[5*8 + 3] = BRIGHTNESS;
    //     frame_buffer[4*8 + 4] = BRIGHTNESS;
    //     frame_buffer[3*8 + 4] = BRIGHTNESS;
    // end


    logic [$clog2(clock_rate) - 1:0] copy_counter = 0;


    logic update_pending = 1'b0;

    always_ff @(posedge clk) begin
        if (UPDATE_CYCLES != 0) begin
            if (copy_counter == UPDATE_CYCLES - 1) begin
                copy_counter <= 0;
                auto_update_sig <= 1'b1;
                update_pending <= 1'b1;
                // current_color = next_color;
            end else begin
                copy_counter <= copy_counter + 1;
                auto_update_sig <= 1'b0;
            end
        end else begin
            auto_update_sig <= 1'b0;
        end

        if (update_pending && ctrl_idle) begin
            update_pending <= 1'b0;
            for (int i = 0; i < 64; i++) begin
                frame_buffer[i] <= next_bits[i] ? BRIGHTNESS : 8'h00;
            end
        end
    end

    typedef enum {RED, YELLOW, GREEN, CYAN, BLUE, MAGENTA} colors;

    colors current_color = GREEN;
    colors next_color = CYAN;

    logic [$clog2(clock_rate) - 1:0] color_counter = 0;
    localparam COLOR_INTERVAL = 2000000;

    always_ff @(posedge clk) begin
        if (color_counter == COLOR_INTERVAL - 1) begin
            color_counter = 0;
            current_color <= next_color;
        end 
        else begin
            color_counter = color_counter + 1;
        end
    end

    always_ff @(posedge clk) begin
        if (load_sreg) begin
            case (current_color)
                RED: begin
                    shift_reg <= { 8'd0, data_reg, 8'd0 };
                    next_color = YELLOW;
                end
                YELLOW: begin
                shift_reg <= { data_reg, data_reg, 8'd0 };
                    next_color = GREEN;  
                end
                GREEN: begin
                    shift_reg <= { data_reg, 8'd0, 8'd0 };
                    next_color = CYAN;
                end
                CYAN: begin
                    shift_reg <= { data_reg, 8'd0, data_reg };
                    next_color = BLUE;
                end
                BLUE: begin
                    shift_reg <= { 8'd0, 8'd0, data_reg };
                    next_color = MAGENTA;
                end
                MAGENTA: begin
                    shift_reg <= { 8'd0, data_reg, data_reg };
                    next_color = RED;
                end
            endcase
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
        end
    end

    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule
