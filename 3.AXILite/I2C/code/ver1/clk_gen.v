`timescale 1ns/1ps

module clk_gen(
    input clk,
    input en,
    input reset,
    output reg o_clk,
    output reg tick_sample
);
    parameter FCOUNT = 1000, CLK0= 250, CLK1=500, CLK2=750;

    reg [$clog2(FCOUNT)-1:0] counter_reg;

    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            counter_reg <=0;
            o_clk <=0;
            tick_sample <=1;
        end else begin
            if(en) begin
                if(counter_reg >= 0 && counter_reg < CLK0-1) begin
                    counter_reg <= counter_reg +1;
                    o_clk <=0;
                    tick_sample <=0;
                end else if(counter_reg >= CLK0-1 && counter_reg < CLK1-1) begin
                    counter_reg <= counter_reg +1;
                    o_clk <=1;
                    tick_sample <=0;
                end else if(counter_reg >= CLK1-1 && counter_reg < CLK2-1) begin
                    counter_reg <= counter_reg +1;
                    o_clk <=1;
                    tick_sample <=0;
                end else if (counter_reg >= CLK2-1 && counter_reg < FCOUNT-1) begin
                    counter_reg <= counter_reg +1;
                    o_clk <=0;
                    tick_sample <=0;
                end else if (counter_reg == FCOUNT -1)begin
                    counter_reg <= 0;
                    o_clk <=0;
                    tick_sample <=1;
                end
            end else begin
                counter_reg <= 0;
                o_clk <=0;
                tick_sample <=1;
            end
        end
    end

endmodule