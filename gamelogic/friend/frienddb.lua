
cfrienddb = class("cfrienddb",cdatabaseable,{
	applyerlimit = 20,
	frdlimit = 200,
	recommendlimit = 15,
	blacklimit = 200,
})

function cfrienddb:init(pid)
	self.flag = "cfrienddb"
	cdatabaseable.init(self,{
		pid = pid,
		flag = self.flag,
	})
	self.frdlist = {}
	self.frddata = {} -- 好友关系数据
	self.applyerlist = {}
	self.recommendlist = {}
	self.blacklist = {} --黑名单
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
	data.frddata = self.frddata
	data.applyerlist = self.applyerlist
	data.recommendlist = self.recommendlist
	data.blacklist = self.blacklist
	data.data = self.data
	data.timeattr = self.timeattr:save()
	return data
end

function cfrienddb:load(data)
	if not data or not next(data) then
		return
	end
	self.frdlist = data.frdlist
	local frddata = data.frddata or {}
	for pid,value in pairs(frddata) do
		pid = tonumber(pid)
		self.frddata[pid] = value
	end
	self.applyerlist = data.applyerlist
	self.recommendlist = data.recommendlist or {}
	self.blacklist = data.blacklist or {}
	self.data = data.data
	self.timeattr:load(data.timeattr)
	self:onload()
end

function cfrienddb:clear()
	self.frdlist = {}
	self.frddata = {}
	self.applyerlist = {}
	self.recommendlist = {}
	self.blacklist = {}
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
	tmplist = {}
	for pos,pid in ipairs(self.blacklist) do
		local frdblk = self:getfrdblk(pid)
		if frdblk then
			table.insert(tmplist,pid)
		else
			logger.log("error","friend",format("[delblacklist onload] pid=%d",pid))
		end
	end
	self.blacklist = tmplist
end

