`include "fade.sv"
`include "pwm.sv"

// Fade top level module

module top #(
    parameter PWM_INTERVAL = 1200       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B,
);

    typedef enum {INCREMENTING, DECREMENTING, HIGH_HOLD, LOW_HOLD} states;

    typedef enum {X0TO60, X60TO120, X120TO180, X180TO240, X240TO300, X300TO360} intervals;


    states current_states = ;
    states next_states = ;

    states current_states = ;
    states next_states = ;

    states current_states = ;
    states next_states = ;

    states current_states = ;
    states next_states = ;


    always_ff @(posedge clk) begin
    
        if (count == PWM - 1) begin
            current_color <= next_color;
            count <= 0;
        end
            
        else begin
            count <= count + 1;
        end
    end

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value;
    logic pwm_out;

    fade #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u1 (
        .clk            (clk), 
        .pwm_value      (pwm_value)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk), 
        .pwm_value      (pwm_value), 
        .pwm_out        (pwm_out)
    );

    assign RGB_R = ~pwm_out;
    assign RGB_G = ~RGB_R;
    assign RGB_B = ~RGB_G;

endmodule
