`timescale 1ns / 1ps

module ControlUnit (
    input  logic       clk,
    input  logic       reset,
    output logic       RFSrcMuxSel,
    output logic [2:0] readAddr1,
    output logic [2:0] readAddr2,
    output logic [2:0] writeAddr,
    output logic       writeEn,
    output logic       outBuf,
    output logic [2:0] aluOP,
    input  logic       aBTb
);
    typedef enum { S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11 } state_e;
    
    state_e state, state_next;
    logic [14:0] out_signals;


//1줄로 끝내게 해주는 코드!
    assign {RFSrcMuxSel, readAddr1, readAddr2, writeAddr, writeEn, outBuf, aluOP} = out_signals;

    always_ff @(posedge clk, posedge reset) begin : state_reg
        if (reset) state <= S0;
        else state <= state_next;
    end

    always_comb begin : state_next_machine
        state_next     = state;
        out_signals = 0;
        case (state)
            //{RFSrcMuxSel, readAddr1, readAddr2, writeAddr, writeEn, outBuf} = out_signals;
            S0: begin // R1 = 0
                out_signals = 15'b0_000_000_001_1_0_000; 
                //CPU에서의 machine 코드(instructions), machine 코드가 datapath로 들어간다.
                //이 명령어들이 ROM에 들어가 하나씩 읽으면 그것이 CPU다
                state_next     = S1;
            end
            S1: begin // R2 = 0
                out_signals = 15'b0_000_000_010_1_0_000;
                state_next     = S2;
            end
            S2: begin // R3 = 1;
                out_signals = 15'b1_000_000_011_1_0_000;
                state_next     = S3;
            end
            S3: begin //r4=r1+r1 
                out_signals = 15'b0_001_001_100_1_1_000;
                state_next = S4;
            end
            S4: begin // r5=r4+r4
                out_signals = 15'b0_100_100_101_1_1_000;
                state_next     = S5;
            end
            S5: begin // r6=r5-r1
                out_signals = 15'b0_101_001_110_1_1_001;
                state_next     = S6;
            end
            S6: begin // r2=r6&r4
                out_signals = 15'b0_110_100_010_1_1_010;
                state_next     = S7;
            end
            S7: begin //r3=r2|r5
                out_signals = 15'b0_010_101_011_1_1_011;
                state_next     = S8;
            end
            S8: begin //r7=r3^r2
                out_signals = 15'b0_011_010_111_1_1_100;
                state_next     = S9;
            end
            S9: begin //r7=~r7
                out_signals = 15'b0_111_xxx_111_1_1_101;
                state_next     = S10;
            end
            S10: begin
                if(aBTb) begin
                    state_next=S4;
                end else begin
                    state_next= S11;
                end
            end
            S11: begin
                out_signals = 15'b0_000_000_000_0_0_000;
            end
        endcase
    end
endmodule
