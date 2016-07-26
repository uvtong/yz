netteam = netteam or {
	C2S = {},
	S2C = {},
}

local C2S = netteam.C2S
local S2C = netteam.S2C

function C2S.createteam(player,request)
	teammgr:createteam(player,request)
end

function C2S.dismissteam(player,request)
	teammgr:dismissteam(player)
end

function C2S.jointeam(player,request)
	local teamid = request.teamid
	teammgr:jointeam(player,teamid)
end

function C2S.quitteam(player,request)
	teammgr:quitteam(player)
end

function C2S.publishsteam(player,request)
	teammgr:publishteam(player,request)
end

function C2S.leaveteam(player,request)
	teammgr:leaveteam(player)
end



function C2S.backteam(player,request)
	teammgr:backteam(player)
end

function C2S.recallmember(player,request)
	local teamid = player:getteamid()
	if not teamid then
		return
	end
	local team = teammgr:getteam(teamid)
	if not team then
		return
	end
	local pid = player.pid
	if team.captain ~= pid then
		return
	end
	local pids = request.pids
	if table.isempty(pids) then
		pids = team:members(TEAM_STATE_LEAVE)
	end
	for i,uid in ipairs(pids) do
		if uid ~= pid and team:ismember(uid) then
			net.msg.S2C.messagebox(uid,
				MB_RECALLMEMBER,
				language.format("召回"),
				language.format("队长#<G>{1}#(等级:{2}级)召回你归队",player.name,player.lv),
				{},
				{language.format("确认"),language.format("取消"),},
				function (obj,request,buttonid)
					if buttonid ~= 1 then
						return
					end
					if obj.teamid ~= teamid then
						return
					end
					local team = teammgr:getteam(teamid)
					if not team then
						return
					end
					if not team.leave[obj.pid] then
						return
					end
					teammgr:backteam(obj)
				end)
		end
	end
end

function C2S.apply_become_captain(player,request)
	local teamid = player:getteamid()
	if not teamid then
		return
	end
	local team = teammgr:getteam(teamid)
	if not team then
		return
	end
	local pid = player.pid
	if team.captain == pid then
		return
	end
	if not team.follow[pid] then
		return
	end
	local captain = playermgr.getplayer(team.captain)
	if not captain then
		teammgr:changecaptain(teamid,player.pid)
	else
		net.msg.S2C.messagebox(team.captain,
			MB_APPLY_BECOME_CAPTAIN,
			language.format("申请队长"),
			language.format("队员#<G>{1}#(等级:{2}级)申请成为队长",player.name,player.lv),
			{},
			{language.format("同意"),language.format("拒绝"),},
			function (obj,request,buttonid)
				if buttonid ~= 1 then
					return
				end
				if obj.teamid ~= teamid then
					return
				end
				local team = teammgr:getteam(teamid)
				if not team then
					return
				end
				if team.captain == pid then
					return
				end
				if not team.follow[pid] then
					return
				end
				teammgr:changecaptain(teamid,pid)
			end)
	end

end

function C2S.changecaptain(player,request)
	local pid = request.pid
	local teamid = player:getteamid()
	if not teamid then
		return
	end
	local team = teammgr:getteam(teamid)
	if not team then
		return team
	end
	if team.captain ~= player.pid then
		return
	end
	if not team.follow[pid] then
		return
	end
	teammgr:changecaptain(teamid,pid)
end

function C2S.kickmember(player,request)
	local teamid = player:getteamid()
	if not teamid then
		net.msg.S2C.notify(player.pid,language.format("你没有队伍"))
		return
	end
	local team = teammgr:getteam(teamid)
	if team.captain ~= player.pid then
		net.msg.S2C.notify(player.pid,language.format("你不是队长"))
		return
	end
	local targetid = assert(request.pid)
	teammgr:kickmember(player,targetid)
end

