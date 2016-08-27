netplayer = netplayer or {
	C2S = {},
	S2C = {},
}

local C2S = netplayer.C2S
local S2C = netplayer.S2C

function C2S.gm(player,request)
	if not player:isgm() then
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

-- 开启/关闭开关
function C2S.switch(player,request)
	local switchs = assert(request.switchs)
	if table.isempty(switchs) then
		return
	end
	player:setswitch(switchs)
end

function C2S.rename(player,request)
	local name = assert(request.name)
	local isok,errmsg = isvalid_name(name)
	if not isok then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	end
	player.name = name
	sendpackage(player.pid,"player","update",{
		name = name,
	})
end

-- s2c

function S2C.switch(pid,switchs)
	if table.isempty(switchs) then
		return
	end
	sendpackage(pid,"player","switch",{ switchs = switchs, })
end

return netplayer
