*************************************************************************
*************************************************************************
*                              源网荷协调控制  V1.0 MINLP
*                                               Written by Wuhan in Hohai
*************************************************************************
*************************************************************************
$Ontext
基于MINLP的源网荷协调控制程序
包含分布式电源，储能，可中断负荷，变压器变比
求解器设置：推荐求解器 DICOPT
$Offtext
*************************************************************************
*                              设 定 集 合
*************************************************************************
set bus           '节点' /
$include '..\data\setbus.inc'
/;
set unit          '电源' /
$include '..\data\setunit.inc'
/
    pv(unit)      '光伏电源' /i2/
;
set ess           '储能' /
$include '..\data\setess.inc'
/
;
set cl            '可控负荷' /
$include '..\data\setcl.inc'
/
    il(cl)        '可中断负荷' /cl1/
;
set line          '线路' /
$include '..\data\setline.inc'
/;
set pd            '仿真时段数' /
$include '..\data\sett.inc'
/;
set it            '负荷可中断时间' /
$include '..\data\setit.inc'
/
    cluseit(it)   '每个可控负荷的中断时间,子集'
;
set clit (cl,it)  '每个可控负荷对应可中断时间'
;
set PVPName       '光伏系统参数信息' /
$include '..\data\setPVPName.inc'
/;
set EssPName      '储能系统参数信息' /
$include '..\data\setEssPName.inc'
/;
set ClPName       '可控负荷参数信息' /
$include '..\data\setClPName.inc'
/;
set LinePName     '线路参数信息' /
$include '..\data\setLinePName.inc'
/;
*set UnitPName     '发电机参数信息' /
*$include '..\data\setUnitPName.inc'
*/;
alias(Bus,Busj);
*************************************************************************
*                           设 定 潮 流 参 数
*************************************************************************
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~基础参数设定~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Scalar pi /3.14159/
;
Scalar MW2kW /1000/
;
scalar step          '仿真步长,分钟'/
$include '..\data\step.inc'
/;
Scalar BasePower     '基准功率,MW'/
$include '..\data\BasePower.inc'
/;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~经济性参数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
table C(pd,unit)     '每MWh成本,元/MWh'
$include '..\data\Cost.inc'
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~发电机参数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parameter GenBus(unit)'电源对应的节点'/
$include '..\data\PowerBus.inc'
/;
table Pmax(pd,unit)  '电源理论有功出力值（上限）'
$include '..\data\UnitPmax.inc'
;
table Pmin(pd,unit)  '电源理论有功出力值（下限）'
$include '..\data\UnitPmin.inc'
;
table Qmax(pd,unit)  '电源理论无功出力值（上限）'
$include '..\data\UnitQmax.inc'
;
table Qmin(pd,unit)  '电源理论无功出力值（下限）'
$include '..\data\UnitQmin.inc'
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~光伏发电系统参数~~~~~~~~~~~~~~~~~~~~~~~~~~~~
table PVPara(pv,PVPName) '光伏发电系统参数读取'
$include '..\data\tablePVPara.inc'
;
parameter  PVCap(pv)    '光伏发电容量,MWp';
PVCap(pv)=PVPara(pv,'Cap');
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~储能系统参数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
table EssPara(ess,EssPName) '储能参数读取'
$include '..\data\tableEssPara.inc'
;
parameter  EssBus(ess)    '储能系统对应的节点';
EssBus(ess)=EssPara(ess,'InBus');

parameter  EssCap(ess)    '储能电池容量,MWh';
EssCap(ess)=EssPara(ess,'Cap');

parameter  EssMaxCP(ess)  '储能最大充电功率,MW';
EssMaxCP(ess)=EssPara(ess,'MaxCharP');

parameter  EssMaxDP(ess)  '储能最大放电功率,MW';
EssMaxDP(ess)=EssPara(ess,'MaxDisCharP');

parameter  EssMinCP(ess)  '储能最小充电功率,MW';
EssMinCP(ess)=EssPara(ess,'MinCharP');

parameter  EssCRate(ess)  '储能充电效率';
EssCRate(ess)=EssPara(ess,'CharRate');

parameter  EssDRate(ess)  '储能放电效率';
EssDRate(ess)=EssPara(ess,'DisRate');

parameter  EssDOD(ess)    '储能放电深度';
EssDOD(ess)=EssPara(ess,'DOD');

parameter  EssSOH0(ess)   '储能初始SOH';
EssSOH0(ess)=EssPara(ess,'SOH0');

