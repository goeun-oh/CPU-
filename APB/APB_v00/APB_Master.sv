`timescale 1ns / 1ps

module APB_Master (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    output logic [31:0] PADDR,
    output logic [31:0] PWDATA,
    output logic        PENABLE,
    output logic        PWRITE,
    output logic        PSEL1,     //우선 1개의 peri만 있다 가정
    input  logic [31:0] PRDATA1,   //우선 1개의 peri만 있다 가정
    input  logic        PREADY1,   //우선 1개의 peri만 있다 가정
    // Internal Interface Signals
    input  logic        transfer,
    // trigger(방아쇠, 시스템을 동작하게 만드는 최초 신호) sig cpu to bus
    output logic        ready,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    input  logic        write      //1: write, 0: read
);
    logic [31:0] temp_addr_reg, temp_addr_next;
    logic [31:0] temp_wdata_reg, temp_wdata_next;
    logic temp_write_reg, temp_write_next;

    typedef enum bit [1:0] {
        IDLE,
        SETUP,
        ACCESS
    } apb_state_e;

    apb_state_e state, state_next;

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            state <= IDLE;
            temp_addr_reg <= 0;
            temp_wdata_reg <= 0;
            temp_write_reg <= 0;
        end else begin
            state <= state_next;
            temp_addr_reg <= temp_addr_next;
            temp_wdata_reg <= temp_wdata_next;
            temp_write_reg <= temp_write_next;
        end
    end

    always_comb begin
        state_next      = state;
        temp_addr_next  = temp_addr_reg;
        temp_wdata_next = temp_wdata_reg;
        temp_write_next = temp_write_reg;
        case (state)
            IDLE: begin
                PSEL1 = 1'b0;
                if (transfer) begin
                    state_next = SETUP;
                    temp_addr_next = addr; //latching (임시 저장소에 저장)
                    temp_wdata_next = wdata;
                    temp_write_next = write;
                end
            end
            SETUP: begin
                PADDR   = temp_addr_reg;
                PENABLE = 1'b0;
                PSEL1   = 1'b1;
                if (temp_write_reg) begin
                    PWRITE = 1'b1;
                    PWDATA = temp_wdata_reg;
                end else begin
                    PWRITE = 1'b0;
                end
                state_next = ACCESS;
            end
            ACCESS: begin
                PADDR   = temp_addr_reg;
                PENABLE = 1'b1;
                PSEL1   = 1'b1;
                if (temp_write_reg) begin
                    PWRITE = 1'b1;
                    PWDATA = temp_wdata_reg;
                end else begin
                    PWRITE = 1'b0;
                end

                if (PREADY1) state_next = IDLE;
            end
        endcase
    end



endmodule


