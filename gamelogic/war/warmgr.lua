warmgr = warmgr or {}

function warmgr.init()
	warmgr.wars = {}
end

function warmgr.onlogin(player)
	local pid = player.pid
	local watch_warid = player.watch_warid
	if watch_warid then
		local war = warmgr.getwar(watch_warid)
		if war then
			warmgr.watchwar(player,watch_warid)
		else
			player.watch_warid = nil
		end
	end
	local warid = player.warid
	if warid then
		local war = warmgr.getwar(warid)
		if war then
			local ishelper = table.find(war.attack_helpers,pid) or table.find(war.defense_helpers,pid)
			if ishelper then
				warmgr.quitwar(player,warid)
			end
			-- dosomething
		else
			player.warid = nil
		end
		if not player.warid then
			local scene = scenemgr.getscene(player.sceneid)
			scene:set(player.pid,{
				warid = 0,
			})
		end
	end
end

function warmgr.onlogoff(player)
	local watch_warid = player.watch_warid
	if watch_warid then
		local war = warmgr.getwar(watch_warid)
		if war then
			warmgr.quit_watchwar(player,watch_warid)
		else
			player.watch_warid = nil
		end
	end
	local warid = player.warid
	if warid then
		local war = warmgr.getwar(warid)
		if war then
			-- dosomething
		else
			player.warid = nil
		end
	end
end

function warmgr.packwar(war)
	return war
end

function warmgr.packplayer(player)
	return {
		pid = player.pid,
		attr = {},  -- 玩家属性
		items = {},
		pets = {},
		skills = {},
	}
end

function warmgr.genwarid()
	local warid = globalmgr.server:query("warid",0)
	if warid > MAX_NUMBER then
		warid = 0
	end
	warid = warid + 1
	globalmgr.server:set("warid",warid)
	return warid
end

function warmgr.addwar(warid,war)
	assert(warmgr.getwar(warid)==nil, "Repeat warid:" .. tostring(warid))
	war.warid = warid
	war.attack_escapers = {}
	war.defense_escapers = {}
	war.attack_watchers = {}
	war.defense_watchers = {}
	warmgr.wars[warid] = war
	if not table.isempty(war.attackers) then
		for i,pid in ipairs(war.attackers) do
			local player = playermgr.getplayer(pid)
			assert(player)
			player.warid = warid
		end
	end
	if not table.isempty(war.defensers) then
		for i,pid in ipairs(war.defensers) do
			local player = playermgr.getplayer(pid)
			assert(player)
			if war.wartype == PVP_RANK_WAR then
			else
				player.warid = warid
			end
		end
	end
	return warid
end

function warmgr.delwar(warid)
	local war = warmgr.getwar(warid)
	if war then
		warmgr.wars[warid] = nil
		if not table.isempty(war.attackers) then
			for i,pid in ipairs(war.attackers) do
				local player = playermgr.getplayer(pid)
				if not player then
					player = playermgr.loadofflineplayer(pid)
				end
				assert(player)
				player.warid = nil
			end
		end
		if not table.isempty(war.defensers) then
			for i,pid in ipairs(war.defensers) do
				local player = playermgr.getplayer(pid)
				if not player then
					player = playermgr.loadofflineplayer(pid)
				end
				assert(player)
				if war.wartype == PVP_RANK_WAR then
				else
					player.warid = nil
				end
			end
		end
		return war
	end
end

function warmgr.getwar(warid)
	return warmgr.wars[warid]
end

function warmgr.can_startwar(attackers,defensers,war)
	local set = table.intersect_set(table.toset(attackers),table.toset(defensers))
	if not table.isempty(set) then
		return false,set
	end
	-- is anyone inwar?
	if not table.isempty(attackers) then
		for i,pid in ipairs(attackers) do
			local player = playermgr.getplayer(pid)
			if not player then
				player = playermgr.loadofflineplayer(pid)
			end
			assert(player,"Invalid pid:" .. tostring(pid))
			if player.warid then
				return false,pid
			end
		end
	end
	if not table.isempty(war.attack_helpers) then
		for i,pid in ipairs(war.attack_helpers) do
			local player = playermgr.getplayer(pid)
			if not player then
				player = playermgr.loadofflineplayer(pid)
			end
			assert(player,"Invalid pid:" .. tostring(pid))
			--援助玩家一定是离线玩家
			assert(player.__state == "offline")
			if player.warid then
				return false,pid
			end
		end
	end
	if not table.isempty(defensers) then
		for i,pid in ipairs(defensers) do
			for i,pid in ipairs(defensers) do
				local player = playermgr.getplayer(pid)
				if not player then
					player = playermgr.loadofflineplayer(pid)
				end
				assert(player,"Invalid pid:" .. tostring(pid))
				if player.warid then
					return false,pid
				end
			end
		end
	end
	if not table.isempty(war.defense_helpers) then
		for i,pid in ipairs(war.defense_helpers) do
			for i,pid in ipairs(war.defense_helpers) do
				local player = playermgr.getplayer(pid)
				if not player then
					player = playermgr.loadofflineplayer(pid)
				end
				assert(player,"Invalid pid:" .. tostring(pid))
				--援助玩家一定是离线玩家
				assert(player.__state == "offline")
				return false,pid
			end
		end
	end
	return true
