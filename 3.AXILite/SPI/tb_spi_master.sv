`timescale 1ns/1ps

module  tb_spi_master();
    logic       clk;
    logic       rst;
    logic       start;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic       done;
    logic       ready;
    logic       SCLK;
    logic       MOSI;
    logic       MISO;
    logic CPOL;
    logic CPHA;

    always #5 clk = ~clk;

    initial begin
        clk =0; rst=1;
        #10 rst =0; CPOL = 0; CPHA = 0;
        
        repeat (3) @(posedge clk);

        start = 1; tx_data = 8'haa; 
        @(posedge clk);
        start =0;
        wait(done);
        @(posedge clk);

        start = 1; tx_data = 8'hbb; CPOL = 1;
        @(posedge clk);
        start =0;
        wait(done);
        @(posedge clk);

        #50 $finish;
    end

    SPI_Master U_SPI_Master(
        .*,
        .MISO(MOSI)
    );

endmodule