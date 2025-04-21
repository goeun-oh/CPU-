`timescale 1ns / 1ps

module rom (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:127]; // 128 words of 32 bits

    initial begin
        $readmemh("code.mem", rom);
    end
    assign data = rom[addr[31:2]];
endmodule
