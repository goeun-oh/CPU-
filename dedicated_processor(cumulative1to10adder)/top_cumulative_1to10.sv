`timescale 1ns / 1ps


module top_cumulative_1to10(
    input logic clk,
    input logic rst,
    output logic [7:0] outPort
    );
    
    logic nlt10, nSel, sumSel, adderMuxSel, nEn, sumEn, outBuf;

    controlUnit CU(
        .clk(clk),
        .rst(rst),
        .nlt10(nlt10),
        .nSel(nSel),
        .sumSel(sumSel),
        .adderMuxSel(adderMuxSel),
        .nEn(nEn),
        .sumEn(sumEn),
        .outBuf(outBuf)
    );


    dataPath DP(
        .clk(clk),
        .rst(rst),
        .nSel(nSel),
        .sumSel(sumSel),
        .adderMuxSel(adderMuxSel),
        .nEn(nEn),
        .sumEn(sumEn),
        .outBuf(outBuf),
        .nlt10(nlt10),
        .o_sum(outPort)
    );

endmodule
