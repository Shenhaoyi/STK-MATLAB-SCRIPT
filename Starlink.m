% 调用stk分析Starlink星座
% 戴正旭 2019.06.16
% stkConnect和stkExec操作是等价的，但个人推荐使用stkConnect，避免命令太长
%       1）stkConnect(conID, 'command', 'objPath', 'cmdParamString')
%       2）stkExec(conId, [command ' ' path ' ' cmdParamString])
function StarlinkAnalyze_MexConnect
% 开始前需要打开STK，无需新建工程
% 这部分其实可以参考COM部分自动启动程序，详情参考下一个代码示例
stkInit;                                % 建立连接
remMachine = stkDefaultHost;
conid = stkOpen(remMachine);            % 得到连接句柄（用于发送指令）
% 判断场景是否存在
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

% 新建场景
disp('创建一个场景');
stkNewObj('/','Scenario','StarLink');

% 设定场景时间
disp('设定场景时间');
strBegTime = '27 May 2019 06:14:00.000';
strEndTime = '28 May 2019 06:14:00.000';
stkSetTimePeriod(strBegTime,strEndTime,'GREGUTC');
% 使aeroToolbox中函数的历元时间与场景一致
stkSetEpoch(strBegTime,'GREGUTC');
stkSyncEpoch;
% 设定场景动画开始时间
strQuteBegTime = ['"' strBegTime '"']; % 时间写入命令是得加双引号，比较刻板
rtn = stkConnect(conid,'Animate','Scenario/StarLink',['SetValues ' strQuteBegTime ' 60 0.1']);
% rtn = stkConnect(conid,'Animate','Scenario/StarLink','SetValues "27 May 2019 06:14:00.000" 60 0.1');
% 设定动画时间回到起始点
rtn = stkConnect(conid,'Animate','Scenario/StarLink','Reset');
% 新建种子卫星
disp('创建种子卫星');
strSeedSat = 'Sat';
stkNewObj('*/','Satellite',strSeedSat);
% 卫星积分起止时间、轨道历元时间、步长
t_start=0; t_stop=24*3600; orbitEpoch=t_start; dt=60;
% 卫星初始轨道根数
a=6928.137*1000;  e=0.0; i=53.0*pi/180;
w=0*pi/180; Raan=160*pi/180; M=0*pi/180;
% 输入卫星轨道
stkSetPropClassical(['*/Satellite/' strSeedSat],'J4Perturbation','J2000',t_start,t_stop,dt,orbitEpoch,a,e,i,w,Raan,M);
% stkPropagate('*/Satellite/SZ', t_start, t_stop);
% 在种子卫星上添加传感器，创建星座后每个卫星上都会有传感器
strSensor = 'Sen';
stkNewObj(['*/Satellite/' strSeedSat],'Sensor',strSensor);
% 设置传感器参数
strSetSensor = ['Conical 0 44.85 AngularRes 360.0'];
stkConnect(conid,'Define',['*/Satellite/' strSeedSat '/Sensor/' strSensor],strSetSensor);
% strSetSensor = ['Define */Satellite/Sat/Sensor/Sen Conical 0 44.85 AngularRes 360.0'];
% SensorModel = stkExec(conid,strSetSensor);
% 生成walker星座
disp('生成walker星座');
nPlan = 2;% 平面数
nPerPlan = 2;% 每个平面卫星数
nRANNSpreed = 1;% 相邻平面卫星相位差
% STK生成的卫星名称为strSeedSat_**##，**代表平面数，##代表平面内卫星数
% 后续循环编号格式化用，表示几位数填充
nFormatPlan = 1;
nFormatPerPlan = 1;
strFormatPlan = ['%0' int2str(nFormatPlan) 'd'];
strFormatPerPlan = ['%0' int2str(nFormatPerPlan) 'd'];
% 创建星座，命名为MyConst
strWalkerSet = ['Delta ' int2str(nPlan) ' ' int2str(nPerPlan) ' ' int2str(nRANNSpreed) ' 360.0 No ConstellationName MyConst'];
stkConnect(conid,'Walker', ['*/Satellite/' strSeedSat],strWalkerSet);
% 

% 创建覆盖区域
disp('创建覆盖区域');
stkNewObj('*/','CoverageDefinition','CovGlobal');
% 定义全球覆盖分析 设置可查询Cov Grid
stkConnect(conid,'Cov','*/CoverageDefinition/CovGlobal','Grid AreaOfInterest Global');
% 设置图像参数
% stkConnect(conid,'Graphics','*/CoverageDefinition/CovGlobal','Static Points On yellow');
% stkConnect(conid,'Graphics','*/CoverageDefinition/CovGlobal','Static Regions Off');
% stkConnect(conid,'Graphics','*/CoverageDefinition/CovGlobal','Static FillPoints Off Point');

% 创建品质参数
disp('创建FOM参数');
stkConnect(conid,'New','/ */CoverageDefinition/CovGlobal/FigureOfMerit Fom');
stkConnect(conid,'Cov ','*/CoverageDefinition/CovGlobal/FigureOfMerit/Fom FOMDefine Definition NAsset Minimum');
% 设置图像参数
% stkConnect(conid,'Graphics','*/CoverageDefinition/CovGlobal/FigureOfMerit/Fom Static Off');
% stkConnect(conid,'Graphics','*/CoverageDefinition/CovGlobal/FigureOfMerit/Fom Animation On NotCurrent blue');
% stkConnect(conid,'Graphics','*/CoverageDefinition/CovGlobal/FigureOfMerit/Fom Animation FillPoints On ');

% 为区域关联覆盖资源
disp('关联覆盖资源');
% 可惜星座创建默认Assigned object是卫星，这里要用的是传感器，
% 我没找到设置星座对象集的函数，以下只好使用循环操作了
% stkConnect(conid,'Cov','*/CoverageDefinition/CovGlobal Asset */Constellation/MyConst Assign');

for i = 1:nPlan
    for j = 1:nPerPlan
        strStarName = [strSeedSat num2str(i,strFormatPlan) num2str(j,strFormatPerPlan)];
        strAssetCommand = ['*/CoverageDefinition/CovGlobal Asset */Satellite/' strStarName '/Sensor/Sen Assign'];
        stkConnect(conid,'Cov',strAssetCommand);
    end
end

% 分析覆盖
disp('分析覆盖');
stkConnect(conid,'Cov','*/CoverageDefinition/CovGlobal Access Compute');

stkClose(conid);

end