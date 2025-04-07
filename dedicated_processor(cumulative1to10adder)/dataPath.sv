module dataPath (
    input  logic       clk,
    input  logic       rst,
    input  logic       nSel,
    input  logic       sumSel,
    input  logic       adderMuxSel,
    input  logic       nEn,
    input  logic       sumEn,
    input  logic       outBuf,
    output logic       nle10,
    output logic [7:0] o_sum
);

    logic [7:0] d_sum, d_n;
    logic [7:0] q_sum, q_n;
    logic [7:0] o_adder;
    logic [7:0] adderSelmuxOut;
    
    mux2X1_8bit mux_sum (
        .sel(sumSel),
        .x0 (8'h00),
        .x1 (o_adder),
        .y  (d_sum)
    );


    mux2X1_8bit mux_n (
        .sel(nSel),
        .x0 (8'h00),
        .x1 (o_adder),
        .y  (d_n)
    );

    register REG_sum (
        .clk(clk),
        .rst(rst),
        .en (sumEn),
        .d  (d_sum),
        .q  (q_sum)
    );


    register REG_n (
        .clk(clk),
        .rst(rst),
        .en (nEn),
        .d  (d_n),
        .q  (q_n)
    );

    mux2X1_8bit adderSelMux (
        .sel(adderMuxSel),
        .x0 (8'h01),
        .x1 (q_sum),
        .y  (adderSelmuxOut)
    );

    adder ADDER (
        .a(adderSelmuxOut),
        .b(q_n),
        .y(o_adder)
    );


    comparator COMP (
        .a (q_n),
        .b (8'h0B),
        .lt(nle10)
    );

    buffer BUF (
        .en(outBuf),
        .x (q_sum),
        .y (o_sum)
    );

endmodule

module mux2X1_8bit (
    input logic sel,
    input logic [7:0] x0,
    input logic [7:0] x1,
    output logic [7:0] y
);

    assign y = sel ? x1 : x0;


endmodule


module register (
    input logic clk,
    input logic rst,
    input logic en,
    input logic [7:0] d,
    output logic [7:0] q
);

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            q <= 0;
        end else begin
            if (en) begin
                q <= d;
            end
        end
    end

endmodule


module adder (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] y
);
    assign y = a + b;

endmodule

module comparator (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic lt
);

    assign lt = a < b;
endmodule


module buffer (
    input logic en,
    input logic [7:0] x,
    output logic [7:0] y
);
    assign y = en ? x : 8'hxx;
endmodule
