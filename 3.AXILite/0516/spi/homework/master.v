`timescale 1ns / 1ps
module master (
    input         clk,
    input         rst,
    input         start,
    input  [13:0] number,
    output        o_start,
    output [ 7:0] tx_data,
    input  [ 7:0] rx_data,
    input         done,
    output        CS
);

    parameter IDLE = 0, L_BYTE = 1, H_BYTE = 2;
    reg [1:0] state, state_next;
    reg [7:0] tx_reg, tx_next;
    wire [3:0] digit1, digit10, digit100, digit1000;
    reg cs_reg, cs_next;

    assign tx_data = tx_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state  <= IDLE;
            tx_reg <= 0;
            cs_reg <= 1'b1;
        end else begin
            state  <= state_next;
            tx_reg <= tx_next;
            cs_reg <= cs_next;
        end
    end

    always @(*) begin
        state_next = state;
        tx_next = tx_reg;
        cs_next = cs_reg;
        case (state)
            IDLE: begin
                cs_next = 1'b1;
                if (o_start) begin
                    state_next = L_BYTE;
                end
            end
            L_BYTE: begin
                cs_next = 1'b0;
                tx_next = {digit10, digit1};
                if (done) begin
                    state_next = H_BYTE;
                end
            end
            H_BYTE: begin
                cs_next = 1'b0;
                tx_next = {digit1000, digit100};
                if (done) begin
                    state_next = IDLE;
                end
            end
        endcase
    end



    digitSplitter U_digitSplitter (
        .i_digit     (number),
        .o_digit_1   (digit1),
        .o_digit_10  (digit10),
        .o_digit_100 (digit100),
        .o_digit_1000(digit1000)
    );


    btn_debounce U_BTN_DEBOUNCE (
        .clk  (clk),
        .reset(rst),
        .i_btn(start),
        .o_btn(o_start)
    );
endmodule

module digitSplitter (
    input  [13:0] i_digit,
    output [ 3:0] o_digit_1,
    output [ 3:0] o_digit_10,
    output [ 3:0] o_digit_100,
    output [ 3:0] o_digit_1000
);

    assign o_digit_1 = i_digit % 10;
    assign o_digit_10 = i_digit / 10 % 10;
    assign o_digit_100 = i_digit / 100 % 10;
    assign o_digit_1000 = i_digit / 1000 % 10;
endmodule
