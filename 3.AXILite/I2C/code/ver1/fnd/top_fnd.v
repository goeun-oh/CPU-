`timescale 1ns / 1ps

module FND_C(
    input clk, 
    input reset,
    input  [7:0] Digit,
    output [7:0] fndFont,
    output [3:0] fndCom
    );

    fnd_controller U_FND(
    .clk(clk), 
    .reset(reset),
    .Digit(Digit),
    .seg(fndFont),
    .seg_comm(fndCom)
);
endmodule
