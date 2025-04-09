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
        rom[5] = 32'b000000000010_00100_001_00101_0010011; //slli x5, x4, 2
        rom[6] = 32'b010000000010_00101_101_00110_0010011; //srai x6, x5, 2

    end
    assign data = rom[addr[31:2]];
endmodule
