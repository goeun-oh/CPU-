`timescale 1ns / 1ps

module timer_Periph (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY
);

    logic en;
    logic clear;
    logic [31:0] TCNT;
    logic [31:0] PSC;
    logic [31:0] ARR;

    timer_SlaveIntf U_timer_Intf (.*);

    timer U_timer (
        .*,
        .clk    (PCLK),
        .reset  (PRESET),
        .psc    (PSC),
        .arr    (ARR),
        .counter(TCNT)
    );
endmodule

module timer_SlaveIntf (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // internal signals
    output logic en,
    output logic clear,
    output logic [31:0] TCNT,
    output logic [31:0] PSC,
    output logic [31:0] ARR
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;


    assign en  = slv_reg0[0];
    assign clear = slv_reg0[1];
    assign TCNT = slv_reg1;
    assign PSC  = slv_reg2;
    assign ARR  = slv_reg3;


    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            //slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
        end else begin
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1:; //slv_reg1 <= PWDATA;
                        2'd2: slv_reg2 <= PWDATA;
                        2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                        2'd2: PRDATA <= slv_reg2;
                        2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end

endmodule

module timer (
    input  logic        clk,
    input  logic        reset,
    input  logic        en,
    input  logic        clear,
    input  logic [31:0] psc,
    input  logic [31:0] arr,
    output logic [31:0] counter
);
    logic tick;

    clk_div U_CLK_DIV (.*);
    counter U_COUNTER (.*);


endmodule


module clk_div (
    input logic clk,
    input logic reset,
    input logic en,
    input logic clear,
    input logic [31:0] psc,
    output logic tick
);
    logic [31:0] count_reg, count_next;
    logic tick_reg, tick_next;

    assign tick = tick_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            tick_reg  <= 0;
            count_reg <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    always_comb begin
        count_next = count_reg;
        tick_next  = 1'b0;
        if (en) begin
            if (count_reg == psc - 1) begin
                count_next = 0;
                tick_next  = 1'b1;
            end else begin
                count_next = count_next + 1;
                tick_next  = 1'b0;
            end
        end if (clear) begin
            count_next = 0;
        end
    end
endmodule

module counter (
    input  logic        clk,
    input  logic        reset,
    input  logic        clear,
    input  logic        tick,
    input  logic [31:0] arr,
    output logic [31:0] counter
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else if (tick) begin
            if (counter == arr) begin
                counter <= 0;
            end else begin
                if (clear)  counter <=0;
                else counter <= counter + 1;
            end
        end 
    end

endmodule
