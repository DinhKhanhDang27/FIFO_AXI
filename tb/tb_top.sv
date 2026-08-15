`timescale 1ns/1ps

module tb_top;
  import uvm_pkg::*;
  import fifo_pkg::*;

  bit clk;
  bit resetn;

  fifo_if axi_if(clk, resetn);

  wire interrupt;
  wire mm2s_prmry_reset_out_n;
  wire axi_str_txd_tvalid;
  wire axi_str_txd_tlast;
  wire [31:0] axi_str_txd_tdata;
  wire mm2s_cntrl_reset_out_n;
  wire axi_str_txc_tvalid;
  wire axi_str_txc_tlast;
  wire [31:0] axi_str_txc_tdata;
  wire s2mm_prmry_reset_out_n;
  wire axi_str_rxd_tready;

  initial forever #5 clk = ~clk;

  initial begin
    resetn = 0;
    repeat (10) @(posedge clk);
    resetn = 1;
  end

  axi_fifo_mm_s_0 DUT (
    .interrupt(interrupt),
    .s_axi_aclk(clk),
    .s_axi_aresetn(resetn),
    .s_axi_awaddr(axi_if.awaddr),
    .s_axi_awvalid(axi_if.awvalid),
    .s_axi_awready(axi_if.awready),
    .s_axi_wdata(axi_if.wdata),
    .s_axi_wstrb(axi_if.wstrb),
    .s_axi_wvalid(axi_if.wvalid),
    .s_axi_wready(axi_if.wready),
    .s_axi_bresp(axi_if.bresp),
    .s_axi_bvalid(axi_if.bvalid),
    .s_axi_bready(axi_if.bready),
    .s_axi_araddr(axi_if.araddr),
    .s_axi_arvalid(axi_if.arvalid),
    .s_axi_arready(axi_if.arready),
    .s_axi_rdata(axi_if.rdata),
    .s_axi_rresp(axi_if.rresp),
    .s_axi_rvalid(axi_if.rvalid),
    .s_axi_rready(axi_if.rready),
    .mm2s_prmry_reset_out_n(mm2s_prmry_reset_out_n),
    .axi_str_txd_tvalid(axi_str_txd_tvalid),
    .axi_str_txd_tready(1'b1),
    .axi_str_txd_tlast(axi_str_txd_tlast),
    .axi_str_txd_tdata(axi_str_txd_tdata),
    .mm2s_cntrl_reset_out_n(mm2s_cntrl_reset_out_n),
    .axi_str_txc_tvalid(axi_str_txc_tvalid),
    .axi_str_txc_tready(1'b1),
    .axi_str_txc_tlast(axi_str_txc_tlast),
    .axi_str_txc_tdata(axi_str_txc_tdata),
    .s2mm_prmry_reset_out_n(s2mm_prmry_reset_out_n),
    .axi_str_rxd_tvalid(1'b0),
    .axi_str_rxd_tready(axi_str_rxd_tready),
    .axi_str_rxd_tlast(1'b0),
    .axi_str_rxd_tdata(32'h0)
  );

  initial begin
    uvm_config_db#(virtual fifo_if)::set(null, "uvm_test_top.env.agent.driver", "vif", axi_if);
    uvm_config_db#(virtual fifo_if)::set(null, "uvm_test_top.env.agent.monitor", "vif", axi_if);
    if ($test$plusargs("UVM_TESTNAME"))
      run_test();
    else
      run_test("fifo_all_tests");
  end
endmodule
