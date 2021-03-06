local function test2(player,taskid)
	local container = player.taskdb:gettaskcontainer(taskid)
	assert(container:gettask(taskid))
	assert(not container:gettask(90000001))
	warmgr.onwarend(player:warid(),1)
	assert(not container:gettask(taskid))
end

local function test(pid)
	local player = playermgr.getplayer(pid)
	player.testman = 1
	player.taskdb:clear()
	local container = player.taskdb.test
	--开启任务
	net.task.C2S.opentask(player,{ taskkey = "test" })
	assert(container.len == 1)
	--寻人任务,服务端执行,自动提交
	net.task.C2S.accepttask(player,{ taskid = 90000001 })
	local task = player.taskdb:gettask(90000001)
	assert(task)
	net.task.C2S.executetask(player,{ taskid = 90000001 })
	task = player.taskdb:gettask(90000001)
	assert(not task)
	--寻人任务,客户端完成,自动提交
	net.task.C2S.accepttask(player,{taskid = 90000001 })
	task = player.taskdb:gettask(90000001)
	assert(task)
	net.task.C2S.finishtask(player,{taskid = 90000001 })
	task = player.taskdb:gettask(90000001)
	assert(not task)
	--寻物任务,服务端执行,自动提交
	net.task.C2S.accepttask(player,{taskid = 90000002})
	task = player.taskdb:gettask(90000002)
	assert(task)
	player.itemdb:clear()
	player:additembytype(501001,1,nil,"test")
	local itemobj = player.itemdb:getitemsbytype(501001)[1]
	local itemid = itemobj.id
	local ext = cjson.encode({{itemid=itemid,num=1},})
	net.task.C2S.executetask(player,{taskid = 90000002,ext = ext})
	itemobj = player:getitem(itemid)
	assert(not itemobj)
	task = player.taskdb:gettask(90000002)
	assert(not task)
	--明雷任务,服务端执行,模拟战斗先失败后胜利,客户端提交
	net.task.C2S.accepttask(player,{taskid = 90000003})
	task = player.taskdb:gettask(90000003)
	assert(task.state)
	net.task.C2S.executetask(player,{taskid = 90000003})
	assert(task.state == 1)
	local taskcontainer = player.taskdb:gettaskcontainer(90000003)
	taskcontainer:failtask(task)
	assert(task.state == 1)
	net.task.C2S.executetask(player,{taskid = 90000003})
	taskcontainer:finishtask(task)
	assert(task.state == 2)
	net.task.C2S.submittask(player,{taskid = 90000003})
	task = player.taskdb:gettask(90000003)
	assert(not task)
	--放弃任务
	net.task.C2S.accepttask(player,{taskid = 90000001})
	task = player.taskdb:gettask(90000001)
	assert(task)
	net.task.C2S.giveuptask(player,{taskid = 90000001})
	task = player.taskdb:gettask(90000001)
	assert(not task)
	--限时任务
	net.task.C2S.accepttask(player,{taskid = 90000003})
	net.task.C2S.accepttask(player,{taskid = 90000001})
	local now = os.time()
	task = player.taskdb:gettask(90000003)
	local task2 = player.taskdb:gettask(90000001)
	assert(task)
	task.exceedtime = now + 5
	task2.exceedtime = now + 5
	timer.timeout(format("task%d",player.pid),6,functor(test2,player,task.taskid))
	net.task.C2S.executetask(player,{taskid = 90000003})
end

local function test3(pid)
	local player = playermgr.getplayer(pid)
	assert(player)
	player.testman = 1
	player.taskdb.test:clear()
	local taskid = 90000010
	net.task.C2S.accepttask(player,{taskid = taskid})
	local task = player.taskdb:gettask(taskid)
	assert(task)
	net.task.C2S.executetask(player,{taskid = taskid})
	local respondid = reqresp.id
	net.msg.C2S.respondanswer(player,{ id = respondid, answer = 0})
	assert(task.execute_result == TASK_SCRIPT_NONE)
	net.task.C2S.executetask(player,{taskid = taskid})
	net.msg.C2S.respondanswer(player,{ id = respondid+1, answer = 1})
end

return test3
