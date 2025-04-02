`timescale 1ns / 1ps

module top_counter_up_down (
    input        clk,
    input        reset,
    input  [2:0] sw,
    output [3:0] fndCom,
    output [7:0] fndFont
);
    wire [13:0] fndData;
    wire [3:0] fndDot;
    wire w_run, w_clear, w_mode;

    counter_up_down U_Counter (
        .clk  (clk),
        .reset(reset),
        .mode (w_mode),
        .run (w_run),
        .clear(w_clear),
        .count(fndData),
        .dot_data(fndDot)
    );

    
    CU U_CU(
        .clk(clk),
        .rst(reset),
        .sw(sw),
        .run(w_run),
        .clear(w_clear),
        .mode(w_mode)
    );

    fndController U_FndController (
        .clk(clk),
        .reset(reset),
        .fndData(fndData),
        .fndDot(fndDot),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );
    

endmodule

module CU(
    input clk,
    input rst,
    input [2:0] sw,
    output run,
    output clear,
    output mode
);
    assign mode=sw[0];
    parameter STOP=2'b00, RUN=2'b01, CLEAR=2'b10;
    reg [1:0] state, next;
    reg run_reg, run_next;
    reg clear_reg, clear_next;

    assign run =run_reg;
    assign clear =clear_reg;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state <=0;
            run_reg <=0;
            clear_reg <=0;
        end else begin
            state <=next;
            run_reg <=run_next;
            clear_reg <=clear_next;
        end
    end

    always @(*) begin
        next =state;
        run_next =run_reg;
        clear_next=clear_reg;
        case(state)
            STOP: begin
                run_next=0;
                clear_next=0;
                if(sw[1]) begin
                    next= RUN;
                end else if(sw[2]) begin
                    next= CLEAR;
                end
            end
            RUN: begin
                run_next=1;
                clear_next=0;
                if(!sw[1]) begin
                    next= STOP;
                end else if(sw[2]) begin
                    next= CLEAR;
                end
            end
            CLEAR: begin
                clear_next=1;
                run_next=0;
                if(!sw[2]) begin
                    if(sw[1]) begin
                        next= RUN;
                    end else begin
                        next=STOP;
                    end
                end
            end
        endcase
    end
endmodule


module counter_up_down (
    input         clk,
    input         reset,
    input         mode,
    input         run,
    input         clear,
    output [13:0] count,
    output [3:0] dot_data
);
    wire tick;

    clk_div_10hz U_Clk_Div_10Hz (
        .clk  (clk),
        .reset(reset),
        .run (run),
        .tick (tick)
    );

    counter U_Counter_Up_Down (
        .clk  (clk),
        .reset(reset),
        .tick (tick),
        .mode (mode),
        .clear(clear),
        .count(count)
    );
    
    comp_dot U_COMP_DATA(
        .count(count),
        .dot_data(dot_data)
    );
endmodule


module counter (
    input         clk,
    input         reset,
    input         tick,
    input         mode,
    input         clear,
    output [13:0] count
);
    reg [$clog2(10000)-1:0] counter;

    assign count = counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else begin
            if(!clear) begin
                if (mode == 1'b0) begin
                    if (tick) begin
                        if (counter == 9999) begin
                            counter <= 0;
                        end else begin
                            counter <= counter + 1;
                        end
                    end
                end else begin
                    if (tick) begin
                        if (counter == 0) begin
                            counter <= 9999;
                        end else begin
                            counter <= counter - 1;
                        end
                    end
                end
            end
            else begin
                counter <=0;
            end
        end
    end
endmodule

module clk_div_10hz (
    input  wire clk,
    input  wire reset,
    input run,
    output reg  tick
);
    reg [$clog2(10_000_000)-1:0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if(run) begin
                if (div_counter == 10_000_000 - 1) begin
                    div_counter <= 0;
                    tick <= 1'b1;
                end else begin
                    div_counter <= div_counter + 1;
                    tick <= 1'b0;
                end
            end
        end
    end
endmodule


module comp_dot(
    input [13:0] count,
    output [3:0] dot_data
);
    assign dot_data = (count % 10) < 5 ? 4'b1101:4'b1111;
    
endmodule