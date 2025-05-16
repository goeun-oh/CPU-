`timescale 1ns / 1ps

module AXI4_Lite_Slave (
    // Global Signals
    input  logic        ACLK,
    input  logic        ARESETn,
    // WRITE Transaction, AW Channel
    input  logic [ 3:0] AWADDR,
    input  logic        AWVALID,
    output logic        AWREADY,
    // WRITE Transaction, W Channel
    input  logic [31:0] WDATA,
    input  logic        WVALID,
    output logic        WREADY,
    // WRITE Transaction, B Channel
    output logic [ 1:0] BRESP,
    output logic        BVALID,
    input  logic        BREADY
);

    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;

    // WRITE Transaction, AW Channel transfer
    typedef enum {
        AW_IDLE_S,
        AW_READY_S
    } aw_state_e;

    aw_state_e aw_state, aw_state_next;
    logic [3:0] aw_addr_reg, aw_addr_next;

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            aw_state    <= AW_IDLE_S;
            aw_addr_reg <= 0;
        end else begin
            aw_state    <= aw_state_next;
            aw_addr_reg <= aw_addr_next;
        end
    end

    always_comb begin
        aw_state_next = aw_state;
        aw_addr_next  = aw_addr_reg;
        AWREADY       = 1'b0;
        case (aw_state)
            AW_IDLE_S: begin
                AWREADY = 1'b0;
                if (AWVALID) begin
                    aw_state_next = AW_READY_S;
                    aw_addr_next  = AWADDR;
                end
            end
            AW_READY_S: begin
                AWREADY      = 1'b1;
                aw_addr_next = AWADDR;
                if (AWVALID && AWREADY) begin
                    aw_state_next = AW_IDLE_S;
                end
            end
        endcase
    end

    // WRITE Transaction, W Channel transfer
    typedef enum {
        W_IDLE_S,
        W_READY_S
    } w_state_e;

    w_state_e w_state, w_state_next;

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            w_state <= W_IDLE_S;
        end else begin
            w_state <= w_state_next;
        end
    end

    always_comb begin
        w_state_next = w_state;
        WREADY = 1'b0;
        case (w_state)
            W_IDLE_S: begin
                WREADY = 1'b0;
                if (AWVALID) w_state_next = W_READY_S;
            end
            W_READY_S: begin
                WREADY = 1'b1;
                if (WVALID) begin
                    w_state_next = W_IDLE_S;    
                    case (aw_addr_reg[3:2])
                        2'd0: slv_reg0 = WDATA;
                        2'd1: slv_reg1 = WDATA;
                        2'd2: slv_reg2 = WDATA;
                        2'd3: slv_reg3 = WDATA;
                    endcase
                end
            end
        endcase
    end

    // WRITE Transaction, B Channel transfer
    typedef enum {
        B_IDLE_S,
        B_VALID_S
    } b_state_e;

    b_state_e b_state, b_state_next;

    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            b_state <= B_IDLE_S;
        end else begin
            b_state <= b_state_next;
        end
    end

    always_comb begin
        b_state_next = b_state;
        BRESP        = 2'b00;
        BVALID       = 1'b0;
        case (b_state)
            B_IDLE_S: begin
                BVALID = 1'b0;
                if (WVALID && WREADY) begin
                    b_state_next = B_VALID_S;
                end
            end
            B_VALID_S: begin
                BRESP  = 2'b00;  // OK
                BVALID = 1'b1;
                if (BREADY) begin
                    b_state_next = B_IDLE_S;
                end
            end
        endcase
    end
endmodule
