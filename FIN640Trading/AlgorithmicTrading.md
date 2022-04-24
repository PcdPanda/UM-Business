[toc]

# 1. 基本概念

### 1.1 交易术语

##### 报价

| Bid Price | Ask Price | Quote          | Size/Quantity | Bid-Ask Spread                        | Arrival Price | Effective Spread              | Depth             |
| --------- | --------- | -------------- | ------------- | ------------------------------------- | ------------- | ----------------------------- | ----------------- |
| 出价(买)  | 问价(卖)  | 公开的最好价格 | 交易量        | 盘口差价,描述立刻买入并卖出的亏损 * 2 | (AP + BP) /2  | 2  * (成交价 - Arrival Price) | 考虑Quote后的差价 |

##### 交易所 (Trade Venue)

- Electronic Communication Networks (ECN): Quote会公开
- <u>Dark Pool: 无法获得任何报价信息,避免订单信息对价格造成影响</u>

### 1.2 <u>交易所撮合逻辑</u>

##### 撮合逻辑

- <u>价格-时间优先</u>: 价格越合适的order越早执行
- 价格-交易量优先: 提高交易量,但order的volume可能不真实
- 价格-券商优先: 鼓励券商将order发送到交易所,避免本地交易
- 价格-透明度优先: 鼓励交易者公开交易信息

##### 集合竞价

- 努力促成数量最多的交易
- 报价完成后,根据优先原则逐步撮合,最后一笔可以执行的交易就是竞价价格

##### 手续费

- Maker-taker-model: 市价单手续费高,market maker通过报限价单提供流动性赚取手续费
- Taker-maker-mode: 限价单手续费高,减小orderbook的长度

### 1.3 交易算法分类

##### 执行规模

- Single-order: order之间不会互相影响
- List-based: order的成交会影响另外一个order的操作

##### Function

- Algorithmic: 专注于order size和price的设置
- Smart router: 将order发送刀最合适的交易所

##### Working Approach

- Scheduled-based: 基于一些特定指标,如TWAP,VWAP,OS,并根据预先设置好的逻辑执行
- Dynamic: 会根据市场指标POV等信息调节交易逻辑,例如交易节奏等
- Opportunistic: <u>在有机会的时候才会交易,但依然会服从逻辑,适合大订单</u>

### 1.4 交易三要素

##### 交易成本

- 盘口价差会带来流动性成本 (需要加钱才能立刻交易)
- 市场因素会导致价格不理性地上涨,因此需要额外成本
- 措施交易机会会导致额外的机会成本

##### 超额收益 (Alpha)

- 短期内可以获得的超额利润 (T0通常捕捉日内Alpha)
- 利用orderbook信息提供流动性可以获得alpha收益
- 延迟套利,利用别人未撤的order可以获得收益

##### 风险控制

- 资产风险,参考CAPM可以划分为内在风险和市场风险
- 通过分散投资和对冲来降低市场风险
- 通过交易频率来平衡内在风险,但是会提高交易成本

# 2. 单订单算法(Single-Order Algorithms)

### 2.1 Scheduled-Based

##### TWAP (Time-Weight Average Price)

- 设定目标成交数量,以固定的交易速率交易
- 通过限价单来减少市价单的交易成本,但是会提高误差
- 通过设置交易量区间,来决定使用限价单/市价单. 当成交量较少,接近区间下沿时,使用市价单
- 区间的宽度决定了算法在单位时间内的最大交易量,可以用来分析对市场的反身性效应

##### VWAP (Volume-Weight Average Price)

- 将历史交易数据按照交易时间划分成等长区间,根据区间中的相对交易量,来设定自己在每个区间里的目标交易量
- 使用连续函数拟合历史数据,来估计交易量
- 使用手动划分(基于行业)/自动划分(K-means)将标的分组计算交易量的平均值,来平滑交易量曲线

##### IS (Implementation Shortfall)

