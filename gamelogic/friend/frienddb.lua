
cfrienddb = class("cfrienddb",cdatabaseable)

function cfrienddb:init(pid)
	self.flag = "cfrienddb"
	cdatabaseable.init(self,{
		pid = pid,
		flag = self.flag,
	})
	self.frdlist = {}
	self.frdshiplist = {} -- 好友度表
	self.applyerlist = {}
	self.recommendlist = {}
	self.applyerlimit = 20
	self.frdlimit = 60
	self.recommendlimit = 15
	self.data = {}
	self.thistemp = cthistemp.new{
		pid = pid,
		flag = self.flag,
	}
	self.timeattr = cattrcontainer.new{
		thistemp = self.thistemp,
	}
end

function cfrienddb:save()
	local data = {}
	data.frdlist = self.frdlist
	data.frdshiplist = self.frdshiplist
	data.applyerlist = self.applyerlist
	data.recommendlist = self.recommendlist
	data.data = self.data
	data.timeattr = self.timeattr:save()
	return data
end

function cfrienddb:load(data)
	if not data or not next(data) then
		return
	end
	self.frdlist = data.frdlist
	local frdshiplist = data.frdshiplist or {}
	for pid,frdship in pairs(frdshiplist) do
		pid = tonumber(pid)
		self.frdshiplist[pid] = frdship
	end
	self.applyerlist = data.applyerlist
	self.recommendlist = data.recommendlist or {}
	self.data = data.data
	self.timeattr:load(data.timeattr)
	self:onload()
end

function cfrienddb:clear()
	self.frdlist = {}
	self.frdshiplist = {}
	self.applyerlist = {}
	self.recommendlist = {}
	self.data = {}
	self.timeattr:clear()
end

function cfrienddb:oncreate(player)
	if not globalmgr.server:isopen("friend") then
		return
	end
end

function cfrienddb:onload()
	local tmplist = {}
	for pos,pid in ipairs(self.frdlist) do
		local frdblk = self:getfrdblk(pid)
		if frdblk then
			table.insert(tmplist,pid)
		else
			logger.log("error","friend",format("[delfrdlist onload] pid=%d",pid))
		end
	end
	self.frdlist = tmplist
	tmplist = {}
	for pos,pid in ipairs(self.applyerlist) do
		local frdblk = self:getfrdblk(pid)
		if frdblk then
			table.insert(tmplist,pid)
		else
			logger.log("error","friend",format("[delapplyerlist onload] pid=%d",pid))
		end
	end
	self.applyerlist = tmplist
	tmplist = {}
	for pos,pid in ipairs(self.recommendlist) do
		local frdblk = self:getfrdblk(pid)
		if frdblk then
			table.insert(tmplist,pid)
		else
			logger.log("error","friend",format("[delrecommendlist onload] pid=%d",pid))
		end
	end
	self.recommendlist = tmplist
end


