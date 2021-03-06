--关卡容器
cchapterdb = class("cchapterdb",ccontainer)

function cchapterdb:init(conf)
	ccontainer.init(self,conf)
	self.pid = assert(conf.pid)
	self.mainlinestar = {}
	self.branchline = {}
	self.awardrecord = {}
	self.loadstate = "unload"
end

function cchapterdb:load(data)
	if table.isempty(data) then
		return
	end
	ccontainer.load(self,data)
	self.awardrecord = data.awardrecord
	for _,chapter in pairs(self.objs) do
		if self:getchapterdata(chapter.id) then
			self:_onupdate(chapter)
		else
			self:del(chapter.id)
		end
	end
end

function cchapterdb:save()
	local data = ccontainer.save(self)
	data.awardrecord = self.awardrecord
	return data
end

function cchapterdb:onupdate(chapterid,attrs)
	local chapter = self:get(chapterid)
	self:_onupdate(chapter)
	attrs.chapterid = chapterid
	net.chapter.S2C.update(self.pid,attrs)
end

function cchapterdb:_onupdate(chapter)
	local chapterdata = self:getchapterdata(chapter.id)
	local section = chapterdata.section
	if chapterdata.line == 1 then
		if not self.mainlinestar[section] then
			self.mainlinestar[section] = {}
		end
		self.mainlinestar[section][chapter.id] = chapter.star
	else
		if not self.branchline[section] then
			self.branchline[section] = {}
		end
		self.branchline[section][chapter.id] = 1
	end
end

function cchapterdb:onadd(chapter)
	net.chapter.S2C.unlock(self.pid,chapter.id)
end

function cchapterdb:clear()
	ccontainer.clear(self)
	self.awardrecord = {}
	self.mainlinestar = {}
end

function cchapterdb:onlogin(player)
	local chapters = {}
	for _,chapter in pairs(self.objs) do
		table.insert(chapters,self:pack(chapter))
	end
	net.chapter.S2C.allchapter(self.pid,chapters)
	net.chapter.S2C.awardrecord(self.pid,self.awardrecord)
end

function cchapterdb:findrecord(awardid)
	return table.find(self.awardrecord,awardid)
end

function cchapterdb:getchapterdata(chapterid)
	local data = data_1201_Chapter[chapterid]
	if data and data.isopen == 1 then
		return data
	end
end

function cchapterdb:getawarddata(awardid)
	return data_1202_ChapterAward[awardid]
end

function cchapterdb:sumstar(section)
	if not self.mainlinestar[section] then
		return 0
	end
	local sum = 0
	for _,star in pairs(self.mainlinestar[section]) do
		sum = sum + star
	end
	return sum
end

function cchapterdb:pack(chapter)
	return {
		chapterid = chapter.id,
		star = chapter.star,
		pass = chapter.pass,
		time = chapter.time or 0,
	}
end

function cchapterdb:unlockchapter(chapterid)
	if self:get(chapterid) then
		return
	end
	local chapterdata = self:getchapterdata(chapterid)
	if not chapterdata then
		return
	end
	logger.log("info","chapter",format("[unlock] pid=%d chapterid=%d",self.pid,chapterid))
	local chapter = {
		star = 0,
		pass = false,
		time = os.time(),
	}
	self:add(chapter,chapterid)
end

function cchapterdb:mainlineaward(awardid)
	local awarddata = self:getawarddata(awardid)
	if not awarddata then
		return
	end
	if self:findrecord(awardid) then
		net.msg.S2C.notify(self.pid,language.format("该奖励已经领取过了"))
		net.chapter.S2C.awardrecord(self.pid,self.awardrecord)
		return
	end
	local section,needstar = awarddata.section,awarddata.needstar
	if self:sumstar(section) < needstar then
		net.msg.S2C.notify(self.pid,language.format("需要达到{1}颗星才能领取该奖励",needstar))
		return
	end
	local player = playermgr.getplayer(self.pid)
	assert(player)
	logger.log("info","chapter",format("[award] pid=%d section=%d awardid=%d",self.pid,section,awardid))
	table.insert(self.awardrecord,awardid)
	player:additembytype(awarddata.item,awarddata.num,nil,"chapteraward",true)
	net.chapter.S2C.awardrecord(self.pid,self.awardrecord)
