`timescale 1ns / 1ps

module spi_ctrl (
    input         clk,
    input         rst,
    input         btn,
    input  [13:0] number,
    input         CS,
    input         done,
    input  [7:0]  DATA,
    output        start,
    output [ 7:0] tx_data,
    output [15:0] fndData
);

    parameter IDLE = 0, L_BYTE = 1, L_DATA=2, H_BYTE = 3, H_DATA=4;
    wire o_btn;
    reg [2:0] state, state_next;
    reg [7:0] r_txData, n_txData;
    reg [7:0] r_lData, n_lData;
    reg [7:0] r_hData, n_hData;
    reg [15:0] r_fndData, n_fndData;
    reg rStart, nStart;

    assign fndData = r_fndData;
    assign start   = rStart;
    assign tx_data = r_txData;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            r_fndData <= 16'b0;
            r_lData   <= 8'b0;
            r_hData   <= 8'b0;
            r_txData  <= 8'b0;
            rStart    <= 0;
        end else begin
            state     <= state_next;
            r_fndData <= n_fndData;
            r_lData   <= n_lData;
            r_hData   <= n_hData;
            r_txData  <= n_txData;
            rStart    <= nStart;
        end
    end

    always @(*) begin
        state_next = state;
        n_fndData  = r_fndData;
        n_lData    = r_lData;
        n_hData    = r_hData;
        n_txData   = r_txData;
        nStart     = 0;
        case (state)
            IDLE: begin
                n_fndData = {r_hData, r_lData};
                if (o_btn) begin
                    nStart     = 1;
                    state_next = L_BYTE;
                    n_txData   = number[7:0];
                end
            end
            L_BYTE: begin
                if (!CS) begin
                    if (done) begin
                        state_next = L_DATA;
                    end
                end
            end
            L_DATA : begin
                nStart     = 1;
                n_lData    = DATA;
                state_next =H_BYTE;
                n_txData   = {2'b00, number[13:8]};
            end
            H_BYTE: begin
                if (!CS) begin
                    if (done) begin
                        state_next = H_DATA;
                    end
                end
            end
            H_DATA: begin
                n_hData    = DATA;
                state_next = IDLE;             
            end
        endcase
    end

    btn_debounce U_BTN_DEBOUNCE (
        .clk  (clk),
        .reset(rst),
        .i_btn(btn),
        .o_btn(o_btn)
    );



endmodule
