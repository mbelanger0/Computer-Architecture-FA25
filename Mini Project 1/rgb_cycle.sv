// // Blink

// module top(
//     input logic     clk, 
//     output logic    LED
// );

//     // CLK frequency is 12MHz, so 6,000,000 cycles is 0.5s
//     parameter BLINK_INTERVAL = 6000000;
//     logic [$clog2(BLINK_INTERVAL) - 1:0] count = 0;

//     initial begin
//         LED = 1'b0;
//     end

//     always_ff @(posedge clk) begin
//         if (count == BLINK_INTERVAL - 1) begin
//             count <= 0;
//             LED <= ~LED;
//         end
//         else begin
//             count <= count + 1;
//         end
//     end

// endmodule



module top(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    parameter FADE_INTERVAL = 2000000;
    logic [$clog2(FADE_INTERVAL) - 1:0] count = 0;

    initial begin
        RGB_R = 1'b1;
        RGB_G = 1'b1;
        RGB_B = 1'b1;

        parameter ON = 1'b0;
        parameter OFF = 1'b1;
    end

    always_ff @(posedge clk) begin

        // Red
        if (count == 0 * FADE_INTERVAL) begin
            RGB_R = 1'b0;
        end

        // Yellow
        else if(count == FADE_INTERVAL) begin
            RGB_G = 1'b0;
        end

        // Green
        else if(count == 2 * FADE_INTERVAL) begin
            RGB_R = 1'b1;
        end



    end

