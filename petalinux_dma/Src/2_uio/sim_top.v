`timescale 1ns/1ns
module sim_top();

   reg clk, reset;

   reg rreq, wreq, awreq;
   reg [31:0] addr;
   reg [31:0] wdata;

   initial begin
      #0;
      reset = 1'b1;
      rreq = 1'b0;
      wreq = 1'b0;
      awreq = 1'b0;
      addr = 32'h0;
      #5;
      #10;
      reset = 1'b0;
      #10;
      wreq = 1'b1;
      wdata = 32'habad1dea;
      #10;
      wreq = 1'b0;
      awreq = 1'b1;
      addr = 32'h10;
      #10;
      wreq = 1'b0;
      awreq = 1'b0;
      #10;
      rreq = 1'b1;
      addr = 32'h10;
      #10;
      rreq = 1'b0;
      #10;
      #10;
      wreq = 1'b1;
      wdata = 32'hdeadbeef;
      awreq = 1'b1;
      addr = 32'h400;
      #10;
      wreq = 1'b0;
      awreq = 1'b0;
      #10;
      rreq = 1'b1;
      addr = 32'h400;
      #10;
      rreq = 1'b0;
      
      #100 $finish;
   end

   always begin
      clk=1;#5;
      clk=0;#5;
   end

   ////////////////////////////////////////////////////////////////////////////
   // AXI Lite Slave Interface
   wire         S_AXI_ACLK = clk;
   wire         S_AXI_ARESETN = ~reset;

   wire [31:0]  S_AXI_AWADDR = addr;
   wire         S_AXI_AWVALID = awreq;
   wire         S_AXI_AWREADY;
   wire [31:0]  S_AXI_WDATA = wdata;
   wire [3:0]   S_AXI_WSTRB;
   wire         S_AXI_WVALID = wreq;
   wire         S_AXI_WREADY;
   wire [1:0]   S_AXI_BRESP;
   wire         S_AXI_BVALID;
   wire         S_AXI_BREADY = 1'b1;

   wire [31:0]  S_AXI_ARADDR = addr;
   wire         S_AXI_ARVALID = rreq;
   wire         S_AXI_ARREADY;
   wire [31:0]  S_AXI_RDATA;
   wire [1:0]   S_AXI_RRESP;
   wire         S_AXI_RVALID;
   wire         S_AXI_RREADY = 1'b1;

   mem mem
     (
      .S_AXI_ACLK(S_AXI_ACLK),
      .S_AXI_ARESETN(S_AXI_ARESETN),

      .S_AXI_AWADDR(S_AXI_AWADDR),
      .S_AXI_AWVALID(S_AXI_AWVALID),
      .S_AXI_AWREADY(S_AXI_AWREADY),
      .S_AXI_WDATA(S_AXI_WDATA),
      .S_AXI_WSTRB(S_AXI_WSTRB),
      .S_AXI_WVALID(S_AXI_WVALID),
      .S_AXI_WREADY(S_AXI_WREADY),
      .S_AXI_BRESP(S_AXI_BRESP),
      .S_AXI_BVALID(S_AXI_BVALID),
      .S_AXI_BREADY(S_AXI_BREADY),

      .S_AXI_ARADDR(S_AXI_ARADDR),
      .S_AXI_ARVALID(S_AXI_ARVALID),
      .S_AXI_ARREADY(S_AXI_ARREADY),
      .S_AXI_RDATA(S_AXI_RDATA),
      .S_AXI_RRESP(S_AXI_RRESP),
      .S_AXI_RVALID(S_AXI_RVALID),
      .S_AXI_RREADY(S_AXI_RREADY)
      );

endmodule
