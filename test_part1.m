%% 获取句柄，创建场景
app = actxserver('STK11.application');
root = app.Personality2;
root.NewScenario('Astro');
scenario = root.CurrentScenario;

%% 场景初始化时间
scenario.StartTime = '1 Jan 2000 00:00:00.000';

%% 创建卫星
satellite = scenario.Children.New(18,'mysat'); 
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
customThruster.Thrust = 1/2000;

%% 新建初始段
initstate = MCS.Insert('eVASegmentTypeInitialState','initstate','-');
initstate.OrbitEpoch = scenario.StartTime;
% initstate.SetElementType('eVAElementTypeModKeplerian');  %改进春分点轨道根数
initstate.SetElementType('eVAElementTypeKeplerian');     %经典轨道根数

%% 初始质量设置
initstate.InitialState.DryMass = 1000; %除了燃料之外的质量
initstate.FuelTank.FuelMass = 2000;

%% 气动板、光电版等参数设置
initstate.InitialState.Cd = 2.2;
initstate.InitialState.DragArea = 10;
initstate.InitialState.Cr = 1;
initstate.InitialState.SRPArea = 20;

%% 初始轨道根数设置
initstate.InitialState.Element.SemiMajorAxis = 7.8781e+03;
initstate.InitialState.Element.Inclination = 50;

%% 初始轨道外推段
propagate = MCS.Insert('eVASegmentTypePropagate','Propagate','-');
propagate.PropagatorName = 'Earth Point Mass';
propagate.Properties.Color = uint32(hex2dec('00ff00'));
propagate.StoppingConditions.Item('Duration').Properties.Trip = 3600;

%% 目标轨道外推段
propagate2 = MCS.Insert('eVASegmentTypePropagate','Propagate','-');
propagate2.PropagatorName = 'Earth Point Mass';
propagate2.Properties.Color = uint32(hex2dec('00ff00'));
propagate2.StoppingConditions.Item('Duration').Properties.Trip = 5184000;

%% 运行
satellite.Propagator.RunMCS;

%%
%先插入Target Sequence模块
mytars = MCS.Insert('eVASegmentTypeTargetSequence','mytarget','-');
%在Target Sequence模块前插入初始状态模块
myinit = MCS.Insert('eVASegmentTypeInitialState','myinit','mytarget');
%修改初始时刻
myinit.InitialState.Epoch = '1 Jan 2000 00:00:00.000';
%从上面语句，就可以看出Insert方法的使用方式，三个参数分别是：模块类型、自定义的模块名称、后一个模块的名称（在该模块前插入新的模块）
% pro500 = MCS.Insert('eVASegmentTypePropagate','pro500','mytarget');
myinit.InitialState.get

myinit.InitialState.SetElementType('eVAElementTypeKeplerian');
%设置轨道高度为500km，没设置的会有默认值
myinit.InitialState.Element.SemiMajorAxis = 6.8781e+03;
myinit.InitialState.Element.Inclination = 50;
%初始质量
sat.Propagator.MainSequence.Item(0).InitialState.DryMass =1000;

%设置pro500模块运行500s
%Propagate模块默认的停止条件是运行时间，这里我们就不修改了
% pro500.StoppingConditions.Item(0).Properties.Trip = 500;

man1 = mytars.Segments.Insert('eVASegmentTypeManeuver','man1','-');
%设置该段初始时刻和结束时刻的轨道参数类型
man1.InitialState.SetElementType('eVAElementTypeKeplerian')
man1.FinalState.SetElementType('eVAElementTypeKeplerian')
man1.Maneuver.get
man1.SetManeuverType('eVAManeuverTypeFinite');%有限推力
man1.Maneuver.ThrustEfficiencyMode = 'eVAThrustTypeAffectsAccelAndMassFlow';%设置质量变化

%首先需要自己先在stk中新建一个engine