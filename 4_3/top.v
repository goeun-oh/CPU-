`timescale 1ns / 1ps

module top(
    input clk,
    input rst,
    input rx,
    input btn_L,
    input btn_R,
    input btn_U,
    input btn_D,
    output tx,
    output [3:0] fndCom,
    output [7:0] fndFont
    );
    wire o_btn_L, o_btn_R, o_btn_U, o_btn_D;
    wire [3:0] fndDot;
    
    btn_debounce BTN_L(
        .clk(clk),
        .rst(rst),
        .i_btn(btn_L),
        .o_btn(o_btn_L)
    );
    btn_debounce BTN_R(
        .clk(clk),
        .rst(rst),
        .i_btn(btn_R),
        .o_btn(o_btn_R)
    );
    btn_debounce BTN_U(
        .clk(clk),
        .rst(rst),
        .i_btn(btn_U),
        .o_btn(o_btn_U)
    );
    btn_debounce BTN_D(
        .clk(clk),
        .rst(rst),
        .i_btn(btn_D),
        .o_btn(o_btn_D)
    );


    top_counter_up_down updownCounter(
        .clk(clk),
        .reset(rst),
        .fndFont(fndFont),
        .fndDot(fndDot)
    );

    wire [7:0] tx_data;
    wire [7:0] rx_data;
    wire       rx_done;
    wire       tx_start;
    wire       tx_busy;
    wire       tx_done;

    control_unit U_ControlUnit (
        .clk     (clk),
        .reset   (reset),
        .btn_L   (o_btn_L), //mode
        .btn_R   (o_btn_R), //run/stop
        .btn_D   (o_btn_D), //clear
        .btn_U   (o_btn_U), //up/down
        //tx side port
        .tx_data (tx_data),
        .tx_start(tx_start),
        .tx_busy (tx_busy),
        .tx_done (tx_done),
        //rx side port
        .rx_data (rx_data),
        .rx_done (rx_done),
        //data path side
        .en      (en),
        .clear   (clear),
        .mode    (mode)
    );
    
    uart U_uart (
        //global port
        .clk(clk),
        .reset(reset),
        //tx port
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx(tx),
        //rx port
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    fndController U_FndController (
        .clk    (clk),
        .reset  (reset),
        .fndData(fndData),
        .fndDot (fndDot),
        .fndCom (fndCom),
        .fndFont(fndFont)
    );

endmodule


module btn_debounce(
    input clk,
    input rst,
    input i_btn,
    output o_btn
);
    parameter FCOUNT=100_000_000/1_000; //1khz

    reg [$clog2(FCOUNT)-1:0] count_1khz;
    reg tick_1khz;
    reg [7:0] shift_reg, shift_next;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            shift_reg <=0;
        end else begin
            shift_reg <= shift_next;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count_1khz <=0;
            tick_1khz <=1'b0;
        end else begin
            if(count_1khz == FCOUNT-1) begin
                count_1khz <=0;
                tick_1khz <=1'b1;
            end else begin
                count_1khz <= count_1khz +1;
                tick_1khz <= 1'b0;
            end
        end
    end

    
    always @(*) begin
        shift_next=shift_reg;
        if (tick_1khz) begin
            shift_next = {i_btn, shift_reg[7:1]};
        end
    end

    wire o_combi;
    reg q;
    assign o_combi= &shift_reg;
    
    assign o_btn = o_combi | q;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            q<=0;
        end else begin
            q<=o_combi;
        end
    end





endmodule