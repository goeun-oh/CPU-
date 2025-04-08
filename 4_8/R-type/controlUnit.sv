`timescale 1ns/1ps

module controlUnit(
    input logic [31:0] instrCode,
    output logic regFileWe,
    output logic [3:0] aluOP
);
    wire [6:0] opcode= instrCode[6:0];
    wire [3:0] operator = {instrCode[30], instrCode[14:12]};

    always_comb begin
        regFileWe =1'b0;
        case (opcode)
            7'b0110011: regFileWe=1'b1; //r-type
        endcase
    end

    always_comb begin
        aluOP= 2'bx;
        case(opcode)
            7'b0110011: begin
                case(operator)
                    4'b0000: aluOP=4'b0000; //ADD 
                    4'b1000: aluOP=4'b0001; //SUB
                    4'b0001: aluOP=4'b0010; //SLL
                    4'b0101: aluOP=4'b0011; //SRL
                    4'b1101: aluOP=4'b0100; //SRA
                    4'b0010: aluOP=4'b0101; //SLT
                    4'b0011: aluOP=4'b0110; //SLTU
                    4'b0100: aluOP=4'b0111; //XOR
                    4'b0110: aluOP=4'b1000; //OR
                    4'b0111: aluOP=4'b1001; //AND
                endcase
            end
        endcase

    end

endmodule