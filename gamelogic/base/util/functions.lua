--/*
-- 功能:游戏内常用全局函数/lua5.3兼容
--*/
unpack = unpack or table.unpack

--STARTTIME1 = 1408896000  --2014-08-25 00:00:00 Mon Aug
--STARTTIME2 = 1408809600  --2014-08-24 00:00:00 Sun Aug
STARTTIME1 = os.time({year=2014,month=8,day=25,hour=0,min=0,sec=0})
STARTTIME2 = os.time({year=2014,month=8,day=24,hour=0,min=0,sec=0})
HOUR_SECS = 3600
DAY_SECS = 24 * HOUR_SECS 
WEEK_SECS = 7 * DAY_SECS

SAVE_DELAY = 240

-- number
MAX_NUMBER = math.floor(2 ^ 31 - 1)
MIN_NUMBER = -MAX_NUMBER

SYSTEM_MAIL = 0
BASE_RATIO = 1000000

--用户必须保证对象非递归嵌套表
function mytostring(obj)
	if type(obj) ~= "table" then
		return tostring(obj)
	end
	if obj.__type then  -- 类实例
		return tostring(obj)
	end
	local cache = {}
	table.insert(cache,"{")
	for k,v in pairs(obj) do
		if type(k) == "number" then
			--table.insert(cache,mytostring(v)..",")
			table.insert(cache,string.format("[%d]=%s,",k,mytostring(v)))
		else
			local str = string.format("%s=%s,",mytostring(k),mytostring(v))
			table.insert(cache,str)	
		end
	end
	table.insert(cache,"}")
	return table.concat(cache)
end

