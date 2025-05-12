`timescale 1ns / 1ps

module fifo_Periph_tb;

  // APB 신호
  logic        PCLK;
  logic        PRESET;
  logic [3:0]  PADDR;
  logic [31:0] PWDATA;
  logic        PWRITE;
  logic        PENABLE;
  logic        PSEL;
  logic [31:0] PRDATA;
  logic        PREADY;
    logic [31:0] rdata;

  // DUT 인스턴스
  fifo_Periph dut (
    .PCLK(PCLK),
    .PRESET(PRESET),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PENABLE(PENABLE),
    .PSEL(PSEL),
    .PRDATA(PRDATA),
    .PREADY(PREADY)
  );

  // 클럭 생성 (100MHz)
  always #5 PCLK = ~PCLK;

  // APB write task
  task apb_write(input [3:0] addr, input [31:0] data);
    begin
      @(posedge PCLK);
      PADDR   <= addr;
      PWDATA  <= data;
      PWRITE  <= 1;
      PSEL    <= 1;
      PENABLE <= 0;

      @(posedge PCLK);
      PENABLE <= 1;

      wait(PREADY == 1);

      @(posedge PCLK);
      PSEL    <= 0;
      PENABLE <= 0;
      PWRITE  <= 0;
    end
  endtask

  // APB read task
  task apb_read(input [3:0] addr, output [31:0] data);
    begin
      @(posedge PCLK);
      PADDR   <= addr;
      PWRITE  <= 0;
      PSEL    <= 1;
      PENABLE <= 0;

      @(posedge PCLK);
      PENABLE <= 1;

      wait(PREADY == 1);

      data = PRDATA;

      @(posedge PCLK);
      PSEL    <= 0;
      PENABLE <= 0;
    end
  endtask

  // 초기화 및 테스트 시나리오
  initial begin
    $display("===== FIFO Peripheral Testbench 시작 =====");
    PCLK = 0;
    PRESET = 1;
    PSEL = 0;
    PENABLE = 0;
    PWRITE = 0;
    PADDR = 0;
    PWDATA = 0;

    // 리셋
    repeat (2) @(posedge PCLK);
    PRESET = 0;


    // 1. FSR 읽기
    apb_read(4'h0, rdata);
    $display("[READ] FSR = %b (empty: %b, full: %b)", rdata[1:0], rdata[0], rdata[1]);

    // 2. 데이터 0xAA 쓰기
    apb_write(4'h4, 32'h000000AA);
    $display("[WRITE] FWD <= 0xAA");

    // 3. 데이터 0xBB 쓰기
    apb_write(4'h4, 32'h000000BB);
    $display("[WRITE] FWD <= 0xBB");
    // 5. 실제 데이터 읽기
    apb_read(4'h8, rdata);  // FRD 레지스터
    $display("[READ] FRD = 0x%0h", rdata[7:0]);

    // 7. 두 번째 데이터 읽기
    apb_read(4'h8, rdata);
    $display("[READ] FRD = 0x%0h", rdata[7:0]);

    $display("===== FIFO Peripheral Testbench 완료 =====");
    $stop;
  end

endmodule
