`timescale 1ns / 1ps

module tb_AXI4_Lite ();

    // Global Signals
    logic        ACLK;
    logic        ARESETn;
    // WRITE Transaction, AW Channel
    logic [ 3:0] AWADDR;
    logic        AWVALID;
    logic        AWREADY;
    // WRITE Transaction, W Channel
    logic [31:0] WDATA;
    logic        WVALID;
    logic        WREADY;
    // WRITE Transaction, B Channel
    logic [ 1:0] BRESP;
    logic        BVALID;
    logic        BREADY;

    // internal signals
    logic        transfer;
    logic        ready;
    logic [ 3:0] addr;
    logic [31:0] wdata;
    logic        write;
    logic [31:0] rdata;

    AXI4_Lite_Master dut_master (.*);
    AXI4_Lite_Slave dut_slave (.*);

    always #5 ACLK = ~ACLK;

    initial begin
        ACLK = 0; ARESETn =0;
        #10 ARESETn =1;

        @(posedge ACLK);
        #1 addr = 0; wdata = 32'd10; write =1; transfer =1;
        @(posedge ACLK);
        #1 transfer =0;
        wait(ready == 1);
        @(posedge ACLK);
        #1 addr = 4; wdata = 32'd15; write =1; transfer =1;
        @(posedge ACLK);
        #1 transfer =0;
        wait(ready == 1);
        @(posedge ACLK);
        #1 addr = 8; wdata = 32'd20; write =1; transfer =1;
        @(posedge ACLK);
        #1 transfer =0;
        wait(ready == 1);
        @(posedge ACLK);
        #1 addr = 12; wdata = 32'd25; write =1; transfer =1;
        @(posedge ACLK);
        #1 transfer =0;
        wait(ready == 1);

        #200 $finish;
    end
endmodule
