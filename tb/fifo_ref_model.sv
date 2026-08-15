class fifo_ref_model extends uvm_component;
  uvm_analysis_imp #(fifo_item, fifo_ref_model) in;
  uvm_analysis_port #(fifo_item) exp_ap;
  fifo_reg_model regs;
  bit [31:0] mirror[bit [31:0]];

  `uvm_component_utils(fifo_ref_model)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in = new("in", this);
    exp_ap = new("exp_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(fifo_reg_model)::get(this, "", "reg_model", regs))
      regs = fifo_reg_model::type_id::create("regs");
    mirror[fifo_reg_model::ISR] = regs.reset_value(fifo_reg_model::ISR);
    mirror[fifo_reg_model::IER] = regs.reset_value(fifo_reg_model::IER);
    mirror[fifo_reg_model::TX_ECC_CFG] = 32'h0;
    mirror[fifo_reg_model::RX_ECC_CFG] = 32'h0;
  endfunction

  function void write(fifo_item tr);
    fifo_item exp = fifo_item::type_id::create("exp");
    exp.copy(tr);
    if (!regs.is_valid(tr.addr)) begin
      exp.resp = 2'b00;
      exp.check_data = 0;
      exp.rdata = '0;
    end else if (tr.kind == fifo_item::WRITE) begin
      exp.resp = (regs.is_writable(tr.addr) || tr.addr == fifo_reg_model::TDFV) ? 2'b00 : 2'b10;
      if (exp.resp == 2'b00 && tr.addr == fifo_reg_model::IER)
        mirror[tr.addr] = tr.data;
    end else begin
      if (tr.addr == fifo_reg_model::RLR)
        exp.resp = 2'b10;
      else
        exp.resp = (regs.is_readable(tr.addr) || tr.addr == fifo_reg_model::TDFR) ? 2'b00 : 2'b10;
      exp.check_data = mirror.exists(tr.addr);
      exp.rdata = exp.check_data ? mirror[tr.addr] : '0;
    end
    exp_ap.write(exp);
  endfunction
endclass
