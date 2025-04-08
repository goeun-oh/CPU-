module tb_mcu();

    logic clk;
    logic rst;

    always #5 clk= ~clk;

    initial begin
        clk =0; rst=1;
        #10 rst=0;
    end

    mcu DUT(.*);

endmodule
