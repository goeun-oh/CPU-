`timescale 1ns / 1ps

`include "defines.sv"

module ControlUnit (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic [ 3:0] aluControl,
    output logic        aluSrcMuxSel,
    output logic        dataWe,
    output logic [ 2:0] RFWDSrcMuxSel,
    output logic        branch,
    output logic        jal,
    output logic        jalr,
    output logic        PCEn
);
    wire [6:0] opcode = instrCode[6:0];
    wire [3:0] operators = {
        instrCode[30], instrCode[14:12]
    };  // {func7[5], func3}

    logic [9:0] signals;
    assign {PCEn, regFileWe, aluSrcMuxSel, dataWe, RFWDSrcMuxSel, branch, jal, jalr} = signals;

    typedef enum {
        FETCH,
        DECODE,
        R_EXE,
        I_EXE,
        B_EXE,
        LU_EXE,
        AU_EXE,
        J_EXE,
        JL_EXE,
        S_EXE,
        S_MEM,
        L_EXE,
        L_MEM,
        L_WB
    } state_e;

    state_e state, state_next;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) state <= FETCH;
        else state <= state_next;
    end

    always_comb begin
        state_next = state;
        case (state)
            FETCH:  state_next = DECODE;
            DECODE: begin //DECODE 단계에서 어떤 상태인지 판단하기
                case (opcode)
                    `OP_TYPE_R:  state_next = R_EXE;
                    `OP_TYPE_S:  state_next = S_EXE;
                    `OP_TYPE_L:  state_next = L_EXE;
                    `OP_TYPE_I:  state_next = I_EXE;
                    `OP_TYPE_B:  state_next = B_EXE;
                    `OP_TYPE_LU: state_next = LU_EXE;
                    `OP_TYPE_AU: state_next = AU_EXE;
                    `OP_TYPE_J:  state_next = J_EXE;
                    `OP_TYPE_JL: state_next = JL_EXE;
                endcase
            end
            R_EXE:  state_next = FETCH;
            I_EXE:  state_next = FETCH;
            B_EXE:  state_next = FETCH;
            S_EXE:  state_next = S_MEM;
            S_MEM:  state_next = FETCH;
            L_EXE:  state_next = L_MEM;
            L_MEM:  state_next = L_WB;
            L_WB:   state_next = FETCH;
            LU_EXE: state_next = FETCH;
            AU_EXE: state_next = FETCH;
            J_EXE:  state_next = FETCH;
            JL_EXE: state_next = FETCH;
        endcase
    end

    always_comb begin
        // {PCEn, regFileWe, aluSrcMuxSel, dataWe, RFWDSrcMuxSel(3), branch, jal, jalr} = signals
        aluControl = operators;
        signals = 10'b0;
        case (state)
            FETCH:
            signals = 10'b1_0_0_0_000_0_0_0;  //PCEn외에는 모두 dis-enable
            DECODE:
            signals=10'b0; //decode는 판단(자체 분석)만 하기 때문에 신호를 아무것도 주면 안된다.
            R_EXE: signals = 10'b0_1_0_0_000_0_0_0;
            I_EXE: begin
                signals = 10'b0_1_1_0_000_0_0_0;
                if (operators == 4'b1101)
                    aluControl = operators;  // {1'b1, func3}
                else aluControl = {1'b0, operators[2:0]};  // {1'b0, func3} 
            end

            S_EXE: begin
                signals = 10'b0_0_1_0_000_0_0_0;
                aluControl = `ADD;
            end
            S_MEM:  signals = 10'b0_0_0_1_000_0_0_0;
            L_EXE: begin
                signals = 10'b0_0_1_0_001_0_0_0;
                aluControl = `ADD;
            end
            L_MEM:  signals = 10'b0_0_1_0_001_0_0_0;
            L_WB:   signals = 10'b0_1_1_0_001_0_0_0;
            B_EXE:  signals = 10'b0_0_0_0_000_1_0_0;
            LU_EXE: signals = 10'b0_1_0_0_010_0_0_0;
            AU_EXE: signals = 10'b0_1_0_0_010_0_0_0;
            J_EXE:  signals = 10'b0_1_0_0_100_0_1_0;
            JL_EXE: begin
                signals = 10'b0_1_0_0_100_0_1_1;
                aluControl = `ADD;
            end
        endcase
    end

endmodule
