`include "memory.sv"
`include "ws2812b.sv"
`include "controller.sv"
`include "game_of_life.sv"

module top(
    input logic clk,
    output logic _48b,
    output logic _45a
);

    // logic [7:0] data_reg_R, data_reg_G;//, data_reg_B;
    logic [7:0] data_reg_G;

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

    // logic [7:0] frame_buffer_R [0:63];
    logic [7:0] frame_buffer_G [0:63];
    // logic [7:0] frame_buffer_B [0:63];

    always_ff @(posedge clk) begin
        if (load_sreg) begin
            // data_reg_R <= frame_buffer_R[address];
            data_reg_G <= frame_buffer_G[address];
            // data_reg_B <= frame_buffer_B[address];
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

    logic [63:0] frame_bits_G;//, frame_bits_G;//, frame_bits_B;
    logic [63:0] next_bits_G;//, next_bits_G;//, next_bits_B;

    logic auto_update_sig = 1'b0;

    always_comb begin
        for (int i = 0; i < 64; i++) begin
            // frame_bits_R[i] = frame_buffer_R[i];
            frame_bits_G[i] = frame_buffer_G[i];
            // frame_bits_B[i] = frame_buffer_B[i];
        end
    end

    //     game_of_life u_gol_R (
    //     .clk            (clk),
    //     .update         (auto_update_sig),
    //     .current_bits   (frame_bits_R),
    //     .next_bits      (next_bits_R)
    // );

        game_of_life u_gol_G (
        .clk            (clk),
        .update         (auto_update_sig),
        .current_bits   (frame_bits_G),
        .next_bits      (next_bits_G)
    );

    // game_of_life u_gol_B (
    //     .clk            (clk),
    //     .update         (auto_update_sig),
    //     .current_bits   (frame_bits_B),
    //     .next_bits      (next_bits_B)
    // );

    initial begin
        for (int i = 0; i < 64; i++) begin
            // frame_buffer_R[i] = 8'h00;
            frame_buffer_G[i] = 8'h00;
            // frame_buffer_B[i] = 8'h00;
        end

        // Glider pattern positions
        // (1,2), (2,3), (3,1),(3,2),(3,3)
        // frame_buffer_R[1*8 + 2] = BRIGHTNESS;
        // frame_buffer_R[2*8 + 3] = BRIGHTNESS;
        // frame_buffer_R[3*8 + 1] = BRIGHTNESS;
        // frame_buffer_R[3*8 + 2] = BRIGHTNESS;
        // frame_buffer_R[3*8 + 3] = BRIGHTNESS;

        frame_buffer_G[1*8 + 2] = BRIGHTNESS;
        frame_buffer_G[2*8 + 3] = BRIGHTNESS;
        frame_buffer_G[3*8 + 1] = BRIGHTNESS;
        frame_buffer_G[3*8 + 2] = BRIGHTNESS;
        frame_buffer_G[3*8 + 3] = BRIGHTNESS;
        
        // frame_buffer_B[3*8 + 3] = BRIGHTNESS;
        // frame_buffer_B[4*8 + 3] = BRIGHTNESS;
        // frame_buffer_B[5*8 + 3] = BRIGHTNESS;
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

        if (update_pending && ctrl_idle) begin
            update_pending <= 1'b0;
            for (int i = 0; i < 64; i++) begin
                // frame_buffer_R[i] <= next_bits_R[i] ? BRIGHTNESS : 8'h00;
                frame_buffer_G[i] <= next_bits_G[i] ? BRIGHTNESS : 8'h00;
                // frame_buffer_B[i] <= next_bits_B[i] ? BRIGHTNESS : 8'h00;
            end
        end
    end

    typedef enum {RED, GREEN, BLUE} colors;

    colors current_color = GREEN;

    always_ff @(posedge clk) begin
        if (load_sreg) begin
            case (current_color)
                GREEN: begin
                    shift_reg <= { data_reg_G, 8'd0, 8'd0 };
                    current_color = RED;
                end
                RED: begin
                    shift_reg <= { 8'd0, data_reg_G, 8'd0 };
                    current_color = BLUE;

                end
                BLUE: begin
                    shift_reg <= { 8'd0, 8'd0, data_reg_G };
                    current_color = GREEN;
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
