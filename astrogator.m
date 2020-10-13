uiap = actxserver('STK11.application');
root = uiap.Personality2;
%创建场景
root.NewScenario('Astro');
sc = root.CurrentScenario;
%创建卫星
sat = sc.Children.New(18,'mysat');  %sc.Children.New('eSatellite', 'MySatellite')
%通过下面的语句，就将卫星轨道生成器类型定义为了Astrogator类型
sat.SetPropagatorType('ePropagatorAstrogator');
%获取模块序列
satMS = sat.Propagator.MainSequence;
%清除所有模块，然后再添加模块。
satMS.RemoveAll();
%先插入Target Sequence模块
mytars = satMS.Insert('eVASegmentTypeTargetSequence','mytarget','-');
%在Target Sequence模块前插入初始状态模块
myinit = satMS.Insert('eVASegmentTypeInitialState','myinit','mytarget');
%从上面语句，就可以看出Insert方法的使用方式，三个参数分别是：模块类型、自定义的模块名称、后一个模块的名称（在该模块前插入新的模块）
pro500 = satMS.Insert('eVASegmentTypePropagate','pro500','mytarget');

%设置卫星初始状态，500km圆轨道，倾角50°，其他参数选用默认值
%设置轨道参数类型为轨道六根数形式，默认为笛卡尔形式
myinit.InitialState.SetElementType('eVAElementTypeKeplerian');
%设置轨道高度为500km，没设置的会有默认值
myinit.InitialState.Element.SemiMajorAxis = 6.8781e+03;
myinit.InitialState.Element.Inclination = 50;

%初始质量
sat.Propagator.MainSequence.Item(0).InitialState.DryMass =1000;


%设置pro500模块运行500s
%Propagate模块默认的停止条件是运行时间，这里我们就不修改了
pro500.StoppingConditions.Item(0).Properties.Trip = 500;
% 执行完以上语句，就完成了轨道初始状态设置，卫星可运行500s。
% 首先解释一下霍曼转移：两次变轨，实现轨道转移。是最节省燃料的轨道转移方式。对于本案例，卫星两次点火，第二次点火在远地点实施。为简化分析，这里我们使用脉冲机动方式，有限推力的方式，后续会讨论到。
% 接下来，也就是本文的关键，设置Target Sequence模块参数，实现霍曼转移。向Target Sequence模块添加子模块：
%第一次脉冲点火设置
man_hm1 = mytars.Segments.Insert('eVASegmentTypeManeuver','man_hm1','-');
Pro2App = mytars.Segments.Insert('eVASegmentTypePropagate','Pro2App','-');
man_hm2 = mytars.Segments.Insert('eVASegmentTypeManeuver','man_hm2','-');


% 将Target Sequence模块设置为激活状态
mytars.Action = 'eVATargetSeqActionRunActiveProfiles';

sat.Propagator.RunMCS