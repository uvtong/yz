netplayer = netplayer or {
	C2S = {},
	S2C = {},
}

local C2S = netplayer.C2S
local S2C = netplayer.S2C

function C2S.gm(player,request)
	if skynet.getenv("servermode") ~= "DEBUG" and not player:query("gm") then
		net.msg.S2C.notify(player.pid,"你没有权限执行gm指令")
		return
	end
	local cmd = assert(request.cmd)
	-- trim prefix "$"
	cmd = string.ltrim(cmd,"%$")
	gm.docmd(player.pid,cmd)
end

-- 分配素质点
function C2S.alloc_qualitypoint(player,request)
	local isok,errmsg = player:alloc_qualitypoint(request)
	if not isok then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	end
end

-- 重置素质点
function C2S.reset_qualitypoint(player,request)
	player:reset_qualitypoint()
end

-- s2c

return netplayer