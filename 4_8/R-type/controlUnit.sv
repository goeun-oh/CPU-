`timescale 1ns/1ps

module controlUnit(
    input logic [31:0] instrCode,
    output logic regFileWe,
    output logic [1:0] aluOP
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
                    4'b0000: aluOP=2'b00;
                    4'b1000: aluOP=2'b01;
                    4'b0110: aluOP=2'b10;
                    4'b0111: aluOP=2'b11;
                endcase
            end
        endcase

    end

endmodule