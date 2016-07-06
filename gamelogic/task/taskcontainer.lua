require "gamelogic.base.container"
require "gamelogic.template.template"

ctaskcontainer = class("ctaskcontainer",ccontainer,ctemplate)

function ctaskcontainer:init(conf)
	ccontainer.init(self,conf)
	ctemplate.init(self,conf)
	self.finishtasks = {}
	self.nowtaskid = nil  -- 仅对同时只有一个任务的任务类有效
	--脚本注册
	self.script_handle.find = "findnpc"
	self.script_handle.verify = "verifynpc"
	self.script_handle.item = "needitem"
	self.script_handle.patrol = "setpatrol"
	self.script_handle.progress = "progressbar"
	self.script_handle.handin = "handinitem"
	self.script_handle.nexttask = "givenexttask"
	self.script_handle.finish = "finishtask"
end

function ctaskcontainer:load(data)
	if not data or not next(data) then
		return
	end
	ccontainer.load(self,data,function(objdata)
		local taskid = objdata.taskid
		local task = self:__newtask({taskid = taskid})
		if not task then
			self:log("info","task",string.format("[load unknow task] pid=%s taskid=%s",self.pid,taskid))
			return nil
		end
		task:load(objdata)
		self:loadres(task,objdata)
		return task
	end)
	self.nowtaskid = data.nowtaskid
	local finishtasks = data.finishtasks or {}
	for i,taskid in ipairs(finishtasks) do
		self.finishtasks[taskid] = true
	end
end

function ctaskcontainer:save()
	local data = ccontainer.save(self,function(obj)
		local data = obj:save()
		self:saveres(obj,data)
		return data
	end)
	data.nowtaskid = self.nowtaskid
	data.finishtasks = table.values(self.finishtasks)
	return data
end

function ctaskcontainer:clear()
	self:log("info","task",string.format("clear,pid=%s",self.pid))
	ccontainer.clear(self)
	-- 累积完成任务又使用者决定是否清空
	--self.finishtasks = {}
end


function ctaskcontainer:onlogin(player)
	self:sendalltask()
end

function ctaskcontainer:onlogoff(player)
end

function ctaskcontainer:onclear(tasks)
	for _,task in pairs(tasks) do
		self:ondel(task)
	end
end

function ctaskcontainer:ondel(task)
	self:release(task)
	net.task.S2C.deltask(self.pid,task.taskid)
end

function ctaskcontainer:onadd(task)
	net.task.S2C.addtask(self.pid,self:pack(task))
end

function ctaskcontainer:onwarend(warid,result)
	local wardata = getwarinfo(warid)
	local taskid  = assert(wardata.info.taskid)
	local npcid = assert(wardata.info.npcid)
	local task =self:gettask(taskid)
	if task then
		self:setcurrentnpc(task,npcid)
		if WAR_IS_WIN(result) then
			self:finishtask(task)
		else
			self:failtask(task)
		end
	end
end

function ctaskcontainer:doscript(playunit,script,pid,...)
	local result = ctemplate.doscript(self,playunit,script,pid,...)
	if not result then
		return TASK_SCRIPT_FINISH
	end
	return result
end

function ctaskcontainer:raisewar(playunit,arg,pid,npc)
	ctemplate.raisewar(self,playunit,arg,pid,npc)
	return TASK_SCRIPT_SUSPEND
end

function ctaskcontainer:isdonelimit(player,count,spacing)
	return false
end

--内部接口
function ctaskcontainer:gettask(taskid,nocheckvalid)
	--任务超时的机制看是否改下，接触与get的耦合
	local task = self:get(taskid)
	if task then
		if not nocheckvalid then
			if task.exceedtime then
				local now = os.time()
				if now >= task.exceedtime then
					self:deltask(taskid,"timeout")
					return
				end
			end
		end
	end
	return task
end

