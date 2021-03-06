[toc]

# 1. Trading Basis

### 1.1 Trading Industry Participants

##### Buy Side

- 交易市场服务的使用者

- 交易机构/基金/政府机构/信托/基金

##### Sell Side

- Dealer: 证券发行方,交易定价方
- Broker: 帮助交易者接入市场
- Consultants: 研究服务提供者

##### Trade Facilitators

- 交易所: Light Exchange/Dark Pool
- Clearing houses: 结算部门,确保交易成交
- DTCC: 证券托管持有部门

##### Regulator

- 政府/国会制定监管法律
- SEC根据法律执行监管
- Trade Facilitators负责上报可疑信息
- 自律机构负责相关组织内的监管

### 1.2 Securities

##### Stocks

- 描述了持有者对公司的所有权
- 持有者可以获得公司的分红和表决权

##### 债券 (Bond)

- 公司/政府的贷款凭证
- 在指定日期会归还本金和利润(无风险投资)
- 在OTC交易

##### Options (期权)

- Calls Option: 认购期权,可以在日后行权以低价买入证券
- Puts Option: 认沽期权,可以在日后行权以高价卖出证券

##### Futures/Forward (远期合约)

- 在未来以指定价格交易的合同,必须行权
- 被交易的远期合约就是期货

# 2. Order Driven Market

### 2.1 特点

##### 执行方式

- 只有Broker来寻找对手方,没有dealer来定价
- 资产价格完全由市场决定

##### 交易参与者

- Public trader: 通过报限价单/市价单等订单来完成常规交易
- Dealer: 本质上和散户一样,只能进行常规交易
- Specialists (Designed Market Maker): 对一支个股的交易提供流动性

### 2.2 Order 

##### Price Type

| Bid Price | Ask Price | Quote          | Size/Quantity | Bid-Ask Spread                        | Arrival Price | Effective Spread              | Depth             |
| --------- | --------- | -------------- | ------------- | ------------------------------------- | ------------- | ----------------------------- | ----------------- |
| 出价(买)  | 问价(卖)  | 公开的最好价格 | 交易量        | 盘口差价,描述立刻买入并卖出的亏损 * 2 | (AP + BP) /2  | 2  * (成交价 - Arrival Price) | 考虑Quote后的差价 |

##### <u>Order Type</u>

- Market Order: 立即成交的订单,成交价格不确定,但是有最高的优先级成交
- Limit Order: 不会在更坏情况下成交的订单,<u>常用于入场</u>
- Stop Order: 当价格逆势运动到指定价格时,触发生成市价单交易,<u>常用于平仓和止损</u>
- Stop-Limit Order: 当Stop Order触发时,不会立即生成市价单,而是生成限价单

##### 交易约束

| 约束角度 | 解释                           | 例子            |
| -------- | ------------------------------ | --------------- |
| 有效期   | 超出有效时间订单自动失效       | 5min后失效      |
| 交易时点 | 只有在特定交易时点内才可以成交 | 收盘前5min      |
| 交易量   | 交易量分割的最小单位           | 至少以100手成交 |

### 2.3 连续交易

##### 特点

- 交易者可以在开市的任何时间报单交易
- 波动率大,自由度高
- 价格可以很快反应信息

##### 撮合逻辑

- <u>价格-透明度-时间优先</u>: 价格越合适的order越早执行,随后优先看是否公开,再看报单时间 (核心是为了提高流动性)
- 价格-交易量优先: 提高交易量,但order的volume可能不真实
- 价格-券商优先: 鼓励券商将order发送到交易所,避免本地交易
- 大订单会被拆分成小订单,来分批成交

### 2.4 竞价交易

##### 特点

- 交易所只会在特定时点结算交易
- 波动率低,可以在同一时间吸引大量交易者
- 价格反应信息的速度较慢

##### 竞价逻辑

- 努力促成数量最多的交易
- 报价完成后,根据优先原则逐步撮合,<u>最后一笔可以执行的交易就是竞价价格</u>

### 2.5 Order Protection Rule

##### 功能

- 当标的在不同交易所同时上市是,指导broker从全局上按照order priority发送订单
- 只要公开的订单都会受到保护,即能按照优先级成交
- Trade through任然有可能发生,因为发送到交易所之后,可能和价格更好的本地隐藏单先成交

##### NBBO

- 每次交易所有报单时,就更新quote,Bid取最大,Ask取最小
- 当Bid和Ask有交叉时,就可以产生交易
- 高频交易者可以更快地从交易所直接获得best quote和NBBO的更新,因此存在套利机会

# 3. Off-Exchange Trading Market

### 3.1 Alternative Trading System (ATS)

##### 特点

- 由任何组织/团体/机构搭建的交易系统,提供证券和衍生品交易服务
- 和交易所不同,只进行交易服务,而不提供发行等服务,因此<u>只对交易行为进行监管</u>
- 只允许有特定资质的成员进入

##### 典型的ATS

- ECN: 公开的交易系统,orderbook可见
- Dark Pool: 私人运作的交易系统,orderbook不可见,且不会被上报到NBBO
- Dark Pool和常规交易所都运行交易,属于商业竞争关系

### 3.2 Dark Pool

##### 运作模式

