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

        //rom[x] = 32'b imm7_rs2_rs1_func3_imm5_opcode //I-type : BEQ
        rom[5]= 32'b0000000_00000_00000_000_01100_1100011; //beq x0, x0, 12(8번 PC jump)

        //rom[x] = 32'b imm7_rs2_rs1_func3_imm5_opcode //I-type : BNE

        //rom[x] = 32'b imm7_rs2_rs1_func3_imm5_opcode //I-type : BLT


        rom[8]= 32'b0000000_00000_00000_001_01100_1100011; //bne x0, x0, 12(다르면 8번 PC로 jump)
        rom[9]= 32'b0000000_00011_00000_100_01000_1100011;//blt x0, x3, 8 (x0>x3 이면 9번 PC로 jump)


    end
    assign data = rom[addr[31:2]];
endmodule