function C2S.invite_jointeam(player,request)
	local pid = player.pid
	local tid = request.pid
	local teamid = player:getteamid()
	if not teamid then
		teamid = teammgr:createteam(player,{})
	end
	local team = teammgr:getteam(teamid)
	if not team then
		return
	end
	if team:ismember(tid) then
		return
	end
	local target = playermgr.getplayer(tid)
	if not target then
		net.msg.S2C.notify(player.pid,language.format("对方不在线"))
		return
	end
	if target:getteamid() then
		net.msg.S2C.notify(player.pid,language.format("对方已经有队伍"))
		return
	end

	net.msg.S2C.messagebox(tid,
		MB_INVITE_JOINTEAM,
		language.format("邀请入队"),
		language.format("#<G>{1}#(等级:{2}级)邀请你加入他的队伍",player.name,player.lv),
		{},
		{language.format("同意"),language.format("拒绝")},
		function (obj,request,buttonid)
			if buttonid ~= 1 then
				return
			end
			local team = teammgr:getteam(teamid)
			if not team then
				return
			end
			if obj:getteamid() then
				net.msg.S2C.notify(obj.pid,language.format("你已经有队伍"))
				return
			end
			if team:ismember(obj.pid) then
				return
			end
			if team.captain == pid then
				teammgr:jointeam(obj,teamid)
			else
				team:addapplyer(obj)
			end
		end)
end

function C2S.syncteam(player,request)
	local teamid = request.teamid
	local team = teammgr:getteam(teamid)	
	local package
	if not team then
		package = {}
	else
		package = team:pack()
	end
	sendpackage(player.pid,"team","syncteam",{
		team = package,
	})
end

function C2S.openui_team(player,request)
	local pid = player.pid
	local teamid = player:getteamid()
	if not teamid then
		local teams = {}
		for teamid,team in pairs(teammgr.teams) do
			table.insert(teams,team:pack())
		end
		sendpackage(pid,"team","openui_team",{
			teams = teams,
			automatch = teammgr.automatch_pids[pid] and true or false,
		})
	else
		local team = teammgr:getteam(teamid)
		if team then
			sendpackage(player.pid,"team","syncteam",{
				team = team:pack(),
			})
		end
	end
end

function C2S.automatch(player,request)
	local target = request.target
	local lv = request.lv
	local teamid = player:getteamid()
	if not teamid then
		teammgr:automatch(player,target,lv)
	else
		local team = teammgr:getteam(teamid)
		if team.captain ~= player.pid then
			return
		end
		teammgr:team_automatch(teamid)
	end
end

function C2S.unautomatch(player,request)
	local teamid = player:getteamid()
	if not teamid then
		teammgr:unautomatch(player.pid,"cacel")
	else
		local team = teammgr:getteam(teamid)
		if team.captain ~= player.pid then
			return
		end
		teammgr:team_unautomatch(teamid,"cacel")
	end
end

function C2S.changetarget(player,request)
	local target = request.target
	local lv = request.lv
	teammgr:changetarget(player,target,lv)
end

function C2S.apply_jointeam(player,request)
	local teamid = player:getteamid()
	if teamid then
		return
	end
	teamid = request.teamid
	local team = teammgr:getteam(teamid)
	if not team then
		return
	end
	team:addapplyer(player)
end

function C2S.delapplyers(player,request)
	local pids = request.pids
	local teamid = player:getteamid()
	if not teamid then
		return
	end
	local team = teammgr:getteam(teamid)
	if team.captain ~= player.pid then
		return
	end
	if pids then
		for i,pid in ipairs(pids) do
			team:delapplyer(pid)
		end
	else
		team:clearapplyer()
	end
end

function C2S.agree_jointeam(player,request)
	local pid = request.pid
	local teamid = player:getteamid()
	if not teamid then
		return
	end
	local team = teammgr:getteam(teamid)
	if team.captain ~= player.pid then
		return
	end
	local applyer = team:getapplyer(pid)
	if not applyer then
		return
	end
	local target = playermgr.getplayer(pid)
	if not target then
		net.msg.S2C.notify(player,"对方已离线")
		return
	end
	if target:getteamid() then
		net.msg.S2C.notify(player,"对方已经有队伍了")
		return
	end
	teammgr:jointeam(target,teamid)
end

function C2S.look_publishteams(player,request)
	local publish_teams = {}
	for teamid,v in pairs(teammgr.publish_teams) do
		table.insert(publish_teams,teammgr:pack_publishteam(teamid))
	end
	sendpackage(player.pid,"team","publishteams",publish_teams)
end


-- s2c
return netteam
