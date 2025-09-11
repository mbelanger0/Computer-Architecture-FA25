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
    logic [$clog2(6 * FADE_INTERVAL) - 1:0] count = 0;

    initial begin

        RGB_R = 1'b0;
        RGB_G = 1'b1;
        RGB_B = 1'b1;

    end

    always_ff @(posedge clk) begin

        // // Red
        // if (count == 0 * FADE_INTERVAL) begin
        //     RGB_R <= ~RGB_R;
        //     count <= count + 1;
        // end


        // Yellow
        if(count == 1 * FADE_INTERVAL-1) begin
            RGB_G <= ~RGB_G;
            count <= count + 1;
        end

        // Green
        else if(count == 2 * FADE_INTERVAL-1) begin
            RGB_R <= ~RGB_R;
            count <= count + 1;
        end

        // Cyan
        else if(count == 3 * FADE_INTERVAL-1) begin
            RGB_B <= ~RGB_B;
            count <= count + 1;
        end

        // Blue
        else if(count == 4 * FADE_INTERVAL-1) begin
            RGB_G <= ~RGB_G;
            count <= count + 1;
        end

        // Magenta
        else if(count == 5 * FADE_INTERVAL-1) begin
            RGB_R <= ~RGB_R;
            count <= count + 1;
        end

        else if(count == 6 * FADE_INTERVAL-1) begin
            RGB_B <= ~RGB_B;
            count <= 0;
        end
        
        else begin
            count <= count + 1;
        end
    end
    
endmodule

