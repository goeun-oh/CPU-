`timescale 1ns / 1ps

module RV32I_Core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instrCode,
    input  logic [31:0] rData,
    output logic        dataWe,
    output logic [31:0] instrMemAddr,
    output logic [31:0] dataAddr,
    output logic [31:0] datawData
);
    logic       regFileWe;
    logic [3:0] aluControl;
    logic       aluSrcMuxSel;
    logic [1:0] wdataSel;
    logic       compare;
    logic       PCAddrSrcMuxSel;
    logic       alurd1MuxSel;
    logic       PCSrcMuxSel;


    
    ControlUnit CU (
        .instrCode      (instrCode),
        .regFileWe      (regFileWe),
        .aluControl     (aluControl),
        .aluSrcMuxSel   (aluSrcMuxSel),
        .dataWe         (dataWe),
        .wdataSel       (wdataSel),
        .compare        (compare),
        .PCAddrSrcMuxSel(PCAddrSrcMuxSel),
        .alurd1MuxSel   (alurd1MuxSel),
        .PCSrcMuxSel    (PCSrcMuxSel)
    );


    DataPath DP (
        .clk            (clk),
        .reset          (reset),
        .instrCode      (instrCode),
        .instrMemAddr   (instrMemAddr),
        .regFileWe      (regFileWe),
        .aluControl     (aluControl),
        .aluSrcMuxSel   (aluSrcMuxSel),
        .wdataSel       (wdataSel),
        .rData          (rData),
        .dataAddr       (dataAddr),
        .datawData      (datawData),
        .compare        (compare),
        .PCAddrSrcMuxSel(PCAddrSrcMuxSel),
        .alurd1MuxSel   (alurd1MuxSel),
        .PCSrcMuxSel    (PCSrcMuxSel)
    );


endmodule
