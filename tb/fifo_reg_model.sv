class fifo_reg_model extends uvm_object;
  static const bit [31:0] ISR  = 32'h00;
  static const bit [31:0] IER  = 32'h04;
  static const bit [31:0] TDFR = 32'h08;
  static const bit [31:0] TDFV = 32'h0c;
  static const bit [31:0] TDFD = 32'h10;
  static const bit [31:0] TLR  = 32'h14;
  static const bit [31:0] RDFR = 32'h18;
  static const bit [31:0] RDFO = 32'h1c;
  static const bit [31:0] RDFD = 32'h20;
  static const bit [31:0] RLR  = 32'h24;
  static const bit [31:0] SRR  = 32'h28;
  static const bit [31:0] TDR  = 32'h2c;
  static const bit [31:0] RDR  = 32'h30;
  static const bit [31:0] TX_ECC_CFG = 32'h44;
  static const bit [31:0] TX_ECC_CNT = 32'h48;
  static const bit [31:0] RX_ECC_CFG = 32'h4c;
  static const bit [31:0] RX_ECC_CNT = 32'h50;

  `uvm_object_utils(fifo_reg_model)

  function new(string name = "fifo_reg_model");
    super.new(name);
  endfunction

  function bit is_valid(bit [31:0] addr);
    return addr inside {ISR, IER, TDFR, TDFV, TDFD, TLR, RDFR, RDFO, RDFD,
                        RLR, SRR, TDR, RDR, TX_ECC_CFG, TX_ECC_CNT,
                        RX_ECC_CFG, RX_ECC_CNT};
  endfunction

  function bit is_readable(bit [31:0] addr);
    return addr inside {ISR, IER, TDFV, RDFO, RDFD, RLR, RDR,
                        TX_ECC_CFG, TX_ECC_CNT, RX_ECC_CFG, RX_ECC_CNT};
  endfunction

  function bit is_writable(bit [31:0] addr);
    return addr inside {ISR, IER, TDFR, TDFD, TLR, RDFR, SRR, TDR,
                        TX_ECC_CFG, RX_ECC_CFG};
  endfunction

  function bit [31:0] reset_value(bit [31:0] addr);
    if (addr == ISR) return 32'h0180_0000;
    return 32'h0;
  endfunction
endclass
