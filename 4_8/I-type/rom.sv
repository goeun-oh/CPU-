`timescale 1ns / 1ps

module rom (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:15];

    initial begin
        //rom[x]=32'b fucn7 _ rs2 _ rs1 _f3 _ rd  _opcode; // R-Type
        rom[0] = 32'b0000000_00001_00010_000_00100_0110011; // add x4, x2, x1
        rom[1] = 32'b0100000_00001_00010_000_00101_0110011; // sub x5, x2, x1

        //rom[x]=32'b imm7 _ rs2 _ rs1 _f3 _ imm5  _opcode; // S-Type
        rom[2] = 32'b0000000_00010_00000_010_01000_0100011; //sw x2, 8(x0);

        //rom[x]=32'b imm11 _ rs1 _ f3 _rd _opcode; // L-Type : rd=mem[rs1+imm]
        rom[3] = 32'b000000001000_00000_010_00011_0000011; //lw x3, 2(x0);

        //rom[x] = 32'b imm12_rs1_f3_rd_opcode //I-type : ADDI
        rom[4] = 32'b000000000001_00000_000_00100_0010011; //addi x4, x0, 1
        rom[5] = 32'b111111111101_00100_010_00101_0010011; //slti x5, x4, -3
        rom[6] = 32'b000000000001_00101_011_00110_0010011; //sltiu x6, x5, 1
        rom[9] = 32'b000000000001_00001_111_01000_0010011; // andi x8, x1, 1
        rom[10] = 32'b000000000001_01000_001_01001_0010011; // slli x9, x8, 1
        rom[11] = 32'b000000000001_01000_101_01010_0010011; // srli x10, x8, 1
        rom[12] = 32'b000000000001_01000_101_01011_0010011; // srai x11, x8, 1
    end
    assign data = rom[addr[31:2]];
endmodule
