`timescale 1ns / 1ps

//truth table 만들고 -> ASM -> code

module controlUnit(
    input  logic       clk,
    input  logic       rst,
    input  logic       iLe10,
    output logic       RFSrcMuxSel,
    output logic [2:0] readAddr1,
    output logic [2:0] readAddr2,
    output logic [2:0] writeAddr,
    output logic       writeEn,
    output logic       outBuf
    );

    typedef enum logic [2:0] {
        r1INIT = 3'b000,
        r2INIT = 3'b001,
        r3INIT = 3'b010,
        r2UP = 3'b011,
        r1UP = 3'b100,
        HALT = 3'b101
    } state_t;
    state_t state, next;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= r1INIT;
        end else begin
            state <= next;
        end
    end

    always_comb begin
        // Default values
        RFSrcMuxSel = 1'b0;
        readAddr1 = 3'b000;
        readAddr2 = 3'b000;
        writeAddr = 3'b000;
        writeEn = 1'b0;
        outBuf = 1'b0;

        case (state)
            r1INIT: begin
                RFSrcMuxSel = 1'b1;
                readAddr1 = 3'b000; // Read from register 1
                readAddr2 = 3'b000; // Read from register 2
                writeAddr = 3'b001; // Write to register 3
                writeEn = 1'b1;     // Enable writing
                next = r2INIT;
            end

            r2INIT: begin
                RFSrcMuxSel = 1'b1; // Select register file source
                readAddr1 = 3'b000; // Read from register 1
                readAddr2 = 3'b000; // Read from register 2
                writeAddr = 3'b010; // Write to register 3
                writeEn = 1'b1;     // Enable writing
                next = r3INIT;
            end

            r3INIT: begin
                RFSrcMuxSel = 1'b0;
                readAddr1 = 3'b000; 
                readAddr2 = 3'b000; 
                writeAddr = 3'b011;
                writeEn = 1'b1;     

                if (iLe10) begin
                    next = r2UP;
                end else begin
                    next = HALT;
                end
            end

            r2UP: begin
                RFSrcMuxSel = 1'b1;
                readAddr1 = 3'b001; 
                readAddr2 = 3'b010; 
                writeAddr = 3'b010;
                writeEn = 1'b1;     
                outBuf = 1'b1;
                next = r1UP;
            end

            r1UP: begin
                RFSrcMuxSel = 1'b1;
                readAddr1 = 3'b001; 
                readAddr2 = 3'b011; 
                writeAddr = 3'b001;
                writeEn = 1'b1;     
                next = r3INIT;
            end

            HALT: begin
                // Do nothing, halt state
                next = HALT;
            end

            default: begin
                next = HALT; // Default to halt state on unknown state
            end
        endcase
    end
endmodule

