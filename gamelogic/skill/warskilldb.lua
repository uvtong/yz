--战斗技能容器
cwarskilldb = class("cwarskilldb",ccontainer)

function cwarskilldb:init(conf)
	ccontainer.init(self,conf)
	self.pid = assert(conf.pid)
	self.skillpoint = 0
	self.pos_id = {}
	self:initskillslot()
	self.loadstate = "unload"
end

function cwarskilldb:load(data)
	if table.isempty(data) then
		return
	end
	ccontainer.load(self,data,function(skill)
		self:_onadd(skill)
		return skill
	end)
	self.skillpoint = data.skillpoint
	self.curslot = data.curslot
	for slot,skills in pairs(data.skillslot) do
		slot = tonumber(slot)
		for idx,skillid in pairs(skills) do
			idx = tonumber(idx)
			self.skillslot[slot][idx] = skillid
		end
	end
end

function cwarskilldb:save()
	local data = ccontainer.save(self)
	data.skillpoint = self.skillpoint
	data.skillslot = self.skillslot
	data.curslot = self.curslot
	return data
end

function cwarskilldb:clear()
	ccontainer.clear(self)
	self:initskillslot()
	self.pos_id = {}
end

function cwarskilldb:initskillslot()
	self.skillslot = {
		[1] = { [1] = 0, [2] = 0, [3] = 0, [4] = 0,},
		[2] = { [1] = 0, [2] = 0, [3] = 0, [4] = 0,},
		[3] = { [1] = 0, [2] = 0, [3] = 0, [4] = 0,},
	}
	self.curslot = 1
end

function cwarskilldb:_onadd(skill)
	self.pos_id[skill.pos] = skill.id
end

function cwarskilldb:onadd(skill)
	self:_onadd(skill)
	net.skill.S2C.addskill(self.pid,self:pack(skill))
end

function cwarskilldb:onupdate(skillid,attrs)
	attrs.id = skillid
	net.skill.S2C.updateskill(self.pid,self:pack(attrs))
end

function cwarskilldb:onlogin(player)
	self:sendallskill()
	net.skill.S2C.updatepoint(self.pid,self.skillpoint)
	net.skill.S2C.updateslot(self.pid,self.skillslot[self.curslot],self.curslot)
end

function cwarskilldb:oncreate(player)
	self:openskills(player.roletype)
end

function cwarskilldb:getskilldata(skillid)
	return data_0201_Skill[skillid]
end

function cwarskilldb:pack(skill)
	return skill
end

function cwarskilldb:sendallskill()
	local skills = {}
	for _,skill in pairs(self.objs) do
		table.insert(skills,self:pack(skill))
	end
	net.skill.S2C.allskill(self.pid,skills)
end

function cwarskilldb:openskills(job)
	local skillids = skillaux.getskills_byjob(job)
	if not skillids then
		return
	end
	logger.log("info","skill",format("[openskill] pid=%d job=%d skills=%s",self.pid,job,skillids))
	for _,skillid in ipairs(skillids) do
		if not self:get(skillid) then
			local pos = self.len + 1
			local skill = self:newskill(skillid,pos)
			self:add(skill,skillid)
		end
	end
end

function cwarskilldb:newskill(skillid,pos)
	local skill = {
		level = 0,
		pos = pos,
	}
	return skill
end

function cwarskilldb:wieldskill(skillid,position)
	if position < 1 or position > 4 then
		return
	end
	if not self:canwield(skillid) then
		return
	end
	for key,value in pairs(self.skillslot[self.curslot]) do
		if value == skillid then
			self.skillslot[self.curslot][key] = 0
			break
		end
	end
	logger.log("info","skill",format("[wieldskill] pid=%d skillid=%d pos=%d",self.pid,skillid,position))
	self.skillslot[self.curslot][position] = skillid
	net.skill.S2C.updateslot(self.pid,self.skillslot[self.curslot])
end

function cwarskilldb:canwield(skillid)
	local skill = self:get(skillid)
	if not skill or skill.level <= 0 then
		return false
	end
	local skilldata = self:getskilldata(skillid)
	if skilldata.attackType == 1 then
		return false
	end
	return true
end

function cwarskilldb:setcurslot(idx)
	if not self.skillslot[idx] then
		return
	end
	self.curslot = idx
	net.skill.S2C.updateslot(self.pid,self.skillslot[self.curslot],self.curslot)
end

function cwarskilldb:getcurskills()
	local skills = {}
	if self.skillslot[self.curslot] then
		for pos,skillid in ipairs(self.skillslot[self.curslot]) do
			local skill = self:get(skillid)
			if skill then
				table.insert(skills,{ id = skillid, lv = skill.level, pos = pos, })
			end
		end
	end
	for _,skill in pairs(self.objs) do
		local skilldata = self:getskilldata(skill.id)
		--被动技能
		if skill.level > 0 and skilldata.attackType == 1 then
			table.insert(skills,{ id = skill.id, lv = skill.level, pos = 0, })
		end
	end
	return skills
end

function cwarskilldb:changepos(skillid1,skillid2)
	local skill1 = self:get(skillid1)
	local skill2 = self:get(skillid2)
	if not skill1 or not skill2 then
		return
	end
	local pos1,pos2 = skill1.pos,skill2.pos
	self.update(skillid1,{ pos = pos2,})
	self.update(skillid2,{ pos = pos1,})
end

function cwarskilldb:learnskill(skillid)
	if not self:canlearn(skillid) then
		return
	end
	local skill = self:get(skillid)
	local lv = skill.level
	self:addpoint(-1,"learnskill")
	logger.log("info","skill",format("[learn] pid=%d skillid=%d lv=%d",self.pid,skillid,lv + 1))
	self:update(skillid,{ level = lv + 1,})
end

function cwarskilldb:canlearn(skillid)
	if not self:get(skillid) then
		return false
	end
	if self.skillpoint <= 0 then
		return false
	end
	local skill = self:get(skillid)
	local data = self:getskilldata(skillid)
	if not data then
		return false
	end
	local preskill,presklv,maxlv,preskpoint = data.skillPre,data.skillPreLv,data.maxLv,data.skillPrePt
	if preskill ~= 0 then
		local skill2 = self:get(preskill)
		if not skill2 or skill2.level < presklv then
			return false
		end
	end
	if maxlv ~= 0 and skill.level >= maxlv then
		return false
	end
	if preskpoint ~= 0 and self:getallpoint() < preskpoint then
		return false
	end
	return true
end

function cwarskilldb:resetpoint()
	if not self:canreset() then
		return
	end
	--TODO 重置消耗
	local point = 0
	for _,skill in pairs(self.objs) do
		local data = self:getskilldata(skill.id)
		-- 初心者技能不变
		if data.jobID ~= 10001 then
			point = point + skill.level
			skill.level = 0
		end
	end
	logger.log("info","skill",format("[reset] pid=%d point=%d",self.pid,point))
	self.skillpoint = self.skillpoint + point
	self:sendallskill()
	net.skill.S2C.updatepoint(self.pid,self.skillpoint)
	self:initskillslot()
	net.skill.S2C.updateslot(self.pid,self.skillslot[self.curslot],self.curslot)
end

function cwarskilldb:getallpoint()
	local point = 0
	for _,skill in pairs(self.objs) do
		point = point + skill.level
	end
	return point
end

function cwarskilldb:canreset()
	return true
end

function cwarskilldb:addpoint(point,reason)
	logger.log("info","skill",format("[addpoint] pid=%d point=%d reason=%s",self.pid,point,reason))
	self.skillpoint = self.skillpoint + point
	net.skill.S2C.updatepoint(self.pid,self.skillpoint)
end

