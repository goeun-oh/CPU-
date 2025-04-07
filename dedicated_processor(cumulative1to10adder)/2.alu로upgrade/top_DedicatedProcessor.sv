`timescale 1ns / 1ps

module top_DedicatedProcessor (
    input  logic       clk,
    input  logic       reset,
    output logic [7:0] outPort
);

    logic       RFSrcMuxSel;
    logic [2:0] readAddr1;
    logic [2:0] readAddr2;
    logic [2:0] writeAddr;
    logic       writeEn;
    logic       outBuf;
    logic       aBTb;
    logic [2:0] aluOP;

    DataPath U_DataPath (
        .clk(clk),
        .reset(reset),
        .RFSrcMuxSel(RFSrcMuxSel),
        .readAddr1(readAddr1),
        .readAddr2(readAddr2),
        .writeAddr(writeAddr),
        .writeEn(writeEn),
        .outBuf(outBuf),
        .aluOP(aluOP),
        .outPort(outPort),
        .aBTb(aBTb)
    );
    ControlUnit U_ControlUnit (
        .clk(clk),
        .reset(reset),
        .RFSrcMuxSel(RFSrcMuxSel),
        .readAddr1(readAddr1),
        .readAddr2(readAddr2),
        .writeAddr(writeAddr),
        .writeEn(writeEn),
        .outBuf(outBuf),
        .aluOP(aluOP),
        .aBTb(aBTb)
    );

endmodule
