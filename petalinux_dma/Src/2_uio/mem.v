/**********************************************************************\
*      addrress range   access size                                    *
* reg  0x010            32bit                                          *
* mem1 0x400-0x7fc      32bit                                          *
\**********************************************************************/
module mem
  (
   input wire        S_AXI_ACLK,
   input wire        S_AXI_ARESETN,

   ////////////////////////////////////////////////////////////////////////////
   // AXI Lite Slave Interface
   input wire [31:0] S_AXI_AWADDR,
   input wire        S_AXI_AWVALID,
   output wire       S_AXI_AWREADY,
   input wire [31:0] S_AXI_WDATA,
   input wire [3:0]  S_AXI_WSTRB,
   input wire        S_AXI_WVALID,
   output wire       S_AXI_WREADY,
   output wire [1:0] S_AXI_BRESP,
   output wire       S_AXI_BVALID,
   input wire        S_AXI_BREADY,

   input wire [31:0] S_AXI_ARADDR,
   input wire        S_AXI_ARVALID,
   output wire       S_AXI_ARREADY,
   output reg [31:0] S_AXI_RDATA,
   output wire [1:0] S_AXI_RRESP,
   output wire       S_AXI_RVALID,
   input wire        S_AXI_RREADY
   );

   reg [3:0]         axist;
   reg [11:2]        wb_adr_i;
   reg [11:2]        rd_adr_i;
   reg [31:0]        wb_dat_i;

   assign S_AXI_BRESP = 2'b00;
   assign S_AXI_RRESP = 2'b00;
   assign S_AXI_AWREADY = (axist == 4'b0000)|(axist == 4'b0010);
   assign S_AXI_WREADY  = (axist == 4'b0000)|(axist == 4'b0001);
   assign S_AXI_ARREADY = (axist == 4'b0000);
   assign S_AXI_BVALID  = (axist == 4'b0011);
   assign S_AXI_RVALID  = (axist == 4'b1000);

   always @(posedge S_AXI_ACLK)begin
      if(~S_AXI_ARESETN)begin
         axist<=4'b0000;

         wb_adr_i<=0;
         wb_dat_i<=0;
      end else if(axist==4'b000)begin
         if(S_AXI_AWVALID & S_AXI_WVALID)begin
            axist<=4'b0011;
            wb_adr_i[11:2]<=S_AXI_AWADDR[11:2];
            wb_dat_i<=S_AXI_WDATA;
         end else if(S_AXI_AWVALID)begin
            axist<=4'b0001;
            wb_adr_i[11:2]<=S_AXI_AWADDR[11:2];
         end else if(S_AXI_WVALID)begin
            axist<=4'b0010;
            wb_dat_i<=S_AXI_WDATA;
         end else if(S_AXI_ARVALID)begin
            axist<=4'b0100;
            rd_adr_i[11:2]<=S_AXI_ARADDR[11:2];
         end
      end else if(axist==4'b0001)begin
         if(S_AXI_WVALID)begin
            axist<=4'b0011;
            wb_dat_i<=S_AXI_WDATA;
         end
      end else if(axist==4'b0010)begin
         if(S_AXI_AWVALID)begin
            axist<=4'b0011;
            wb_adr_i[11:2]<=S_AXI_AWADDR[11:2];
         end
      end else if(axist==4'b0011)begin
         if(S_AXI_BREADY)
           axist<=4'b0000;
      end else if(axist==4'b0100)begin
         axist<=4'b1000;
      end else if(axist==4'b1000)begin
         if(S_AXI_RREADY)
           axist<=4'b0000;
      end
   end

   reg [31:0] control;
   wire        regwrite = (axist==4'b0011) & (wb_adr_i[11:10]==2'b00);
   wire        regread  = (axist==4'b0100) & (rd_adr_i[11:10]==2'b00);

   wire [11:2] wb_adr_p = (S_AXI_AWVALID&S_AXI_AWREADY) ? S_AXI_AWADDR[11:2]: wb_adr_i[11:2];
   wire        m1write0 = ((axist[1] | (S_AXI_WVALID &S_AXI_WREADY)) &
                           (axist[0] | (S_AXI_AWVALID&S_AXI_AWREADY))&
                           (axist!=4'b0011))           & (wb_adr_p[11:10]==2'b01);
   wire        m1write1 = (axist==4'b0011)             & (wb_adr_i[11:10]==2'b01);
   wire        m1read0  = S_AXI_ARVALID &S_AXI_ARREADY & (S_AXI_ARADDR[11:10]==2'b01);
   wire        m1read1  = (axist==4'b0100)             & (rd_adr_i[11:10]==2'b01);

   wire [31:0] wb_dat_p = (S_AXI_WVALID &S_AXI_WREADY) ? S_AXI_WDATA: wb_dat_i;
   
   reg [31:0]  mem1 [0:255];
   reg [31:0]  mrd1;

   always @(posedge S_AXI_ACLK)begin
     if(m1write0)
       mem1[wb_adr_p[9:2]] <= wb_dat_p;
     else if(m1read0)
       mrd1 <= mem1[S_AXI_ARADDR[9:2]];
   end

   always @(posedge S_AXI_ACLK)begin
      if(~S_AXI_ARESETN)begin
         control <= 32'h0;
      end else if(regwrite)begin
         case(wb_adr_i[9:2])
           8'h04: control <= wb_dat_i;
         endcase
      end
   end

   always @(posedge S_AXI_ACLK)begin
      if(regread)begin
         case(rd_adr_i[9:2])
           8'h04: S_AXI_RDATA <= control;
         endcase
      end else if(m1read1)begin
         S_AXI_RDATA <= mrd1;
      end
   end
endmodule
