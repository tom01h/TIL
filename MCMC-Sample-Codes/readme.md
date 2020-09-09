

# ゼロからできる MCMC メモ

[ゼロからできる MCMC](https://www.kspub.co.jp/book/detail/5201749.html) のコードです。

Gaussian_HMC_multi_variables.cpp は公式サンプルからちょっとだけ変更したもの。  
Gaussian_HMC_multi_variables.py は試しに Python に翻訳したもの。

replica_salesman.c は公式サンプルからちょっとだけ変更したもの。  
replica_salesman.py は Python に翻訳したもの。

最初は意味を変えずに翻訳したものです。  
結果は test1/ 、ソースのコミットは d3eabd0770cdf534239c21303850cc511eec94d7 。

次に、レプリカ交換を並列実行可能とするために、チクタクで隣と交換するだけにした 。  
結果は test2/ 、ソースのコミットは 6b60e3a6b3771b20c9f91ae56481db1793230694。

2-opt 法と簡易 or-opt 法のチクタクに変更。[これ](http://www.nct9.ne.jp/m_hiroi/light/pyalgo64.html) を参考にさせてもらった。 

レプリカ交換をチクタクにして 10000万回実行、その後 2-opt と簡易 or-opt にして 50万回実行した結果。

![salesman](salesman.gif)

![distance](test2\distance.png)