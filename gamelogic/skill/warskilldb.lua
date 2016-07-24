--战斗技能容器
cwarskilldb = class("cwarskilldb",ccontainer)

function cwarskilldb:init(conf)
	ccontainer.init(self,conf)
	self.skillpoint = 0
	self.skillslot = {
		[1] = { [1] = nil, [2] = nil, [3] = nil, [4] = nil,},
		[2] = { [1] = nil, [2] = nil, [3] = nil, [4] = nil,},
		[3] = { [1] = nil, [2] = nil, [3] = nil, [4] = nil,},
	}
	self.curslot = 1
	self.pos_id = {}
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
	self.skillslot = data.skillslot
	self.curslot = data.curslot
end

function cwarskilldb:save()
	data = ccontainer.save(self)
	data.skillpoint = self.skillpoint
	data.skillslot = self.skillslot
	data.curslot = self.curslot
	return data
end

function cwarskilldb:_onadd(skill)
	self.pos_id[skill.pos] = skill.id
end

function cwarskilldb:onadd(skill)
	self:_onadd(skill)
	net.skill.S2C.addskill(self.pid,skill)
end

function cwarskilldb:onupdate(skillid,attrs)
	attrs.id = skillid
	net.skill.S2C.updateskill(self.pid,attrs)
end

function cwarskilldb:onlogin(player)
	self:sendallskill()
	net.skill.S2C.updateslot(self.pid,self.skillslot,self.curslot)
end

function cwarskilldb:getwarskilldata(skillid)
	return data_0201_Skill[skillid]
end

function cwarskilldb:sendallskill()
	local skills = {}
	for _,skill in pairs(self.objs) do
		table.insert(skills,{
			skillid = skill.id,
			level = skill.level,
		})
	end
	net.skill.S2C.allskills(skills,self.skillpoint)
end

function cwarskilldb:openskills(job)
	local skillids = {}
	for _,skillid in ipairs(skillids) do
		local pos = self.len + 1
		local skill = self:newskill(skillid,pos)
		self:add(skill,skillid)
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
	self.skillslot[self.curslot][position] = skillid
	net.skill.S2C.updateslot(self.pid,self.skillslot)
end

function cwarskilldb:canwield(skllid)
	return true
end

function cwarskilldb:setcurslot(idx)
	if not self.skillslot[idx] then
		return
	end
	self.curslot = idx
	net.skill.S2C.updateslot(self.pid,nil,self.curslot)
end

function cwarskilldb:changepos(skillid1,skillid2)
	local skill1 = self:get(skillid1)
	local skill2 = self:get(skillid2)
	if not skill1 or not skilll2 then
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
	logger.log("info","skill",format("[learn] pid=%d skillid=%d",self.pid,skillid))
	local skill = self:get(skillid)
	local lv = skill.level
	self:update(skillid,{ level = lv + 1,})
end

function cwarskilldb:canlearn(skillid)
	return true
end

function cwarskilldb:resetpoint()
	if not self:canreset() then
		return
	end
	local point = 0
	for _,skill in pairs(self.objs) do
		point = point + skill.level
	end
	if point == 0 then
		return
	end
	--TODO 重置消耗
	logger.log("info","skill",format("[reset] pid=%d point=%d",self.pid,point))
	for _,skill in pairs(self.objs) do
		skill.level = 0
	end
	self.skillpoint = self.skillpoint + point
	self:sendallskill()
end

function cwarskilldb:canreset()
	return true
end

function cwarskilldb:addpoint(point,reason)
	logger.log("info","skill",format("[addpoint] pid=%d point=%d reason=%s",self.pid,point,reason))
	self.skillpoint = self.skillpoint + point
end