- 通常和基于arrival price的benchmark做比较并衡量低买高卖的效果
- 专注于最小化目标函数,包括<u>交易成本,alpha损失(例如错过交易机会)和风险</u>, 风险可以用<u>波动率(方差)和交易量乘积表示</u>
- 算法的风险厌恶程度会决定不同风险的权重,因此会导致最优参数改变(例如持仓时间)

##### Close Algorithm

- 使用收盘价代替arrival price作为benchmark,因为收盘集合竞价没有交易风险
- 在收盘集合竞价时会强制平仓,减少风险,但需要考虑自身订单

### 2.2 Dynamic 

##### POV (Percent of Volume)

- 要求trader定义一个<u>participation rate,使得算法交易量和当前市场成交量比例固定</u> (放量的时候要多报单)
- 交易量追踪可以有误差,但一般需要在1%以内,通过限价单和市价单构成的band来执行
- 需要追踪tick-tick数据,且计算市场交易量时需要考虑自身成交,例如(900(市场)+100(自身))=1000
- 在放量的时候,做出的交易更多. 由于放量的时候风险变大,因此<u>更多交易可以降低风险</u>
- 为了追踪的<u>时效性</u>,会使用大量市价单,导致盘口成本上升,<u>在流动性差的标的上成本尤其高</u>
- 算法<u>本质上还是在跟随和回应交易量</u>,而不是成为交易量的一部分

##### <u>Forecasted POV</u>

- 根据participation rate,使自身交易量和<u>估计市场交易量</u>成比例,<u>可以避免滞后性</u>
- 将时间轴切片成区间,对每个区间里的市场成交量估计,<u>估计值会随当前市场表现而改变</u>

##### Optimal POV IS Variation

- 随着市场交易成交量的改变,<u>估计最优participation rate</u>,但依然以VWAP为基准交易
- 通过引入手动participation rate,允许算法完成“must complete"订单,本质上VWAP/TWAP是lower bound

### 2.3 Opportunistic

##### Hide and Take

- 平时挂限价单,或者持有仓位/被动交易,当有机会时,<u>报市价单</u>
- 相比scheduled algorithm, 适合应对小市值,流动性差的标的
- 基于price/liquidity/换手率等信息来发现opportunity

##### Adaptive Arrival Price

- 基于最近的价格走势做交易,但需要对未来的价格有一定预测能力
- 设定目标价格,根据实际价格和目标价格的相对位置做交易
- 反转交易:低买高卖/动量交易:上升时卖,下跌时卖

# 3. <u>多订单算法 (Multi-Order Algorithms)</u>

### 3.1 配对交易 (Pair Trading)

##### Overview

- 交易两种资产,一种做多,一种做空
- 根据两种资产价格的比值来判断交易方向,例如比值应为1.5的资产,当比值超过1.5时,就做空高比值的资产,做多低比值的资产
- 交易/平仓的比值触发范围要<u>留有缓冲区</u>,同时要考虑交易成本,盘口价格和市场反身性
- 交易时,要尽量保证<u>两种资产投入的资金相等</u>

##### Risk

- 当持仓过大时,可能不好平仓,或者使算法进入失控,因此需要设定平仓上限
- 每笔交易的交易量会决定比值跟踪的精确度,因此要以<u>小步快跑式交易</u> (先小幅交易A,再小幅交易B,保证比例一致)
- 通常<u>先用限价单交易难以/交易成本较高的资产A</u>,再用市价单交易流动性好的B,这样只需要控制B的交易风险

### 3.2 资产组合交易 (Portfolio Trading Algorithms)

##### Overview

- 基于single order IS algorithm扩展,寻求最小化trading penalty,可以<u>最好地权衡交易成本和风险</u>
- 交易成本和single order相同
- 风险可以用<u>波动率(方差)和交易量乘积以及两两资产间的表示</u> $\text{Trading Risk}=\text{Var}(Q_1\sigma_1+Q_2\sigma_2+\cdots+Q_n\sigma_n)$
- 可以通过对冲,或者同时做多相关系数是负的资产,来降低风险
- 可以利用不同资产间订单的相互作用,来赚取alpha. 例如买入A后会使B价格上涨,这时可以卖出B

