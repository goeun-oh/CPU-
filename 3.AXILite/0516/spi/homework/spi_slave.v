`timescale 1ns / 1ps

module spi_slave (
    input              SCLK,
    input              CS,
    input              MOSI,
    output      [7:0] DATA,
    output wire        MISO
);

    reg shift_in;
    reg [7:0] shift_reg;

    assign MISO = CS ? 1'bz : shift_reg[7];
    assign DATA  = CS? shift_reg: 8'b0;
    
    always @(posedge SCLK) begin
        shift_in <= MOSI;
    end

    always @(negedge SCLK) begin
        if(!CS) begin
            shift_reg <= {shift_reg[6:0], shift_in};
        end
    end
endmodule
