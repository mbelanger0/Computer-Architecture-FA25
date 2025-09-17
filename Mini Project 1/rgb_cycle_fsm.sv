module top(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    // Create variable that is 1/6th of a 12MHz clock cycle to
    // account for 6 different colors
    parameter FADE_INTERVAL = 2000000;
    logic [$clog2(FADE_INTERVAL) - 1:0] count = 0;

    // Setting initial states
    initial begin

        RGB_R = 1'b0;
        RGB_G = 1'b1;
        RGB_B = 1'b1;

    end

    // Define the different color states that are possible
    typedef enum {RED, YELLOW, GREEN, CYAN, BLUE, MAGENTA} colors;

    // Red initially on so next color is yellow
    colors next_color = YELLOW;


        // Check if 2000000 rising edges have passed, and if so
        // change the current/next color states. Increment counter
        // by one if not
        always_ff @(posedge clk) begin
        
        if (count == FADE_INTERVAL - 1) begin
            case (next_color)

                // RED
                RED: begin
                RGB_R <= 1'b0;
                RGB_B <= 1'b1;
                RGB_G <= 1'b1;
                next_color <= YELLOW;
                end

                // YELLOW
                YELLOW: begin
                RGB_R <= 1'b0;
                RGB_G <= 1'b0;
                RGB_B <= 1'b1;
                next_color <= GREEN;
                end
                
                // GREEN
                GREEN: begin
                RGB_R <= 1'b1;
                RGB_G <= 1'b0;
                RGB_B <= 1'b1;
                next_color <= CYAN;
                end

                // CYAN
                CYAN: begin
                RGB_R <= 1'b1;
                RGB_G <= 1'b0;
                RGB_B <= 1'b0;
                next_color <= BLUE;
                end

                // BLUE
                BLUE: begin                
                RGB_R <= 1'b1;
                RGB_G <= 1'b1;
                RGB_B <= 1'b0;
                next_color <= MAGENTA;
                end

                //MAGENTA
                MAGENTA: begin
                RGB_R <= 1'b0;
                RGB_G <= 1'b1;
                RGB_B <= 1'b0;
                next_color <= RED;
                end
            endcase

            count <= 0;
        end
            
        else begin
            count <= count + 1;
        end

        end

endmodule
