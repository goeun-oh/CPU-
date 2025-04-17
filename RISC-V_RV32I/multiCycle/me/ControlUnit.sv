`timescale 1ns / 1ps

`include "defines.sv"

module ControlUnit (
    input logic clk,
    input logic reset,
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic [ 3:0] aluControl,
    output logic        aluSrcMuxSel,
    output logic        dataWe,
    output logic [ 2:0] RFWDSrcMuxSel,
    output logic        branch,
    output logic        jal,
    output logic        jalr,
    output logic        pcEn
);
    wire [6:0] opcode = instrCode[6:0];
    wire [3:0] operators = {
        instrCode[30], instrCode[14:12]
    };  // {func7[5], func3}

    logic [9:0] signals;
    assign {regFileWe, aluSrcMuxSel, dataWe, RFWDSrcMuxSel, branch, jal, jalr} = signals;

    always_comb begin
        signals = 9'b0;
        case (opcode)
            // {regFileWe, aluSrcMuxSel, dataWe, RFWDSrcMuxSel(3), branch, jal, jalr} = signals
            `OP_TYPE_R:  signals = 9'b1_0_0_000_0_0_0;
            `OP_TYPE_S:  signals = 9'b0_1_1_000_0_0_0;
            `OP_TYPE_L:  signals = 9'b1_1_0_001_0_0_0;
            `OP_TYPE_I:  signals = 9'b1_1_0_000_0_0_0;
            `OP_TYPE_B:  signals = 9'b0_0_0_000_1_0_0;
            `OP_TYPE_LU: signals = 9'b1_0_0_010_0_0_0;
            `OP_TYPE_AU: signals = 9'b1_0_0_011_0_0_0;
            `OP_TYPE_J:  signals = 9'b1_0_0_100_0_1_0;
            `OP_TYPE_JL: signals = 9'b1_0_0_100_0_1_1;
        endcase
    end

    always_comb begin
        aluControl = 4'bx;
        case (opcode)
            `OP_TYPE_S: aluControl = `ADD;
            `OP_TYPE_L: aluControl = `ADD;
            `OP_TYPE_JL: aluControl = `ADD;  // {func7[5], func3}
            `OP_TYPE_I: begin
                if (operators == 4'b1101)
                    aluControl = operators;  // {1'b1, func3}
                else aluControl = {1'b0, operators[2:0]};  // {1'b0, func3}
            end
            default: aluControl = operators;  // {func7[5], func3}
            // `OP_TYPE_R:  aluControl = operators;  // {func7[5], func3}
            // `OP_TYPE_B:  aluControl = operators;  // {func7[5], func3}
            // `OP_TYPE_LU: aluControl = operators;  // {func7[5], func3}
            // `OP_TYPE_AU: aluControl = operators;  // {func7[5], func3}
            // `OP_TYPE_J:  aluControl = operators;  // {func7[5], func3}
        endcase
    end


    typedef enum {IDLE, Fetch, Decode, EXE, memAccess, WB} state_e;

    state_e state, state_next;

    always_ff @(posedge clk, posedge reset) begin
        if(reset) state <= Fetch;
        else state <= state_next;
    end

    always_comb begin
        state_next = state;
        pcEn=1'b0;
        case(state)
            Fetch: begin
                state_next= Decode;
                pcEn=1'b1;
            end
            Decode: begin
                state_next = EXE;
            end
            EXE: begin
                state_next=Fetch;
                case(opcode)
                    `OP_TYPE_L: begin
                        state_next = memAccess;
                    end
                    `OP_TYPE_S: begin
                        state_next= memAccess;
                    end
                endcase
            end
            memAccess: begin
                state_next=Fetch;
                case(opcode)
                    `OP_TYPE_L: begin
                        state_next= WB;
                    end
                endcase
            end
            WB: begin
                state_next = Fetch;
            end
        endcase
    end
endmodule
