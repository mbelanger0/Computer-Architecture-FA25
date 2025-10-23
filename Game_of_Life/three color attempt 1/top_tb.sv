`timescale 1ns/1ps
`include "top.sv"

module top_tb;

    logic clk = 0;
    logic _48b;
    logic _45a;

    // Instantiate DUT
    top dut (
        .clk(clk),
        ._48b(_48b),
        ._45a(_45a)
    );

    // Clock: ~12 MHz -> period 83.333 ns. Use 41.666 ns half period.
    always #41.666 clk = ~clk;

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        // Let the DUT initialize
        #1000;

        // Force the internal copy_counter close to UPDATE_CYCLES to trigger an update quickly
        // (hierarchical access is allowed in simulation)
        dut.copy_counter = dut.UPDATE_CYCLES - 2;

        // Run long enough to observe several frame updates and WS2812 activity (shortened for CI)
        #2000000000;

        $display("Simulation complete");
        $finish;
    end

    // Debug prints
    always @(posedge clk) begin
        if (dut.u_ctrl.load_sreg) begin
            $display("%0t: LOAD_SREG addr=%0d frame=%0d pixel=%0d data=0x%02h", $time, dut.address, dut.frame, dut.pixel, dut.frame_buffer[dut.address]);
        end
        if (dut.u_ctrl.transmit_pixel && dut.u_ws.shift) begin
            $display("%0t: TRANSMIT_PIXEL pixel=%0d shift_bit=%b shift_reg=%b", $time, dut.pixel, dut.shift_reg[23], dut.shift_reg);
        end
        if (dut.auto_update_sig) begin
            $display("%0t: AUTO_UPDATE asserted", $time);
        end
        if (dut.update_pending) begin
            $display("%0t: update_pending set", $time);
        end
    end

endmodule

