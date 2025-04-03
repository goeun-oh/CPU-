
module comp_dot (
    input  [13:0] count,
    input  mode,
    output reg [ 3:0] dot_data
);

//mode:0 stopWatch, 1: updownCounter

    always @(*) begin
        if(mode) begin
            dot_data = ((count %10) <5) ? 4'b1101: 4'b1111;
        end else begin
            dot_data = ((count %10 <5)) ? 4'b0101: 4'b1111;
        end
    end
endmodule
