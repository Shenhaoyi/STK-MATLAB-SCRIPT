%% 配置推力的幅值
componentAstrogator = sc.ComponentDirectory.GetComponents('eComponentAstrogator');
engineModels = componentAstrogator.GetFolder('Engine Models');
customThruster = engineModels.Item('New Constant Thrust and Isp');
customThruster.Isp = 720;
customThruster.Thrust = 0.001;

%% 配置推力的方向等
man1.Maneuver.SetPropulsionMethod('eVAPropulsionMethodEngineModel','New Constant Thrust and Isp');%设置发动机
% man1.Maneuver.SetPropulsionMethod('eVAPropulsionMethodEngineModel','Custom Engine');
man1.Maneuver.AttitudeControl.ThrustVector.AssignXYZ(1,0,0);
man1.Maneuver.Propagator.PropagatorName =  'Earth Point Mass';  %动力学模型
man1.Maneuver.SetAttitudeControlType('eVAAttitudeControlThrustVector');%姿态控制设置
man1.Maneuver.AttitudeControl.ThrustAxesName = 'Satellite LVLH'; %推力设置的坐标系
man1.Maneuver.Propagator.StoppingConditions.Item('Duration').Properties.Trip = 600;

%% Astrogator Config
componentAstrogator = scenario.ComponentDirectory.GetComponents('eComponentAstrogator');
engineModels = componentAstrogator.GetFolder('Engine Models');
try
    customThruster = engineModels.Item('customThruster');
catch
    customThruster = engineModels.DuplicateComponent('Constant Thrust and Isp','customThruster');
end
customThruster.Isp = 720;
customThruster.Thrust = 0.001;

man2 = mytars.Segments.Insert('eVASegmentTypeManeuver','man2','-');
man2.Properties.Color = uint32(hex2dec('00d3ff'));
man2.InitialState.SetElementType('eVAElementTypeKeplerian')
man2.FinalState.SetElementType('eVAElementTypeKeplerian')
man2.SetManeuverType('eVAManeuverTypeFinite');
man2.Maneuver.ThrustEfficiencyMode = 'eVAThrustTypeAffectsAccelAndMassFlow';%设置质量变化

maneuver = man2.Maneuver;
maneuver.SetAttitudeControlType('eVAAttitudeControlThrustVector');
maneuver.AttitudeControl.ThrustAxesName = 'Satellite VNC(Earth)';
maneuver.AttitudeControl.ThrustVector.AssignXYZ(1,0,0);
maneuver.Propagator.StoppingConditions.Item('Duration').Properties.Trip = 864000;
maneuver.Propagator.PropagatorName = 'Earth Point Mass';
maneuver.SetPropulsionMethod('eVAPropulsionMethodEngineModel','customThruster');

propagate2 = MCS.Insert('eVASegmentTypePropagate','Propagate','-');
propagate2.PropagatorName = 'Earth Point Mass';
propagate2.Properties.Color = uint32(hex2dec('00ff00'));
propagate2.StoppingConditions.Item('Duration').Properties.Trip = 3600;


%如何只运行一段？
%如何设置初始的时间
% sat.Propagator.RunMCS %运行