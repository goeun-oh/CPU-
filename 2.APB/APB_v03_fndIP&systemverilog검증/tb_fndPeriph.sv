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

    task display(string name);
        $display(
            "[%s] PADDR=%h, PWDATA=%h, PWRITE=%h, PENABLE=%h, PSEL=%h, PRDATA=%h, PREADY=%h, fndComm=%h, fndFont=%h",
            name, PADDR, PWDATA, PWRITE, PENABLE, PSEL, PRDATA, PREADY,
            fndComm, fndFont);
    endtask  //display

endclass  //transaction


interface APB_fnd_Controller;
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

    function new(mailbox #(transaction) Gen2Drv_mbox);
        this.Gen2Drv_mbox= Gen2Drv_mbox;
    endfunction

    task run(int repeat_counter);
        transaction fnd_tr;
        repeat(repeat_counter) begin
            fnd_tr = new();
            if (!fnd_tr.randomize()) $error("Randomization fail!");
            fnd_tr.display("GEN");
            Gen2Drv_mbox.put(fnd_tr);
        end
    endtask

endclass


module tb_fndPeriph ();



endmodule
