cplayer = class("cplayer",cdatabaseable)

function cplayer:init(pid)
	self.flag = "cplayer"
	cdatabaseable.init(self,{
		pid = pid,
		flag = self.flag,
	})
	self.pid = pid

	self.data = {}
	self.frienddb = cfrienddb.new(self.pid)
	self.achievedb = cachievedb.new(self.pid)
	self.today = ctoday.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.today:register(function(data)
		local player = playermgr.getplayer(pid)
		player:oncleartoday(data)
	end)
	self.thistemp = cthistemp.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.thisweek = cthisweek.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.thisweek2 = cthisweek2.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.timeattr = cattrcontainer.new{
		today = self.today,
		thistemp = self.thistemp,
		thisweek = self.thisweek,
		thisweek2 = self.thisweek2,
	}
	self.taskdb = ctaskdb.new(self.pid)
	-- 一般物品背包
	self.itemdb = citemdb.new({
		pid = self.pid,
		name = "itemdb",
		type = BAGTYPE.NORMAL,
		initspace = 18,
		beginpos = ITEMPOS_BEGIN,
	})
	-- 时装背包
	self.fashionshowdb = citemdb.new({
		pid = self.pid,
		name = "fashinoshowdb",
		type = BAGTYPE.FASHION_SHOW,
	})
	-- 怪物卡片
	self.carddb = ccarddb.new({
		pid = self.pid,
		name = "carddb",
		type = BAGTYPE.CARD,
	})
	self.delaytonextlogin = cdelaytonextlogin.new(self.pid)
	self.switch = cswitch.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.suitequip = csuitequip.new(self.pid)
	self.privatemsg = cprivatemsg.new(self.pid)

	self.titledb = ctitledb.new({
		pid = self.pid,
		name = "titledb",
	})

	-- 签到容器
	self.signindb = csignindb.new(self.pid)
	-- 关卡容器
	self.chapterdb = cchapterdb.new({
		pid = self.pid,
		name = "chapterdb",
	})
	self.warskilldb = cwarskilldb.new({
		pid = self.pid,
		name = "warskill",
	})

	self.shopdb = cshopdb.new(self.pid)
	self.equipposdb = cequipposdb.new({
		pid = self.pid,
		name = "equipposdb"
	})

	self.petdb = cpetdb.new(self.pid)

	self.autosaveobj = {
		time = self.timeattr,
		friend = self.frienddb,
		achieve = self.achievedb,
		task = self.taskdb,
		item = self.itemdb,
		fashionshow = self.fashionshowdb,
		card = self.carddb,
		delaytonextlogin = self.delaytonextlogin,
		switch = self.switch,
		suitequip = self.suitequip,
		privatemsg = self.privatemsg,
		signin = self.signindb,
		chapter = self.chapterdb,
		warskill = self.warskilldb,
		shop = self.shopdb,
		equippos = self.equipposdb,
		pet = self.petdb,
	}

	self.delaypackage = cdelaypackage.new(self.pid)
	self.loadstate = "unload"
end

function cplayer:save()
	local data = {}
	data.data = self.data
	data.basic = {
		gold = self.gold,
		silver = self.silver,
		coin = self.coin,
		viplv = self.viplv,
		account = self.account,
		channel = self.channel,
		name = self.name,
		lv = self.lv,
		exp = self.exp,
		roletype = self.roletype,
		sex = self.sex,
		jobzs = self.jobzs,
		joblv = self.joblv,
		jobexp = self.jobexp,

		sceneid = self.sceneid,
		pos = self.pos,
		objid = self.objid,
	}
	return data
end


function cplayer:load(data)
	if not data or not next(data) then
		logger.log("error","error",string.format("[cplayer:load null] pid=%d",self.pid))
		return
	end
	self.data = data.data
	if data.basic then
		self.gold = data.basic.gold or 0
		self.silver = data.basic.silver or 0
		self.coin = data.basic.coin or 0
		self.viplv = data.basic.viplv or 0
		self.account = data.basic.account
		self.channel = data.basic.channel
		self.name = data.basic.name
		self.lv = data.basic.lv or 0
		self.exp = data.basic.exp or 0
		self.roletype = data.basic.roletype
		self.sex = data.basic.sex or 1
		self.jobzs = data.basic.jobzs or 0
		self.joblv = data.basic.joblv or 0
		self.jobexp = data.basic.jobexp or 0

		self.sceneid = data.basic.sceneid
		self.pos = data.basic.pos
		self.objid = data.basic.objid
	end
	self:onload()
end

function cplayer:onload()
	self.fightpoint = 0
end

function cplayer:packresume()
	local resume = {
		gold = self.gold,
		silver = self.silver,
		coin = self.coin,
		viplv = self.viplv,
		account = self.account,
		name = self.name,
		lv = self.lv,
		roletype = self.roletype,
		jobzs = self.jobzs,
		joblv = self.joblv,
		fightpoint = self.fightpoint or 0,--战力待补充
		teamstate = self:teamstate(),
		teamid = self:teamid() or 0,
		unionid = self:unionid() or 0,
		lang = self:getlanguage(),
	}
	return resume
end


function cplayer:savetodatabase()
	assert(self.pid)
	-- 离线对象已超过过期时间则删除
	if self.__state == "offline" and (not self.__activetime or os.time() - self.__activetime > 300) then
		playermgr.unloadofflineplayer(self.pid)
	end
	if self.nosavetodatabase then
		return
	end

	local srvname = globalmgr.home_srvname(self.pid)
	local db = dbmgr.getdb(srvname)
	if self.loadstate == "loaded" then
		local data = self:save()
		db:set(db:key("role",self.pid,"data"),data)
	end
	for k,v in pairs(self.autosaveobj) do
		if v.loadstate == "loaded" then
			db:set(db:key("role",self.pid,k),v:save())
		end
	end

	-- 临时处理方法，agent发现内存占用过高，暂时每次存盘让玩家对应的agent服gc
	if self.__agent then
		skynet.error(self.__agent,"gc")
		skynet.send(self.__agent,"lua","gc")
	end
end

function cplayer:loadfromdatabase(loadall)
	if loadall == nil then
		loadall = true
	end
	assert(self.pid)
	if not self.loadstate or self.loadstate == "unload" then
		self.loadstate = "loading"
		local db = dbmgr.getdb(self.pid)
		local data = db:get(db:key("role",self.pid,"data"))
		-- pprintf("role:data=>%s",data)
		-- 正常角色至少会有基本数据
		if not data or not next(data) then
			self.loadstate = "loadnull"
		else
			self:load(data)
			self.loadstate = "loaded"
		end
	end
	if loadall then
		for k,v in pairs(self.autosaveobj) do
			if not v.loadstate or v.loadstate == "unload" then
				v.loadstate = "loading"
				local db = dbmgr.getdb(self.pid)
				local data = db:get(db:key("role",self.pid,k))
				v:load(data)
				v.loadstate = "loaded"
			end
		end
	end
end

function cplayer:isloaded()
	if self.loadstate == "loaded" then
		for k,v in pairs(self.autosaveobj) do
			if v.loadstate ~= "loaded" then
				return false
			end
		end
		return true
	end
	return false
end

