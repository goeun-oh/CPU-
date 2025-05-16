interface adder_if ();
    logic clk;
    logic [7:0] a;
    logic [7:0] b;
    logic [8:0] y;
endinterface


`include "uvm_macros.svh"
import uvm_pkg::*;

class adder_seq_item extends uvm_sequence_item;
    rand bit [7:0] a;
    rand bit [7:0] b;
    bit [8:0] y;

    function new(string name = "ADDER_ITEM");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(adder_seq_item)
        `uvm_field_int(a, UVM_DEFAULT)
        `uvm_field_int(b, UVM_DEFAULT)
        `uvm_field_int(y, UVM_DEFAULT)
    `uvm_object_utils_end

endclass

class adder_sequence extends uvm_sequence #(adder_seq_item);
    `uvm_object_utils(adder_sequence)

    function new(string name = "SEQ");
        super.new(name);
    endfunction

    adder_seq_item adder_item;

    virtual task body();
        adder_item = adder_seq_item::type_id::create("ADDER_ITEM");

        for (int i = 0; i < 100; i++) begin
            start_item(adder_item);
            adder_item.randomize();
            $display(""); //한 줄만 띄우기
            `uvm_info(
                "SEQ", $sformatf(
                "adder item to driver a:%0d, b:%0d", adder_item.a, adder_item.b
                ), UVM_LOW);
            //adder_item.print(uvm_default_line_printer);

            finish_item(adder_item);
        end
    endtask  //body

endclass


class adder_driver extends uvm_driver #(adder_seq_item);
    `uvm_component_utils(adder_driver)

    function new(string name = "DRV", uvm_component parent);
        super.new(name, parent);
    endfunction

    adder_seq_item   adder_item;
    virtual adder_if a_if;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_item = adder_seq_item::type_id::create("ADDER ITEM");

        if (!uvm_config_db#(virtual adder_if)::get(this, "", "a_if", a_if))
            `uvm_fatal("DRV", "adder_if not found in uvm_config_db");
    endfunction


    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(adder_item);
            @(posedge a_if.clk);
            a_if.a = adder_item.a;
            a_if.b = adder_item.b;

            `uvm_info("DRV", $sformatf(
                      "Drive DUT a: %0d, b: %0d", a_if.a, a_if.b), UVM_LOW);
            //adder_item.print(uvm_default_line_printer);
            #1; //driver에서 dut로 입력하고 다시 dut에서 출력이 나올때까지 살짝 대기 한다. (nonitor에서 처리할 시간을 주는 것)
            seq_item_port.item_done();
            //#10;
        end
    endtask
endclass

class adder_monitor extends uvm_monitor;
    `uvm_component_utils(adder_monitor)  //factory 등록

    uvm_analysis_port #(adder_seq_item) send;

    function new(string name = "MON", uvm_component parent);
        super.new(name, parent);
        send = new("WRITE", this);
    endfunction

    adder_seq_item   adder_item;

    virtual adder_if a_if;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_item = adder_seq_item::type_id::create("ADDER_ITEM");
        if (!uvm_config_db#(virtual adder_if)::get(this, "", "a_if", a_if))
            `uvm_fatal("MON", "adder_if not found in uvm_config_db");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge a_if.clk);
            #1; //dut에서 입력이 들어가고 처리될 시간을 살짝 준 후, output을 가져온다.
            //1ns 동안 dut에서 처리가 되었다고 생각하는 것
            adder_item.a = a_if.a;
            adder_item.b = a_if.b;
            adder_item.y = a_if.y;

            `uvm_info("MON", $sformatf(
                      "sampled a: %0d, b: %0d, y: %0d",
                      adder_item.a,
                      adder_item.b,
                      adder_item.y
                      ), UVM_LOW)
            //adder_item.print(uvm_default_line_printer);

            send.write(adder_item);  //scoreboard로 전송
        end
    endtask
endclass

class adder_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(adder_scoreboard)

    uvm_analysis_imp #(adder_seq_item, adder_scoreboard) recv;  //

    adder_seq_item adder_item; //"adder_seq_item"은 class 이름, "adder_item"은 handler


    function new(string name = "SCO", uvm_component parent);
        super.new(name, parent);
        recv = new("READ", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_item = adder_seq_item::type_id::create("ADDER_ITEM");
    endfunction

    virtual function void write(
        adder_seq_item item
    );  //monitor -> scb로 transaction을 보낼 때 사용하는 함수
        adder_item = item;
        `uvm_info("SCO", $sformatf(
                  "Received a: %0d, b:%0d, y:%0d", item.a, item.b, item.y),
                  UVM_LOW)
        //adder_item.print(uvm_default_line_printer);

        if (adder_item.y == adder_item.a + adder_item.b)
            `uvm_info("SCO", "*** TEST PASSED ***", UVM_NONE)
        else `uvm_error("SCO", "*** TEST FAILED ***");
    endfunction

