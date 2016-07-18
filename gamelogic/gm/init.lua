require "gamelogic.skynet"

gm = gm or {}
master = nil
master_pid = nil

local exclude_func = {
	init = true,
}

local function getfunc(cmds,cmd)
	if exclude_func[string.lower(cmd)] then
		return
	end
	if cmds[cmd] then
		return cmds[cmd],cmd
	end
	cmd = string.lower(cmd)
	for k,v in pairs(cmds) do
		if string.lower(k) == cmd then
			return v,cmd
		end
	end
end


local function docmd(player,cmdline)
	local cmd,leftcmd = string.match(cmdline,"^([%w_]+)%s+(.*)$")
	if cmd then
		local func = getfunc(gm,cmd)
		if func then
			local args = {}
			if leftcmd then
				for arg in string.gmatch(leftcmd,"[^%s]+") do
					table.insert(args,arg)
				end
			end
			return func(args)
		else
			return string.format("no cmd: %q",cmd)
		end
	else
		return "cann't parse cmdline:" .. tostring(cmdline)
	end
end

function gm.docmd(pid,cmdline)
	local player
	if pid ~= 0 then
		player = playermgr.getplayer(pid)
		if not player then
			player = playermgr.loadofflineplayer(pid)
		end
	else
		player = 0
	end
	master = player
	master_pid = player == 0 and 0 or player.pid
	--local tbl = {xpcall(docmd,onerror,player,cmdline)}
	-- gm指令执行的报错不记录到onerror.log中
	local tbl = {pcall(docmd,player,cmdline)}
	master = nil
	master_pid = nil
	local issuccess = table.remove(tbl,1)
	local result
	if next(tbl) then
		for i,v in ipairs(tbl) do
			tbl[i] = mytostring(v)
		end
		result = table.concat(tbl,",")
	end
	logger.log("info","gm",format("[gm.docmd] pid=%s cmd='%s' issuccess=%s result=%s",pid,cmdline,issuccess,result))
	if pid ~= 0 then
		net.msg.S2C.notify(pid,string.format("执行%s\n%s",issuccess and "未报错" or "报错了",result))
	end
	return issuccess,result
end

function gm.init()
	require "gamelogic.gm.sys"
	require "gamelogic.gm.helper"
	require "gamelogic.gm.test"
	require "gamelogic.gm.other"
	require "gamelogic.gm.player"
end

function __hotfix(oldmod)
	gm.init()
	gm.__doc = nil
end

return gm
