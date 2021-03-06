gm = require "gamelogic.gm.init"

local friend = {}

function gm.friend(args)
	local funcname = args[1]
	local player = playermgr.getplayer(master_pid)
	if not player then
		return
	end
	local func = friend[funcname]
	if not func then
		gm.notify("指令未找到，查看帮助：help friend",master_pid)
		return
	end
	table.remove(args,1)
	func(player,args)
end

--- 指令: friend addall
--- 用法: friend addall <=> 添加该服所有玩家为好友，上限200
function friend.addall(player,args)
	if not friend.plist then
		friend.plist = {}
		local db = dbmgr.getdb()
		local pidlist = db:hkeys(db:key("role","list")) or {}
		for i,v in ipairs(pidlist) do
			friend.plist[tonumber(v)] = true
		end
	end
	for pid,_ in pairs(friend.plist) do
		if player.frienddb:can_addfriend(pid) then
			local isok = rpc.callplayer(pid,"playermethod",pid,"frienddb:tryaddfriend",player.pid)
			if isok then
				player.frienddb:delapplyer(pid)
				player.frienddb:delrecommend(pid)
				player.frienddb:addfriend(pid)
			end
		end
	end
end