function ctaskcontainer:__newtask(conf)
	local taskid = assert(conf.taskid)
	local taskdata = self.formdata.taskinfo[taskid]
	if taskdata then
		conf.state = TASK_STATE_ACCEPT
		conf.type = taskdata.type
		conf.owner = self.pid
		if taskdata.exceedtime then
			if taskdata.exceedtime == "today" then
				conf.exceedtime = getdayzerotime() + DAY_SECS + 5 * HOUR_SECS
			elseif taskdata.exceedtime == "thisweek" then
				conf.exceedtime = getweekzerotime() + DAY_SECS * 7 + 5 * HOUR_SECS
			elseif taskdata.exceedtime == "thisweek2" then
				conf.exceedtime = getweek2zerotime() + DAY_SECS * 7 + 5 * HOUR_SECS
			elseif taskdata.exceedtime == "thismonth" then
				local now = os.time()
				conf.exceedtime = os.time({year=getyear(now),month=getyearmonth(now)+1,day=1,hour=5,min=0,sec=0,})
			elseif taskdata.exceedtime == "forever" then
			else
				local secs = assert(tonumber(taskdata.exceedtime))
				secs = math.floor(secs)
				conf.exceedtime = os.time() + secs
			end
		end
		local task =  ctask.new(conf)
		self:loadres(task,nil)
		return task
	end
end

function ctaskcontainer:addtask(task)
	local taskid = task.taskid
	assert(self:get(taskid) == nil,"Repeat taskid:" .. tostring(taskid))
	self:log("info","task",string.format("addtask,pid=%d taskid=%d",self.pid,taskid))
	self:add(task,taskid)
	self.nowtaskid = taskid
end

function ctaskcontainer:deltask(taskid,reason)
	local task = self:get(taskid)
	if task then
		self:log("info","task",string.format("deltask,pid=%d taskid=%d reason=%s",self.pid,taskid,reason))
		self:del(taskid)
		self.nowtaskid = nil  -- nowtaskid只对同时只有一个任务的任务类有效
		return task
	end
end

function ctaskcontainer:sendalltask()
	local tasks = {}
	for _,task in ipairs(self.objs) do
		table.insert(tasks,self:pack(task))
	end
	net.task.S2C.alltask(self.pid,tasks)
end

function ctaskcontainer:refreshtask(taskid)
	local task = self:gettask(taskid)
	if task then
		net.task.S2C.updatetask(self.pid,self:pack(task))
	end
end

function ctaskcontainer:addfinishtask(taskid)
	self.finishtasks[taskid] = true
end

function ctaskcontainer:failtask(task)
	local failscript = self.formdata.taskinfo[task.taskid].fail
	for _,script in ipairs(failscript) do
		self:doscript(task,script,self.pid)
	end
end

function ctaskcontainer:pack(task)
	local data = {}
	data.taskid = task.taskid
	data.state = task.state
	data.exceedtime = task.exceedtime
	data.findnpc = task.resourcemgr:get("findnpc")
	data.patrol = task.resourcemgr:get("patrol")
	data.progress = task.resourcemgr:get("progresstime")
	local itemneed = task.resourcemgr:get("itemneed")
	if itemneed then
		data.items = {}
		for itemtype,num in pairs(itemneed) do
			table.insert(data.items,{
				type = itemtype,
				num = num,
			})
		end
	end
	if next(task.resourcemgr.npclist) then
		data.npcs = {}
		for _,npc in pairs(task.resourcemgr.npclist) do
			table.insert(data.npcs,npc:pack())
		end
	end
	return data
end


--脚本接口
function ctaskcontainer:findnpc(task,arg)
	local nid = arg
	task.resourcemgr:set("findnpc",nid)
end

function ctaskcontainer:verifynpc(task,arg,pid,npc)
	local findnpc = task.resourcemgr:get("findnpc")
	if not npc or findnpc ~= npc.nid then
		return TASK_SCRIPT_FAIL
	end
end

