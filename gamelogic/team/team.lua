cteam = class("cteam")

function cteam:init(param)
	self.target = param.target or 0
	self.minlv = param.minlv or 1
	self.maxlv = param.maxlv or playeraux.getmaxlv()
	self.captain = assert(param.captain)
	self.createtime = os.time()
	self.follow = {}
	self.leave = {}
	self.applyers = {}
	-- self.id,self.channel在队伍纳入管理后生成
end

function cteam:onlogin(player)
	local pid = player.pid
	channel.subscribe(self.channel,pid)
	-- 同步申请者列表
	sendpackage(pid,"team","addapplyer",{applyers=self.applyers})
	-- 同步自身队伍信息
	sendpackage(pid,"team","selfteam",{
		team = self:pack(),
	})
	-- 尝试归队
	if pid ~= self.captain then
		local captain = playermgr.getplayer(self.captain)
		if captain and captain.sceneid == player.sceneid then
			teammgr:backteam(player)
		end
	end
end

function cteam:onlogoff(player,reason)
	local pid = player.pid
	channel.unsubscribe(self.channel,pid)
	if reason == "replace" then
		return
	end
	-- 下线后暂离队伍，如果是队长则先切换队长
	if self.captain == pid then
		local newcaptain = self:choose_newcaptain()
		assert(newcaptain ~= self.captain)
		if newcaptain then
			teammgr:changecaptain(self.id,newcaptain)
		else
			teammgr:quitteam(player)
		end
	end
	if teammgr:teamid(pid) then
		teammgr:leaveteam(player)
	end
end


function cteam:join(player)
	local pid = player.pid
	local teamid = teammgr:teamid(pid)
	assert(teamid==nil)
	teammgr.pid_teamid[pid] = self.id
	channel.subscribe(self.channel,pid)
	self:delapplyer(pid)
	self.leave[pid] = true
	self:broadcast(function (uid)
		if uid ~= pid then
			sendpackage(uid,"team","addmember",{
				teamid = self.id,
				member = self:packmember(player),
			})
		end
	end)
	
end

function cteam:back(player)
	local pid = player.pid
	local captain = playermgr.getplayer(self.captain)
	local scene = scenemgr.getscene(captain.sceneid)
	if self.leave[pid] then
		self.leave[pid] = nil
	end
	self.follow[pid] = true
	local teamstate = self:teamstate(pid)
	scene:set(pid,{
		teamid = self.id,
		teamstate = teamstate,
	})
	self:broadcast(function (uid)
		sendpackage(uid,"team","updatemember",{
			teamid = self.id,
			member = {
				pid = pid,
				teamstate = teamstate,
			}
		})
	end)
	return true
end

function cteam:leaveteam(player)
	local pid = player.pid
	assert(self.captain ~= pid)
	self.follow[pid] = nil
	self.leave[pid] = true
	local scene = scenemgr.getscene(player.sceneid)
	local teamstate = self:teamstate(pid)
	scene:set(pid,{
		teamid = self.id,
		teamstate = teamstate,
	})
	self:broadcast(function (uid)
		sendpackage(uid,"team","updatemember",{
			teamid = self.id,
			member = {
				pid = pid,
				teamstate = teamstate,
			}
		})
	end)
	return true
end

function cteam:choose_newcaptain()
	local newcaptain
	if next(self.follow) then
		local pids = {}
		for pid in pairs(self.follow) do
			if playermgr.getplayer(pid) then
				table.insert(pids,pid)
			end
		end
		if not table.isempty(pids) then
			newcaptain = randlist(pids)
		end
	elseif next(self.leave) then
		local pids = {}
		for pid in pairs(self.leave) do
			if playermgr.getplayer(pid) then
				table.insert(pids,pid)
			end
		end
		if not table.isempty(pids) then
			newcaptain = randlist(pids)
		end
	end
	return newcaptain
end

