`timescale 1ns / 1ps

// トップモジュール
module tb;

    reg  reset;
    reg  clk;
    
    always begin
        #5 clk = 'b0;
        #5 clk = 'b1;
    end    
    
    initial begin
        clk = 1'b1;
        c_tb();
        $finish;
    end

    wire         S_AXI_ACLK    = clk;
    wire         S_AXI_ARESETN = ~reset;

    ////////////////////////////////////////////////////////////////////////////
    // AXI Lite Slave Interface
    reg  [31:0]  S_AXI_AWADDR;
    reg          S_AXI_AWVALID;
    reg          S_AXI_AWREADY;
    reg  [31:0]  S_AXI_WDATA;
    reg  [3:0]   S_AXI_WSTRB;
    reg          S_AXI_WVALID;
    reg          S_AXI_WREADY;
    reg  [1:0]   S_AXI_BRESP;
    reg          S_AXI_BVALID;
    reg          S_AXI_BREADY;

    reg  [31:0]  S_AXI_ARADDR;
    reg          S_AXI_ARVALID;
    reg          S_AXI_ARREADY;
    reg [31:0]   S_AXI_RDATA;
    reg  [1:0]   S_AXI_RRESP;
    reg          S_AXI_RVALID;
    reg          S_AXI_RREADY;


    wire         AXIS_ACLK    = clk;
    wire         AXIS_ARESETN = ~reset;

    ////////////////////////////////////////////////////////////////////////////
    // AXI Stream Master Interface
    reg          M_AXIS_TVALID;
    reg  [31:0]  M_AXIS_TDATA;
    reg  [3:0]   M_AXIS_TSTRB;
    reg          M_AXIS_TLAST;
    reg          M_AXIS_TREADY;

    ////////////////////////////////////////////////////////////////////////////
    // AXI Stream Slave Interface
    reg          S_AXIS_TREADY;
    reg  [31:0]  S_AXIS_TDATA;
    reg  [3:0]   S_AXIS_TSTRB;
    reg          S_AXIS_TLAST;
    reg          S_AXIS_TVALID;

    task v_init();
        reset = 1'b1;
        S_AXI_BREADY = 'b1;
        S_AXI_WSTRB = 'hf;
        S_AXI_RREADY = 'b1;
        S_AXIS_TSTRB = 'hf;
        S_AXIS_TLAST = 'b0;
        M_AXIS_TREADY = 'b1;
        S_AXI_ARVALID = 'b0;
        S_AXI_AWVALID = 'b0;
        S_AXI_WVALID = 'b0;
        S_AXIS_TVALID = 'b0;
        repeat(10) @(posedge clk);
        reset = 1'b0;
    endtask

    task v_finish();
        repeat(10) @(posedge clk);
        //$finish;
    endtask

    task v_write(input int address, input int data);
        S_AXI_AWADDR = address;
        S_AXI_WDATA = data;
        S_AXI_AWVALID = 'b1;
        S_AXI_WVALID = 'b1;
        repeat(1) @(posedge clk);
        S_AXI_AWVALID = 'b0;
        S_AXI_WVALID = 'b0;
        repeat(1) @(posedge clk);
    endtask
  
    task v_send(input int data[64], input int size);
        S_AXIS_TVALID = 'b1;
        for(int i=0; i<size; i+=1)begin
            S_AXIS_TDATA = data[i];
            repeat(1) @(posedge clk);
        end
        S_AXIS_TVALID = 'b0;
        repeat(1) @(posedge clk);
    endtask

    task v_receive(output int data[64], input int size);
        while(M_AXIS_TVALID== 'b0)
            repeat(1) @(posedge clk);
        for(int i=0; i<size; i+=1)begin
            data[i] = M_AXIS_TDATA;
            repeat(1) @(posedge clk);
        end
        repeat(1) @(posedge clk);
    endtask


    export "DPI-C" task v_init;
    export "DPI-C" task v_finish;
    export "DPI-C" task v_write;
    export "DPI-C" task v_send;
    export "DPI-C" task v_receive;

    import "DPI-C" context task c_tb();

    top top
    (
        .S_AXI_ACLK     ( S_AXI_ACLK    ),
        .S_AXI_ARESETN  ( S_AXI_ARESETN ),

        ////////////////////////////////////////////////////////////////////////////
        // AXI Lite Slave Interface
        .S_AXI_AWADDR   ( S_AXI_AWADDR  ),
        .S_AXI_AWVALID  ( S_AXI_AWVALID ),
        .S_AXI_AWREADY  ( S_AXI_AWREADY ),
        .S_AXI_WDATA    ( S_AXI_WDATA   ),
        .S_AXI_WSTRB    ( S_AXI_WSTRB   ),
        .S_AXI_WVALID   ( S_AXI_WVALID  ),
        .S_AXI_WREADY   ( S_AXI_WREADY  ),
        .S_AXI_BRESP    ( S_AXI_BRESP   ),
        .S_AXI_BVALID   ( S_AXI_BVALID  ),
        .S_AXI_BREADY   ( S_AXI_BREADY  ),

        .S_AXI_ARADDR   ( S_AXI_ARADDR  ),
        .S_AXI_ARVALID  ( S_AXI_ARVALID ),
        .S_AXI_ARREADY  ( S_AXI_ARREADY ),
        .S_AXI_RDATA    ( S_AXI_RDATA   ),
        .S_AXI_RRESP    ( S_AXI_RRESP   ),
        .S_AXI_RVALID   ( S_AXI_RVALID  ),
        .S_AXI_RREADY   ( S_AXI_RREADY  ),


        .AXIS_ACLK      ( AXIS_ACLK     ),
        .AXIS_ARESETN   ( AXIS_ARESETN  ),

        ////////////////////////////////////////////////////////////////////////////
        // AXI Stream Master Interface
        .M_AXIS_TVALID  ( M_AXIS_TVALID ),
        .M_AXIS_TDATA   ( M_AXIS_TDATA  ),
        .M_AXIS_TSTRB   ( M_AXIS_TSTRB  ),
        .M_AXIS_TLAST   ( M_AXIS_TLAST  ),
        .M_AXIS_TREADY  ( M_AXIS_TREADY ),

        ////////////////////////////////////////////////////////////////////////////
        // AXI Stream Slave Interface
        .S_AXIS_TREADY  ( S_AXIS_TREADY ),
        .S_AXIS_TDATA   ( S_AXIS_TDATA  ),
        .S_AXIS_TSTRB   ( S_AXIS_TSTRB  ),
        .S_AXIS_TLAST   ( S_AXIS_TLAST  ),
        .S_AXIS_TVALID  ( S_AXIS_TVALID )
    );

endmodule