parameter  EssSOC0(ess)   '储能初始SOC';
EssSOC0(ess)=EssPara(ess,'SOC0');

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~可控负荷参数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
table ClPara(cl,ClPName) '可控负荷参数读取'
$include '..\data\tableClPara.inc'
;
parameter clinuse(cl)     '在用可中断负荷';

parameter  ClBus(cl)     '可控负荷所在的节点';
ClBus(cl)=ClPara(cl,'InBus');

parameter  ClCost(cl)    '可控负荷调度成本,元/MWh';
ClCost(cl)=ClPara(cl,'Cost');

parameter  ClMaxFreq(cl) '可控负荷最大中断次数';
ClMaxFreq(cl)=ClPara(cl,'MaxFreq');

parameter  IlTimeOMax(cl) '可控负荷单次最大中断时间,小时';
IlTimeOMax(cl)=ClPara(cl,'MaxOnceTime');

parameter  IlTimeAMax(cl) '可控负荷总计最大中断时间,小时';
IlTimeAMax(cl)=ClPara(cl,'MaxTime')*60/step;

parameter  IlTimeAMin(cl) '可控负荷总计最小中断时间,小时';
IlTimeAMin(cl)=ClPara(cl,'MinIntTime')*60/step;

parameter  IlTime(cl,it) '可控负荷中断时间表';

IlTime(cl,it)=ord(it)$(ord(it)<=IlTimeOMax(cl)*60/step);

clit (cl,it)=no;
clit (cl,it)=yes$(IlTime(cl,it)<>0);

table CloadP(pd,cl)     '可控负荷有功'
$include '..\data\tableCLoadP.inc'
;
parameter CloadPtemp(pd,cl);
CloadPtemp(pd,cl)=CloadP(pd,cl);

table CloadQ(pd,cl)     '可控负荷无功'
$include '..\data\tableCLoadQ.inc'
;
parameter CloadQtemp(pd,cl);
CloadQtemp(pd,cl)=CloadQ(pd,cl);
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~节点参数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parameter BusType(bus) '节点种类' /
$include '..\data\BusType.inc'
/;
parameter  Vmax(bus)   '节点电压幅值上限' /
$include '..\data\Vmax.inc'
/;
parameter  Vmin(bus)   '节点电压幅值下限'/
$include '..\data\Vmin.inc'
/;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~线路参数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
table  LinePara(line,LinePName)  '线路参数读取'
$include '..\data\tableLinePara.inc'
;
parameter  From(line)   '线路起始节点';
From(line)=LinePara(line,'From');

parameter  To(line)     '线路终止节点';
To(line)=LinePara(line,'To');

parameter  R(line)      '线路电阻';
R(line)=LinePara(line,'R');

parameter  X(line)      '线路电抗';
X(line)=LinePara(line,'X');

parameter  B(line)      '充电电纳';
B(line)=LinePara(line,'B');

parameter  State(line)  '线路状态，是否使用';
State(line)=LinePara(line,'State');

parameter  MaxPower(line) '线路最大输送功率';
MaxPower(line)=LinePara(line,'MaxPower');

*节点导纳矩阵参数定义
parameters
           Yg(line)       '线路电导'
           Yb(line)       '线路电纳'
           Yfg(line,bus)
           Yfb(line,bus)
           Ytg(line,bus)
           Ytb(line,bus)
           Yttg(line)
           Yttb(line)
           Yffg(line)
           Yffb(line)
           Yftg(line)
           Yftb(line)
           Ytfg(line)
           Ytfb(line)
           Cf(bus,line)
           Ct(bus,line)
           Bc(line)       '线路充电功率'
           Gij(bus,bus)   '节点电导'
           Bij(bus,bus)   '节点电纳'
           Am(bus,bus)    '节点导纳相角'
           Ym(bus,bus)    '节点导纳幅值'
;
*************************************************************************
*                           参 数 赋 初 值
*************************************************************************
table LoadP(pd,bus)      '不可控负荷有功'
$include '..\data\tableLoadP.inc'
;
parameter LoadPtemp(pd,bus);
LoadPtemp(pd,bus)=LoadP(pd,bus);

table LoadQ(pd,bus)      '不可控负荷无功'
$include '..\data\tableLoadQ.inc'
;
parameter LoadQtemp(pd,bus);
LoadQtemp(pd,bus)=LoadQ(pd,bus);

