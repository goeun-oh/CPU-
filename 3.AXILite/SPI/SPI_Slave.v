`timescale 1ns / 1ps

module SPI_Slave_Intf (
    input        SCLK,
    input        MOSI,
    output       MISO,
    input        SS,
    output [7:0] wdata,
    input  [7:0] rdata,
    output [1:0] addr,
    output       done
);

endmodule


module SPI_RegisterFile (
    input        write,
    input  [1:0] addr,
    input  [7:0] wdata,
    output [7:0] rdata
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
        end
    end

endmodule
