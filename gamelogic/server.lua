cserver = class("cserver",cdatabaseable)

function cserver:init()
	logger.log("info","server","[init]")
	self.flag = "cserver"
	cdatabaseable.init(self,{
		pid = 0,
		flag = self.flag,
	})
	self.data = {}
	self.onlinelimit = tonumber(skynet.getenv("maxclient")) or 10240

	self.loadstate = "unload"
	self.savename = string.format("%s.%s",self.flag,self.pid)
	autosave(self)
end

function cserver:create()
	logger.log("info","server","[create]")
	self:set("createtime",os.time())
end

function cserver:save()
	local data = {}
	data.data = self.data
	return data
end

function cserver:load(data)
	if not data or not next(data) then
		return
	end
	self.data = data.data
end

function cserver:savetodatabase()
	if self.loadstate ~= "loaded" then
		return
	end
	local data = self:save()
	local db = dbmgr.getdb()
	db:set(db:key("global","server"),data)
end

function cserver:loadfromdatabase()
	if self.loadstate ~= "unload" then
		return
	end
	self.loadstate = "loading"
	local db = dbmgr.getdb()
	local data = db:get(db:key("global","server"))
	if data == nil then
		self:create()
	else
		self:load(data)
	end
	self.loadstate = "loaded"
end



-- getter
function cserver:getopenday()
	if not self:query("createtime") then
		self:set("createtime",os.time())
	end
	return getdayno() - getdayno(self:query("createtime")) + self:query("openday",0)
end

function cserver:addopenday(val,reason)
	logger.log("info","server",string.format("[addopenday] val=%d reason=%s",val,reason))
	self:add("openday",val)
end

function cserver:getsrvlv(openday)
	openday = openday or self:getopenday()
	local srvinfo = data_SrvLv[openday]
	if not srvinfo then
		return data_GlobalVar.MaxSrvLv
	end
	return srvinfo.srvlv
end


function cserver:isopen(typ)
	if typ == "friend" then
		if not cserver.isgamesrv() then
			return false
		end
		if not clustermgr.isconnect(cserver.datacenter()) then	
			return false
		end
		return true
	end
end

function cserver.starttimer_logstatus()
	local interval = skynet.getenv("servermode") == "DEBUG" and 5 or 60
	timer.timeout("timer.logstatus",interval,cserver.starttimer_logstatus)
	local mqlen = skynet.mqlen()
	logger.log("info","status",string.format("onlinenum=%s linknum=%s offlinenum=%s kuafunum=%s gokuafunum=%s num=%s task=%s mqlen=%s",playermgr.onlinenum,playermgr.linknum,playermgr.offlinenum,playermgr.kuafunum,playermgr.gokuafunum,playermgr.num,skynet.task(),mqlen))
	if cserver.isgamesrv() then
		local url = string.format("/update_srv_status")
		local request = make_request({
			gameflag = cserver.gameflag(),
			srvname = cserver.getsrvname(),
			createtime = globalmgr.server:query("createtime"),
			onlinenum = playermgr.onlinenum,
			onlinelimit = globalmgr.server.onlinelimit,
			loadlv = mqlen / 1000,  -- >=1--高负载
		})
		httpc.postx(cserver.accountcenter(),url,request)
	end
	if ishit(1,5) then
		cserver.allsrv_status(true)
	end
end

function cserver.allsrv_status(bforce)
	if not cserver._allsrv_status or bforce then
		local url = string.format("/allsrv_status")
		local request = make_request({
			gameflag = cserver.gameflag(),
			srvname = cserver.getsrvname(),
		})
		local status,response = httpc.postx(cserver.accountcenter(),url,request)
		if status == 200 then
			local errcode,result = unpack_response(response)
			if errcode == STATUS_OK then
				cserver._allsrv_status = result
			end
		end
	end
	return cserver._allsrv_status
end

function cserver.isopensrv(srvname)
	srvname = srvname or cserver.getsrvname()
	local allsrv_status = cserver.allsrv_status()
	local srvinfo = allsrv_status[srvname]
	if srvinfo then
		return istrue(srvinfo.isopen)
	else
		local srv = data_RoGameSrvList[srvname]
		if istrue(srv.isopen) then
			return true
		end
	end
	return false
end

-- class method
function cserver.isdatacenter(srvname)
	srvname = srvname or cserver.getsrvname()
	return string.find(srvname,"datacenter") ~= nil
end

function cserver.datacenter()
	return skynet.getenv("datacenter") or "datacenter"
end

function cserver.accountcenter()
	return skynet.getenv("accountcenter") or "192.168.1.244:8886"
end

function cserver.warsrv()
	return skynet.getenv("warsrv")
end

function cserver.unionsrv()
	return skynet.getenv("unionsrv") or "unionsrv"
end

function cserver.gameflag()
	return skynet.getenv("gameflag") or "ro"
end

function cserver.isgamesrv(srvname)
	srvname = srvname or cserver.getsrvname()
	return string.find(srvname,"gamesrv") ~= nil
end

function cserver.iswarsrv(srvname)
	srvname = srvname or cserver.getsrvname()
	return string.find(srvname,"warsrv") ~= nil
end

function cserver.isaccountcenter(srvname)
	srvname = srvname or cserver.getsrvname()
	return string.find(srvname,"accountcenter") ~= nil
end

function cserver.isunionsrv(srvname)
	srvname = srvname or cserver.getsrvname()
	return string.find(srvname,"unionsrv") ~= nil
end

-- 仅对游戏服有效
function cserver.isinnersrv(srvname)
	srvname = srvname or cserver.getsrvname()
	local data = data_RoGameSrvList[srvname]
	if string.find(data.zonename,"inner") then
		return true
	end
	return false
end


function cserver.isvalidsrv(srvname)
	local data = data_RoGameSrvList[srvname]
	if data then
		return true,data
	else
		return false
	end
end

-- 得到自身服务器名
function cserver.getsrvname()
	return skynet.getenv("srvname")
end

-- 同区广播
function cserver.call_in_samezone(protoname,cmd,...)
	local self_srvname = cserver.getsrvname()
	local srv = data_RoGameSrvList[self_srvname]
	for srvname,data in pairs(data_RoGameSrvList) do
		if srvname ~= self_srvname and data.zonename == srv.zonename and clustermgr.isconnect(srvname) then
			rpc.call(srvname,protoname,cmd,...)
		end
	end
end

function cserver.samezone_srvnames(srvname)
	srvname = srvname or cserver.getsrvname()
	local srvnames = {}
	local srv = data_RoGameSrvList[srvname]
	for k,v in pairs(data_RoGameSrvList) do
		if v.zonename == srv.zonename then
			table.insert(srvnames,k)
		end
	end
	return srvnames
end

function cserver.pcall_in_samezone(protoname,cmd,...)
	local self_srvname = cserver.getsrvname()
	local srv = data_RoGameSrvList[self_srvname]
	local srvnames = cserver.samezone_srvnames(self_srvname)
	for i,srvname in pairs(srvnames) do
		local srv2 = data_RoGameSrvList[srvname]
		if srvname ~= self_srvname and srv2.zonename == srv.zonename and clustermgr.isconnect(srvname) then
			skynet.fork(rpc.pcall,srvname,protoname,cmd,...)
		end
	end
end

return cserver
