`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit (
    input  logic [31:0] instrCode,
    input  logic        compare,
    output logic        regFileWe,
    output logic [ 3:0] aluControl,
    output logic        aluSrcMuxSel,
    output logic        dataWe,
    output logic [ 1:0] wdataSel,
    output logic        PCAddrSrcMuxSel,
    output logic        PCSrcMuxSel,
    output logic        alurd1MuxSel
);
    wire [6:0] opcode = instrCode[6:0];
    wire [3:0] operators = {
        instrCode[30], instrCode[14:12]
    };  // {func7[5], func3}

    logic [5:0] signals;

    assign {regFileWe, alurd1MuxSel, aluSrcMuxSel, dataWe, wdataSel} = signals;

    always_comb begin
        signals = 6'b000000;
        case (opcode)
            `OP_TYPE_R: signals = 6'b1_0_0_0_00;
            `OP_TYPE_S: signals = 6'b0_0_1_1_00;
            `OP_TYPE_L: signals = 6'b1_0_1_0_01;
            `OP_TYPE_I: signals = 6'b1_0_1_0_00;
            `OP_TYPE_B: signals = 6'b0_0_0_0_00;
            `OP_TYPE_LU: signals = 6'b1_0_1_0_10;
            `OP_TYPE_AU: signals = 6'b1_1_1_0_00;
            `OP_TYPE_JAL: signals = 6'b1_0_0_0_11;
            `OP_TYPE_JALR: signals = 6'b1_0_1_0_11;
        endcase
    end

    always_comb begin
        PCAddrSrcMuxSel = 1'b0;
        PCSrcMuxSel = 1'b0;
        case (opcode)
            `OP_TYPE_B: begin
                if (compare ^ operators[0]) begin
                    PCAddrSrcMuxSel = 1'b1;
                    PCSrcMuxSel = 1'b1;
                end
            end
            `OP_TYPE_JAL: begin
                PCAddrSrcMuxSel = 1'b1;
                PCSrcMuxSel = 1'b1;
            end
            `OP_TYPE_JALR: begin
                PCAddrSrcMuxSel = 1'b1;
                PCSrcMuxSel = 1'b0;
            end
        endcase
    end
    always_comb begin
        aluControl = 4'bx;
        case (opcode)
            `OP_TYPE_R: aluControl = operators;  //{func[5], func3}
            `OP_TYPE_S: aluControl = `ADD;
            `OP_TYPE_L: aluControl = `ADD;
            `OP_TYPE_I: begin
                if (operators == 4'b1101) begin
                    aluControl = operators;
                end else begin
                    aluControl = {1'b0, operators[2:0]};
                end
            end
            `OP_TYPE_B: begin
                case (operators[2:1])
                    2'b00: aluControl = `BEQ;
                    2'b10: aluControl = `SLT;
                    2'b11: aluControl = `SLTU;
                endcase
            end
            `OP_TYPE_AU: aluControl = `ADD;
            `OP_TYPE_JAL: aluControl = `ADD;
            `OP_TYPE_JALR: aluControl = `ADD;
        endcase
    end

endmodule