end

function cchapterdb:raisewar(chapterid)
	local chapterdata = self:getchapterdata(chapterid)
	if not chapterdata or not self:get(chapterid) then
		return
	end
	local player = playermgr.getplayer(self.pid)
	local attackers = player:getfighters()
	local warid = chapterdata.warid
	local war = {
		wardataid = warid,
		attack_helpers = {},
		defense_helpers = {},
		wartype = WARTYPE.PVE_CHAPTER,
		chapterid = chapterid,
		attackers = attackers,
	}
	warmgr.startwar(attackers,{},war)
end

function cchapterdb:onwarend(war,result)
	local star = result
	for _,pid in ipairs(war.attackers) do
		local member = playermgr.getplayer(pid)
		member.chapterdb:onwarend2(star,war.chapterid)
	end
end

function cchapterdb:onwarend2(star,chapterid)
	local chapter = self:get(chapterid)
	if not chapter then
		return
	end
	if star > 0 then
		local chapterdata = self:getchapterdata(chapterid)
		local attrs = {}
		--主线关卡3星通关
		if chapterdata.line == 1 then
			if chapter.star < star then
				attrs.star = star
			end
			if star == 3 and not chapter.pass then
				attrs.pass = true
			end
		elseif not chapter.pass then
			attrs.pass = true
		end
		if not table.isempty(attrs) then
			logger.log("info","chapter",format("[update] pid=%d chapterid=%d attrs=%s",self.pid,chapterid,attrs))
			self:update(chapterid,attrs)
		end
	end
end

function cchapterdb:get_unlockcondition(chapterid)
	if self:get(chapterid) then
		return
	end
	local chapterdata = self:getchapterdata(chapterid)
	if not chapterdata then
		return
	end
	local player = playermgr.getplayer(self.pid)
	local taskcontainer = player.taskdb:gettaskcontainer(chapterdata.taskid)
	if not taskcontainer then
		return
	end
	local taskdata = taskcontainer:getformdata("task")[chapterdata.taskid]
	local data = {}
	local needtasks = {}
	for _,tid in ipairs(taskdata.pretask) do
		local con = player.taskdb:gettaskcontainer(tid)
		if con and not con.finishtasks[tid] then
			table.insert(needtasks,tid)
		end
	end
	data.needtasks = next(needtasks) and needtasks or nil
	net.chapter.S2C.send_unlockcondition(self.pid,chapterid,data)
end

function cchapterdb:reviewstory(line,section)
	local lineinfo
	if line == 1 then
		lineinfo = self.mainlinestar
	else
		lineinfo = self.branchline
	end
	if not lineinfo[section] then
		net.msg.S2C.notify(self.pid,language.format("该章节未解锁"))
		return
	end
	local textids,transstr = {},{}
	local chapterdata,taskcontainer,taskid
	local player = playermgr.getplayer(self.pid)
	local sortedchapter = table.keys(lineinfo[section])
	table.sort(sortedchapter)
	for _,chapterid in ipairs(sortedchapter) do
		if self:get(chapterid) then
			chapterdata = self:getchapterdata(chapterid)
			for _,tid in ipairs(chapterdata.story) do
				taskcontainer = player.taskdb:gettaskcontainer(tid)
				local tbl1,tbl2 = taskcontainer:reviewstory(tid)
				table.extend(textids,tbl1)
				table.update(transstr,tbl2)
				taskid = tid
			end
		end
	end
	if table.isempty(textids) then
		return
	end
	net.chapter.S2C.sendstory(self.pid,taskid,textids,transstr)
end

return cchapterdb
