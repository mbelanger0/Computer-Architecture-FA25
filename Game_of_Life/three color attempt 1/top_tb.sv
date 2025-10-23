`timescale 1ns/1ps
`include "top.sv"

module top_tb;

    logic clk = 0;
    logic _48b;
    logic _45a;

    top dut (
        .clk(clk),
        ._48b(_48b),
        ._45a(_45a)
    );

    always #41.666 clk = ~clk;

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        #1000;

        dut.copy_counter = dut.UPDATE_CYCLES - 2;

        #2000000000;

        $finish;
    end

endmodule