function cfrienddb:onlogin(player)
	if not globalmgr.server:isopen("friend") then
		return
	end
	resumemgr.onlogin(player) -- keep before
	local frdblk = self:getfrdblk(self.pid)
	frdblk:addref(self.pid)

	-- 发送好友列表
	local frdcnt = self:query("frdcnt",0)
	local frdlist = table.slice(self.frdlist,1,frdcnt)
	net.friend.S2C.addlist(self.pid,"friend",frdlist)
	if #self.frdlist > frdcnt then
		local new_frdlist = table.slice(self.frdlist,frdcnt+1,#self.frdlist)
		net.friend.S2C.addlist(self.pid,"friend",new_frdlist,true)
	end
	for _,pid in ipairs(self.frdlist) do
		frdblk = self:getfrdblk(pid)
		frdblk:addref(self.pid)
		net.friend.S2C.sync(self.pid,self:pack_frdblk(frdblk))
	end

	-- 发送申请者列表
	local applyercnt = self:query("applyercnt",0)
	local applyerlist = table.slice(self.applyerlist,1,applyercnt)
	net.friend.S2C.addlist(self.pid,"applyer",applyerlist)
	if #self.applyerlist > applyercnt then
		local new_applyerlist = table.slice(self.applyerlist,applyercnt+1,#self.applyerlist)
		net.friend.S2C.sync(self.pid,"applyer",new_applyerlist,true)
	end
	for _,pid in ipairs(self.applyerlist) do
		frdblk = self:getfrdblk(pid)
		frdblk:addref(self.pid)
		net.friend.S2C.sync(self.pid,self:pack_frdblk(frdblk))
	end

	-- 发送推荐列表
	net.friend.S2C.addlist(self.pid,"recommend",self.recommendlist)
	for _,pid in ipairs(self.recommendlist) do
		frdblk = self:getfrdblk(pid)
		frdblk:addref(self.pid)
		net.friend.S2C.sync(self.pid,self:pack_frdblk(frdblk))
	end

	local toapplylist = self.thistemp:query("toapplylist")
	if toapplylist then
		net.friend.S2C.addlist(self.pid,"toapply",toapplylist)
	end

	--发送离线收到的私聊
	local msgs = player.privatemsg:popall()
	net.friend.S2C.addmsgs(self.pid,msgs)
end

function cfrienddb:onlogoff(player,reason)
	if not globalmgr.server:isopen("friend") then
		return
	end
	resumemgr.onlogoff(player,reason) -- keep before
	local frdblk = self:getfrdblk(self.pid)
	frdblk:delref(self.pid)
	for _,pid in ipairs(self.frdlist) do
		frdblk = self:getfrdblk(pid)
		frdblk:delref(self.pid)
	end
	for _,pid in ipairs(self.applyerlist) do
		frdblk = self:getfrdblk(pid)
		frdblk:delref(self.pid)
	end
	for _,pid in ipairs(self.recommendlist) do
		frdblk = self:getfrdblk(pid)
		frdblk:delref(self.pid)
	end
	self:set("applyercnt",#self.applyerlist)
	self:set("frdcnt",#self.frdlist)
end

function cfrienddb:getfrdblk(pid)
	if not route.getsrvname(pid) then
		return
	end
	return resumemgr.getresume(pid)
end

function cfrienddb:delfrdblk(pid)
	return resumemgr.delresume(pid)
end

function cfrienddb:pack_frdblk(frdblk)
	local data = {}
	data.resume = {
		pid = frdblk.pid,
		name = frdblk:query("name"),
		lv = frdblk:query("lv"),
		roletype = frdblk:query("roletype"),
		srvname = frdblk:query("srvname"),
		online = frdblk:query("online"),
		fightpoint = frdblk:query("fightpoint"),
	}
	if table.find(self.frdlist,frdblk.pid) then
		data.frdship = self.frdshiplist[pid] or 0
	end
	return data
end


function cfrienddb:addapplyer(pid)
	if #self.applyerlist >= self:getapplyerlimit() then
		self:delapplyer(self.applyerlist[1])
	end
	local pos = table.find(self.applyerlist,pid)
	if pos then
		return
	end
	pos = table.find(self.frdlist,pid)
	if pos then
		return
	end
	logger.log("info","friend",string.format("[addapplyer] owner=%s pid=%d",self.pid,pid))
	table.insert(self.applyerlist,pid)
	local frdblk = self:getfrdblk(pid)
	frdblk:addref(self.pid)
	net.friend.S2C.sync(self.pid,self:pack_frdblk(frdblk))
	net.friend.S2C.addlist(self.pid,"applyer",pid,true)
end

function cfrienddb:delapplyer(pid)
	logger.log("info","friend",string.format("[delapplyer] owner=%s pid=%d",self.pid,pid))
	local pos = table.find(self.applyerlist,pid)
	if not pos then
	else
		table.remove(self.applyerlist,pos)
		local frdblk = self:getfrdblk(pid)
		frdblk:delref(self.pid)
	end
	net.friend.S2C.dellist(self.pid,"applyer",pid)
end

function cfrienddb:addfriend(pid)
	local pos = table.find(self.frdlist,pid)
	if pos then
		return
	end
	logger.log("info","friend",string.format("[addfriend] owner=%s pid=%d",self.pid,pid))
	table.insert(self.frdlist,pid)
	self.frdshiplist[pid] = 0
	local frdblk = self:getfrdblk(pid)
	frdblk:addref(self.pid)
	net.friend.S2C.sync(self.pid,self:pack_frdblk(frdblk))
	net.friend.S2C.addlist(self.pid,"friend",pid,true)
end

function cfrienddb:delfriend(pid)
	local ret
	local pos = table.find(self.frdlist,pid)
	if not pos then
		ret = false
	else
		logger.log("info","friend",string.format("[delfriend] owner=%s pid=%d",self.pid,pid))
		table.remove(self.frdlist,pos)
		self.frdshiplist[pid] = nil
		local frdblk = self:getfrdblk(pid)
		frdblk:delref(self.pid)
		ret = true
	end
	net.friend.S2C.dellist(self.pid,"friend",pid)	
	return ret
end


function cfrienddb:req_delfriend(pid)
	if not self:delfriend(pid) then
		return
	end
	local srvname = route.getsrvname(pid)
	if srvname == cserver.getsrvname() then
		local target = playermgr.getplayer(pid)
		if not target then
			target = playermgr.loadofflineplayer(pid)
		end
		if target then
			target.frienddb:delfriend(self.pid)
		end
	else
		rpc.call(srvname,"playermethod",self.pid,"frienddb:delfriend",pid)
	end
end

function cfrienddb:apply_addfriend(pid)
	local toapplylist,exceedtime = self.thistemp:query("toapplylist",{})
	local pos = table.find(toapplylist,pid)
	if pos then
		net.msg.S2C.notify(self.pid,"您的申请已经发出")
		return
	end
	logger.log("info","friend",string.format("[apply_addfriend] owner=%s pid=%d",self.pid,pid))
	table.insert(toapplylist,pid)
	self.thistemp:set("toapplylist",toapplylist,300)
	net.friend.S2C.addlist(self.pid,"toapply",pid,true)
	local srvname = route.getsrvname(pid)
	if srvname == cserver.getsrvname() then
		local target = playermgr.getplayer(pid)
		if not target then
			target = playermgr.loadofflineplayer(pid)
		end
		if target then
			target.frienddb:addapplyer(self.pid)
		end
	else
		rpc.call(srvname,"playermethod",pid,"frienddb:addapplyer",self.pid)
	end
end

function cfrienddb:agree_addfriend(pid)
	local pos = table.find(self.frdlist,pid)
	if pos then
		net.msg.S2C.notify(self.pid,"该玩家已经是你好友了")
		return
	end
	if #self.frdlist >= self:getfriendlimit() then
		net.msg.S2C.notify(self.pid,"好友个数已达上限")
		return
	end
	pos = table.find(self.applyerlist,pid)
	if not pos then
		net.msg.S2C.notify(self.pid,"该玩家未向你发起过申请")
		return
	end
	logger.log("info","friend",string.format("[agree_addfriend] owner=%s pid=%d",self.pid,pid))
	self:delapplyer(pid)
	self:addfriend(pid)
	local srvname = route.getsrvname(pid)
	if not srvname then
		net.msg.S2C.notify(self.pid,"该玩家不存在")
		return
	end
	if srvname == cserver.getsrvname() then
		local target = playermgr.getplayer(pid)
		if not target then
			target = playermgr.loadofflineplayer(pid)
		end
		if target then
			target.frienddb:addfriend(self.pid)
		end
	else
		rpc.call(srvname,"playermethod",pid,"frienddb:addfriend",self.pid)
	end

end

function cfrienddb:reject_addfriend(pid)
	logger.log("info","friend",string.format("[reject_addfriend] owner=%s pid=%d",self.pid,pid))
	self:delapplyer(pid)
end

function cfrienddb:sendmsg(pid,msg)
	if not table.find(self.frdlist,pid) then
		net.msg.S2C.notify(self.pid,"不能与陌生人发送聊天信息")
		return
	end
	local frdblk = self:getfrdblk(pid)
	if not frdblk then
		return
	end
	logger.log("debug","friend",string.format("[sendmsg] owner=%s pid=%d msg=%s",self.pid,pid,msg))
	local packmsg = { msg = msg, sender = self.pid, sendtime = os.time(), }
	if frdblk:query("online") then
		local srvname = route.getsrvname(pid)
		if srvname == cserver.getsrvname() then
			net.friend.S2C.addmsgs(pid,packmsg)
		else
			rpc.call(srvname,"modmethod","net.friend",".addmsgs",pid,packmsg)
		end
	else
		local srvname = route.getsrvname(pid)
		if srvname == cserver.getsrvname() then
			target = playermgr.loadofflineplayer(pid)
			target.privatemsg:push(packmsg)
		else
			rpc.call(srvname,"playermethod",pid,"privatemsg:push",packmsg)
		end
	end
end

function cfrienddb:syncfrdblk(pid,frddata)
	local data = {}
	data.resume = {
		srvname = frddata.srvname,
		pid = pid,
		name = frddata.name,
		roletype = frddata.roletype,
		lv = frddata.lv,
		online = frddata.online,
		fightpoint = frddata.fightpoint,
	}
	data.frdship = frddata.frdship
	if table.isempty(data) then
		return
	end
	net.friend.S2C.sync(self.pid,data)
end

function cfrienddb:search_bypid(pid)
	local frdblk = self:getfrdblk(pid)
	if not frdblk then
		net.msg.S2C.notify(pid,language.format("找不到该玩家"))
		return
	end
	local tbl = {}
	table.insert(tbl,self:pack_frdblk(frdblk))
	net.friend.S2C.search_result(self.pid,tbl)
end

function cfrienddb:search_byname(name)
	local db = dbmgr.getdb(cserver.datacenter())
	local srvname = cserver.getsrvname()
	local zonename = data_RoGameSrvList[srvname].zonename
	local pid = db:hget(db:key("allname",zonename),name)
	if not pid then
		net.msg.S2C.notify(pid,language.format("找不到该玩家"))
	end
	self:search_bypid(pid)
end

function cfrienddb:change_recommend()
	local oldrecommend = self.recommendlist
	self.recommendlist = {}
	for _,pid in ipairs(oldrecommend) do
		local frdblk = self:getfrdblk(pid)
		frdblk:delref(self.pid)
	end
	net.friend.S2C.dellist(self.pid,"recommend",oldrecommend)
	local ignorelist = self:update_oldrecommend(oldrecommend)
	-- TODO 根据规则生成推荐列表
	local plist = {}
	for _,pid in ipairs(playermgr.allobject()) do
		if not table.find(self.frdlist,pid) and not table.find(ignorelist,pid) then
			table.insert(plist,pid)
		end
	end
	self.recommendlist = shuffle(plist,nil,self.recommendlimit)
	net.friend.S2C.addlist(self.pid,"recommend",self.recommendlist)
	for _,pid in ipairs(self.recommendlist) do
		local frdblk = self:getfrdblk(pid)
		frdblk:addref(self.pid)
		net.friend.S2C.sync(self.pid,self:pack_frdblk(frdblk))
	end
end

function cfrienddb:update_oldrecommend(oldrecommend)
	local now = os.time()
	local dayno = getdayno(now)
	local exceedtime = getdayzerotime(now) + 3600 * 72 - now
	local recommendlist = self.thistemp:query(format("recommend.%d",dayno),{})
	table.extend(recommendlist,oldrecommend)
	self.thistemp:set(format("recommend.%d",dayno),recommendlist,exceedtime)
	local ignorelist = {}
	table.extend(ignorelist,recommendlist)
	table.extend(ignorelist,self.thistemp:query(format("recommend.%d",dayno-1),{}))
	table.extend(ignorelist,self.thistemp:query(format("recommend.%d",dayno-2),{}))
	return ignorelist
end

-- getter
function cfrienddb:getfriendlimit()
	return self.frdlimit + self:query("extfrdlimit",0)
end

function cfrienddb:getapplyerlimit()
	return self.applyerlimit
end

return cfrienddb