##### Implementation

- 当订单之间负相关,风险较小,算法会更慢地交易,降低交易成本
- 当资产之间流动性不同,算法会大量交易流动性好的资产来实现对冲,因为交易成本更低
- 当资产的波动率不同,算法会大量交易波动性大的资产,降低风险

- 以VWAP形式交易,但是实时都在优化交易量目标
- 发大量小单代替大订单,保证灵活性,并减少对市场的影响

##### 优点

- 可以对不同的标的,进行不同的交易模式,例如对A使用VWAP,对B进行投机交易

- 交易时可以统筹规划所有标的的交易量
- 执行交易时,可以临时买入其他资产进行对冲减小风险,并在交易完成后平仓

##### 辅助功能

- 对于single-order algorithm的风险进行再平衡
- 因为只考虑了风险,因此可能导致大量交易成本
- 再平衡过程中可能忽视了交易机会,且对走势奇怪的标的可能无效

# 4. 风险权衡

### 4.1 交易程序风险控制

##### 边界条件

- 注意用户输入和市场行为带来的未定义/错误行为 (例如放量/overflow等)
- 需要探索可能的场景,并对不同的参数做测试
- 需要设定特定的benchmark来测试

##### 集合竞价

- VWAP通常会估计竞价的交易量,并设定算法下单数量
- TWAP会手动设置交易量
- POV算法通常不参与竞价,因为无法准确估计交易量,可能出现边界情况
- 为了避免不稳定性,尽量在交易截止前平仓

##### 量价限制

- 交易量限制防止算法做出过多交易对市场有反身性影响 (VWAP和POV算法有不同的设置)
- 当算法只允许报限价单时,会因为无法成交而无法满足交易量要求,这时候需要设定优先级
- <u>当限价单要求取消后,算法可能会报很多单来满足交易量,但这个时候需要平滑恢复</u>
- 交易量设置太紧会让算法接近于POV,有滞后性等问题,<u>在流动性差的标的上会有严重影响</u>
- 需要识别出block trade并避免它们对交易量激增的影响,并判断是否有持续性

##### 平仓限制

- 设定平仓方式,撤单还是变成市价单
- 考虑平大量仓位时对市场的反身性影响
- 延迟和市场随机性,平仓有时无法完成,因此算法会提前进入平仓模式
- 使用市价触发的限价单,来避免平仓时价格波动太大造成的损失,再次失败后使用市价单平仓

### 4.2 利弊权衡

##### Large Optimization

- 当Portfolio参数很大时,相关性矩阵很大,需要大量时间计算
- 通过定性分析和稀疏矩阵,减少计算量

##### 人工约束

- 当算法同时受到交易量和人工强制订单约束时,可能会出现逻辑错误
- 可以放松约束,从一天变成好几天的聚合值,但同时可能放大误差
- 将约束分为两步,第一步是总体约束,必须完成,第二部在更细颗粒度上进行约束,且实时计算,可以引入手工措施
- 在交易时间上也可以加入约束(例如让算法提早完成交易,减少clean up的风险)

##### 量价准确度对最优解的影响

- 交易量的随机性可能会对算法生成的最优解产生影响
- 对单个订单的成交价约束,会影响到其他订单,因此估计可能不准确
- 算法获得到的交易量,成本和风险可能有一定误差,也有可能随着市场而改变,因此需要添加额外逻辑弥补误差 (例如减少早上的交易)

# 5. 订单提交

通常需要同时考虑价格,订单量和路由三者的关系,但是按照特定顺序处理任然可以逼近最优解

### <u>5.1 定价 (Pricing)</u>

##### Overview

- <u>订单价格本质上在成交率,edge和损失风险上权衡</u>. $\text{Expected Gain}=p\times\text{Edge}-(1-p)\times\text{Cost of Not Fill}$
- 在交易时,对不同的edge计算收益率期望,并选择最优报价

