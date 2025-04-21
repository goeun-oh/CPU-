`timescale 1ns / 1ps

module GPIO (
    input  logic [7:0] modeReg,
    input  logic [7:0] odReg,
    output logic [7:0] idReg,    //input data Register
    inout logic [7:0] inoutPort
);

    genvar i;
    generate
        for (i = 0; i < 8; i++) begin
            assign inoutPort[i] = modeReg[i] ? odReg[i] : 1'bz;
            assign idReg[i] = ~modeReg[i] ? inoutPort[i] : 1'bz;
        end
    endgenerate
endmodule


module GPIO_Periph (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    //export Signals
    output logic [31:0] PRDATA,
    output logic        PREADY,
    inout  logic [ 7:0] inoutPort
);


    logic [7:0] modeReg;
    logic [7:0] idReg;
    logic [7:0] odReg;

    APB_SlaveIntf_GPIO U_APB_Intf_GPIO (.*);

    GPIO U_GPIO (.*);


endmodule



module APB_SlaveIntf_GPIO (
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
    //internal Signals
    output logic [ 7:0] modeReg,
    input  logic [ 7:0] idReg,
    output logic [7:0] odReg
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2; //, slv_reg3;
    assign modeReg = slv_reg0[7:0];
    assign slv_reg1[7:0] = idReg;  //idReg는 cpu가 write할 수 없다
    assign odReg = slv_reg2[7:0];

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            //slv_reg1 <= 0; //idReg는 cpu가 write할 수 없다
            slv_reg2 <= 0;
            // slv_reg3 <= 0;
        end else begin
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: ;  //idReg는 cpu가 write할 수 없다
                        2'd2: slv_reg2 <= PWDATA;
                        // 2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                       // 2'd2: PRDATA <= slv_reg2;
                        // 2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end

endmodule

