// PWM generator to fade LED - from fade example

module pwm #(
    parameter PWM_INTERVAL = 1200       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic clk, 
    input logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value, 
    output logic pwm_out
);

    // Declare PWM generator counter variable
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_count = 0;

    // Implement counter for timing transition in PWM output signal
    always_ff @(posedge clk) begin
        if (pwm_count == PWM_INTERVAL - 1) begin
            pwm_count <= 0;
        end
        else begin
            pwm_count <= pwm_count + 1;
        end
    end

    // Generate PWM output signal - make sure pwm_out stays 0 when pwm_value is 0
    always_comb
        if (pwm_value == 0) begin
            pwm_out = 1'b0;
        end
        else begin
            pwm_out = (pwm_count > pwm_value) ? 1'b0 : 1'b1;
        end

endmodule
