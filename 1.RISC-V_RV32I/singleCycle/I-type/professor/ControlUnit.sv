`timescale 1ns / 1ps

`include "defines.sv"

module ControlUnit (
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic [ 4:0] aluControl,
    output logic        aluSrcMuxSel,
    output logic        dataWe,
    output logic        RFWDSrcMuxSel,
    output logic        branch
);
    wire [6:0] opcode = instrCode[6:0];
    wire [4:0] operators = {
        1'b0,instrCode[30], instrCode[14:12]
    };  // {func7[5], func3}
    wire [4:0] operators_branch = {2'b10, instrCode[14:12]};

    logic [4:0] signals;
    assign {regFileWe, aluSrcMuxSel, dataWe, RFWDSrcMuxSel, branch} = signals;

    always_comb begin
        signals = 5'b0;
        case (opcode)
            // {regFileWe, aluSrcMuxSel, dataWe, RFWDSrcMuxSel, branch} = signals
            `OP_TYPE_R: signals = 5'b1_0_0_0_0;
            `OP_TYPE_S: signals = 5'b0_1_1_0_0;
            `OP_TYPE_L: signals = 5'b1_1_0_1_0;
            `OP_TYPE_I: signals = 5'b1_1_0_0_0;
            `OP_TYPE_B: signals = 5'b1_0_0_0_1;
        endcase
    end

    always_comb begin
        aluControl = 5'bx;
        case (opcode)
            `OP_TYPE_R: aluControl = operators;  // {func7[5], func3}begin
            `OP_TYPE_S: aluControl = `ADD;
            `OP_TYPE_L: aluControl = `ADD;
            `OP_TYPE_I: begin
                if (operators == 5'b01101) aluControl = operators;   // {1'b1, func3}
                else aluControl = {1'b00, operators[2:0]};  // {1'b0, func3}
            end
            `OP_TYPE_B: aluControl = operators_branch;
        endcase
    end
endmodule
