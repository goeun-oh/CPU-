module tb_AXI4_Lite_GPIO ();

    logic        ACLK;
    logic        ARESETn;
    logic [ 3:0] AWADDR;
    logic        AWVALID;
    logic        AWREADY;
    logic [31:0] WDATA;
    logic        WVALID;
    logic        WREADY;
    logic [ 1:0] BRESP;
    logic        BVALID;
    logic        BREADY;
    logic [ 3:0] ARADDR;
    logic        ARVALID;
    logic        ARREADY;
    logic [31:0] RDATA;
    logic        RVALID;
    logic        RREADY;
    logic [ 1:0] RRESP;
    wire  [ 7:0] io_port;
    logic [ 7:0] io_port_input;
    logic [ 7:0] io_port_mode;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin
            assign io_port[i] = (io_port_mode[i] == 0) ? io_port_input[i] : 1'bz;
        end
    endgenerate

    always #5 ACLK = ~ACLK;

    initial begin
        ACLK = 0;
        ARESETn = 0;
        #10 ARESETn = 1;

        //mode값 output 으로 설정

        @(posedge ACLK);
        #1;
        AWADDR  = 0;
        AWVALID = 1;
        WDATA   = 8'hff;
        WVALID  = 1;
        BREADY  = 1;
        wait (WREADY && WVALID);
        @(posedge ACLK);
        AWVALID = 0;
        WVALID  = 0;
        wait (BVALID);
        @(posedge ACLK);
        BREADY = 0;
        @(posedge ACLK);

        //write

        @(posedge ACLK);
        #1;
        AWADDR  = 4;
        AWVALID = 1;
        WDATA   = 8'haa;
        WVALID  = 1;
        BREADY  = 1;
        wait (WREADY && WVALID);
        @(posedge ACLK);
        AWVALID = 0;
        WVALID  = 0;
        wait (BVALID);
        @(posedge ACLK);
        BREADY = 0;
        @(posedge ACLK);

        @(posedge ACLK);
        #1;
        AWADDR  = 4;
        AWVALID = 1;
        WDATA   = 8'h55;
        WVALID  = 1;
        BREADY  = 1;
        wait (WREADY && WVALID);
        @(posedge ACLK);
        AWVALID = 0;
        WVALID  = 0;
        wait (BVALID);
        @(posedge ACLK);
        BREADY = 0;
        @(posedge ACLK);

        //mode 값 input으로 설정        

        @(posedge ACLK);
        #1;
        AWADDR  = 0;
        AWVALID = 1;
        WDATA   = 8'h00;
        WVALID  = 1;
        BREADY  = 1;
        wait (WREADY && WVALID);
        @(posedge ACLK);
        AWVALID = 0;
        WVALID  = 0;
        wait (BVALID);
        @(posedge ACLK);
        BREADY = 0;
        @(posedge ACLK);

        //read

        io_port_mode  = 8'h00;
        io_port_input = 8'h12;

        @(posedge ACLK);
        #1;
        ARADDR  = 8;
        ARVALID = 1;
        RREADY  = 1;
        wait (ARREADY);
        @(posedge ACLK);
        ARVALID = 0;
        wait (RVALID);
        @(posedge ACLK);
        RREADY = 0;
        @(posedge ACLK);

        io_port_mode  = 8'h00;
        io_port_input = 8'h34;

        @(posedge ACLK);
        #1;
        ARADDR  = 8;
        ARVALID = 1;
        RREADY  = 1;
        wait (ARREADY);
        @(posedge ACLK);
        ARVALID = 0;
        wait (RVALID);
        @(posedge ACLK);
        RREADY = 0;  //address 처리되고 data처리되고 순서/

        @(posedge ACLK);

        #50 $finish;
    end


    AXI4_Lite_GPIO dut (.*);
endmodule
