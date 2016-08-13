gm = require "gamelogic.gm.init"

local task = {}

function gm.task(args)
	local funcname = args[1]
	local player = playermgr.getplayer(master_pid)
	if not player then
		return
	end
	local func = task[funcname]
	if not func then
		net.msg.S2C.notify("指令未找到，查看帮助:help task")
		return
	end
	table.remove(args,1)
	func(player,args)
end

--- 指令: task open
--- 用法: task open test <=> 随机接受test类型任务
function task.open(player,args)
	local isok,args = checkargs(args,"string")
	if not isok then
		net.msg.S2C.notify(player.pid,"task open test <=> 随机接受test类型任务")
		return
	end
	local taskkey = args[1]
	net.task.C2S.opentask(player,{ taskkey = taskkey })
end

--- 指令: task add
--- 用法: task add 90000001 <=> 接受90000001任务
function task.add(player,args)
	local isok,args = checkargs(args,"int")
	if not isok then
		net.msg.S2C.notify(player.pid,"task add 90000001 <=> 接受90000001任务")
		return
	end
	local taskid = args[1]
	net.task.C2S.accepttask(player,{ taskid = taskid })
end

--- 指令: task execute
--- 用法: task execute 90000001 <=> 执行任务90000001,触发任务执行行为
function task.execute(player,args)
	local isok,args = checkargs(args,"int")
	if not isok then
		net.msg.S2C.notify(player.pid,"task execute 90000001 <=> 执行90000001任务")
		return
	end
	local taskid = args[1]
	net.task.C2S.executetask(player,{ taskid = taskid })
end

--- 指令: task delete
--- 用法: task delete 90000001 <=> 删除任务90000001
function task.delete(player,args)
	local isok,args = checkargs(args,"int")
	if not isok then
		net.msg.S2C.notify(player.pid,"task delete 90000001 <=> 删除90000001任务")
		return
	end
	local taskid = args[1]
	local taskcontainer = player.taskdb:gettaskcontainer(taskid)
	taskcontainer:deltask(taskid,"gm")
end

--- 指令: task endwar
--- 用法: task endwar 90000003 1 <=> 结束任务90000003中的战斗,>0:胜利,0--平局,<0:失败
function task.endwar(player,args)
	local isok,args = checkargs(args,"int","int")
	if not isok then
		net.msg.S2C.notify(player.pid,"用法: task endwar 90000003 1 <=> 结束任务90000003中的战斗,>0:胜利,0--平局,<0:失败")
		return
	end
	local taskid = args[1]
	local iswin = args[2]
	local task = player.taskdb:gettask(taskid)
	if not task or not task.inwar then
		net.msg.S2C.notify(player.pid,"任务编号错误")
		return
	end
	if not player.warid then
		net.msg.S2C.notify(player.pid,"玩家不在战斗中")
		return
	end
	warmgr.onwarend(player.warid,iswin)
	net.msg.S2C.notify(player.pid,"任务战斗结束")
end

--- 指令: task submit
--- 用法: task submit 90000001 <=> 提交任务90000001
function task.submit(player,args)
	local isok,args = checkargs(args,"int")
	if not isok then
		net.msg.S2C.notify(player.pid,"用法: task submit 90000001 <=> 提交任务90000001")
	end
	local taskid = args[1]
	net.task.C2S.submittask(player,{ taskid = taskid })
end

--- 指令: task finish
--- 用法: task finish 90000001 <=> 立即完成任务
function task.finish(player,args)
	local isok,args = checkargs(args,"int")
	if not isok then
		net.msg.S2C.notify(player.pid,"用法: task finish 90000001 <=> 立即完成任务")
	end
	local taskid = args[1]
	local task = player.taskdb:gettask(taskid)
	if not task then
		return
	end
	local taskcontainer = player.taskdb:gettaskcontainer(taskid)
	taskcontainer:finishtask(task,"gm")
end

task.onwarend = task.endwar
