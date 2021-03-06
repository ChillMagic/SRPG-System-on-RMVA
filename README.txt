SRPG System on RMVA 说明文档
Version 1.0.0
by Chill
Date: 2016.5.11

一、事件命名：
  事件名称是大小写不敏感的。处理名称时会自动将名称转换为大写形式。
  (一) 战斗者事件(BattlerEvent)
  1.通用命名方式：
    通用命名方式用于编号固定的战斗者，如固定角色、默认敌人等。想要获得动态，请使用特殊命名方式。
    (1) 类型：由命名中最前面的两个字母组成。
      前一个字符表示具体的初始化战斗者类型（所属阵营），分为： A:角色 E:敌人 F:友军。
      后一个字符表示该战斗者所读取的数据库类型，分为： A:角色 E:敌人。
      常用的表示有：AA, EE, FA 等。
      同时，为方便起见，也可以使用特殊命名。如 A（或AC）、E（或EM）、F 等，分别表示 AA（通常角色）、EE（通常敌人）和 FA（通常友军）。
    (2) 编号：紧随类型名的数字。
      编号是识别战斗者的重要方式。我们使用十进制数字来填写编号，长度不限。编号与类型名之间不能存在其他字符。
      通过编号，从类型获得的数据库中查找对应的数据项。由于编号与数据项是一一对应的，请准确填写。
      正确的编号方式：AA001, EM052, FA05 等。
      建议使用等长的字符串来表示标号，如1,52分别编写为001,052，将使阅读简便。
    (3) 分隔符：半角字符 ":" 。
      分隔符用于分隔不同的命名标记。读取其余标记时将根据":"分隔。
      请不要在正常项内加入此字符，否则可能会出现难以预料的错误。
    (4) 首领标记：带有 LEADER (或BOSS, LED) 关键词。
      该关键词主要用于标记首领身份。首领也可以在数据库中标记。
      两者的区别在于，事件命名中的首领标记只在此事件代表，而数据库标记则用于所有获取该数据的战斗者。
    (5) 属性设置：用于变更默认数据库的某项的值。
      ① 变更值：带有=关键词。
        使用方式是 数据项名称 + "="(或+= -= *= /=等类似赋值符) + 数据值 。如 hp=5000, mp=atk+500 等。
      ② 变更标记：带有-关键词。
        用于去除在数据库中定义的标记。如 去除首领标记： -leader 。
    
    2.特殊命名方式：
      (1) NUM(或PA, PE) 表示 放置角色(PlaceActor)。
      用于在参战时提供放置位点。其编号采用和通用编号相同的形式，但不同的是其所对应的是排列参战角色时所对应的相对位置。
      如果将设置“在地图上自动放置”变更为false，也可以选择忽略编号，直接命名为NUM(或PA) 即可。
      (2) 
      
二、动画
    攻击动画
    攻击