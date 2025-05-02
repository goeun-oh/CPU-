`timescale 1ns / 1ps

module uart_Periph_tb;

  logic clk;
  logic reset;

  // APB signals
  logic [3:0]  PADDR;
  logic [31:0] PWDATA;
  logic        PWRITE;
  logic        PENABLE;
  logic        PSEL;
  logic [31:0] PRDATA;
  logic        PREADY;

  // UART signals
  logic rx;
  logic tx;
    logic [31:0] read_data;

  uart_Periph dut (
    .PCLK(clk),
    .PRESET(reset),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PENABLE(PENABLE),
    .PSEL(PSEL),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .rx(rx),
    .tx(tx)
  );

  // Parameters
  parameter BAUD_RATE = 9600;
  parameter BIT_TIME = 104167; // 1e9ns / 9600bps

  // 100MHz clock
  always #5 clk = ~clk;

  // APB Write
  task apb_write(input [3:0] addr, input [31:0] data);
    begin
      @(posedge clk);
      PADDR   <= addr;
      PWDATA  <= data;
      PWRITE  <= 1;
      PSEL    <= 1;
      PENABLE <= 0;

      @(posedge clk);
      PENABLE <= 1;
      wait (PREADY);
      @(posedge clk);
      PWRITE  <= 0;
      PSEL    <= 0;
      PENABLE <= 0;
    end
  endtask

  // APB Read
  task apb_read(input [3:0] addr, output [31:0] data);
    begin
      @(posedge clk);
      PADDR   <= addr;
      PWRITE  <= 0;
      PSEL    <= 1;
      PENABLE <= 0;

      @(posedge clk);
      PENABLE <= 1;
      wait (PREADY);
      data = PRDATA;
      @(posedge clk);
      PSEL    <= 0;
      PENABLE <= 0;
    end
  endtask

  // UART RX 시리얼 바이트 입력 (9600bps 기준)
  task uart_send_byte(input [7:0] data);
    int i;
    begin
      rx <= 0; #(BIT_TIME);  // Start bit
      for (i = 0; i < 8; i++) begin
        rx <= data[i]; #(BIT_TIME);
      end
      rx <= 1; #(BIT_TIME);  // Stop bit
    end
  endtask

  initial begin
    clk = 0;
    reset = 1;
    rx = 1;

    repeat (2) @(posedge clk);
    reset = 0;
    repeat (10) @(posedge clk);

    $display("=== UART Testbench 시작 ===");

    // RX 경로로 0x3C 전송
    uart_send_byte(8'h3C);
    $display("[UART] Sent byte 0x3C to rx");

    // 수신 대기
    #(BIT_TIME * 12);

    // RX FIFO에서 읽기
    apb_read(4'hC, read_data);
    $display("[APB] Read from RX FIFO: 0x%0h", read_data[7:0]);

    $display("=== UART Testbench 완료 ===");
    $stop;
  end

endmodule
