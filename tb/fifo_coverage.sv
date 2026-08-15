class fifo_coverage extends uvm_subscriber #(fifo_item);
  bit is_write;
  bit [31:0] addr;
  bit [1:0] resp;

  covergroup cg;
    option.per_instance = 1;
    cp_kind: coverpoint is_write;
    cp_addr: coverpoint addr {
      bins readable[] = {32'h00, 32'h04, 32'h0c, 32'h1c, 32'h20, 32'h24, 32'h30};
      bins writable[] = {32'h00, 32'h04, 32'h08, 32'h10, 32'h14, 32'h18, 32'h28, 32'h2c};
      bins invalid = default;
    }
    cp_resp: coverpoint resp { bins okay = {0}; bins err = {2}; }
    rw_resp: cross cp_kind, cp_resp;
  endgroup

  `uvm_component_utils(fifo_coverage)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg = new();
  endfunction

  function void write(fifo_item t);
    is_write = (t.kind == fifo_item::WRITE);
    addr = t.addr;
    resp = t.resp;
    cg.sample();
  endfunction
endclass
