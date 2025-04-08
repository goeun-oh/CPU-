module rom(
    input logic [31:0] addr,
    output logic [31:0] rdata
);

    logic [31:0] rom_mem [0:15];

    initial begin
        //rom[x] = 32'b func7_rs2_rs1_f3_rd_opcode; //r-type
        rom_mem[0] = 32'b0000000_00001_00010_000_00100_0110011; //add x4,x2,x1
        rom_mem[1] = 32'b0100000_00001_00010_000_00101_0110011; //sub x5,x2,x1
    end

    assign rdata = rom_mem[addr[31:2]]; //4의 배수로 가기위해 하위 2bit 무시
endmodule