`timescale 1ns / 1ps

module I2C_Master (
    input            clk,
    input            reset,
    input      [7:0] tx_data,
    output reg       tx_done,
    output reg       ready,
    input            start,
    input            i2c_en,
    input            stop,
    output reg       SCL,
    inout            SDA
);

    parameter IDLE=0, START1=1, START2=2, DATA1=3, DATA2=4, DATA3=5, DATA4=6, HOLD=7, ACK1=8, ACK2=9, ACK3=10, ACK4=11, STOP1=12, STOP2=13;
    parameter FCOUNT = 500;
    reg [3:0] state, state_next;
    reg o_data;
    reg en;
    reg [$clog2(FCOUNT)-1:0] sclk_counter_reg, sclk_counter_next;
    reg [7:0] temp_tx_data_reg, temp_tx_data_next;
    reg [3:0] bit_counter_reg, bit_counter_next;

    assign SDA = en ? o_data : 1'bz;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            sclk_counter_reg <= 0;
            temp_tx_data_reg <= 0;
            bit_counter_reg <= 0;
        end else begin
            state <= state_next;
            sclk_counter_reg <= sclk_counter_next;
            temp_tx_data_reg <= temp_tx_data_next;
            bit_counter_reg <= bit_counter_next;
        end
    end

    always @(*) begin
        state_next = state;
        sclk_counter_next = sclk_counter_reg;
        temp_tx_data_next = temp_tx_data_reg;
        bit_counter_next = bit_counter_reg;
        tx_done =0;
        o_data = 1'b1;
        ready = 0;
        SCL= 1'b0;
        en= 1'b1;
        case (state)
            IDLE: begin
                en = 1'b1;
                SCL = 1'b1;
                o_data = 1'b1;
                ready = 1;
                if (start && i2c_en) begin
                    state_next = START1;
                    sclk_counter_next = 0;
                    temp_tx_data_next = tx_data;
                    bit_counter_next = 0;
                end
            end
            START1: begin
                en = 1'b1;
                o_data = 1'b0;
                SCL = 1'b1;
                if (sclk_counter_reg == FCOUNT - 1) begin
                    state_next = START2;
                    sclk_counter_next = 0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            START2: begin
                en = 1'b1;
                o_data = 1'b0;
                SCL = 1'b0;
                if (sclk_counter_reg == FCOUNT - 1) begin
                    ready = 1;
                    if (i2c_en) begin
                        sclk_counter_next = 0;
                        state_next = DATA1;
                    end
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end

            DATA1: begin
                en = 1'b1;
                o_data = temp_tx_data_reg[7];
                SCL = 1'b0;
                if (sclk_counter_reg == 250 - 1) begin
                    state_next = DATA2;
                    sclk_counter_next = 0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            DATA2: begin
                en = 1'b1;
                o_data = temp_tx_data_reg[7];
                SCL = 1'b1;
                if (sclk_counter_reg == 250 - 1) begin
                    state_next = DATA3;
                    sclk_counter_next = 0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            DATA3: begin
                en = 1'b1;
                o_data = temp_tx_data_reg[7];
                SCL = 1'b1;
                if (sclk_counter_reg == 250 - 1) begin
                    state_next = DATA4;
                    sclk_counter_next = 0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            DATA4: begin
                en = 1'b1;
                o_data = temp_tx_data_reg[7];
                SCL = 1'b0;
                if (sclk_counter_reg == 250 - 1) begin
                    if (bit_counter_reg == 8 - 1) begin
                        state_next = ACK1;
                        tx_done = 1;
                        en = 1'b0;
                        sclk_counter_next = 0;
                        bit_counter_next =0;
                    end else begin
                        bit_counter_next = bit_counter_reg + 1;
                        sclk_counter_next = 0;
                        state_next = DATA1;
                        temp_tx_data_next = {temp_tx_data_reg[6:0], 1'b0};
                    end
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            ACK1: begin
                en = 1'b0;
                SCL=1'b0;
                if(sclk_counter_reg == 250 -1) begin
                    state_next = ACK2;
                    sclk_counter_next = 0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            ACK2: begin
                en = 1'b0;
                SCL = 1'b1;
                if(sclk_counter_reg == 250-1) begin
                    state_next = ACK3;
                    sclk_counter_next =0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            ACK3 : begin
                en=1'b0;
                SCL = 1'b1;
                if(sclk_counter_reg == 250-1) begin
                    state_next = ACK4;
                    sclk_counter_next =0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            ACK4 : begin
                en=1'b0;
                SCL = 1'b0;
                if(sclk_counter_reg == 250-1) begin
                    state_next = HOLD;
                    sclk_counter_next =0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            HOLD: begin
                en = 1'b1;
                SCL = 1'b0;
                o_data = 1'b0;
                ready = 1;
                tx_done = 0;
                if (i2c_en) begin
                    case ({
                        start, stop
                    })
                        2'b00: begin 
                            state_next = DATA1;
                            temp_tx_data_next = tx_data;
                        end
                        2'b10: state_next = START1;
                        2'b01: state_next = STOP1;
                    endcase
                end
            end
            STOP1: begin
                en = 1'b1;
                o_data = 1'b0;
                SCL = 1'b1;
                ready = 0;
                tx_done = 0;
                if (sclk_counter_next == FCOUNT - 1) begin
                    state_next = STOP2;
                    sclk_counter_next = 0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            STOP2: begin
                en = 1'b1;
                o_data = 1'b1;
                SCL = 1'b1;
                ready = 0;
                tx_done = 0;
                if (sclk_counter_next == FCOUNT - 1) begin
                    state_next = IDLE;
                    sclk_counter_next = 0;
                end else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
        endcase
    end

endmodule
