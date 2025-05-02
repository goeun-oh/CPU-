`timescale 1ns / 1ps
module uart_cu(
    input clk,
    input rst,
    input [7:0] i_cmd,
    input valid,
    output run,
    output clear,
    output hour,
    output min,
    output sec,
    output mode
    );
    reg run_reg, run_next;
    reg clear_reg, clear_next;
    reg hour_reg, hour_next;
    reg min_reg, min_next;
    reg sec_reg, sec_next;
    reg mode_reg, mode_next;

    assign run=run_reg;
    assign clear=clear_reg;
    assign hour=hour_reg;
    assign min=min_reg;
    assign sec=sec_reg;
    assign mode=mode_reg;
  
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            run_reg <= 1'b0;
            clear_reg <=1'b0;
            hour_reg <=1'b0;
            min_reg <= 1'b0;
            sec_reg <=1'b0;
            mode_reg <=1'b0;
        end else begin
            run_reg <= run_next;
            clear_reg <= clear_next;
            hour_reg <= hour_next;
            min_reg <= min_next;
            sec_reg <= sec_next;
            mode_reg <= mode_next;
        end
    end


    always @(*) begin
        run_next=1'b0;
        clear_next=1'b0;
        hour_next=1'b0;
        min_next=1'b0;
        sec_next=1'b0;
        mode_next=1'b0;
        case(i_cmd)
            //////////run//////////
            "R": begin
                run_next=1'b1 & valid;
            end
            "r": begin
                run_next=1'b1 & valid;
            end
            "C": begin
                clear_next=1'b1 & valid;                
            end
            "c": begin
                clear_next=1'b1 & valid;                
            end
            "H": begin
                hour_next= 1'b1 & valid;
            end
            "h": begin
                hour_next= 1'b1 & valid;

            end
            "M": begin
                min_next= 1'b1 & valid;
            end
            "m": begin
                min_next= 1'b1 & valid;
            end
            "S": begin
                sec_next= 1'b1 & valid;
            end
            "s": begin
                sec_next= 1'b1 & valid;
            end
            "X": begin
                mode_next=1'b1 & valid;
            end
            "x": begin
                mode_next=1'b1 & valid;
            end
 
        endcase
    end
endmodule
