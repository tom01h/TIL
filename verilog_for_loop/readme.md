# Verilog で多重 loop を読みやすく記述する

多重の for loop で最内ループを 1サイクルピッチで実行するための Verilog 記述を、出来るだけ読みやすくする記述を考えてみました。  
次のような SystemC のコードを 読みやすい Verilog で記述したいと思います。

```c++
    for(int c=0; c<=2; c++){
      for(int y=0; y<=2; y++){
        for(int x=0; x<=2; x++){

          wa.write(c*9+y*3+x);
          ia.write(c*100+y*10+x);

          if(!((c==2)&&(y==2)&&(x==2))){
            wait();
          }
          while(!start.read()&(c==0)&&(y==0)&&(x==0)){
            wait();
          }
        }
      }
    }
    last.write(1);
    wait();
    last.write(0);
```

Verilog で書くとこんな感じ。  
Verilog なので書く順番は関係ないですが、C で書くときとそろえると読みやすくなるかと思います。  
Verilog Mode を使っても、自動でインデントが付かないのがいまいちですけど…

```verilog
   assign last = last_c;

   loop1 #(.W(4)) l_c(.ini(4'd0), .fin(4'd2), .data(c[3:0]), .start(start),  .last(last_c),
                      .clk(clk),  .rst(rst),                  .next(next_c),   .en(last_y) );

   loop1 #(.W(4)) l_y(.ini(4'd0), .fin(4'd2), .data(y[3:0]), .start(next_c), .last(last_y),
                      .clk(clk),  .rst(rst),                  .next(next_y),   .en(last_x) );

   loop1 #(.W(4)) l_x(.ini(4'd0), .fin(4'd2), .data(x[3:0]), .start(next_y), .last(last_x),
                      .clk(clk),  .rst(rst),                  .next(next_x),   .en(1'b1) );

   assign wa = c*9+y*3+x;
   assign ia = c*100+y*10+x;
```

内側のループが終わった時だけ外側のループを実行するために、last と en をつないでいます。  
内側のループが終わった後に、もう一度繰り返すかを外側のループから伝えるのが next と start の接続です。

流してみた波形がこんな感じ。

![wave](wave.png)

流してみる環境はないですが、実際に tiny-dnn アクセラレータで使ったコードも置いておきます。  
SystemC の tiny_dnn_sc_ctl.h, tiny_dnn_sc_ctl.cpp が tiny_dnn_ex_ctl.sv になります。  
exec==0 の時は ia, wa が一致しませんが、exec==1 の時しか必要のない信号なので書きやすいように書いています。
