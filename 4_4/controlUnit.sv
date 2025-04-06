module controlUnit (
    input  logic clk,
    input  logic rst,
    input  logic nlt10,
    output logic nSel,
    output logic sumSel,
    output logic adderMuxSel,
    output logic nEn,
    output logic sumEn,
    output logic outBuf
);

    localparam S0 = 0, S1 = 1, Nup = 2, SUMup = 3, S4 = 4, HALT=5;

    logic [2:0] state, next;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S0;
        end else begin
            state <= next;
        end
    end


    always_comb begin
        next= state;

        case(state)
            S0: begin
                nSel=0;
                sumSel=0;
                adderMuxSel=0;
                nEn=0;
                sumEn=0;
                outBuf=0;
                next= S1;        
            end
            S1: begin
                nSel=1;
                sumSel=0;
                adderMuxSel=0;
                nEn=0;
                sumEn=0;
                outBuf=0;
                if (nlt10) begin
                    next= Nup;
                end else begin
                    next= HALT;
                end
            end
            Nup: begin
                nSel=1;
                sumSel=1;
                adderMuxSel=0;
                nEn=1;
                sumEn=0;
                outBuf=0;
                next=SUMup;
            end
            SUMup: begin
                nSel=1;
                sumSel=1;
                adderMuxSel=1;
                nEn=0;
                sumEn=0;
                outBuf=1;
                next=S4;
            end
            S4: begin
                nSel=1;
                sumSel=1;
                adderMuxSel=1;
                nEn=0;
                sumEn=1;
                outBuf=1;
                next=S1;
            end
            HALT: begin
                nSel=0;
                sumSel=0;
                adderMuxSel=0;
                nEn=0;
                sumEn=0;
                outBuf=0;
            end
        endcase
    end

endmodule
