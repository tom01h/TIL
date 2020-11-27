`timescale 1ns / 1ps

// トップモジュール
module tb;

    reg  clk;
    
    always begin
        #5 clk = 'b0;
        #5 clk = 'b1;
    end    
    
    initial begin
        clk = 1'b1;
        c_top();
    end

    logic [63:0] x;

    task v_init(input longint seed);
        x = seed;
    endtask

    task v_random(input int start, input int last, input int msk, output int unsigned rnd);
        logic [31:0] val;
        do begin
            x = x ^ (x << 13);
            x = x ^ (x >> 7);
            x = x ^ (x << 17);
            val = x & msk;
            repeat(1) @(posedge clk);
        end while(!((start <= val) && (val <= last)));
        rnd = val;
    endtask

    task v_finish();
        repeat(10) @(posedge clk);
        $finish;
    endtask

    export "DPI-C" task v_init;
    export "DPI-C" task v_random;
    export "DPI-C" task v_finish;

    import "DPI-C" context task c_top();

endmodule
