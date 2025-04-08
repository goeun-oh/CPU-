module rom(
    input logic [31:0] addr,
    output logic [31:0] rdata
);

    logic [31:0] rom_mem [0:2**5-1];
    
endmodule