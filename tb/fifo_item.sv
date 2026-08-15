class fifo_item extends uvm_sequence_item;
  typedef enum bit {READ, WRITE} kind_e;
  rand kind_e       kind;
  rand bit [31:0]   addr;
  rand bit [31:0]   data;
  bit [31:0]        rdata;
  bit [1:0]         resp;
  bit               check_data;

  `uvm_object_utils_begin(fifo_item)
    `uvm_field_enum(kind_e, kind, UVM_DEFAULT)
    `uvm_field_int(addr,  UVM_HEX)
    `uvm_field_int(data,  UVM_HEX)
    `uvm_field_int(rdata, UVM_HEX)
    `uvm_field_int(resp,  UVM_HEX)
    `uvm_field_int(check_data, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "fifo_item");
    super.new(name);
  endfunction
endclass
