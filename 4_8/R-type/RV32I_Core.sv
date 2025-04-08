module RV32I_Core(
    input logic clk,
    input logic rst,
    input logic [31:0] instrCode,
    output logic [31:0] instrMemAddr
);
    logic regFileWe;
    logic [1:0] aluOP;

    controlUnit CU(.*);
    dataPath DP(
        .clk(clk),
        .rst(rst),
        .instrCode(instrCode),
        .aluOP(aluOP),
        .regFileWe(regFileWe),
        .instrMemAddr(instrMemAddr)   
    );
endmodule