function cfrienddb:onlogin(player)
	if not globalmgr.server:isopen("friend") then
		return
	end
	local frdblk = self:getfrdblk(self.pid)
	self:addblkref(self.pid)

	-- 发送好友列表，客户端需要先拿到数据，才收列表
	if not table.isempty(self.frdlist) then
		for _,pid in ipairs(self.frdlist) do
			self:addblkref(pid)
			net.friend.S2C.sync_frddata(self.pid,self:pack_frddata(pid,self.frddata[pid]))
		end
		local frdcnt = self:query("frdcnt",0)
		local frdlist = table.slice(self.frdlist,1,frdcnt)
		net.friend.S2C.addlist(self.pid,"friend",frdlist)
		if #self.frdlist > frdcnt then
			local new_frdlist = table.slice(self.frdlist,frdcnt+1,#self.frdlist)
			net.friend.S2C.addlist(self.pid,"friend",new_frdlist,true)
		end
	end

	-- 发送申请者列表
	if not table.isempty(self.applyerlist) then
		for _,pid in ipairs(self.applyerlist) do
			self:addblkref(pid)
		end
		local applyercnt = self:query("applyercnt",0)
		local applyerlist = table.slice(self.applyerlist,1,applyercnt)
		net.friend.S2C.addlist(self.pid,"applyer",applyerlist)
		if #self.applyerlist > applyercnt then
			local new_applyerlist = table.slice(self.applyerlist,applyercnt+1,#self.applyerlist)
			net.friend.S2C.addlist(self.pid,"applyer",new_applyerlist,true)
		end
	end

	-- 发送推荐列表
	if table.isempty(self.recommendlist) then
		self:change_recommend()
	else
		for _,pid in ipairs(self.recommendlist) do
			self:addblkref(pid)
		end
		net.friend.S2C.addlist(self.pid,"recommend",self.recommendlist)
	end

	-- 发送黑名单列表
	if not table.isempty(self.blacklist) then
		for _,pid in ipairs(self.blacklist) do
			self:addblkref(pid)
		end
		net.friend.S2C.addlist(self.pid,"black",self.blacklist)
	end

	local toapplylist = self.thistemp:query("toapplylist")
	if toapplylist then
		net.friend.S2C.addlist(self.pid,"toapply",toapplylist)
	end

	--发送离线收到的私聊
	local msgs = player.privatemsg:popall()
	if not table.isempty(msgs) then
		net.friend.S2C.addmsgs(self.pid,msgs)
	end
end

function cfrienddb:onlogoff(player,reason)
	if not globalmgr.server:isopen("friend") then
		return
	end
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
	local blk = resumemgr.getresume(pid)
	if not blk or blk.loadstate == "loadnull" then
		return
	end
	return blk
end

function cfrienddb:addblkref(pid)
	local frdblk = self:getfrdblk(pid)
	if not frdblk then
		return
	end
	frdblk:addref(self.pid)
	sendpackage(self.pid,"player","syncresumes",{
		resumes = {frdblk:pack()},
	})
end

function cfrienddb:pack_frddata(pid,data)
	local packdata = {}
	packdata.frdship = data.frdship
	packdata.addfrdtime = data.addfrdtime
	if table.isempty(packdata) then
		return
	end
	packdata.pid = pid
	return packdata
end

function cfrienddb:update_frddata(pid,attr,value)
	if not self.frddata[pid] or not self.frddata[pid][attr] then
		return
	end
	self.frddata[pid][attr] = value
	local change = self:pack_frddata({ attr = value, })
	if change then
		net.friend.S2C.sync_frddata(self.pid,change)
	end
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
	pos = table.find(self.blacklist,pid)
	if pos then
		return
	end
	logger.log("info","friend",string.format("[addapplyer] owner=%s pid=%d",self.pid,pid))
	table.insert(self.applyerlist,pid)
	self:addblkref(pid)
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
	self.frddata[pid] = self:newfrddata()
	self:addblkref(pid)
	net.friend.S2C.sync_frddata(self.pid,self:pack_frddata(pid,self.frddata[pid]))
	net.friend.S2C.addlist(self.pid,"friend",pid,true)
end

function cfrienddb:newfrddata()
	return {
		frdship = 0,
		addfrdtime = os.time(),
	}
end

function cfrienddb:delfriend(pid)
	local ret
	local pos = table.find(self.frdlist,pid)
	if not pos then
		ret = false
	else
		logger.log("info","friend",string.format("[delfriend] owner=%s pid=%d",self.pid,pid))
		table.remove(self.frdlist,pos)
		self.frddata[pid] = nil
		local frdblk = self:getfrdblk(pid)
		frdblk:delref(self.pid)
		ret = true
	end
	net.friend.S2C.dellist(self.pid,"friend",pid)
	return ret
end


function cfrienddb:req_delfriend(pid)
	local ret = rpc.callplayer(pid,"playermethod",pid,"frienddb:delfriend",self.pid)
	if ret then
		self:delfriend(pid)
	end
end

function cfrienddb:apply_addfriend(pid)
	local toapplylist,exceedtime = self.thistemp:query("toapplylist",{})
	local pos = table.find(toapplylist,pid)
	if pid == self.pid then
		return false,language.format("不能加自己为好友")
	end
	if pos then
		return false,language.format("您的申请已经发出")
	end
	if table.find(self.blacklist,pid) then
		return false,language.format("对方在你的黑名单中，无法申请")
	end
	logger.log("info","friend",string.format("[apply_addfriend] owner=%s pid=%d",self.pid,pid))
	self:delrecommend(pid)
	table.insert(toapplylist,pid)
	self.thistemp:set("toapplylist",toapplylist,10)
	net.friend.S2C.addlist(self.pid,"toapply",pid,true)
	rpc.callplayer(pid,"playermethod",pid,"frienddb:addapplyer",self.pid)
	return true,language.format("申请成功")
end

function cfrienddb:agree_addfriend(pid)
	local pos = table.find(self.frdlist,pid)
	if pos then
		return false,language.format("该玩家已经是你好友了")
	end
	pos = table.find(self.applyerlist,pid)
	if not pos then
		return false,language.format("该玩家未向你发起过申请")
	end
	local srvname = globalmgr.home_srvname(pid)
	if not srvname then
		return false,language.format("该玩家不存在")
	end
	local isok,msg = self:can_addfriend(pid)
	if not isok then
		return false,msg
	end
	self.lock_addfriend = os.time() + 1
	isok = false
	isok = rpc.callplayer(pid,"playermethod",pid,"frienddb:tryaddfriend",self.pid)
	self.lock_addfriend = nil
	if not isok then
		return false
	end
	logger.log("info","friend",string.format("[agree_addfriend] owner=%s pid=%d",self.pid,pid))
	self:delapplyer(pid)
	self:delrecommend(pid)
	self:addfriend(pid)
	return true,language.format("添加成功")
end

function cfrienddb:tryaddfriend(pid)
	if not self:can_addfriend(pid) then
		return false
	end
	self:delapplyer(pid)
	self:delrecommend(pid)
	self:addfriend(pid)
	return true
end

function cfrienddb:can_addfriend(pid)
	if pid == self.pid then
		return false,language.format("不能加自己为好友")
	end
	if self.lock_addfriend and self.lock_addfriend > os.time() then
		return false
	end
	if #self.frdlist >= self:getfriendlimit() then
		return false,language.format("好友个数已达上限")
	end
	if table.find(self.blacklist,pid) then
		return false,language.format("对方在你的黑名单中，无法添加")
	end
	return true
end

function cfrienddb:reject_addfriend(pid)
	logger.log("info","friend",string.format("[reject_addfriend] owner=%s pid=%d",self.pid,pid))
	self:delapplyer(pid)
end

function cfrienddb:sendmsg(pid,msg)
	if not table.find(self.frdlist,pid) then
		return false,language.format("不能与陌生人发送聊天信息")
	end
	if table.find(self.blacklist,pid) then
		return false
	end
	local frdblk = self:getfrdblk(pid)
	if not frdblk then
		return false
	end
	local isok,errmsg = net.msg.filter(msg)
	if not isok then
		return false,errmsg
	else
		msg = errmsg
	end
	logger.log("debug","friend",string.format("[sendmsg] owner=%s pid=%d msg=%s",self.pid,pid,msg))
	local packmsg = { msg = msg, sender = self.pid, sendtime = os.time(), receiver = pid, }
	if frdblk:query("online") then
		rpc.callplayer(pid,"rpc","net.friend.S2C.addmsgs",pid,packmsg)
	else
		rpc.callplayer(pid,"playermethod",pid,"privatemsg:push",packmsg)
	end
	return true,packmsg
end

function cfrienddb:change_recommend()
	local oldrecommend = self.recommendlist
	local plist = {}
	for _,pid in ipairs(playermgr.allplayer()) do
		if self:can_recommend(pid) then
			plist[pid] = 1
		end
	end
	if table.isempty(plist) then
		return false
	end
	self.recommendlist = {}
	for _,pid in ipairs(oldrecommend) do
		local frdblk = self:getfrdblk(pid)
		frdblk:delref(self.pid)
	end
	net.friend.S2C.dellist(self.pid,"recommend",oldrecommend)
	local lv_plist = {}
	local fightpoint_plist = {}
	local owner = playermgr.getplayer(self.pid)
	local minlv,maxlv = math.max(1,owner.lv - RECOMMEND_LV_RANGE),math.min(playeraux.getmaxlv(),owner.lv + RECOMMEND_LV_RANGE)
	local tmp = math.floor(owner.fightpoint * 25 / 100)
	local minfightpoint,maxfightpoint = math.max(0,owner.fightpoint - tmp),owner.fightpoint + tmp
	for pid,_ in pairs(plist) do
		local player = playermgr.getplayer(pid)
		if minlv <= player.lv and player.lv <= maxlv then
			lv_plist[pid] = 1
		end
		if minfightpoint <= player.fightpoint and player.fightpoint <= maxfightpoint then
			fightpoint_plist[pid] = 1
		end
	end
	local tmplist
	for _,typ in ipairs(RECOMMEND_RULES) do
		if typ == 1 then
			tmplist = lv_plist
		elseif typ == 2 then
			tmplist = fightpoint_plist
		else
			tmplist = plist
		end
		if table.isempty(tmplist) then
			tmplist = plist
		end
		local pid = choosekey(tmplist)
		plist[pid] = nil
		lv_plist[pid] = nil
		fightpoint_plist[pid] = nil
		table.insert(self.recommendlist,pid)
		if table.isempty(plist) then
			break
		end
	end
	logger.log("info","friend",format("[changerecommend] owner=%s oldplist=%s newplist=%s",self.pid,oldrecommend,self.recommendlist))
	for _,pid in ipairs(self.recommendlist) do
		self:addblkref(pid)
	end
	net.friend.S2C.addlist(self.pid,"recommend",self.recommendlist)
	return true
end

function cfrienddb:can_recommend(pid)
	if pid == self.pid then
		return false
	end
	if table.find(self.frdlist,pid) then
		return false
	end
	if table.find(self.blacklist,pid) then
		return false
	end
	local player = playermgr.getplayer(pid)
	assert(player)
	if #player.frienddb.frdlist >= player.frienddb:getfriendlimit() then
		return false
	end
	if table.find(player.frienddb.blacklist,self.pid) then
		return false
	end
	return true
end

function cfrienddb:delrecommend(pid)
	local pos = table.find(self.recommendlist,pid)
	if pos then
		logger.log("info","friend",format("[delrecommend] owner=%s pid=%d",self.pid,pid))
		table.remove(self.recommendlist,pos)
		local frdblk = self:getfrdblk(pid)
		frdblk:delref(self.pid)
		net.friend.S2C.dellist(self.pid,"recommend",pid)
	end
end

--添加到黑名单
function cfrienddb:addblack(pid)
	if table.find(self.blacklist,pid) then
		return
	end
	local frdblk = self:getfrdblk(pid)
	if not frdblk then
		return
	end
	logger.log("info","friend",format("[addblack] owner=%d pid=%d",self.pid,pid))
	if table.find(self.frdlist,pid) then
		self:req_delfriend(pid)
	end
	if table.find(self.applyerlist,pid) then
		self:delapplyer(pid)
	end
	if table.find(self.recommendlist,pid) then
		self:delrecommend(pid)
	end
	table.insert(self.blacklist,pid)
	self:addblkref(pid)
	net.friend.S2C.addlist(self.pid,"black",pid,true)
end

function cfrienddb:delblack(pid)
	local pos = table.find(self.blacklist,pid)
	if not pos then
		return
	end
	logger.log("info","friend",format("[delblack] owner=%d pid=%d",self.pid,pid))
	table.remove(self.blacklist,pos)
	local frdblk = self:getfrdblk(pid)
	frdblk:delref(self.pid)
	net.friend.S2C.dellist(self.pid,"black",pid)
end

function cfrienddb:getfriendlimit()
	return self.frdlimit + self:query("extfrdlimit",0)
end

function cfrienddb:getapplyerlimit()
	return self.applyerlimit
end

return cfrienddb
