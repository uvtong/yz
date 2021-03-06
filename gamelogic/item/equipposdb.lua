-- 装备栏格子自身带属性（如精炼次数，策划现在要求跟格子，而不是跟装备)
-- 精炼增加的属性
--	self.refine = {
--		cnt = nil,					-- 精炼次数
--		succ_ratio = nil,			-- 精炼当前成功概率(基数为100）
--	}


cequipposdb = class("cequipposdb",ccontainer)

function cequipposdb:init(conf)
	ccontainer.init(self,conf)
	self.pid = assert(conf.pid)
	for i = 1,ITEMPOS_BEGIN-1 do
		self:add({
			refine = {},
			cardid = 0,
		},i)
	end
end

function cequipposdb:clear()
	ccontainer.clear(self)
	for i = 1,ITEMPOS_BEGIN-1 do
		self:add({
			refine = {},
			cardid = 0,
		},i)
	end
end

function cequipposdb:onlogin(player)
	sendpackage(player.pid,"item","all_equippos",{
		equipposes = table.values(self.objs),
	})
end

function cequipposdb:refine(pos)
	local player = playermgr.getplayer(self.pid)
	if not player then
		return
	end
	local obj = self:get(pos)
	if not obj then
		return
	end
	assert(obj.id == pos)
	local itemdb = player.itemdb
	local cnt = obj.refine.cnt or 0
	local refinedata = data_0801_Refine[cnt+1]
	if not refinedata then
		net.msg.S2C.notify(player.pid,language.format("精炼次数已达上限"))
		return
	end
	if cnt >= player.lv then
		net.msg.S2C.notify(player.pid,language.format("精炼次数已超过角色等级"))
		return
	end
	local costitem = EQUIPPOS_NAME[pos] == "weapon" and refinedata.weapon_costitem or refinedata.costitem
	local costcoin = refinedata.costcoin
	for itemtype,num in pairs(costitem) do
		if itemdb:getnumbytype(itemtype) < num then
			net.msg.S2C.notify(player.pid,language.format("{1}数量不足#<R>{2}#个",itemaux.itemlink(itemtype),num))
			return
		end
	end
	if not player:validpay("coin",costcoin,true) then
		return
	end
	local reason = string.format("refine#%d",obj.id)
	for itemtype,num in pairs(costitem) do
		itemdb:costitembytype(itemtype,num,reason)
	end
	player:addcoin(-costcoin,reason)

	local succ_ratio = obj.refine.succ_ratio or refinedata.init_succ_ratio
	if not ishit(succ_ratio,100) then
		net.msg.S2C.notify(player.pid,language.format("精炼失败"))
		obj.refine.succ_ratio = math.min(succ_ratio+data_0801_PromoteEquipVar.RefineFailAddRatio,100)
		self:update(obj.id,{
			refine = obj.refine,
		})
		return
	end
	net.msg.S2C.notify(player.pid,language.format("精炼成功"))
	obj.refine.succ_ratio = nil
	obj.refine.cnt = cnt + 1
	self:update(obj.id,{
		refine = obj.refine,
	})
end

function cequipposdb:onupdate(id,attrs)
	attrs.id = id
	sendpackage(self.pid,"item","update_equippos",{
		equippos = attrs,
	})
end

return cequipposdb
