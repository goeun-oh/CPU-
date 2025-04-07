`timescale 1ns / 1ps

module DataPath (
    input  logic       clk,
    input  logic       reset,
    input  logic       RFSrcMuxSel,
    input  logic [2:0] readAddr1,
    input  logic [2:0] readAddr2,
    input  logic [2:0] writeAddr,
    input  logic       writeEn,
    input  logic       outBuf,
    input logic [2:0] aluOP,
    output logic       iLe10,
    output logic [7:0] outPort,
    output logic aBTb
);
    logic [7:0] adderResult, RFSrcMuxData, RFReadData1, RFReadData2;

    mux_2x1 U_RFSrcMux (
        .sel(RFSrcMuxSel),
        .x0 (adderResult),
        .x1 (8'b1),
        .y  (RFSrcMuxData)
    );

    RegFile U_RegFile (
        .clk(clk),
        .readAddr1(readAddr1),
        .readAddr2(readAddr2),
        .writeAddr(writeAddr),
        .writeEn(writeEn),
        .wData(RFSrcMuxData),
        .rData1(RFReadData1),
        .rData2(RFReadData2)
    );

    comparator U_Comp_iLe10 (
        .a (RFReadData1),
        .b (8'd10),
        .le(iLe10)
    );
    comparator U_Comp_aBTb (
        .a (RFReadData1),
        .b (RFReadData2),
        .le(aBTb)
    );
    ALU U_ALU (
        .aluOP(aluOP),
        .a(RFReadData1),
        .b(RFReadData2),
        .result(adderResult)
    );
    register U_OutReg (
        .clk(clk),
        .reset(reset),
        .en(outBuf),
        .d(RFReadData1),
        .q(outPort)
    );

endmodule

module ALU (
    input logic [2:0] aluOP,
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] result
);
    logic [7:0] sum, sub, o_and, o_or, o_exor, o_not;

    adder U_Adder(.*);
    subtractor U_Subtractor(.*);
    AND U_AND(.*);
    OR U_OR(.*);
    EXOR U_EXOR(.*);
    NOT U_NOT(.*);    

    always_comb begin : ALU
        case (aluOP)
            3'b000: result = sum;
            3'b001: result = sub;
            3'b010: result = o_and;
            3'b011: result = o_or;
            3'b100: result = o_exor;
            3'b101: result = o_not;
            default: result = 8'bx;
        endcase
    end
endmodule

module adder (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] sum
);
    assign sum = a + b;
endmodule

module subtractor (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] sub
);
    assign sub = a - b;
endmodule

module AND (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] o_and
);
    assign o_and = a & b;
endmodule

module OR (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] o_or
);
    assign o_or = a | b; 
endmodule


module EXOR (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] o_exor
);
    assign o_exor = a ^ b;
endmodule

module NOT (
    input  logic [7:0] a,
    output logic [7:0] o_not
);
    assign o_not = ~a;
endmodule

module RegFile (
    input  logic       clk,
    input  logic [2:0] readAddr1,
    input  logic [2:0] readAddr2,
    input  logic [2:0] writeAddr,
    input  logic       writeEn,
    input  logic [7:0] wData,
    output logic [7:0] rData1,
    output logic [7:0] rData2
);
    logic [7:0] mem[0:7];

    always_ff @(posedge clk) begin : write
        if (writeEn) mem[writeAddr] <= wData;
    end

    assign rData1 = (readAddr1 == 3'b0) ? 8'b0 : mem[readAddr1];
    assign rData2 = (readAddr2 == 3'b0) ? 8'b0 : mem[readAddr2];
endmodule

module mux_2x1 (
    input  logic       sel,
    input  logic [7:0] x0,
    input  logic [7:0] x1,
    output logic [7:0] y
);
    always_comb begin : mux
        y = 8'b0;
        case (sel)
            1'b0: y = x0;
            1'b1: y = x1;
        endcase
    end
endmodule

module register (
    input  logic       clk,
    input  logic       reset,
    input  logic       en,
    input  logic [7:0] d,
    output logic [7:0] q
);
    always_ff @(posedge clk, posedge reset) begin : register
        if (reset) q <= 0;
        else begin
            if (en) q <= d;
        end
    end
endmodule

module comparator (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic       le
);
    assign le = (a <= b);
endmodule

