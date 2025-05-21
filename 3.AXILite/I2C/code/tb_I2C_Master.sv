`timescale 1ns/1ps
module tb_I2C_Master();
    logic       clk;
    logic       reset;
    logic [7:0] tx_data;
    logic       tx_done;
    logic       ready;
    logic       start;
    logic       i2c_en;
    logic       stop;
    logic       SCL;
    tri1 SDA;
 
    always #5 clk= ~clk;
    initial begin
        clk =0; reset =1;
        #10 reset =0;
        start = 1; tx_data = 8'b10101010; i2c_en = 1; stop =0;
        #10;
        @(ready);
        #20;
        i2c_en=0;
        @(tx_done);
        @(ready);
        start = 0; stop = 0; i2c_en = 1; tx_data= 8'hff;
        #10;
        @(ready);
        i2c_en =0;
        @(tx_done);
        start =0; stop =1; i2c_en = 1;
    end

    I2C_Master DUT(.*);
    I2C_Slave Slave(.*);
endmodule