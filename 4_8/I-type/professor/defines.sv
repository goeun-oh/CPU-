`define ADD  5'b00000 // {func7[5], func3}
`define SUB  5'b01000
`define SLL  5'b00001
`define SRL  5'b00101
`define SRA  5'b01101
`define SLT  5'b00010
`define SLTU 5'b00011
`define XOR  5'b00100
`define OR   5'b00110
`define AND  5'b00111

// branch
`define BEQ  5'b10000
`define BNE  5'b10001
`define BLT  5'b10100
`define BGE  5'b10101
`define BLTU  5'b10110
`define BGEU  5'b10111

`define OP_TYPE_R 7'b0110011
`define OP_TYPE_L 7'b0000011
`define OP_TYPE_I 7'b0010011
`define OP_TYPE_S 7'b0100011
`define OP_TYPE_B 7'b1100011
`define OP_TYPE_LU 7'b0110111
`define OP_TYPE_AU 7'b0010111