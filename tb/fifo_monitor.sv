class fifo_monitor extends uvm_component;
  virtual fifo_if vif;
  uvm_analysis_port #(fifo_item) ap;

  `uvm_component_utils(fifo_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "fifo_if not set")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.bvalid && vif.mon_cb.bready) sample_write();
      if (vif.mon_cb.rvalid && vif.mon_cb.rready) sample_read();
    end
  endtask

  task sample_write();
    fifo_item tr = fifo_item::type_id::create("wr_mon");
    tr.kind = fifo_item::WRITE;
    tr.addr = vif.mon_cb.awaddr;
    tr.data = vif.mon_cb.wdata;
    tr.resp = vif.mon_cb.bresp;
    ap.write(tr);
  endtask

  task sample_read();
    fifo_item tr = fifo_item::type_id::create("rd_mon");
    tr.kind = fifo_item::READ;
    tr.addr = vif.mon_cb.araddr;
    tr.rdata = vif.mon_cb.rdata;
    tr.resp = vif.mon_cb.rresp;
    ap.write(tr);
  endtask
endclass
