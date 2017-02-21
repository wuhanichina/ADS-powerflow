*************************************************************************
*************************************************************************
*                              Դ����Э������  V1.0 MINLP
*                                               Written by Wuhan in Hohai
*************************************************************************
*************************************************************************
$Ontext
����MINLP��Դ����Э�����Ƴ���
�����ֲ�ʽ��Դ�����ܣ����жϸ��ɣ���ѹ�����
��������ã��Ƽ������ DICOPT
$Offtext
*************************************************************************
*                              �� �� �� ��
*************************************************************************
set bus           '�ڵ�' /
$include '..\data\setbus.inc'
/;
set unit          '��Դ' /
$include '..\data\setunit.inc'
/
    pv(unit)      '�����Դ' /i2/
;
set ess           '����' /
$include '..\data\setess.inc'
/
;
set cl            '�ɿظ���' /
$include '..\data\setcl.inc'
/
    il(cl)        '���жϸ���' /cl1/
;
set line          '��·' /
$include '..\data\setline.inc'
/;
set pd            '����ʱ����' /
$include '..\data\sett.inc'
/;
set it            '���ɿ��ж�ʱ��' /
$include '..\data\setit.inc'
/
    cluseit(it)   'ÿ���ɿظ��ɵ��ж�ʱ��,�Ӽ�'
;
set clit (cl,it)  'ÿ���ɿظ��ɶ�Ӧ���ж�ʱ��'
;
set PVPName       '���ϵͳ������Ϣ' /
$include '..\data\setPVPName.inc'
/;
set EssPName      '����ϵͳ������Ϣ' /
$include '..\data\setEssPName.inc'
/;
set ClPName       '�ɿظ��ɲ�����Ϣ' /
$include '..\data\setClPName.inc'
/;
set LinePName     '��·������Ϣ' /
$include '..\data\setLinePName.inc'
/;
*set UnitPName     '�����������Ϣ' /
*$include '..\data\setUnitPName.inc'
*/;
alias(Bus,Busj);
*************************************************************************
*                           �� �� �� �� �� ��
*************************************************************************
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~���������趨~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Scalar pi /3.14159/
;
Scalar MW2kW /1000/
;
scalar step          '���沽��,����'/
$include '..\data\step.inc'
/;
Scalar BasePower     '��׼����,MW'/
$include '..\data\BasePower.inc'
/;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~�����Բ���~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
table C(pd,unit)     'ÿMWh�ɱ�,Ԫ/MWh'
$include '..\data\Cost.inc'
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~���������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parameter GenBus(unit)'��Դ��Ӧ�Ľڵ�'/
$include '..\data\PowerBus.inc'
/;
table Pmax(pd,unit)  '��Դ�����й�����ֵ�����ޣ�'
$include '..\data\UnitPmax.inc'
;
table Pmin(pd,unit)  '��Դ�����й�����ֵ�����ޣ�'
$include '..\data\UnitPmin.inc'
;
table Qmax(pd,unit)  '��Դ�����޹�����ֵ�����ޣ�'
$include '..\data\UnitQmax.inc'
;
table Qmin(pd,unit)  '��Դ�����޹�����ֵ�����ޣ�'
$include '..\data\UnitQmin.inc'
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~�������ϵͳ����~~~~~~~~~~~~~~~~~~~~~~~~~~~~
table PVPara(pv,PVPName) '�������ϵͳ������ȡ'
$include '..\data\tablePVPara.inc'
;
parameter  PVCap(pv)    '�����������,MWp';
PVCap(pv)=PVPara(pv,'Cap');
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~����ϵͳ����~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
table EssPara(ess,EssPName) '���ܲ�����ȡ'
$include '..\data\tableEssPara.inc'
;
parameter  EssBus(ess)    '����ϵͳ��Ӧ�Ľڵ�';
EssBus(ess)=EssPara(ess,'InBus');

