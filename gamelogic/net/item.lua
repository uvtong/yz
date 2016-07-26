netitem = netitem or {
	C2S = {},
	S2C = {},
}

local C2S = netitem.C2S
local S2C = netitem.S2C


--[[
-- 使用物品步骤:
-- 1. 判断物品是否存在
-- 2. 判断目标是否存在
-- 3. 判断是否可以对目标使用物品（如物品数量不足，其他条件)
-- 4. 使用物品
-- 5. 扣除物品
--]]
function C2S.useitem(player,request)
	local itemid = assert(request.itemid)
	local targetid = request.targetid
	local num = request.num
	local item = player:getitem(itemid)
	if not item then
		net.msg.S2C.notify(player.pid,language.format("物品不存在"))
		return
	end
	local target
	if targetid then
		local target = player:gettarget(targetid)
		if not target then
			net.msg.S2C.notify(player.pid,language.format("未知目标"))
			return
		end
	end
	item:use(player,target,num)
end

function C2S.sellitem(player,request)
	local itemid = assert(request.itemid)
	local num = request.num or 1
	local item,itemdb = player:getitem(itemid)
	if not item then
		return
	end
	if item.num < num then
		net.msg.S2C.notify(player.pid,language.format("物品数量不足#<R>{1}#个",num))
		return
	end
	local reason = string.format("sellitem#%s",item.id)
	itemdb:costitembyid(itemid,num,reason)
	local itemdata = itemaux.getitemdata(item.type)
	local maintype = itemaux.getmaintype(itemtype)
	if maintype == ItemMainType.CARD then  -- 卡片卖银币，而且跟卡片等级有关
		local lv = item.lv or 1
		local data = itemdata.lv_attr[lv]
		local addsilver = itemdata.silver_price * num
		player:addsilver(addsilver,reason)
	else
		local addcoin = itemdata.coin_price * num
		player:addcoin(addcoin,reason)
	end
end

function C2S.produceitem(player,request)
end

function C2S.destroyitem(player,request)
	local itemid = assert(request.itemid)
	local item,itemdb = player:getitem(itemid)
	if item then
		itemdb:delitem(itemid,"destroyitem")
	end
end

function C2S.mergeto(player,request)
	local from_itemid = assert(request.from_itemid)
	local to_itemid = assert(request.to_itemid)
	local num = request.num
	local fromitem,fromitemdb = player:getitem(from_itemid)
	if not fromitem then
		return
	end
	local toitem,toitemdb = player:getitem(to_itemid)
	if not toitem then
		return
	end
	if fromitemdb ~= toitemdb then
		return
	end
	if fromitemdb.name == "carddb" then
		net.msg.S2C.notify(player.pid,language.format("卡片无法合并"))
		return
	end
	local itemdata = itemaux.getitemdata(toitem.type)
	assert(itemdata)
	num = num or fromitem.num
	local itemdb = fromitemdb
	if not itemdb:canmerge(fromitem,toitem) then
		return
	end
	if toitem.num >= itemdata.maxnum then
		return
	end
	local addnum = itemdata.maxnum - toitem.num
	addnum = math.min(num,addnum)
	local reason = string.format("%s_mergeto_%s",from_itemid,to_itemid)
	itemdb:costitembyid(from_itemid,addnum,reason)
	itemdb:additembyid(to_itemid,addnum,reason)
end

function C2S.wield(player,request)
	local equipid = assert(request.itemid)
	local equip = player:getitem(equipid)
	if not equip then
		return
	end
	local itemtype = itemaux.getmaintype(equip.type)
	if itemtype ~= ItemMainType.EQUIP then
		return
	end
	player:wield(equip)
end

function C2S.unwield(player,request)
	local equipid = assert(request.itemid)
	local equip = player:getitem(equipid)
	if not equip then
		return
	end
	local itemtype = itemaux.getmaintype(equip.type)
	if itemtype ~= ItemMainType.EQUIP then
		return
	end
	player:unwield(equip)
end

function C2S.changesuit(player,request)
	local suitno = assert(request.suitno)
	player.suitequip:changesuit(suitno)
