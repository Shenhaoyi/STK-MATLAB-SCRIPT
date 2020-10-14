%% 获取句柄，创建场景
app = actxserver('STK11.application');
% 不知何用
app.UserControl = 1;
app.visible = 1;

root = app.Personality2;
root.NewScenario('Astro'); % 创建并命名
scenario = root.CurrentScenario;

%% 场景初始化时间
scenario.StartTime = '1 Jan 2000 00:00:00.000';

%% 创建卫星
satellite = scenario.Children.New(18,'mysat'); % 创建并命名
% satellite = scenario.Children.New('eSatellite','ValidationSat');
% 与18的区别是什么？

%% 配置为Astrogator
satellite.SetPropagatorType('ePropagatorAstrogator');

%% 创建段序列，并清空
MCS = satellite.Propagator.MainSequence;  % 机动段序列
MCS.RemoveAll();

%% 新建发动机
componentAstrogator = scenario.ComponentDirectory.GetComponents('eComponentAstrogator');
engineModels = componentAstrogator.GetFolder('Engine Models');
try
    customThruster = engineModels.Item('customThruster');
catch
    % 复制一个发动机
    customThruster = engineModels.DuplicateComponent('Constant Thrust and Isp','customThruster');
end

%% 发动机推力幅值和比冲设置
customThruster.Isp = 3000;
customThruster.Thrust = 1;

%% 新建初始段
initstate = MCS.Insert('eVASegmentTypeInitialState','initstate','-');
initstate.OrbitEpoch = scenario.StartTime;
% initstate.SetElementType('eVAElementTypeModKeplerian');  %改进春分点轨道根数
initstate.SetElementType('eVAElementTypeKeplerian');     %经典轨道根数

%% 初始质量设置
initstate.InitialState.DryMass = 1000; %除了燃料之外的质量
initstate.FuelTank.FuelMass = 1000;

%% 气动板、光电版等参数设置
initstate.InitialState.Cd = 2.2;
initstate.InitialState.DragArea = 10;
initstate.InitialState.Cr = 1;
initstate.InitialState.SRPArea = 20;

%% 初始轨道根数设置
initstate.Element.SemiMajorAxis = 7.8781e+03;
initstate.Element.Inclination = 50;

%% 初始轨道外推段
propagate = MCS.Insert('eVASegmentTypePropagate','Propagate','-');%三个参数分别是：模块类型、自定义的模块名称、后一个模块的名称（在该模块前插入新的模块）
propagate.PropagatorName = 'Earth Point Mass';
propagate.Properties.Color = uint32(hex2dec('00ff00'));
propagate.StoppingConditions.Item('Duration').Properties.Trip = 3600;


%% 修改成只运行更新段
satellite.Propagator.Option.SmartRunMode = 1; %'eVASmartRunModeOnlyChanged'

%% 循环插入
max = 100;
count = 1;
res = [];
while count <= max
    name = strcat('Man',num2str(count));
    
    man = MCS.Insert('eVASegmentTypeManeuver',name,'-');
    man.Properties.Color = uint32(hex2dec('0000ff'));
    man.SetManeuverType('eVAManeuverTypeFinite'); % 设置为有限推力
    man.InitialState.SetElementType('eVAElementTypeKeplerian');
    man.FinalState.SetElementType('eVAElementTypeKeplerian');
    maneuver = man.Maneuver;
    maneuver.SetPropulsionMethod('eVAPropulsionMethodEngineModel','customThruster');% 选择发动机为复制的发动机
%     maneuver.Propagator.PropagatorName = 'Earth Point Mass'; %动力学模型
    maneuver.Propagator.PropagatorName = 'Earth J2'; %动力学模型
    maneuver.ThrustEfficiencyMode = 'eVAThrustTypeAffectsAccelAndMassFlow';%设置质量变化
    maneuver.SetAttitudeControlType('eVAAttitudeControlThrustVector');%姿态控制设置
    maneuver.AttitudeControl.ThrustAxesName = 'Satellite LVLH'; %推力所在的坐标系设置
    maneuver.AttitudeControl.ThrustVector.AssignXYZ(0,1,0);
    maneuver.Propagator.StoppingConditions.Item('Duration').Properties.Trip = 3600*24;
    satellite.Propagator.RunMCS;
    % 获取该段推进之后的轨道根数
    res = [res;man.FinalState.Element.SemiMajorAxis];
    count = count + 1;
end
%% 新建机动段
% man = MCS.Insert('eVASegmentTypeManeuver','Man','-');
% man.Properties.Color = uint32(hex2dec('0000ff'));
% man.SetManeuverType('eVAManeuverTypeFinite'); % 设置为有限推力
% man.InitialState.SetElementType('eVAElementTypeKeplerian');
% man.FinalState.SetElementType('eVAElementTypeKeplerian');
% maneuver = man.Maneuver;
% maneuver.SetPropulsionMethod('eVAPropulsionMethodEngineModel','customThruster');% 选择发动机为复制的发动机
% maneuver.Propagator.PropagatorName = 'Earth Point Mass'; %动力学模型
% maneuver.ThrustEfficiencyMode = 'eVAThrustTypeAffectsAccelAndMassFlow';%设置质量变化
% maneuver.SetAttitudeControlType('eVAAttitudeControlThrustVector');%姿态控制设置
% maneuver.AttitudeControl.ThrustAxesName = 'Satellite LVLH'; %推力所在的坐标系设置
% maneuver.AttitudeControl.ThrustVector.AssignXYZ(1,1,1);
% maneuver.Propagator.StoppingConditions.Item('Duration').Properties.Trip = 3600*240;

%% 目标轨道外推段
propagate2 = MCS.Insert('eVASegmentTypePropagate','Propagate2','-');
propagate2.PropagatorName = 'Earth Point Mass';
propagate2.Properties.Color = uint32(hex2dec('00ff00'));
propagate2.StoppingConditions.Item('Duration').Properties.Trip = 3600;

%% 运行
satellite.Propagator.RunMCS;
% 如何run only changed segments
