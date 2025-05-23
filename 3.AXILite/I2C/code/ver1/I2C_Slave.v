`timescale 1ns/1ps

module I2C_Slave(
    input clk,
    input reset,
    input SCL,
    inout SDA,
    output [7:0] LED
);
    parameter IDLE=0, ADDR=1, WAIT=2, ACK=3, READ=4, DATA=5, READ_ACK=6, DATA_ACK = 7, STOP=8;

    reg [3:0] state, state_next;
    reg [7:0] temp_rx_data_reg, temp_rx_data_next;
    reg [7:0] temp_tx_data_reg, temp_tx_data_next;
    reg [7:0] temp_addr_reg, temp_addr_next;
    reg [3:0] bit_counter_reg, bit_counter_next;
    reg en;
    reg o_data;
    reg read_ack_reg, read_ack_next;
    
    reg sclk_sync0, sclk_sync1;
    wire sclk_rising, sclk_falling;
    reg [7:0] slv_reg0_reg, slv_reg0_next;

    reg [7:0] led_reg, led_next;
    assign SDA= en? o_data: 1'bz;
    assign LED=led_reg;

    //always @(posedge clk or posedge reset) begin
    //    if(reset) begin
    //        state <= IDLE;
    //        sclk_sync0 <=0;
    //        sclk_sync1 <=0;
    //        temp_rx_data_reg <=0;
    //        temp_tx_data_reg <=0;
    //        bit_counter_reg <=0;
    //        temp_addr_reg <=0;
    //        led_reg <=0;
    //        slv_reg0_reg <=0;
    //    end else begin
    //        state <= state_next;
    //        sclk_sync0 <= SCL;
    //        sclk_sync1 <= sclk_sync0;
    //        temp_rx_data_reg <= temp_rx_data_next;
    //        temp_tx_data_reg <= temp_tx_data_next;
    //        bit_counter_reg <= bit_counter_next;
    //        temp_addr_reg <= temp_addr_next;
    //        led_reg <= led_next;
    //        slv_reg0_reg <= slv_reg0_next;
    //    end
    //end

    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            state <= IDLE;
            sclk_sync0 <=1;
            sclk_sync1 <=1;
            temp_rx_data_reg <=0;
            temp_tx_data_reg <=0;
            bit_counter_reg <=0;
            temp_addr_reg <=0;
            led_reg <=0;
            slv_reg0_reg <=0;
            read_ack_reg <=1'bz;
        end else begin
            state <= state_next;
            sclk_sync0 <= SCL;
            sclk_sync1 <= sclk_sync0;
            temp_rx_data_reg <= temp_rx_data_next;
            temp_tx_data_reg <= temp_tx_data_next;
            bit_counter_reg <= bit_counter_next;
            temp_addr_reg <= temp_addr_next;
            led_reg <= led_next;
            slv_reg0_reg <= slv_reg0_next;
            read_ack_reg <= read_ack_next;
        end
    end

    assign sclk_rising = sclk_sync0 & ~sclk_sync1;
    assign sclk_falling = ~sclk_sync0 & sclk_sync1;

    always @(*) begin
        state_next = state;
        en = 1'b0;
        o_data = 1'b0;
        temp_rx_data_next = temp_rx_data_reg;
        temp_tx_data_next = temp_tx_data_reg;
        bit_counter_next = bit_counter_reg;
        temp_addr_next = temp_addr_reg;
        slv_reg0_next = slv_reg0_reg;
        read_ack_next=read_ack_reg;
        case (state)
            IDLE: begin
                if(SCL && ~SDA) begin
                    state_next = ADDR;
                    bit_counter_next = 0;
                end
            end
            ADDR: begin
                if(sclk_rising) begin
                    temp_addr_next = {temp_addr_reg[6:0], SDA};
                    if (bit_counter_reg == 8-1) begin
                        bit_counter_next = 0;
                        state_next = WAIT;
                    end else begin
                        bit_counter_next = bit_counter_reg + 1;
                    end
                end
            end
            WAIT: begin
                if(sclk_falling) begin
                    state_next =ACK;
                end
            end
            ACK: begin
                if (temp_addr_reg[7:1] == 7'b1010101) begin
                    en = 1'b1;
                    o_data =1'b0;
                    if(sclk_falling) begin
                        if(temp_addr_reg[0]) begin
                            state_next= READ;
                            temp_tx_data_next = slv_reg0_reg;
                        end else begin
                            state_next=DATA;
                        end
                    end
                end else begin
                    state_next= IDLE;
                end
            end
            READ: begin
                en=1'b1;
                o_data = temp_tx_data_reg[7];
                if(sclk_falling) begin
                    if (bit_counter_reg == 8-1) begin
                        bit_counter_next = 0;
                        state_next = READ_ACK;
                    end else begin
                        temp_tx_data_next = {temp_tx_data_reg[6:0], 1'b0};
                        bit_counter_next = bit_counter_reg + 1;
                    end
                end
            end
            READ_ACK: begin
                en=1'b0;
                if(sclk_rising) begin
                    read_ack_next= SDA;
                end
                if(sclk_falling) begin
                    if(read_ack_reg ==1'b0)
                        state_next = STOP;
                end
            end
            DATA: begin
                if(sclk_rising) begin
                    temp_rx_data_next = {temp_rx_data_reg[6:0], SDA};
                end
                if (sclk_falling) begin
                    if (bit_counter_reg == 8-1) begin
                        bit_counter_next = 0;
                        state_next = DATA_ACK;
                    end else begin
                        bit_counter_next = bit_counter_reg + 1;
                    end
                end
            end
            DATA_ACK: begin
                en=1'b1;
                o_data =1'b0;
                if(sclk_falling) begin
                    state_next= STOP;
                end
            end
            STOP: begin
                if(SDA && SCL) begin
                    state_next = IDLE;
                    led_next = temp_rx_data_reg;
                    slv_reg0_next = temp_rx_data_reg;
                end
            end
        endcase
    end

endmodule