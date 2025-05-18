`timescale 1ns / 1ps

module fndController (
    input         clk,
    input         reset,
    input  [15:0] fndData,
    output [ 7:0] fndFont,
    output [ 3:0] fndCom
);

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] w_digit;
    wire o_clk;
    wire [1:0] sel;

    clk_divider U_Clk_Divider (
        .clk  (clk),
        .reset(reset),
        .o_clk(o_clk)
    );
    counter_4 U_Counter_4 (
        .clk  (o_clk),
        .reset(reset),
        .o_sel(sel)
    );
    decoder U_Decoder (
        .x(sel),
        .y(fndCom)
    );

    digitSplitter U_DIGIT (
        .i_digit   (fndData),
        .o_digit_1 (w_digit_1),
        .o_digit_10(w_digit_10),
        .o_digit_100 (w_digit_100),
        .o_digit_1000(w_digit_1000)
    );


    mux U_Mux (
        .sel(sel),
        .x0 (w_digit_1),
        .x1 (w_digit_10),
        .x2 (w_digit_100),
        .x3 (w_digit_1000),
        .y  (w_digit)
    );

    BCDtoSEG U_BcdToSeg (
        .bcd(w_digit),
        .seg(fndFont)
    );

endmodule



module counter_4 (
    input clk,
    input reset,
    output [1:0] o_sel
);
    reg [1:0] r_counter;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 2'b00;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
    //overflow가 발생해도 0,1,2,3 안에서 반복된다. (순환)
    assign o_sel = r_counter;
endmodule

module clk_divider (
    input  clk,
    input  reset,
    output o_clk
);
    parameter FCOUNT = 500_000;
    reg r_clk;
    reg [$clog2(FCOUNT)-1:0] r_counter;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk <= 1'b0;
        end else begin
            if (r_counter == FCOUNT - 1) begin
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
                r_clk <= 1'b0;
                r_counter <= r_counter + 1;
            end
        end
    end
    assign o_clk = r_clk;

endmodule
module decoder (
    input [1:0] x,
    output reg [3:0] y
);
    always @(x) begin
        case (x)
            2'b00: y = 4'b1110;
            2'b01: y = 4'b1101;
            2'b10: y = 4'b1011;
            2'b11: y = 4'b0111;
        endcase
    end
endmodule

module mux (
    input [1:0] sel,
    input [3:0] x0,
    input [3:0] x1,
    input [3:0] x2,
    input [3:0] x3,
    output reg [3:0] y
);

    always @(*) begin
        case (sel)
            2'b00:   y = x0;
            2'b01:   y = x1;
            2'b10:   y = x2;
            2'b11:   y = x3;
            default: y = x0;
        endcase
    end
endmodule

module BCDtoSEG (
    input [3:0] bcd,
    output reg [7:0] seg
);

    always @(bcd) begin
        case (bcd)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hf9;
            4'h2: seg = 8'ha4;
            4'h3: seg = 8'hb0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'ha: seg = 8'h88;
            4'hb: seg = 8'h83;
            4'hc: seg = 8'hc6;
            4'hd: seg = 8'ha1;
            4'he: seg = 8'h86;
            4'hf: seg = 8'h8e;

            default: seg = 8'hff;
        endcase
    end
endmodule

module digitSplitter (
    input  [15:0] i_digit,
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
