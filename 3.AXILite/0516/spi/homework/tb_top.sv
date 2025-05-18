`timescale 1ns/1ps

module tb_top();
    logic        clk;
    logic        rst;
    logic        btn;
    logic [13:0] number;
    logic [ 3:0] fndCom;
    logic [ 7:0] fndFont;

    always #5 clk= ~clk;
    
    initial begin
        clk =0; rst=0;
        @(posedge clk);
        rst=1;
        @(posedge clk);
        rst=0; number=16'haabb;
        #10;    
        btn=1;
        #100;
        btn=0;

    
    end

    top U_TOP(.*);
endmodule