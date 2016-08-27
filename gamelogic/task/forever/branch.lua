--支线任务
cbranchtask = class("cbranchtask",ctaskcontainer)

function cbranchtask:init(conf)
	ctaskcontainer.init(self,conf)
end

function cbranchtask:addtask(task)
	ctaskcontainer.addtask(self,task)
	local player = playermgr.getplayer(self.pid)
	local chapterid = self:getformdata("task")[task.taskid].chapterid
	if chapterid then
		player.chapterdb:unlockchapter(chapterid)
	end
end

function cbranchtask:onwarend(war,result)
	ctaskcontainer.onwarend(self,war,result)
	local player = playermgr.getplayer(self.pid)
	local chapterid = self:getformdata("task")[war.taskid].chapterid
	if chapterid then
		war.chapterid = chapterid
		player.chapterdb:onwarend(war,result)
	end
end

function cbranchtask:getcanaccept()
	local canaccept = {}
	for taskid,_ in pairs(self:getformdata("task")) do
		if not self.finishtasks[taskid] then
			local isok,msg = self:can_accept(taskid)
			if isok then
				table.insert(canaccept,{ taskkey = self.name, taskid = taskid })
			end
		end
	end
	return canaccept
end

function cbranchtask:can_directaccept(taskid)
	return true
end

function cbranchtask:directaccept(taskid)
	local isaccept = ctaskcontainer.directaccept(self,taskid)
	if isaccept then
		local taskname = self:getformdata("task")[taskid].name
		net.msg.S2C.notify(self.pid,language.format("接受【{1}】",taskname))
	end
	return isaccept
end

return cbranchtask
