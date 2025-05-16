`timescale 1ns/1ps

module top(
    input clk,
    input rst,
    input start,
    input [13:0] number,
    output [3:0] fndCom,
    output [7:0] fndFont
);

    wire SCLK, MOSI, MISO,CS, ready, done, o_start;

    parameter IDLE = 0, L=1, H=2;
    reg [7:0] low_reg, low_next;
    reg [7:0] high_reg, high_next;
    reg [1:0] state, state_next;
    wire [7:0] font;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= 0;
            low_reg <=0;
            high_reg <=0;
        end else begin
            state <= state_next;
            low_reg <= low_next;
            high_reg <= high_next;
        end
    end
    
    always @(*) begin
        state_next =state;
        low_next =low_reg;
        high_next = high_reg;
        case(state)
            IDLE: begin
                if(o_start) state_next =L;
            end
            L: begin
                if(done) begin
                    state_next = H;
                    low_next = font;
                end
            end
            H: begin
                if(done) begin
                    state_next =IDLE;
                    high_next =font;
                end
            end
        endcase
    end


    top_master U_TOP_MASTER(
        .clk(clk),
        .rst(rst),
        .start(start),
        .number(number),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .done(done),
        .CS(CS),
        .o_start(o_start)
    );


    spi_slave U_SPI_SLAVE(
        .SCLK(SCLK),
        .rst(rst),
        .CS(CS),
        .MOSI(MOSI),
        .MISO(MISO),
        .font(font)
    );
    
    fndController U_FND(
        .clk(clk),
        .reset(rst),
        .low(low_reg),
        .high(high_reg),
        .fndFont(fndFont),
        .fndCom(fndCom)
    );


endmodule

