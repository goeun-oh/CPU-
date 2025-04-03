`timescale 1ns / 1ps
module top_counter_up_down (
    input        clk,
    input        reset,
    input        updown,
    input        mode,
    input        clear,
    input        run,   
    output [13:0] fndData,
    output [3:0] fndDot
);
    counter_up_down U_Counter (
        .clk     (clk),
        .reset   (reset),
        .en      (run),
        .clear   (clear),
        .up_down (updown),
        .mode    (mode),
        .count   (fndData),
        .dot_data(fndDot)
    );
endmodule

module stop_watch(
    input clk,
    input rst,
    input run,
    input clear,
    output [13:0] fndData,
    output [3:0] fndDOt
);
    counter_up_down U_Counter (
        .clk     (clk),
        .reset   (reset),
        .en      (run),
        .clear   (clear),
        .up_down (updown),
        .mode    (mode),
        .count   (fndData),
        .dot_data(fndDot)
    );
endmodule