table UnitP0(pd,unit)    '电源有功出力初值'
$include '..\data\UnitP0.inc'
;
table UnitQ0(pd,unit)    '电源无功出力初值'
$include '..\data\UnitQ0.inc'
;
table BusV0(pd,bus)      '节点电压初值'
$include '..\data\BusV.inc'
;
table BusT0(pd,bus)      '节点相角初值'
$include '..\data\BusT.inc'
;
**************************************************************************
*                           参 数 计 算
**************************************************************************
*~~~~~~~~~~~~~~~~~~~~~~~~~~节点导纳矩阵~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*$Ontext
*增加数据判断环节
*线路导纳计算
Yg(line)=R(line)*State(line)/(R(line)*R(line)+X(line)*X(line));
Yb(line)=-X(line)*State(line)/(R(line)*R(line)+X(line)*X(line));
Bc(line)=State(line)*B(line);
*节点导纳矩阵参数计算
Yttg(line)=Yg(line);
Yttb(line)=Yb(line)+Bc(line)/2;
Yffg(line)=Yttg(line);
Yffb(line)=Yttb(line);
Yftg(line)=-Yg(line);
Yftb(line)=-Yb(line);
Ytfg(line)=-Yg(line);
Ytfb(line)=-Yb(line);

Cf(bus,line)$(ord(bus)=From(line))=1;
Ct(bus,line)$(ord(bus)=To(line))=1;

Yfg(line,bus)$(ord(bus)=From(line))=Yffg(line);
Yfb(line,bus)$(ord(bus)=From(line))=Yffb(line);
Yfg(line,bus)$(ord(bus)=To(line))=Yftg(line);
Yfb(line,bus)$(ord(bus)=To(line))=Yftb(line);

Ytg(line,bus)$(ord(bus)=From(line))=Ytfg(line);
Ytb(line,bus)$(ord(bus)=From(line))=Ytfb(line);
Ytg(line,bus)$(ord(bus)=To(line))=Yttg(line);
Ytb(line,bus)$(ord(bus)=To(line))=Yttb(line);
*节点导纳矩阵生成
Gij(bus,busj)=sum(line,Cf(bus,line)*Yfg(line,busj)+Ct(bus,line)*Ytg(line,busj));
Bij(bus,busj)=sum(line,Cf(bus,line)*Yfb(line,busj)+Ct(bus,line)*Ytb(line,busj));
*$Offtext
*~~~~~~~~~~~~~~~~~~~~~~~节点导纳矩阵转化~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*$Ontext
Ym(bus,busj)=sqrt(power(Gij(bus,busj),2)+power(Bij(bus,busj),2))$(Gij(bus,busj)<>0 or Bij(bus,busj)<>0);
*第一象限、第四象限
Am(bus,busj)$(Gij(bus,busj)>0)=arctan(Bij(bus,busj)/Gij(bus,busj));
*第二象限、第三象限
Am(bus,busj)$(Gij(bus,busj)<0)=arctan(Bij(bus,busj)/Gij(bus,busj))+pi;
*坐标轴上方
Am(bus,busj)$((Gij(bus,busj)=0) and (Bij(bus,busj)>0))=pi/2;
*坐标轴下方
Am(bus,busj)$((Gij(bus,busj)=0) and (Bij(bus,busj)<0))=-pi/2;
*$Offtext

**************************************************************************
*                           变 量 定 义
**************************************************************************
Variables
*~~~~~~~~~~~~~~~~~~~~~~~~~~目标函数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Obj                     '目标变量'
BuyCost                 '购电成本'
*~~~~~~~~~~~~~~~~~~~~~~~~~控制变量~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
P(pd,unit)              '发电机有功出力'
Q(pd,unit)              '发电机无功出力'
EssCharP(pd,ess)        '储能系统充电功率'
EssDiscP(pd,ess)        '储能系统放电功率'
SoCini(pd,ess)          '储能系统该时刻初始荷电状态'
SoCend(pd,ess)          '储能系统该时刻最终荷电状态'
SoMPA(pd,ess)           '储能电池最大充放电功率，MW'
IloadP(pd,cl)           '可中断负荷有功出力'
IloadQ(pd,cl)           '可中断负荷无功出力'
Iltimeone(pd,cl)        '可中断负荷持续停电时间'
Ilfreq(cl)              '可中断负荷中断次数'
;
Binary Variables
CharState(pd,ess)       '储能电池充电状态'
DisCState(pd,ess)       '储能电池放电状态'
ILState(pd,cl)          '可中断负荷状态'
;
Integer Variable
OLTCk(pd)               '有载调压变变比k'
;
Variables
*~~~~~~~~~~~~~~~~~~~~~~~~节点相关变量~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Vm(pd,bus)              '节点电压幅值'
Va(pd,bus)              '节点电压相角'
Ve(pd,bus)              '节点电压实部'
Vf(pd,bus)              '节点电压虚部'
BusInP(pd,bus)          '节点注入有功'
BusInQ(pd,bus)          '节点注入无功'
OtherBusP(pd,bus)       '相邻节点注入有功功率'
OtherBusQ(pd,bus)       '相邻节点注入无功功率'
*~~~~~~~~~~~~~~~~~~~~~~~线路相关变量~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Iij(pd,bus,Busj)        '线路电流幅值'
LineInP(pd,bus,Busj)    '输电线路有功,节点表示'
LineInPL(pd,line)       '输电线路有功,线路表示'
LineInQ(pd,bus,Busj)    '输电线路无功,节点表示'
LineVdrop2(pd,line)     '线路压降'
LineLossP(pd,line)      '线损，有功'
LineLossQ(pd,line)      '线损，无功'
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~设定变量上下限~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

