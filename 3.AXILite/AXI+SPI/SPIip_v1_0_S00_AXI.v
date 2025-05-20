`timescale 1 ns / 1 ps

module SPI_v1_0_S00_AXI #(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 4
) (
    output wire CPOL,
    output wire CPHA,
    output wire START,
    output wire [7:0] SOD,
    input wire [7:0] SID,
    input wire SR,

    input wire S_AXI_ACLK,
    input wire S_AXI_ARESETN,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    input wire [2 : 0] S_AXI_AWPROT,
    input wire S_AXI_AWVALID,
    output wire S_AXI_AWREADY,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input wire S_AXI_WVALID,
    output wire S_AXI_WREADY,
    output wire [1 : 0] S_AXI_BRESP,
    output wire S_AXI_BVALID,
    input wire S_AXI_BREADY,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    input wire [2 : 0] S_AXI_ARPROT,
    input wire S_AXI_ARVALID,
    output wire S_AXI_ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    output wire [1 : 0] S_AXI_RRESP,
    output wire S_AXI_RVALID,
    input wire S_AXI_RREADY
);

    // AXI4LITE signals

    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
    reg axi_awready;
    reg axi_wready;
    reg [1 : 0] axi_bresp;
    reg axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
    reg axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0] axi_rdata;
    reg [1 : 0] axi_rresp;
    reg axi_rvalid;

    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH / 32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 1;

    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg0;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg1;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg2;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg3;
    wire slv_reg_rden;
    wire slv_reg_wren;
    reg [C_S_AXI_DATA_WIDTH-1:0] reg_data_out;
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
    // Implement axi_awready generation

    // axi_awready is asserted for one S_AXI_ACLK clock cycle when both

    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is

    // de-asserted when reset is low.


    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_awready <= 1'b0;
            aw_en <= 1'b1;
        end else begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
                axi_awready <= 1'b1;
                aw_en <= 1'b0;
            end else if (S_AXI_BREADY && axi_bvalid) begin
                aw_en <= 1'b1;
                axi_awready <= 1'b0;
            end else begin
                axi_awready <= 1'b0;
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

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
        end else begin
            if (slv_reg_wren) begin
                case (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
                    2'h0:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                    if (S_AXI_WSTRB[byte_index] == 1) begin
                        // Respective byte enables are asserted as per write strobes 

                        // Slave register 0

                        slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    end
                    2'h1:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                    if (S_AXI_WSTRB[byte_index] == 1) begin
                        // Respective byte enables are asserted as per write strobes 

                        // Slave register 1

                        slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    end
                    2'h2:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                    if (S_AXI_WSTRB[byte_index] == 1) begin
                        // Respective byte enables are asserted as per write strobes 

                        // Slave register 2

                        slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    end
                    2'h3:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
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


    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_bvalid <= 0;
            axi_bresp  <= 2'b0;
        end else begin
            if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)

	        begin
                // indicates a valid write response is available

                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b0;  // 'OKAY' response 

            end                   // work error responses in future

	      else

	        begin
                if (S_AXI_BREADY && axi_bvalid) 

	            //check if bready is asserted while bvalid is high) 

	            //(there is a possibility that bready is always asserted high)   

	            begin
                    axi_bvalid <= 1'b0;
                end
            end
        end
    end

    // Implement axi_arready generation

    // axi_arready is asserted for one S_AXI_ACLK clock cycle when

    // S_AXI_ARVALID is asserted. axi_awready is 

    // de-asserted when reset (active low) is asserted. 

    // The read address is also latched when S_AXI_ARVALID is 

    // asserted. axi_araddr is reset to zero on reset assertion.


    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_arready <= 1'b0;
            axi_araddr  <= 32'b0;
        end else begin
            if (~axi_arready && S_AXI_ARVALID) begin
                // indicates that the slave has acceped the valid read address

                axi_arready <= 1'b1;
                // Read address latching

                axi_araddr  <= S_AXI_ARADDR;
            end else begin
                axi_arready <= 1'b0;
            end
        end
    end

    // Implement axi_arvalid generation

    // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 

    // S_AXI_ARVALID and axi_arready are asserted. The slave registers 

    // data are available on the axi_rdata bus at this instance. The 

    // assertion of axi_rvalid marks the validity of read data on the 

    // bus and axi_rresp indicates the status of read transaction.axi_rvalid 

    // is deasserted on reset (active low). axi_rresp and axi_rdata are 

    // cleared to zero on reset (active low).  

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_rvalid <= 0;
            axi_rresp  <= 0;
        end else begin
            if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
                // Valid read data is available at the read data bus

                axi_rvalid <= 1'b1;
                axi_rresp  <= 2'b0;  // 'OKAY' response

            end else if (axi_rvalid && S_AXI_RREADY) begin
                // Read data is accepted by the master

                axi_rvalid <= 1'b0;
            end
        end
    end

    // Implement memory mapped register select and read logic generation

    // Slave register read enable is asserted when valid address is available

    // and the slave is ready to accept the read address.

    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
    always @(*) begin
        // Address decoding for reading registers

        case (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
            2'h0   : reg_data_out <= slv_reg0;
            2'h1   : reg_data_out <= slv_reg1;
            2'h2   : reg_data_out <= {23'b0, SID};
            2'h3   : reg_data_out <= {31'b0, SR};
            default : reg_data_out <= 0;
        endcase
    end

    // Output register or memory read data

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
    assign CPOL = slv_reg0[2];
    assign CPHA = slv_reg0[1];
    assign START = slv_reg0[0];
    assign SOD = slv_reg1[7:0];



    // User logic ends


endmodule

module SPI_Master (
    // global signal

    input            clk,
    input            reset,
    // internal signal

    input            CPOL,
    input            CPHA,
    input            start,
    input      [7:0] tx_data,
    output     [7:0] rx_data,
    output reg       done,
    output reg       ready,
    // external signal

    output           SCLK,
    output           MOSI,
    input            MISO
);

    localparam IDLE = 0, CP_DELAY = 1, CP0 = 2, CP1 = 3;

    reg [1:0] state, state_next;
    reg [7:0] temp_tx_data_reg, temp_tx_data_next;
    reg [5:0] sclk_counter_reg, sclk_counter_next;
    reg [2:0] bit_counter_reg, bit_counter_next;
    reg [7:0] temp_rx_data_reg, temp_rx_data_next;

    wire r_sclk;

    assign r_sclk = ((state == CP1) && !CPHA) || ((state == CP0) && CPHA);

    assign MOSI = temp_tx_data_reg[7];
    assign rx_data = temp_rx_data_reg;
    assign SCLK = CPOL ? ~r_sclk : r_sclk;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state            <= IDLE;
            temp_tx_data_reg <= 0;
            temp_rx_data_reg <= 0;
            sclk_counter_reg <= 0;
            bit_counter_reg  <= 0;
        end else begin
            state            <= state_next;
            temp_tx_data_reg <= temp_tx_data_next;
            temp_rx_data_reg <= temp_rx_data_next;
            sclk_counter_reg <= sclk_counter_next;
            bit_counter_reg  <= bit_counter_next;
        end
    end

    always @(*) begin
        state_next = state;
        done = 0;
        ready = 0;
        temp_tx_data_next = temp_tx_data_reg;
        temp_rx_data_next = temp_rx_data_reg;
        sclk_counter_next = sclk_counter_reg;
        bit_counter_next = bit_counter_reg;

        case (state)
            IDLE: begin
                temp_tx_data_next = 8'b0;
                done = 0;
                ready = 1;
                if (start) begin
                    state_next        = CPHA ? CP_DELAY : CP0;
                    ready             = 0;
                    temp_tx_data_next = tx_data;
                    sclk_counter_next = 0;
                    bit_counter_next  = 0;
                end
            end

            CP_DELAY: begin
                if (sclk_counter_reg == 50 - 1) begin
                    state_next = CP0;
                    sclk_counter_next = 0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end

            CP0: begin
                if (sclk_counter_reg == 50 - 1) begin
                    state_next = CP1;
                    temp_rx_data_next = {temp_rx_data_reg[6:0], MISO};
                    sclk_counter_next = 0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end

            CP1: begin
                if (sclk_counter_reg == 50 - 1) begin
                    if (bit_counter_reg == 8 - 1) begin
                        done = 1;
                        state_next = IDLE;
                    end else begin
                        sclk_counter_next = 0;
                        temp_tx_data_next = {temp_tx_data_reg[6:0], 1'b0};
                        state_next = CP0;
                        bit_counter_next = bit_counter_reg + 1;
                    end
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
        endcase
    end
endmodule