function cteam:quit(pid)
	teammgr.pid_teamid[pid] = nil
	channel.unsubscribe(self.channel,pid)
	local oldcaptain = self.captain
	if oldcaptain == pid then
		local newcaptain = self:choose_newcaptain()
		if newcaptain then
			teammgr:changecaptain(self.id,newcaptain)
		else
			self.captain = nil
		end
	end
	self.follow[pid] = nil
	self.leave[pid] = nil
	sendpackage(pid,"team","selfteam",{})
	self:broadcast(function (uid)
		sendpackage(uid,"team","delmember",{
			teamid = self.id,
			pid = pid,
		})
		if self.captain ~= oldcaptain then
			sendpackage(uid,"team","updatemember",{
				teamid = self.id,
				member = {
					pid = self.captain,
					teamstate = self:teamstate(self.captain),
				}
			})
		end
	end)
	local player = playermgr.getplayer(pid)
	if player then
		local scene = scenemgr.getscene(player.sceneid)
		scene:set(pid,{
			teamid = 0,
			teamstate = NO_TEAM,
		})
	end
	if self:len(TEAM_STATE_ALL) == 0 or self:isall_logoff() then
		teammgr:delteam(self.id)
	end
end

function cteam:changecaptain(pid)
	assert(self.captain~=pid)
	local oldcaptain_pid = self.captain
	local oldcaptain = playermgr.getplayer(oldcaptain_pid)
	local newcaptain = playermgr.getplayer(pid)
	if oldcaptain then
		self.follow[oldcaptain_pid] = true
	else
		self.leave[oldcaptain_pid] = true
	end
	self.captain = pid
	self.follow[pid] = nil
	self.leave[pid] = nil
	self:broadcast(function (uid)
		sendpackage(uid,"team","updatemember",{
			teamid = self.id,
			member = {
				pid = oldcaptain_pid,
				teamstate = self:teamstate(oldcaptain_pid),
			}
		})
		sendpackage(uid,"team","updatemember",{
			teamid = self.id,
			member = {
				pid = self.captain,
				teamstate = self:teamstate(self.captain),
			}
		})
	end)
	if oldcaptain then
		local scene = scenemgr.getscene(oldcaptain.sceneid)
		local teamstate = self:teamstate(oldcaptain.pid)
		scene:set(oldcaptain.pid,{
			teamid = self.id,
			teamstate = teamstate,
		})
	end
	if newcaptain then
		local scene = scenemgr.getscene(newcaptain.sceneid)
		local teamstate = self:teamstate(newcaptain.pid)
		scene:set(newcaptain.pid,{
			teamid = self.id,
			teamstate = teamstate,
		})
	end

end

function cteam:getapplyer(pid,ispos)
	if ispos then
		local pos = pid
		return self.applyers[pos],pos
	else
		for i,applyer in ipairs(self.applyers) do
			if applyer.pid == pid then
				return applyer,i
			end
		end
	end
end

function cteam:addapplyer(player)
	local pid = player.pid
	local applyer = self:getapplyer(pid)
	if applyer then
		net.msg.S2C.notify(player.pid,language.format("你已经申请过该队伍了"))
		return
	end
	applyer = {
		pid = pid,
		name = player.name,
		lv = player.lv,
		joblv = player.joblv,
		roletype = player.roletype,
		time = os.time(),
	}
	logger.log("info","team",format("[addapplyer] teamid=%d applyer=%s",self.id,applyer))
	if #self.applyers >= 10 then
		self:delapplyer(1,true)
	end
	table.insert(self.applyers,applyer)
	self:broadcast(function (uid)
		sendpackage(uid,"team","addapplyer",{applyers = {applyer,}})
	end)
end

function cteam:delapplyer(pid,ispos)
	local applyer,pos = self:getapplyer(pid,ispos)
	if applyer then
		logger.log("info","team",string.format("[delapplyer] teamid=%d pid=%d",self.id,applyer.pid))
		table.remove(self.applyers,pos)
		self:broadcast(function (uid)
			sendpackage(uid,"team","delapplyer",{applyers={applyer.pid,}})
		end)
	end
end

