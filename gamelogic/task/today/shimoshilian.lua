-- 使魔试炼
cshimoshiliantask = class("cshimoshiliantask",ctaskcontainer)

function cshimoshiliantask:init(conf)
	ctaskcontainer.init(self,conf)
end

function cshimoshiliantask:onfivehourupdate()
	local player = playermgr.getplayer(self.pid)
	local donecnt = self:getdonecnt(true)
	local donelimit = self:getdonelimit(true)
	local leftcnt = math.min(0,donelimit - donecnt)
	local adddonelimit = taskaux.gettaskdata(self.name,"donelimit")
	self:setdonelimit(leftcnt + adddonelimit,"onfivehourupdate")
	self.lasttaskid = nil
end

function cshimoshiliantask:can_accept(taskid)
	local player = playermgr.getplayer(self.pid)
	local fighters,errmsg = player:getfighters()
	if table.isempty(fighters) then
		return false,errmsg
	end
	local neednum = data_1500_ShiMoShiLianTaskVar.StartWarNeedNum
	if #fighters < neednum then
		return false,language.format("队伍人数不足#<R>#{1}人",neednum)
	end
	for i,uid in ipairs(fighters) do
		local member = playermgr.getplayer(uid)
		if member then
			local isok,errmsg = ctaskcontainer.can_accept(member.taskdb.shimoshilian,taskid)
			if not isok then
				return false,errmsg
			end
		end
	end
	return true
end

function cshimoshiliantask:can_raisewar()
	local player = playermgr.getplayer(self.pid)
	local fighters,errmsg = player:getfighters()
	if table.isempty(fighters) then
		return false,errmsg
	end
	local neednum = data_1500_ShiMoShiLianTaskVar.StartWarNeedNum
	local needlv = data_1500_ShiMoShiLianTaskVar.StartWarNeedLv
	if #fighters < neednum then
		return false,language.format("队伍人数不足#<R>#{1}人",neednum)
	end
	for i,uid in ipairs(fighters) do
		local member = playermgr.getplayer(uid)
		if member.lv < needlv then
			return false,language.format("成员#<G>{1}#等级不足#<R>{2}#级",member:getname(),needlv)
		end
	end
	return true
end

