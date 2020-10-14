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




%如何只运行一段？
%如何设置初始的时间
% sat.Propagator.RunMCS %运行