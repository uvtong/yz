cteam = class("cteam")

function cteam:init(teamid,param)
	param = param or {}
	self.teamid = teamid
	self.createtime = os.time()
	self.follow = {}
	self.leave = {}
	self.captain = 0
	self.applyers = {}
	self.target = param.target or 0
	self.lv = param.lv or 0
	self.channel = string.format("team#%s",self.teamid)
end

function cteam:onlogin(player)
	local pid = player.pid
	sendpackage(pid,"team","addapplyer",self.applyers)
	sendpackage(pid,"team","selfteam",{
		team = self:pack(),
	})
end

function cteam:onlogoff(player)
end

function cteam:create(player,param)
	param = param or {}
	local pid = player.pid
	self.target = param.target or 0
	self.lv = param.lv or 0
	self.captain = pid
	player.teamid = self.teamid
	local scene = scenemgr.getscene(player.sceneid)
	local teamstate = TEAM_STATE_CAPTAIN
	scene:set(pid,{
		teamid = self.teamid,
		teamstate = teamstate,
	})
	self:broadcast(function (uid)
		sendpackage(uid,"team","selfteam",{
			team = self:pack(),
		})
	end)
end

function cteam:join(player)
	local teamid = player.teamid
	assert(teamid==nil)
	local pid = player.pid
	self:delapplyer(pid)
	player.teamid = self.teamid
	self.leave[pid] = true
	local captain = playermgr.getplayer(self.captain)
	-- captain is online
	if player.sceneid == captain.sceneid then
		if player:jumpto(captain.sceneid,captain.pos) then
			self.leave[pid] = nil
			self.follow[pid] = true
		end
	end
	local scene = scenemgr.getscene(player.sceneid)
	local teamstate = player:teamstate()
	scene:set(pid,{
		teamid = self.teamid,
		teamstate = teamstate,
	})
	
	self:broadcast(function (uid)
		if uid ~= pid then
			sendpackage(uid,"team","addmember",{
				teamid = self.teamid,
				member = self:packmember(player),
			})
		end
	end)
	sendpackage(pid,"team","selfteam",{
		team = self:pack(),
	})
	channel.subscribe(self.channel,player.pid)
end

function cteam:back(player)
	local pid = player.pid
	local captain = playermgr.getplayer(self.captain)
	if not player:jumpto(captain.sceneid,captain.pos) then
		return false
	end
	local scene = scenemgr.getscene(captain.sceneid)
	if self.leave[pid] then
		self.leave[pid] = nil
	end
	self.follow[pid] = true
	local teamstate = player:teamstate()
	scene:set(pid,{
		teamid = self.teamid,
		teamstate = teamstate,
	})
	self:broadcast(function (uid)
		sendpackage(uid,"team","updatemember",{
			teamid = self.teamid,
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
	local teamstate = player:teamstate()
	scene:set(pid,{
		teamid = self.teamid,
		teamstate = teamstate,
	})
	self:broadcast(function (uid)
		sendpackage(uid,"team","updatemember",{
			teamid = self.teamid,
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
		newcaptain = randlist(table.keys(self.follow))
	elseif next(self.leave) then
		newcaptain = randlist(table.keys(self.leave))
	end
	return newcaptain
end

function cteam:quit(player)
	local pid = player.pid
	self:_quit(pid)
	local scene = scenemgr.getscene(player.sceneid)
	local teamstate = player:teamstate() -- NO_TEAM
	scene:set(pid,{
		teamid = 0,
		teamstate = teamstate,
	})
end

function cteam:_quit(pid)
	local oldcaptain = self.captain
	if oldcaptain == pid then
		local newcaptain = self:choose_newcaptain()
		if newcaptain then
			teammgr:changecaptain(self.teamid,newcaptain)
		else
			self.captain = nil
		end
	end
	player.teamid = nil
	self.follow[pid] = nil
	self.leave[pid] = nil
	self:broadcast(function (uid)
		sendpackage(uid,"team","delmember",{
			teamid = self.teamid,
			pid = pid,
		})
		if self.captain ~= oldcaptain then
			sendpackage(uid,"team","updatemember",{
				teamid = self.teamid,
				member = {
					pid = self.captain,
					teamstate = TEAM_STATE_CAPTAIN,
				}
			})
		end
	end)
	channel.unsubscribe(self.channel,player.pid)
end

function cteam:changecaptain(pid)
	assert(self.captain~=pid)
	local oldcaptain_pid = self.captain
	if playermgr.getplayer(oldcaptain_pid) then
		self.follow[oldcaptain_pid] = true
	else
		self.leave[oldcaptain_pid] = true
	end
	self.captain = pid
	self.follow[pid] = nil
	self.leave[pid] = nil
	self:broadcast(function (uid)
		sendpackage(uid,"team","updatemember",{
			teamid = self.teamid,
			member = {
				pid = oldcaptain_pid,
				teamstate = self.follow[oldcaptain_pid] and TEAM_STATE_FOLLOW or TEAM_STATE_LEAVE,
			}
		})
		sendpackage(uid,"team","updatemember",{
			teamid = self.teamid,
			member = {
				pid = self.captain,
				teamstate = TEAM_STATE_CAPTAIN,
			}
		})
	end)
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
		return
	end
	applyer = {
		pid = pid,
		name = player.name,
		lv = player.lv,
		roletype = player.roletype,
		time = os.time(),
	}
	logger.log("info","team",format("[addapplyer] teamid=%d applyer=%s",self.teamid,applyer))
	if #self.applyers >= 10 then
		self:delapplyer(1,true)
	end
	table.insert(self.applyers,applyer)
	self:broadcast(function (uid)
		sendpackage(uid,"team","addapplyer",{applyer,})
	end)
end

function cteam:delapplyer(pid,ispos)
	local applyer,pos = self:getapplyer(pid,ispos)
	if applyer then
		logger.log("info","team",string.format("[delapplyer] teamid=%d pid=%d",self.teamid,applyer.pid))
		table.remove(self.applyers,pos)
		self:broadcast(function (uid)
			sendpackage(uid,"team","delapplyer",{pid,})
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
	return {
		pid = player.pid,
		name = player.name,
		lv = player.lv,
		roletype = player.roletype,
		teamstate = self:teamstate(player.pid),	
	}
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
			table.insert(members,self:packmember(member))
		end
	end
	for pid,_ in pairs(self.leave) do
		local member = playermgr.getplayer(pid)
		if not member then
			member = resumemgr.getresume(pid)
			table.insert(members,self:packmember(member))
		end
	end
	return members
end

function cteam:pack()
	return {
		teamid = self.teamid,
		target = self.target,
		lv = self.lv,
		members = self:packmembers(),
		automatch = teammgr.automatch_teams[self.teamid] and true or false,
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
	if teamstate == TEAM_STATE_FOLLOW then
		pids = table.keys(self.follow)
		table.insert(pids,1,self.captain)
	elseif teamstate == TEAM_STATE_LEAVE then
		pids = table.keys(self.leave)
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
return cteam
