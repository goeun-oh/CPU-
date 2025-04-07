module dataPath(
    input  logic        clk,
    input  logic        rst,
    input  logic        RFSrcMuxSel,
    input  logic [2:0]  readAddr1,
    input  logic [2:0]  readAddr2,
    input  logic [2:0]  writeAddr,
    input  logic        writeEn,
    input  logic        outBuf,
    output logic        iLe10,
    output logic [7:0]  outPort
);
    logic [7:0] rData1, rData2;
    logic [7:0] adderOut;
    logic [7:0] wData;

    mux_2X1 mux(
        .sel(RFSrcMuxSel),
        .x0(8'h01),
        .x1(adderOut),
        .y(wData)
    );

    RegFile regFile(
        .clk(clk),
        .readAddr1(readAddr1),
        .readAddr2(readAddr2),
        .writeAddr(writeAddr),
        .writeEn(writeEn),
        .wData(wData),
        .rData1(rData1),
        .rData2(rData2)
    );

    adder ADDER(
        .x0(rData1),
        .x1(rData2),
        .y(adderOut)
    );

    compare CMP(
        .x0(rData1),
        .x1(8'd10),
        .iLe10(iLe10)   
    );

    register outReg(
        .clk(clk),
        .rst(rst),
        .en(outBuf),
        .d(rData2),
        .q(outPort)
    );

endmodule

module mux_2X1(
    input logic sel,
    input logic [7:0] x0,
    input logic [7:0] x1,
    output logic [7:0] y
);
    assign y= (sel)? x1: x0;

endmodule

module register (
    input logic clk,
    input logic rst,
    input logic en,
    input logic [7:0] d,
    output logic [7:0] q
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 8'b0;
        end else begin
            if (en) begin
                q <= d;
            end
        end
    end    
endmodule


module RegFile(
    input  logic        clk,
    input  logic  [2:0] readAddr1,
    input  logic  [2:0] readAddr2,
    input  logic  [2:0] writeAddr,
    input  logic        writeEn,
    input  logic  [7:0] wData,
    output logic  [7:0] rData1,
    output logic  [7:0] rData2
    );

    logic [7:0] mem[0:7];

    always_ff @(posedge clk) begin
        if (writeEn) mem[writeAddr] <= wData;
    end


    assign rData1= (readAddr1 == 3'b0) ? 8'b0: mem[readAddr1];
    assign rData2= (readAddr2 == 3'b0) ? 8'b0: mem[readAddr2];

endmodule

module compare(
    input logic [7:0] x0,
    input logic [7:0] x1,
    output logic iLe10
);
    assign iLe10 = x0 <= x1;
endmodule


module adder(
    input logic [7:0] x0,
    input logic [7:0] x1,
    output logic [7:0] y
);

    always_comb begin
        y = x0 + x1;
    end
endmodule