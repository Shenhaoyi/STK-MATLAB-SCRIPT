% ����stk����Starlink����
% ������ 2019.06.16
% stkConnect��stkExec�����ǵȼ۵ģ��������Ƽ�ʹ��stkConnect����������̫��
%       1��stkConnect(conID, 'command', 'objPath', 'cmdParamString')
%       2��stkExec(conId, [command ' ' path ' ' cmdParamString])
function StarlinkAnalyze_MexConnect
% ��ʼǰ��Ҫ��STK�������½�����
% �ⲿ����ʵ���Բο�COM�����Զ�������������ο���һ������ʾ��
stkInit;                                % ��������
remMachine = stkDefaultHost;
conid = stkOpen(remMachine);            % �õ����Ӿ�������ڷ���ָ�
% �жϳ����Ƿ����
scen_open = stkValidScen;
if scen_open == 1
    rtn = questdlg('Close the current scenario?');
    if ~strcmp(rtn,'Yes')
        stkClose(conid);
        return;
    else
        stkUnload('/*');
    end
end

% �½�����
disp('����һ������');
stkNewObj('/','Scenario','StarLink');

% �趨����ʱ��
disp('�趨����ʱ��');
strBegTime = '27 May 2019 06:14:00.000';
strEndTime = '28 May 2019 06:14:00.000';
stkSetTimePeriod(strBegTime,strEndTime,'GREGUTC');
% ʹaeroToolbox�к�������Ԫʱ���볡��һ��
stkSetEpoch(strBegTime,'GREGUTC');
stkSyncEpoch;
% �趨����������ʼʱ��
strQuteBegTime = ['"' strBegTime '"']; % ʱ��д�������ǵü�˫���ţ��ȽϿ̰�
rtn = stkConnect(conid,'Animate','Scenario/StarLink',['SetValues ' strQuteBegTime ' 60 0.1']);
% rtn = stkConnect(conid,'Animate','Scenario/StarLink','SetValues "27 May 2019 06:14:00.000" 60 0.1');
% �趨����ʱ��ص���ʼ��
rtn = stkConnect(conid,'Animate','Scenario/StarLink','Reset');
% �½���������
disp('������������');
strSeedSat = 'Sat';
stkNewObj('*/','Satellite',strSeedSat);
% ���ǻ�����ֹʱ�䡢�����Ԫʱ�䡢����
t_start=0; t_stop=24*3600; orbitEpoch=t_start; dt=60;
% ���ǳ�ʼ�������
a=6928.137*1000;  e=0.0; i=53.0*pi/180;
w=0*pi/180; Raan=160*pi/180; M=0*pi/180;
% �������ǹ��
stkSetPropClassical(['*/Satellite/' strSeedSat],'J4Perturbation','J2000',t_start,t_stop,dt,orbitEpoch,a,e,i,w,Raan,M);
% stkPropagate('*/Satellite/SZ', t_start, t_stop);
% ��������������Ӵ�����������������ÿ�������϶����д�����
strSensor = 'Sen';
stkNewObj(['*/Satellite/' strSeedSat],'Sensor',strSensor);
% ���ô���������
strSetSensor = ['Conical 0 44.85 AngularRes 360.0'];
stkConnect(conid,'Define',['*/Satellite/' strSeedSat '/Sensor/' strSensor],strSetSensor);
% strSetSensor = ['Define */Satellite/Sat/Sensor/Sen Conical 0 44.85 AngularRes 360.0'];
% SensorModel = stkExec(conid,strSetSensor);
% ����walker����
disp('����walker����');
nPlan = 2;% ƽ����
nPerPlan = 2;% ÿ��ƽ��������
nRANNSpreed = 1;% ����ƽ��������λ��
% STK���ɵ���������ΪstrSeedSat_**##��**����ƽ������##����ƽ����������
% ����ѭ����Ÿ�ʽ���ã���ʾ��λ�����
nFormatPlan = 1;
nFormatPerPlan = 1;
strFormatPlan = ['%0' int2str(nFormatPlan) 'd'];
strFormatPerPlan = ['%0' int2str(nFormatPerPlan) 'd'];
% ��������������ΪMyConst
strWalkerSet = ['Delta ' int2str(nPlan) ' ' int2str(nPerPlan) ' ' int2str(nRANNSpreed) ' 360.0 No ConstellationName MyConst'];
stkConnect(conid,'Walker', ['*/Satellite/' strSeedSat],strWalkerSet);
% 

% ������������
disp('������������');
stkNewObj('*/','CoverageDefinition','CovGlobal');
% ����ȫ�򸲸Ƿ��� ���ÿɲ�ѯCov Grid
stkConnect(conid,'Cov','*/CoverageDefinition/CovGlobal','Grid AreaOfInterest Global');
% ����ͼ�����
% stkConnect(conid,'Graphics','*/CoverageDefinition/CovGlobal','Static Points On yellow');
% stkConnect(conid,'Graphics','*/CoverageDefinition/CovGlobal','Static Regions Off');
% stkConnect(conid,'Graphics','*/CoverageDefinition/CovGlobal','Static FillPoints Off Point');

% ����Ʒ�ʲ���
disp('����FOM����');
stkConnect(conid,'New','/ */CoverageDefinition/CovGlobal/FigureOfMerit Fom');
stkConnect(conid,'Cov ','*/CoverageDefinition/CovGlobal/FigureOfMerit/Fom FOMDefine Definition NAsset Minimum');
% ����ͼ�����
% stkConnect(conid,'Graphics','*/CoverageDefinition/CovGlobal/FigureOfMerit/Fom Static Off');
% stkConnect(conid,'Graphics','*/CoverageDefinition/CovGlobal/FigureOfMerit/Fom Animation On NotCurrent blue');
% stkConnect(conid,'Graphics','*/CoverageDefinition/CovGlobal/FigureOfMerit/Fom Animation FillPoints On ');

% Ϊ�������������Դ
disp('����������Դ');
% ��ϧ��������Ĭ��Assigned object�����ǣ�����Ҫ�õ��Ǵ�������
% ��û�ҵ������������󼯵ĺ���������ֻ��ʹ��ѭ��������
% stkConnect(conid,'Cov','*/CoverageDefinition/CovGlobal Asset */Constellation/MyConst Assign');

for i = 1:nPlan
    for j = 1:nPerPlan
        strStarName = [strSeedSat num2str(i,strFormatPlan) num2str(j,strFormatPerPlan)];
        strAssetCommand = ['*/CoverageDefinition/CovGlobal Asset */Satellite/' strStarName '/Sensor/Sen Assign'];
        stkConnect(conid,'Cov',strAssetCommand);
    end
end

% ��������
disp('��������');
stkConnect(conid,'Cov','*/CoverageDefinition/CovGlobal Access Compute');

stkClose(conid);

end