parameter  EssCap(ess)    '���ܵ������,MWh';
EssCap(ess)=EssPara(ess,'Cap');

parameter  EssMaxCP(ess)  '��������繦��,MW';
EssMaxCP(ess)=EssPara(ess,'MaxCharP');

parameter  EssMaxDP(ess)  '�������ŵ繦��,MW';
EssMaxDP(ess)=EssPara(ess,'MaxDisCharP');

parameter  EssMinCP(ess)  '������С��繦��,MW';
EssMinCP(ess)=EssPara(ess,'MinCharP');

parameter  EssCRate(ess)  '���ܳ��Ч��';
EssCRate(ess)=EssPara(ess,'CharRate');

parameter  EssDRate(ess)  '���ܷŵ�Ч��';
EssDRate(ess)=EssPara(ess,'DisRate');

parameter  EssDOD(ess)    '���ܷŵ����';
EssDOD(ess)=EssPara(ess,'DOD');

parameter  EssSOH0(ess)   '���ܳ�ʼSOH';
EssSOH0(ess)=EssPara(ess,'SOH0');

parameter  EssSOC0(ess)   '���ܳ�ʼSOC';
EssSOC0(ess)=EssPara(ess,'SOC0');

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~�ɿظ��ɲ���~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
table ClPara(cl,ClPName) '�ɿظ��ɲ�����ȡ'
$include '..\data\tableClPara.inc'
;
parameter clinuse(cl)     '���ÿ��жϸ���';

parameter  ClBus(cl)     '�ɿظ������ڵĽڵ�';
ClBus(cl)=ClPara(cl,'InBus');

parameter  ClCost(cl)    '�ɿظ��ɵ��ȳɱ�,Ԫ/MWh';
ClCost(cl)=ClPara(cl,'Cost');

parameter  ClMaxFreq(cl) '�ɿظ�������жϴ���';
ClMaxFreq(cl)=ClPara(cl,'MaxFreq');

parameter  IlTimeOMax(cl) '�ɿظ��ɵ�������ж�ʱ��,Сʱ';
IlTimeOMax(cl)=ClPara(cl,'MaxOnceTime');

parameter  IlTimeAMax(cl) '�ɿظ����ܼ�����ж�ʱ��,Сʱ';
IlTimeAMax(cl)=ClPara(cl,'MaxTime')*60/step;

parameter  IlTimeAMin(cl) '�ɿظ����ܼ���С�ж�ʱ��,Сʱ';
IlTimeAMin(cl)=ClPara(cl,'MinIntTime')*60/step;

parameter  IlTime(cl,it) '�ɿظ����ж�ʱ���';

IlTime(cl,it)=ord(it)$(ord(it)<=IlTimeOMax(cl)*60/step);

clit (cl,it)=no;
clit (cl,it)=yes$(IlTime(cl,it)<>0);

table CloadP(pd,cl)     '�ɿظ����й�'
$include '..\data\tableCLoadP.inc'
;
parameter CloadPtemp(pd,cl);
CloadPtemp(pd,cl)=CloadP(pd,cl);

table CloadQ(pd,cl)     '�ɿظ����޹�'
$include '..\data\tableCLoadQ.inc'
;
parameter CloadQtemp(pd,cl);
CloadQtemp(pd,cl)=CloadQ(pd,cl);
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~�ڵ����~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parameter BusType(bus) '�ڵ�����' /
$include '..\data\BusType.inc'
/;
parameter  Vmax(bus)   '�ڵ��ѹ��ֵ����' /
$include '..\data\Vmax.inc'
/;
parameter  Vmin(bus)   '�ڵ��ѹ��ֵ����'/
$include '..\data\Vmin.inc'
/;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~��·����~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
table  LinePara(line,LinePName)  '��·������ȡ'
$include '..\data\tableLinePara.inc'
;
parameter  From(line)   '��·��ʼ�ڵ�';
From(line)=LinePara(line,'From');

