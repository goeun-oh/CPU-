`timescale 1ns / 1ps

module MCU (
    input logic clk,
    input logic reset
);
    //ROM Signals
    logic [31:0] instrCode;
    logic [31:0] instrMemAddr;
    //RAM Signals
    logic        dataWe;
    logic [31:0] dataAddr;
    logic [31:0] dataWData;
    logic [31:0] dataRData; 

    //APB Interface Signals
    logic        PCLK;
    logic        PRESET;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL_RAM;
    logic        PSEL1;
    logic        PSEL2;
    logic        PSEL3;
    logic [31:0] PRDATA_RAM;
    logic [31:0] PRDATA1;
    logic [31:0] PRDATA2;
    logic [31:0] PRDATA3;
    logic        PREADY_RAM;
    logic        PREADY1;
    logic        PREADY2;
    logic        PREADY3;
    //CPU-APB Master Signals
    logic        transfer;
    logic        ready;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic        write;  // 1:write, 0:read

    assign addr   = dataAddr;
    assign wdata  = dataWData;
    assign rdata  = dataRData;
    assign write  = dataWe;
    assign PCLK   = clk;
    assign PRESET = reset;

    RV32I_Core U_Core (.*);

    rom U_ROM (
        .addr(instrMemAddr),
        .data(instrCode)
    );


    ram U_RAM(
        .*,
        .PSEL(PSEL_RAM),
        .PRDATA(PRDATA_RAM),
        .PREADY(PREADY_RAM)
    );

    APB_Master U_APB_Master (
        .*,
        .PSEL0  (PSEL_RAM),
        .PSEL1  (),
        .PSEL2  (),
        .PSEL3  (),
        .PRDATA0(PRDATA_RAM),
        .PRDATA1(),
        .PRDATA2(),
        .PRDATA3(),
        .PREADY0(PREADY_RAM),
        .PREADY1(),
        .PREADY2(),
        .PREADY3()
    );

endmodule