endclass


class adder_agent extends uvm_agent;
    `uvm_component_utils(adder_agent)

    function new(string name = "AGENT", uvm_component parent);
        super.new(name, parent);
    endfunction

    adder_monitor adder_mon;
    adder_driver adder_drv;
    uvm_sequencer #(adder_seq_item) adder_sqr; //uvm framework에서 제공하는 class 사용

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_mon = adder_monitor::type_id::create("MON", this);
        adder_drv = adder_driver::type_id::create("DRV", this);
        adder_sqr =
            uvm_sequencer#(adder_seq_item)::type_id::create("SQR", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        adder_drv.seq_item_port.connect(
            adder_sqr.seq_item_export);  //port와 export 연결
    endfunction
endclass


class adder_envirnment extends uvm_env;
    `uvm_component_utils(adder_envirnment)

    function new(string name = "ENV", uvm_component parent);
        super.new(name, parent);
    endfunction

    adder_scoreboard adder_sco;
    adder_agent adder_agt;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_sco = adder_scoreboard::type_id::create("SCO", this);
        adder_agt = adder_agent::type_id::create("AGT", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(
            phase);  //agent안 monitor <-> scoreboard간 연결통로 만듬
        adder_agt.adder_mon.send.connect(adder_sco.recv);  //TLM port 연결
    endfunction
endclass


class test extends uvm_test;
    `uvm_component_utils(test)  //factory에 등록 매크로

    function new(string name = "TEST", uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    adder_sequence   adder_seq;
    adder_envirnment adder_env;
  
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        adder_seq = adder_sequence::type_id::create("SEQ", this);
        //"factory excute: factory에서 실행했다"(adder_seq = new(); 한거랑 비슷)
        adder_env = adder_envirnment::type_id::create("ENV", this);
    endfunction
  
    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        uvm_root::get().print_topology();
    endfunction  
  

    virtual task run_phase(uvm_phase phase);  //overiding
        //test class 안에 있는 모든 것들을 실행시키는 task
        phase.raise_objection(this);
        adder_seq.start(
            adder_env.adder_agt.adder_sqr); //sequence와 sequencer는 다르다
        phase.drop_objection(this);  //objection 해제, run_phase 종료
    endtask

endclass  //test extends superClass;



module tb_adder ();
    //test adder_test;  //handler
    adder_if a_if ();

    always #5 a_if.clk = ~a_if.clk;

    initial begin
        $fsdbDumpvars(0);
        $fsdbDumpfile("wave.fsdb");
        a_if.clk   = 0;
        //adder_test = new("TEST", null);
        uvm_config_db#(virtual adder_if)::set(null, "*", "a_if", a_if);
        //uvm_config_db library : database에 interface 정보를 저장할 수 있다.
        run_test();  //test 안에 있는 program들이 실행 된다.
    end

    adder dut (
        .a(a_if.a),
        .b(a_if.b),
        .y(a_if.y)
    );

endmodule

