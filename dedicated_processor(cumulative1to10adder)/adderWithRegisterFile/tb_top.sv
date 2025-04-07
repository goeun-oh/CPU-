`timescale 1ns / 1ps
module tb_top();

logic clk;
logic rst; 
logic [7:0] outPort;

initial begin
    clk = 0;
    rst = 1;
    #10 rst = 0;

    wait(outPort == 8'd55);
    #10;
    $finish;
end
always #5 clk = ~clk;


top DUT(
    .clk(clk),
    .rst(rst),
    .outPort(outPort)
);
endmodule
