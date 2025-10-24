`include "fade.sv"
`include "pwm.sv"

// Fade top level module

module top #(
    parameter PWM_INTERVAL = 1200       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    // Enum of what interval each LED could be in
    typedef enum logic[1:0] {INCREMENTING = 2'b00, DECREMENTING = 2'b01, HIGH_HOLD = 2'b10, LOW_HOLD = 2'b11} states;

    // Enum defining sixty degree intervals of what part of the HSV cycle the LEDs could be in
    typedef enum {X0TO60, X60TO120, X120TO180, X180TO240, X240TO300, X300TO360} intervals;

    // Set starting interval as the first sixty degrees of the HSV color wheel
    intervals current_interval = X0TO60;
    intervals next_interval = X60TO120;

    states R_current_state = HIGH_HOLD;
    states G_current_state = INCREMENTING;
    states B_current_state = LOW_HOLD;

    // 0.2 second variables for use in changing HSV intervals
    parameter FADE_INTERVAL = 2000000;
    logic [$clog2(FADE_INTERVAL) - 1:0] count = 0;

    // Timer to change HSV interval every 0.2s by counting the clock cycles.
    // Start with all initial conditions if rst is asserted
    always_ff @(posedge clk) begin
        if (count == FADE_INTERVAL - 1) begin
            current_interval <= next_interval;
            count <= 0;
        end  
        else begin
            count <= count + 1;
        end
    end

    // State machine to set the state of each LED in accordance to what part of the
    // HSV color wheel the LEDs should be in
    always_comb begin

        case(current_interval)
            X0TO60: begin
                R_current_state = HIGH_HOLD;
                G_current_state = INCREMENTING;
                B_current_state = LOW_HOLD;
                next_interval = X60TO120;
            end
            X60TO120: begin
                R_current_state = DECREMENTING;
                G_current_state = HIGH_HOLD;
                B_current_state = LOW_HOLD;
                next_interval = X120TO180;
            end
            X120TO180: begin
                R_current_state = LOW_HOLD;
                G_current_state = HIGH_HOLD;
                B_current_state = INCREMENTING;
                next_interval = X180TO240;
            end
            X180TO240: begin
                R_current_state = LOW_HOLD;
                G_current_state = DECREMENTING;
                B_current_state = HIGH_HOLD;
                next_interval = X240TO300;
            end
            X240TO300: begin
                R_current_state = INCREMENTING;
                G_current_state = LOW_HOLD;
                B_current_state = HIGH_HOLD;
                next_interval = X300TO360;
            end
            X300TO360: begin
                R_current_state = HIGH_HOLD;
                G_current_state = LOW_HOLD;
                B_current_state = DECREMENTING;
                next_interval = X0TO60;
            end
            default: begin
                R_current_state = HIGH_HOLD;
                G_current_state = INCREMENTING;
                B_current_state = LOW_HOLD;
                next_interval = X60TO120;
            end
        endcase
    end

    // Instantiating fade and pwm for each LED
    logic [$clog2(PWM_INTERVAL) - 1:0] R_pwm_value;
    logic R_pwm_out;

    logic [$clog2(PWM_INTERVAL) - 1:0] G_pwm_value;
    logic G_pwm_out;

    logic [$clog2(PWM_INTERVAL) - 1:0] B_pwm_value;
    logic B_pwm_out;

    // Red
    fade #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) R_u1 (
        .clk            (clk),
        .current_state  (R_current_state),
        .pwm_value      (R_pwm_value)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) R_u2 (
        .clk            (clk), 
        .pwm_value      (R_pwm_value), 
        .pwm_out        (R_pwm_out)
    );

    // Green
    fade #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) G_u1 (
        .clk            (clk), 
        .current_state  (G_current_state),
        .pwm_value      (G_pwm_value)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) G_u2 (
        .clk            (clk), 
        .pwm_value      (G_pwm_value), 
        .pwm_out        (G_pwm_out)
    );

    // Blue
    fade #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) B_u1 (
        .clk            (clk), 
        .current_state  (B_current_state),
        .pwm_value      (B_pwm_value)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) B_u2 (
        .clk            (clk), 
        .pwm_value      (B_pwm_value), 
        .pwm_out        (B_pwm_out)
    );

    // Toggling the LEDs
    assign RGB_R = ~R_pwm_out;
    assign RGB_G = ~G_pwm_out;
    assign RGB_B = ~B_pwm_out;

endmodule
