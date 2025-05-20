`timescale 1ns / 1ps

module SPI_Slave_Intf (
    input        SCLK,
    input        rst,
    input        MOSI,
    output       MISO,
    input        SS,
    output [7:0] wdata,
    input  [7:0] rdata,
    output [1:0] addr,
    output       done
);
    localparam SO_IDLE =0, SO_DATA=1;

    wire rden;
    
    reg state, state_next;
    reg [7:0] temp_tx_data_reg, temp_tx_data_next;
    reg [7:0] temp_rx_data_reg, temp_rx_data_next;
    
    assign MISO = SS? 1'bz: temp_tx_data_reg[7];

    // MOSI sequence
    always @(posedge SCLK) begin
        if (!SS) begin
            temp_rx_data_reg <= {temp_rx_data_reg[6:0], MOSI};
        end    
    end

    // MISO sequence
    always @(negedge SCLK) begin
        if (!SS) begin
            temp_tx_data_reg <= {temp_tx_data_reg[6:0], 1'b0};
        end
    end

    always @(*) begin
        state_next = state;
        temp_tx_data_next = temp_tx_data_reg;
        case (state)
            SO_IDLE: begin
                if (!SCLK) begin
                    if(!SS && rden) begin
                        temp_tx_data_next = rdata;
                        state_next = SO_DATA;
                    end
                end
            end
            SO_DATA: begin
                if(!SS && rden) begin
                    
                end                
            end
        endcase
    end


endmodule


module SPI_RegisterFile (
    input        write,
    input  [1:0] addr,
    input  [7:0] wdata,
    output reg [7:0] rdata
);
    reg [7:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;

    always @(*) begin
        if (write) begin
            case (addr)
                2'b00: slv_reg0 = wdata;
                2'b01: slv_reg1 = wdata;
                2'b10: slv_reg2 = wdata;
                2'b11: slv_reg3 = wdata;
            endcase
        end else begin
            case(addr)
                2'b00: rdata =slv_reg0;
                2'b01: rdata =slv_reg1;
                2'b10: rdata =slv_reg2;
                2'b11: rdata =slv_reg3;
            endcase
        end
    end

endmodule