parameter  To(line)     '��·��ֹ�ڵ�';
To(line)=LinePara(line,'To');

parameter  R(line)      '��·����';
R(line)=LinePara(line,'R');

parameter  X(line)      '��·�翹';
X(line)=LinePara(line,'X');

parameter  B(line)      '������';
B(line)=LinePara(line,'B');

parameter  State(line)  '��·״̬���Ƿ�ʹ��';
State(line)=LinePara(line,'State');

parameter  MaxPower(line) '��·������͹���';
MaxPower(line)=LinePara(line,'MaxPower');

*�ڵ㵼�ɾ����������
parameters
           Yg(line)       '��·�絼'
           Yb(line)       '��·����'
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
           Bc(line)       '��·��繦��'
           Gij(bus,bus)   '�ڵ�絼'
           Bij(bus,bus)   '�ڵ����'
           Am(bus,bus)    '�ڵ㵼�����'
           Ym(bus,bus)    '�ڵ㵼�ɷ�ֵ'
;
*************************************************************************
*                           �� �� �� �� ֵ
*************************************************************************
table LoadP(pd,bus)      '���ɿظ����й�'
$include '..\data\tableLoadP.inc'
;
parameter LoadPtemp(pd,bus);
LoadPtemp(pd,bus)=LoadP(pd,bus);

table LoadQ(pd,bus)      '���ɿظ����޹�'
$include '..\data\tableLoadQ.inc'
;
parameter LoadQtemp(pd,bus);
LoadQtemp(pd,bus)=LoadQ(pd,bus);

table UnitP0(pd,unit)    '��Դ�й�������ֵ'
$include '..\data\UnitP0.inc'
;
table UnitQ0(pd,unit)    '��Դ�޹�������ֵ'
$include '..\data\UnitQ0.inc'
;
table BusV0(pd,bus)      '�ڵ��ѹ��ֵ'
$include '..\data\BusV.inc'
;
table BusT0(pd,bus)      '�ڵ���ǳ�ֵ'
$include '..\data\BusT.inc'
;
**************************************************************************
*                           �� �� �� ��
**************************************************************************
*~~~~~~~~~~~~~~~~~~~~~~~~~~�ڵ㵼�ɾ���~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*$Ontext
*���������жϻ���
*��·���ɼ���
Yg(line)=R(line)*State(line)/(R(line)*R(line)+X(line)*X(line));
Yb(line)=-X(line)*State(line)/(R(line)*R(line)+X(line)*X(line));
Bc(line)=State(line)*B(line);
*�ڵ㵼�ɾ����������
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
*�ڵ㵼�ɾ�������
Gij(bus,busj)=sum(line,Cf(bus,line)*Yfg(line,busj)+Ct(bus,line)*Ytg(line,busj));
Bij(bus,busj)=sum(line,Cf(bus,line)*Yfb(line,busj)+Ct(bus,line)*Ytb(line,busj));
*$Offtext
*~~~~~~~~~~~~~~~~~~~~~~~�ڵ㵼�ɾ���ת��~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*$Ontext
Ym(bus,busj)=sqrt(power(Gij(bus,busj),2)+power(Bij(bus,busj),2))$(Gij(bus,busj)<>0 or Bij(bus,busj)<>0);
*��һ���ޡ���������
Am(bus,busj)$(Gij(bus,busj)>0)=arctan(Bij(bus,busj)/Gij(bus,busj));
*�ڶ����ޡ���������
Am(bus,busj)$(Gij(bus,busj)<0)=arctan(Bij(bus,busj)/Gij(bus,busj))+pi;
*�������Ϸ�
Am(bus,busj)$((Gij(bus,busj)=0) and (Bij(bus,busj)>0))=pi/2;
*�������·�
Am(bus,busj)$((Gij(bus,busj)=0) and (Bij(bus,busj)<0))=-pi/2;
*$Offtext