P.lo(pd,unit)=Pmin(pd,unit)/BasePower;
P.up(pd,unit)=Pmax(pd,unit)/BasePower;
Q.lo(pd,unit)=Qmin(pd,unit)/BasePower;
Q.up(pd,unit)=Qmax(pd,unit)/BasePower;
Vm.lo(pd,bus)=Vmin(bus);
Vm.up(pd,bus)=Vmax(bus);
LineInPL.up(pd,line)=MaxPower(line)/BasePower;
IloadP.l(pd,cl)=CloadP(pd,cl);
OLTCk.lo(pd)=-8;
OLTCk.up(pd)=8;
SoCini.up(pd,ess)=1;
SoCini.lo(pd,ess)=1-EssDOD(ess);
SoCend.up(pd,ess)=1;
SoCend.lo(pd,ess)=1-EssDOD(ess);
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~设定变量初值~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

P.l(pd,unit)=UnitP0(pd,unit)/BasePower;
Q.l(pd,unit)=UnitQ0(pd,unit)/BasePower;
Vm.l(pd,bus)=BusV0(pd,bus);
Va.l(pd,bus)=BusT0(pd,bus);
LineLossP.l(pd,line)=0;
Obj.l=sum((pd,line),LineLossP.l(pd,line)*BasePower*(step/60));
BuyCost.l=sum((pd,unit,cl),(C(pd,unit)*P.l(pd,unit)+ClCost(cl)*(CloadP(pd,cl)-IloadP.l(pd,cl)))*BasePower)*(step/60);

**************************************************************************
*                              方 程 定 义
**************************************************************************
Equations
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~目标函数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ObjFunc                        '目标函数'
BuyElecCost                    '购电成本'
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~节点变量定义~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BusActivePower(pd,bus)         '节点注入有功'
BusReactivePow(pd,bus)         '节点注入无功'
OtherBusInPower(pd,bus)        '相邻节点注入有功功率'
OtherBusInRepower(pd,bus)      '相邻节点注入无功功率'
RealVoltage(pd,bus)            '节点电压实部值定义'
ImagVoltage(pd,bus)            '节点电压虚部值定义'

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~线路变量定义~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LineActivePower(pd,bus,Busj)   '线路注入有功'
LineActivePowerL(pd,line)      '线路功率,线路表示'
VoltageDroponLine(pd,line)     '线路压降平方'
LineLossPower(pd,line)         '输电线路有功损耗U^2Yg'
LineLossRepower(pd,line)       '输电线路无功损耗U^2Yb'

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~约束条件~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*储能电池约束
ESSState(pd,ess)               '储能充放电状态约束'

ESSCharMAXP(pd,ess)            '储能电池最大充电功率'
ESSCharMinP(pd,ess)            '储能电池最小充电功率'
ESSDisMAXP(pd,ess)             '储能电池最大放电功率'
ESSDisMinP(pd,ess)             '储能电池最小放电功率'

SOCDef0(pd,ess)                '储能SOC定义,第一个点'
SOCDef(pd,ess)                 '储能SOC定义,其余点'
SOClink(pd,ess)                '储能SOC连接'

