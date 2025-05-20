`timescale 1ns / 1ps

module SPI_Master (
    // global signal
    input            clk,
    input            rst,
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
    
    assign r_sclk = ((state == CP1) && !CPHA)||((state == CP0) && CPHA);

    assign MOSI = temp_tx_data_reg[7];
    assign rx_data = temp_rx_data_reg;
    assign SCLK = CPOL ? ~r_sclk : r_sclk; 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
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
                    state_next = CPHA ? CP_DELAY : CP0;
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