end

function C2S.setsuit(player,request)
	local suitno = assert(request.suitno)
	player.suitequip:setsuit(suitno)
end

function C2S.pickitem(player,request)
	local itemid = assert(request.itemid)
	local sceneid = assert(request.sceneid)
	if player.sceneid ~= sceneid then
		return
	end
	local item = scenemgr.getitem(itemid,sceneid)
	if not item then
		return
	end
	local distance = getdistance(player.pos,item.pos)
	if distance > 20 then
		net.msg.S2C.notify(player.pid,language.format("距离物品太远"))
		return
	end
	scenemgr.delitem(itemid,sceneid)
	player:additembytype(item.type,item.num,item.bind,"pickitem")
end

function C2S.upgradeequip(player,request)
	local itemid = assert(request.itemid)
	local item,itemdb = player:getitem(itemid)
	if not item then
		net.msg.S2C.notify(player.pid,language.format("该装备不存在"))
		return
	end
	local itemdata = itemaux.getitemdata(item.type)
	local next_itemtype = item.type + 1
	local next_itemdata = itemaux.getitemdata(next_itemtype)
	if not next_itemdata or next_itemdata.equiptype ~= itemdata.equiptype then
		net.msg.S2C.notify(player.pid,language.format("该装备已无法升级"))
		return
	end
	local costitem = next_itemdata.upgrade_costitem
	local costcoin = next_itemdata.upgrade_costcoin
	for itemtype,num in pairs(costitem) do
		-- 材料和装备一定是在同一个背包中!
		if num ~= 0 and itemdb:getnumbytype(itemtype) < num then

			net.msg.S2C.notify(player.pid,language.format("{1}数量不足#<R>{2}#个",itemaux.itemlink(itemtype),num))
			return
		end
	end
	if not player:validpay("coin",costcoin,true) then
		return
	end

	local reason = string.format("upgradeequip#",item.id)
	for itemtype,num in pairs(costitem) do
		itemdb:costitembytype(itemtype,num,reason)
	end
	player:addcoin(-costcoin,reason)
	logger.log("info","item",string.format("[upgradeitem] pid=%s itemid=%s type=%s->%s",player.pid,itemid,item.type,next_itemtype))
	itemdb:update(itemid,{type=next_itemtype})
end

function C2S.refineequip(player,request)
	local itemid = assert(request.itemid)
	local item,itemdb = player:getitem(itemid)
	if not item then
		net.msg.S2C.notify(player.pid,language.format("该装备不存在"))
		return
	end
	local maintype = itemaux.getmaintype(item.type)
	if maintype ~= ItemMainType.EQUIP then
		net.msg.S2C.notify(player.pid,language.format("非装备类型无法精炼"))
		return
	end
	local equiplv = item:get("lv")
	local need_equiplv = data_0801_PromoteEquipVar.RefineNeedEquipLv
	if equiplv < need_equiplv then
		net.msg.S2C.notify(player.pid,language.format("装备等级不足#<R>{1}#级",need_equiplv))
		return
	end
	local cnt = item.refine.cnt or 0
	local refinedata = data_0801_Refine[cnt+1]
	if not refinedata then
		net.msg.S2C.notify(player.pid,language.format("精炼次数已达上限"))
		return
	end
	if cnt >= player.lv then
		net.msg.S2C.notify(player.pid,language.format("精炼次数已超过角色等级"))
		return
	end
	if cnt >= equiplv + 9 then
		net.msg.S2C.notify(player.pid,language.format("精炼次数已超过装备等级+9"))
		return
	end
	local itemdata = itemaux.getitemdata(item.type)
	local costitem = itemaux.isweapon(itemdata.equiptype) and refinedata.weapon_costitem or refinedata.costitem
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
	local reason = string.format("refineequip#%d",item.id)
	for itemtype,num in pairs(costitem) do
		itemdb:costitembytype(itemtype,num,reason)
	end
	player:addcoin(-costcoin,reason)

	local succ_ratio = item.refine.succ_ratio or refinedata.init_succ_ratio
	if not ishit(succ_ratio,100) then
		net.msg.S2C.notify(player.pid,language.format("精炼失败"))
		item.refine.succ_ratio = math.min(succ_ratio+data_0801_PromoteEquipVar.RefineFailAddRatio,100)
		net.item.S2C.updateitem(player.pid,{
			id = item.id,
			refine = item.refine,
		})
		--itemdb:update(item.id,{
		--	refine = item.refine,
		--})
		return
	end
	item.refine.succ_ratio = nil
	item.refine.cnt = cnt + 1
	net.item.S2C.updateitem(player.pid,{
		id = item.id,
		refine = item.refine
	})
