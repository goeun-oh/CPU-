module ram (
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] addr,
    input  logic [31:0] wData,
    output logic [31:0] rData
);
    logic [31:0] ram[0:9];

    always_ff @(posedge clk) begin
        if (we) ram[addr[31:2]] <= wData;
    end

    assign rData = ram[addr[31:2]];
endmodule
