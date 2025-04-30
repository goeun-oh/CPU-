`timescale 1ns / 1ps

class transaction;
    rand logic we;
    rand logic re;
    rand logic [7:0] wdata;
    logic [7:0] rdata;
    logic empty;
    logic full;

    task display(string name);
        $display("[%s] we=%h, re=%h, wdata=%h, rdata=%h, empty=%h, full=%h",
                 name, we, re, wdata, rdata, empty, full);
    endtask  //display
endclass

interface fifo_interface (
    input logic clk,
    input logic reset
);
    logic       we;
    logic       re;
    logic [7:0] wdata;
    logic [7:0] rdata;
    logic       empty;
    logic       full;
endinterface  //fifo_intf

class generator;
    mailbox #(transaction) Gen2Drv_mbox;
    event gen_next_event;

    function new(mailbox#(transaction) Gen2Drv_mbox, event gen_next_event);
        this.Gen2Drv_mbox   = Gen2Drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run(int repeat_count);
        transaction fifo_tr;
        repeat (repeat_count) begin
            fifo_tr = new();
            if (!fifo_tr.randomize()) $error("Randomization fail!");
            fifo_tr.display("GEN");
            Gen2Drv_mbox.put(fifo_tr);
            @(gen_next_event);
        end
    endtask  //run

endclass

class driver;
    mailbox #(transaction) Gen2Drv_mbox;
    virtual fifo_interface fifo_intf;

    function new(mailbox#(transaction) Gen2Drv_mbox,
                 virtual fifo_interface fifo_intf);
        this.Gen2Drv_mbox = Gen2Drv_mbox;
        this.fifo_intf    = fifo_intf;
    endfunction

    task run();
        transaction fifo_tr;
        forever begin
            Gen2Drv_mbox.get(fifo_tr);
            fifo_intf.we = fifo_tr.we;
            fifo_intf.re = fifo_tr.re;
            fifo_intf.wdata = fifo_tr.wdata;
            fifo_tr.display("DRV");
            @(posedge fifo_intf.clk);

        end
    endtask
endclass


class monitor;
    mailbox #(transaction) Mon2SCB_mbox;
    virtual fifo_interface fifo_intf;

    function new(mailbox#(transaction) Mon2SCB_mbox,
                 virtual fifo_interface fifo_intf);
        this.Mon2SCB_mbox = Mon2SCB_mbox;
        this.fifo_intf = fifo_intf;
    endfunction

    task run();
        transaction fifo_tr;
        forever begin
            @(posedge fifo_intf.clk);
            fifo_tr       = new();
            fifo_tr.we    = fifo_intf.we;
            fifo_tr.re    = fifo_intf.re;
            fifo_tr.wdata = fifo_intf.wdata;
            fifo_tr.rdata = fifo_intf.rdata;
            fifo_tr.empty = fifo_intf.empty;
            fifo_tr.full  = fifo_intf.full;
            Mon2SCB_mbox.put(fifo_tr);
            fifo_tr.display("MON");
        end
    endtask
endclass

class scoreboard;
    mailbox #(transaction) Mon2SCB_mbox;
    transaction fifo_tr;
    event gen_next_event;

    logic [7:0] scb_fifo[$];  //동적 큐 선언
    logic [7:0] pop_data;

    function new(mailbox#(transaction) Mon2SCB_mbox, event gen_next_event);
        this.Mon2SCB_mbox   = Mon2SCB_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run();
        forever begin
            Mon2SCB_mbox.get(fifo_tr);
            fifo_tr.display("SCB");
            if (fifo_tr.we) begin
                if (!fifo_tr.full) begin
                    scb_fifo.push_back(
                        fifo_tr.wdata);  // 큐 맨 뒤에 값 추가
                    $display("[SCB] : Data Stored in queue : %h\n",
                             fifo_tr.wdata, scb_fifo);
                end else begin
                    $display("[SCB]: FIFO is full, %p\n", scb_fifo);
                end
            end
            if(fifo_tr.re) begin
                if(!fifo_tr.empty) begin
                    pop_data = scb_fifo.pop_front();
                    if(fifo_tr.rdata == pop_data) begin
                        $display("[SCB] data matched %h == %h\n", fifo_tr.rdata, pop_data);
                    end else begin
                        $display("[SCB] data dismatched %h != %h\n", fifo_tr.rdata, pop_data);
                    end
                end else begin
                    $display("[SCB] fifo is empty, %p\n", scb_fifo);
                end
            end
            ->gen_next_event;
        end
    endtask

endclass

class envirnment;
    mailbox #(transaction) Gen2Drv_mbox;
    mailbox #(transaction) Mon2SCB_mbox;
    generator fifo_gen;
    driver fifo_drv;
    event gen_next_event;

    monitor fifo_mon;
    scoreboard fifo_scb;

    function new(virtual fifo_interface fifo_intf);
        Gen2Drv_mbox = new();
        Mon2SCB_mbox = new();
        fifo_gen = new(Gen2Drv_mbox, gen_next_event);
        fifo_drv = new(Gen2Drv_mbox, fifo_intf);
        fifo_mon = new(Mon2SCB_mbox, fifo_intf);
        fifo_scb = new(Mon2SCB_mbox, gen_next_event);
    endfunction

    task run(int count);
        fork
            fifo_gen.run(count);
            fifo_drv.run();
            fifo_mon.run();
            fifo_scb.run();
        join_any
    endtask
endclass

module tb_fifo ();
    logic clk, reset;

    envirnment fifo_env;

    fifo_interface fifo_intf (
        clk,
        reset
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #10 reset = 0;
        @(posedge clk);
        fifo_env = new(fifo_intf);
        fifo_env.run(10);
        #30 $display("finish!");
        $finish;
    end

    fifo u_fifo (
        .clk  (clk),
        .reset(reset),
        .we   (fifo_intf.we),
        .re   (fifo_intf.re),
        .wdata(fifo_intf.wdata),
        .rdata(fifo_intf.rdata),
        .empty(fifo_intf.empty),
        .full (fifo_intf.full)
    );
endmodule
