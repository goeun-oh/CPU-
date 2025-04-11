`timescale 1ns / 1ps
`include "defines.sv"

module DataPath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instrCode,
    output logic [31:0] instrMemAddr,
    input  logic        regFileWe,
    input  logic [ 3:0] aluControl,
    input  logic        aluSrcMuxSel,
    input  logic [ 1:0] wdataSel,
    input  logic        PCAddrSrcMuxSel,
    input  logic        alurd1MuxSel,
    input  logic [31:0] rData,
    output logic [31:0] dataAddr,
    output logic [31:0] datawData,
    output logic        compare,
    input  logic        PCSrcMuxSel
);
    logic [31:0] aluResult, RFData1, RFData2;
    logic [31:0] PCSrcData, PCOutData;
    logic [31:0] immExt, aluSrcMuxOut;
    logic [31:0] wData;
    logic [31:0] PCAddrSrcMuxOut, alurd1MuxOut;
    logic [31:0] PCAddr0MuxOut, PCAddr1MuxOut;
    logic [31:0] PCSrcMuxOut;

    assign instrMemAddr = PCOutData;
    assign dataAddr     = aluResult;
    assign datawData    = RFData2;
    assign compare      = aluResult[0];

    RegisterFile U_RegFile (
        .clk   (clk),
        .we    (regFileWe),
        .RAddr1(instrCode[19:15]),
        .RAddr2(instrCode[24:20]),
        .WAddr (instrCode[11:7]),
        .WData (wData),
        .RData1(RFData1),
        .RData2(RFData2)
    );

    mux1_2X1 ALUSrcMux (
        .sel(aluSrcMuxSel),
        .x0 (RFData2),
        .x1 (immExt),
        .y  (aluSrcMuxOut)
    );

    mux1_4X1 wdataMux (
        .sel(wdataSel),
        .x0 (aluResult),
        .x1 (rData),
        .x2 (immExt),
        .x3 (PCAddr0MuxOut),
        .y  (wData)
    );

    mux1_2X1 ALUrd1Mux (
        .sel(alurd1MuxSel),
        .x0 (RFData1),
        .x1 (PCOutData),
        .y  (alurd1MuxOut)
    );

    alu U_ALU (
        .aluControl(aluControl),
        .a         (alurd1MuxOut),
        .b         (aluSrcMuxOut),
        .result    (aluResult)
    );


    extend ImmExtend (
        .instrCode(instrCode),
        .immExt   (immExt)
    );

    register U_PC (
        .clk  (clk),
        .reset(reset),
        .d    (PCSrcData),
        .q    (PCOutData)
    );

    adder U_PC_Adder0 (
        .a(32'd4),
        .b(PCOutData),
        .y(PCAddr0MuxOut)
    );

    adder U_PC_Adder1 (
        .a(PCSrcMuxOut),
        .b(PCOutData),
        .y(PCAddr1MuxOut)
    );


    mux1_2X1 PCSrcMux (
        .sel(PCSrcMuxSel),
        .x0 (aluResult),
        .x1 (immExt),
        .y  (PCSrcMuxOut)
    );

    mux1_2X1 PCAddrSrcMux (
        .sel(PCAddrSrcMuxSel),
        .x0 (PCAddr0MuxOut),
        .x1 (PCAddr1MuxOut),
        .y  (PCSrcData)
    );

endmodule

module mux1_4X1 (
    input  logic [ 1:0] sel,
    input  logic [31:0] x0,
    input  logic [31:0] x1,
    input  logic [31:0] x2,
    input  logic [31:0] x3,
    output logic [31:0] y
);
    always_comb begin
        case (sel)
            2'b00:   y = x0;
            2'b01:   y = x1;
            2'b10:   y = x2;
            2'b11:   y = x3;
            default: y = 32'bx;
        endcase
    end
endmodule

module alu (
    input  logic [ 3:0] aluControl,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    always_comb begin
        case (aluControl)
            `ADD:    result = a + b;
            `SUB:    result = a - b;
            `SLL:    result = a << b;
            `SRL:    result = a >> b;
            `SRA:    result = $signed(a) >>> b;
            `SLT:    result = $signed(a) < $signed(b);
            `SLTU:   result = a < b;
            `XOR:    result = a ^ b;
            `OR:     result = a | b;
            `AND:    result = a & b;
            `BEQ:    result = a == b;
            default: result = 32'bx;
        endcase
    end
endmodule

module register (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] d,
    output logic [31:0] q
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) q <= 0;
        else q <= d;
    end
endmodule

module adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    assign y = a + b;
endmodule

module RegisterFile (
    input  logic        clk,
    input  logic        we,
    input  logic [ 4:0] RAddr1,
    input  logic [ 4:0] RAddr2,
    input  logic [ 4:0] WAddr,
    input  logic [31:0] WData,
    output logic [31:0] RData1,
    output logic [31:0] RData2
);
    logic [31:0] RegFile[0:2**5-1];
    initial begin
        for (int i = 0; i < 32; i++) begin
            RegFile[i] = 10 + i;
        end
    end

    always_ff @(posedge clk) begin
        if (we) RegFile[WAddr] <= WData;
    end

    assign RData1 = (RAddr1 != 0) ? RegFile[RAddr1] : 32'b0;
    assign RData2 = (RAddr2 != 0) ? RegFile[RAddr2] : 32'b0;
endmodule


module mux1_2X1 (
    input  logic        sel,
    input  logic [31:0] x0,
    input  logic [31:0] x1,
    output logic [31:0] y
);

    assign y = sel ? x1 : x0;
endmodule

module extend (
    input  logic [31:0] instrCode,
    output logic [31:0] immExt
);
    wire [6:0] opcode = instrCode[6:0];
    wire [2:0] func3 = instrCode[14:12];
    wire [7:0] func7 = instrCode[31:25];

    always_comb begin
        immExt = 32'bx;
        case (opcode)
            `OP_TYPE_R: immExt = 32'bx;
            `OP_TYPE_L: immExt = {{20{instrCode[31]}}, instrCode[31:20]};
            `OP_TYPE_S:
            immExt = {{20{instrCode[31]}}, instrCode[31:25], instrCode[11:7]};
            `OP_TYPE_I: begin
                case (func3)
                    3'b001:  immExt = {27'b0, instrCode[24:20]};
                    3'b101:  immExt = {27'b0, instrCode[24:20]};
                    3'b011:  immExt = {20'b0, instrCode[31:20]};
                    default: immExt = {{20{instrCode[31]}}, instrCode[31:20]};
                endcase
            end
            `OP_TYPE_B: begin
                if (func3[1:0] == 2'b11)
                    immExt = {
                        {19{instrCode[31]}},
                        instrCode[31],
                        instrCode[7],
                        instrCode[30:25],
                        instrCode[11:8],
                        1'b0
                    };
                else
                    immExt = {
                        19'b0,
                        instrCode[31],
                        instrCode[7],
                        instrCode[30:25],
                        instrCode[11:8],
                        1'b0
                    };
            end
            `OP_TYPE_LU: immExt = {instrCode[31:12], 12'b0};
            `OP_TYPE_AU: immExt = {instrCode[31:12], 12'b0};
            `OP_TYPE_JAL: immExt = 
                {11'b0,
                instrCode[31],
                instrCode[19:12],
                instrCode[20],
                instrCode[30:21],
                1'b0
            };
            `OP_TYPE_JALR: immExt = {20'b0, instrCode[31:20]};
            default: immExt = 32'bx;
        endcase
    end

endmodule
