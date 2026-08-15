interface fifo_if(input logic clk, input logic resetn);
  logic [31:0] awaddr;
  logic        awvalid;
  logic        awready;
  logic [31:0] wdata;
  logic [3:0]  wstrb;
  logic        wvalid;
  logic        wready;
  logic [1:0]  bresp;
  logic        bvalid;
  logic        bready;
  logic [31:0] araddr;
  logic        arvalid;
  logic        arready;
  logic [31:0] rdata;
  logic [1:0]  rresp;
  logic        rvalid;
  logic        rready;
  logic        write_addr_hs;
  logic        write_data_hs;
  logic        write_resp_hs;
  logic        read_addr_hs;
  logic        read_data_hs;
  logic        invalid_addr_access;
  logic [31:0] dbg_addr;
  logic [31:0] dbg_wdata;
  logic [31:0] dbg_rdata;
  logic [1:0]  dbg_resp;

  assign write_addr_hs = awvalid && awready;
  assign write_data_hs = wvalid && wready;
  assign write_resp_hs = bvalid && bready;
  assign read_addr_hs = arvalid && arready;
  assign read_data_hs = rvalid && rready;
  assign invalid_addr_access = ((awvalid && awaddr == 32'h0000_0ffc) ||
                                (arvalid && araddr == 32'h0000_0ffc));
  assign dbg_addr = arvalid ? araddr : awaddr;
  assign dbg_wdata = wdata;
  assign dbg_rdata = rdata;
  assign dbg_resp = rvalid ? rresp : bresp;

  clocking drv_cb @(posedge clk);
    default input #1step output #1step;
    output awaddr, awvalid, wdata, wstrb, wvalid, bready;
    output araddr, arvalid, rready;
    input  awready, wready, bresp, bvalid;
    input  arready, rdata, rresp, rvalid;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step;
    input awaddr, awvalid, awready, wdata, wstrb, wvalid, wready;
    input bresp, bvalid, bready, araddr, arvalid, arready;
    input rdata, rresp, rvalid, rready;
  endclocking

  modport drv(clocking drv_cb, input clk, resetn);
  modport mon(clocking mon_cb, input clk, resetn);
endinterface
