netteam = netteam or {
	C2S = {},
	S2C = {},
}

local C2S = netteam.C2S
local S2C = netteam.S2C

-- 正规化：组队目标+等级范围
function netteam.uniform_target(player,request)
	request.target = request.target or 0
	if request.target == 0 then
		request.minlv = 1
		request.maxlv = playeraux.getmaxlv()
	else
		local data = data_0301_TeamTarget[request.target]
		request.minlv = request.minlv or player.lv - data.down_float
		request.minlv = math.max(1,request.minlv)
		request.maxlv = request.maxlv or player.lv + data.up_float
		request.maxlv = math.min(playeraux.getmaxlv(),request.maxlv)
	end
end

function C2S.createteam(player,request)
	if not playeraux.isopen(player.lv,"队伍") then
		net.msg.S2C.notify(player.pid,language.format("等级不足"))
		return
	end
	netteam.uniform_target(player,request)
	local data = data_0301_TeamTarget[request.target]
	local minlv = data and data.minlv or 10
	if player.lv < minlv then
		net.msg.S2C.notify(player.pid,language.format("等级不足{1}级",minlv))
		return
	end
	teammgr:createteam(player,request)
end

function C2S.dismissteam(player,request)
	teammgr:dismissteam(player)
end

function C2S.jointeam(player,request)
	local teamid = request.teamid
	local isok,errmsg = teammgr:jointeam(player,teamid)
	if not isok and errmsg then
		net.msg.S2C.notify(player.pid,errmsg)
	end
end

function C2S.quitteam(player,request)
	teammgr:quitteam(player)
end

function C2S.publishteam(player,request)
	teammgr:publishteam(player,request)
end

function C2S.leaveteam(player,request)
	teammgr:leaveteam(player)
end

function C2S.backteam(player,request)
	teammgr:backteam(player)
end