**************************************************************************
*                           �� �� �� ��
**************************************************************************
Variables
*~~~~~~~~~~~~~~~~~~~~~~~~~~Ŀ�꺯��~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Obj                     'Ŀ�����'
BuyCost                 '����ɱ�'
*~~~~~~~~~~~~~~~~~~~~~~~~~���Ʊ���~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
P(pd,unit)              '������й�����'
Q(pd,unit)              '������޹�����'
EssCharP(pd,ess)        '����ϵͳ��繦��'
EssDiscP(pd,ess)        '����ϵͳ�ŵ繦��'
SoCini(pd,ess)          '����ϵͳ��ʱ�̳�ʼ�ɵ�״̬'
SoCend(pd,ess)          '����ϵͳ��ʱ�����պɵ�״̬'
SoMPA(pd,ess)           '���ܵ������ŵ繦�ʣ�MW'
IloadP(pd,cl)           '���жϸ����й�����'
IloadQ(pd,cl)           '���жϸ����޹�����'
Iltimeone(pd,cl)        '���жϸ��ɳ���ͣ��ʱ��'
Ilfreq(cl)              '���жϸ����жϴ���'
;
Binary Variables
CharState(pd,ess)       '���ܵ�س��״̬'
DisCState(pd,ess)       '���ܵ�طŵ�״̬'
ILState(pd,cl)          '���жϸ���״̬'
;
Integer Variable
OLTCk(pd)               '���ص�ѹ����k'
;
Variables
*~~~~~~~~~~~~~~~~~~~~~~~~�ڵ���ر���~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Vm(pd,bus)              '�ڵ��ѹ��ֵ'
Va(pd,bus)              '�ڵ��ѹ���'
Ve(pd,bus)              '�ڵ��ѹʵ��'
Vf(pd,bus)              '�ڵ��ѹ�鲿'
BusInP(pd,bus)          '�ڵ�ע���й�'
BusInQ(pd,bus)          '�ڵ�ע���޹�'
OtherBusP(pd,bus)       '���ڽڵ�ע���й�����'
OtherBusQ(pd,bus)       '���ڽڵ�ע���޹�����'
*~~~~~~~~~~~~~~~~~~~~~~~��·��ر���~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Iij(pd,bus,Busj)        '��·������ֵ'
LineInP(pd,bus,Busj)    '�����·�й�,�ڵ��ʾ'
LineInPL(pd,line)       '�����·�й�,��·��ʾ'
LineInQ(pd,bus,Busj)    '�����·�޹�,�ڵ��ʾ'
LineVdrop2(pd,line)     '��·ѹ��'
LineLossP(pd,line)      '�����й�'
LineLossQ(pd,line)      '�����޹�'
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~�趨����������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~�趨������ֵ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

P.l(pd,unit)=UnitP0(pd,unit)/BasePower;
Q.l(pd,unit)=UnitQ0(pd,unit)/BasePower;
Vm.l(pd,bus)=BusV0(pd,bus);
Va.l(pd,bus)=BusT0(pd,bus);
LineLossP.l(pd,line)=0;
Obj.l=sum((pd,line),LineLossP.l(pd,line)*BasePower*(step/60));
BuyCost.l=sum((pd,unit,cl),(C(pd,unit)*P.l(pd,unit)+ClCost(cl)*(CloadP(pd,cl)-IloadP.l(pd,cl)))*BasePower)*(step/60);

