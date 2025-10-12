 module game_of_life (
    input logic clk,
    input logic update,
    input logic [7:0] current_state [0:63],
    output logic [7:0] next_state [0:63],
 )

    localparam num_rows = 8;
    localparam num_cols = 8;


    logic [0:7][0:7] led_grid;
    logic [$clog2(num_rows) - 1:0] row;
    logic [$clog2(num_cols) - 1:0] col;


    logic [3:0] alive_cell_count = 0;

    // Neighbor counting

    always_ff @(posedge clk) {
        if (update) begin
            for (row = 0, row < num_cols, row++) begin
                for (col = 0, col < num_col) begin
                    
                end
            end
        end

    }