end

--/*
-- @functions : 发起一场战斗,调用前必须先判断是否可以发起战斗
-- @param table attackers  进攻方玩家列表
-- @param table defensers  防守方玩家列表(PVE战斗传nil)
-- @param table war		   战斗数据，一般格式如下:
--	{
--		wartype=战斗类型,
--		wardataid=战斗数据ID(PVE战斗必填),
--		attack_helpers=进攻方援助列表 [可选],
--		defense_helpers=防守方援助列表 [可选],
--		其他字段（根据游戏逻辑设定)
--	}
--*/
function warmgr.startwar(attackers,defensers,war)
	local set = table.intersect_set(table.toset(attackers),table.toset(defensers))
	assert(table.isempty(set),format("attacker show in defenser:%s",set))
	for i,pid in ipairs(attackers) do
		local player = playermgr.getplayer(pid)
		if not player then
			player = playermgr.loadofflineplayer(pid)
		end
		assert(player,"Invalid pid:" .. tostring(pid))
		if player.warid then
			return
		end
	end
	sendtowarsrv("war","startwar",warmgr.packwar(war))
	if not table.isempty(attackers) then
		for i,pid in ipairs(attackers) do
			local player = playermgr.getplayer(pid)
			if not player then
				player = playermgr.loadofflineplayer(pid)
			end
			assert(player,"Invalid pid:" .. tostring(pid))
			sendtowarsrv("war","addplayer",warmgr.packplayer(player))
			if player.watch_warid then
				warmgr.quit_watchwar(player,player.watch_warid)
			end
		end
	end
	if not table.isempty(war.attack_helpers) then
		for i,pid in ipairs(war.attack_helpers) do
			local player = playermgr.getplayer(pid)
			if not player then
				player = playermgr.loadofflineplayer(pid)
			end
			assert(player,"Invalid pid:" .. tostring(pid))
			--援助玩家一定是离线玩家
			assert(player.__state == "offline")
			sendtowarsrv("war","addplayer",warmgr.packplayer(player))
		end
	end
	if not table.isempty(defensers) then
		for i,pid in ipairs(defensers) do
			for i,pid in ipairs(defensers) do
				local player = playermgr.getplayer(pid)
				if not player then
					player = playermgr.loadofflineplayer(pid)
				end
				assert(player,"Invalid pid:" .. tostring(pid))
				sendtowarsrv("war","addplayer",warmgr.packplayer(player))
				if player.watch_warid then
					warmgr.quit_watchwar(player,player.watch_warid)
				end
			end
		end
	end
	if not table.isempty(war.defense_helpers) then
		for i,pid in ipairs(war.defense_helpers) do
			for i,pid in ipairs(war.defense_helpers) do
				local player = playermgr.getplayer(pid)
				if not player then
					player = playermgr.loadofflineplayer(pid)
				end
				assert(player,"Invalid pid:" .. tostring(pid))
				--援助玩家一定是离线玩家
				assert(player.__state == "offline")
				sendtowarsrv("war","addplayer",warmgr.packplayer(player))
			end
		end
	end
	sendtowarsrv("war","finish_startwar",{warid=warid})
	war.attackers = attackers
	war.defensers = defensers
	local warid = warmgr.genwarid()
	logger.log("info","war",format("[startwar] warid=%s war=%s",warid,war))
	warmgr.addwar(warid,war)
end

-- 打包一个玩家简介数据
function warmgr.packresume(player)
	return resumemgr.getresume(player.pid)
end

