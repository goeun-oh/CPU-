`timescale 1ns / 1ps

module fndController(
    input clk,
    input rst,
    input [13:0] fndData,
    output [3:0] fndCom,
    output [7:0] fndFont
    );

    wire tick;
    wire [1:0] count_4;

    wire [3:0] w_digit_1;
    wire [3:0] w_digit_10;
    wire [3:0] w_digit_100;
    wire [3:0] w_digit_1000;

    wire [3:0] i_bcd;
    clk_div_1khz U_CLK_DIV_1KHZ (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    counter_2bit CONTER_2BIT(
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .count(count_4)
    );

    decoder_2X4 DECODER_2X4(
        .x(count_4),
        .y(fndCom)
    );
    digitSplitter U_digit_splitter(
        .fndData(fndData),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );

    mux_4X1 U_MUX (
        .sel(count_4),
        .x0(w_digit_1),
        .x1(w_digit_10),
        .x2(w_digit_100),
        .x3(w_digit_1000),
        .y(i_bcd)
    );


    BCDtoSEG BCDTOSEG(
        .bcd(i_bcd),
        .seg(fndFont)
    );
endmodule


module clk_div_1khz (
    input clk,
    input rst,
    output reg tick
);
    reg [$clog2(100_000)-1:0] div_counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            div_counter <=0;
            tick <=1'b0;
        end else begin
            if(div_counter == 100_000-1) begin
                div_counter <=0;
                tick <=1'b1;
            end else begin
                div_counter <= div_counter +1;
                tick <=1'b0;
            end
        end
    end
endmodule


module counter_2bit(
    input clk,
    input rst,
    input tick,
    output reg [1:0] count
);
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            count <=0;
        end else begin
            if (tick) begin
                count <= count +1;
            end
        end
    end

endmodule


module decoder_2X4(
    input [1:0] x,
    output reg [3:0] y
);
    always @(*) begin
        y=4'b1111;
        case(x)
            2'b00: y=4'b1110;
            2'b01: y=4'b1101;
            2'b10: y=4'b1011;
            2'b11: y=4'b0111;
        endcase
    end

    // latch를 방지 하는 방법: default 값을 넣거나 case 위에 기본 default 값을 넣어버린다.
    // 후자로 하는 방법이 더 많다.
endmodule


module digitSplitter(
    input [13:0] fndData,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);
    assign digit_1 = fndData % 10;
    assign digit_10 = fndData/10 % 10;
    assign digit_100 = fndData/100 % 10;
    assign digit_1000 = fndData/1000 % 10;
    
endmodule


module mux_4X1 (
    input [1:0] sel,
    input [3:0] x0,
    input [3:0] x1,
    input [3:0] x2,
    input [3:0] x3,
    output reg [3:0] y
);
    always @(*) begin
        //지금은 경우의 수가 있지만 만약 경우의 수가 모두 지정이 안되어있다면 latch 방지를 위해 넣는다
        y=4'b0000;
        case(sel)
            2'b00: y=x0;
            2'b01: y=x1;
            2'b10: y=x2;
            2'b11: y=x3;
        endcase
    end
    
endmodule



module BCDtoSEG(
    input [3:0] bcd,
    output reg[7:0] seg
    );

    always @(bcd) begin
        case(bcd)
        4'h0: seg= 8'hc0;
        4'h1: seg= 8'hf9;
        4'h2: seg = 8'ha4;
        4'h3: seg=8'hb0;
        4'h4: seg=8'h99;
        4'h5: seg=8'h92;
        4'h6: seg=8'h82;
        4'h7: seg=8'hf8;
        4'h8: seg=8'h80;
        4'h9: seg=8'h90;
        4'ha: seg=8'h88;
        4'hb: seg=8'h83;
        4'hc: seg=8'hc6;
        4'hd: seg=8'ha1;
        4'he: seg=8'h86;
        4'hf: seg=8'h8e;

        default:seg=8'hff;
        endcase
    end
endmodule