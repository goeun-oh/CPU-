
`timescale 1 ns / 1 ps

module GPIO_v1_0_S00_AXI
#(
	// Users to add parameters here
	// User parameters ends
	// Do not modify the parameters beyond this line
	// Width of S_AXI data bus
	parameter integer C_S_AXI_DATA_WIDTH = 32,
	parameter integer C_S_AXI_ADDR_WIDTH =4
	//parameter integer 32	= 32,
	// Width of S_AXI address bus
	//parameter integer 4	= 4
)
(
    // Users to add ports here
	output [7:0] moder,
    output [7:0] odr,
    input  [7:0] idr,
    // User ports ends
    // Do not modify the ports beyond this line
    // Global Clock Signal
    input wire S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input wire [4-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
    // privilege and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
    // valid write address and control information.
    input wire S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
    // to accept an address and associated control signals.
    output wire S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave) 
    input wire [32-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
    // valid data. There is one write strobe bit for each eight
    // bits of the write data bus.    
    input wire [(32/8)-1 : 0] S_AXI_WSTRB, //4bit 짜리
    // Write valid. This signal indicates that valid write
    // data and strobes are available.

    input wire S_AXI_WVALID,
    // Write ready. This signal indicates that the slave

    // can accept the write data.

    output wire S_AXI_WREADY,
    // Write response. This signal indicates the status

    // of the write transaction.

    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel

    // is signaling a valid write response.

    output wire S_AXI_BVALID,
    // Response ready. This signal indicates that the master

    // can accept a write response.

    input wire S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)

    input wire [4-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege

    // and security level of the transaction, and whether the

    // transaction is a data access or an instruction access.

    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel

    // is signaling valid read address and control information.

    input wire S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is

    // ready to accept an address and associated control signals.

    output wire S_AXI_ARREADY,
    // Read data (issued by slave)

    output wire [32-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the

    // read transfer.

    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is

    // signaling the required read data.

    output wire S_AXI_RVALID,
    // Read ready. This signal indicates that the master can

    // accept the read data and response information.

    input wire S_AXI_RREADY
);

    // AXI4LITE signals

    reg [4-1 : 0] axi_awaddr;
    reg axi_awready;
    reg axi_wready;
    reg [1 : 0] axi_bresp;
    reg axi_bvalid;
    reg [4-1 : 0] axi_araddr;
    reg axi_arready;
    reg [32-1 : 0] axi_rdata;
    reg [1 : 0] axi_rresp;
    reg axi_rvalid;

    // Example-specific design signals

    // local parameter for addressing 32 bit / 64 bit 32

    // 2 is used for addressing 32/64 bit registers/memories

    // 2 = 2 for 32 bits (n downto 2)

    // 2 = 3 for 64 bits (n downto 3)

    //localparam integer 2 = (32/32) + 1;

    //localparam integer 1 = 1;

    //----------------------------------------------

    //-- Signals for user logic register space example

    //------------------------------------------------

    //-- Number of Slave Registers 4

    reg [32-1:0] slv_reg0;
    reg [32-1:0] slv_reg1;
    reg [32-1:0] slv_reg2;
    reg [32-1:0] slv_reg3;
    wire slv_reg_rden;
    wire slv_reg_wren;
    reg [32-1:0] reg_data_out;
    integer byte_index;
    reg aw_en;

    // I/O Connections assignments


    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BRESP   = axi_bresp;
    assign S_AXI_BVALID  = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA   = axi_rdata;
    assign S_AXI_RRESP   = axi_rresp;
    assign S_AXI_RVALID  = axi_rvalid;


// WA Channel //
    // Implement axi_awready generation : awready 만드는 코드 -> awready만 1 or 0 인지 정해주는 블록
    // axi_awready is asserted for one S_AXI_ACLK clock cycle when both 
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is de-asserted when reset is low. : addr와 data를 동시에 보내는 중인거임

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_awready <= 1'b0;
            aw_en <= 1'b1; //write address enable : write transaction이 start 될 수 있음을 의미
        end else begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
                // slave is ready to accept write address when 
                // there is a valid write address and write data
                // on the write address and data bus. This design 
                // expects no outstanding transactions. 
                axi_awready <= 1'b1;
                aw_en <= 1'b0; //transaction이 시작됐다면 aw_en이 0이 됨으로써 이 다음에 들어오는 transaction이 무시되게된다.
            end else if (S_AXI_BREADY && axi_bvalid) begin 
				//response 값이 handshaking 이 일어났을 때 (write transaction이 다 끝날 때) aw_en이 다시 1이 된다. (다시 transaction이 start될 수 있게한다.)
				aw_en <= 1'b1;
                axi_awready <= 1'b0;
            end else begin
                axi_awready <= 1'b0;
				//awready는 1clk만 asserted
            end
        end
    end

    // Implement axi_awaddr latching
    // This process is used to latch the address when both 
    // S_AXI_AWVALID and S_AXI_WVALID are valid. 
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_awaddr <= 0;
        end else begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
                // Write Address latching 
                axi_awaddr <= S_AXI_AWADDR;
            end
        end
    end

// W Channel //
    // Implement axi_wready generation
    // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
    // de-asserted when reset is low. 
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_wready <= 1'b0;
        end else begin
            if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en) begin
                // slave is ready to accept write data when 
                // there is a valid write address and write data
                // on the write address and data bus. This design 
                // expects no outstanding transactions. 
                axi_wready <= 1'b1;
            end else begin
                axi_wready <= 1'b0;
            end
        end
    end

    // Implement memory mapped register select and write logic generation
    // The write data is accepted and written to memory mapped registers when
    // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
    // select byte enables of slave registers while writing.
    // These registers are cleared when reset (active low) is applied.
    // Slave register write enable is asserted when valid address and data are available
    // and the slave is ready to accept the write address and write data.

    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;
	// awready && awvalid : AW channel handshaking 발생. -> write 하려는 주소 (awaddr) 를 알고 있다.
	//wready && wvalid : W channel 에 대한 handshaking 발생 -> write 하려는 값 (wdata)를 알고 있다.
	// -> 이 조건 만족 시 slv_regx에 wdata 저장.

	//wstrb있는 이유: c언어에서 char, int, short.. 등등이 차지하는 bit수 다르다., 자료형에 따라 strb 선택해주면 된다.
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
        end else begin
            if (slv_reg_wren) begin
                case (axi_awaddr[2+1:2])
                    2'h0:
                    for(byte_index = 0;byte_index <= (32 / 8) - 1;byte_index = byte_index + 1) //for문이 0,1,2,3 이렇게 4번 돈다.
                    if (S_AXI_WSTRB[byte_index] == 1) begin
                        // Respective byte enables are asserted as per write strobes 
                        // Slave register 0
                        slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
						// ex) slv_reg0[0+:8] : 0을포함해서 8개 vector
                    end
                    2'h1:
                    for (byte_index = 0;byte_index <= (32 / 8) - 1;byte_index = byte_index + 1)
                    if (S_AXI_WSTRB[byte_index] == 1) begin
                        // Respective byte enables are asserted as per write strobes 
                        // Slave register 1
                        slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    end
                    2'h2:
                    for (byte_index = 0;byte_index <= (32 / 8) - 1;byte_index = byte_index + 1)
                    if (S_AXI_WSTRB[byte_index] == 1) begin
                        // Respective byte enables are asserted as per write strobes 
                        // Slave register 2
                        slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    end
                    2'h3:
                    for (byte_index = 0;byte_index <= (32 / 8) - 1;byte_index = byte_index + 1)
                    if (S_AXI_WSTRB[byte_index] == 1) begin
                        // Respective byte enables are asserted as per write strobes 
                        // Slave register 3
                        slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    end
                    default: begin
                        slv_reg0 <= slv_reg0;
                        slv_reg1 <= slv_reg1;
                        slv_reg2 <= slv_reg2;
                        slv_reg3 <= slv_reg3;
                    end
                endcase
            end
        end
    end

    // Implement write response logic generation
    // The write response and response valid signals are asserted by the slave 
    // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
    // This marks the acceptance of address and indicates the status of 
    // write transaction.

	//b valid 신호 결정//
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_bvalid <= 0;
            axi_bresp  <= 2'b0;
        end else begin
            if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) //aw handshaking, w handshaking 발생 & b channel만 안일어남
	        begin
                // indicates a valid write response is available
                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b0;  // 'OKAY' response 
            end                   // work error responses in future
	      else
	        begin
                if (S_AXI_BREADY && axi_bvalid) //b handshaking이 발생하면 bvalid 0으로
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
                    axi_bvalid <= 1'b0;
                end
            end
        end
    end


// read transfer//
    // Implement axi_arready generation
    // axi_arready is asserted for one S_AXI_ACLK clock cycle when
    // S_AXI_ARVALID is asserted. axi_awready is 
    // de-asserted when reset (active low) is asserted. 
    // The read address is also latched when S_AXI_ARVALID is 
    // asserted. axi_araddr is reset to zero on reset assertion.
    
	//read address ready를 결정//
	always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_arready <= 1'b0;
            axi_araddr  <= 32'b0;
        end else begin
            if (~axi_arready && S_AXI_ARVALID) begin //ARVALID 1 : 유효한 read address가 들어올 때 & read transaction 이 가능할 떄
                // indicates that the slave has acceped the valid read address
                axi_arready <= 1'b1;
                // Read address latching
                axi_araddr  <= S_AXI_ARADDR;
            end else begin
                axi_arready <= 1'b0;
            end
        end
    end

    // Implement axi_rvalid generation
    // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
    // S_AXI_ARVALID and axi_arready are asserted. The slave registers 
    // data are available on the axi_rdata bus at this instance. The 
    // assertion of axi_rvalid marks the validity of read data on the 
    // bus and axi_rresp indicates the status of read transaction.axi_rvalid 
    // is deasserted on reset (active low). axi_rresp and axi_rdata are 
    // cleared to zero on reset (active low).  
    
	//rvalid 결정//
	always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_rvalid <= 0;
            axi_rresp  <= 0;
        end else begin
            if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin //arready, arvalid =1: 주소가 저장이 됐고, read data 전송이 안된 경우
                // Valid read data is available at the read data bus
                axi_rvalid <= 1'b1;
                axi_rresp  <= 2'b0;  // 'OKAY' response
            end else if (axi_rvalid && S_AXI_RREADY) begin //r handshake 발생하면 rvalid 0
                // Read data is accepted by the master
                axi_rvalid <= 1'b0;
            end
        end
    end

    // Implement memory mapped register select and read logic generation
    // Slave register read enable is asserted when valid address is available
    // and the slave is ready to accept the read address.

	// rdata 결정 //
    always @(*) begin
        // Address decoding for reading registers
        case (axi_araddr[2+1:2])
            2'h0   : reg_data_out <= slv_reg0;
            2'h1   : reg_data_out <= slv_reg1;
            2'h2   : reg_data_out <= {24'b0,idr}; //slv_reg2;
            2'h3   : reg_data_out <= slv_reg3;
            default : reg_data_out <= 0;
        endcase
    end

    // Output register or memory read data
    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_rdata <= 0;
        end else begin
            // When there is a valid read address (S_AXI_ARVALID) with 
            // acceptance of read address by the slave (axi_arready), 
            // output the read dada 
            if (slv_reg_rden) begin
                axi_rdata <= reg_data_out;  // register read data
            end
        end
    end

    // Add user logic here
    assign moder         = slv_reg0[7:0];
    assign odr           = slv_reg1[7:0];
    //assign slv_reg2[7:0] = idr;


    // User logic ends


endmodule
