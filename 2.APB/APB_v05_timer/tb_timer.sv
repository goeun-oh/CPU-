`timescale 1ns/1ps

module tb_timer();
    logic clk, en, reset, clear;

    logic [31:0] counter;

    always #5 clk = ~clk;
    initial begin
        clk =0; en =1; reset=0; clear=0;
        #5;
        reset=1;
        #5;
        reset=0;
    end
    timer U_TIMER (.*);
endmodule