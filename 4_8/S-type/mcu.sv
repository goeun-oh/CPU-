module mcu (
    input logic clk,
    input logic reset
);
    logic [31:0] instrCode, instrMemAddr;
    logic dataWe;
    logic [31:0] dataAddr, datawData;
    logic [31:0] rData;

    RV32I_Core CORE (.*);

    rom InstMem (
        .addr(instrMemAddr),
        .data(instrCode)
    );

    ram DataMem (
        .clk(clk),
        .we(dataWe),
        .addr(dataAddr),
        .wData(datawData),
        .rData(rData)
    );

endmodule