end

function C2S.fumoequip(player,request)
	local itemid = assert(request.itemid)
	local item,itemdb = player:getitem(itemid)
	if not item then
		net.msg.S2C.notify(player.pid,language.format("该物品不存在"))
		return
	end
	local maintype = itemaux.getmaintype(item.type)
	if maintype ~= ItemMainType.EQUIP then
		net.msg.S2C.notify(player.pid,language.format("非装备类型无法附魔"))
		return
	end

	local minortype = itemaux.getminortype(item.type)
	local minortype_name = assert(EQUIP_MINORTYPE_NAME[minortype],"Invalid item minortype:" .. tostring(minortype))
	local equiplv = item:get("lv")
	local need_equiplv = data_0801_PromoteEquipVar.FumoNeedEquipLv
	if equiplv < need_equiplv then
		net.msg.S2C.notify(player.pid,language.format("装备等级不足#<R>{1}#级",need_equiplv))
		return
	end
	local fumodata = assert(data_0801_Fumo[equiplv],"Invalid equiplv:" .. tostring(equiplv))
	local costitem = fumodata.costitem
	local costcoin = fumodata.costcoin
	for itemtype,num in pairs(costitem) do
		if itemdb:getnumbytype(itemtype) < num then
			net.msg.S2C.notify(player.pid,language.format("{1}数量不足#<R>{2}#个",itemaux.itemlink(itemtype),num))
			return
		end
	end
	if not player:validpay("coin",costcoin,true) then
		return
	end
	local reason = string.format("fumoequip#%d",item.id)
	for itemtype,num in pairs(costitem) do
		itemdb:costitembytype(itemtype,num,reason)
	end
	player:addcoin(-costcoin,reason)
	local attrnum = choosekey(data_0801_PromoteEquipVar.FumoShowAttrNumRatio)
	local attrs = {}
	-- 随机attrnum条不重复的属性
	for i=1,attrnum do
		local attr = choosekey(data_0801_FumoAttrRatio,function (k,v)
			-- 已出现属性，强制将其概率改成0
			if attrs[attr] then
				return 0
			end
			local key = string.format("%s_ratio",minortype_name)
			return v[key]
		end)
		local data = data_0801_FumoAttrRatio[attr]
		local attr_factor = data[string.format("%s_factor",minortype_name)]
		local maxlv = math.floor(fumodata[attr] * attr_factor)
		local minlv = math.floor(maxlv * 0.2)
		attrs[attr] = math.random(minlv,maxlv)
	end
	attrs.exceedtime = os.time() + 3 * DAY_SECS
	item.tmpfumo = attrs
	C2S.confirm_fumoequip(player,{itemid=item.id})
end

function C2S.confirm_fumoequip(player,request)
	local itemid = assert(request.itemid)
	local item,itemdb = player:getitem(itemid)
	if not item then
		net.msg.S2C.notify(player.pid,language.format("该装备不存在"))
		return
	end
	if table.isempty(item.tmpfumo) then
		return
	end
	local tmpfumo = item.tmpfumo
	tmpfumo.exceedtime = nil
	item.tmpfumo = nil
	itemdb:update(itemid,{
		fumo = tmpfumo,
	})
end

