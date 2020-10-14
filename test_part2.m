%% ���������ķ�ֵ
componentAstrogator = sc.ComponentDirectory.GetComponents('eComponentAstrogator');
engineModels = componentAstrogator.GetFolder('Engine Models');
customThruster = engineModels.Item('New Constant Thrust and Isp');
customThruster.Isp = 720;
customThruster.Thrust = 0.001;

%% ���������ķ����
man1.Maneuver.SetPropulsionMethod('eVAPropulsionMethodEngineModel','New Constant Thrust and Isp');%���÷�����
% man1.Maneuver.SetPropulsionMethod('eVAPropulsionMethodEngineModel','Custom Engine');
man1.Maneuver.AttitudeControl.ThrustVector.AssignXYZ(1,0,0);
man1.Maneuver.Propagator.PropagatorName =  'Earth Point Mass';  %����ѧģ��
man1.Maneuver.SetAttitudeControlType('eVAAttitudeControlThrustVector');%��̬��������
man1.Maneuver.AttitudeControl.ThrustAxesName = 'Satellite LVLH'; %�������õ�����ϵ
man1.Maneuver.Propagator.StoppingConditions.Item('Duration').Properties.Trip = 600;




%���ֻ����һ�Σ�
%������ó�ʼ��ʱ��
% sat.Propagator.RunMCS %����