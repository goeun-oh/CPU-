`timescale 1ns/1ps

module SPI_Master(
    input clk,
    input reset,
    input [7:0] tx_data,
    output tx_done,
    output ready,
    input start,
    input i2c_en,
    input stop,
    output SCL,
    inout SDA
);



endmodule