function C2S.insertcard(player,request)
	local itemid = assert(request.itemid)
	local cardid = assert(request.cardid)
	local item,itemdb = player:getitem(itemid)
	if not item then
		net.msg.S2C.notify(player.pid,language.format("该物品不存在"))
		return
	end
	if item.cardid then
		net.msg.S2C.notify(player.pid,language.format("无法重复插入卡片"))
		return
	end

	local card,carddb = player:getitem(cardid)
	if not card then
		net.msg.S2C.notify(player.pid,language.format("卡片不存在"))
		return
	end
	local maintype1 = itemaux.getmaintype(item.type)
	if maintype1 ~= ItemMainType.EQUIP then
		net.msg.S2C.notify(player.pid,language.format("非装备无法插入卡片"))
		return
	end
	local maintype2 = itemaux.getmaintype(card.type)
	if maintype2 ~= ItemMainType.CARD then
		net.msg.S2C.notify(player.pid,language.format("插入的物品非卡片类型"))
		return
	end
	if not card.isopen then
		net.msg.S2C.notify(player.pid,language.format("该卡片尚未开启"))
		return
	end
	local itemdata1 = itemaux.getitemdata(item.type)
	local itemdata2 = itemaux.getitemdata(card.type)
	if itemdata1.equippos ~= itemdata2.equippos then
		net.msg.S2C.notify(player.pid,language.format("卡片和装备类型不相符"))
		return
	end
	local reason = string.format("insertcard#%d",card.id)
	logger.log("info","item",string.format("[insertcard] pid=%s itemid=%s cardid=%s",player.pid,itemid,cardid))
	item.cardid = card.id
	net.item.S2C.updateitem(player.pid,{
		id = item.id,
		cardid = card.id,
	})
end

function C2S.upgradecard(player,request)
	local cardid = assert(request.cardid)
	local card,carddb = player:getitem(cardid)
	if not card then
		net.msg.S2C.notify(player.pid,language.format("该卡片不存在"))
		return
	end
	local maintype = itemaux.getmaintype(card.type)
	if maintype ~= ItemMainType.CARD then
		net.msg.S2C.notify(player.pid,language.format("该物品不是卡片"))
		return
	end
	local itemdata = itemaux.getitemdata(card.type)

	-- 同类型卡片只有一张
	if card.num < itemdata.upgrade_neednum then
		net.msg.S2C.notify(player.pid,language.format("{1}数量不足#<R>{2}#个",itemaux.itemlink(itemtype),num))
		return
	end
	local leftnum = card.num - itemdata.upgrade_neednum + 1
	local nextlv = (card.lv or 1) + 1
	logger.log("info","item",string.format("[upgradecard] pid=%s itemid=%s nextlv=%s leftnum=%s",player.pid,card.id,nextlv,leftnum))
	carddb:update(card.id,{
		num = leftnum,
		lv = nextlv,
	})	
end

function C2S.opencard(player,request)
	local cardid = assert(request.cardid)
	local card,carddb = player:getitem(cardid)
	if not card then
		net.msg.S2C.notify(player.pid,language.format("该卡片不存在"))
		return
	end
	local maintype = itemaux.getmaintype(card.type)
	if maintype ~= ItemMainType.CARD then
		net.msg.S2C.notify(player.pid,language.format("该物品不是卡片"))
		return
	end
	carddb:opencard(cardid)
end

-- s2c
function S2C.additem(pid,item)
	sendpackage(pid,"item","additem",{
		item = item:pack(),
	})
end

function S2C.allitem(pid,items)
	local params = {}
	local itemlst = {}
	local num = 0
	local len = table.count(items)
	for _,item in pairs(items) do
		table.insert(itemlst,item:pack())
		num = num + 1
		if num % 50 == 0 or num == len then
			table.insert(params,{ items = itemlst })
			itemlst = {}
		end
	end
	for _,param in ipairs(params) do
		sendpackage(pid,"item","allitem",param)
	end
end

function S2C.delitem(pid,itemid)
	sendpackage(pid,"item","delitem",{
		id = itemid,
	})
end

function S2C.updateitem(pid,item)
	assert(item.id)
	sendpackage(pid,"item","updateitem",{
		item = item,
	})
end

return netitem
