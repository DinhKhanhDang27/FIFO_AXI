class fifo_env extends uvm_env;
  fifo_agent      agent;
  fifo_scoreboard scoreboard;
  fifo_ref_model  ref_model;
  fifo_coverage   coverage;
  fifo_reg_model  reg_model;
  fifo_vseqr      vseqr;

  `uvm_component_utils(fifo_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reg_model = fifo_reg_model::type_id::create("reg_model");
    uvm_config_db#(fifo_reg_model)::set(this, "ref_model", "reg_model", reg_model);
    agent = fifo_agent::type_id::create("agent", this);
    scoreboard = fifo_scoreboard::type_id::create("scoreboard", this);
    ref_model = fifo_ref_model::type_id::create("ref_model", this);
    coverage = fifo_coverage::type_id::create("coverage", this);
    vseqr = fifo_vseqr::type_id::create("vseqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    agent.monitor.ap.connect(ref_model.in);
    agent.monitor.ap.connect(scoreboard.act_in);
    agent.monitor.ap.connect(coverage.analysis_export);
    ref_model.exp_ap.connect(scoreboard.exp_in);
    vseqr.axi_sqr = agent.sequencer;
  endfunction
endclass