function C2S.recallmember(player,request)
	local pids = request.pids
	local pid = player.pid
	local team = player:getteam()
	if not team or team.captain ~= pid then
		return
	end
	local teamid = team.id
	if table.isempty(pids) then
		pids = team:members(TEAM_STATE_LEAVE)
	end
	for i,uid in ipairs(pids) do
		if uid ~= pid and team:ismember(uid) then
			openui.messagebox(uid,{
				type = MB_RECALLMEMBER,
				title = language.format("召回"),
				content = language.format("队长#<G>{1}#(等级:{2}级)召回你回归队伍，是否立即回归队伍？",player.name,player.lv),
				buttons = {
					openui.button(language.format("取消")),
					openui.button(language.format("归队"),5),
				},
				lifetime = 5,
				attach = {},},
				function (uid,request,response)
					local obj = playermgr.getplayer(uid)
					if not obj then
						return
					end
					local answer = response.answer
					if not (answer == 2 or openui.istimeout(answer)) then
						return
					end
					if obj:teamid() ~= teamid then
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
	local pid = player.pid
	local team = player:getteam()
	if not team then
		return
	end
	local teamid = team.id
	if team.captain == pid then
		return
	end
	if not team.follow[pid] then
		net.msg.S2C.notify(player.pid,language.format("归队队员才能申请队长"))
		return
	end
	local captain = playermgr.getplayer(team.captain)
	if not captain then
		teammgr:changecaptain(teamid,player.pid)
	else
		local lifetime = 20
		local buttons
		if captain.switch:isopen("team.agreetocaptain") then
			buttons = {
				openui.button(language.format("拒绝")),
				openui.button(language.format("同意"),lifetime),
			}
		else
			buttons = {
				openui.button(language.format("拒绝"),lifetime),
				openui.button(language.format("同意")),
			}
		end
		openui.messagebox(team.captain,{
			type = MB_APPLY_BECOME_CAPTAIN,
			title = language.format("申请队长"),
			content = language.format("队员#<G>{1}#(等级:{2}级)申请成为队长",player.name,player.lv),
			buttons = buttons,
			lifetime = lifetime,
			attach = {},},
			function (uid,request,response)
				local obj = playermgr.getplayer(uid)
				local answer = response.answer
				if not ((request.buttons[2].timeout and request.buttons[2].timeout > 0 and openui.istimeout(answer)) or
					(answer == 2)) then
					net.msg.S2C.notify(pid,language.format("队长申请已被拒绝"))
					return
				end
				if obj:teamid() ~= teamid then
					return
				end
				local team = teammgr:getteam(teamid)
				if not team then
					return
				end
				if team.captain ~= uid then
					net.msg.S2C.notify(uid,language.format("不能进行此项操作"))
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
	local captain_pid = player.pid
	local team = player:getteam()
	if not team then
		return
	end
	if team.captain ~= captain_pid then
		return
	end
	if not team.follow[pid] then
		return
	end
	local teamid = team.id
	openui.messagebox(pid,{
		type = MB_INVITE_BECOME_CAPTAIN,
		title = language.format("邀请成为队长"),
		content = language.format("队长#<G>{1}#(等级:{2}级)邀请你成为队长，是否同意？",player.name,player.lv),
		buttons = {
			openui.button(language.format("拒绝")),
			openui.button(language.format("同意"),20),
		},
		lifetime = 20,
		attach = {},},
		function (uid,request,response)
			if not (response.answer == 2 or openui.istimeout(response.answer)) then
				net.msg.S2C.notify(captain_pid,language.format("该队员拒绝了你的提升队长邀请"))
				return
			end
			teammgr:changecaptain(teamid,uid)
			end)
end

function C2S.kickmember(player,request)
	local team = player:getteam()
	if not team then
		net.msg.S2C.notify(player.pid,language.format("你没有队伍"))
		return
	end
	if team.captain ~= player.pid then
		net.msg.S2C.notify(player.pid,language.format("你不是队长"))
		return
	end
	local targetid = assert(request.pid)
	teammgr:kickmember(player,targetid)
end

function C2S.invite_jointeam(player,request)
	if not playeraux.isopen(player.lv,"队伍") then
		net.msg.S2C.notify(player.pid,language.format("等级不足"))
		return
	end
	local pid = player.pid
	local tid = request.pid
	local teamid = player:teamid()
	if not teamid then
		local team = teammgr:createteam(player,{})
		teamid = team.id
	end
	local team = teammgr:getteam(teamid)
	if not team then
		return
	end
	if team:ismember(tid) then
		return
	end
	local self_srvname = cserver.getsrvname()
	local now_srvname,isonline = globalmgr.now_srvname(tid)
	if now_srvname == self_srvname then
		local target = playermgr.getplayer(tid)
		if not target then
			net.msg.S2C.notify(player.pid,language.format("对方不在线"))
			return
		end
		if not playeraux.isopen(target.lv,"队伍") then
			net.msg.S2C.notify(player.pid,language.format("对方等级不足"))
			return
		end

		if target:teamid() then
			net.msg.S2C.notify(player.pid,language.format("对方已经有队伍"))
			return
		end
	else
		if not isonline then
			net.msg.S2C.notify(player.pid,language.format("对方不在线"))
			return
		end
		local target = cproxyplayer.new(tid,now_srvname)
		if target:teamid() then
			net.msg.S2C.notify(player.pid,language.format("对方已经有队伍"))
			return
		end
		local lv = target:getlv()
		if not playeraux.isopen(lv,"队伍") then
			net.msg.S2C.notify(player.pid,language.format("对方等级不足"))
			return
		end
	end
	openui.messagebox(tid,{
		type = MB_INVITE_JOINTEAM,
		title = language.format("邀请入队"),
		content = language.format("#<G>{1}#(等级:{2}级)邀请你加入他的队伍。\n队伍目标:{3} {4}-{5}级队伍",player.name,player.lv,team:targetname(),team.minlv,team.maxlv),
		buttons = {
			openui.button(language.format("拒绝"),10),
			openui.button(language.format("同意")),
		},
		lifetime = 10,
		attach = {},},
		function (uid,request,response)
			local obj = playermgr.getplayer(uid)
			if not obj then
				return
			end
			local answer = response.answer
			if answer ~= 2 then
				return
			end
			local team = teammgr:getteam(teamid)
			if not team then
				return
			end
			if obj:teamid() then
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
	local teamid = player:teamid()
	if not teamid then
		local publish_teams = {}
		for teamid,v in pairs(teammgr.publish_teams) do
			local publishteam = teammgr:pack_publishteam(teamid)
			if publishteam then
				table.insert(publish_teams,publishteam)
			end
		end
		local package = {
			publishteams = publish_teams,
			waiting_num = table.count(teammgr.automatch_pids),
		}
		local automatch = teammgr.automatch_pids[pid]
		if automatch then
			package.automatch = true
			package.target = automatch.target
			package.minlv = automatch.minlv
			package.maxlv = automatch.maxlv
		end
		teammgr.openui_pids[pid] = true
		sendpackage(pid,"team","openui_team",package)
	else
		local team = teammgr:getteam(teamid)
		if team then
			sendpackage(player.pid,"team","selfteam",{
				team = team:pack(),
				applyers = team.applyers,
			})
		end
	end
end

function C2S.closeui_team(player,request)
	teammgr.openui_pids[player.pid] = nil
end

function C2S.automatch(player,request)
	netteam.uniform_target(player,request)
	local teamid = player:teamid()
	if not teamid then
		teammgr:automatch(player,request.target,request.minlv,request.maxlv)
	else
		local team = teammgr:getteam(teamid)
		if team.captain ~= player.pid then
			return
		end
		teammgr:team_changetarget(player,request.target,request.minlv,request.maxlv)
		teammgr:team_automatch(teamid)
	end
end

function C2S.unautomatch(player,request)
	local teamid = player:teamid()
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
	netteam.uniform_target(player,request)
	local target = request.target
	local minlv = request.minlv
	local maxlv = request.maxlv
	local teamid = player:teamid()
	if not teamid then
		teammgr:automatch_changetarget(player,target,minlv,maxlv)
	else
		local team = teammgr:getteam(teamid)
		if team.captain ~= player.pid then
			return
		end
		teammgr:team_changetarget(player,target,minlv,maxlv)
	end
end

function C2S.apply_jointeam(player,request)
	local teamid = player:teamid()
	if teamid then
		return
	end
	teamid = request.teamid
	local isok,errmsg = teammgr:addapplyer(teamid,teammgr:pack_applyer(player))
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
	else
		net.msg.S2C.notify(player.pid,language.format("已申请加入对方队伍"))
	end
end

function C2S.delapplyers(player,request)
	local pids = request.pids
	local team = player:getteam()
	if not team then
		return
	end
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
	local pid = player.pid
	local tid = request.pid
	local team = player:getteam()
	if not team then
		return
	end
	if team.captain ~= pid then
		return
	end
	local applyer = team:getapplyer(tid)
	if not applyer then
		return
	end
	if applyer.fromsrv ~= cserver.getsrvname() then
		rpc.call(applyer.fromsrv,"rpc","net.team.agree_jointeam",pid,tid,team.id)
	else
		net.team.agree_jointeam(pid,tid,team.id)
	end
end

function netteam.agree_jointeam(pid,tid,teamid)
	local target = playermgr.getplayer(tid)
	if not target then
		net.msg.S2C.notify(pid,"对方已离线")
		return
	end
	if target:teamid() then
		net.msg.S2C.notify(pid,"对方已经有队伍了")
		return
	end
	teammgr:jointeam(target,teamid)
	local teamstate = target:teamstate()
	if teamstate == TEAM_STATE_LEAVE then
		openui.messagebox(target.pid,{
			type = MB_NOTIFY_BACKTEAM,
			title = language.format("归队提示"),
			content = language.format("是否立即回归队伍"),
			buttons = {
				openui.button("取消"),
				openui.button("归队",5),
			},
			lifetime = 5,
			attach = {},},
			function (uid,request,response)
				local player = playermgr.getplayer(uid)
				if not player then
					return
				end
				if not (response.answer == 2 or openui.istimeout(response.answer)) then
					return
				end
				teammgr:backteam(player)
			end)
	end
end

function C2S.look_publishteams(player,request)
	local publish_teams = {}
	for teamid,v in pairs(teammgr.publish_teams) do
		local publishteam = teammgr:pack_publishteam(teamid)
		if publishteam then
			table.insert(publish_teams,publishteam)
		end
	end
	sendpackage(player.pid,"team","publishteams",{
		publishteams = publish_teams,
	})
end


-- s2c
return netteam
