`timescale 1ns/1ps


module tb();
    logic clk;
    logic reset;

    initial begin
        clk =0; reset=0;
        #5
        reset=1;
        @(posedge clk);
        reset=0;
    end

    always #5 clk= ~clk;
    MCU dut(.*);
endmodule