*可中断负荷约束
ILOutPutP(pd,cl)               '可中断负荷实际有功'
ILOutPutQ(pd,cl)               '可中断负荷实际无功'
*IntFrequence1(cl)              '可中断负荷中断次数定义'
*IntFrequence2(cl)              '可中断负荷中断次数约束'
IntTimeOnce1(pd,cl)            '可中断负荷单次中断时间定义'
IntTimeOnce2(pd,cl)            '可中断负荷单次中断时间约束'
IntTimeALLMax(cl)              '可中断负荷总计最大中断时间'
IntTimeALLMin(cl)              '可中断负荷总计最小中断时间'
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~潮流约束~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DeltaP(pd,bus)                 '潮流等式约束-有功'
DeltaQ(pd,bus)                 '潮流等式约束-无功'
SlackbusT(pd,bus)              '平衡节点相角约束'
OLTCVoltage(pd,bus)            '有载调压变压器低压侧电压'
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~目 标 函 数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ObjFunc
.. Obj=E=sum((pd,line),LineLossP(pd,line)*BasePower*(step/60))
;
BuyElecCost
.. BuyCost=E=sum((pd,unit,cl),(C(pd,unit)*P(pd,unit)+ClCost(cl)*(CloadP(pd,cl)-IloadP(pd,cl)))*BasePower)*(step/60)
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~储 能 系 统~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*储能充放电状态约束
ESSState(pd,ess)
..CharState(pd,ess)+DisCState(pd,ess)=l=1
;
*储能电池最大充电功率
ESSCharMAXP(pd,ess)
.. EssCharP(pd,ess)=l=CharState(pd,ess)*EssMaxCP(ess)/BasePower
;
*储能电池最小充电功率
ESSCharMinP(pd,ess)
.. ESSCharP(pd,ess)=g=CharState(pd,ess)*EssMinCP(ess)/BasePower
;
*储能电池最大放电功率
ESSDisMAXP(pd,ess)
.. EssDiscP(pd,ess)=l=DisCState(pd,ess)*EssMaxDP(ess)/BasePower
;
*储能电池最小放电功率
ESSDisMinP(pd,ess)
.. EssDiscP(pd,ess)=g=DisCState(pd,ess)*0/BasePower
;
*储能SOC计算
SOCDef0(pd,ess)$(ord(pd)=1)
..SoCini(pd,ess)=e= EssSOC0(ess)
;
SOCDef(pd,ess)
..SoCend(pd,ess)=e=SoCini(pd,ess)+EssCharP(pd,ess)*BasePower*EssCRate(ess)*(step/60)/EssCap(ess)
                -EssDiscP(pd,ess)*BasePower/EssDRate(ess)*(step/60)/EssCap(ess)
;
SOClink(pd,ess)$(ord(pd)>1)
..SOCini(pd,ess)=e=SOCend(pd-1,ess)
;

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~可 中 断 负 荷~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*可中断负荷出力
ILOutPutP(pd,cl)
..IloadP(pd,cl)=e=ILState(pd,cl)*CloadP(pd,cl)
;
ILOutPutQ(pd,cl)
..IloadQ(pd,cl)=e=ILState(pd,cl)*CloadQ(pd,cl)
;
$ontext
*可中断负荷中断次数约束
IntFrequence1(cl)
..sum(pd$(ord(pd)>1),(ILState(pd-1,cl) xor ILState(pd,cl)) and (not ILState(pd,cl)))=e=Ilfreq(cl)
;

IntFrequence2(cl)
..Ilfreq(cl)=l=ClMaxFreq(cl)
;
$offtext
*可中断负荷单次中断持续时间
IntTimeOnce1(pd,cl)$(ord(pd)>IlTimeOMax(cl)*60/step)
..sum(it$(clit(cl,it)),ILState(pd-IlTime(cl,it),cl))=e=Iltimeone(pd,cl)
;
IntTimeOnce2(pd,cl)$(ord(pd)>IlTimeOMax(cl)*60/step)
..Iltimeone(pd,cl)=g=1
;

IntTimeALLMax(cl)
..card(pd)-sum(pd,ILState(pd,cl))=l=IlTimeAMax(cl)
;

IntTimeALLMin(cl)
..card(pd)-sum(pd,ILState(pd,cl))=g=IlTimeAMin(cl)
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~中 间 变 量 赋 值~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*节点电压实部值定义
RealVoltage(pd,bus)
.. Ve(pd,bus)=e=Vm(pd,bus)*cos(Va(pd,bus))
;
*节点电压虚部值定义
ImagVoltage(pd,bus)
.. Vf(pd,bus)=e=Vm(pd,bus)*sin(Va(pd,bus))
;
*线路压降定义
VoltageDroponLine(pd,line)
..LineVdrop2(pd,line)=e=sum(bus$(From(line)=ord(Bus)),Vm(pd,bus))**2+sum(bus$(To(line)=ord(Bus)),Vm(pd,bus))**2
                     -2*sum(bus$(From(line)=ord(Bus)),Vm(pd,bus))*sum(bus$(To(line)=ord(Bus)),Vm(pd,bus))*cos(sum(bus$(From(line)=ord(Bus)),Va(pd,bus))-sum(bus$(To(line)=ord(Bus)),Va(pd,bus)))