**************************************************************************
*                              �� �� �� ��
**************************************************************************
Equations
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Ŀ�꺯��~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ObjFunc                        'Ŀ�꺯��'
BuyElecCost                    '����ɱ�'
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~�ڵ��������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BusActivePower(pd,bus)         '�ڵ�ע���й�'
BusReactivePow(pd,bus)         '�ڵ�ע���޹�'
OtherBusInPower(pd,bus)        '���ڽڵ�ע���й�����'
OtherBusInRepower(pd,bus)      '���ڽڵ�ע���޹�����'
RealVoltage(pd,bus)            '�ڵ��ѹʵ��ֵ����'
ImagVoltage(pd,bus)            '�ڵ��ѹ�鲿ֵ����'

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~��·��������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LineActivePower(pd,bus,Busj)   '��·ע���й�'
LineActivePowerL(pd,line)      '��·����,��·��ʾ'
VoltageDroponLine(pd,line)     '��·ѹ��ƽ��'
LineLossPower(pd,line)         '�����·�й����U^2Yg'
LineLossRepower(pd,line)       '�����·�޹����U^2Yb'

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Լ������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*���ܵ��Լ��
ESSState(pd,ess)               '���ܳ�ŵ�״̬Լ��'

ESSCharMAXP(pd,ess)            '���ܵ������繦��'
ESSCharMinP(pd,ess)            '���ܵ����С��繦��'
ESSDisMAXP(pd,ess)             '���ܵ�����ŵ繦��'
ESSDisMinP(pd,ess)             '���ܵ����С�ŵ繦��'

SOCDef0(pd,ess)                '����SOC����,��һ����'
SOCDef(pd,ess)                 '����SOC����,�����'
SOClink(pd,ess)                '����SOC����'

*���жϸ���Լ��
ILOutPutP(pd,cl)               '���жϸ���ʵ���й�'
ILOutPutQ(pd,cl)               '���жϸ���ʵ���޹�'
*IntFrequence1(cl)              '���жϸ����жϴ�������'
*IntFrequence2(cl)              '���жϸ����жϴ���Լ��'
IntTimeOnce1(pd,cl)            '���жϸ��ɵ����ж�ʱ�䶨��'
IntTimeOnce2(pd,cl)            '���жϸ��ɵ����ж�ʱ��Լ��'
IntTimeALLMax(cl)              '���жϸ����ܼ�����ж�ʱ��'
IntTimeALLMin(cl)              '���жϸ����ܼ���С�ж�ʱ��'
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~����Լ��~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DeltaP(pd,bus)                 '������ʽԼ��-�й�'
DeltaQ(pd,bus)                 '������ʽԼ��-�޹�'
SlackbusT(pd,bus)              'ƽ��ڵ����Լ��'
OLTCVoltage(pd,bus)            '���ص�ѹ��ѹ����ѹ���ѹ'
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Ŀ �� �� ��~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ObjFunc
.. Obj=E=sum((pd,line),LineLossP(pd,line)*BasePower*(step/60))
;
BuyElecCost
.. BuyCost=E=sum((pd,unit,cl),(C(pd,unit)*P(pd,unit)+ClCost(cl)*(CloadP(pd,cl)-IloadP(pd,cl)))*BasePower)*(step/60)
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~�� �� ϵ ͳ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*���ܳ�ŵ�״̬Լ��
ESSState(pd,ess)
..CharState(pd,ess)+DisCState(pd,ess)=l=1
;
*���ܵ������繦��
ESSCharMAXP(pd,ess)
.. EssCharP(pd,ess)=l=CharState(pd,ess)*EssMaxCP(ess)/BasePower
;
*���ܵ����С��繦��
ESSCharMinP(pd,ess)
.. ESSCharP(pd,ess)=g=CharState(pd,ess)*EssMinCP(ess)/BasePower
;
*���ܵ�����ŵ繦��
ESSDisMAXP(pd,ess)
.. EssDiscP(pd,ess)=l=DisCState(pd,ess)*EssMaxDP(ess)/BasePower
;
*���ܵ����С�ŵ繦��
ESSDisMinP(pd,ess)
.. EssDiscP(pd,ess)=g=DisCState(pd,ess)*0/BasePower
;
*����SOC����
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

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~�� �� �� �� ��~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*���жϸ��ɳ���
ILOutPutP(pd,cl)
..IloadP(pd,cl)=e=ILState(pd,cl)*CloadP(pd,cl)
;
ILOutPutQ(pd,cl)
..IloadQ(pd,cl)=e=ILState(pd,cl)*CloadQ(pd,cl)
;
$ontext
*���жϸ����жϴ���Լ��
IntFrequence1(cl)
..sum(pd$(ord(pd)>1),(ILState(pd-1,cl) xor ILState(pd,cl)) and (not ILState(pd,cl)))=e=Ilfreq(cl)
;

