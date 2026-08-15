class fifo_driver extends uvm_driver #(fifo_item);
  virtual fifo_if vif;

  `uvm_component_utils(fifo_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "fifo_if not set")
  endfunction

  task run_phase(uvm_phase phase);
    fifo_item tr;
    idle();
    forever begin
      seq_item_port.get_next_item(tr);
      if (tr.kind == fifo_item::WRITE) drive_write(tr);
      else drive_read(tr);
      seq_item_port.item_done();
    end
  endtask

  task idle();
    vif.drv_cb.awaddr <= '0;
    vif.drv_cb.awvalid <= 0;
    vif.drv_cb.wdata <= '0;
    vif.drv_cb.wstrb <= '0;
    vif.drv_cb.wvalid <= 0;
    vif.drv_cb.bready <= 0;
    vif.drv_cb.araddr <= '0;
    vif.drv_cb.arvalid <= 0;
    vif.drv_cb.rready <= 0;
  endtask

  task drive_write(fifo_item tr);
    bit aw_done;
    bit w_done;
    wait (vif.resetn);
    @(vif.drv_cb);
    vif.drv_cb.awaddr <= tr.addr;
    vif.drv_cb.awvalid <= 1;
    vif.drv_cb.wdata <= tr.data;
    vif.drv_cb.wstrb <= 4'hf;
    vif.drv_cb.wvalid <= 1;
    vif.drv_cb.bready <= 1;
    do begin
      @(vif.drv_cb);
      if (vif.drv_cb.awready) aw_done = 1;
      if (vif.drv_cb.wready) w_done = 1;
      if (aw_done) vif.drv_cb.awvalid <= 0;
      if (w_done) vif.drv_cb.wvalid <= 0;
    end while (!aw_done || !w_done);
    wait (vif.drv_cb.bvalid);
    tr.resp = vif.drv_cb.bresp;
    @(vif.drv_cb);
    vif.drv_cb.bready <= 0;
  endtask

  task drive_read(fifo_item tr);
    wait (vif.resetn);
    @(vif.drv_cb);
    vif.drv_cb.araddr <= tr.addr;
    vif.drv_cb.arvalid <= 1;
    vif.drv_cb.rready <= 1;
    wait (vif.drv_cb.arready);
    @(vif.drv_cb);
    vif.drv_cb.arvalid <= 0;
    wait (vif.drv_cb.rvalid);
    tr.rdata = vif.drv_cb.rdata;
    tr.resp = vif.drv_cb.rresp;
    @(vif.drv_cb);
    vif.drv_cb.rready <= 0;
  endtask
endclass
