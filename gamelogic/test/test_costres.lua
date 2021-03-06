local function test(pid)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	for resid,resdata in pairs(data_ResType) do
		local restype = resdata.flag
		player[restype] = 0
	end
	player.itemdb:clear()
	local reason = "test"
	local id = player:oncostres({
		items = {
			{type=401001,num=3},
			{type=401100,num=3},
		},
		gold = 1,
		silver = 3,
		coin = 10,
	},reason,true,function (uid)
		print("[res not enough] no print")
	end)
	assert(id ~= nil)
	net.msg.C2S.respondanswer(player,{
		id = id,
		answer = 1,
	})
	
	local reason = "test"
	player:addgold(100,reason)
	local id = player:oncostres({
		items = {
			{type=401001,num=3},
			{type=401100,num=3},
		},
		gold = 1,
		silver = 3,
		coin = 10,
	},reason,true,function (uid)
		print("cost 2 gold")
	end)
	assert(id ~= nil)
	net.msg.C2S.respondanswer(player,{
		id = id,
		answer = 1,
	})
	assert(player.gold==98)
end

return test
