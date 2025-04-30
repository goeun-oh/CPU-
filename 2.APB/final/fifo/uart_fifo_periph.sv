module UART_FIFO_Periph (
    // global signal
    input logic PCLK,
    input logic PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    input  logic        rx,
    output logic        tx
);

    logic [7:0] uart_rx_data;
    logic [7:0] uart_tx_data;

    logic full_tx, empty_tx, full_rx, empty_rx;
    logic [7:0] fifo_rdata, fifo_wdata;
    logic rd_en_rx, wr_en_tx;
    logic w_tick;

    logic rx_done, tx_done;
    logic rx_ready;

    APB_Intf_FIFO u_APB_Intf_FIFO (
        .*,
        .fifo_rdata(fifo_rdata),
        .fifo_wdata(fifo_wdata),
        .rd_en     (rd_en_rx),
        .wr_en     (wr_en_tx),
        .full_tx   (full_tx),
        .empty_tx  (empty_tx),
        .full_rx   (full_rx),
        .empty_rx  (empty_rx)
    );

    FIFO u_FIFO_tx (
        .clk  (PCLK),
        .reset(PRESET),
        .wr_en(wr_en_tx),
        .rd_en(tx_done),
        .full (full_tx),
        .empty(empty_tx),
        .wdata(fifo_wdata),
        .rdata(uart_tx_data)
    );

    FIFO u_FIFO_rx (
        .clk  (PCLK),
        .reset(PRESET),
        .wr_en(rx_done),
        .rd_en(rd_en_rx),
        .full (full_rx),
        .empty(empty_rx),
        .wdata(uart_rx_data),
        .rdata(fifo_rdata)
    );

    tx u_tx (
        .clk      (PCLK),
        .rst      (PRESET),
        .tick     (w_tick),
        .tx_start (!empty_tx),
        .i_data   (uart_tx_data),
        .o_tx_done(tx_done),
        .o_tx     (tx)
    );


    rx u_rx (
        .clk    (PCLK),
        .rst    (PRESET),
        .rx     (rx),
        .tick   (w_tick),
        .rx_data(uart_rx_data),
        .rx_done(rx_done)
    );



    baudrate_gen u_baudrate_gen_9600 (
        .clk(PCLK),
        .reset(PRESET),
        .br_tick(w_tick)
    );


endmodule

