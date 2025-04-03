
module control_unit (
    input            clk,
    input            reset,
    input            btn_L, //mode
    input            btn_R, //run/stop
    input            btn_D, //clear
    input            btn_U, //up/down
    //rx port
    input      [7:0] rx_data,
    input            rx_done,
    //tx port
    output reg [7:0] tx_data,
    output reg       tx_start,
    input            tx_busy,
    input            tx_done,
    //data path side port
    output reg       en,
    output reg       clear,
    output reg       up_down,
    output reg       mode
);
    localparam STOP = 0, RUN = 1, CLEAR = 2;  //state
    localparam UP = 0, DOWN = 1;  //updown_state
    localparam IDLE = 0, ECHO = 1;  //echo_state
    localparam WATCH =0, COUNT = 1;

    reg [1:0] state, state_next;
    reg updown_state, updown_state_next;
    reg echo_state, echo_state_next;
    reg mode_state, mode_next;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
            updown_state <= UP;
            echo_state <= IDLE;
            mode_state <= WATCH;
        end else begin
            state <= state_next;
            updown_state <= updown_state_next;
            echo_state <= echo_state_next;
            mode_state <= mode_next;
        end
    end
////////////mode
    always @(*) begin
        mode_next = mode_state;
        mode=1'b0;
        case(mode_state)
            WATCH: begin
                mode = 1'b0;
                if (rx_done) begin
                    if (rx_data == "m" || rx_data == "M")
                        mode_next = COUNT;
                end else if(btn_L) begin
                    mode_next= COUNT;
                end
            end

            COUNT: begin
                mode = 1'b1;
                if(rx_done) begin
                    if(rx_data == "m" || rx_data == "M")
                        mode_next= WATCH;
                end else if(btn_L) begin
                    mode_next = WATCH;
                end
            end

        endcase
    end

    always @(*) begin
        echo_state_next = echo_state;
        tx_data = 0;                
        tx_start = 1'b0;
        case (echo_state)
            IDLE: begin
                tx_data = 0;                
                tx_start = 1'b0;
                if (rx_done) begin
                    echo_state_next = ECHO;
                end
            end
            ECHO: begin
                if (tx_done) begin
                    echo_state_next = IDLE;
                end else begin
                    tx_data = rx_data;
                    tx_start = 1'b1;                    
                end
            end
        endcase
    end

//////////////updown
    always @(*) begin
        updown_state_next = updown_state;
        up_down = 1'b0;
        case (updown_state)
            UP: begin
                up_down = 1'b0;
                if (rx_done) begin
                    if (rx_data == "D" || rx_data == "d")
                        updown_state_next = DOWN;
                end else if(btn_U) begin
                    updown_state_next = DOWN;
                end
            end
            DOWN: begin
                up_down = 1'b1;
                if (rx_done) begin
                    if (rx_data == "D" || rx_data == "d")
                        updown_state_next = UP;
                end else if(btn_U) begin
                    updown_state_next=UP;
                end
            end
        endcase
    end
///////////clear, run/stop
    always @(*) begin
        state_next = state;
        en         = 1'b0;
        clear      = 1'b0;
        case (state)
            STOP: begin
                en = 1'b0;
                clear = 1'b0;
                if (rx_done) begin
                    if (rx_data == 8'h52 || rx_data == 8'h72)
                        state_next = RUN;  // "R","r"
                    else if (rx_data == 8'h43 || rx_data == 8'h63)
                        state_next = CLEAR;  //"C","c"
                end else if(btn_R) begin
                    state_next = RUN;
                end else if(btn_D) begin
                    state_next= CLEAR;
                end
            end
            RUN: begin
                en = 1'b1;
                clear = 1'b0;
                if (rx_done) begin
                    if (rx_data == 8'h53 || rx_data == 8'h73)
                        state_next = STOP;  // "S", "s"
                end else if(btn_R) begin
                    state_next = STOP;
                end
            end
            CLEAR: begin
                en = 1'b0;
                clear = 1'b1;
                state_next = STOP;
            end
        endcase
    end
endmodule

