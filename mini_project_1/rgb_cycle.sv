module top(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    // Create variable that is 1/6th of a 12MHz clock cycle to
    // account for 6 different colors
    parameter FADE_INTERVAL = 2000000;
    logic [$clog2(6 * FADE_INTERVAL) - 1:0] count = 0;
    

    // Setting initial states
    initial begin

        RGB_R = 1'b0;
        RGB_G = 1'b1;
        RGB_B = 1'b1;

    end

    // Changes states during every multiple of 2000000 in the HSV order.
    // Increase the counter by one for every rising edge that doesn't
    // lead to a state transition. Reset counter to 0 at 11999999.
    always_ff @(posedge clk) begin

        // Yellow
        if(count == 1 * FADE_INTERVAL - 1) begin
            RGB_G <= ~RGB_G;
            count <= count + 1;
        end

        // Green
        else if(count == 2 * FADE_INTERVAL - 1) begin
            RGB_R <= ~RGB_R;
            count <= count + 1;
        end

        // Cyan
        else if(count == 3 * FADE_INTERVAL - 1) begin
            RGB_B <= ~RGB_B;
            count <= count + 1;
        end

        // Blue
        else if(count == 4 * FADE_INTERVAL - 1) begin
            RGB_G <= ~RGB_G;
            count <= count + 1;
        end

        // Magenta
        else if(count == 5 * FADE_INTERVAL - 1) begin
            RGB_R <= ~RGB_R;
            count <= count + 1;
        end

        else if(count == 6 * FADE_INTERVAL - 1) begin
            RGB_B <= ~RGB_B;
            count <= 0;
        end
        
        else begin
            count <= count + 1;
        end
    end
    
endmodule

