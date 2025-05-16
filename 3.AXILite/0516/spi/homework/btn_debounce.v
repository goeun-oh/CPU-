`timescale 1ns / 1ps


module btn_debounce(
    input clk,
    input reset,
    input i_btn,
    output o_btn
    );
    wire btn_debounce;

    // state
    reg [7:0] q_reg, q_next;
    reg edge_detect;
    reg r_1khz;

    // 1khz clk
    parameter COUNT =100_000;
    reg [$clog2(COUNT)-1:0] counter;
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            counter <= 0;
            r_1khz=1'b0;
        end else begin
            if (counter == COUNT -1) begin
                counter <=0;
                r_1khz <=1'b1;
            end else begin
                counter <= counter +1;
                r_1khz <=1'b0;
            end
        end

    end

    always @(posedge r_1khz or posedge reset) begin
        if(reset) q_reg <=0;
        else q_reg <= q_next;
    end
    // next logic
    always @(i_btn, r_1khz) begin
        q_next = {i_btn, q_reg[7:1]};
    end 
    
    // 8 input AND gate
    assign btn_debounce = ~&q_reg;

    //edge detector

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            edge_detect <= 0;
        end else begin
            edge_detect <= btn_debounce;
        end
    end

    //edge detector 최종 출력
    assign o_btn =(~edge_detect) & btn_debounce;


endmodule
