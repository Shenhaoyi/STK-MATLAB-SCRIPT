uiap = actxserver('STK11.application');
root = uiap.Personality2;
%��������
root.NewScenario('Astro');
sc = root.CurrentScenario;
%��������
sat = sc.Children.New(18,'mysat');  %sc.Children.New('eSatellite', 'MySatellite')
%ͨ���������䣬�ͽ����ǹ�����������Ͷ���Ϊ��Astrogator����
sat.SetPropagatorType('ePropagatorAstrogator');
%��ȡģ������
satMS = sat.Propagator.MainSequence;
%�������ģ�飬Ȼ�������ģ�顣
satMS.RemoveAll();
%�Ȳ���Target Sequenceģ��
mytars = satMS.Insert('eVASegmentTypeTargetSequence','mytarget','-');
%��Target Sequenceģ��ǰ�����ʼ״̬ģ��
myinit = satMS.Insert('eVASegmentTypeInitialState','myinit','mytarget');
%��������䣬�Ϳ��Կ���Insert������ʹ�÷�ʽ�����������ֱ��ǣ�ģ�����͡��Զ����ģ�����ơ���һ��ģ������ƣ��ڸ�ģ��ǰ�����µ�ģ�飩
pro500 = satMS.Insert('eVASegmentTypePropagate','pro500','mytarget');

%�������ǳ�ʼ״̬��500kmԲ��������50�㣬��������ѡ��Ĭ��ֵ
%���ù����������Ϊ�����������ʽ��Ĭ��Ϊ�ѿ�����ʽ
myinit.InitialState.SetElementType('eVAElementTypeKeplerian');
%���ù���߶�Ϊ500km��û���õĻ���Ĭ��ֵ
myinit.InitialState.Element.SemiMajorAxis = 6.8781e+03;
myinit.InitialState.Element.Inclination = 50;

%��ʼ����
sat.Propagator.MainSequence.Item(0).InitialState.DryMass =1000;


%����pro500ģ������500s
%Propagateģ��Ĭ�ϵ�ֹͣ����������ʱ�䣬�������ǾͲ��޸���
pro500.StoppingConditions.Item(0).Properties.Trip = 500;
% ִ����������䣬������˹����ʼ״̬���ã����ǿ�����500s��
% ���Ƚ���һ�»���ת�ƣ����α�죬ʵ�ֹ��ת�ơ������ʡȼ�ϵĹ��ת�Ʒ�ʽ�����ڱ��������������ε�𣬵ڶ��ε����Զ�ص�ʵʩ��Ϊ�򻯷�������������ʹ�����������ʽ�����������ķ�ʽ�����������۵���
% ��������Ҳ���Ǳ��ĵĹؼ�������Target Sequenceģ�������ʵ�ֻ���ת�ơ���Target Sequenceģ�������ģ�飺
%��һ������������
man_hm1 = mytars.Segments.Insert('eVASegmentTypeManeuver','man_hm1','-');
Pro2App = mytars.Segments.Insert('eVASegmentTypePropagate','Pro2App','-');
man_hm2 = mytars.Segments.Insert('eVASegmentTypeManeuver','man_hm2','-');


% ��Target Sequenceģ������Ϊ����״̬
mytars.Action = 'eVATargetSeqActionRunActiveProfiles';

sat.Propagator.RunMCS