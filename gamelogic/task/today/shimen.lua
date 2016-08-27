--师门任务
local g_specialtask = {}

cshimentask = class("cshimentask",ctaskcontainer)

function cshimentask:init(conf)
	ctaskcontainer.init(self,conf)
	self.isautohandin = true
	self.ringnum = 1
end

function cshimentask:nexttask(taskid,reason)
	if self:reachlimit() then
		return nil,language.format("今天已经完成20环协会请援")
	end
	local player = playermgr.getplayer(self.pid)
	if player.lv < 10 then
		return nil,language.format("等级不足，无法接受")
	end
	return ctaskcontainer.nexttask(self,taskid,reason)
end

function cshimentask:can_open()
	for _,task in pairs(self.objs) do
		-- 普通师门只能接一个
		if not table.find(g_specialtask,task.taskid) then
			return false,language.format("无法重复领取该任务")
		end
	end
	return true
end

function cshimentask:opentask()
	local player = playermgr.getplayer(self.pid)
	if player.today:query("task.shimen.giveup") then
		local npc = data_0601_NPC[20001001]
		local silver = 100
		net.msg.S2C.npcsay(self.pid,npc,
			language.format("协会任务在今天放弃过，是否支付{1}银币再次领取",silver),
			{ language.format("确认"), language.format("取消") },
			function(pid,request,respond)
				local player = playermgr.getplayer(pid)
				if not player or not player.today:query("task.shimen.giveup") or respond.answer ~= 1 then
					return
				end
				local silver = request[1]
				if not player:validpay("silver",silver,true) then
					return
				end
				player:addres("silver",-silver,"rmshimengiveup",true)
				player.today:delete("task.shimen.giveup")
				player.taskdb.shimen:opentask()
			end,
			silver
		)
		return false
	end
	return ctaskcontainer.opentask(self)
end

function cshimentask:onsubmittask(taskid)
	if table.find(g_specialtask,taskid) then
		player.thistemp:set("task.shimen.specialdone",1,3600*36)
		return
	end
	local ringlimit = self:getformdata("ringlimit")
	if self.ringnum % 10 == 0 then
		local playtype = self:getformdata("task")[taskid].type
		local itemtype = self:getformdata("var").RingDoneAward[playtype]
		local player = playermgr.getplayer(self.pid)
		self:log("info","task",format("[ringdoneaward] pid=%d itemtype=%d ring=%d",self.pid,itemtype,self.ringnum))
		player:additembytype(itemtype,1,nil,"shimenring")
		if self.ringnum == ringlimit then
			if not player.thistemp:query("task.shimen.specialdone") and ishit(50) then
				player.today:set("task.shimen.specialcapacity",1)
				-- TODO 通知客户端可以查看特殊任务面板
			end
		end
	end
	self.ringnum = (self.ringnum + 1) % ringlimit
	if self.ringnum == 0 then
		self.ringnum = ringlimit
	end
end

function cshimentask:transaward(task,awardid,pid)
	if awardid < 0 then
		local player = playermgr.getplayer(pid)
		local lv = player.lv
		local fakedata = self:getformdata("fake")[lv]
		awardid =  fakedata.awardid[-awardid]
	end
	local bonus = ctaskcontainer.transaward(self,task,awardid,pid)
	return bonus
end

function cshimentask:revisebonus(task,bonus)
	if table.find(g_specialtask,task.taskid) then
		return bonus
	end
	local promoteratio = self:getformdata("var").AwardPromoteRatio
	bonus.exp = math.floor(bonus.exp * (100 + (self.ringnum - 1) * promoteratio) / 100)
	bonus.jobexp = math.floor(bonus.jobexp * (100 + (self.ringnum - 1) * promoteratio) / 100)
	bonus.coin = math.floor(bonus.coin * (100 + (self.ringnum - 1) * promoteratio) / 100)
	return bonus
end

function cshimentask:onfivehourupdate()
	self:resettask()
end

function cshimentask:resettask()
	self.ringnum = 1
end

function cshimentask:giveuptask(taskid)
	local isok,msg = ctaskcontainer.giveuptask(self,taskid)
	if isok and not table.find(g_specialtask,taskid) then
		local player = playermgr.getplayer(self.pid)
		player.today:set("task.shimen.giveup",1)
	end
	return isok,msg
end

function cshimentask:can_directaccept(taskid)
	if not table.find(g_specialtask,taskid) then
		return false
	end	
	local player = playermgr.getplayer(self.pid)
	if not player.today:query("task.shimen.specialcapacity") then
		return false
	end
	return true
end

function cshimentask:directaccept(taskid)
	local isaccept = ctaskcontainer.directaccept(self,taskid)
	if isaccept then
		player.today:delete("task.shimen.specialcapacity")
	end
	return isaccept
end

return cshimentask
