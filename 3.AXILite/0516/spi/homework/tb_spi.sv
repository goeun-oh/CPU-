`timescale 1ns/1ps

module tb_spi();
    logic       clk;
    logic       rst;
    logic       SCLK;
    logic [7:0] tx_data;
    logic       start;
    logic       ready;
    logic       done;
    logic [7:0] rx_data;
    logic       MOSI;
    logic       CS;
    logic       MISO;
    logic [15:0] DATA;

    always #5 clk= ~clk;

    initial begin
        clk =0; rst=0;
        @(posedge clk);
        rst=1;
        @(posedge clk);
        rst=0;
        #10;
        start = 1'b1; tx_data= 8'haa;
        #10;
        start = 1'b0; 
        @(ready)
        #100;
        #100;
        start = 1'b1; tx_data = 8'h00;
        #10;
        start = 1'b0;
    end

    spi_master U_SPI_MASTER (
        .*
    );
    spi_slave U_SPI_SLAVE(
        .*
    );
endmodule