;

*节点注入有功
BusActivePower(pd,bus)
.. BusInP(pd,bus)=e=sum(Unit$(GenBus(Unit)=ord(Bus)),P(pd,unit))
                   +sum(ess$(EssBus(ess)=ord(Bus)),EssDiscP(pd,ess)-EssCharP(pd,ess))
                   -(LoadP(pd,bus)+sum(cl$(ClBus(cl)=ord(Bus)),IloadP(pd,cl)))/BasePower
;
*节点注入无功
BusReactivePow(pd,bus)
.. BusInQ(pd,bus)=e=sum(Unit$(GenBus(Unit)=ord(Bus)),Q(pd,unit))
                   -(LoadQ(pd,bus)+sum(cl$(ClBus(cl)=ord(Bus)),IloadQ(pd,cl)))/BasePower
;
*输电线路有功损耗
LineLossPower(pd,line)
.. LineLossP(pd,line)=e=LineVdrop2(pd,line)*Yg(line)
;
*输电线路无功损耗
LineLossRepower(pd,line)
.. LineLossQ(pd,line)=e=-LineVdrop2(pd,line)*Yb(line)
;
*线路有功组
LineActivePower(pd,bus,Busj)
.. LineInP(pd,bus,Busj)=e=Vm(pd,bus)*Vm(pd,Busj)*(Gij(bus,Busj)*cos(Va(pd,bus)-Va(pd,Busj))+Bij(bus,Busj)*sin(Va(pd,bus)-Va(pd,Busj)))
-Vm(pd,bus)*Vm(pd,bus)*Gij(bus,Busj)
;
LineActivePowerL(pd,line)
.. LineInPL(pd,line)=e=sum(bus$(ord(bus)=From(line)),sum(busj$(ord(busj)=To(line)),LineInP(pd,bus,busj)))
;
*相邻节点注入有功功率
OtherBusInPower(pd,bus)
.. OtherBusP(pd,bus)=e=Vm(pd,bus)*sum( Busj$(Gij(bus,busj)<>0 or Bij(bus,busj)<>0 ),
Vm(pd,Busj)*(Gij(bus,Busj)*cos(Va(pd,bus)-Va(pd,Busj))+Bij(bus,Busj)*sin(Va(pd,bus)-Va(pd,Busj))))
;
*相邻节点注入无功功率
OtherBusInRepower(pd,bus)
.. OtherBusQ(pd,bus)=e=Vm(pd,bus)*sum(Busj,
Vm(pd,Busj)*(Gij(bus,Busj)*sin(Va(pd,bus)-Va(pd,Busj))-Bij(bus,Busj)*cos(Va(pd,bus)-Va(pd,Busj))))
;

*~~~~~~~~~~~~~~~~~~~~~~~~~~~潮 流 等 式 约 束~~~~~~~~~~~~~~~~~~~~~~~~~~~
*$ontext
*节点有功平衡
DeltaP(pd,bus)
.. BusInP(pd,bus)-OtherBusP(pd,bus)=e=0
;
*节点无功平衡
DeltaQ(pd,bus)
.. BusInQ(pd,bus)-OtherBusQ(pd,bus)=e=0
;
*$offtext
*平衡节点相角约束
SlackbusT(pd,bus)$(BusType(bus)=3)
.. Va(pd,bus)=e=0
;
*有载调压变压器低压侧电压
OLTCVoltage(pd,bus)$(ord(bus)=1)
..Vm(pd,bus)=e=1+0.00125*OLTCk(pd)
;

**************************************************************************
*                           指 标 计 算
**************************************************************************
*~~~~~~~~~~~~~~~~~~~~~~~~~指标参数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parameters
Networkloss            '网损'
CEConsum               '清洁能源消纳率'
CLStaterate            '可控负荷静态比率'
CLDynrate              '可控负荷动态比率'
DGStatePene            '间歇式电源静态渗透率指标'
DGDynPene              '间歇式电源有效渗透率'

;

**************************************************************************
*                             求 解 设 置
**************************************************************************
OPTION MINLP = DICOPT;
OPTION NLP = IPOPTH;
OPTION MIP = cplex;