##### Fair Value

- 资产的真实经济价值,可以用折现现金流,资产价值表等多种方式衡量,但很难准确估计,微观上是<u>MP</u>或者VWAP
- VWAP由于报单量和交易的发生的不确定性,可能有较大波动. 且随着成交价格下降,VWAP可能上升
- 市场上发生的交易会fair value产生反作用,自身的交易也会. 在informed trader主导的市场交易,期望收益永远是负的
- Fair value自身存在波动,可能来不及修改订单,价格就变了,导致了不理想的成交. 因此速度是关键,这也是散户最大的劣势
- 自身的报单也会会对市场产生反作用,取决于订单的在orderbook上的位置和交易量

##### Edge

- 在交易上获得的利润,本质上是订单成交价格和fair value的差
- Edge越大,成交概率越低,但收益越高
- 使用历史数据中的盘口,波动率,时间曲面和orderbook数据作为神经网络/probit/logit的输入来估计不同edge下的成交概率
- Pegging Edge Estimation: order价格始终和quote相同,非常简单,但是当价格变动时,来不及反应,且具有盲目性. 因此需要补充额外逻辑来提前调整价格,并发现quote中的陷阱. 例如只有持续$X$秒以上的quote才有效
- <u>Market Edge Estimation</u>：使用盘口spread一半的EMA或者TWAP来作为edge

##### Cost of Not Fill

- 挂单未成交的损失,包括<u>时间,手续费和机会成本</u>(当订单只成交一半时,都是盈利的)

- <u>使用动态规划估计交易成本,$t=n$时刻的cost of not fiil就是$t=n+1$时刻的expected gain+潜在价格变化(通常为0)</u>. 如果是必须成交单,则在最后一个时刻的expected gain就是手续费

  $\text{Cost of Not Fill at }t=-\text{Expected Gain at }(t+1)+\text{Fee at }(t+1)+\text{Potential Price Change}$

##### Other Consideration

- 如果算法已经落后于计划(例如靠近band),需要使用更激进的定价.或者市价单,来确保成交
- 算法由时间触发/事件触发:时间触发可能会让算法在休眠阶段错过市场数据,事件触发需要大量计算资源
- Alpha的应用: 持续时间短(几秒)但可靠的alpha可以用来辅助预测fair price
- 用short-lived fleeting order来获得对手关注,之后再撤单
- 使用reinforcement learning来优化tick rounding,因为有的edge价格是无法报单的

### 5.2 定量 (Sizing)

##### Overview

- 决定每笔订单的交易量多少是最优的
- 决定多少订单需要公开在orderbook上

##### Orderbook Layering

- <u>在orderbook上不同的价格挂很多订单,从对流动性诉求强的对手中获得超额利润</u>
- 隐式地定义了订单成交的时间,因为价格必须向一边波动才可以成交
- 挂很多订单可能泄露自己的交易目的,要注意对市场的反作用,因此有时使用hidden order

##### Order Visibility

- Light Order: 暴露在orderbook上的订单,可以用来获取对手注意力,但小心会暴露自己的交易意图
- Hidden Order: 不在orderbook上显示的订单,优先级很低,只有在对手有oversize/sweeping订单时才好成交
- Reserve Order: 设置了在orderbook上暴露的max quantity的冰山订单,综合了light和hidden order的优劣

### 5.3 订单路由

##### Smart Market Order Routers

- 对市价单进行路由,寻求流动性最充分的交易所,降低交易成本
- 使用IOC市价单,来防止因为价格波动太快,市价单的成交价格和路由基于的价格差距过大
- 在收到订单确认回报前,router要不断工作,发现当前最合适的venue,以便在被拒后继续发送
- 需要调整发现报单的交易所顺序,以防因为自己在交易所A的order导致了交易所B价格的上涨