- 常用于吸纳大订单,因为可以避免因为信息泄露而使价格向不利方向发展
- 当市场平稳时,客户的人数会越来越多
- <u>交易依然需要上报,因此可以通过发送探测小订单来挖掘少量报价信息</u>
- 将交易者分级,低级交易者无法主动和高级交易者交易

##### Order Type

- Peg-Order: 特殊的限价单,限制价格是特定值,例如mid-price, best ask等
- Min-Quantity: 设定最小成交量的报单
- Interaction Rule: 限制成交对手方

##### Crossing Market

- 客户的订单只有成交量,而没有价格
- 统一按照NBBO的Mid Price成交,有效阻止了信息泄露,但是利用了竞争对手(lit exchange)的信息
- 可以在固定时点发生交易(Scheduled Crossing),也可以是连续的
- 因为没有价格和报单信息,可能会减少市场流动性

##### 问题

- 交易者可以通过在公开交易所报单修改NBBO价格,从而在Dark Pool交易中盈利
- Dark Pool可能使用客户信息来获取利润
- 交易者可能用探测订单来获得Order Book信息
- 监管远比常规交易所少

# 4. Sell

### 4.1 Broker

##### 职责

- 给客户寻找交易对手方,不同的broker专门负责散户/机构
- 提供接入市场的服务,因此知道所有客户的交易信息
- 提供研报等服务

##### 问题

- Internalization: 不将订单发到交易所,而是直接在客户之间成交,可以降低交易成本,但会分裂市场
- Trade Assignment: 没有完全遵守报单优先级原则,而是根据自己利益选择交易对手方
- Front-Running: 在将客户订单发到市场之前,提前下单,在市场发生变化前赚取利润
- Churning: 替客户托管资金,但是过度交易,从而谋取大量手续费
- Kickbacks: 通过给提供回扣的客户提供优质服务,对其他客户不公平

##### 盈利模式

- Commission Fee: 对每笔交易收取手续费
- Soft Dollars: 给客户提供研究分析服务
- Order Flow Payment: 将订单导向做市商或者自己的dealer部门促成交易

##### 监管

- 明确怎样的行为才符合客户利益
- 通过设立监督和评价机构,促进broker向好发展

##### Broker Market

- Broker帮助交易者寻找对手方,并促成交易
- 股票市场通常是Broker Market 

### 4.2 Dealer/DMM/Specialist

##### 职责

- 注册后,为特定股票报固定价格的限价单,为市场提供流动性
- 通过做市来赚取盘口差价,因此盘口越大利润越大
- 不会持有大量仓位,否则风险太大

##### Dealers Market

| NASDAQ | Over the Counter Bond Market | Foreign Exchange | SEAQ | NYSE |
| ------ | ---------------------------- | ---------------- | ---- | ---- |

- Dealer作为买卖的对手方,主导整个市场
- Dealer设定买卖的价格,交易者只能选择是否在该价位成交
- Dealer为交易所填充orderbook,提高交易热度
- 市场不透明,且dealer之外的人无法获得很精准的报价

##### 盈利模式

- 赚取流动性的盘口差价
- 订单成交赚取手续费

# 5. 买方

### 5.1 价格

##### Market Value

- 上一次交易的价格
- 由供求关系决定,但包含了流动性,基本面,技术面等因素

##### Fundamental Value

- 如果所有人都有相同信息,并会达成一致的价格
- 描述了标的的真实价格,但永远无法被观测

##### 信息对价格的影响

- Public Information: 所有人都知道的信息,应该已经反映在价格里了
- Private Information: 私人信息,可以通过研究或者内部人士知道,但是利用内部信息交易时违法的
- 信息会对基本面造成巨大影响,而不是流动性,但依然会影响供求关系
- 重大信息发布前,交易者会倾向于平仓,这个时候流动性减弱,盘口扩大,做市商会停止提供服务
- 信息发布后,会出现极端的单边行情,交易量激增

### 5.2 交易者分类

##### Informed Traders

- 对公司的基本面价值有准确估计,当真实价格偏离过大时,就会买入
- 交易会导致价格回归基本面,但需要流动性才能获利,否则无法成交

| 交易者类型               | 方法                           | 参考指标             | 交易习惯                 |
| ------------------------ | ------------------------------ | -------------------- | ------------------------ |
| Value-Motivated Traders  | 使用经济模型来分析标的的基本面 | 财报/资金流/折现报表 | 遵守纪律和模型           |
| Information-Flow Traders | 分析新闻对价格的影响来交易     | 新闻/事件            | 行动快速                 |
| Pseudo News trader       | 使用发酵后的新闻交易           | 价格中包含的新闻     | 速度慢,常亏钱            |
| Insiders                 | 使用公司内部私人信息交易       | 私人信息             | 提前布局,利润高,但是违法 |

##### Technical Traders

- 使用历史价格和信息来预测未来走势
- 技术分析的自身行为导致技术分析失效
- 利润最少,通常使用其他人的残羹剩饭

##### Arbitrageurs

- 使用不同标的之间的相对走势差获利
- 可以在不同品种,不同交易所,不同时间中交易获利

##### Noise Traders

- 对市场影响最小的散户,并使用市价单交易
- 一定程度上可以提供流动性

##### Market Makers

- 通过提供流动性和填充orderbook来赚取盘口差价
- 竞争非常激烈,长期来看几乎没有收益

### 5.3 信息