function ctaskcontainer:needitem(task,arg)
	local itemtype = arg.type
	local itemnum = arg.num
	local itemneed = task.resourcemgr:get("itemneed",{})
	if not itemneed[itemtype] then
		itemneed[itemtype] = 0
	end
	itemneed[itemtype] = itemneed[itemtype] + itemnum
	task.resourcemgr:set("itemneed",itemneed)
end

function ctaskcontainer:handinitem(task,arg,pid,npc,ext)
	local taskinfo = self.formdata.taskinfo[task.taskid]
	local player = playermgr.getplayer(self.pid)
	local itemneed = task.resourcemgr:get("itemneed")
	if not itemneed then
		return
	end
	local handinlst = nil
	if taskinfo.autohandin ~= 1 then
		handinlst,msg = self:manualhandin(player,itemneed,ext)
	else
		handinlst,msg = self:autohandin(player,itemneed)
	end
	if not handinlst then
		if msg and npc then
			npc:say(self.pid,msg)
		end
		return TASK_SCRIPT_FAIL
	end
	self:log("info","task",string.format("handin,pid=%d,item=%s",pid,mytostring(itemneed)))
	self:truehandin(player,handinlst)
end

function ctaskcontainer:manualhandin(player,itemneed,ext)
	if not ext or not next(ext) then
		return
	end
	local type_num = {}
	local handinlst = {}
	for _,value in ipairs(ext) do
		local itemid = value.itemid
		local num = value.num
		local itemobj = player.itemdb:getitem(itemid)
		if not itemobj or itemobj.num < num then
			return
		end
		if not itemneed[itemobj.type] then
			return nil,language.format("%s不是需求的物品",itemobj.name)
		end
		type_num[itemobj.type] = (type_num[itemobj.type] or 0) + num
		handinlst[itemid] = (handinlst[itemid] or 0) + num
	end
	for type,num in pairs(itemneed) do
		if not type_num[type] or type_num[type] < num then
			return nil,"物品数量不足"
		end
	end
	return handinlst
end

function ctaskcontainer:autohandin(player,itemneed)
	local type_num = {}
	local handinlst = {}
	for type,num in pairs(itemneed) do
		type_num[type] = 0
		local items = player.itemdb:getitemsbytype(type,function(item)
			return true
		end)
		table.sort(items,function(item1,item2)
			return true
		end)
		for _,itemobj in ipairs(items) do
			if type_num[type] + itemobj.num < num then
				handinlst[itemobj.id] = itemobj.num
				type_num[type] = type_num[type] + itemobj.num
			else
				handinlst[itemobj.id] = num - type_num[type]
				type_num[type] = num
				break
			end
		end
		if type_num[type] ~= num then
			return nil
		end
	end
	return handinlst
end

function ctaskcontainer:truehandin(player,handinlst)
	for itemid,num in pairs(handinlst) do
		player.itemdb:costitembyid(itemid,num,string.format("task_%s",self.name))
	end
end

function ctaskcontainer:setpatrol(task,arg,pid,npc)
	local scid,x,y = arg.scene,arg.x,arg.y
	scid,x,y = self:transcode(scid)
	if not x and not y then
		--x,y = self:randompos(scid)
	end
	task.resourcemgr:set("patrol",{scid,x,y})
end

function ctaskcontainer:progressbar(task,arg,pid,npc)
	local time = arg
	task.resourcemgr:set("progresstime",time)
end

function ctaskcontainer:finishtask(task)
	local taskid = task.taskid
	self:log("info","task",string.format("finishtask,pid=%d taskid=%d",self.pid,task.taskid))
	task.state = TASK_STATE_FINISH
	local taskdata = self.formdata.taskinfo[taskid]
	if taskdata.submitnpc == 0 then
		self:submittask(taskid)
	else
		self:refreshtask(taskid)
	end
end

function ctaskcontainer:givenexttask(task,arg,pid,npc)
	local newtaskid = arg
	local isok = self:can_accepttask(newtaskid)
	if not isok then
		return
	end
	self:accepttask(newtaskid,npc.nid)