function cplayer:create(conf)
	local name = assert(conf.name)
	local roletype =assert(conf.roletype)
	local account = assert(conf.account)
	local sex = assert(conf.sex)
	logger.log("info","createrole",string.format("[createrole] account=%s pid=%s name=%s roletype=%s ip=%s:%s",account,self.pid,name,roletype,conf.__ip,conf.__port))

	self.loadstate = "loaded"

	self.account = account
	--self.name = name
	self:setname(name)
	self.roletype = roletype		-- 角色类型(职业类型)
	self.sex = sex					-- 性别(1--男,2--女)
	self.gold = conf.gold or 0
	self.silver = conf.silver or 0
	self.coin = conf.coin or 0
	self.lv = conf.lv or 1
	self.exp = conf.exp or 0
	self.jobzs = conf.jobzs or 0
	self.joblv = conf.joblv or 1
	self.jobexp = conf.jobexp or 0
	self.viplv = conf.viplv or 0
	self.objid = 1000		-- [1,1000)为预留ID
	self.fightpoint = 0
	-- 素质点
	self:set("qualitypoint",{
		sum = 48,
		expand = 0,
		liliang = 1,
		minjie = 1,
		tili = 1,
		lingqiao = 1,
		zhili = 1,
		xingyun = 1,
	})

	-- scene
	self.sceneid = BORN_SCENEID
	self.pos = randlist(ALL_BORN_LOCS)
	self.scene_strategy = STRATEGY_SEE_ALL
	self.createtime = getsecond()
	local db = dbmgr.getdb()
    db:hset(db:key("role","list"),self.pid,1)
    --route.addroute(self.pid)
	self:oncreate(conf)
	local resume = self:packresume()
	resume.now_srvname = cserver.getsrvname()
	resume.home_srvname = cserver.getsrvname()
	resume.online = true
	resumemgr.create(self.pid,resume)
end

function cplayer:entergame()
	-- 确保登录第一个执行
	playermgr.delkuafuplayer(self.pid)
	self.delaytonextlogin:entergame()
	self:onlogin()
	--xpcall(self.onlogin,onerror,self)
end


-- 正常退出游戏
function cplayer:exitgame(reason)
	if not self:can_exitgame() then
		self:delay_exitgame()
		return
	end
	xpcall(self.onlogoff,onerror,self,reason)
	self:del_delay_exitgame()
	-- playermgr.delobject 会触发存盘
	playermgr.delobject(self.pid,reason)
	if self.home_srvname then
		rpc.pcall(self.home_srvname,"rpc","playermgr.delkuafuplayer",self.pid)
	end
end


-- 客户端主动掉线处理
function cplayer:disconnect(reason)
	-- 已经在托管/战斗延迟下线的玩家，不做disconnect日志了，上次下线已经做过一次!
	if not self.delay_exitgame_timerid then
		self:ondisconnect(reason)
	end
	self:exitgame(reason)
end

function cplayer:isdisconnect()
	if self.__state == "online" then
		-- 托管/处于战斗/观战中掉线的对象
		if self.delay_exitgame_timerid then
			return true
		end
		return false
	else
		return true
	end
end

-- 跨服前处理流程
function cplayer:ongosrv(srvname)
	self:onkuafu(srvname)
end

-- 回到原服前处理流程
function cplayer:ongohome(srvname)
	self:onkuafu(srvname)
end

function cplayer:onkuafu(srvname)
	teammgr:quitteam(self)
	warmgr.quitwar(self.pid)
	warmgr.quit_watchwar(self.pid)
end

-- 是否可以离线托管
function cplayer:can_tuoguan()
	if globalmgr.server.closetuoguan then
		return false
	end
	if self.closetuoguan then
		return false
	end
	if self.bforce_exitgame then
		return false
	end
	return true,60 -- test
	--return true,1200
end


function cplayer:synctoac()
	local role = {
		roleid = self.pid,
		name = self.name,
		gold = self.gold,
		lv = self.lv,
		roletype = self.roletype,
		jobzs = self.jobzs,
		joblv = self.joblv,
		sex = self.sex,
	}
	local url = string.format("/sync")
	local request = make_request({
		gameflag = cserver.gameflag(),
		srvname = cserver.getsrvname(),
		acct = self.account,
		roleid = self.pid,
		role = cjson.encode(role),
	})
	httpc.postx(cserver.accountcenter(),url,request)
end


local function heartbeat(pid)
	local player = playermgr.getplayer(pid)
	if player then
		local interval = 120
		timer.timeout("player.heartbeat",interval,functor(heartbeat,pid))
		--sendpackage(pid,"player","heartbeat",{})
	end
end

function cplayer:oncreate(conf)
	logger.log("info","createrole",string.format("[createrole end] account=%s pid=%d name=%s roletype=%d sex=%s lv=%s gold=%d ip=%s:%s",self.account,self.pid,self.name,self.roletype,self.sex,self.lv,self.gold,conf.__ip,conf.__port))
	for k,obj in pairs(self.autosaveobj) do
		obj.loadstate = "loaded"
		if obj.oncreate then
			obj:oncreate(self)
		end
	end
end

function cplayer:comptible_process()
	-- 部分旧号无等级字段（先兼容下，后续删除这里代码）
	if not self.lv then
		self.lv = 1
	end
	if not self.thisweek:query("dexppoint") then
		self.thisweek:set("dexppoint",data_GlobalVar.ResetDexpPoint)
	end
	if not self.scene_strategy then
		self.scene_strategy = STRATEGY_SEE_ALL
	end
	local scene = scenemgr.getscene(self.sceneid)
	if not scene or not self:canenterscene(self.sceneid,self.pos) then
		if scene then
			self:leavescene(self.sceneid)
		end
		local born_sceneid = BORN_SCENEID
		local born_pos = randlist(ALL_BORN_LOCS)
		self:setpos(born_sceneid,born_pos)
	end
	-- 防止地图大小变后，玩家所在位置超出地图界限
	local scene = scenemgr.getscene(self.sceneid)
	if not scene:isvalidpos(self.pos) then
		self:setpos(self.sceneid,scene:fixpos(self.pos))
	end
end

function cplayer:onlogin()
	logger.log("info","login",string.format("[login] account=%s pid=%s name=%s roletype=%s sex=%s lv=%s gold=%s channel=%s ip=%s:%s agent=%s",self.account,self.pid,self.name,self.roletype,self.sex,self.lv,self.gold,self.channel,self:ip(),self:port(),self.__agent))
	self:comptible_process()
	--  玩家基本/简介信息
	sendpackage(self.pid,"player","sync",{
		roletype = self.roletype,
		sex = self.sex,
		name = self.name,
		lv = self.lv,
		exp = self.exp,
		jobzs = self.jobzs,
		joblv = self.joblv,
		jobexp = self.jobexp,
		viplv = self.viplv,
		qualitypoint = self:query("qualitypoint"),
		huoli = self:query("huoli") or 0,
		storehp = self:query("storehp") or 0,
		usehorncnt = self.today:query("usehorncnt") or 0,
	})
	if not self.thistemp:query("onfivehourupdate") then
		self:onfivehourupdate()
	end
	--route.onlogin(self)
	resumemgr.onlogin(self)
	local server = globalmgr.server
	heartbeat(self.pid)
	self:add("logincnt",1)
	sendpackage(self.pid,"player","resource",{
		gold = self.gold,
		silver = self.silver,
		coin = self.coin,
		dexppoint = self.thisweek:query("dexppoint") or 0,
	})
	self:sync_chongzhilist()
	self.switch:onlogin(self)
	-- 放到teammgr:onlogin之前
	self:enterscene(self.sceneid,self.pos,true)
	mailmgr.onlogin(self)
	huodongmgr.onlogin(self)
	for k,obj in pairs(self.autosaveobj) do
		if obj.onlogin then
			obj:onlogin(self)
		end
	end
	navigation.onlogin(self)
	teammgr:onlogin(self)
	warmgr.onlogin(self)
	gm.onlogin(self)

	-- 跨服上线后回调的逻辑
	if self.kuafu_onlogin then
		local kuafu_onlogin = self.kuafu_onlogin
		self.kuafu_onlogin = nil
		local func = unpack_function(kuafu_onlogin)
		skynet.fork(xpcall,func,onerror)
	end
	channel.subscribe("world",self.pid)
	unionaux.onlogin(self)		-- 保证放到resumemgr.onlogin之后
	self:synctoac()
