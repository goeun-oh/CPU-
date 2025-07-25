`timescale 1ns / 1ps

module rom (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:15];

    initial begin
        //rom[x]=32'b fucn7 _ rs2 _ rs1 _f3 _ rd  _opcode; // R-Type
        rom[0]  = 32'b0000000_00001_00010_000_00100_0110011;  // add x4, x2, x1
        rom[1]  = 32'b0100000_00001_00010_000_00101_0110011;  // sub x5, x2, x1

        //rom[x]=32'b imm7 _ rs2 _ rs1 _f3 _ imm5  _opcode; // S-Type
        rom[2]  = 32'b0000000_00010_00000_010_01000_0100011;  //sw x2, 8(x0);

        //rom[x]=32'b imm12_ rs1 _ f3 _rd _opcode; // L-Type : rd=mem[rs1+imm]
        rom[3]  = 32'b000000001000_00000_010_00011_0000011;  //lw x3, 2(x0);

        //rom[x] = 32'b imm12_rs1_f3_rd_opcode //I-type : ADDI
        rom[4]  = 32'b000000001000_00010_000_00110_0010011;  //addi x6, x2, 8

        //lui
        rom[5]=32'b00000000000000000001_01011_0110111; //lui x11, 0x1 (x11 <<12 = 0x00001000)
        //auipc
        rom[6]=32'b00000000000000000001_01100_0010111; //auipc x12, 0x1 (x12 <<12 = 0x00001000)
        
        rom[7] = 32'b00000001000000000000_00011_1101111; // jal x3, 16
        rom[11] = 32'b000000010000_00110_000_00100_1100111; // jalr x4, 16(x6)
    end
    assign data = rom[addr[31:2]];
endmodule
