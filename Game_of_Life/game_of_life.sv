module game_of_life (
    input logic clk,
    input logic update,
    input logic [63:0] current_bits,
    output logic [63:0] next_bits
);
    localparam int num_rows = 8;
    localparam int num_cols = 8;


    int idx;
    int neighbors;
    logic alive;
    int nidx;

    always_ff @(posedge clk) begin
        if (update) begin
            // Neighbor counting
            for (int row = 0; row < num_rows; row++) begin
                for (int col = 0; col < num_cols; col++) begin
                    idx = row * num_cols + col;

                    neighbors = 0;
                    for (int delta_row = -1; delta_row <= 1; delta_row++) begin
                        for (int delta_col = -1; delta_col <= 1; delta_col++) begin
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

                    if (alive) begin
                        if ((neighbors == 2) || (neighbors == 3))
                            next_bits[idx] <= 1'b1;
                        else
                            next_bits[idx] <= 1'b0;
                    end
                    else begin
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