end

-- reason: replace/disconnect/delay_exitgame
function cplayer:onlogoff(reason)
	logger.log("info","login",string.format("[logoff] account=%s pid=%s name=%s roletype=%s sex=%s lv=%s gold=%s channel=%s ip=%s:%s agent=%s reason=%s",self.account,self.pid,self.name,self.roletype,self.sex,self.lv,self.gold,self.channel,self:ip(),self:port(),self.__agent,reason))
	if reason ~= "replace" then
		self:set("logofftime",os.time())
	end
	resumemgr.onlogoff(self,reason)
	mailmgr.onlogoff(self,reason)
	huodongmgr.onlogoff(self,reason)
	for k,obj in pairs(self.autosaveobj) do
		if obj.onlogoff then
			obj:onlogoff(self,reason)
		end
	end
	warmgr.onlogoff(self,reason)
	teammgr:onlogoff(self,reason)
	-- 放到teammgr:onlogoff之后
	self:leavescene(self.sceneid)
	channel.unsubscribe("world",self.pid)
	-- 保持在最后
	self:synctoac()
end

function cplayer:ondisconnect(reason)

	logger.log("info","login",string.format("[disconnect] account=%s pid=%s name=%s roletype=%s sex=%s lv=%s gold=%s channel=%s ip=%s:%s agent=%s reason=%s",self.account,self.pid,self.name,self.roletype,self.sex,self.lv,self.gold,self.channel,self:ip(),self:port(),self.__agent,reason))


end

function cplayer:ondayupdate()
end

function cplayer:onmondayupdate()
end

function cplayer:onmondayupdate_infivehour()
	self.thisweek:set("dexppoint",data_GlobalVar.ResetDexpPoint)
	sendpackage(self.pid,"player","resource",{
		dexppoint = self.thisweek:query("dexppoint") or 0,
	})
end


function cplayer:validpay(typ,num,notify)
	local hasnum
	if typ == RESTYPE.GOLD or string.lower(typ) == "gold" then
		hasnum = self.gold
	elseif typ == RESTYPE.SILVER or string.lower(typ) == "silver" then
		hasnum = self.silver
	elseif typ == RESTYPE.COIN or string.lower(typ) == "coin" then
		hasnum = self.coin
	else
		error("invalid resource type:" .. tostring(typ))
	end
	if hasnum < num then
		if notify then
			local resname = getresname(typ)
			net.msg.S2C.notify(self.pid,language.format("{1}不足{2}",resname,num))
		end
		return false
	end
	return true
end

-- 转身等玩法可能用到，根据玩法看是否重新分配素质点等信息！，切记同步更新关联数据
function cplayer:setlv(val,reason)
	local oldval = self.lv
	assert(val <= playeraux.getmaxlv())
	logger.log("info","lv",string.format("[setlv] pid=%d lv=%d->%d reason=%s",self.pid,oldval,val,reason))
	self.lv = val
end

