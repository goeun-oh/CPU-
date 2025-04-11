`timescale 1ns / 1ps

module rom (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:15];

    initial begin
        //rom[x]=32'b fucn7 _ rs2 _ rs1 _f3 _ rd  _opcode; // R-Type
        rom[0] = 32'b0000000_00001_00010_000_00100_0110011; // add x4, x2, x1 (x4= x1+x2, 답은 23)
        rom[1] = 32'b0100000_00001_00010_000_00101_0110011; // sub x5, x1, x2 (x5 = x1- x2, 답은 -1)
        rom[2] = 32'b0000000_00101_00100_010_00110_0110011; // slt x6, x4, x5 (x6= x4 < x5답은 0)

    end
    assign data = rom[addr[31:2]];
endmodule
