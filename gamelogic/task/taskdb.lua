ctaskdb = class("ctaskdb")

function ctaskdb:init(pid)
	self.pid = pid
	self.loadstate = "unload"
	self.taskcontainers = {}
	for name,data in pairs(data_1500_GlobalTask) do
		local tasktype = data.tasktype
		local taskcontainer = taskaux.newcontainer(name,pid,tasktype)
		self:addtaskcontainer(taskcontainer)
	end
	self.canaccepttask = {}
end

function ctaskdb:load(data)
	if not data or not next(data) then
		return
	end
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self[name]
		taskcontainer:load(data[name])
	end
end

function ctaskdb:save()
	local data = {}
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self[name]
		data[name] = taskcontainer:save()
	end
	return data
end

function ctaskdb:clear()
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self[name]
		taskcontainer:clear()
	end
end

function ctaskdb:addtaskcontainer(taskcontainer)
	local name = assert(taskcontainer.name)
	assert(self.taskcontainers[name] == nil)
	self.taskcontainers[name] = true
	self[name] = taskcontainer
end

function ctaskdb:gettaskcontainer(taskid)
	local tasktype = math.floor(taskid / 100000)
	local name = taskaux.gettaskname(tasktype)
	return self[name]
end

function ctaskdb:gettask(taskid)
	local taskcontainer = self:gettaskcontainer(taskid)
	if not taskcontainer then
		return
	end
	local task = taskcontainer:gettask(taskid)
	return task
end

function ctaskdb:update_canaccept()
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self[name]
		if taskcontainer.autoaccept then
			taskcontainer:autoaccept()
		end
	end
	self.canaccepttask = {}
	for name,_ in pairs(self.taskcontainers) do 
		local taskcontainer = self[name]
		local canaccept = taskcontainer:getcanaccept()
		if not table.isempty(canaccept) then
			table.extend(self.canaccepttask,canaccept)
		end
	end
	net.task.S2C.update_canaccept(self.pid,self.canaccepttask)
end

function ctaskdb:incanaccept(taskkey)
	for _,canaccept in ipairs(self.canaccepttask) do
		if canaccept.taskkey == taskkey then
			return true
		end
	end
	return false
end

function ctaskdb:oncreate(player)
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self[name]
		if taskcontainer.oncreate then
			taskcontainer:oncreate(player)
		end
	end
end

function ctaskdb:onlogin(player)
	local alltask = {}
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self[name]
		if taskcontainer.onlogin then
			taskcontainer:onlogin(player)
		end
		table.extend(alltask,taskcontainer:getallsendtask())
	end
	if next(alltask) then
		net.task.S2C.alltask(self.pid,alltask)
	end
	self:update_canaccept()
end

function ctaskdb:onlogoff(player,reason)
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self[name]
		if taskcontainer.onlogoff then
			taskcontainer:onlogoff(player,reason)
		end
	end
end

function ctaskdb:onchangelv()
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self[name]
		if taskcontainer.onchangelv then
			taskcontainer:onchangelv()
		end
	end
	self:update_canaccept()
end

function ctaskdb:onchangejoblv()
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self[name]
		if taskcontainer.onchangjoblv then
			taskcontainer:onchangejoblv()
		end
	end
	self:update_canaccept()
end

-- 物品(itemtype)增加数量(num)
function ctaskdb:onadditem(itemtype,num)
end

-- 物品(itemtype)减少数量(num)
function ctaskdb:ondelitem(itemtype,num)
end

function ctaskdb:onaddpet(pettype,num)
end

function ctaskdb:ondelpet(pettype,num)
end

function ctaskdb:onfivehourupdate()
	local player = playermgr.getplayer(self.pid)
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self[name]
		if taskcontainer.onfivehourupdate then
			taskcontainer:onfivehourupdate(player)
		end
	end
	self:update_canaccept()
end

function ctaskdb:oncleartoday(dataunit)
	for name,_ in pairs(self.taskcontainers) do
		local taskcontainer = self[name]
		if taskcontainer.oncleartoday then
			taskcontainer:oncleartoday(dataunit)
		end
	end
end

function ctaskdb:isfinishtask(taskid)
	local taskcontainer = self:gettaskcontainer(taskid)
	if not taskcontainer then
		return false
	end
	if not taskcontainer.finishtasks[taskid] then
		return false
	end
	return true
end

return ctaskdb