end


--外部接口
function ctaskcontainer:accepttask(taskid,npcid)
	local task = self:__newtask({taskid = taskid})
	if task then
		self:setcurrentnpc(task,npcid)
		local acceptscript = self.formdata.taskinfo[taskid].accept
		for _,script in ipairs(acceptscript) do
			self:doscript(task,script,self.pid)
		end
		self:addtask(task)
	end
end

function ctaskcontainer:can_accept(taskid)
	local player = playermgr.getplayer(self.pid)
	if not player then
		return false
	end
	local taskdata = self.formdata.taskinfo[taskid]
	if taskdata.lvlimit and taskdata.lvlimit > player.lv then
		return false,language.format("玩家等级到达%s级才可以领取该任务",taskdata.lvlimit)
	end
	if taskdata.joblimit and next(taskdata.joblimit) then
		local isok = false
		for _,job in ipairs(taskdata.joblimit) do
			if player.job == job then
				isok = true
				break
			end
		end
		if not isok then
			return false,"职业不符合领取条件"
		end
	end
	if taskdata.pretask and next(taskdata.pretask) then
		local isok = true
		for i,taskid in ipairs(taskdata.pretask) do
			if not self.finishtasks[taskid] then
				isok = false
			end
		end
		if not isok then
			return false,"前置任务未完成"
		end
	end
	if taskdata.donelimit and next(taskdata.donelimit) then
		local islimit,msg = self:isdonelimit(player,taskdata.donelimit.count,taskdata.donelimit.spacing)
		if islimit then
			return false,msg
		end
	end
	return true
end

function ctaskcontainer:giveuptask(taskid)
	local task = self:gettask(taskid)
	if task then
		self:deltask(taskid,"giveup")
		return task
	end
end

function ctaskcontainer:can_giveup(taskid)
	local taskdata = self.formdata.taskinfo[taskid]
	if not istrue(taskdata.cangiveup) then
		return false,"该任务无法放弃"
	end
	return true
end

function ctaskcontainer:executetask(taskid,npcid,ext)
	local task = self:gettask(taskid)
	self:setcurrentnpc(task,npcid)
	local executescript = self.formdata.taskinfo[taskid].execution
	local result = TASK_SCRIPT_FINISH
	for _,script in ipairs(executescript) do
		result = self:doscript(task,script,self.pid,ext)
		if result ==TASK_SCRIPT_SUSPEND then
			return
		end
		if result == TASK_SCRIPT_FAIL then
			self:failtask(task)
			return
		end
	end
	if result ==TASK_SCRIPT_FINISH then
		self:finishtask(task)
	end
end

function ctaskcontainer:can_execute(taskid)
	local task = self:gettask(taskid)
	if not task then
		return false,"任务已失效"
	end
	if task.state == TASK_FINISH then
		return false
	end
	return true
end

function ctaskcontainer:submittask(taskid,npcid)
	local task = self:gettask(taskid)
	self:setcurrentnpc(task,npcid)
	self:addfinishtask(taskid)
	local submitscript = self.formdata.taskinfo[taskid].submit
	for _,script in ipairs(submitscript) do
		self:doscript(task,script,self.pid)
	end
	self:deltask(taskid,"taskdone")
end

function ctaskcontainer:can_submit(taskid)
	local task = self:gettask(taskid)
	if not task then
		return false,"任务已失效"
	end
	if task.state ~= TASK_STATE_FINISH then
		return false,"任务未完成"
	end
	return true
end

function ctaskcontainer:clientfinishtask(taskid)
	local task = self:gettask(taskid)
	self:finishtask(task)
end

function ctaskcontainer:can_clientfinish(taskid)
	local task = self:gettask(taskid)
	if not task then
		return false,"任务已失效"
	end
	local taskdata = self.formdata.taskinfo[taskid]
	if taskdata.finishbyclient ~= 1 then
		return false
	end
	return true
end

return ctaskcontainer
