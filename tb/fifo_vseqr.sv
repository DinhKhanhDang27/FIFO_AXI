class fifo_vseqr extends uvm_sequencer;
  fifo_sequencer axi_sqr;

  `uvm_component_utils(fifo_vseqr)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass
