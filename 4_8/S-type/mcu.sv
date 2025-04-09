module mcu(
    input logic clk,
    input logic rst
);
    logic [31:0] instrCode, instrMemAddr;
    logic dataWe;
    logic [31:0] dataAddr, datawData;

    RV32I_Core CORE(.*);

    rom InstMem(
        .addr(instrMemAddr),
        .rdata(instrCode)
    );

    ram DataMem(
        .clk(clk),
        .we(dataWe),
        .addr(dataAddr),
        .wData(datawData),
        .rData()
    );

endmodule