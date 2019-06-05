`timescale 1ns/1ns
module sim_top();

   reg clk, reset;

   reg rreq,  wreq, awreq;
   reg srreq, swreq, srrdy;
   reg [31:0] addr;
   reg [31:0] wdata;
   reg [31:0] swdata;
   

   initial begin
      #0;
      reset = 1'b1;
      rreq = 1'b0;
      wreq = 1'b0;
      awreq = 1'b0;
      addr = 32'h0;
      srreq = 1'b0;
      swreq = 1'b0;
      srrdy = 1'b1;
      #5;
      #10;
      reset = 1'b0;
      #10;
      wreq = 1'b1;
      awreq = 1'b1;
      addr = 0;
      wdata = 1;
      #10;
      wreq = 1'b0;
      awreq = 1'b0;
      #10;
      wreq = 1'b1;
      awreq = 1'b1;
      addr = 4;
      wdata = 4;
      #10;
      wreq = 1'b0;
      awreq = 1'b0;



      #30;
      swreq = 1'b1;
      swdata = 32'hffff0000;
      #10;
      swdata = 32'hfffe0001;
      #10;
      swreq = 1'b0;
      #10;
      swreq = 1'b1;
      swdata = 32'hfffd0002;
      #10;
      swdata = 32'hfffc0003;
      #30;
      swreq = 1'b0;
      
      
      #10;
      wreq = 1'b1;
      awreq = 1'b1;
      addr = 0;
      wdata = 0;
      #10;
      wreq = 1'b0;
      awreq = 1'b0;
      #10;
      wreq = 1'b1;
      awreq = 1'b1;
      addr = 0;
      wdata = 2;
      #10;
      wreq = 1'b0;
      awreq = 1'b0;

      #30;
      srrdy = 1'b0;
      #10;
      srrdy = 1'b1;
      
      #100 $finish;
   end

   always begin
      clk=1;#5;
      clk=0;#5;
   end

   wire         S_AXI_ACLK = clk;
   wire         S_AXI_ARESETN = ~reset;
   wire         AXIS_ACLK = clk;
   wire         AXIS_ARESETN = ~reset;
   ////////////////////////////////////////////////////////////////////////////
   // AXI Lite Slave Interface

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


   ////////////////////////////////////////////////////////////////////////////
   // AXI Stream Master Interface
   wire         M_AXIS_TVALID;
   wire [31:0]  M_AXIS_TDATA;
   wire [3:0]   M_AXIS_TSTRB;
   wire         M_AXIS_TLAST;
   wire         M_AXIS_TREADY = srrdy;

   ////////////////////////////////////////////////////////////////////////////
   // AXI Stream Slave Interface
   wire         S_AXIS_TREADY;
   wire [31:0]  S_AXIS_TDATA = swdata;
   wire [3:0]   S_AXIS_TSTRB = 4'hf;
   wire         S_AXIS_TLAST = 1'b0;
   wire         S_AXIS_TVALID = swreq;

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
      .S_AXI_RREADY(S_AXI_RREADY),

   
      .AXIS_ACLK(AXIS_ACLK),
      .AXIS_ARESETN(AXIS_ARESETN),

      .M_AXIS_TVALID(M_AXIS_TVALID),
      .M_AXIS_TDATA(M_AXIS_TDATA),
      .M_AXIS_TSTRB(M_AXIS_TSTRB),
      .M_AXIS_TLAST(M_AXIS_TLAST),
      .M_AXIS_TREADY(M_AXIS_TREADY),

      .S_AXIS_TREADY(S_AXIS_TREADY),
      .S_AXIS_TDATA(S_AXIS_TDATA),
      .S_AXIS_TSTRB(S_AXIS_TSTRB),
      .S_AXIS_TLAST(S_AXIS_TLAST),
      .S_AXIS_TVALID(S_AXIS_TVALID)
      );

endmodule
