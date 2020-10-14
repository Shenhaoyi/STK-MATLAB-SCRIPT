%% ��ȡ�������������
app = actxserver('STK11.application');
% ��֪����
app.UserControl = 1;
app.visible = 1;

root = app.Personality2;
root.NewScenario('Astro'); % ����������
scenario = root.CurrentScenario;

%% ������ʼ��ʱ��
scenario.StartTime = '1 Jan 2000 00:00:00.000';

%% ��������
satellite = scenario.Children.New(18,'mysat'); % ����������
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
customThruster.Thrust = 1;

%% �½���ʼ��
initstate = MCS.Insert('eVASegmentTypeInitialState','initstate','-');
initstate.OrbitEpoch = scenario.StartTime;
% initstate.SetElementType('eVAElementTypeModKeplerian');  %�Ľ����ֵ�������
initstate.SetElementType('eVAElementTypeKeplerian');     %����������

%% ��ʼ��������
initstate.InitialState.DryMass = 1000; %����ȼ��֮�������
initstate.FuelTank.FuelMass = 1000;

%% �����塢����Ȳ�������
initstate.InitialState.Cd = 2.2;
initstate.InitialState.DragArea = 10;
initstate.InitialState.Cr = 1;
initstate.InitialState.SRPArea = 20;

%% ��ʼ�����������
initstate.Element.SemiMajorAxis = 7.8781e+03;
initstate.Element.Inclination = 50;

%% ��ʼ������ƶ�
propagate = MCS.Insert('eVASegmentTypePropagate','Propagate','-');%���������ֱ��ǣ�ģ�����͡��Զ����ģ�����ơ���һ��ģ������ƣ��ڸ�ģ��ǰ�����µ�ģ�飩
propagate.PropagatorName = 'Earth Point Mass';
propagate.Properties.Color = uint32(hex2dec('00ff00'));
propagate.StoppingConditions.Item('Duration').Properties.Trip = 3600;


%% �޸ĳ�ֻ���и��¶�
satellite.Propagator.Option.SmartRunMode = 1; %'eVASmartRunModeOnlyChanged'

%% ѭ������
max = 100;
count = 1;
res = [];
while count <= max
    name = strcat('Man',num2str(count));
    
    man = MCS.Insert('eVASegmentTypeManeuver',name,'-');
    man.Properties.Color = uint32(hex2dec('0000ff'));
    man.SetManeuverType('eVAManeuverTypeFinite'); % ����Ϊ��������
    man.InitialState.SetElementType('eVAElementTypeKeplerian');
    man.FinalState.SetElementType('eVAElementTypeKeplerian');
    maneuver = man.Maneuver;
    maneuver.SetPropulsionMethod('eVAPropulsionMethodEngineModel','customThruster');% ѡ�񷢶���Ϊ���Ƶķ�����
%     maneuver.Propagator.PropagatorName = 'Earth Point Mass'; %����ѧģ��
    maneuver.Propagator.PropagatorName = 'Earth J2'; %����ѧģ��
    maneuver.ThrustEfficiencyMode = 'eVAThrustTypeAffectsAccelAndMassFlow';%���������仯
    maneuver.SetAttitudeControlType('eVAAttitudeControlThrustVector');%��̬��������
    maneuver.AttitudeControl.ThrustAxesName = 'Satellite LVLH'; %�������ڵ�����ϵ����
    maneuver.AttitudeControl.ThrustVector.AssignXYZ(0,1,0);
    maneuver.Propagator.StoppingConditions.Item('Duration').Properties.Trip = 3600*24;
    satellite.Propagator.RunMCS;
    % ��ȡ�ö��ƽ�֮��Ĺ������
    res = [res;man.FinalState.Element.SemiMajorAxis];
    count = count + 1;
end
%% �½�������
% man = MCS.Insert('eVASegmentTypeManeuver','Man','-');
% man.Properties.Color = uint32(hex2dec('0000ff'));
% man.SetManeuverType('eVAManeuverTypeFinite'); % ����Ϊ��������
% man.InitialState.SetElementType('eVAElementTypeKeplerian');
% man.FinalState.SetElementType('eVAElementTypeKeplerian');
% maneuver = man.Maneuver;
% maneuver.SetPropulsionMethod('eVAPropulsionMethodEngineModel','customThruster');% ѡ�񷢶���Ϊ���Ƶķ�����
% maneuver.Propagator.PropagatorName = 'Earth Point Mass'; %����ѧģ��
% maneuver.ThrustEfficiencyMode = 'eVAThrustTypeAffectsAccelAndMassFlow';%���������仯
% maneuver.SetAttitudeControlType('eVAAttitudeControlThrustVector');%��̬��������
% maneuver.AttitudeControl.ThrustAxesName = 'Satellite LVLH'; %�������ڵ�����ϵ����
% maneuver.AttitudeControl.ThrustVector.AssignXYZ(1,1,1);
% maneuver.Propagator.StoppingConditions.Item('Duration').Properties.Trip = 3600*240;

%% Ŀ�������ƶ�
propagate2 = MCS.Insert('eVASegmentTypePropagate','Propagate2','-');
propagate2.PropagatorName = 'Earth Point Mass';
propagate2.Properties.Color = uint32(hex2dec('00ff00'));
propagate2.StoppingConditions.Item('Duration').Properties.Trip = 3600;

%% ����
satellite.Propagator.RunMCS;
% ���run only changed segments
