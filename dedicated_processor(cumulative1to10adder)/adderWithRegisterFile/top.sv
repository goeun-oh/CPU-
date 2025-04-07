module top(
    input  logic       clk,
    input  logic       rst,
    output logic [7:0] outPort
);

    logic       RFSrcMuxSel;
    logic [2:0] readAddr1;
    logic [2:0] readAddr2;
    logic [2:0] writeAddr;
    logic       writeEn;
    logic       outBuf;
    logic iLe10;

    controlUnit CU(.*);

    dataPath DP(.*);

endmodule