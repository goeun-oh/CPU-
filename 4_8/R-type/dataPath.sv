`timescale 1ns/1ps

module dataPath(
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instrCode,
    input  logic [1:0]  aluOP,
    input  logic        regFileWe,
    output logic [31:0] instrMemAddr
);

    logic [31:0] aluResult, RFData1, RFData2, PCSrcData, PCOutData;
    
    assign instrMemAddr = PCOutData;

    RegisterFile RF(
        .clk(clk),
        .we(regFileWe),
        .rAddr1(instrCode[19:15]),
        .rAddr2(instrCode[24:20]),
        .wAddr(instrCode[11:7]),
        .wData(aluResult),
        .rData1(RFData1),
        .rData2(RFData2)
    );

    alu ALU(
        .aluOP(aluOP),
        .a(RFData1),
        .b(RFData2),
        .result(aluResult)
    );

    register PC(
        .clk(clk),
        .rst(rst),
        .d(PCSrcData),
        .q(PCOutData)
    );
    
    adder PC_ADDER(
        .a(32'd4),
        .b(PCOutData),
        .y(PCSrcData)
    );
endmodule

module alu(
    input  logic [1:0]  aluOP,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    always_comb begin
        case(aluOP)
            2'b00: result = a + b;  // ADD
            2'b01: result = a - b;  // SUB
            2'b10: result = a | b;  // OR
            2'b11: result = a & b;  // AND
            default: result = 32'bx;
        endcase
    end
endmodule

module register(
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] d,
    output logic [31:0] q
);
    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end
endmodule

module adder(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    assign y= a+b;
endmodule

module RegisterFile(
    input  logic        clk,
    input  logic        we,
    input  logic [4:0]  rAddr1,
    input  logic [4:0]  rAddr2,
    input  logic [4:0]  wAddr,
    input  logic [31:0] wData,
    output logic [31:0] rData1,
    output logic [31:0] rData2
);
    logic [31:0] regFile[0:2**5-1]; //32 bit 짜리 공간이 32개 존재

    initial begin
        for (int i=0; i<32; i++) begin
            regFile[i] =10 +i;
        end
    end

    always_ff@(posedge clk) begin
        if(we) regFile[wAddr] <= wData;
    end

    assign rData1 = (rAddr1 !=0) ? regFile[rAddr1]:32'b0;
    assign rData2 = (rAddr2 !=0) ? regFile[rAddr2]:32'b0;

endmodule