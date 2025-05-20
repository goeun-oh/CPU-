`timescale 1ns / 1ps

module tb_SPI_Master();
    // global signals
    logic       clk;
    logic       reset;

    logic       CPOL;
    logic       CPHA;
    logic       start;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic       done;
    logic       ready;
    // external port
    logic       SCLK;
    logic       MOSI;
    logic       MISO;
    logic       SS;

    SPI_Master dut(
        .*
    );
    SPI_Slave slave_dut(
        .*
    );
    
    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1;
        #10 reset = 0;
        SS = 1;

        repeat (3) @(posedge clk); // clk 3번 후 동작.

        // address byte
        SS = 0;
        @(posedge clk);         
        // WRITE 절차.
        tx_data = 8'b10000000; start = 1; CPOL = 0; CPHA = 0; //1번째 바이트는 [7] msb, write read선택, lsb는 00으로 주소.
        SS = 0;
        @(posedge clk);
        start = 0;
        wait(done == 1);
        @(posedge clk);

        //write data byte on 0x00 address
        @(posedge clk);
        tx_data = 8'h10; start = 1; CPOL = 0; CPHA = 0;
        SS = 0;
        @(posedge clk);
        start = 0;
        wait(done == 1);
        @(posedge clk);

        //write data byte on 0x01 address
        @(posedge clk);
        tx_data = 8'h20; start = 1; CPOL = 0; CPHA = 0;
        SS = 0;
        @(posedge clk);
        start = 0;
        wait(done == 1);
        @(posedge clk);

        //write data byte on 0x02 address
        @(posedge clk);
        tx_data = 8'h30; start = 1; CPOL = 0; CPHA = 0;
        SS = 0;
        @(posedge clk);
        start = 0;
        wait(done == 1);
        @(posedge clk);

        // write data byte on 0x03 address
        @(posedge clk);
        tx_data = 8'h40; start = 1; CPOL= 0; CPHA = 0;                  //MISO = MOSI;    //loop형성.x 그냥 값을 준거임. 위에 assign으로.
        SS = 0;
        @(posedge clk);
        start = 0;
        wait(done == 1);
        @(posedge clk);

        SS = 1; //선택 해제

        repeat(5) @(posedge clk);
        SS = 0;
        @(posedge clk);
        tx_data = 8'b00000000; start =1; CPOL = 0; CPHA = 0; // 0번지의 주소의 데이터를 읽겠다.
        @(posedge clk);
        start = 0;
        wait (done == 1); 
        @(posedge clk);

        for (int i=0; i<4; i++) begin
        tx_data = 8'hff; start =1;          //
        //dumy data"? 를 줘야함.
        @(posedge clk);
        start = 1;   
        @(posedge clk);
        start = 0;   
        wait (done == 1); 
        @(posedge clk);
        end

        SS = 1;


        #2000 $finish;
    end


    endmodule
