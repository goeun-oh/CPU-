`timescale 1ns / 1ps

module spi_slave (
    input        SCLK,
    input        rst,
    input        CS,
    input        MOSI,
    output       MISO,
    output [7:0] font
);


    parameter IDLE = 0, RUN = 1;

    reg state, state_next;
    reg [7:0] slv_reg, slv_reg_next;
    reg [7:0] temp_slv_reg, temp_slv_reg_next;

    assign MISO= temp_slv_reg[7];
    assign font = slv_reg;

    always @(posedge SCLK or posedge rst or negedge SCLK) begin
        if (rst) begin
            state <= IDLE;
            slv_reg <= 0;
            temp_slv_reg <= 0;
        end else begin
            state <=state_next;
            slv_reg <= slv_reg_next;
            temp_slv_reg <= temp_slv_reg_next;
        end
    end

    


    always @(*) begin
        state_next = state;
        slv_reg_next = slv_reg;
        temp_slv_reg_next = temp_slv_reg;
        case (state)
            IDLE: begin
                temp_slv_reg = 8'bz;
                if (!CS) begin
                    state_next = RUN;
                    slv_reg_next ={slv_reg[6:0], MOSI};
                    temp_slv_reg_next = slv_reg;
                end
            end
            RUN: begin
                if (!CS) begin
                    if(SCLK) begin
                        slv_reg_next = {slv_reg[6:0], MOSI};
                    end else begin
                        temp_slv_reg_next = {temp_slv_reg[6:0], 1'b0};
                    end
                end else begin
                    state_next = IDLE;
                end
            end
        endcase
    end



endmodule
