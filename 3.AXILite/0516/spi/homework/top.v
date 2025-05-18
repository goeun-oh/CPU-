`timescale 1ns / 1ps
module top (
    input         clk,
    input         rst,
    input         btn,
    input  [13:0] number,
    output [ 3:0] fndCom,
    output [ 7:0] fndFont
);
    wire CS, SCLK, done, start;
    wire MOSI, MISO;
    wire [7:0] DATA, tx_data;
    wire [15:0] fndData;

    spi_ctrl U_SPI_CTRL (
        .clk    (clk),
        .rst    (rst),
        .btn    (btn),
        .number (number),
        .CS     (CS),
        .done   (done),
        .DATA   (DATA),
        .tx_data(tx_data),
        .start  (start),
        .fndData(fndData)
    );

    spi_master U_SPI_Master (
        .clk    (clk),
        .rst    (rst),
        .SCLK   (SCLK),
        .tx_data(tx_data),
        .start  (start),
        .ready  (),
        .done   (done),
        .rx_data(),
        .MOSI   (MOSI),
        .CS     (CS),
        .MISO   (MISO)
    );

    spi_slave U_SPI_SLAVE (
        .SCLK(SCLK),
        .CS  (CS),
        .MOSI(MOSI),
        .DATA(DATA),
        .MISO(MISO)
    );

    fndController U_FND (
        .clk    (clk),
        .reset  (rst),
        .fndData(fndData),
        .fndFont(fndFont),
        .fndCom (fndCom)
    );


endmodule
