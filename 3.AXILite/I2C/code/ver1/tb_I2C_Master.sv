`timescale 1ns/1ps
module tb_I2C_Master();
    logic       clk;
    logic       reset;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic       tx_done;
    logic       ready;
    logic       start;
    logic       i2c_en;
    logic       stop;
    logic       SCL;
    logic [7:0] LED;
    tri1 SDA;
 
    always #5 clk= ~clk;
    initial begin
        clk =0; reset =1;
        #10 reset =0;
        @(posedge clk) reset=1;
        start = 1; tx_data = 8'b10101010; i2c_en = 1; stop =0;
        #10;
        @(ready);
        start =0; stop=0; 

        #10;
        @(!ready);
        #10;
        @(ready);
        #10;
        @(!ready);
        wait(ready ==1);
        tx_data = 8'h01;
        @(ready);
        start=0; stop=1;
        @(ready);

        @(ready);
        start = 1; tx_data = 8'b10101011; i2c_en = 1; stop =0;
        #10;
        start=0; stop=0;
        #10;
        #10;
        start=1; stop=1;
  
    end

    I2C_Master DUT(.*);
    I2C_Slave U_Slave(.*);
endmodule