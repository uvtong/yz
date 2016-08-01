playunit_guaji = playunit_guaji or {}
huodongmgr.playunit.guaji = playunit_guaji

playunit_guaji.UNGUAJI_STATE = 0
playunit_guaji.GUAJI_STATE = 1

function playunit_guaji.onlogin(player)
	-- onenter场景后会修正挂机状态
	local state = playunit_guaji.getstate(player)
	sendpackage(player.pid,"guaji","state",{state=state})
end

function playunit_guaji.onlogoff(player)
end

function playunit_guaji.isguajimap(mapid)
	local map = data_1104_GuaJiMap[mapid]
	if map then
		return true,map
	end
end

function playunit_guaji.canenter(player,sceneid)
	local scene = scenemgr.getscene(sceneid)
	local isok,map = playunit_guaji.isguajimap(scene.mapid)
	-- 非挂机地图不检30
	if not isok then
		return true
	end
	if player.lv < map.openlv and false then
		return false,language.format("#<R>{1}#级后开放该挂机地图",map.openlv)
	end
	return true
end

function playunit_guaji.onenter(player,sceneid,pos)
	local scene = scenemgr.getscene(sceneid)
	if playunit_guaji.isguajimap(scene.mapid) then
		playunit_guaji.setstate(player,playunit_guaji.GUAJI_STATE)
	else
		playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
	end
end

function playunit_guaji.onleave(player,sceneid)
	local scene = scenemgr.getscene(sceneid)
	if playunit_guaji.isguajimap(scene.mapid) then
		playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
	end
end

playunit_guaji.canenterscene = playunit_guaji.canenter
playunit_guaji.onenterscene = playunit_guaji.onenter
playunit_guaji.onleavescene = playunit_guaji.onleave

function playunit_guaji.guaji(player)
	local scene = scenemgr.getscene(player.sceneid)
	if not playunit_guaji.isguajimap(scene.mapid) then
		return false,language.format("非挂机地图无法挂机")
	end
	local teamstate = player:teamstate()
	if teamstate == TEAM_STATE_FOLLOW then
		return false,language.format("跟随状态无法挂机")
	end
	if player:inwar() then
		return false,language.format("战斗中无法挂机")
	end
	playunit_guaji.setstate(player,playunit_guaji.GUAJI_STATE)
	return true
end

function playunit_guaji.unguaji(player)
	-- need to check ?
	--local scene = scenemgr.getscene(player.sceneid)
	--if not playunit_guaji.isguajimap(scene.mapid) then
	--	return false,language.format("非挂机地图无法取消挂机")
	--end

	local teamstate = player:teamstate()
	if teamstate == TEAM_STATE_FOLLOW then
		return false,language.format("跟随状态无法取消挂机")
	end
	if player:inwar() then
		return false,language.format("战斗中无法取消挂机")
	end
	playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
	return true
end

function playunit_guaji.setstate(player,state)
	local oldstate = playunit_guaji.getstate(player)
	if oldstate ~= state then
		player:set("guaji.state",state)
		sendpackage(player.pid,"guaji","state",{
			state = state,
		})
	end
	local teamstate = player:teamstate()
	if teamstate == TEAM_STATE_CAPTAIN then
		local team = teammgr:getteam(player.teamid)
		for uid in pairs(team.follow) do
			local member = playermgr.getplayer(uid)
			if member then
				playunit_guaji.setstate(member,state)
			end
		end
	end
end

function playunit_guaji.getstate(player)
	return player:query("guaji.state") or playunit_guaji.UNGUAJI_STATE
end

function playunit_guaji.onmove(player)
	if playunit_guaji.getstate(player) ~= playunit_guaji.GUAJI_STATE then
		return
	end
	local ratio = player:query("guaji.ratio") or 0
	if ratio < 100 then
		ratio = math.min(100,ratio+data_1104_GuaJiVar.AddRatioPerSec)
	end
	if ishit(ratio,100) then
		ratio = 0
		playunit_guaji.raisewar(player)
	end
	player:set("guaji.ratio",ratio)
end

function playunit_guaji.raisewar(player)
	local sceneid = player.sceneid
	local wargroup = data_1104_GuaJiWarGroup[sceneid]
	local warid = choosekey(wargroup,function (key,val)
		return val.ratio
	end)
	local fighters = assert(player:getfighters())
	local reward = wargroup[warid]
	local war = {
		wardataid = warid,
		wartype = WARTYPE.PVE_GUAJI,
		-- ext
		reward = {
			exp = reward.exp,
			items = {reward.item,},
		},
	}
	warmgr.startwar(fighters,nil,war)
end

function playunit_guaji.onwarend(war,result)
	local reason = "guaji.onwarend"
	if warmgr.iswin(result) then
		local reward = war.reward
		for i,uid in ipairs(war.attackers) do
			local player = playermgr.getplayer(pid)
			if player then
				doaward("player",player.pid,reward,reason,true)
			end
		end
	end
end

function playunit_guaji.onbackteam(player,teamid)
	local team = teammgr:getteam(teamid)
	local captain = playermgr.getplayer(team.captain)
	local state = playunit_guaji.getstate(captain)
	playunit_guaji.setstate(player,state)
end

-- 暂离队伍
function playunit_guaji.onleaveteam(player,teamid)
	if playunit_guaji.getstate(player) == playunit_guaji.GUAJI_STATE then
		playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
	end
end

function playunit_guaji.onquitteam(player,teamid)
	if playunit_guaji.getstate(player) == playunit_guaji.GUAJI_STATE then
		playunit_guaji.setstate(player,playunit_guaji.UNGUAJI_STATE)
	end
end

return playunit_guaji

