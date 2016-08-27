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


local function docmd(cmdline)
	local cmd,leftcmd = string.match(cmdline,"^([%w_]+)%s*(.*)$")
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
	local tbl = {xpcall(docmd,onerror,cmdline)}
	-- gm指令执行的报错不记录到日志中
	--local tbl = {pcall(docmd,cmdline)}
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
	require "gamelogic.gm.res"
	require "gamelogic.gm.item"
	require "gamelogic.gm.map"
	require "gamelogic.gm.skill"
	require "gamelogic.gm.mergeserver"
	require "gamelogic.gm.task"
	require "gamelogic.gm.war"
end

function gm.onlogin(player)
	if player:isgm() then
		local msg = [[Hi,看到此消息表明你已经是GM了
		为了快速入门，系统提供以下帮助指令:
		1. help 关键字 <=> 查找包含'关键字'的指令用法
		如: help gold <=> 会显示所有金币相关的指令用法。
		如果你是在公司内网操作，也可以用buildgmdoc来生
		成最新的指令用法文档，具体存放路径在(策划文档/GM/GM指令文档.txt)
		GM指令可以在世界频道输入'$指令 参数'来操作，
		如: $addgold 100 <=> 给自身增加100金币]]
		local sender = net.msg.packsender(player)
		local packmsg = {
			sender = sender,
			msg = msg
		}
		sendpackage(player.pid,"msg","worldmsg",packmsg)
	end
end

function gm.say(pid,msg)
	local sender = {
		pid = 0,
		name = "系统",
	}
	print("gm.say",pid,msg)
	sendpackage(pid,"msg","worldmsg",{
		sender = sender,
		msg = msg
	})
end


function __hotfix(oldmod)
	gm.init()
	gm.__doc = nil
end

return gm
