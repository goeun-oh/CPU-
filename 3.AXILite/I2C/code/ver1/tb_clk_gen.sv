`timescale 1ns/1ps

module tb_clk_gen();
    logic clk;
    logic en;
    logic reset;
    logic o_clk;
    logic tick_sample;



    always #5 clk= ~clk;

    initial begin
        clk =0; en=0; reset=1;
        #10 reset=0; en=1;
        @(posedge clk) reset=1;

        #5000;

    end

    clk_gen DUT(.*);
endmodule