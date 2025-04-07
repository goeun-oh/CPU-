`timescale 1ns / 1ps


module top_cumulative_1to10(
    input logic clk,
    input logic rst,
    output logic [7:0] outPort
    );
    
    logic nle10, nSel, sumSel, adderMuxSel, nEn, sumEn, outBuf;

    controlUnit CU(
        .clk(clk),
        .rst(rst),
        .nle10(nle10), //less than or equal to 10
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
        .nle10(nle10),
        .o_sum(outPort)
    );

endmodule
