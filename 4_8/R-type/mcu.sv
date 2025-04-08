module mcu(
    input logic clk,
    input logic rst
);
    logic [31:0] instrCode, intrMemAddr;

    RV32I_Core CORE(
        .clk(clk),
        .rst(rst),
        .instrCode(instrCode),
        .instrMemAddr(instrMemAddr)
    );

    rom InstMem(
        .addr(instrMemAddr),
        .rdata(instrCode)
    );

endmodule