MODEL ADSSchedule   '源网荷协调优化模型'
/ObjFunc, BusActivePower, BusReactivePow, OtherBusInPower, OtherBusInRepower,
RealVoltage,ImagVoltage, LineActivePower, LineActivePowerL, VoltageDroponLine,
LineLossPower, LineLossRepower, ESSState, ESSCharMAXP, ESSCharMinP, ESSDisMAXP,
ESSDisMinP, SOCDef0, SOCDef, SOClink, ILOutPutP, ILOutPutQ,
IntTimeALLMax,DeltaP, DeltaQ, SlackbusT, OLTCVoltage
/;

set i  '选取的可中断负荷' /1*8/;

parameter  Clnow(bus,pd,i)   '测试';
parameter ESSposition(i)  '储能系统位置';


parameters resobj(i)      '并行计算网损结果'
           resbuycost(i)   '并行计算购电成本'
           resp(unit,pd,i)  '并行计算发电机有功结果'
           resSoCini(ess,pd,i) '并行计算储能SOC结果'
           resEssCharP(ess,pd,i)  '并行计算储能充电功率结果'
           resEssDiscP(ess,pd,i)  '并行计算储能放电功率结果'
           resCharState(ess,pd,i)  '储能充电状态结果'
           resDiscState(ess,pd,i)  '储能放电状态结果'
           resIloadP(cl,pd,i) '并行计算可中断负荷出力结果'
           resVm(bus,pd,i) '并行计算节点电压结果'
           resVdiv(bus,i)  '最大电压偏移'
           resOLTCk(pd,i)  '并行计算变比结果'
           resNetworkloss(i) '并行计算网损结果'
           reslineloss(line,i) '并行计算线路网损结果'
           resCEConsum(i)  '清洁能源消纳率'
           resCLStaterate(i)  '可控负荷静态比率'
           resCLDynrate(i)    '可控负荷动态比率'
           resDGStatePene(i)  '间歇式电源静态渗透率指标'
           resDGDynPene(i)    '间歇式电源有效渗透率'
           resLoadstate(cl,pd,i)
;

parameter h(i) model handels;
ADSSchedule.solvelink=3;
loop(i,
    clinuse(cl)=1$(ord(cl)=ord(i));

    IlTimeAMax(cl)$(ord(cl)=ord(i))=2*60/step;
    CloadP(pd,cl)=CloadPtemp(pd,cl)*clinuse(cl);
    CloadQ(pd,cl)=CloadQtemp(pd,cl)*clinuse(cl);
    LoadP(pd,bus)=LoadPtemp(pd,bus);
    LoadP(pd,bus)$(ord(bus)=sum(cl$(ord(cl)=ord(i)),ClBus(cl)))=0;
    LoadQ(pd,bus)=LoadQtemp(pd,bus);
    LoadQ(pd,bus)$(ord(bus)=sum(cl$(ord(cl)=ord(i)),ClBus(cl)))=0;

    SOLVE ADSSchedule using MINLP minimizing Obj;

    h(i)=ADSSchedule.handle
);

Repeat
    loop(i$handlecollect(h(i)),
    resobj(i)=obj.l;
    resp(unit,pd,i)=P.l(pd,unit)*MW2kW;
    resSoCini(ess,pd,i)=SoCini.l(pd,ess);
    resCharState(ess,pd,i)=CharState.l(pd,ess);
    resDiscState(ess,pd,i)=DiscState.l(pd,ess);
    resEssCharP(ess,pd,i)=EssCharP.l(pd,ess)*MW2kW;
    resEssDiscP(ess,pd,i)=EssDiscP.l(pd,ess)*MW2kW;
    resIloadP(cl,pd,i)=IloadP.l(pd,cl)*MW2kW;
    resVm(bus,pd,i)=Vm.l(pd,bus);
    resVdiv(bus,i)=max(abs((smax(pd,Vm.l(pd,bus))-1)),abs(smin(pd,Vm.l(pd,bus))-1))*100;
    resOLTCk(pd,i)=OLTCk.l(pd);
    resNetworkloss(i)=sum((pd,line),LineLossP.l(pd,line)*BasePower*(step/60))*MW2kW;
    reslineloss(line,i)=sum(pd,LineLossP.l(pd,line)*BasePower*(step/60))*MW2kW;
    resCEConsum(i)=sum((pd,pv(unit)),P.l(pd,unit))/sum((pd,pv(unit)),Pmax(pd,unit)/BasePower);
    resCLStaterate(i)=smax(pd,sum(cl,CloadP(pd,cl)))/(smax(pd,sum(bus,loadP(pd,bus))+sum(cl,CloadP(pd,cl))));
    resCLDynrate(i)=sum((pd,cl),IloadP.l(pd,cl))/(sum((pd,cl),CloadP(pd,cl)))$((sum((pd,cl),CloadP(pd,cl))<>0));
    resDGStatePene(i)=sum(pv,PVCap(pv))/(smax(pd,sum(bus,loadP(pd,bus))+sum(cl,CloadP(pd,cl))));
    resDGDynPene(i)=sum((pd,pv(unit)),P.l(pd,unit))*BasePower/sum((pd,bus),LoadP(pd,bus)+sum(cl$(ClBus(cl)=ord(Bus)),IloadP.l(pd,cl)));
    resbuycost(i)=BuyCost.l;
    resLoadstate(cl,pd,i)=ILState.l(pd,cl);
    display $handledelete(h(i)) 'trouble deleting handles';
    h(i)=0
);
    display $sleep(card(h)*0.2) 'sleep sometime';
