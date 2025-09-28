// Fade - Adapted from the provided face.sv example

module fade #(
    parameter INC_DEC_INTERVAL = 10000,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms
    parameter INC_DEC_MAX = 200,            // Transition to next state after 200 increments / decrements, which is 0.2s
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX
)(
    input logic clk,
    input logic [1:0] current_state,
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value
);

    // Define state variable values
    localparam PWM_INC   = 2'b00;
    localparam PWM_DEC   = 2'b01;
    localparam HIGH_HOLD = 2'b10;
    localparam LOW_HOLD  = 2'b11;


    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;

    initial begin
        pwm_value = 0;
    end

    // Implement counter for incrementing / decrementing PWM value
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement / Hold PWM value as appropriate given current state
    always_ff @(posedge clk) begin
        if (time_to_inc_dec) begin
            case (current_state)
                PWM_INC:
                    if (pwm_value < PWM_INTERVAL - INC_DEC_VAL)
                        pwm_value <= pwm_value + INC_DEC_VAL;
                    else
                        pwm_value <= PWM_INTERVAL - 1;
                PWM_DEC:
                    if (pwm_value > INC_DEC_VAL)
                        pwm_value <= pwm_value - INC_DEC_VAL;
                    else
                        pwm_value <= 0;
                HIGH_HOLD:
                    pwm_value <= PWM_INTERVAL - 1;
                LOW_HOLD:
                    pwm_value <= 0;
            endcase
        end
    end

endmodule
