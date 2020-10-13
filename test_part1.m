%% ��ȡ�������������
app = actxserver('STK11.application');
root = app.Personality2;
root.NewScenario('Astro');
scenario = root.CurrentScenario;

%% ������ʼ��ʱ��
scenario.StartTime = '1 Jan 2000 00:00:00.000';

%% ��������
satellite = scenario.Children.New(18,'mysat'); 
% satellite = scenario.Children.New('eSatellite','ValidationSat');
% ��18��������ʲô��

%% ����ΪAstrogator
satellite.SetPropagatorType('ePropagatorAstrogator');

%% ���������У������
MCS = satellite.Propagator.MainSequence;  % ����������
MCS.RemoveAll();

%% �½�������
componentAstrogator = scenario.ComponentDirectory.GetComponents('eComponentAstrogator');
engineModels = componentAstrogator.GetFolder('Engine Models');
try
    customThruster = engineModels.Item('customThruster');
catch
    % ����һ��������
    customThruster = engineModels.DuplicateComponent('Constant Thrust and Isp','customThruster');
end

%% ������������ֵ�ͱȳ�����
customThruster.Isp = 3000;
customThruster.Thrust = 1/2000;

%% �½���ʼ��
initstate = MCS.Insert('eVASegmentTypeInitialState','initstate','-');
initstate.OrbitEpoch = scenario.StartTime;
% initstate.SetElementType('eVAElementTypeModKeplerian');  %�Ľ����ֵ�������
initstate.SetElementType('eVAElementTypeKeplerian');     %����������

%% ��ʼ��������
initstate.InitialState.DryMass = 1000; %����ȼ��֮�������
initstate.FuelTank.FuelMass = 2000;

%% �����塢����Ȳ�������
initstate.InitialState.Cd = 2.2;
initstate.InitialState.DragArea = 10;
initstate.InitialState.Cr = 1;
initstate.InitialState.SRPArea = 20;

%% ��ʼ�����������
initstate.InitialState.Element.SemiMajorAxis = 7.8781e+03;
initstate.InitialState.Element.Inclination = 50;

%% ��ʼ������ƶ�
propagate = MCS.Insert('eVASegmentTypePropagate','Propagate','-');
propagate.PropagatorName = 'Earth Point Mass';
propagate.Properties.Color = uint32(hex2dec('00ff00'));
propagate.StoppingConditions.Item('Duration').Properties.Trip = 3600;

%% Ŀ�������ƶ�
propagate2 = MCS.Insert('eVASegmentTypePropagate','Propagate','-');
propagate2.PropagatorName = 'Earth Point Mass';
propagate2.Properties.Color = uint32(hex2dec('00ff00'));
propagate2.StoppingConditions.Item('Duration').Properties.Trip = 5184000;

%% ����
satellite.Propagator.RunMCS;

%%
%�Ȳ���Target Sequenceģ��
mytars = MCS.Insert('eVASegmentTypeTargetSequence','mytarget','-');
%��Target Sequenceģ��ǰ�����ʼ״̬ģ��
myinit = MCS.Insert('eVASegmentTypeInitialState','myinit','mytarget');
%�޸ĳ�ʼʱ��
myinit.InitialState.Epoch = '1 Jan 2000 00:00:00.000';
%��������䣬�Ϳ��Կ���Insert������ʹ�÷�ʽ�����������ֱ��ǣ�ģ�����͡��Զ����ģ�����ơ���һ��ģ������ƣ��ڸ�ģ��ǰ�����µ�ģ�飩
% pro500 = MCS.Insert('eVASegmentTypePropagate','pro500','mytarget');
myinit.InitialState.get

myinit.InitialState.SetElementType('eVAElementTypeKeplerian');
%���ù���߶�Ϊ500km��û���õĻ���Ĭ��ֵ
myinit.InitialState.Element.SemiMajorAxis = 6.8781e+03;
myinit.InitialState.Element.Inclination = 50;
%��ʼ����
sat.Propagator.MainSequence.Item(0).InitialState.DryMass =1000;

%����pro500ģ������500s
%Propagateģ��Ĭ�ϵ�ֹͣ����������ʱ�䣬�������ǾͲ��޸���
% pro500.StoppingConditions.Item(0).Properties.Trip = 500;

man1 = mytars.Segments.Insert('eVASegmentTypeManeuver','man1','-');
%���øöγ�ʼʱ�̺ͽ���ʱ�̵Ĺ����������
man1.InitialState.SetElementType('eVAElementTypeKeplerian')
man1.FinalState.SetElementType('eVAElementTypeKeplerian')
man1.Maneuver.get
man1.SetManeuverType('eVAManeuverTypeFinite');%��������
man1.Maneuver.ThrustEfficiencyMode = 'eVAThrustTypeAffectsAccelAndMassFlow';%���������仯

%������Ҫ�Լ�����stk���½�һ��engine