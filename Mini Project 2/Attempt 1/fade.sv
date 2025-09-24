// Fade

module fade #(
    parameter INC_DEC_INTERVAL = 12000,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms
    parameter INC_DEC_MAX = 200,            // Transition to next state after 200 increments / decrements, which is 0.2s
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value
);

    localparam ON_OFF_INTERVAL = 12000000;     //


    // Define state variable values
    localparam PWM_INC = 2'b00;
    localparam PWM_DEC = 2'b01;
    localparam OFF_HOLD = 2'b10;
    localparam ON_HOLD = 2'b11;

    // Declare state variables
    logic current_state = PWM_INC;
    logic next_state;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic [$clog2(ON_OFF_INTERVAL) - 1:0] on_off_counter = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        pwm_value = 0;
    end

    // Register the next state of the FSM
    always_ff @(posedge time_to_transition)
        current_state <= next_state;

    // Compute the next state of the FSM
    always_comb begin
        next_state = 2'bxx;
        case (current_state)
            PWM_INC:
                next_state = ON_HOLD;
            ON_HOLD:
                next_state = PWM_DEC;
            PWM_DEC:
                next_state = OFF_HOLD;
            OFF_HOLD:
                next_state = PWM_INC;
        endcase
    end

    // Implement counter for incrementing / decrementing PWM value
    always_ff @(posedge clk) begin
        case (current_state)
            PWM_INC, PWM_DEC: begin
                if (count == INC_DEC_INTERVAL - 1) begin
                    count <= 0;
                    time_to_inc_dec <= 1'b1;
                end
                else begin
                    count <= count + 1;
                    time_to_inc_dec <= 1'b0;
                end
            end
        endcase

    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin
        case (current_state)
            PWM_INC:
                pwm_value <= pwm_value + INC_DEC_VAL;
            PWM_DEC:
                pwm_value <= pwm_value - INC_DEC_VAL;
            ON_HOLD:
                pwm_value <= PWM_INTERVAL - 1;
            OFF_HOLD:
                pwm_value <= 0;
                

        endcase
    end

    // Implement counter for timing state transitions
    always_ff @(posedge time_to_inc_dec) begin
        case(current_state)    
            PWM_INC, PWM_DEC: begin   
                if (inc_dec_count == INC_DEC_MAX - 1) begin
                    inc_dec_count <= 0;
                    time_to_transition <= 1'b1;
                end
                else begin
                    inc_dec_count <= inc_dec_count + 1;
                    time_to_transition <= 1'b0;
                end
            end

            ON_HOLD, OFF_HOLD: begin
                if (on_off_counter == ON_OFF_INTERVAL - 1) begin
                    on_off_counter <= 0;
                    time_to_transition <= 1'b1;
                end
                else begin
                    on_off_counter <= on_off_counter + 1;
                    time_to_transition <= 1'b0;

                end
            end
        endcase
    end

endmodule