function cshimoshiliantask:transwar(task,warid,pid)
	assert(pid == self.pid)
	local war = ctaskcontainer.transwar(self,task,warid,pid)
	local player = playermgr.getplayer(pid)
	if warid < 0 then
		local lv = player:team_avglv(TEAM_STATE_CAPTAIN_FOLLOW)
		local fakedata = taskaux.gettaskdata(self.name,"fake")
		local data = fakedata[lv] or fakedata[#fakedata]
		warid = randlist(data.warids)
	end
	war.wardataid = warid
	war.wartype = WARTYPE.PVE_SHARE_TASK
	return war
end

function cshimoshiliantask:_transaward(awardid,lv)
	if awardid < 0 then
		local fakedata = taskaux.gettaskdata(self.name,"fake")
		local data = fakedata[lv] or fakedata[#fakedata]
		awardid = data.awardid
	end
	local awarddata = self:getformdata("award")
	local bonus = award.getaward(awarddata,awardid,function (i,data)
		return data.ratio
	end)
	local ringlimit = data_1500_ShiMoShiLianTaskVar.ringLimit
	bonus = deepcopy(bonus)
	return bonus
end

function cshimoshiliantask:transaward(task,awardid,pid)
	assert(pid == self.pid)
	local player = playermgr.getplayer(self.pid)
	local lv = player:team_avglv(TEAM_STATE_CAPTAIN_FOLLOW)
	local teamstate = player:teamstate()
	local ringlimit = data_1500_ShiMoShiLianTaskVar.RingLimit
	local bonus = self:_transaward(awardid)
	-- 队长经验加成
	if teamstate == TEAM_STATE_CAPTAIN then
		local captain_exp_adden = math.floor(bonus.exp * CAPTAIN_EXP_ADDEN)
		bonus.exp = bonus.exp + captain_exp_adden
		if self.ringnum == ringlimit then
			if not bonus.items then
				bonus.items = {}
			end
			local item = data_1500_ShiMoShiLianTaskVar.GiveItemToCaptainAt10Ring
			table.insert(bonus.items,item)
		end
	end
	-- 双倍点经验加成
	local dexp_adden = 0
	local isok,cost_dexp = player:can_cost_dexp(self.name)
	if isok then
		local dexp = player.thisweek:query("dexppoint") or 0
		if dexp >= cost_dexp then
			player.thisweek:add("dexppoint",-cost_dexp)
			dexp_adden = bonus.exp
		end
	end
	if dexp_adden > 0 then
		bonus.exp = bonus.exp + dexp_adden
	end
	return bonus
end

function cshimoshiliantask:nexttask(taskid,reason)
	local chinesename = taskaux.gettaskdata(self.name,"name")
	local donelimit = taskaux.gettaskdata(self.name,"donelimit")
	local donecnt = self:getdonecnt()
	local ringnum = self.ringnum or 0
	local ringlimit = data_1500_ShiMoShiLianTaskVar.RingLimit
	local look_npctype = data_1500_ShiMoShiLianTaskVar.LookNpcType
	local leftcnt = math.min(0,donelimit-donecnt)
	if donecnt >= donelimit then
		net.msg.S2C.messagebox(self.pid,
								MB_SHIMOSHILIAN_REACHLIMIT,
								language.format("次数耗尽"),
								language.format("【{1}】次数耗尽，继续任务将不会获得奖励。\n剩余次数：{2}/{3}",chinesename,leftcnt,donelimit),
								{},
								{language.format("确认")})
		return
	end
	if reason ~= "opentask" and ringnum >= ringlimit then
		local player = playermgr.getplayer(self.pid)
		if player and player:teamstate() == TEAM_STATE_CAPTAIN then
			net.msg.S2C.messagebox(self.pid,
								MB_SHIMOSHILIAN_10_RING,
								language.format("任务完成"),
								language.format("已完成{1}环【{2}】。\n剩余次数：{3}/{4}",ringlimit,chinesename,leftcnt,donelimit),
								{npctype=look_npctype},
								{language.format("取消"),language.format("继续"),})
		end
		return
	end
	local next_taskid,errmsg
	if self._next_taskid then
		next_taskid = self._next_taskid
		self._next_taskid = nil
	else
		next_taskid,errmsg = ctaskcontainer.nexttask(self,taskid,reason)
	end
	if next_taskid then
		self.ringnum = (ringnum + 1) % ringlimit
	end
	return next_taskid,errmsg
end

function cshimoshiliantask:quick_finish()
	local player = playermgr.getplayer(self.pid)
	local donecnt = self:getdonecnt()
	local donelimit = self:getdonelimit()
	local leftcnt = donelimit - donecnt
	local need_leftcnt = data_1500_ShiMoShiLianTaskVar.QuickFinishNeedLeftCnt
	local needitem = data_1500_ShiMoShiLianTaskVar.QuickFinishNeedItem
	local reason = "quick_finish"
	local chinesename = taskaux.gettaskdata(self.name,"name")
	if leftcnt < need_leftcnt then
		net.msg.S2C.notify(self.pid,language.format("{1}剩余次数不足{2}次，无法使用封魔卷",chinesename,need_leftcnt))
		return
	end
	local itemdb = player:getitemdb(needitem.type)
	local hasnum = itemdb:getnumbytype(needitem.type)
	if hasnum < needitem.num then
		net.msg.S2C.notify(self.pid,language.format("物品数量不足"))
		return
	end
	itemdb:costitembytype(needitem.type,needitem.num,reason)
	local multi = 10
	local tasktable = self:getformdata(self.name,"task")
	local taskid = randlist(table.keys(tasktable))
	local taskdata = tasktable[taskid]
	local bonus = self:_transaward(taskdata.award,player.lv)
	bonus.items = nil
	bonus.pets = nil
	-- 双倍点经验加成
	local dexp_adden = 0
	local isok,cost_dexp = player:can_cost_dexp(self.name)
	if isok then
		local dexp = player.thisweek:query("dexppoint") or 0
		local cnt = math.floor(dexp / cost_dexp)
		if cnt > 0  then
			local sum_cost_dexp = cost_dexp * cnt
			player.thisweek:add(-sum_cost_dexp)
			dexp_adden = bonus.exp * cnt
		end
	end
	bonus.exp = bonus.exp + dexp_adden
	doaward("player",self.pid,bonus,reason,true)
end

return cshimoshiliantask