function cplayer:addlv(val,reason)
	local oldval = self.lv
	local newval = oldval + val
	assert(newval <= playeraux.getmaxlv())
	logger.log("info","lv",string.format("[addlv] pid=%d lv=%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	self.lv = newval
	sendpackage(self.pid,"player","update",{lv=self.lv})
	self:onaddlv(val,reason)
end

function cplayer:onaddlv(val,reason)
	-- 例如：10级升到11级，可获得int(10/5+3）= 5点剩余点数
	local add_qualitypoint = 0
	for lv=self.lv-val+1,self.lv do
		add_qualitypoint = add_qualitypoint + math.floor((lv-1) / 5 + 3)
	end
	if add_qualitypoint ~= 0 then
		self:add_qualitypoint(add_qualitypoint,"onaddlv")
	end
	for _,obj in pairs(self.autosaveobj) do
		if obj.onchangelv then
			obj:onchangelv(self)
		end
	end
end


function cplayer:addexp(val,reason)
	local maxlv = playeraux.getmaxlv()
	if self.lv >= maxlv then
		return 0
	end
	local oldval = self.exp
	local newval = oldval + val
	logger.log("debug","lv",string.format("[addexp] pid=%d addexp=%d reason=%s",self.pid,val,reason))
	local addlv = 0
	for lv=self.lv,maxlv-1 do
		local maxexp = playeraux.getmaxexp(lv)
		if newval >= maxexp then
			newval = newval - maxexp
			addlv = addlv + 1
		else
			break
		end
	end
	self.exp = newval
	sendpackage(self.pid,"player","update",{exp=self.exp})
	if addlv > 0 then
		self:addlv(addlv,reason)
	end
	return val
end

-- 增加职业转生等级
function cplayer:addjobzs(val,reason)
	local oldval = self.jobzs
	local newval = oldval + val
	assert(newval <= playeraux.getmaxjobzs())
	logger.log("info","lv",string.format("[addjobzs] pid=%s jobzs=%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	self.jobzs = newval
	sendpackage(self.pid,"player","update",{jobzs=self.jobzs})
end

function cplayer:setjoblv(val,reason)
	local oldval = self.joblv
	assert(val <= playeraux.getmaxjoblv(self.jobzs))
	logger.log("info","lv",string.format("[setjoblv] pid=%d joblv=%d->%d reason=%s",self.pid,oldval,val,reason))
	self.joblv = val
	sendpackage(self.pid,"player","update",{joblv=self.joblv})
end

function cplayer:addjoblv(val,reason)
	local oldval = self.joblv
	local newval = oldval + val
	assert(newval <= playeraux.getmaxjoblv(self.jobzs))
	logger.log("info","lv",string.format("[addjoblv] pid=%d joblv=%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	self.joblv = newval
	sendpackage(self.pid,"player","update",{joblv=self.joblv})
	self:onaddjoblv(val,reason)
end

function cplayer:onaddjoblv(val,reason)
	self.warskilldb:addpoint(val,"addjoblv")
	self.taskdb:onchangejoblv()
end

function cplayer:addjobexp(val,reason)
	local maxlv = playeraux.getmaxjoblv(self.jobzs)
	if self.joblv >= maxlv then
		return 0
	end
	local oldval = self.jobexp
	local newval = oldval + val
	logger.log("debug","lv",string.format("[addjobexp] pid=%d addjobexp=%d reason=%s",self.pid,val,reason))
	local addlv = 0
	for lv=self.joblv,playeraux.getmaxjoblv(self.jobzs)-1 do
		local maxexp = playeraux.getmaxjobexp(self.jobzs,lv)
		if newval >= maxexp then
			newval = newval - maxexp
			addlv = addlv + 1
		else
			break
		end
	end
	self.jobexp = newval
	sendpackage(self.pid,"player","update",{jobexp=self.jobexp})
	if addlv > 0 then
		self:addjoblv(addlv,reason)
	end
	return val
end

-- 转职(职业ID,就是角色类型ID)
function cplayer:changejob(tojobid)
	if not isvalid_roletype(tojobid) then
		net.msg.S2C.notify(self.pid,language.format("非法职业ID"))
		return
	end
	local needjoblv = data_0101_Hero[self.roletype].ZZHILV
	if self.joblv < needjoblv then
		net.msg.S2C.notify(self.pid,language.format("职业等级不足{1}级，无法进行转职",needjoblv))
		return
	end
	-- TODO: check more
	local jobdata = data_0101_Hero[tojobid]
	if jobdata.ZSPRE ~= self.roletype then
		net.msg.S2C.notify(self.pid,language.format("你无法转成该职业"))
		return
	end
	if jobdata.isOpen == 1 then
		net.msg.S2C.notify(self.pid,language.format("此职业暂未开放"))
		return
	end
	logger.log("info","lv",string.format("[changejob] pid=%d oldjob=%d newjob=%d",self.pid,self.roletype,tojobid))
	self.roletype = tojobid
	self.warskilldb:openskills(self.roletype)
	self:addjobzs(1,"changejob")
	self.joblv = 1
	self.jobexp = 0
	sendpackage(self.pid,"player","update",{
		roletype = self.roletype,
		joblv = self.joblv,
		jobexp = self.jobexp,
	})
	-- TODO:推送转职消息，谁注册谁处理
	self.taskdb.zhiyin:onchangejob(jobdata.ZSPRE)
	local token = uuid()
	playermgr.addtoken(token,{
		pid = self.pid,
		player_data = playermgr.packplayer4kuafu(self.pid),
	})
	playermgr.kick(self,"changejob",function(player)
		net.login.S2C.reentergame(player,{
			go_srvname = cserver.getsrvname(),
			token = token,
		})
	end)
end

function cplayer:addgold(val,reason)
	val = math.floor(val)
	local oldval = self.gold
	local newval = oldval + val
	logger.log("info","resource/gold",string.format("[addgold] pid=%d gold=%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	self.gold = newval
	sendpackage(self.pid,"player","resource",{gold=self.gold})
	local addgold = newval - oldval
	if addgold > 0 then
		event.playerdo(self.pid,"金币增加",addgold)
	end
	return addgold
end

function cplayer:addsilver(val,reason)
	val = math.floor(val)
	local oldval = self.silver
	local newval = oldval + val
	logger.log("info","resource/silver",string.format("[addsilver] pid=%d silver=%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	self.silver = newval
	sendpackage(self.pid,"player","resource",{silver=self.silver})
	return val
end

function cplayer:addcoin(val,reason)
	val = math.floor(val)
	local oldval = self.coin
	local newval = oldval + val
	logger.log("info","resource/coin",string.format("[addcoin] pid=%d coin=%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	self.coin = newval
	sendpackage(self.pid,"player","resource",{coin=self.coin})
	return val
end

-- 增加素质点
function cplayer:add_qualitypoint(val,reason)
	self:add("qualitypoint.sum",val)
	sendpackage(self.pid,"player","update",{
		qualitypoint = self:query("qualitypoint"),
	})
end

-- 获取消耗的素质点
function cplayer:get_cost_qualitypoint(typ,val)
	local key = string.format("qualitypoint.%s",typ)
	local hasnum = self:query(key,0)
	local costnum = 0
	for i=1,val do
		costnum = costnum + math.floor((hasnum-1)/10+2)
		hasnum = hasnum + 1
	end
	return  costnum
end

function cplayer:can_alloc_qualitypoint_to(typ,val)
	assert(val > 0)
	if not data_1001_PlayerVar.ValidQualityPointType[typ] then
		return false,language.format("非法素质点类型")
	end
	local maxnum = data_1001_PlayerVar.MaxUseQualityPoint[self.jobzs]
	local costnum = self:get_cost_qualitypoint(typ,val)
	local hasnum = self:query("qualitypoint." .. typ) or 0
	local sumnum = self:query("qualitypoint.sum",0) + self:query("qualitypoint.expand",0)
	if costnum > sumnum then
		return false,language.format("可分配点不足#<R>{1}#点",costnum)
	end
	if val + hasnum > maxnum then
		return false,language.format("分配的单项素质点无法超过#<R>{1}#点",maxnum)
	end
	return true
end

-- 分配指定素质点
function cplayer:alloc_qualitypoint_to(typ,val)
	assert(val > 0)
	local key = string.format("qualitypoint.%s",typ)
	local costnum = self:get_cost_qualitypoint(typ,val)
	self:add("qualitypoint.sum",-costnum)
	self:add(key,val)
	sendpackage(self.pid,"player","update",{
		qualitypoint = self:query("qualitypoint"),
	})
end

-- 分配素质点
function cplayer:alloc_qualitypoint(tbl)
	-- 忽略未改变的素质类型
	for typ,val in pairs(tbl) do
		if val == 0 then
			tbl[typ] = nil
		end
	end
	local maxnum = data_1001_PlayerVar.MaxUseQualityPoint[self.jobzs]
	local costnum = 0
	for typ,val in pairs(tbl) do
		local isok,errmsg = self:can_alloc_qualitypoint_to(typ,val)
		if not isok then
			return isok,errmsg
		end
		costnum = costnum + self:get_cost_qualitypoint(typ,val)
	end
	local sumnum = self:query("qualitypoint.sum",0) + self:query("qualitypoint.expand",0)
	if costnum > sumnum then
		return false,language.format("可分配点不足#<R>{1}#点",costnum)
	end
	self:add("qualitypoint.sum",-costnum)
	for typ,val in pairs(tbl) do
		self:add("qualitypoint." .. typ,val)
	end
	sendpackage(self.pid,"player","update",{
		qualitypoint = self:query("qualitypoint"),
	})
	return true
end

function cplayer:reset_qualitypoint()
	local addnum = 0
	for typ in pairs(data_1001_PlayerVar.ValidQualityPointType) do
		local hasnum = self:query("qualitypoint." .. typ,0)
		for i=1,hasnum-1 do
			addnum = addnum + math.floor((i-1)/10+2)
		end
	end
	self:add("qualitypoint.sum",addnum)
	for typ in pairs(data_1001_PlayerVar.ValidQualityPointType) do
		self:set("qualitypoint." .. typ,1)
	end
	sendpackage(self.pid,"player","update",{
		qualitypoint = self:query("qualitypoint"),
	})
end

function cplayer:genid()
	-- 基本不可能溢出,玩家平均每天消耗10万ID，超过32位整数也需要>70年时间
	if self.objid > MAX_NUMBER then
		self.objid = 1000
	end
	self.objid = self.objid + 1
	return self.objid
end

function cplayer:additembytype(itemtype,num,bind,reason,tip)
	local itemdb = self:getitemdb(itemtype)
	local num1,num2 = itemdb:additembytype(itemtype,num,bind,reason)
	if tip then
		local itemdata = itemaux.getitemdata(itemtype)
		net.msg.S2C.notify(self.pid,language.format("获得 #<II{1}># #<O>【{2}】+{3}#",itemtype,itemaux.itemlink(itemtype),num1))
	end
	return num1,num2
end

function cplayer:getitemdb(itemtype)
	local maintype = itemaux.getmaintype(itemtype)
	if maintype == ItemMainType.FASHION_SHOW then
		return self.fashionshowdb
	elseif maintype == ItemMainType.CARD then
		return self.carddb
	else
		return self.itemdb
	end
end

-- 返回的也是itemdb，根据背包类型获取
function cplayer:getitembag(bagtype)
	if bagtype == BAGTYPE.NORMAL or bagtype == "itemdb" then
		return self.itemdb
	elseif bagtype == BAGTYPE.FASHION_SHOW or bagtype == "fashionshowdb" then
		return self.fashionshowdb
	else
		assert(bagtype == BAGTYPE.CARD or bagtype == "carddb")
		return self.carddb
	end
end

function cplayer:getitem(itemid)
	local item = self.itemdb:getitem(itemid)
	if item then
		return item,self.itemdb
	end
	item = self.carddb:getitem(itemid)
	if item then
		return item,self.carddb
	end
	item = self.fashionshowdb:getitem(itemid)
	if item then
		return item,self.fashionshowdb
	end
end

function cplayer:wield(equip)
	local itemdata = itemaux.getitemdata(equip.type)
	if equip.pos == itemdata.equippos then
		return
	end
	self.itemdb:moveitem(equip.id,itemdata.equippos)
	self:refreshequip()
	local scene = scenemgr.getscene(self.sceneid)
	if equip.pos == EQUIPPOS.WEAPON then
		scene:set(self.pid,{
			weapontype = equip.type
		})
	elseif equip.pos == EQUIPPOS.SHIELD then
		scene:set(self.pid,{
			shieldtype = equip.type
		})
	end
end

function cplayer:unwield(equip)
	local itemdata = itemaux.getitemdata(equip.type)
	if equip.pos ~= itemdata.equippos then
		return
	end
	local newpos = self.itemdb:getfreepos()
	if newpos == nil then
		net.msg.S2C.notify(self.pid,"背包已满")
		return
	end
	self.itemdb:moveitem(equip.id,newpos)
	self:refreshequip()

	local scene = scenemgr.getscene(self.sceneid)
	if itemdata.equippos == EQUIPPOS.WEAPON then
		scene:set(self.pid,{
			weapontype = 0,
		})
	elseif itemdata.equippos == EQUIPPOS.SHIELD then
		scene:set(self.pid,{
			shieldtype = 0,
		})
	end

end

function cplayer:refreshequip()
	for pos = 1,self.itemdb.beginpos - 1 do
		local equip = self.itemdb:getitembypos(pos)
		if equip then
		end
	end
end

function cplayer:addhuoli(num,reason)
	self:add("huoli",num)
	sendpackage(self.pid,"player","update",{ huoli = self:query("huoli"), })
	return num
end

function cplayer:addres(typ,num,reason,btip)
	if num == 0 then
		return 0
	end
	local resid = getresid(typ)
	local flag = string.format("IR%d",resid)
	if resid == RESTYPE.GOLD then
		num = self:addgold(num,reason)
	elseif resid == RESTYPE.SILVER then
		num = self:addsilver(num,reason)
	elseif resid == RESTYPE.COIN then
		num = self:addcoin(num,reason)
	elseif resid == RESTYPE.EXP then
		num = self:addexp(num,reason)
	elseif resid == RESTYPE.UNION_OFFER then
		num = self:union_addoffer(num,reason)
	elseif resid == RESTYPE.HUOLI then
		num = self:addhuoli(num,reason)
	elseif resid == RESTYPE.JOBEXP then
		num = self:addjobexp(num,reason)
	elseif resid == RESTYPE.UNION_MONEY then
		num = self:union_addmoney(num,reason)
		flag = "IR"
	elseif resid == RESTYPE.LIVENESS then
		num = navigation.addliveness(self,num)
	else
		error("Invlid restype:" .. tostring(typ))
	end
	if btip then
		local msg
		if num > 0 then
			msg = language.format("{1}#<O>{2}# #<{3}>#","获得",num,flag)
		elseif num < 0 then
			msg = language.format("{1}#<O>{2}# #<{3}>#","花费",-num,flag)
		end
		if msg then
			net.msg.S2C.notify(self.pid,msg)
		end
	end
	return num
end

-- getter
function cplayer:authority()
	if skynet.getenv("servermode") == "DEBUG" then
		return 100
	end
	return self:query("auth",0)
end

function cplayer:ip()
	return self.__ip
end

function cplayer:port()
	return self.__port
end

function cplayer:teamstate()
	local team = self:getteam(self.pid)
	if not team then
		return NO_TEAM
	end
	return team:teamstate(self.pid)
end

function cplayer:getteam()
	return teammgr:getteambypid(self.pid)
end

function cplayer:teamid()
	local team = self:getteam()
	return team and team.id
end

-- 组队成员
function cplayer:packmember()
	return {
		pid = self.pid,
		name = self.name,
		lv = self.lv,
		roletype = self.roletype,
		sex = self.sex,
		state = self:teamstate(),
	}
end

-- 场景信息
function cplayer:packscene(sceneid,pos)
	sceneid = sceneid or self.sceneid
	pos = pos or self.pos
	local scene = scenemgr.getscene(sceneid)
	local pack = {
		pid = self.pid,
		name = self.name,
		lv = self.lv,
		roletype = self.roletype,
		sex = self.sex,
		jobzs = self.jobzs,
		joblv = self.joblv,
		teamid = self:teamid() or 0,
		teamstate = self:teamstate(),
		warid = self:warid() or 0,
		unionid = self:unionid() or 0,
		scene_strategy = self.scene_strategy,
		agent = self.__agent,
		mapid = scene.mapid,
		sceneid = sceneid,
		pos = pos,
	}
	local weapon = self.itemdb:getitembypos(EQUIPPOS.WEAPON)
	if weapon then
		pack.weapontype = weapon.type
	end
	local shield = self.itemdb:getitembypos(EQUIPPOS.SHIELD)
	if shield then
		pack.shieldtype = shield.type
	end
	return pack
end

-- setter
function cplayer:setauthority(auth)
	self:set("auth",auth)
end

function cplayer:canmove()
	local teamstate = self:teamstate()
	if teamstate == TEAM_STATE_FOLLOW then
		return false
	end
	if self:warid() then
		return false
	end
	return true
end

function cplayer:move(package)
	assert(package)
	if not self:canmove() then
		return
	end
	local pid = self.pid
	assert(self.sceneid)
	local scene = scenemgr.getscene(self.sceneid)
	if scene then
		local oldpos = self.pos
		scene:move(self,package)
		self:onmove(oldpos,self.pos)
		return true
	end
end

function cplayer:onmove(oldpos,newpos)
	huodongmgr.onmove(self,oldpos,newpos)
end

function cplayer:leavescene(sceneid)
	sceneid = sceneid or self.sceneid
	assert(sceneid)
	if sceneid then
		local scene = scenemgr.getscene(sceneid)
		if scene then
			scene:leave(self)
			return true
		end
	end
	return false
end

-- 上线进入场景时notleave为真
function cplayer:enterscene(sceneid,pos,notleave)
	assert(sceneid)
	assert(pos)

	local newscene = scenemgr.getscene(sceneid)
	if not newscene then
		return false
	end
	if not newscene:isvalidpos(pos) then
		pos = newscene:fixpos(pos)
	end
	local isok,errmsg = self:canenterscene(sceneid,pos)
	if not isok then
		net.msg.S2C.notify(self.pid,errmsg)
		return false
	end
	local pid = self.pid
	if not notleave then
		self:leavescene(self.sceneid)
	end
	newscene:enter(self,pos)
	return true
end

-- 强制跳转到指定坐标
cplayer.jumpto = cplayer.enterscene

function cplayer:canenterscene(sceneid,pos)
	local scene = scenemgr.getscene(sceneid)
	if not scene then
		return false,language.format("场景不存在")
	end
	local isok,errmsg = huodongmgr.canenterscene(self,sceneid,pos)
	if not isok then
		return false,errmsg
	end
	return true
end

function cplayer:setpos(sceneid,pos)
	local scene = scenemgr.getscene(sceneid)
	if not scene:isvalidpos(pos) then
		pos = scene:fixpos(pos)
	end
	self.sceneid = sceneid
	self.pos = pos
	local teamstate = self:teamstate()
	if teamstate == TEAM_STATE_CAPTAIN then
		local team = self:getteam()
		if team then
			for pid,_ in pairs(team.follow) do
				if pid ~= self.pid then
					local member = playermgr.getplayer(pid)
					if member then
						member:setpos(sceneid,deepcopy(pos))
					end
				end
			end
		end
	end
end

function cplayer:onhourupdate()
	self.shopdb:onhourupdate()
end

function cplayer:onfivehourupdate()
	local now = os.time()
	local today_zerotime = getdayzerotime(now)
	local next_five_hour = today_zerotime + 5 * 3600
	if next_five_hour <= now then
		next_five_hour = next_five_hour + DAY_SECS
	end
	local lefttime = next_five_hour - now
	self.thistemp:set("onfivehourupdate",1,lefttime)
	-- dosomething(),涉及到玩家数据变动,需要主动更新
	for k,obj in pairs(self.autosaveobj) do
		if obj.onfivehourupdate then
			obj:onfivehourupdate()
		end
	end
	navigation.onfivehourupdate(self)
	local monthno = getyearmonth()
	if self:query("monthno") ~= monthno then
		self:onmonthupdate_infivehour()
	end
end

function cplayer:oncleartoday(data)
	local dataunit = cbasicattr.new({pid=self.pid,flag="oncleartoday"})
	dataunit.data = data
	self.taskdb:oncleartoday(dataunit)
end

-- 每个月第一天的5点时更新
function cplayer:onmonthupdate_infivehour()
	self:set("monthno",getyearmonth())
end

function cplayer:gettarget(targetid)
	if targetid == 1 then
		return self
	else
		return self.petdb:getpet(targetid)
	end
end

function cplayer:isgm()
	if cserver.isinnersrv() then
		return true
	end
	if self:query("gm") then
		return true
	end
	return false
end

function cplayer:getskilldb(skillid)
	--TODO 按照编号范围区分
	if data_0201_Skill[skillid] then
		return self.warskilldb
	end
end

function cplayer:getlanguage()
	return self:query("lang") or language.language_to
end

function cplayer:getfighters()
	local fighters = nil
	local errmsg
	local teamstate = self:teamstate()
	if teamstate == NO_TEAM then
		fighters = {self.pid}
	elseif teamstate == TEAM_STATE_CAPTAIN then
		fighters = {self.pid}
		local team = self:getteam()
		table.extend(fighters,team:members(TEAM_STATE_FOLLOW))
	elseif teamstate == TEAM_STATE_LEAVE then
		fighters = {self.pid,}
	else
		assert(teamstate == TEAM_STATE_FOLLOW)
		fighters = nil
		errmsg = language.format("跟随队员无法进行此操作")
	end
	return fighters,errmsg
end

function cplayer:getwar()
	return warmgr.getwarbypid(self.pid)
end

function cplayer:warid()
	local war = self:getwar()
	return war and war.warid
end

function cplayer:getname()
	return self.name
end

function cplayer:has_dexp_addn(playname,exp)
	local data = data_ExpPlayUnit[playname]
	if not data then
		return false
	end
	-- 策划要求：挂机是跟随队员不消耗双倍点,也不收益于双倍点
	if playname == "guaji" and self:teamstate() == TEAM_STATE_FOLLOW then
		return false
	end
	local exp_addn = 0
	if data.cost_dexp ~= 0 then
		if self.switch:isopen("costdexp") then
			local dexp = self.thisweek:query("dexppoint") or 0
			if dexp >= data.cost_dexp then
				self.thisweek:add("dexppoint",-data.cost_dexp)
				sendpackage(self.pid,"player","resource",{
					dexppoint = self.thisweek:query("dexppoint") or 0,
				})
				exp_addn = math.floor(exp * data.dexp_addn)
			end
		end
	end
	return true,exp_addn
end

-- 玩法消耗的双倍点
function cplayer:has_exp_addn(playname,exp)
	local data = data_ExpPlayUnit[playname]
	if not data then
		return false
	end
	local exp_addn = 0
	local detail = {}
	local isok,dexp_addn = self:has_dexp_addn(playname,exp)
	if isok then
		detail.dexp_addn = dexp_addn
	end
	if data.captain_addn ~= 0 then
		if self:teamstate() == TEAM_STATE_CAPTAIN then
			detail.captain_addn = math.floor(exp * data.captain_addn)
		end
	end
	for k,addn in pairs(detail) do
		exp_addn = exp_addn + addn
	end
	--print(true,exp_addn,table.dump(detail))
	return true,exp_addn,detail
end

function cplayer:team_maxlv(state)
	state = state or TEAM_STATE_ALL
	local teamid = self:teamid()
	if not teamid then
		return self.lv
	else
		local team = teammgr:getteam(teamid)
		local maxlv = 0
		for i,uid in ipairs(team:members(state)) do
			local member = playermgr.getplayer(uid)
			if member.lv > maxlv then
				maxlv = member.lv
			end
		end
		return maxlv
	end
end

function cplayer:team_avglv(state)
	state = state or TEAM_STATE_ALL
	local teamid = self:teamid()
	if not teamid then
		return self.lv
	else
		local team = teammgr:getteam(teamid)
		local sumlv = 0
		local cnt = 0
		for i,uid in ipairs(team:members(state)) do
			local member = playermgr.getplayer(uid)
			cnt = cnt + 1
			sumlv = sumlv + member.lv
		end
		return math.floor(sumlv / cnt)
	end
end

function cplayer:team_avglv2(state)
	state = state or TEAM_STATE_ALL
	local maxlv = self:team_maxlv(state)
	local avglv = self:team_avglv(state)
	return math.floor((maxlv+avglv)/2)
end

function cplayer:captain_lv()
	local teamid = self:teamid()
	if not teamid then
		return self.lv
	else
		local team = teammgr:getteam(teamid)
		local captain = playermgr.getplayer(team.captain)
		return captain.lv
	end
end

-- 延迟下线机制 [START]
function cplayer:can_exitgame()
	if self.bforce_exitgame then
		return true
	end
	local now = os.time()
	local can_tuoguan,tuoguan_time = self:can_tuoguan()
	if not self.delay_exitgame_timerid and can_tuoguan then
		self:set_exitgame_time(now + tuoguan_time)
	end
	if self:warid() then
		if not self.exitgame_time or self.exitgame_time <= now then
			self:set_exitgame_time(now + 60)
		end
	end
	if not self.exitgame_time then
		return true
	else
		return now >= self.exitgame_time
	end
end

function cplayer:set_exitgame_time(time)
	if not self.exitgame_time or self.exitgame_time < time then
		self.exitgame_time = time
	end
	return self.exitgame_time
end

function cplayer.__exitgame(pid)
	local player = playermgr.getplayer(pid)
	if player then
		player:exitgame("delay_exitgame")
	end
end

function cplayer:delay_exitgame()
	self.delay_exitgame_timerid = timer.timeout("timer.delay_exitgame",60,functor(cplayer.__exitgame,self.pid))
	return self.delay_exitgame_timerid
end

function cplayer:del_delay_exitgame()
	self.bforce_exitgame = nil
	self.exitgame_time = nil
	if self.delay_exitgame_timerid then
		local timerid = self.delay_exitgame_timerid
		timer.deltimerbyid(timerid)
		self.delay_exitgame_timerid = nil
		return timerid
	end
end
-- 延迟下线机制 [END]

-- 充值 [START]
function cplayer:getchongzhilist()
	local channel = self.channel
	local valid_products = {}
	for id,product in pairs(data_1401_ChongZhi) do
		if table.find(product.channels,0) or table.find(product.channels,channel) then
			if product.maxbuycnt ~= 0 then		-- 0: 禁止购买; -1:购买次数不受限制
				if product.maxbuycnt < 0 or self:getchongzhicnt(id) < product.maxbuycnt then
					valid_products[id] = product
				end
			end
		end
	end
	-- 排除互斥项/未达成购买条件项
	local seen = {}
	for id,product in pairs(valid_products) do
		if product.preid == 0 then
			seen[id] = true
		elseif self:getchongzhicnt(product.preid) > 0 then
			seen[id] = true
		end
	end
	return seen
end

function cplayer:sync_chongzhilist(seen)
	seen = seen or self:getchongzhilist()
	sendpackage(self.pid,"player","chongzhilist",{
		seen = table.keys(seen),
	})
end

function cplayer:getprodcut(id)
	return data_1401_ChongZhi[id]
end

function cplayer:addchongzhicnt(id,num)
	num = num or 1
	local key = string.format("chongzhicnt.%s",id)
	self:add(key,num)
end

function cplayer:getchongzhicnt(id)
	-- 这里可以做特殊处理
	local key = string.format("chongzhicnt.%s",id)
	return self:query(key) or 0
end

-- @param buy_product {id=充值项ID,rmb=RMB}
function cplayer:chongzhi(buy_product)
	local id = assert(buy_product.id)
	local rmb = buy_product.rmb
	local seen = self:getchongzhilist()
	local product = self:getprodcut(id)
	if not product then
		logger.log("error","chongzhi",format("[no product] pid=%s buy_product=%s acct=%s channel=%s ip=%s isgm=%s",self.pid,buy_product,self.account,self.channel,self:ip(),self:isgm()))
		return
	end
	if not seen[id] then
		logger.log("warning","chongzhi",format("[cann't seen] pid=%s buy_product=%s acct=%s channel=%s ip=%s isgm=%s",self.pid,buy_product,self.account,self.channel,self:ip(),self:isgm()))
		if not product.nextid or product.nextid == 0 then
			return
		end
		id = product.nextid
	end
	product = self:getprodcut(id)
	if product.rmb ~= rmb then
		logger.log("error","chongzhi",format("[money not enough] pid=%s buy_product=%s acct=%s channel=%s ip=%s isgm=%s",self.pid,buy_product,self.account,self.channel,self:ip(),self:isgm()))
		net.msg.S2C.notify(self.pid,language.format("购买失败,您是否支付数目不足?"))
		return
	end
	logger.log("info","chongzhi",format("[chongzhi] pid=%s buy_product=%s acct=%s channel=%s ip=%s isgm=%s",self.pid,buy_product,self.account,self.channel,self:ip(),self:isgm()))
	local reason = string.format("chongzhi:%s",product.id)
	self:addchongzhicnt(product.id)
	self:addres("gold",product.gold,reason,true)
	self:addres("gold",product.give_gold,reason,true)
	if product.itemtype and product.itemtype ~= 0 and product.itemnum > 0 then
		self:additembytype(product.itemtype,product.itemnum,nil,reason,true)
	end
	if product.pettype and product.pettype > 0 then

	end
	local new_seen = self:getchongzhilist()
	if not table.equal(seen,new_seen) then
		self:sync_chongzhilist(new_seen)
	end
end

-- 充值 [END]


function cplayer:getres(restype)
	return self[restype]
end

-- e.g:
-- local isok,lackres,costres = player:checkres({
--		items = {xxx},
--		gold = xxx,
--		silver = xxx,
--		coin = xxx,
-- })
-- if not isok then
--	--dosomething
-- end
function cplayer:checkres(needres)
	local isok = true
	local cost = {}
	local lack = {}
	for restype,resval in pairs(needres) do
		if restype == "items" then
			cost.items = {}
			lack.items = {}
			for i,item in ipairs(resval) do
				assert(item.num > 0)
				local itemdb = self:getitemdb(item.type)
				local hasnum = itemdb:getnumbytype(item.type)
				if hasnum < item.num then
					table.insert(lack.items,{
						type = item.type,
						num = item.num - hasnum,
					})
					if hasnum > 0 then
						table.insert(cost.items,{
							type = item.type,
							num = hasnum,
						})
					end
					isok = false
				else
					table.insert(cost.items,{
						type = item.type,
						num = item.num,
					})
				end
			end
		else
			local hasval = self:getres(restype)
			if hasval < resval then
				lack[restype] = resval - hasval
				cost[restype] = hasval
				isok = false
			else
				cost[restype] = resval
			end
		end
	end
	cost.gold = (cost.gold or 0) + self:togold(lack)
	return isok,lack,cost
end

function cplayer:costres(costres,reason,btip)
	for restype,resval in pairs(costres) do
		if restype == "items" then
			for i,item in ipairs(resval) do
				local itemdb = self:getitemdb(item.type)
				if itemdb:getnumbytype(item.type) < item.num then
					if btip then
						net.msg.S2C.notify(self.pid,language.format("{1}数量不足",itemaux.itemlink(item.type)))
					end
					return false
				end
			end
		else
			if not self:validpay(restype,resval,btip) then
				return false
			end
		end
	end
	for restype,resval in pairs(costres) do
		if restype == "items" then
			for i,item in ipairs(resval) do
				local itemdb = self:getitemdb(item.type)
				itemdb:costitembytype(item.type,item.num,reason)
				if btip then
					net.msg.S2C.notify(self.pid,language.format("消耗#<II{1}>#{2}-{3}",item.type,itemaux.itemlink(item.type),item.num))
				end
			end
		else
			self:addres(restype,-resval,reason,true)
		end
	end
	return true
end

function cplayer:togold(lackres)
	local needgold = 0
	for restype,resval in pairs(lackres) do
		if restype == "items" then
			for i,item in ipairs(resval) do
				local itemdata = itemaux.getitemdata(item.type)
				needgold = needgold +  itemdata.buygold * item.num
			end
		else
			local resid = RESTYPE[restype]
			local resdata = data_ResType[resid]
			needgold = needgold + resval / resdata.goldbuyhowmuch
		end
	end
	needgold = math.ceil(needgold)
	return needgold
end

function cplayer:oncostres(needres,reason,btip,callback)
	local isok,lackres,costres = self:checkres(needres)
	if not isok then
		return openui.messagebox(self.pid,{
			type = MB_LACK_CONDITION,
			title = language.format("条件不足"),
			buttons = {
				openui.button(language.format("花费#<O>{1}# #<IR2>#兑换并购买",costres.gold)),
			},
			attach = {
				lackres = lackres,
				costgold = costres.gold,
			}},function (uid,request,response)
				local player = playermgr.getplayer(uid)
				if not player then
					return
				end
				if response.answer ~= 1 then
					return
				end
				if not self:costres(costres,reason,btip) then
					return
				end
				if callback then
					callback(uid)
				end
			end)
	else
		if not self:costres(costres,reason,btip) then
			return
		end
		if callback then
			callback(self.pid)
		end
	end
end

function cplayer:setname(name)
	local oldname = self.name
	self.name = name
	local db = dbmgr.getdb(cserver.datacenter())
	local srvname = cserver.getsrvname()
	local zonename = data_RoGameSrvList[srvname].zonename
	local key = db:key("allname",zonename)

	if oldname then
		db:hdel(key,oldname)
	end
	db:hset(key,name,self.pid)
end

-- for rpc
function cplayer:getlv()
	return self.lv
end

function cplayer:unionid()
	return self:query("union.id")
end

function cplayer:union_recommendlist()
	local list = self.thistemp:query("union_recommendlist")
	if not list then
		local pids = {}
		for i,pid in ipairs(playermgr.allplayer()) do
			local player = playermgr.getplayer(pid)
			if player and
				not player:unionid() and
				playeraux.isopen(player.lv,"公会") then
				table.insert(pids,pid)
			end
		end
		pids = shuffle(pids,nil,20)
		self.thistemp:set("union_recommendlist",pids,1800)
	end
	return self.thistemp:query("union_recommendlist")
end

function cplayer:delfrom_union_recommendlist(tid)
	local list = self:union_recommendlist()
	local pos = table.find(list,tid)
	if pos then
		table.remove(list,pos)
		sendpackage(self.pid,"union","delinviter",{
			pid = tid,
		})
	end
end

function cplayer:ondelfromunion(unionid)
	self:delete("union.id")
	self.today:delete("union.huodong.collectitem")
	self.thistemp:delete("union_recommendlist")
	if self.lv >= data_1800_UnionVar.QuitUnionCDNeedLv then
		self.thistemp:set("apply_join_cd",unionid,data_1800_UnionVar.JoinUnionCDAfterQuit)
	end
	sendpackage(self.pid,"union","selfunion",{
	})
	local scene = scenemgr.getscene(self.sceneid)
	scene:set(self.pid,{
		unionid = 0,
	})
	self.taskdb:update_canaccept()
end

function cplayer:onaddtounion(unionid,member)
	assert(self.pid == member.pid)
	self:set("union.id",unionid)
	sendpackage(self.pid,"union","selfunion",{
		unionid = unionid,
		jobid = member.jobid,
	})
	
	local scene = scenemgr.getscene(self.sceneid)
	scene:set(self.pid,{
		unionid = unionid,
	})
	self.taskdb:update_canaccept()
end

function cplayer:union_addoffer(addval,reason)
	local unionid = self:unionid()
	if not unionid then
		return 0
	end
	if cserver.isunionsrv() then
		local union = unionmgr:getunion(unionid)
		return union:addoffer(self.pid,addval,reason)
	else
		return rpc.call(cserver.unionsrv(),"rpc","unionmgr:unionmethod",unionid,":addoffer",self.pid,addval,reason)
	end
end

function cplayer:union_addmoney(addval,reason)
	local unionid = self:unionid()
	if not unionid then
		return 0
	end
	return unionaux.addmoney(unionid,addval,reason)
end

function cplayer:union_addwarcnt(cnt)
	cnt = cnt or 1
	local unionid = self:unionid()
	if not unionid then
		return
	end
	if cserver.isunionsrv() then
		local union = unionmgr:getunion(unionid)
		union:addwarcnt(self.pid,cnt)
	else
		rpc.call(cserver.unionsrv(),"rpc","unionmgr:unionmethod",unionid,":addwarcnt",self.pid,cnt)
	end
end

function cplayer:union_addfinishcnt(name,cnt)
	cnt = cnt or 1
	self.thisweek:add(string.format("union.weekfuli.finishcnt.%s",name),cnt)
end

function cplayer:union_collectitem_donate(donate)
	if self:unionid() ~= donate.unionid then
		return false,language.format("该求助信息不是来源于你的公会")
	end
	local task = unionaux.gettask_collectitem(self,donate.taskid)
	if not task then
		return false,language.format("该求助任务已失效")
	end
	if not task.inhelp then
		return false,language.format("该任务尚未求助")
	end
	if donate.itemtype ~= task.itemtype then
		return false,language.format("捐献的物品类型错误")
	end
	if task.hasnum >= task.neednum then
		return false,language.format("该任务已完成")
	end
	if task.isbonus then
		return false,language.format("该任务已领取过奖励")
	end
	if task.hasnum + donate.itemnum ~= task.neednum then
		return false,language.format("捐献的物品数量不能刚好让对方完成任务")
	end
	task.hasnum = task.hasnum + donate.itemnum
	local donater = resumemgr.getresume(donate.pid)
	task.donater = {
		pid = donate.pid,
		name = donater:get("name"),
	}
	return true
end

function cplayer:union_collectitem_submit(submit)
	local task = unionaux.gettask_collectitem(self,submit.taskid)
	if not task then
		return false,language.format("该任务已失效")
	end
	if submit.itemtype ~= task.itemtype then
		return false,language.format("物品类型错误")
	end
	if task.hasnum >= task.neednum then
		return false,language.format("该任务已完成")
	end
	if task.isbonus then
		return false,language.format("该任务已领取过奖励")
	end
	if task.hasnum + submit.itemnum ~= task.neednum then
		return false,language.format("提交的物品数量不能刚好完成任务")
	end
	task.hasnum = task.hasnum + submit.itemnum
	sendpackage(self.pid,"union","collectitem_updatetask",{
		task = task,
	})
	return true
end

function cplayer:union_collectitem_finishtask(taskid)
	local huodong = unionaux.gethuodong_collectitem(self)
	local task = unionaux.gettask_collectitem(self,taskid)
	if not task then
		return false,language.format("该任务已失效")
	end
	if task.hasnum < task.neednum then
		return false,language.format("该任务尚未完成")
	end
	if task.isbonus then
		return false,language.format("该任务已领取奖励了")
	end
	task.isbonus = true
	local reason = "union.collectitem_finishtask"
	local bonus = data_1800_UnionCollectItemAward[self.lv]
	doaward("player",self.pid,bonus,reason,true)
	sendpackage(self.pid,"union","collectitem_updatetask",{
		task = task,
	})
	huodong.finishcnt = huodong.finishcnt + 1
	local finishall = true
	for i,task in ipairs(huodong.tasks) do
		if not task.isbonus then
			finishall = false
		end
	end
	if finishall then
		local bonus = data_1800_UnionCollectItemAward.FinalAward
		doaward("player",self.pid,bonus,reason,true)
	end
end

function cplayer:limit_frequence(cmd,pid,cd,val)
	val = val or true
	local key = string.format("frequence.%s.%s",cmd,pid)
	local incd,exceedtime = self.thistemp:query(key)
	if incd then
		return true,exceedtime - os.time()
	end
	self.thistemp:set(key,val,cd)
	return false
end

return cplayer
