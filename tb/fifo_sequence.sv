class fifo_base_seq extends uvm_sequence #(fifo_item);
  `uvm_object_utils(fifo_base_seq)

  function new(string name = "fifo_base_seq");
    super.new(name);
  endfunction

  task axi_write(bit [31:0] addr, bit [31:0] data);
    fifo_item tr = fifo_item::type_id::create("wr");
    start_item(tr);
    tr.kind = fifo_item::WRITE;
    tr.addr = addr;
    tr.data = data;
    finish_item(tr);
  endtask

  task axi_read(bit [31:0] addr);
    fifo_item tr = fifo_item::type_id::create("rd");
    start_item(tr);
    tr.kind = fifo_item::READ;
    tr.addr = addr;
    finish_item(tr);
  endtask
endclass

class axi_slv_reg_read_seq extends fifo_base_seq;
  `uvm_object_utils(axi_slv_reg_read_seq)

  function new(string name = "axi_slv_reg_read_seq");
    super.new(name);
  endfunction

  task body();
    axi_read(fifo_reg_model::ISR);
    axi_read(fifo_reg_model::IER);
    axi_read(fifo_reg_model::TDFV);
    axi_read(fifo_reg_model::RDFO);
    axi_read(fifo_reg_model::RLR);
  endtask
endclass

class axi_slv_reg_write_seq extends fifo_base_seq;
  `uvm_object_utils(axi_slv_reg_write_seq)

  function new(string name = "axi_slv_reg_write_seq");
    super.new(name);
  endfunction

  task body();
    axi_write(fifo_reg_model::IER, 32'h0800_0000);
    axi_read(fifo_reg_model::IER);
    axi_write(fifo_reg_model::TX_ECC_CFG, 32'h0000_0001);
    axi_read(fifo_reg_model::TX_ECC_CFG);
    axi_write(fifo_reg_model::RX_ECC_CFG, 32'h0000_0001);
    axi_read(fifo_reg_model::RX_ECC_CFG);
  endtask
endclass

class axi_slv_reg_inv_seq extends fifo_base_seq;
  `uvm_object_utils(axi_slv_reg_inv_seq)

  function new(string name = "axi_slv_reg_inv_seq");
    super.new(name);
  endfunction

  task body();
    axi_read(32'h0000_0ffc);
    axi_write(32'h0000_0ffc, 32'hdead_beef);
  endtask
endclass
