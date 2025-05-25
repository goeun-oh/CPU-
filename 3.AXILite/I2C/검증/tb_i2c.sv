interface i2c_if ();
    logic clk;
    logic reset;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic rx_done;
    logic tx_done;
    logic ready;
    logic start;
    logic i2c_en;
    logic stop;
    logic SCL;
    logic SDA;
endinterface


`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_seq_item extends uvm_sequence_item;
    rand bit start;
    rand bit stop;
    rand bit i2c_en;

    rand_bit [7:0] tx_data;
    
    bit [7:0] rx_data;
    bit tx_done;
    bit ready;


    function new(string name = "I2C_ITEM");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(i2c_seq_item)
        `uvm_field_int(start, UVM_DEFAULT)
        `uvm_field_int(stop, UVM_DEFAULT)
        `uvm_field_int(i2c_en, UVM_DEFAULT)
        `uvm_field_int(tx_data, UVM_DEFAULT)
        `uvm_field_int(rx_data, UVM_DEFAULT)
        `uvm_field_int(tx_done, UVM_DEFAULT)
        `uvm_field_int(ready, UVM_DEFAULT)
    `uvm_object_utils_end

endclass

class i2c_sequence extends uvm_sequence #(i2c_seq_item);
    //i2c_seq_item을 factory에 등록하는 매크로
    `uvm_object_utils(i2c_sequence)

    function new(string name = "SEQ");
        super.new(name);
    endfunction


    virtual task body();
        i2c_seq_item i2c_item;

        // === Phase 1: START ===
        i2c_item = i2c_seq_item::type_id::create("start_phase");
        start_item(i2c_item);
        i2c_item.start = 1;
        i2c_item.stop = 0;
        i2c_item.i2c_en = 1;
        finish_item(i2c_item);
        `uvm_info("SEQ", $sformatf("Phase 1: start=%0b stop=%0b", i2c_item.start, i2c_item.stop), UVM_LOW)


        // === Phase 2: Address 전송 ===
        i2c_item = i2c_seq_item::type_id::create("addr_phase");
        start_item(i2c_item);
        i2c_item.start   = 0;
        i2c_item.stop    = 0;
        i2c_item.i2c_en  = 1;
        i2c_item.tx_data = 8'haa; // 예: slave 주소 + write
        finish_item(i2c_item);
        `uvm_info("SEQ", $sformatf("Phase 2: start=%0b stop=%0b tx=%02h", i2c_item.start, i2c_item.stop, i2c_item.tx_data), UVM_LOW)

        // === Phase 3+: 데이터 전송 (랜덤) ===
        for (int i = 0; i < 5; i++) begin
            i2c_item = i2c_seq_item::type_id::create($sformatf("data_phase_%0d", i));
            start_item(i2c_item);

            void'(i2c_item.randomize() with {
                i2c_en == 1;

                // 3단계 시나리오에 맞는 조합만 허용
                ( (start == 1 && stop == 1) ||  // read
                  (start == 0 && stop == 0) ||  // write
                  (start == 0 && stop == 1)     // 종료
                );
            });

            i2c_item.tx_data = $urandom_range(0, 255);
            finish_item(i2c_item);
            `uvm_info("SEQ", $sformatf("Phase 3+ [%0d]: start=%0b stop=%0b tx=%02h", i, i2c_item.start, i2c_item.stop, i2c_item.tx_data), UVM_LOW)
        end
    endtask  //body

endclass


class i2c_driver extends uvm_driver #(i2c_seq_item);
    `uvm_component_utils(i2c_driver)

    function new(string name = "DRV", uvm_component parent);
        super.new(name, parent);
    endfunction

    adder_seq_item   i2c_item;
    virtual i2c_if i2c_if;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        i2c_item =i2c_seq_item::type_id::create("I2c ITEM");

        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "i2c_if", i2c_if))
            `uvm_fatal("DRV", "i2c_if not found in uvm_config_db");
    endfunction


    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(i2c_item);
            @(posedge i2c_if.clk);
            i2c_if.start = i2c_item.start;
            i2c_if.stop = i2c_item.stop;
            i2c_if.i2c_en = i2c_item.i2c_en;
            i2c_if.tx_data = i2c_item.tx_data;

            `uvm_info("DRV", $sformatf(
                      "Drive DUT start: %0b, stop: %0b, en: %0b, data=%02h", i2c_if.start, i2c_if.stop, i2c_if.i2c_en, i2c_if.tx_data), UVM_LOW);
            //adder_item.print(uvm_default_line_printer);
            #1; //driver에서 dut로 입력하고 다시 dut에서 출력이 나올때까지 살짝 대기 한다. (nonitor에서 처리할 시간을 주는 것)
            seq_item_port.item_done();
            //#10;
        end
    endtask
endclass