IntFrequence2(cl)
..Ilfreq(cl)=l=ClMaxFreq(cl)
;
$offtext
*���жϸ��ɵ����жϳ���ʱ��
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
*~~~~~~~~~~~~~~~~~~~~~~~~~~~�� �� �� �� �� ֵ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*�ڵ��ѹʵ��ֵ����
RealVoltage(pd,bus)
.. Ve(pd,bus)=e=Vm(pd,bus)*cos(Va(pd,bus))
;
*�ڵ��ѹ�鲿ֵ����
ImagVoltage(pd,bus)
.. Vf(pd,bus)=e=Vm(pd,bus)*sin(Va(pd,bus))
;
*��·ѹ������
VoltageDroponLine(pd,line)
..LineVdrop2(pd,line)=e=sum(bus$(From(line)=ord(Bus)),Vm(pd,bus))**2+sum(bus$(To(line)=ord(Bus)),Vm(pd,bus))**2
                     -2*sum(bus$(From(line)=ord(Bus)),Vm(pd,bus))*sum(bus$(To(line)=ord(Bus)),Vm(pd,bus))*cos(sum(bus$(From(line)=ord(Bus)),Va(pd,bus))-sum(bus$(To(line)=ord(Bus)),Va(pd,bus)))
;

*�ڵ�ע���й�
BusActivePower(pd,bus)
.. BusInP(pd,bus)=e=sum(Unit$(GenBus(Unit)=ord(Bus)),P(pd,unit))
                   +sum(ess$(EssBus(ess)=ord(Bus)),EssDiscP(pd,ess)-EssCharP(pd,ess))
                   -(LoadP(pd,bus)+sum(cl$(ClBus(cl)=ord(Bus)),IloadP(pd,cl)))/BasePower
;
*�ڵ�ע���޹�
BusReactivePow(pd,bus)
.. BusInQ(pd,bus)=e=sum(Unit$(GenBus(Unit)=ord(Bus)),Q(pd,unit))
                   -(LoadQ(pd,bus)+sum(cl$(ClBus(cl)=ord(Bus)),IloadQ(pd,cl)))/BasePower
;
*�����·�й����
LineLossPower(pd,line)
.. LineLossP(pd,line)=e=LineVdrop2(pd,line)*Yg(line)
;
*�����·�޹����
LineLossRepower(pd,line)
.. LineLossQ(pd,line)=e=-LineVdrop2(pd,line)*Yb(line)
;
*��·�й���
LineActivePower(pd,bus,Busj)
.. LineInP(pd,bus,Busj)=e=Vm(pd,bus)*Vm(pd,Busj)*(Gij(bus,Busj)*cos(Va(pd,bus)-Va(pd,Busj))+Bij(bus,Busj)*sin(Va(pd,bus)-Va(pd,Busj)))
-Vm(pd,bus)*Vm(pd,bus)*Gij(bus,Busj)
;
LineActivePowerL(pd,line)
.. LineInPL(pd,line)=e=sum(bus$(ord(bus)=From(line)),sum(busj$(ord(busj)=To(line)),LineInP(pd,bus,busj)))
;
*���ڽڵ�ע���й�����
OtherBusInPower(pd,bus)
.. OtherBusP(pd,bus)=e=Vm(pd,bus)*sum( Busj$(Gij(bus,busj)<>0 or Bij(bus,busj)<>0 ),
Vm(pd,Busj)*(Gij(bus,Busj)*cos(Va(pd,bus)-Va(pd,Busj))+Bij(bus,Busj)*sin(Va(pd,bus)-Va(pd,Busj))))
;
*���ڽڵ�ע���޹�����
OtherBusInRepower(pd,bus)
.. OtherBusQ(pd,bus)=e=Vm(pd,bus)*sum(Busj,
Vm(pd,Busj)*(Gij(bus,Busj)*sin(Va(pd,bus)-Va(pd,Busj))-Bij(bus,Busj)*cos(Va(pd,bus)-Va(pd,Busj))))
;

