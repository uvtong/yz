cpet = class("cpet",cdatabaseable,{
	zizhi_minratio = 50,	--最小资质比
	zizhi_maxratio = 100,	--最大资质比
})

function cpet:init(param)
	param = param or { pid = 0, flag = "pet", }
	cdatabaseable.init(self,param)
	self.id = param.id
	self.type = param.typ
	self.createtime = param.createtime
	-- 位置一般是放入容器后才有的属性
	self.pos = param.pos
	self.data = {}
	self.lv = 1
	self.exp = 0
	self.name = ""
	self.status = petaux.status("兴奋")
	self.relationship = petaux.relationship("陌生")
	self.close = 0		-- 亲密度
	self.zizhi = {
		liliang = 0,
		minjie = 0,
		tili = 0,
		zhili = 0,
		lingqiao = 0,
		xingyun = 0,
	}
	self.zizhi_ratio = {
		liliang = self.zizhi_minratio,
		minjie = self.zizhi_minratio,
		tili = self.zizhi_minratio,
		lingqiao = self.zizhi_minratio,
		xingyun = self.zizhi_minratio,
	}
	self.skills = cposcontainer.new({
		pid = self.pid,
		name = "petskills",
		initspace = 15,
	})
	self.equipments = cposcontainer.new({
		pid = self.pid,
		name = "petequips",
		initspace = 6,
	})
	self.chats = {"","","","","","",}
	self.bianyi_type = 0
end

function cpet:config()
	local data = petaux.getpetdata(self.type)
	for name,ratio in pairs(self.zizhi_ratio) do
		self.zizhi[name] = math.floor(data[name] * ratio / 100)
	end
end

function cpet:load(data)
	if not data or not next(data) then
		return
	end
	self.id = data.id
	self.type = data.type
	self.createtime = data.createtime
	self.pos = data.pos
	self.data = data.data
	self.lv = data.lv
	self.exp = data.exp
	self.name = data.name
	self.status = data.status
	self.relationship = data.relationship
	self.close = data.close
	self.zizhi_ratio = data.zizhi_ratio
	self.skills:load(data.skills)
	self.equipments:load(data.equipments,function(itemdata)
		local item = citem.new()
		item:load(itemdata)
		return item
	end)
	self.chats = data.chats
	self.bianyi_type = data.bianyi_type
end

function cpet:save()
	local data = {}
	data.id = self.id
	data.type = self.type
	data.createtime = self.createtime
	data.pos = self.pos
	data.data = self.data
	data.lv = self.lv
	data.name = self.name
	data.exp = self.exp
	data.status =  self.status
	data.relationship = self.relationship
	data.close = self.close
	data.zizhi_ratio = self.zizhi_ratio
	data.skills = self.skills:save()
	data.equipments = self.equipments:save(function(item)
		return item:save()
	end)
	data.chats = self.chats
	data.bianyi_type = self.bianyi_type
	return data
end

function cpet:setzizhi(name,value)
	local data = petaux.getpetdata(self.type)
	value = math.max(value,math.floor(data[name] * self.zizhi_minratio / 100))
	value = math.min(value,math.floor(data[name] * self.zizhi_maxratio / 100))
	self.zizhi[name] = value
	self.zizhi_ratio[name] = value * 100 /  data[name]
	return value
end

function cpet:getzizhilimit(name)
	if not self.zizhi[name] then
		return 0
	end
	local basezizhi = self:get(name)
	return math.floor(basezizhi * self.zizhi_maxratio / 100)
end

function cpet:pack()
	local data = {}
	data.id = self.id
	data.type = self.type
	data.name = self:name()
	data.pos = self.pos
	data.createtime = self.createtime
	data.lv = self.lv
	data.exp = self.exp
	data.relationship = self.relationship
	data.close = self.close
	data.status = self.status
	data.readywar = self.readywar or false
	data.zizhi = self.zizhi
	data.skills = self:getallskills()
	data.equips = self:getallequips()
	data.chats = self.chats
	data.bianyi_type = self.bianyi_type
	return data
end

function cpet:get(attr)
	local petdata = petaux.getpetdata(self.type)
	return petdata[attr]
end

function cpet:name()
	if self.name ~= "" then
		return self.name
	end
	return self:get("name")
end

function cpet:hasskill(skillid)
	local bindskill = petaux.getpetdata(self.type).bind_skills
	if table.find(bindskill,skillid) then
		return -1
	end
	local skill = self.skills:get(skillid)
	if not skill then
		return
	end
	return skill.pos
end

function cpet:addskill(skillid,pos)
	if self:hasskill(skillid) then
		return
	end
	local skill = {
		id = skillid,
		time = os.time(),
		pos = pos,
	}
	self:add(skill,skillid)
	return skill
end

function cpet:delskill(skillid)
	local idx = self:hasskill(skillid)
	if not idx or idx == -1 then
		return
	end
	self:del(skillid)
end

function cpet:isbianyi()
	return self.bianyi_type ~= 0
end

function cpet:getallskills()
	local data = petaux.getpetdata(self.type)
	local curpos = 0
	local skills = {}
	for idx,skillid in ipairs(data.bind_skills) do
		curpos = curpos + 1
		table.insert(skills,{
			id = skillid,
			pos = curpos,
		})
	end
	if self:isbianyi() then
		local bianyidata = data_1700_PetBianyi[self.type]
		for idx,skllid in ipairs(bianyidata[self.bianyi_type]) do
			curpos = curpos + 1
			table.insert(skills,{
				id = skillid,
				pos = curpos,
			})
		end
	end
	for _,skill in pairs(self.skills.objs) do
		table.insert(skills,{
			id = skill.id,
			pos = skill.pos + curpos,
		})
	end
	return skills
end

function cpet:getskillslen()
	local data = petaux.getpetdata(self.type)
	return #data.bind_skills + self.skills.len
end

function cpet:getallequips()
	local equips = {}
	for _,equip in pairs(self.equips.objs) do
		table.insert(equips,equip:pack())
	end
	return equips
end

return cpet