module game_of_life (
    input logic clk,
    input logic update,
    input logic [63:0] current_bits,
    output logic [63:0] next_bits
);

    // LED grid has 8 rows and 8 columns
    localparam num_rows = 8;
    localparam num_cols = 8;


    int idx;
    int neighbors;
    logic alive;
    int neighbor_row;
    int neighbor_col;
    int nidx;

    always_ff @(posedge clk) begin
        if (update) begin
            // Neighbor counting. Iterate through all rows/columns on the grid
            for (int row = 0; row < num_rows; row++) begin
                for (int col = 0; col < num_cols; col++) begin
                    idx = row * num_cols + col;

                    neighbors = 0;
                    for (int delta_row = -1; delta_row <= 1; delta_row++) begin
                        for (int delta_col = -1; delta_col <= 1; delta_col++) begin
                            //Skip self but count alive neighbor cells
                            if (!(delta_row == 0 && delta_col == 0)) begin
                                neighbor_row = (row + delta_row + num_rows) % num_rows;
                                neighbor_col = (col + delta_col + num_cols) % num_cols;
                                nidx = neighbor_row * num_cols + neighbor_col;
                                if (current_bits[nidx])
                                    neighbors = neighbors + 1;
                            end
                        end
                    end

                    alive = current_bits[idx];
                    
                    // Keep cell alive if it has 2 or 3 alive neighbors, otherwise
                    // cell becomes dead
                    if (alive) begin
                        if ((neighbors == 2) || (neighbors == 3))
                            next_bits[idx] <= 1'b1;
                        else
                            next_bits[idx] <= 1'b0;
                    end
                    else begin
                    // If cell is not alive but has exactly 3 alive neighbors, cell
                    // becomes a live
                        if (neighbors == 3)
                            next_bits[idx] <= 1'b1;
                        else
                            next_bits[idx] <= 1'b0;
                    end
                end
            end
        end
    end

endmodule