function cteam:clearapplyer()
	for pos = #self.applyers,1,-1 do
		self:delapplyer(pos,true)
	end
end

function cteam:teamstate(pid)
	if self.captain == pid then
		return TEAM_STATE_CAPTAIN
	elseif self.follow[pid] then
		return TEAM_STATE_FOLLOW
	elseif self.leave[pid] then
		return TEAM_STATE_LEAVE
	end
	return NO_TEAM
end

-- player : 1--player object,2 -- resume object
function cteam:packmember(player)
	if typename(player) == "cplayer" then
		return {
			pid = player.pid,
			name = player.name,
			lv = player.lv,
			roletype = player.roletype,
			teamstate = self:teamstate(player.pid),	
			jobzs = player.jobzs,
			joblv = player.joblv,
		}
	else
		return {
			pid = player.pid,
			teamstate = self:teamstate(player.pid),
			name = player:get("lv"),
			lv = player:get("lv"),
			roletype = player:get("roletype"),
			jobzs = player:get("jobzs"),
			joblv = player:get("joblv"),
		}
	end
end

function cteam:packmembers()
	local captain = playermgr.getplayer(self.captain)
	if not captain then
		captain = resumemgr.getresume(self.captain)
	end
	local members = {}
	table.insert(members,self:packmember(captain))
	for pid,_ in pairs(self.follow) do
		local member = playermgr.getplayer(pid)
		if not member then
			member = resumemgr.getresume(pid)
		end
		table.insert(members,self:packmember(member))
	end
	for pid,_ in pairs(self.leave) do
		local member = playermgr.getplayer(pid)
		if not member then
			member = resumemgr.getresume(pid)
		end
		table.insert(members,self:packmember(member))
	end
	return members
end

function cteam:pack()
	return {
		teamid = self.id,
		target = self.target,
		minlv = self.minlv,
		maxlv = self.maxlv,
		members = self:packmembers(),
		automatch = teammgr.automatch_teams[self.id] and true or false,
	}
end

function cteam:broadcast(func)
	func(self.captain)
	for pid,_ in pairs(self.follow) do
		func(pid)
	end
	for pid,_ in pairs(self.leave) do
		func(pid)
	end
end

function cteam:ismember(pid)
	if self.captain == pid then
		return true
	end
	if self.follow[pid] then
		return true
	end
	if self.leave[pid] then
		return true
	end
	return false
end

function cteam:members(teamstate)
	local pids = {}
	if teamstate == TEAM_STATE_CAPTAIN then
		pids = {self.captain,}
	elseif teamstate == TEAM_STATE_FOLLOW then
		pids = table.keys(self.follow)
	elseif teamstate == TEAM_STATE_LEAVE then
		pids = table.keys(self.leave)
	elseif teamstate == TEAM_STATE_CAPTAIN_FOLLOW then
		pids = {self.captain}
		table.extend(pids,table.keys(self.follow))
	elseif teamstate == TEAM_STATE_ALL then
		pids = {self.captain}
		for uid,_ in pairs(self.follow) do
			table.insert(pids,uid)
		end
		for uid,_ in pairs(self.leave) do
			table.insert(pids,uid)
		end
	else
		assert("invalid team state:" .. tostring(teamstate))
	end
	return pids
end

function cteam:len(teamstate)
	local pids = self:members(teamstate)
	return #pids
end

-- 最大人数
function cteam:maxlen()
	local target = self.target
	if not target or target == 0 then
		return 5
	end
	return data_0301_TeamTarget[target].maxlen or 5
end

function cteam:isall_logoff()
	if self.captain then
		if playermgr.getplayer(self.captain) then
			return false
		end
	end
	for pid in pairs(self.follow) do
		if playermgr.getplayer(pid) then
			return false
		end
	end
	for pid in pairs(self.leave) do
		if playermgr.getplayer(pid) then
			return false
		end
	end
	return true
end

function cteam:targetname()
	if self.target == 0 then
		return "无目标"
	end
	local data = data_0301_TeamTarget[self.target]
	return data.minor_target
end

return cteam
