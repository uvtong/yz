--主线任务
cmaintask = class("cmaintask",ctaskcontainer)

function cmaintask:init(conf)
	ctaskcontainer.init(self,conf)
end

function cmaintask:addtask(task)
	ctaskcontainer.addtask(self,task)
	local player = playermgr.getplayer(self.pid)
	local chapterid = self:getformdata("task")[task.taskid].chapterid
	if chapterid then
		player.chapterdb:unlockchapter(chapterid)
	end
end

function cmaintask:onwarend(war,result)
	ctaskcontainer.onwarend(self,war,result)
	local player = playermgr.getplayer(self.pid)
	local chapterid = self:getformdata("task")[war.taskid].chapterid
	if chapterid then
		war.chapterid = chapterid
		player.chapterdb:onwarend(war,result)
	end
end

function cmaintask:onlogin(player)
	if player:query("logincnt") == 1 then
		local taskid = 10000101
		if self:can_accept(taskid) then
			self:accepttask(taskid)
		end
	end
	ctaskcontainer.onlogin(self,player)
end

function cmaintask:getcanaccept()
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


return cmaintask
