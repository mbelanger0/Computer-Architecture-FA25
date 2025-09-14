module top(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    parameter FADE_INTERVAL = 2000000;
    logic [$clog2(FADE_INTERVAL) - 1:0] count = 0;

    initial begin

        RGB_R = 1'b0;
        RGB_G = 1'b1;
        RGB_B = 1'b1;

    end

    typedef enum {red, yellow, green, cyan, blue, magenta} colors;

    colors next_color = yellow;


        always_ff @(posedge clk) begin
        
        if (count == FADE_INTERVAL - 1) begin
            case (next_color)

                // Red
                red: begin
                RGB_B <= ~RGB_B;
                next_color <= yellow;
                end

                // Yellow
                yellow: begin
                RGB_G <= ~RGB_G;
                next_color <= green;
                end
                
                // Green
                green: begin
                RGB_R <= ~RGB_R;
                next_color <= cyan;
                end

                // Cyan
                cyan: begin
                RGB_B <= ~RGB_B;
                next_color <= blue;
                end

                // Blue
                blue: begin
                RGB_G <= ~RGB_G;
                next_color <= magenta;
                end

                //Magenta
                magenta: begin
                RGB_R <= ~RGB_R;
                next_color <= red;
                end
            endcase

            count <= 0;
        end
            
        else begin
            count <= count + 1;
        end

        end

endmodule
