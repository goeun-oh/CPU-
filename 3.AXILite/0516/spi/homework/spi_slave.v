`timescale 1ns / 1ps

module spi_slave (
    input              SCLK,
    input              CS,
    input              MOSI,
    output      [7:0] DATA,
    output wire        MISO
);
 //   parameter IDLE=0, RUN=1;

    reg shift_in;
    reg [7:0] shift_reg;
   // reg state;

    assign MISO = CS ? 1'bz : shift_reg[7];
    assign DATA  = CS? shift_reg: 8'b0;
    
    // always @(*) begin
    //     if(rst) state = IDLE;
    //     case(state)
    //         IDLE: begin
    //             if(!CS) begin
    //                 state = RUN;
    //                 shift_in = MOSI;
    //             end
    //         end
    //         RUN: begin
    //             if(CS) begin
    //                 state = IDLE;
    //             end
    //         end
    //     endcase
    // end
    always @(posedge SCLK) begin
        shift_in <= MOSI;
    end

    always @(negedge SCLK) begin
        shift_reg <= {shift_reg[6:0], shift_in};
    end
endmodule
