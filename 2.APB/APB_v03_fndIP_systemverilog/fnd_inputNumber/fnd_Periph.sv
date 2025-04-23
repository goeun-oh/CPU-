`timescale 1ns / 1ps

module fnd_Periph (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // inport signals
    output logic [ 7:0] fndFont,
    output logic [ 3:0] fndComm
);

    logic FCR;
    logic [13:0] FDR;
    logic [3:0] FPR;

    fnd_SlaveIntf U_fnd_Intf (.*);
    fndController U_fnd (
        .*,
        .clk(PCLK),
        .reset(PRESET)
        );
endmodule

module fnd_SlaveIntf (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // internal signals
    output logic [ 7:0] FCR,
    output logic [ 13:0] FDR,
    output logic [3:0] FPR
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2;  //, slv_reg3;


    assign FCR = slv_reg0[0];
    assign FDR = slv_reg1[13:0];
    assign FPR = slv_reg2[3:0];


    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            // slv_reg3 <= 0;
        end else begin
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: slv_reg1 <= PWDATA;
                        2'd2: slv_reg2 <= PWDATA;
                        // 2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                        2'd2: PRDATA <= slv_reg2;
                        // 2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end

endmodule

module fndController (
    input logic clk,
    input logic reset,
    input  logic       FCR,
    input  logic [13:0] FDR,
    input logic [3:0] FPR,
    output logic [3:0] fndComm,
    output logic [7:0] fndFont
);
    wire [7:0] fndSegData;
    wire [1:0] sel;
    assign fndFont = {FPR[sel], fndSegData[6:0]};

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] w_digit;
    wire o_clk;

    clk_divider U_Clk_Divider(
        .clk(clk),
        .reset(reset),
        .o_clk(o_clk)
    );
    counter_4 U_Counter_4(
        .clk(o_clk),
        .reset(reset),
        .o_sel(sel)
    );
    decoder U_Decoder(
        .en(FCR),
        .x(sel),
        .y(fndComm)
    );

    digitSplitter U_DigitSplitter(
        .i_digit(FDR),
        .o_digit_1(w_digit_1),
        .o_digit_10(w_digit_10),
        .o_digit_100(w_digit_100),
        .o_digit_1000(w_digit_1000)
    );

    mux U_Mux(
        .sel(sel),
        .x0(w_digit_1),
        .x1(w_digit_10),
        .x2(w_digit_100),
        .x3(w_digit_1000),
        .y(w_digit)
    );

    BCDtoSEG U_BCD_to_SEG(
        .bcd(w_digit),
        .seg(fndSegData)
    ); 

    mux_4X1_1bit MUX_4X1_1bit (
         .sel(digit_sel),
         .x(fndDot),
         .y(fndDp)
     );


endmodule




module BCDtoSEG(
    input logic [3:0] bcd,
    output logic [7:0] seg
    );

    always @(bcd) begin
        case(bcd)
        4'h0: seg= 8'hc0;
        4'h1: seg= 8'hf9;
        4'h2: seg = 8'ha4;
        4'h3: seg=8'hb0;
        4'h4: seg=8'h99;
        4'h5: seg=8'h92;
        4'h6: seg=8'h82;
        4'h7: seg=8'hf8;
        4'h8: seg=8'h80;
        4'h9: seg=8'h90;
        4'ha: seg=8'h88;
        4'hb: seg=8'h83;
        4'hc: seg=8'hc6;
        4'hd: seg=8'ha1;
        4'he: seg=8'h86;
        4'hf: seg=8'h8e;

        default:seg=8'hff;
        endcase
    end
endmodule


module clk_divider(
    input clk,
    input reset,
    output o_clk
    );
    parameter FCOUNT = 500_000 ;
    reg r_clk;
    reg [$clog2(FCOUNT)-1:0] r_counter;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk <=1'b0;
        end else begin
            if (r_counter == FCOUNT -1) begin
                r_counter <=0;
                r_clk <= 1'b1;
            end else begin
                r_clk <= 1'b0;
                r_counter <= r_counter+1;
            end
        end 
    end
    assign o_clk = r_clk;

endmodule

module counter_4(
    input clk,
    input reset,
    output [1:0] o_sel
    );
    reg [1:0] r_counter;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <=2'b00;
        end else begin
            r_counter <= r_counter +1;
        end
    end
    //overflow가 발생해도 0,1,2,3 안에서 반복된다. (순환)
    assign o_sel=r_counter;
endmodule


module decoder(
    input logic en,
    input logic [1:0] x,
    output logic [3:0] y
    );
    always @(x) begin
        if(en) begin
            case(x)
                2'b00: y=4'b1110;
                2'b01: y=4'b1101;
                2'b10: y=4'b1011;
                2'b11: y=4'b0111;
            endcase
        end else begin
            y=4'b1111;
        end
    end
endmodule


module digitSplitter(
    input [13:0] i_digit,
    output [3:0] o_digit_1,
    output [3:0] o_digit_10,    
    output [3:0] o_digit_100,
    output [3:0] o_digit_1000
    );

    assign o_digit_1=i_digit%10;
    assign o_digit_10=i_digit/10%10;
    assign o_digit_100=i_digit/100 %10;
    assign o_digit_1000=i_digit/1000 %10;
endmodule



module mux(
    input [1:0] sel,
    input [3:0] x0,
    input [3:0] x1,
    input [3:0] x2,
    input [3:0] x3,
    output reg [3:0] y
    );

    always @(*) begin
        case(sel)
            2'b00: y=x0;
            2'b01: y=x1;
            2'b10: y=x2;
            2'b11: y=x3;
            default: y=x0;
        endcase
    end
endmodule



 module mux_4X1_1bit (
     input [1:0] sel,
     input [3:0] x,
     output reg y
 );
     always @(*) begin
         y=1'b1;
         case(sel)
             2'b00: y=x[0];
             2'b01: y=x[1];
             2'b10: y=x[2];
             2'b11: y=x[3];
         endcase
     end    
 endmodule