*~~~~~~~~~~~~~~~~~~~~~~~~~~~�� �� �� ʽ Լ ��~~~~~~~~~~~~~~~~~~~~~~~~~~~
*$ontext
*�ڵ��й�ƽ��
DeltaP(pd,bus)
.. BusInP(pd,bus)-OtherBusP(pd,bus)=e=0
;
*�ڵ��޹�ƽ��
DeltaQ(pd,bus)
.. BusInQ(pd,bus)-OtherBusQ(pd,bus)=e=0
;
*$offtext
*ƽ��ڵ����Լ��
SlackbusT(pd,bus)$(BusType(bus)=3)
.. Va(pd,bus)=e=0
;
*���ص�ѹ��ѹ����ѹ���ѹ
OLTCVoltage(pd,bus)$(ord(bus)=1)
..Vm(pd,bus)=e=1+0.00125*OLTCk(pd)
;

**************************************************************************
*                           ָ �� �� ��
**************************************************************************
*~~~~~~~~~~~~~~~~~~~~~~~~~ָ�����~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parameters
Networkloss            '����'
CEConsum               '�����Դ������'
CLStaterate            '�ɿظ��ɾ�̬����'
CLDynrate              '�ɿظ��ɶ�̬����'
DGStatePene            '��Ъʽ��Դ��̬��͸��ָ��'
DGDynPene              '��Ъʽ��Դ��Ч��͸��'

;

**************************************************************************
*                             �� �� �� ��
**************************************************************************
OPTION MINLP = DICOPT;
OPTION NLP = IPOPTH;
OPTION MIP = cplex;

MODEL ADSSchedule   'Դ����Э���Ż�ģ��'
/ObjFunc, BusActivePower, BusReactivePow, OtherBusInPower, OtherBusInRepower,
RealVoltage,ImagVoltage, LineActivePower, LineActivePowerL, VoltageDroponLine,
LineLossPower, LineLossRepower, ESSState, ESSCharMAXP, ESSCharMinP, ESSDisMAXP,
ESSDisMinP, SOCDef0, SOCDef, SOClink, ILOutPutP, ILOutPutQ,
IntTimeALLMax,DeltaP, DeltaQ, SlackbusT, OLTCVoltage
/;

set i  'ѡȡ�Ŀ��жϸ���' /1*8/;

parameter  Clnow(bus,pd,i)   '����';
parameter ESSposition(i)  '����ϵͳλ��';


