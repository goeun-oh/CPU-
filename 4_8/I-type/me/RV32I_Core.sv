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
    logic       wdataSel;
    logic       compare;
    logic       PCAddrSrcMuxSel;
    logic       alurd1MuxSel;
    logic       lui;

    ControlUnit CU (
        .instrCode      (instrCode),
        .regFileWe      (regFileWe),
        .aluControl     (aluControl),
        .aluSrcMuxSel   (aluSrcMuxSel),
        .dataWe         (dataWe),
        .wdataSel       (wdataSel),
        .compare        (compare),
        .PCAddrSrcMuxSel(PCAddrSrcMuxSel),
        .lui            (lui),
        .alurd1MuxSel   (alurd1MuxSel)
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
        .lui            (lui),
        .alurd1MuxSel   (alurd1MuxSel)
    );


endmodule