function warmgr.watchwar(player,warid,towatch_pid)
	local pid = player.pid
	if player.warid then
		net.msg.S2C.notify(player.pid,language.format("战斗中无法观战"))
		return
	end
	local war = warmgr.getwar(warid)
	if not war then
		net.msg.S2C.notify(player.pid,language.format("观看的战斗失效"))
		return
	end
	local bfound = false
	if not table.isempty(war.attackers) then
		if table.find(war.attackers,towatch_pid) then
			if not table.find(war.attack_watchers,pid) then
				table.insert(war.attack_watchers,pid)
				bfound = true
			end
		end
	end
	if not bfound then
		if not table.isempty(war.defensers) then
			if table.find(war.defensers,towatch_pid) then
				if not table.find(war.defense_watchers,pid) then
					table.insert(war.defense_watchers,pid)
					bfound = true
				end
			end
		end
	end
	if not bfound then
		net.msg.S2C.notify(player.pid,language.format("观看的战斗失效"))
		return
	end
	logger.log("info","war",string.format("[watchwar] warid=%s pid=%s towatch_pid",warid,pid,towatch_pid))
	player.watch_warid = warid
	sendtowarsrv("war","watchwar",{
		warid = warid,
		watcher = warmgr.packresume(player),
		pid = towatch_pid,
	})
end

function warmgr.quit_watchwar(player,warid)
	local pid = player.pid
	warid = warid or player.watch_warid
	local war = warmgr.getwar(warid)
	if not war then
		return
	end
	local bfound = false
	local pos = table.find(war.attack_watchers,pid)
	if pos then
		table.remove(war.attack_watchers,pid)
		bfound = true
	end
	if not bfound then
		local pos = table.find(war.defense_watchers,pid)
		if pos then
			table.remove(war.defense_watchers,pid)
			bfound = true
		end
	end
	if not bfound then
		return
	end
	logger.log("info","war",string.format("[quit_watchwar] warid=%s pid=%s",warid,pid))
	player.watch_warid = nil
	sendtowarsrv("war","quit_watchwar",{
		warid = warid,
		pid = pid,
	})
end

function warmgr.broadcast_inwar(warid,func)
	local war = warmgr.getwar(warid)
	if not war then
		return
	end
	for i,pid in ipairs(war.attackers) do
		func(pid)
	end
	for i,pid in ipairs(war.defensers) do
		func(pid)
	end
end

-- force to endwar
function warmgr.force_endwar(warid,reason)
	logger.log("info","war",string.format("[force_endwar] warid=%s reason=%s",warid,reason))
	sendtowarsrv("war","endwar",{
		warid = warid,
	})
	warmgr.broadcast_inwar(warid,function (pid)
		sendpackage(pid,"war","warresult",{
			warid = warid,
		})
	end)
	warmgr.delwar(warid,reason)
end

function warmgr.quitwar(player,warid)
	local pid = player.pid
	warid = warid or player.warid
	local war = warmgr.getwar(warid)
	if not war then
		return false
	end
	local bfound = false
	if not table.isempty(war.attackers) then
		local pos = table.find(war.attackers,pid)
		if pos then
			bfound =  true
			table.remove(war.attackers,pos)
			table.insert(war.attack_escapers,pid)
			player.warid = nil
		end
	end
	if not bfound then
		if not table.isempty(war.attack_helpers) then
			local pos = table.find(war.attack_helpers,pid)
			if pos then
				bfound = true
				table.remove(war.attack_helpers,pos)
				table.insert(war.attack_escapers,pid)
				player.warid = nil
			end
		end
	end
	if not bfound then
		if not table.isempty(war.defensers) then
			local pos = table.find(war.defensers,pid)
			if pos then
				bfound = true
				table.remove(war.defensers,pos)
				table.insert(war.defense_escapers,pid)
				player.warid = nil
			end
		end
	end
	if not bfound then
		if not table.isempty(war.defense_helpers) then
			local pos = table.find(war.defense_helpers,pid)
			if pos then
				bfound = true
				table.remove(war.defense_helpers,pos)
				table.insert(war.defense_escapers,pid)
				player.warid = nil
			end
		end
	end
	if bfound then
		logger.log("info","war",string.format("[quitwar] warid=%s pid=%s",warid,pid))
		sendtowarsrv("war","quitwar",{
			warid = warid,
			pid = pid,
		})
		sendpackage(player,"war","quitwar",{
			warid = warid,
		})
		return true
	else
		return false
	end
end

function warmgr.onwarend(warid,result)
	local war = warmgr.getwar(warid)
	if not war then
		logger.log("error","war",string.format("[onwarend] Invalid_warid=%s result=%s",warid,result))
		return
	end
	logger.log("info","war",format("[onwarend] warid=%s result=%s war=%s",warid,result,war))
	for i,pid in ipairs(war.attackers) do
		sendpackage(pid,"war","warresult",{
			warid = warid,
			result = result
		})
	end
	for i,pid in ipairs(war.defensers) do
		sendpackage(pid,"war","warresult",{
			warid = warid,
			result = -result,
		})
	end
	local wartype = assert(war.wartype)
	local callback = warmgr.onwarend_callback[wartype]
	if callback then
		xpcall(callback,onerror,warid,result)
	end
	-- dosomething
	warmgr.delwar(warid)
end

return warmgr
