-- 使魔试炼
cshimoshiliantask = class("cshimoshiliantask",ctaskcontainer)

function cshimoshiliantask:init(conf)
	ctaskcontainer.init(self,conf)
	self.ringnum = 1
end

function cshimoshiliantask:onfivehourupdate()
	ctaskcontainer.onfivehourupdate(self)
	self.lasttaskid = nil
end

function cshimoshiliantask:can_accept(taskid)
	local player = playermgr.getplayer(self.pid)
	if player:teamstate() ~= TEAM_STATE_CAPTAIN then
		return false,language.format("本任务需要组队后才能进行")
	end
	local fighters,errmsg = player:getfighters()
	if table.isempty(fighters) then
		return false,errmsg
	end
	local neednum = self:getformdata("var").StartWarNeedNum
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
	if player:teamstate() ~= TEAM_STATE_CAPTAIN then
		return false,language.format("本任务需要组队后才能进行")
	end
	local fighters,errmsg = player:getfighters()
	if table.isempty(fighters) then
		return false,errmsg
	end
	local neednum = self:getformdata("var").StartWarNeedNum
	local needlv = self:getformdata("var").StartWarNeedLv
	if #fighters < neednum then
		return false,language.format("队伍人数不足#<R>#{1}人",neednum)
	end
	for i,uid in ipairs(fighters) do
		local member = playermgr.getplayer(uid)
		if member.lv < needlv then
			return false,language.format("#<G>{1}#等级不足#<R>{2}#级",member:getname(),needlv)
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
		local fakedata = self:getformdata("fake")
		local data = fakedata[lv] or fakedata[#fakedata]
		warid = data.warids[-warid]
	end
	war.wardataid = warid
	war.wartype = WARTYPE.PVE_SHARE_TASK
	return war
end

function cshimoshiliantask:_transaward(awardid,lv)
	if awardid < 0 then
		local fakedata = self:getformdata("fake")
		local data = fakedata[lv] or fakedata[#fakedata]
		awardid = data.awardid
	end
	local awarddata = self:getformdata("award")
	local bonus = award.getaward(awarddata,awardid,function (i,data)
		return data.ratio
	end)
	local ringlimit = self:getformdata("ringlimit")
	bonus = award.mergebonus(bonus)
	bonus = deepcopy(bonus)
	return bonus
end

function cshimoshiliantask:transaward(task,awardid,pid)
	assert(pid == self.pid)
	local player = playermgr.getplayer(self.pid)
	local lv = player:team_avglv2(TEAM_STATE_CAPTAIN_FOLLOW)
	local teamstate = player:teamstate()
	local ringlimit = self:getformdata("ringlimit")
	local bonus = self:_transaward(awardid,lv)
	-- 队长经验加成
	if teamstate == TEAM_STATE_CAPTAIN then
		if self.ringnum == ringlimit then
			if not bonus.items then
				bonus.items = {}
			end
			local item = self:getformdata("var").GiveItemToCaptainAt10Ring
			table.insert(bonus.items,item)
		end
	end
	local isok,exp_addn,detail = player:has_exp_addn(self.name,bonus.exp)
	if isok and exp_addn > 0 then
		-- tips ?
		bonus.exp = bonus.exp + exp_addn
	end
	return bonus
end

function cshimoshiliantask:nexttask(taskid,reason)
	local chinesename = self:getformdata("name")
	local donelimit = self:getformdata("donelimit")
	local donecnt = self:getdonecnt()
	local ringnum = self.ringnum or 0
	local ringlimit = self:getformdata("ringlimit")
	local look_npctype = self:getformdata("var").LookNpcType
	local leftcnt = math.min(0,donelimit-donecnt)
	if donecnt >= donelimit then
		openui.messagebox(self.pid,{
			type = MB_SHIMOSHILIAN_REACHLIMIT,
			title = language.format("次数耗尽"),
			content = language.format("【{1}】次数耗尽，继续任务将不会获得奖励。\n剩余次数：{2}/{3}",chinesename,leftcnt,donelimit),
			buttons = {
				openui.button(language.format("确认")),
			}
		})
		return
	end
	if reason ~= "opentask" and ringnum >= ringlimit then
		local player = playermgr.getplayer(self.pid)
		if player and player:teamstate() == TEAM_STATE_CAPTAIN then
			openui.messagebox(self.pid,{
				type = MB_SHIMOSHILIAN_10_RING,
				title = language.format("任务完成"),
				content = language.format("已完成{1}环【{2}】。\n剩余次数：{3}/{4}",ringlimit,chinesename,leftcnt,donelimit),
				buttons = {
					openui.button(language.format("取消")),
					openui.button(language.format("继续")),
				},
				attach = {npctype=look_npctype},
			})
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
		if self.ringnum == 0 then
			self.ringnum = ringlimit
		end
	end
	return next_taskid,errmsg
end

function cshimoshiliantask:quick_finish()
	local player = playermgr.getplayer(self.pid)
	local donecnt = self:getdonecnt()
	local donelimit = self:getdonelimit()
	local leftcnt = donelimit - donecnt
	local need_leftcnt = self:getformdata("var").QuickFinishNeedLeftCnt
	local needitem = self:getformdata("var").QuickFinishNeedItem
	local reason = "quick_finish"
	local chinesename = self:getformdata("name")
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
	local bonuss = {}
	local cnt = 10
	for i=1,cnt do
		local tasktable = self:getformdata(self.name,"task")
		local taskid = randlist(table.keys(tasktable))
		local taskdata = tasktable[taskid]
		local bonus = self:_transaward(taskdata.award,player.lv)
		bonus.items = nil
		bonus.pets = nil
		-- 双倍点经验加成
		local isok,dexp_addn = player:has_dexp_addn(self.name,bonus.exp)
		if isok and dexp_addn > 0 then
			bonus.exp = bonus.exp + dexp_addn
		end
		table.insert(bonuss,bonus)
	end
	local bonus = award.mergebonus(bonuss)
	doaward("player",self.pid,bonus,reason,true)
end

return cshimoshiliantask