require "gamelogic.task.task"
require "gamelogic.task.taskdb"
require "gamelogic.task.taskcontainer"
require "gamelogic.task.forever.main"
require "gamelogic.task.forever.branch"
require "gamelogic.task.today.shimen"
require "gamelogic.task.today.shimoshilian"
require "gamelogic.task.today.babatuosi"
require "gamelogic.task.forever.zhuanzhi"
require "gamelogic.task.forever.zhiyin"
require "gamelogic.task.union.paoshang"

--任务容器类注册
g_taskcls = {
	main = cmaintask,
	branch = cbranchtask,
	shimen = cshimentask,
	shimoshilian = cshimoshiliantask,
	zhuanzhi = czhuanzhitask,
	zhiyin = czhiyintask,
	babatuosi = cbabatuositask,
	paoshang = cpaoshangtask,
}
