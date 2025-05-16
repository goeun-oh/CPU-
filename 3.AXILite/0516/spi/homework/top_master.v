`timescale 1ns/1ps

module top_master(
    input clk,
    input rst,
    input start,
    input [13:0] number,
    output SCLK,
    output MOSI,
    input MISO,
    output o_start,
    output CS,
    output done
);

    wire i_CS;
    wire [7:0] tx_data, rx_data;

    master U_MASTER(
        .clk(clk),
        .rst(rst),
        .start(start),
        .number(number),
        .o_start(o_start),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .done(done),
        .CS(i_CS)
    );

    spi_master U_SPI_MASTER(
        .clk(clk),
        .rst(rst),
        .i_CS(i_CS),
        .SCLK(SCLK),
        .tx_data(tx_data),
        .start(o_start),
        .ready(ready),
        .done(done),
        .rx_data(rx_data),
        .MOSI(MOSI),
        .CS(CS),
        .MISO(MISO)
    );


endmodule