function format(fmt,...)
	--local args = {...}	--无法处理nil值参数
	local args = table.pack(...)
	local len = math.max(#args,args.n or 0)
	for i = 1, len do
		if type(args[i]) == "table" then
			args[i] = mytostring(args[i])
		elseif type(args[i]) ~= "number" then
			args[i] = tostring(args[i])
		end
	end
	return string.format(fmt,unpack(args))
end

function printf(fmt,...)
	if ... == nil then
		print(fmt)
	else
		print(format(fmt,...))
	end
end

function pretty_tostring(obj,indent)
	indent = indent or 0
	if type(obj) ~= "table" then
		return tostring(obj)
	end
	local cache = {}
	table.insert(cache,"{")
	indent = indent + 4
	if indent >= 4 * 25 then
		local msg = "deep >= 25,may be in endless"
		skynet.error(msg)
		print(msg)
		return {"...",}
	end
	for k,v in pairs(obj) do
		if type(k) == "number" then
			table.insert(cache,string.rep(" ",indent) .. string.format("[%d]=%s,",k,pretty_tostring(v,indent)))
		else
			local str = string.rep(" ",indent) .. string.format("%s=%s,",pretty_tostring(k,indent),pretty_tostring(v,indent))
			table.insert(cache,str)	
		end
	end
	indent = indent - 4
	table.insert(cache,string.rep(" ",indent) .. "}")
	return table.concat(cache,"\n")
end

function pretty_format(fmt,...)
	--local args = {...}	--无法处理nil值参数
	local args = table.pack(...)
	local len = math.max(#args,args.n or 0)
	for i = 1, len do
		if type(args[i]) == "table" then
			args[i] = pretty_tostring(args[i],0)
		elseif type(args[i]) ~= "number" then
			args[i] = tostring(args[i])
		end
	end
	return string.format(fmt,unpack(args))
end

function pprintf(fmt,...)
	--print(pretty_format(fmt,...))
	-- print 引擎禁用了
	io.write(pretty_format(fmt,...))
	io.write("\n")
end

--copy
-------------------------------------------------------------
-- lua元素复制接口,提供浅复制(copy)和深复制两个接口(deepcopy)
-- 深复制解决以下3个问题:
-- 1. table存在循环引用
-- 2. metatable(metatable都不参与复制)
-- 3. keys也是table
--------------------------------------------------------------
function copy(o)
	local typ = type(o)
	if typ ~= "table" then return o end
	local newtable = {}
	for k,v in pairs(o) do
		newtable[k] = v
	end
	return setmetatable(newtable,getmetatable(o))
end


function deepcopy(o,seen)
	local typ = type(o)
	if typ ~= "table" then return o end
	seen = seen or {}
	if seen[o] then return seen[o] end
	local newtable = {}
	seen[o] = newtable
	for k,v in pairs(o) do
		newtable[deepcopy(k,seen)] = deepcopy(v,seen)
	end
	return setmetatable(newtable,getmetatable(o))
end

--ratio
function ishit(num,limit)
	limit = limit or BASE_RATIO
	assert(limit >= num)
	return math.random(1,limit) <= num
end

function shuffle(list,inplace,limit)
	if not inplace then
		list = deepcopy(list)
	end
	local idx,tmp
	local len = #list
	for i = 1,len-1 do
		if limit and i > limit then
			return table.slice(list,1,limit)
		end
		idx = math.random(i,len)
		tmp = list[idx]
		list[idx] = list[i]
		list[i] = tmp
	end
	return list
end

function randlist(list)
	assert(#list > 0,"list length need > 0")
	local pos = math.random(1,#list)
	return list[pos],pos
end



function choosevalue(dct,func)
	local sum = 0
	for ratio,val in pairs(dct) do
		sum = sum + (func and func(ratio,val) or ratio)
	end
	local hit = math.random(1,sum)
	local limit = 0
	for ratio,val in pairs(dct) do
		limit = limit + (func and func(ratio,val) or ratio)
		if hit <= limit then
			return val
		end
	end
	return nil
end

function choosekey(dct,func)
	local sum = 0
	for key,ratio in pairs(dct) do
		sum = sum + (func and func(key,ratio) or ratio)
	end
	assert(sum >= 1,"[choosekey] Invalid sum ratio:" .. tostring(sum))
	local hit = math.random(1,sum)
	local limit = 0
	for key,ratio in pairs(dct) do
		limit = limit + (func and func(key,ratio) or ratio)
		if hit <= limit then
			return key
		end
	end
	return nil
end

-- time
function gethourno(now,start)
	now = now or os.time()
	start = start or STARTTIME1
	local tm = now - start
	return math.floor(tm/HOUR_SECS) + (tm % HOUR_SECS == 0 and 0 or 1)
end

function gethourno2()
	local tm = os.time() - STARTTIME1
	return math.floor(tm/HOUR_SECS) + (tm % HOUR_SECS == 0 and 0 or 1)
end

function getdayno(flag)
	local start = flag and STARTTIME2 or STARTTIME1
	local tm = os.time() - start
	return math.floor(tm/DAY_SECS) + (tm % DAY_SECS == 0 and 0 or 1)
end

function getdayno2()
	local tm = os.time() - STARTTIME1
	return math.floor(tm/DAY_SECS) + (tm % DAY_SECS == 0 and 0 or 1)
end

function getweekno(flag)
	local start = flag and STARTTIME2 or STARTTIME1
	local tm = os.time() - start
	return math.floor(tm/WEEK_SECS) + (tm % WEEK_SECS == 0 and 0 or 1)
end

function getweekno2()
	local tm = os.time() - STARTTIME1
	return math.floor(tm/WEEK_SECS) + (tm % WEEK_SECS == 0 and 0 or 1)
end

function getsecond(now)
	return now or os.time()
end

function getyear(now)
	now = now or os.time()
	local s = os.date("%Y",now)
	return tonumber(s)
end

function getyearmonth(now)
	now = now or os.time()
	local s = os.date("%m",now)
	return tonumber(s)
end

function getmonthday(now)
	now = now or os.time()
	local s = os.date("%d",now)
	return tonumber(s)
end

-- 本月有多少天
function howmuchdays(monthno)
	local month_zerotime = os.time({year=getyear(),month=monthno,day=1,hour=0,min=0,sec=0})
	for monthday in ipairs({31,30,29,28}) do
		local time = month_zerotime + monthday * DAY_SECS
		if getyearmonth(time) == monthno then
			return monthday
		end
	end
	assert("Invalid monthno:" .. tostring(monthno))
end

--星期天为0
function getweekday(now)
	now = now or os.time()
	local s = os.date("%w",now)
	return tonumber(s)
end

function getdayhour(now)
	now = now or os.time()
	local s = os.date("%H",now)
	return tonumber(s)
end

function gethourminute(now)
	now = now or os.time()
	local s = os.date("%M",now)
	return tonumber(s)
end

function getminutesecond(now)
	now = now or os.time()
	local s = os.date("%S",now)
	return tonumber(s)
end

--当天过去的秒数
function getdaysecond(now)
	now = now or os.time()
	return getdayhour(now) * HOUR_SECS + gethourminute(now) * 60 + getminutesecond(now)
end

--当天0点时间(秒为单位)
function getdayzerotime(now)
	now = now or os.time()
	return getsecond(now) - getdaysecond(now)
end


-- 当周0点(星期一为一周起点)
function getweekzerotime(now)
	now = now or os.time()
	local weekday = getweekday(now)
	weekday = weekday == 0 and 7 or weekday
	local diffday = weekday - 1
	return getdayzerotime(now-diffday*DAY_SECS)
end

-- 当周0点（星期天为一周起点)
function getweek2zerotime(now)
	now = now or os.time()
	local weekday = getweekday(now)
	local diffday = weekday - 0
	return getdayzerotime(now-diffday*DAY_SECS)
end

-- 当月0点
function getmonthzerotime(now)
	now = now or os.time()
	local monthday = getmonthday(now)
	return getdayzerotime(now-monthday*DAY_SECS)
end

function dhms_time(fmt,secs)
	local day = math.floor(secs/DAY_SECS)
	local hour = math.floor(secs/HOUR_SECS)
	local min = math.floor(secs/60)
	local sec = secs
	if fmt.day then
		hour = hour - 24 * day
		min = min - 24*60 * day
		sec = sec - 24*3600 * day
	end
	if fmt.hour then
		min = min - 60 * hour
		sec = sec - 3600 * hour
	end
	if fmt.min then
		sec = sec - 60 * min
	end
	return {
		day = day,
		hour = hour,
		min = min,
		sec = sec,
	}
end


-- 格式化时间，最大粒度：天
-- %D : XX day
-- %H : XX hour
-- %M : XX minute
-- %S : XX sec
-- %d/%h/%m/%s含义同对应大写格式,但是不会0对齐
-- e.g:
-- strftime("%D天%H时%S秒",30*24*3600+3601) => 30天01时01秒
-- strftime("%h时%s秒",30*24*3600+3601) => 721时1秒
function strftime(fmt,secs)
	local startpos = 1
	local endpos = string.len(fmt)
	local has_fmt = {}
	for pos=startpos,endpos do
		local findit,fmtflag
		findit,pos,fmtflag = string.find(fmt,"%%([dhmsDHMS])",pos)
		if not findit then
			break
		else
			pos = pos + 1
			has_fmt[fmtflag] = true
		end
	end
	if not next(has_fmt) then
		return fmt
	end
	local date_fmt = {sec=true}
	if has_fmt["d"] or has_fmt["D"] then
		date_fmt.day = true
	end
	if has_fmt["h"] or has_fmt["H"] then
		date_fmt.hour = true
	end
	if has_fmt["m"] or has_fmt["M"] then
		date_fmt.min = true
	end
	local date = dhms_time(date_fmt,secs)
	local DAY = string.format("%02d",date.day)
	local HOUR = string.format("%02d",date.hour)
	local MIN = string.format("%02d",date.min)
	local SEC = string.format("%02d",date.sec)
	local day = tostring(date.day)
	local hour = tostring(date.hour)
	local min = tostring(date.min)
	local sec = tostring(date.sec)
	local repls = {
		d = day,
		h = hour,
		m = min,
		s = sec,
		D = DAY,
		H = HOUR,
		M = MIN,
		S = SEC,
	}
	return string.gsub(fmt,"%%([dhmsDHMS])",repls)
end

--如果参数为nil,则取当前对应时间
function mktime(year,month,day,hour,min,sec)
	local now = os.time()
	year = year or getyear(now)
	month = month or getyearmonth(now)
	day = day or getmonthday(now)
	hour = hour or getdayhour(now)
	min = min or gethourminute(now)
	sec = sec or getminutesecond(now)
	return os.time({year=year,month=month,day=day,hour=hour,min=min,sec=sec})
end

--filesystem
function currentdir()
	local ok,lfs = pcall(require,"lfs")
	if ok then
		return lfs.currentdir()
	end
	local fd = io.popen("pwd")
	local path = fd:read("*all"):trim()
	fd:close()
	return path
end

function sendtowarsrv(protoname,subprotoname,request)
	local warsrv = skynet.getenv("warsrv")
	return rpc.pcall(warsrv,protoname,subprotoname,request)
end


-- 为了兼容框架，pid可能是连线对象（包括在线玩家），或者玩家ID
-- 登录相关协议传连线对象，其他协议均传玩家ID
function sendpackage(pid,protoname,subprotoname,request)
	local agent,uid
	if type(pid) == "table" then
		agent = pid.__agent
		uid = pid.pid
	else
		local obj = playermgr.getobject(pid)
		if obj then
			if obj.delaypackage.isopen then
				obj.delaypackage:push(protoname,subprotoname,request)
				return
			end
			agent = obj.__agent
			uid = pid
		end
	end
	if agent then
		if skynet.getenv("servermode") == "DEBUG" then
			logger.log("debug","netclient",format("[send] pid=%s agent=%s protoname=%s subprotoname=%s request=%s",uid,agent,protoname,subprotoname,request))
		end
		skynet.send(agent,"lua","senddata",{
			p = protoname,   -- 主协议
			s = subprotoname, -- 子协议
			a = request,	  -- 参数
		})
	end
end

sendtoclient = sendpackage



function checkargs(args,...)
	local typs = {...}
	if #typs == 0 then
		return true,args
	end
	local ret = {}
	for i = 1,#typs do
		if typs[i] == "*" then -- ignore check
			for j=i,#args do
				table.insert(ret,args[j])
			end
			return true,ret
		end
		if not args[i] then
			return nil,string.format("argument not enough(%d < %d)",#args,#typs)
		end
		local typ = typs[i]
		local range_begin,range_end
		local val
		local pos = string.find(typ,":")
		if pos then
			typ = typ:sub(1,pos-1)
			range_begin,range_end = string.match(typ:sub(pos+1),"%[([%d.]*),([%d.]*)%]")
			if not range_begin then
				range_begin = MIN_NUMBER
			end
			if not range_end then
				range_end = MAX_NUMBER
			end
			range_begin,range_end = tonumber(range_begin),tonumber(range_end)
		end
		if typ == "int" or typ == "double" then
			val = tonumber(args[i])
			if not val then
				return false,"invalid number:" .. tostring(args[i])
			end
			if typ == "int" then
				val = math.floor(val)
			end
			if range_begin and range_end then
				if not (range_begin <= val and val <= range_end) then
					return false,string.format("%s not in range [%s,%s]",val,range_begin,range_end)
				end
			end
			table.insert(ret,val)
		elseif typ == "boolean" then
			typ = string.lower(typ)
			if not (typ == "true" or typ == "false" or typ == "1" or typ == "0") then
				return false,"invalid boolean:" .. tostring(typ)
			end
			val = (typ == "true" or typ == "1") and true or false
			table.insert(ret,val)
		elseif typ == "string" then
			val = args[i]
			table.insert(ret,val)
		else
			return false,"unknow type:" ..tostring(typ)
		end
	end
	return true,ret
end

local COLLECT_ATTRS  = {"pid","id","name","sid","warid","flag","state","inarea","targetid","tid","taskid","type","srvname","objid","__fd","__status","m_ID","sceneid","mapid","posid","srvno","owner"}

local function collect_localvar(level)
	level = level + 1 -- skip self function 'collect_localval'
	local function dumptable(tbl) 
		local tips = {}
		local attrs = COLLECT_ATTRS
		for _,attr in ipairs(attrs) do
			if tbl[attr] then
				table.insert(tips,string.format("\t%s=%s",attr,tbl[attr]))
			end
		end
		return tips
	end

	local ret = {}
	local i = 0
	while true do
		i = i + 1
		local name,value = debug.getlocal(level,i)
		if not name then
			break
		end
		
		table.insert(ret,string.format("%s=%s",name,value))
		if type(value) == "table" then
			local tips = dumptable(value)
			if #tips > 0 then
				table.insert(ret,table.concat(tips,"\n"))
			end
		end
	end
	return ret
end

function onerror(msg)
	local level = 4
	pcall(function ()
		-- assert/error触发(需要搜集level+1层--调用assert/error函数所在层)
		-- 代码逻辑直接触发搜集level层即可
		local vars = collect_localvar(level)
		table.insert(vars,"================")
		local vars2 = collect_localvar(level+1)
		for _,s in ipairs(vars2) do
			table.insert(vars,s)
		end
		-- rpc.call时搜集不到srvname,因此多加一层
		table.insert(vars,"================")
		local vars2 = collect_localvar(level+3)
		for _,s in ipairs(vars2) do
			table.insert(vars,s)
		end

		table.insert(vars,1,string.format("[ERROR] [%s] %s",os.date("%Y-%m-%d %H:%M:%S"),msg))
		local msg = debug.traceback(table.concat(vars,"\n"),level)
		print(msg)
		require "gamelogic.logger.init"
		logger.log("error","errdetail",msg)
		--skynet.error(msg)
	end)
end

HEX_MAP = {}
for i=0,15 do
	local char
	if i >= 10 then
		char = string.char(97+i-10)
	else
		char = tostring(i)
	end
	HEX_MAP[i] = char
	HEX_MAP[char] = i
end


function uuid(len)
	len = len or 32
	local ret = {}
	for i=1,len do
		table.insert(ret,HEX_MAP[math.random(0,0xf)])
	end
	return table.concat(ret,"")
end


function istrue(val)
	if val then
		if type(val) == "number" then
			return val ~= 0
		elseif type(val) == "string" then
			val = string.lower(val)
			return val == "true" or val == "yes"
		end
	end
	return false
end

function getdistance(pos1,pos2)
	return math.ceil(math.sqrt((pos1.x-pos2.x)^2 + (pos1.y-pos2.y)^2))
end

-- pack_function/unpack_function [START]
local function getcmd(t,cmd)
	local _cmd = string.format("return %s",cmd)
	t[cmd] = load(_cmd,"=(load)","bt",_G)
	return t[cmd]
end
local compile_cmd = setmetatable({},{__index=getcmd})


function pack_function(cmd,...)
	-- 保证最后一个参数为nil时不丢失
	local n = select("#",...)
	local args = {...}
	local pack_data = {
		cmd = cmd,
		args = cjson.encode(args),
		n = n,
		_name = "pack_function",
	}
	return pack_data
end

function unpack_function(pack_data)
	local cmd = pack_data.cmd
	local attrname,sep,funcname = string.match(cmd,"^(.*)([.:])(.+)$")
	-- e.g: cmd = print
	if not sep then
		attrname = "_G"
		sep = "."
		funcname = cmd
	end
	local args = pack_data.args
	args = cjson.decode(args)
	--print("cjson.decode",cmd,attrname,sep,funcname)
	local n = pack_data.n
	--loadstr = string.format("return %s",attrname)
	--local chunk = load(loadstr,"(=load)","bt",_G)
	local chunk = compile_cmd[attrname]
	local caller = chunk()
	if type(caller) == "function" then
		caller = caller()
	end
	if sep == "." then
		return functor(caller[funcname],table.unpack(args,1,n))
	else
		assert(sep == ":")
		return functor(caller[funcname],caller,table.unpack(args,1,n))
	end
end

function is_pack_function(func)
	if type(func) == "table" then
		return func._name == "pack_function"
	end
end
-- pack_function/unpack_function [END]

function execformula(formula,params)
	local chunk = load(formula,"=(load)","bt",params)
	return chunk()
end

function frozen(obj,timeout)
	timeout = timeout or 50
	obj.bfrozen = true
	if timeout then
		timer.timeout2("timer.frozen",timeout,function ()
			unfrozen(obj)
		end)
	end
end

function unfrozen(obj)
	obj.bfrozen = nil
end

function isfrozen(obj)
	return obj.bfrozen
end
