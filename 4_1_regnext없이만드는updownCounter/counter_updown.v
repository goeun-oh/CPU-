`timescale 1ns / 1ps
module top_counter (
    input clk,
    input rst,
    input mode,
    output [3:0] fndCom,
    output [7:0] fndFont
);
    wire [13:0] count;
    
    counter_updown COUNT_UPDOWN(
        .clk(clk),
        .rst(rst),
        .mode(mode),
        .count(count)
    );

    fndController FNDController(
        .clk(clk),
        .rst(rst),
        .fndData(count),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );

endmodule

module counter_updown(
    input clk,
    input rst,
    input mode,
    output [13:0] count
    );

    wire tick;
    clk_div_10hz U_CLK_DIV_10HZ(
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    counter U_COUNTER(
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .mode(mode),
        .count(count)
    );

endmodule

module counter(
    input clk,
    input rst,
    input tick,
    input mode,
    output [13:0] count
);
    reg[$clog2(10_000)-1:0] counter;
    assign count = counter;
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            counter <=0;
        end else begin
            if (tick) begin
                if (!mode) begin
                    if(counter == 9999) begin
                        counter <=0;
                    end else begin
                        counter <= counter +1;
                    end
                end else begin
                    if(counter == 0) begin
                        counter <=9999;
                    end else begin
                        counter <= counter -1;
                    end
                end
            end
        end
    end
endmodule

module clk_div_10hz (
    input clk,
    input rst,
    output reg tick
);
    //100_000_000 : 1hz,
    // 10_000_000 : 10hz
    reg [$clog2(10_000_000)-1:0] div_counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            div_counter <=0;
            tick <=1'b0;
        end else begin
            if(div_counter == 10_000_000 -1) begin
                div_counter <=0;
                tick <=1'b1;
            end else begin
                div_counter <= div_counter +1;
                tick <= 1'b0;
            end
        end
    end
    
endmodule