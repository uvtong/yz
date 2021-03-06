package.path = package.path  .. ";../src/?.lua;../src/?.luo;../src/?/init.lua;../src/?/init.luo"
--print("package.path:",package.path)
--print("package.cpath:",package.cpath)
local skynet = require "gamelogic.skynet"
local redis = require "redis"

local conn = nil
local conn_conf = nil
-- ignore watch

local command = {}
function command.connect(conf)
	if conf then
		conn_conf = conf
	end
	assert(conn_conf,"No db config")
	if not conn then
		conn = redis.connect(conn_conf)
		return "connected"
	else
		return "already connected"
	end
end

function command.disconnect()
	if conn then
		local _conn = conn
		conn = nil		-- 先置空
		conn_conf = nil
		_conn:disconnect()
		return "disconnected"
	else
		return "alredy disconnected"
	end
end

-- 容灾处理流程：
-- 1. 队列缓存所有执行失败的指令,以保证重新落地时序
-- 2. 当网络畅通（恢复正常后),将所有落地失败的指令重新落地,如果仍然落地失败，则写到文件记录失败指令
-- 3. 为了防止队列过大(占用内存过大)，设定了一个最大队列长度,因此容灾的时间长度也受限定。本身容灾处理
-- 的应该是短时间内（如几秒内)与db失去连接，程序具备一定的容错性。 如果db长时间断开连接，容灾是解决不了
-- 问题。

local queue = {
	cmds = {},
	len = 0,
}

function queue.push(...)
	--print("push",...)
	table.insert(queue.cmds,{
		cmd = {...},
		response = skynet.response(),
		time = string.format("[%s.%s]",os.date("%y-%m-%d %H:%M:%S"),skynet.now()),
	})
	queue.len = queue.len + 1
end

function queue.pop()
	if queue.len == 0 then
		return nil
	end
	local elem = table.remove(queue.cmds,1)
	queue.len = queue.len - 1
	--print("pop",table.unpack(elem.cmd))
	return elem
end

function queue.peer()
	if queue.len == 0 then
		return nil
	end
	local elem = queue.cmds[1]
	--print("peer",table.unpack(elem.cmd))
	return elem
end

function queue.clear()
	skynet.error(string.format("[queue.clear] len=%s",queue.len))
	local cmds = queue.cmds
	queue.cmds = {}
	queue.len = 0
	for i,elem in ipairs(cmds) do
		elem.response(false)
		queue.dumptofile(elem)
	end
end

-- 最大缓存长度，防止db容灾时间过长，内存不足
local MAXLEN = skynet.getenv("db_cache_maxlen") or 100000
local fd = nil
function queue.dumptofile(elem)
	if not fd then
		local ip_port = string.format("%s_%s",conn_conf.host,conn_conf.port)
		local filename = string.format("%s_db_writefail_%s_%s.data",ip_port,os.date("%Y%m%d%H%M%S"),skynet.now())
		fd = io.open(filename,"ab")
	end
	local line = table.concat(elem.cmd," ")
	line = string.format("%s\t%s\n",elem.time,line)
	--print("writefail cmd",line)
	fd:write(line)
	fd:flush()
end

function command.dump()
	local ret = {}
	ret.len = queue.len
	if ret.len < 30 then
		ret.cmds = {}
		for i,tbl in ipairs(queue.cmds) do
			table.insert(ret.cmds,{cmd=tbl.cmd,time=tbl.time})
		end
	end
	skynet.ret(skynet.pack(ret))
end


skynet.start(function ()
	skynet.dispatch("lua",function (session,source,cmd,...)
		local delay_response = false
		local isok,result = false,"unknow cmd"
		local func = command[cmd]
		if func then
			isok,result = pcall(func,...)
		else
			-- 首次连接数据库失败，conn为空值
			if not conn then
				command.connect()
			end
			func = conn[cmd]
			if func then
				--print("exec",cmd,...)
				isok,result = pcall(func,conn,...)
				--print("exec",isok,result,cmd,...)
				if not isok then
					-- 这里执行失败有两种原因：1. 网络不好，db连接不畅; 2. 自身指令有问题。 本身自身指令错误不应该缓存
					-- 记录落地失败指令，待网络恢复正常后重新落地
					if result and string.find(result,"ERR") then
						error(result)
					end
					queue.push(cmd,...)
					-- 防止内存不足
					if queue.len > MAXLEN then
						queue.clear()
					end
					delay_response = true
				else
					-- 这里处理有一个指令的时序问题,正常流程是:先检查db是否连接畅通，畅通后，落地"失败指令"，落地"当前指令"
					-- 现在当前指令比失败指令先落地了
					while queue.len > 0 do
						local elem = queue.pop()
						local cmd = elem.cmd[1]
						local func = conn[cmd]
						if func then
							local ok,ret = pcall(func,conn,select(2,table.unpack(elem.cmd)))
							if ok then
								elem.response(true,ret)
							else
								skynet.error(ret)
								elem.response(false)
								queue.dumptofile(elem)
							end
						else
							skynet.error("Unknow cmd:" .. tostring(cmd))
							elem.response(false)
						end
					end
				end
			end
		end
		-- 执行失败指令，会延迟到下次网络畅通后再回复
		if not delay_response then
			if isok then
				skynet.ret(skynet.pack(result))
			else
				skynet.error(result)
				skynet.ret(skynet.pack(false))
			end
		end
	end)
end)

