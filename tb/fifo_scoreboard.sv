`uvm_analysis_imp_decl(_act)
`uvm_analysis_imp_decl(_exp)

class fifo_scoreboard extends uvm_component;
  uvm_analysis_imp_act #(fifo_item, fifo_scoreboard) act_in;
  uvm_analysis_imp_exp #(fifo_item, fifo_scoreboard) exp_in;
  fifo_item exp_q[$];

  `uvm_component_utils(fifo_scoreboard)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    act_in = new("act_in", this);
    exp_in = new("exp_in", this);
  endfunction

  function void write_exp(fifo_item tr);
    exp_q.push_back(tr);
  endfunction

  function void write_act(fifo_item act);
    fifo_item exp;
    if (exp_q.size() == 0) `uvm_error("SB", "Actual transaction without expected item")
    else begin
      exp = exp_q.pop_front();
      if (act.resp !== exp.resp)
        `uvm_error("SB", $sformatf("Resp mismatch addr=0x%08h exp=%0h act=%0h",
                                   act.addr, exp.resp, act.resp))
      if (act.kind == fifo_item::READ && exp.resp == 2'b00 && exp.check_data &&
          act.rdata !== exp.rdata)
        `uvm_error("SB", $sformatf("Read mismatch addr=0x%08h exp=0x%08h act=0x%08h",
                                   act.addr, exp.rdata, act.rdata))
    end
  endfunction
endclass