- 通过对orderbook上的缺失价位发订单,来检查是否有隐藏单,但是当订单交易量很大时,部分成交可能会泄露信息,这时可以手动设置<u>最小成交量</u>(MAQ)来避免部分成交

##### Smart Limit Order Router

- 对限价单进行路由,<u>寻求成交概率最大的交易所</u>
- 通过分析orderbook的长度,平均每个订单完成的时间,和订单主动被撤的概率,来估计自己成交的概率
- 对于大订单,寻求成交速度快的交易所.对于小订单,寻求orderbook队伍短的交易所
- 有时候队列长度会和交易速度相关,因此很难估计,且最优解会取决于当前的订单大小
- 人们更偏向用复杂的机器学习模型来代替传统的统计拟合模型

##### Dark Pool Aggregator

- 对隐藏单进行路由,寻求在dark pool以mid price进行成交
- 交易者可以使用<u>条件单</u>同时向多个dark pool报价,由于需要firm order交易才会执行,因此可以同时处理更大size的报单
- 同样寻求成交概率最大,但因为无法得到orderbook,只能依赖历史数据进行估计
- 对所有交易所发IOC订单,估计成交概率,随后根据成交概率发送报单. 根据订单的成交量,可以估计orderbook这个价位是否还有报单

- 因为获得的数据量非常有限,通常使用迁移学习模型来选择最好的交易所
- 用户会通过IOC和条件单来获得orderbook上的信息, 但Dark Pool会对交易者进行分区/监控,来减少信息泄露,交易者也可以使用MAQ来减少部分成交的次数

# 6. 交易表现评估

### 6.1 基准价格 (Benchmark price)

##### Overview

- 衡量理想的交易价格,通常和实际价格做差来衡量交易表现
- <u>通常综合在不同benchmark上的表现来评估策略质量</u>
- 需要考虑交易员自身对benchmark price的影响

##### Arrival Price

- 使用提交交易时的Arrival Price作为benchmark price,这个时候的cost称为<u>Execution Shortfall</u>
- 单个样本上的噪音可能比较大,因此比较的时候一定要控制变量
- 需要过滤收盘数据,否则会引入大量波动,且因为成交价格和开盘价一致,此时performance是0
- <u>流动性好的标的,使用开盘价作为arrival price,流动性差的标的使用前一天的收盘价</u>
- 当数据量充足时,使用arrival price的评估结果会收敛于真实值

##### VWAP

- 使用从报单到成交阶段的VWAP作为benchmark price
- <u>可以过滤无关噪音,但因为VWAP受到交易自身的成交影响较大,所以计算出来的performance无法衡量market impact</u> (biased to 0)
- 适合用来衡量VWAP算法的表现,或者两个算法的<u>相对表现</u>

##### Participation-Weighted Price (PWP)

- 指定参与率后,构造一个虚拟的VWAP,再根据目标交易量计算这段时间里的Benchmark
- 将市场按照交易量(Participating Rate * Target Size)切分,计算每个区间里的VWAP,取平均值计算Performance. <u>最差的Performance对应最优频率</u>
- 和VWAP一样,容易受到自身交易的影响,且对于不同的策略,衡量效果有bias

##### Post-Trade Price

- 交易之后的价格,可以是收盘价,或者$X$分钟之后的价格,但可能受到交易自身的影响,因此需要<u>考虑到距离交易的延迟有多少才可以消除误差</u>
- 通过和Arrival Price相减,可以估计交易带来的alpha
- 通过计算post-trade price和区间中峰值的差,通过价格反转,可以分析交易带来了多少信息
- 在Dark Pool中对相同策略使用逆向选择,还可以用于选择最合适的交易所

### 6.2 交易表现测定

##### Realized Performance

- 对于买方,是$\text{Benchmark Price}-\text{Execution Price}$
- 对于买房,是$\text{Execution Price}-\text{Benchmark Price}$
- 在考虑执行价格时,需要加上交易成本
- Realized Cost是performance的相反数