parameters resobj(i)      '���м���������'
           resbuycost(i)   '���м��㹺��ɱ�'
           resp(unit,pd,i)  '���м��㷢����й����'
           resSoCini(ess,pd,i) '���м��㴢��SOC���'
           resEssCharP(ess,pd,i)  '���м��㴢�ܳ�繦�ʽ��'
           resEssDiscP(ess,pd,i)  '���м��㴢�ܷŵ繦�ʽ��'
           resCharState(ess,pd,i)  '���ܳ��״̬���'
           resDiscState(ess,pd,i)  '���ܷŵ�״̬���'
           resIloadP(cl,pd,i) '���м�����жϸ��ɳ������'
           resVm(bus,pd,i) '���м���ڵ��ѹ���'
           resVdiv(bus,i)  '����ѹƫ��'
           resOLTCk(pd,i)  '���м����Ƚ��'
           resNetworkloss(i) '���м���������'
           reslineloss(line,i) '���м�����·������'
           resCEConsum(i)  '�����Դ������'
           resCLStaterate(i)  '�ɿظ��ɾ�̬����'
           resCLDynrate(i)    '�ɿظ��ɶ�̬����'
           resDGStatePene(i)  '��Ъʽ��Դ��̬��͸��ָ��'
           resDGDynPene(i)    '��Ъʽ��Դ��Ч��͸��'
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
*                             �� �� �� ��
**************************************************************************
*~~~~~~~~~~~~~~~~~~~~~~~~~~����ֵת��Ϊ����ֵ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
P.l(pd,unit)=P.l(pd,unit)*BasePower;
Q.l(pd,unit)=Q.l(pd,unit)*BasePower;
BusInP.l(pd,bus)=BusInP.l(pd,bus)*BasePower;
OtherBusP.l(pd,bus)=OtherBusP.l(pd,bus)*BasePower;
LineInP.l(pd,bus,Busj)=LineInP.l(pd,bus,Busj)*BasePower;
LineInPL.l(pd,line)= LineInPL.l(pd,line)*BasePower;
LineLossP.l(pd,line)=LineLossP.l(pd,line)*BasePower;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~�� �� �� ��~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~�� �� �� ��~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*=== Export to Excel using GDX utilities
*=== First unload to GDX file (occurs during execution phase)
execute_unload "results$1.gdx" resObj,resP,resSoCini,resEssCharP,resEssDiscP,resIloadP,resVm,resOLTCk,
resCEConsum,resCLStaterate,resCLDynrate,resDGStatePene,resDGDynPene,resNetworkloss,reslineloss,
resCharState,resDiscState,resbuycost,resVdiv,resLoadstate;
*=== Now write to variable levels to Excel file from GDX
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe results$1.gdx par=resNetworkloss rng=����ָ��!';

execute 'gdxxrw.exe results$1.gdx par=resCEConsum rng=�����Դ������!';

execute 'gdxxrw.exe results$1.gdx par=resCLStaterate rng=�ɿظ��ɾ�̬����!';

execute 'gdxxrw.exe results$1.gdx par=resCLDynrate rng=�ɿظ��ɶ�̬����!';

execute 'gdxxrw.exe results$1.gdx par=resDGStatePene rng=��Ъʽ��Դ��̬��͸��ָ��!';

execute 'gdxxrw.exe results$1.gdx par=resDGDynPene rng=��Ъʽ��Դ��Ч��͸��!';

execute 'gdxxrw.exe results$1.gdx par=resobj rng=Ŀ�꺯��!';

execute 'gdxxrw.exe results$1.gdx par=reslineloss rng=����·����!';

execute 'gdxxrw.exe results$1.gdx par=resP rng=������й�����!';

execute 'gdxxrw.exe results$1.gdx par=resSoCini rng=SOC!';

execute 'gdxxrw.exe results$1.gdx par=resCharState rng=���ܳ��״̬!';

execute 'gdxxrw.exe results$1.gdx par=resDiscState rng=���ܷŵ�״̬!';

execute 'gdxxrw.exe results$1.gdx par=resEssCharP rng=���ܳ�繦��!';

execute 'gdxxrw.exe results$1.gdx par=resEssDiscP rng=���ܷŵ繦��!';

execute 'gdxxrw.exe results$1.gdx par=resIloadP rng=���жϸ��ɹ���!';

execute 'gdxxrw.exe results$1.gdx par=resLoadstate rng=���жϸ���״̬!';

execute 'gdxxrw.exe results$1.gdx par=resVm rng=�ڵ��ѹ!';

execute 'gdxxrw.exe results$1.gdx par=resVdiv rng=�ڵ��ѹƫ��!';

execute 'gdxxrw.exe results$1.gdx par=resOLTCk rng=��ѹ����ͷλ��!';

execute 'gdxxrw.exe results$1.gdx par=resbuycost rng=����ɱ�!';
*$Offtext


