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

    typedef enum {RED, YELLOW, GREEN, CYAN, BLUE, MAGENTA} colors;

    colors next_color = YELLOW;
    colors current_color = RED;


        always_ff @(posedge clk) begin
        
        if (count == FADE_INTERVAL - 1) begin
            current_color = next_color;
            count = 0;
        end
            
        else begin
            count = count + 1;
        end

        end

        always_comb() begin
             case (current_color)

                // RED
                RED: begin
                RGB_R = 1'b0;
                RGB_B = 1'b1.
                RGB_G = 1'b1;
                current_color = RED
                next_color = YELLOW;
                end

                // YELLOW
                YELLOW: begin
                RGB_R = 1'b0;
                RGB_G = 1'b0;
                RGB_B = 1'b1;
                current_color = YELLOW;
                next_color <= GREEN;
                end
                
                // GREEN
                GREEN: begin
                RGB_R = 1'b1;
                RGB_G = 1'b0;
                RGB_B = 1'b1;
                next_color = CYAN;
                current_color = GREEN;
                end

                // CYAN
                CYAN: begin
                RGB_R = 1'b1;
                RGB_G = 1'b0;
                RGB_B = 1'b0;
                current_color = CYAN;
                next_color = BLUE;
                end

                // BLUE
                BLUE: begin                
                RGB_R = 1'b1;
                RGB_G = 1'b1;
                RGB_B = 1'b0;
                current_color = BLUE
                next_color = MAGENTA;
                end

                //MAGENTA
                MAGENTA: begin
                RGB_R = 1'b0;
                RGB_G = 1'b1;
                RGB_B = 1'b0;
                current_color = MAGENTA;
                next_color = RED;
                end
            endcase
        end

endmodule