class i2c_monitor extends uvm_monitor;
    `uvm_component_utils(i2c_monitor)  //factory 등록

    uvm_analysis_port #(i2c_seq_item) send;

    function new(string name = "MON", uvm_component parent);
        super.new(name, parent);
        send = new("WRITE", this);
    endfunction


    virtual i2c_if i2c_if;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual adder_if)::get(this, "", "i2c_if", i2c_if))
            `uvm_fatal("MON", "i2c_if not found in uvm_config_db");
    endfunction

    virtual task run_phase(uvm_phase phase);
        i2c_seq_item   i2c_item;
        forever begin
            @(posedge i2c_if.clk);
            // tx_done이 올라간 시점에서 트랜잭션을 관측했다고 판단
            if (vif.i2c_en && vif.tx_done) begin
                i2c_item = i2c_seq_item::type_id::create("i2c_item");
                i2c_item.start   = i2c_if.start;
                i2c_item.stop    = i2c_if.stop;
                i2c_item.i2c_en  = i2c_if.i2c_en;
                i2c_item.tx_data = i2c_if.tx_data;
                i2c_item.rx_data = i2c_if.rx_data;
                i2c_item.tx_done = i2c_if.tx_done;
                i2c_item.ready   = i2c_if.ready;

                `uvm_info("MON", $sformatf("Observed: start=%0b stop=%0b data=%02h done=%0b",
                                            i2c_item.start, i2c_item.stop,
                                            i2c_item.tx_data, i2c_item.tx_done), UVM_LOW)

                send.write(i2c_item); // Scoreboard로 전달
            end
        end
    endtask
endclass
class i2c_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(i2c_scoreboard)

    uvm_analysis_imp #(i2c_seq_item, i2c_scoreboard) sb_port;

    // 내부 예측값 저장용 queue (나중에 sequencer → scoreboard 연결하면 사용 가능)
    i2c_seq_item expect_q[$];
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        sb_port = new("sb_port", this);
    endfunction

    // 관측된 트랜잭션 하나를 받아서 비교
    virtual function void write(i2c_seq_item observed);
        i2c_seq_item expected;

        if (expect_q.size() == 0) begin
            `uvm_warning("SCOREBOARD", "No expected item to compare.")
            return;
        end

        expected = expect_q.pop_front();

        // tx_data 비교 (기본 예제)
        if (expected.tx_data !== observed.tx_data) begin
            `uvm_error("SCOREBOARD", $sformatf(
                "Mismatch: expected tx_data=%0h, observed=%0h",
                expected.tx_data, observed.tx_data
            ))
        end else begin
            `uvm_info("SCOREBOARD", $sformatf(
                "Match: tx_data=%0h", observed.tx_data
            ), UVM_LOW)
        end
    endfunction
endclass



class i2c_agent extends uvm_agent;
    `uvm_component_utils(i2c_agent)

    i2c_driver     drv;
    i2c_monitor    mon;
    uvm_sequencer #(i2c_seq_item) seqr;

    virtual I2C_if vif;

    function new(string name = "i2c_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        drv  = i2c_driver    ::type_id::create("drv", this);
        mon  = i2c_monitor   ::type_id::create("mon", this);
        seqr = uvm_sequencer#(i2c_seq_item)::type_id::create("seqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

    virtual function void set_vif();
        if (!uvm_config_db#(virtual I2C_if)::get(this, "", "vif", vif))
            `uvm_fatal("AGENT", "Failed to get virtual interface!")

        // 하위 모듈에도 설정
        uvm_config_db#(virtual I2C_if)::set(this, "drv", "vif", vif);
        uvm_config_db#(virtual I2C_if)::set(this, "mon", "vif", vif);
    endfunction

    virtual function void build();
        super.build();
        set_vif();
    endfunction
endclass

class i2c_env extends uvm_env;
    `uvm_component_utils(i2c_env)

    i2c_agent      agent;
    i2c_scoreboard sb;

    function new(string name = "i2c_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent = i2c_agent::type_id::create("agent", this);
        sb    = i2c_scoreboard::type_id::create("sb", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.mon.send.connect(sb.sb_port);
    endfunction
endclass


class i2c_test extends uvm_test;
    `uvm_component_utils(i2c_test)

    i2c_env env;

    function new(string name = "i2c_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = i2c_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        i2c_sequence seq;
        phase.raise_objection(this);

        seq = i2c_sequence::type_id::create("seq");
        seq.start(env.agent.seqr);  // agent 내부 sequencer에 전달

        phase.drop_objection(this);
    endtask
endclass



module top_tb;

    // Clock & Reset
    logic clk;
    logic reset;

    // Interface
    i2c_if i2c_if_inst(clk);

    // DUT
    I2C_Master dut (
        .clk     (clk),
        .reset   (i2c_if_inst.reset),
        .start   (i2c_if_inst.start),
        .stop    (i2c_if_inst.stop),
        .i2c_en  (i2c_if_inst.i2c_en),
        .tx_data (i2c_if_inst.tx_data),
        .rx_data (i2c_if_inst.rx_data),
        .tx_done (i2c_if_inst.tx_done),
        .ready   (i2c_if_inst.ready),
        .SCL     (i2c_if_inst.SCL),
        .SDA     (i2c_if_inst.SDA)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset logic
    initial begin
        reset = 1;
        i2c_if_inst.reset = 1;
        #20;
        reset = 0;
        i2c_if_inst.reset = 0;
    end

    // UVM 연결
    initial begin
        // virtual interface 등록
        uvm_config_db#(virtual i2c_if)::set(null, "env.agent", "vif", i2c_if_inst);

        // UVM test 시작
        run_test("i2c_test");
    end

endmodule