until card(h)=0 or timeelapsed>100;
resobj(i)$h(i)=na;


**************************************************************************
*                             结 果 输 出
**************************************************************************
*~~~~~~~~~~~~~~~~~~~~~~~~~~标幺值转化为有名值~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
P.l(pd,unit)=P.l(pd,unit)*BasePower;
Q.l(pd,unit)=Q.l(pd,unit)*BasePower;
BusInP.l(pd,bus)=BusInP.l(pd,bus)*BasePower;
OtherBusP.l(pd,bus)=OtherBusP.l(pd,bus)*BasePower;
LineInP.l(pd,bus,Busj)=LineInP.l(pd,bus,Busj)*BasePower;
LineInPL.l(pd,line)= LineInPL.l(pd,line)*BasePower;
LineLossP.l(pd,line)=LineLossP.l(pd,line)*BasePower;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~屏 显 结 果~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DISPLAY
Obj.l
LoadP
CloadP
resobj
resCEConsum
resDGDynPene
resp
resLoadstate
P.l
Q.l
Vm.l
Va.l
SoCini.l
SoCend.l
CharState.l
DisCState.l
EssCharP.l
EssDiscP.l
ILState.l
IloadP.l
OLTCk.l

*$Ontext
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~文 件 输 出~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*=== Export to Excel using GDX utilities
*=== First unload to GDX file (occurs during execution phase)
execute_unload "results$1.gdx" resObj,resP,resSoCini,resEssCharP,resEssDiscP,resIloadP,resVm,resOLTCk,
resCEConsum,resCLStaterate,resCLDynrate,resDGStatePene,resDGDynPene,resNetworkloss,reslineloss,
resCharState,resDiscState,resbuycost,resVdiv,resLoadstate;
*=== Now write to variable levels to Excel file from GDX
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe results$1.gdx par=resNetworkloss rng=网损指标!';

execute 'gdxxrw.exe results$1.gdx par=resCEConsum rng=清洁能源消纳率!';

execute 'gdxxrw.exe results$1.gdx par=resCLStaterate rng=可控负荷静态比率!';

execute 'gdxxrw.exe results$1.gdx par=resCLDynrate rng=可控负荷动态比率!';

execute 'gdxxrw.exe results$1.gdx par=resDGStatePene rng=间歇式电源静态渗透率指标!';

execute 'gdxxrw.exe results$1.gdx par=resDGDynPene rng=间歇式电源有效渗透率!';

execute 'gdxxrw.exe results$1.gdx par=resobj rng=目标函数!';

execute 'gdxxrw.exe results$1.gdx par=reslineloss rng=各线路网损!';

execute 'gdxxrw.exe results$1.gdx par=resP rng=发电机有功出力!';

execute 'gdxxrw.exe results$1.gdx par=resSoCini rng=SOC!';

execute 'gdxxrw.exe results$1.gdx par=resCharState rng=储能充电状态!';

execute 'gdxxrw.exe results$1.gdx par=resDiscState rng=储能放电状态!';

execute 'gdxxrw.exe results$1.gdx par=resEssCharP rng=储能充电功率!';

execute 'gdxxrw.exe results$1.gdx par=resEssDiscP rng=储能放电功率!';

execute 'gdxxrw.exe results$1.gdx par=resIloadP rng=可中断负荷功率!';

execute 'gdxxrw.exe results$1.gdx par=resLoadstate rng=可中断负荷状态!';

execute 'gdxxrw.exe results$1.gdx par=resVm rng=节点电压!';

execute 'gdxxrw.exe results$1.gdx par=resVdiv rng=节点电压偏移!';

execute 'gdxxrw.exe results$1.gdx par=resOLTCk rng=变压器抽头位置!';

execute 'gdxxrw.exe results$1.gdx par=resbuycost rng=购电成本!';
*$Offtext