module APB_Intf_FIFO (
    // global signal



    input logic PCLK,
    input logic PRESET,
    // APB Interface Signals



    input  logic [ 3:0] PADDR,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // output logic FSR



    input  logic       full_rx,
    empty_rx,
    full_tx,
    empty_tx,
    output logic       rd_en,
    output logic       wr_en,
    input  logic [7:0] fifo_rdata,
    output logic [7:0] fifo_wdata
);

    logic [1:0] FSR_rx, FSR_tx;
    logic [7:0] FWD;
    logic [7:0] FRD;

    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;

    assign fifo_wdata = slv_reg0[7:0];
    assign slv_reg1 = {24'b0, fifo_rdata};
    assign slv_reg2 = {30'b0, full_tx, empty_tx};
    assign slv_reg3 = {30'b0, full_rx, empty_rx};

    assign FWD = slv_reg0[7:0];
    assign FRD = slv_reg1[7:0];
    assign FSR_tx = slv_reg2;
    assign FSR_rx = slv_reg3;

    logic prev_penable;

    always_ff @(posedge PCLK or posedge PRESET) begin
        if (PRESET) begin
            prev_penable <= 0;
            wr_en <= 0;
            rd_en <= 0;
            PREADY <= 0;
        end else begin
            prev_penable <= PENABLE;  // 항상 현재 PENABLE 기억



            if (PSEL) begin
                if (!prev_penable && PENABLE) begin  // PENABLE rising edge




                    if (PWRITE) begin
                        wr_en <= 1;
                        rd_en <= 0;
                        if (PADDR[3:2] == 2'b0) begin
                            slv_reg0 <= PWDATA;
                        end
                        PREADY <= 1;
                    end else begin
                        wr_en  <= 0;
                        rd_en  <= 1;
                        PREADY <= 1;
                    end
                end else begin
                    wr_en  <= 0;
                    rd_en  <= 0;
                    PREADY <= 0;
                end
            end else begin
                wr_en  <= 0;
                rd_en  <= 0;
                PREADY <= 0;
            end
        end
    end

    always_comb begin
        if (PSEL && PENABLE && !PWRITE) begin
            case (PADDR[3:2])
                2'd1: PRDATA = slv_reg1;  // FRD



                2'd2: PRDATA = slv_reg2;  // FSR_tx



                2'd3: PRDATA = slv_reg3;  // FSR_rx



                default: PRDATA = 32'b0;
            endcase
        end else begin
            PRDATA = 32'b0;  // 필수로 초기화2



        end
    end
endmodule


module FIFO (
    input logic clk,
    input logic reset,
    input logic wr_en,
    input logic rd_en,
    output logic full,
    output logic empty,
    input logic [7:0] wdata,
    output logic [7:0] rdata
);

    logic [1:0] wr_ptr, rd_ptr;

    RAM_FIFO u_RAM_FIFO (
        .clk  (clk),
        .wAddr(wr_ptr),
        .wdata(wdata),
        .wr_en(wr_en & ~full),
        .rAddr(rd_ptr),
        .rdata(rdata)
    );

    FIFO_ControlUnit u_FIFO_Control (
        .clk(clk),
        .reset(reset),
        .wr_ptr(wr_ptr),
        .wr_en(wr_en),
        .full(full),
        .rd_ptr(rd_ptr),
        .rd_en(rd_en),
        .empty(empty)
    );


endmodule


module RAM_FIFO (
    input  logic       clk,
    input  logic [1:0] wAddr,
    input  logic [7:0] wdata,
    input  logic       wr_en,
    input  logic [1:0] rAddr,
    output logic [7:0] rdata
);

    logic [7:0] mem[0:2**2-1];


    always_ff @(posedge clk) begin
        if (wr_en) begin
            mem[wAddr] <= wdata;
        end
    end

    assign rdata = mem[rAddr];


endmodule


module FIFO_ControlUnit (
    input logic clk,
    input logic reset,
    // write side



    output logic [1:0] wr_ptr,
    input logic wr_en,
    output logic full,
    // read side



    output logic [1:0] rd_ptr,
    input logic rd_en,
    output logic empty
);

    localparam READ = 2'b01, WRITE = 2'b10, READ_WRITE = 2'b11;

    logic [1:0] fifo_state;

    logic empty_reg, empty_next;
    logic full_reg, full_next;
    logic [1:0] wr_ptr_reg, wr_ptr_next;
    logic [1:0] rd_ptr_reg, rd_ptr_next;

    assign empty  = empty_reg;
    assign full   = full_reg;
    assign wr_ptr = wr_ptr_reg;
    assign rd_ptr = rd_ptr_reg;


    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr_reg <= 0;
            rd_ptr_reg <= 0;
            full_reg   <= 1'b0;
            empty_reg  <= 1'b1;
        end else begin
            wr_ptr_reg <= wr_ptr_next;
            rd_ptr_reg <= rd_ptr_next;
            full_reg   <= full_next;
            empty_reg  <= empty_next;
        end
    end


    assign fifo_state = {wr_en, rd_en};

    always_comb begin
        wr_ptr_next = wr_ptr_reg;
        rd_ptr_next = rd_ptr_reg;
        full_next   = full_reg;
        empty_next  = empty_reg;
        case (fifo_state)
            READ: begin
                if (!empty) begin
                    full_next   = 0;
                    rd_ptr_next = rd_ptr_reg + 1;
                    if (wr_ptr_next == rd_ptr_next) begin
                        empty_next = 1'b1;
                    end
                end

            end

            WRITE: begin
                if (!full) begin
                    empty_next  = 1'b0;
                    wr_ptr_next = wr_ptr_reg + 1;
                    if (wr_ptr_next == rd_ptr_next) begin
                        full_next = 1'b1;
                    end
                end
            end

            READ_WRITE: begin
                if (empty_reg == 1) begin
                    wr_ptr_next = wr_ptr_reg + 1;
                    empty_next  = 1'b0;
                end else if (full_reg == 1) begin
                    rd_ptr_next = rd_ptr_reg + 1;
                    full_next   = 1'b0;
                end else begin
                    wr_ptr_next = wr_ptr_reg + 1;
                    empty_next  = 1'b0;
                    rd_ptr_next = rd_ptr_reg + 1;
                    full_next   = 1'b0;

                end


            end

        endcase
    end


endmodule





module baudrate_gen (
    input  logic clk,
    reset,
    output logic br_tick
);

    parameter COUNT_MAX = (100_000_000 / 9600) / 16;

    logic [$clog2(COUNT_MAX)-1:0] br_counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            br_counter <= 0;
            br_tick <= 0;
        end else begin
            if (br_counter == COUNT_MAX - 1) begin
                br_tick <= 1;
                br_counter <= 0;
            end else begin
                br_counter <= br_counter + 1;
                br_tick <= 0;
            end
        end
    end

endmodule
