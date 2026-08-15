class fifo_base_test extends uvm_test;
  fifo_env env;

  `uvm_component_utils(fifo_base_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fifo_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #200ns;
    phase.drop_objection(this);
  endtask
endclass

class axi_slv_reg_read_test extends fifo_base_test;
  `uvm_component_utils(axi_slv_reg_read_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_slv_reg_read_seq seq = axi_slv_reg_read_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sequencer);
    #100ns;
    phase.drop_objection(this);
  endtask
endclass

class axi_slv_reg_write_test extends fifo_base_test;
  `uvm_component_utils(axi_slv_reg_write_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_slv_reg_write_seq seq = axi_slv_reg_write_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sequencer);
    #100ns;
    phase.drop_objection(this);
  endtask
endclass

class axi_slv_reg_inv_test extends fifo_base_test;
  `uvm_component_utils(axi_slv_reg_inv_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_slv_reg_inv_seq seq = axi_slv_reg_inv_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sequencer);
    #100ns;
    phase.drop_objection(this);
  endtask
endclass

class fifo_all_tests extends fifo_base_test;
  `uvm_component_utils(fifo_all_tests)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_slv_reg_read_seq  read_seq  = axi_slv_reg_read_seq::type_id::create("read_seq");
    axi_slv_reg_write_seq write_seq = axi_slv_reg_write_seq::type_id::create("write_seq");
    axi_slv_reg_inv_seq   inv_seq   = axi_slv_reg_inv_seq::type_id::create("inv_seq");

    phase.raise_objection(this);

    `uvm_info("ALL_TESTS", "Starting AXI slave register read test", UVM_LOW)
    read_seq.start(env.agent.sequencer);

    `uvm_info("ALL_TESTS", "Starting AXI slave register write test", UVM_LOW)
    write_seq.start(env.agent.sequencer);

    `uvm_info("ALL_TESTS", "Starting AXI slave invalid address test", UVM_LOW)
    inv_seq.start(env.agent.sequencer);

    #100ns;
    phase.drop_objection(this);
  endtask
endclass
