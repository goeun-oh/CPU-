`timescale 1ns / 1ps

module spi_master (
    input        clk,
    input        rst,
    output       SCLK,
    input  [7:0] tx_data,
    input        start,
    output       ready,
    output       done,
    output [7:0] rx_data,
    output       MOSI,
    output       CS,
    input        MISO
);


    parameter IDLE = 2'b00, CP0 = 2'b01, CP1 = 2'b10;

    reg [1:0] state, state_next;

    reg [7:0] temp_tx_data_reg, temp_tx_data_next;
    reg [7:0] rx_data_reg, rx_data_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg [$clog2(50)-1:0] clk_count_reg, clk_count_next;
    reg sclk_reg, sclk_next;
    reg cs_reg, cs_next;
    reg done_reg, done_next;
    reg ready_reg, ready_next;

    assign SCLK = sclk_reg;
    assign CS = cs_reg;
    assign MOSI = temp_tx_data_reg[7];
    assign rx_data = rx_data_reg;
    assign ready = ready_reg;
    assign done = done_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            temp_tx_data_reg <= 8'bz;
            sclk_reg <= 1'b0;
            cs_reg <= 1'b1;
            clk_count_reg <= 0;
            rx_data_reg <= 0;
            bit_count_reg <= 0;
            done_reg <= 0;
            ready_reg <= 1'b1;
        end else begin
            state <= state_next;
            temp_tx_data_reg <= temp_tx_data_next;
            sclk_reg <= sclk_next;
            cs_reg <= cs_next;
            clk_count_reg <= clk_count_next;
            rx_data_reg <= rx_data_next;
            bit_count_reg <= bit_count_next;
            done_reg <= done_next;
            ready_reg <= ready_next;
        end
    end


    always @(*) begin
        state_next = state;
        temp_tx_data_next = temp_tx_data_reg;
        sclk_next = sclk_reg;
        cs_next = cs_reg;
        clk_count_next = clk_count_reg;
        rx_data_next = rx_data_reg;
        bit_count_next = bit_count_reg;
        done_next = done_reg;
        ready_next = ready_reg;
        case (state)
            IDLE: begin
                temp_tx_data_next = 8'bz;
                sclk_next = 1'b0;
                cs_next = 1'b1;
                clk_count_next = 0;
                bit_count_next = 0;
                done_next = 1'b0;
                ready_next = 1'b1;
                if (start) begin
                    state_next = CP0;
                    cs_next = 1'b0;
                    temp_tx_data_next = tx_data;
                    ready_next = 1'b0;
                end
            end
            CP0: begin
                sclk_next = 1'b0;
                if (clk_count_reg == 50 - 1) begin
                    clk_count_next = 0;
                    rx_data_next = {rx_data_reg[6:0], MISO};
                    state_next = CP1;
                end else begin
                    clk_count_next = clk_count_reg + 1;
                end
            end
            CP1: begin
                sclk_next = 1'b1;
                if (clk_count_reg == 50 - 1) begin
                    clk_count_next = 0;
                    if (bit_count_reg == 8 - 1) begin
                        state_next = IDLE;
                        done_next  = 1'b1;
                    end else begin
                        bit_count_next = bit_count_next + 1;
                        clk_count_next = 0;
                        state_next = CP0;
                        temp_tx_data_next = {temp_tx_data_reg[6:0], 1'b0};
                    end
                end else begin
                    clk_count_next = clk_count_next + 1;
                end
            end
        endcase
    end



endmodule