##### Unrealized Performance

- Mark to Market Price: 报单时但没有成交的价格/收盘价

- 对于买方,是$\text{Benchmark Price}-\text{Mark-To-Market-Price}$
- 对于买房,是$\text{Mark-To-Market-Price}-\text{Benchmark Price}$
- Unrealized cost是performance的相反数,描述了机会成本

##### Total Performance

- $\text{Total Performance}=\text{Realized Performance}+\text{Unrealized Performance}$
- 计算performance时,必须同一使用预先设定好的benchmark price
- 多日performance计算,我们使用前一天的execution/Mark-To-Market-Price作为当日的benchmark Price分别计算每日Performance再累加

##### Non-Price-Based Metrics

- Participation Rate: 通过交易次数和交易量来分析交易的激进程度,适合分析交易策略的交易成本 (trading cost)
- Parent-level Fill Rates: 通过分析订单的成交率来分析<u>edge的设定是否合理</u>,并找出影响成交率的原因

- Child-Level Fill Rates: 通过和parent-level fill rates作对比,可以用来分析routing和不同交易所的表现

### 6.4 交易表现测定技巧

##### 测量单位

- Basic Points (基点bp): $\frac{\text{Performance}}{\text{Execution Price}}\times 1\%$

- bp使得不同资产上的表现有了可比性

##### Absolute Performance

- 通过拆分Absolute Performance,可以分析策略表现优劣的来源 (标的选择/报单逻辑/路由)
- 平滑大量相似的订单来去噪,但因为样本数量有限,有时候必须放松条件

##### Trading Cost Model

- 通过拟合来估计交易策略的表现

- 从多个角度引入变量,并通过估计参数来分析

  | 标的选择           | 报单逻辑         | 交易策略                 |
  | ------------------ | ---------------- | ------------------------ |
  | 盘口/成交量/波动率 | 订单量/方向/类型 | 交易频率/参与度/算法类型 |

- <u>常用的估计模型($\sigma$是波动率,$\gamma$是基于策略使用的参数)</u>

  $\text{Expected-Trading-Cost}=\text{Half-Spread }+\gamma\cdot\sigma\cdot\sqrt\frac{\text{Order-Size}}{\text{Volume}}$

- 模型的可靠性依赖于模型结构,估计技巧以及历史数据

##### Relative Performance

- 基于算法和标的等参数,拟合cost model,并把<u>不同策略和cost model进行比较</u>

- 同时在市场上运行算法,并直接对performance进行比较,可以控制市场因素的变量
- <u>通过比较performance和对应cost model的差值,查看哪个算法相比cost model的表现更好</u>

### 6.5 测定问题处理

##### 样本特征比较

- 需要判断样本在不同特征下的分布
- 即使是相同标的上平均值相同的订单,在performance上也有可能不同 (例如成交总数相同,但是大订单交易成本更高)
- 使用不同特征来对订单分组,并衡量模型在不同分组和特征上的表现,可以获得更加全面的评估结果

##### 订单权重分析

- 在衡量算法表现时,首先在每一笔订单上衡量,随后根据权重计算整个算法的表现
- 使用订单成交量作为权重适合分析真实交易情况
- 所有订单等权重适合分析算法对于订单的处理表现

##### 统计量分析

- 根据数据中的标准差,和衡量的订单参数,选择合适的样本数量,获得有意义的结果
- 分析前要考虑统计量和模型的假设是否成立
- 需要考虑数据的信噪比,使用联合分布分析更可靠

##### 极值处理

- Outlier是在特定tail中的样本,我们可以直接移除outlier
- Influential Observation是会影响总体结构的样本(例如size很大的order),我们可以直接修改相关数据为cut off value来减缓影响
- 在处理时,一定要注意是否会对常规统计量造成bias (例如只处理一边的outlier会导致平均数有偏差)
- 衡量算法真实表现和鲁棒性时,不处理极值. 分析算法性质,并优化逻辑时,可以先处理极值
