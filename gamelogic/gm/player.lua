
gm = require "gamelogic.gm.init"

-- cmd: playerset
-- usage: playerset 属性名 属性值 [玩家ID]
-- e.g: playerset lv 10 <=> 不指定玩家ID，将自身等级设置成10级
-- e.g: playerset lv 10 1000001 <=> 将1000001玩家等级设置成10级
function gm.playerset(args)
	local isok,args = checkargs(args,"string","string","*")
	if not isok then
		net.msg.S2C.notify(master_pid,"usage: playerset 属性名 属性值 [玩家ID]")
		return
	end
	local key = args[1]
	local chunk = loadstring("return " .. args[2])
	local pid = tonumber(args[3]) or master_pid
	local val = chunk()
	local player = playermgr.getplayer(pid)
	if not player then
		net.msg.S2C.notify(master_pid,string.format("玩家(%s)不在线",pid))
		return
	end
	if not player[key] or type(player[key]) == "function" then
		net.msg.S2C.notify(master_pid,"非法属性")
		return
	end
	player[key] = val
end

return gm
