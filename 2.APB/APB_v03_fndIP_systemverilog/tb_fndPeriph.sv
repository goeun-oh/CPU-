`timescale 1ns / 1ps

class transaction;

    rand logic [ 3:0] PADDR;
    rand logic [31:0] PWDATA;
    rand logic        PWRITE;
    rand logic        PENABLE;
    rand logic        PSEL;

    //out data들은 random하게 만들 수 없다! 출력이니까

    logic      [31:0] PRDATA;  //dut out data
    logic             PREADY;  //dut out data
    logic      [ 7:0] fndFont;  //dut out data
    logic      [ 3:0] fndComm;  //dut out data

    constraint c_paddr {PADDR inside {4'h0, 4'h4, 4'h8};} //이 중에 하나만 random 값으로 쓰겠다
    constraint c_wdata {PWDATA <10;}

    task display(string name);
        $display(
            "[%s] PADDR=%h, PWDATA=%h, PWRITE=%h, PENABLE=%h, PSEL=%h, PRDATA=%h, PREADY=%h, fndComm=%h, fndFont=%h",
            name, PADDR, PWDATA, PWRITE, PENABLE, PSEL, PRDATA, PREADY,
            fndComm, fndFont);
    endtask  //display

endclass  //transaction


interface APB_fnd_Controller;
    logic        PCLK;
    logic        PRESET;
    logic [ 3:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;
    logic        PREADY;
    logic [ 7:0] fndFont;
    logic [ 3:0] fndComm;

endinterface  //APB_fnd_Controller

class generator;
    mailbox #(transaction) Gen2Drv_mbox;
    event gen_next_event;

    function new(mailbox#(transaction) Gen2Drv_mbox, event gen_next_event);
        this.Gen2Drv_mbox   = Gen2Drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run(int repeat_counter);
        transaction fnd_tr;
        repeat (repeat_counter) begin
            fnd_tr = new();
            if (!fnd_tr.randomize()) $error("Randomization fail!");
            fnd_tr.display("GEN");
            Gen2Drv_mbox.put(fnd_tr);
            @(gen_next_event);
            //wait a event from driver
            //이게 없으면 repeat_counter 만큼 transaction이 계속 만들어질것, 기다리고 만들어야한다.
        end
    endtask

endclass

class driver;
    virtual APB_fnd_Controller fnd_intf;
    mailbox #(transaction) Gen2Drv_mbox;
    event gen_next_event;
    transaction fnd_tr;


    function new(mailbox#(transaction) Gen2Drv_mbox, event gen_next_event,
                 virtual APB_fnd_Controller fnd_intf);
        this.fnd_intf       = fnd_intf;
        this.Gen2Drv_mbox   = Gen2Drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run();
        forever begin
            Gen2Drv_mbox.get(fnd_tr);
            fnd_tr.display("DRV");
            //setup 구간
            @(posedge fnd_intf.PCLK);
            fnd_intf.PADDR   <= fnd_tr.PADDR;
            fnd_intf.PWDATA  <= fnd_tr.PWDATA;
            fnd_intf.PWRITE  <= 1'b1;
            fnd_intf.PENABLE <= 1'b0;
            fnd_intf.PSEL    <= 1'b1;
            //access구간
            @(posedge fnd_intf.PCLK);
            fnd_intf.PADDR   <= fnd_tr.PADDR;
            fnd_intf.PWDATA  <= fnd_tr.PWDATA;
            fnd_intf.PWRITE  <= 1'b1;
            fnd_intf.PENABLE <= 1'b1;
            fnd_intf.PSEL    <= 1'b1;
            wait (fnd_intf.PREADY == 1'b1);
            @(posedge fnd_intf.PCLK);
            @(posedge fnd_intf.PCLK);
            @(posedge fnd_intf.PCLK);

            ->gen_next_event;  //event trigger           
        end
    endtask


endclass


class envirnment;
    mailbox #(transaction) Gen2Drv_mbox;
    generator fnd_gen;
    driver fnd_drv;
    event gen_next_event;

    function new(virtual APB_fnd_Controller fnd_intf);
        Gen2Drv_mbox = new();
        this.fnd_gen = new(Gen2Drv_mbox, gen_next_event);
        this.fnd_drv = new(Gen2Drv_mbox, gen_next_event, fnd_intf);
    endfunction


    task run(int count);
        fork
            fnd_gen.run(count);
            fnd_drv.run();
        join_any
    endtask  //run


endclass

module tb_fndPeriph ();

    envirnment fnd_env;
    APB_fnd_Controller fnd_intf(); //interface는 new필요없이 그냥 소괄호만 만들어줘도 실체화가 된다.

    always #5 fnd_intf.PCLK = ~fnd_intf.PCLK;

    initial begin
        fnd_intf.PCLK   = 0;
        fnd_intf.PRESET = 1;
        #10 fnd_intf.PRESET = 0;

        fnd_env = new(fnd_intf);
        fnd_env.run(10);
        #30 $finish;

    end


    fnd_Periph DUT (
        .PCLK   (fnd_intf.PCLK),
        .PRESET (fnd_intf.PRESET),
        .PADDR  (fnd_intf.PADDR),
        .PWDATA (fnd_intf.PWDATA),
        .PWRITE (fnd_intf.PWRITE),
        .PENABLE(fnd_intf.PENABLE),
        .PSEL   (fnd_intf.PSEL),
        .PRDATA (fnd_intf.PRDATA),
        .PREADY (fnd_intf.PREADY),
        .fndFont(fnd_intf.fndFont),
        .fndComm(fnd_intf.fndComm)
    );


endmodule
