`timescale 1ns / 1ps



interface fifo_interface (
    input logic clk,
    input logic reset
);

    // === DUT 제어 및 데이터 신호 ===
    logic       wr_en;  // Write enable
    logic       rd_en;  // Read enable
    logic       full;  // FIFO full 상태
    logic       empty;  // FIFO empty 상태
    logic [7:0] wdata;  // Write data
    logic [7:0] rdata;  // Read data

    // === Driver용 Clocking Block (TB → DUT) ===
    clocking drv_cb @(posedge clk);
        default input #1 output #1;

        output wr_en;
        output rd_en;
        output wdata;

        input full;
        input empty;
        input  rdata; // (Optional: driver에서 직접 read 결과 비교할 경우)
    endclocking

    // === Monitor용 Clocking Block (DUT → TB) ===
    clocking mon_cb @(posedge clk);
        default input #1 output #1;

        input wr_en;
        input rd_en;
        input wdata;
        input rdata;
        input full;
        input empty;
    endclocking

    // === Driver, Monitor 용도 별 Modport 정의 ===
    modport drv_mport(clocking drv_cb, input reset);
    modport mon_mport(clocking mon_cb, input reset);

endinterface  // FIFO_intf




class transaction;
    rand logic oper; // read/write 동작 결정

    rand logic       wr_en;  // Write enable
    rand logic       rd_en;  // Read enable
    logic            full;  // FIFO full 상태
    logic            empty;  // FIFO empty 상태
    rand logic [7:0] wdata;  // Write data
    logic      [7:0] rdata;  // Read data

    constraint oper_ctrl {oper dist {1:/80, 0:/ 20};}

    task display(string name);
        $display("[%S] wdata=%h, wr_en=%h, full=%d, rdata=%h, rd_en=%h, empty=%d",
                  name, wdata,   wr_en,    full,    rdata,    rd_en,    empty);
    endtask  //


endclass  //transaction



class generator;
    mailbox #(transaction) GenToDrv_mbox;
    event gen_next_event;

    function new(mailbox#(transaction) GenToDrv_mbox, event gen_next_event);
        this.GenToDrv_mbox = GenToDrv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction  //new()

    task run(int repeat_counter);
        transaction fifo_tr;
        repeat (repeat_counter) begin
            fifo_tr = new();
            if (!fifo_tr.randomize()) $error("Randomization failed!!!");
            fifo_tr.display("GEN");
            GenToDrv_mbox.put(fifo_tr);
            @(gen_next_event);
        end
    endtask 
endclass  //generator



class driver;
    mailbox #(transaction) GenToDrv_mbox;
    virtual fifo_interface.drv_mport fifo_if;
    transaction fifo_tr;

    function new(mailbox#(transaction) GenToDrv_mbox, virtual fifo_interface.drv_mport fifo_if);
        this.GenToDrv_mbox = GenToDrv_mbox;
        this.fifo_if = fifo_if;
    endfunction  //new()


    task write ();
        @(fifo_if.drv_cb);
        fifo_if.drv_cb.wdata <= fifo_tr.wdata;
        fifo_if.drv_cb.wr_en <= 1'b1;
        fifo_if.drv_cb.rd_en <= 1'b0;
        @(fifo_if.drv_cb);
        fifo_if.drv_cb.wr_en <= 1'b0;
    endtask //

    task read ();
        @(fifo_if.drv_cb);
        fifo_if.drv_cb.wr_en <= 1'b0;
        fifo_if.drv_cb.rd_en <= 1'b1;
        @(fifo_if.drv_cb);
        fifo_if.drv_cb.rd_en <= 1'b0;
    endtask //



    task run();
        forever begin
            GenToDrv_mbox.get(fifo_tr);
            if (fifo_tr.oper ==1) write();
            else read();
            fifo_tr.display("DRV");
        end
    endtask  //





endclass  //driver



class monitor;
    mailbox #(transaction) MonToSCB_mbox;
    virtual fifo_interface.mon_mport fifo_if;
    transaction fifo_tr;

    function new(mailbox #(transaction) MonToSCB_mbox, virtual fifo_interface.mon_mport fifo_if);
        this.MonToSCB_mbox = MonToSCB_mbox;
        this.fifo_if = fifo_if;
    endfunction  //new()



    task run();
        forever begin
            @(fifo_if.mon_cb);
            @(fifo_if.mon_cb);
            fifo_tr=new();
            fifo_tr.wdata = fifo_if.mon_cb.wdata;
            fifo_tr.wr_en = fifo_if.mon_cb.wr_en;
            fifo_tr.rd_en = fifo_if.mon_cb.rd_en;
            fifo_tr.full = fifo_if.mon_cb.full;
            fifo_tr.empty = fifo_if.mon_cb.empty;
            fifo_tr.rdata = fifo_if.mon_cb.rdata;

            MonToSCB_mbox.put(fifo_tr);
            fifo_tr.display("MON");
        end
    endtask  //

endclass  //monitor




class scoreboard;
    mailbox #(transaction) MonToSCB_mbox;
    event gen_next_event;
    transaction fifo_tr;

    logic [7:0] scb_fifo[$];
    logic [7:0] pop_data;

    logic [7:0] ref_model[0:2**5-1];

    function new(mailbox#(transaction) MonToSCB_mbox, event gen_next_event);
        this.MonToSCB_mbox = MonToSCB_mbox;
        this.gen_next_event = gen_next_event;
    endfunction  //new()

    task run();

        forever begin
            MonToSCB_mbox.get(fifo_tr);
            fifo_tr.display("SCB");

            if (fifo_tr.wr_en) begin  //write 일때
                if (!fifo_tr.full) begin
                    scb_fifo.push_back(fifo_tr.wdata);
                    $display("[SCB] : DATA Stored in queue : %d, current queue: %p", fifo_tr.wdata, scb_fifo);
                end else begin
                    $display("[SCB] : FIFO is full!! ,%p", scb_fifo);
                end
                -> gen_next_event;
            end 

            if (fifo_tr.rd_en) begin  //read 일 때 
                if (!fifo_tr.empty) begin
                    pop_data = scb_fifo.pop_front();    
                    if (fifo_tr.rdata == pop_data) begin
                        $display("[SCB] : DATA Matched!!  %d == %d", fifo_tr.rdata, pop_data);
                    end else begin
                        $display("[SCB] : DATA MisMatched!!  %d != %d", fifo_tr.rdata, pop_data);
                    end
                end else begin
                    $display("[SCB] : FIFO is empty!!");
                end
                -> gen_next_event;
            end
        end

    endtask 
endclass  //scoreboard




class environment;
    mailbox #(transaction) GenToDrv_mbox;
    mailbox #(transaction) MonToSCB_mbox;
    virtual fifo_interface fifo_if;
    event gen_next_event;

    generator              fifo_gen;
    driver                 fifo_drv;
    monitor                fifo_mon;
    scoreboard             fifo_scb;

    function new(virtual fifo_interface fifo_if);
        GenToDrv_mbox = new();
        MonToSCB_mbox = new();
        fifo_gen = new(GenToDrv_mbox, gen_next_event);
        fifo_drv = new(GenToDrv_mbox, fifo_if.drv_mport);
        fifo_mon = new(MonToSCB_mbox, fifo_if.mon_mport);
        fifo_scb = new(MonToSCB_mbox, gen_next_event);
    endfunction  //new()

    task run(int count);
        fork
            fifo_gen.run(count);
            fifo_drv.run();
            fifo_mon.run();
            fifo_scb.run();
        join_any
    endtask  //
endclass  




module tb_FIFO ();

    logic clk,reset;
    environment env;
    fifo_interface fifo_if(clk,reset);

    FIFO DUT (
        .clk(clk),
        .reset(reset),
        .wr_en(fifo_if.wr_en),
        .rd_en(fifo_if.rd_en),
        .full(fifo_if.full),
        .empty(fifo_if.empty),
        .wdata(fifo_if.wdata),
        .rdata(fifo_if.rdata)
);


    always #5 clk= ~clk;
    
    initial begin
        clk=0; reset=1;
        
        @(posedge clk);
        reset=0;
        @(posedge clk);
        env = new(fifo_if);
        env.run(10);
        #50 $finish;
    end




endmodule
