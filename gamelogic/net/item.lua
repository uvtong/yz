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
	local target = nil
	if targetid then
		target = player:gettarget(targetid)
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
	local maintype = itemaux.getmaintype(item.type)
	if maintype == ItemMainType.CARD then  -- 卡片卖银币，而且跟卡片等级有关
		local lv = item.lv or 1
		local lv_attr = itemdata.lv_attr[lv]
		local addsilver = lv_attr.silver_price * num
		player:addsilver(addsilver,reason)
	else
		local addcoin = itemdata.coin_price * num
		player:addcoin(addcoin,reason)
	end
end

function netitem.produceequip(player,itemtype)
	local itemdb = player:getitemdb(itemtype)
	local freepos = itemdb:getfreepos()
	if not freepos then
		net.msg.S2C.notify(player.pid,language.format("背包栏不足"))
		return
	end
	local itemdata = itemaux.getitemdata(itemtype)
	if itemdata.lv < 10 then
		net.msg.S2C.notify(player.pid,language.format("只能打造10级或以上装备"))
		return
	end
	local costitem = itemdata.produce_costitem
	local costcoin = itemdata.produce_costcoin
	for itemtype,num in pairs(costitem) do
		if data_0501_ItemSet[itemtype] then
			itemtype = data_0501_ItemSet[itemtype].items[player.roletype]
			-- 特定职业无法打造该物品
			if not itemtype then
				net.msg.S2C.notify(player.pid,language.format("你的职业无法打造该装备"))
				return
			end
		end
		-- 材料和装备一定是在同一个背包中!
		if num ~= 0 and itemdb:getnumbytype(itemtype) < num then

			net.msg.S2C.notify(player.pid,language.format("{1}数量不足#<R>{2}#个",itemaux.itemlink(itemtype),num))
			return
		end
	end
	if not player:validpay("coin",costcoin,true) then
		return
	end

	local reason = string.format("produceequip:%s",itemtype)
	for itemtype,num in pairs(costitem) do
		if data_0501_ItemSet[itemtype] then
			itemtype = data_0501_ItemSet[itemtype].items[player.roletype]
		end
		itemdb:costitembytype(itemtype,num,reason)
	end
	if costcoin > 0 then
		player:addcoin(-costcoin,reason)
	end
	local item = itemdb:newitem({
		type = itemtype,
		num = 1,
	})
	itemdb:additem(item,reason)
	openui.produceequip_succ(player.pid,item.id)
end


function C2S.produceitem(player,request)
	local itemtype = assert(request.itemtype)
	local num = request.num or 1
	local maintype = itemaux.getmaintype(itemtype)
	if maintype == ItemMainType.EQUIP then
		net.item.produceequip(player,itemtype)
	end
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
	player:additembytype(item.type,item.num,item.bind,"pickitem",true)
end

local function can_replacefumo(from_item,to_item,player,attrtype)
	if not from_item or not to_item then
		return false,language.format("物品不存在")
	end
	local from_maintype = itemaux.getmaintype(from_item.type)
	local to_maintype = itemaux.getmaintype(to_item.type)
	if from_maintype ~= to_maintype then
		return false,language.format("同类型装备才能顶替附魔属性")
	end
	if from_maintype ~= ItemMainType.EQUIP then
		return false,language.format("非装备无法顶替附魔属性")
	end
	local from_equiplv = from_item:get("lv")
	local to_equiplv = to_item:get("lv")
	if from_equiplv > to_equiplv then
		return false,language.format("高级装备无法顶替低级装备的附魔属性")
	end
	local from_attr = from_item.fumo[attrtype]
	if not from_attr then
		return false,language.format("该属性不存在")
	end
	local to_attr = to_item.fumo[attrtype]
	if not to_attr then
		return false,language.format("目标装备没有该附魔属性")
	end
	if to_attr >= from_attr then
		return false,language.format("无法顶替优质属性")
	end
	return true
end

-- 顶替附魔属性：丢弃一件低级装备，将一条"高附魔"属性顶替另一件同类型的高级装备
function C2S.replacefumo(player,request)
	local from_itemid = assert(request.from_itemid)
	local to_itemid = assert(request.to_itemid)
	local attrtype = assert(request.attrtype)
	local from_item = player:getitem(from_itemid)
	local to_item,itemdb = player:getitem(to_itemid)
	local isok,msg  = can_replacefumo(from_item,to_item,player,attrtype)
	sendpackage(player.pid,"item","replacefumo_res",{ result = isok, })
	if not isok then
		if msg then
			net.msg.S2C.notify(player.pid,msg)
		end
		return
	end
	local from_attr = from_item.fumo[attrtype]
	local reason = string.format("replacefumo:%s->%s@%s",from_itemid,to_itemid,attrtype)
	itemdb:delitem(from_itemid,reason)
	to_item.fumo[attrtype] = from_attr
	itemdb:update(to_itemid,{
		fumo = to_item.fumo,
	})
	net.msg.S2C.notify(player.pid,language.format("顶替附魔成功"))
end

-- 精炼：现在已经跟格子，但策划要求精炼必须通过佩戴的装备进行
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
	if item.pos ~= item:get("equippos") then
		net.msg.S2C.notify(player.pid,language.format("只能精炼已佩戴的装备"))
		return
	end
	local equippos = player.equipposdb:get(item:get("equippos"))
	if not equippos then
		net.msg.S2C.notify(player.pid,language.format("非法装备格"))
		return
	end
	local cnt = equippos.refine.cnt or 0
	if cnt >= equiplv + 9 then
		net.msg.S2C.notify(player.pid,language.format("精炼次数已超过装备等级+9"))
		return
	end
	local itemdata = itemaux.getitemdata(item.type)
	if item.pos ~= itemdata.equippos then
		net.msg.S2C.notify(player.pid,language.format("只有装备的物品才能精炼"))
		return
	end
	player.equipposdb:refine(item.pos)
end

function C2S.insertcard(player,request)
	local itemid = assert(request.itemid)
	local cardid = assert(request.cardid)
	local item,itemdb = player:getitem(itemid)
	if not item then
		net.msg.S2C.notify(player.pid,language.format("该物品不存在"))
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
	if item.pos ~= item:get("equippos") then
		net.msg.S2C.notify(player.pid,language.format("只能插入卡片到已佩戴的装备"))
		return
	end
	local equippos = player.equipposdb:get(item:get("equippos"))
	if not equippos then
		net.msg.S2C.notify(player.pid,language.format("非法装备格"))
		return
	end
	local maintype2 = itemaux.getmaintype(card.type)
	if maintype2 ~= ItemMainType.CARD then
		net.msg.S2C.notify(player.pid,language.format("插入的物品非卡片类型"))
		return
	end
	local itemdata1 = itemaux.getitemdata(item.type)
	local itemdata2 = itemaux.getitemdata(card.type)
	if itemdata1.equippos ~= itemdata2.equippos then
		net.msg.S2C.notify(player.pid,language.format("卡片和装备类型不相符"))
		return
	end
	local reason = string.format("insertcard#%d",card.id)
	logger.log("info","item",string.format("[insertcard] pid=%s itemid=%s cardid=%s pos=%s",player.pid,itemid,cardid,item.pos))
	player.equipposdb:update(equippos.id,{
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
	local nextlv = (card.lv or 0) + 1
	local lv_attr = itemdata.lv_attr[nextlv]
	if not lv_attr then
		net.msg.S2C.notify(player.pid,language.format("无法继续升级了"))
		return
	end

	-- 同类型卡片只有一张
	if card.num < lv_attr.upgrade_neednum then
		net.msg.S2C.notify(player.pid,language.format("{1}数量不足#<R>{2}#个",itemaux.itemlink(card.type),lv_attr.upgrade_neednum))
		return
	end
	local leftnum = card.num - lv_attr.upgrade_neednum
	logger.log("info","item",string.format("[upgradecard] pid=%s itemid=%s nextlv=%s leftnum=%s",player.pid,card.id,nextlv,leftnum))
	carddb:update(card.id,{
		num = leftnum,
		lv = nextlv,
	})	
end

-- 排序背包(不是整理，现在已经废除服务端整理，服务端只记录排序方式，排序由客户端做)
function C2S.sortbag(player,request)
	local bagtype = assert(request.bagtype)
	local sorttype = assert(request.sorttype)
	local itemdb = player:getitembag(bagtype)
	itemdb.sorttype =  sorttype
	net.item.S2C.bag(player.pid,{
		type = itemdb.type,
		space = itemdb:getspace(),
		sorttype = itemdb.sorttype,
		beginpos = itemdb.beginpos,
	})
	net.msg.S2C.notify(player.pid,language.format("整理完毕"))
end

function C2S.expandspace(player,request)
	local bagtype = assert(request.bagtype)
	local itemdb = player:getitembag(bagtype)
	local maxspace = data_0801_PromoteEquipVar.ItemBagMaxSpace
	local addspace = data_0801_PromoteEquipVar.ItemBagExpandSpacePerTime
	local nowspace = itemdb:getspace()
	if nowspace >= maxspace then
		net.msg.S2C.notify(player.pid,language.format("扩展的背包已达到上限"))
		return
	end
	local nextrow = math.floor(nowspace / addspace) + 1
	local costgold = data_0801_ItemBagExpand[nextrow].gold
	if not player:validpay("gold",costgold,true) then
		return
	end
	--保证扩展后，总尺寸是addspace的整倍数
	addspace = addspace - (nowspace % addspace)
	player:addgold(-costgold,"expandspace")
	itemdb:expand(addspace,"costgold")
end

function C2S.cancel_baotu(player,request)
	local typ = assert(request.type)
	huodongmgr.playunit.baotu.cancel(player,typ)
end

function C2S.takeout_card(player,request)
	local pos = assert(request.pos)
	local equippos = player.equipposdb:get(pos)
	if not equippos then
		net.msg.S2C.notify(player.pid,language.format("非法装备格"))
		return
	end
	if not equippos.cardid then
		return
	end
	player.equipposdb:update(equippos.id,{
		cardid = 0,
	})
end

-- s2c
function S2C.additem(pid,item,typ)
	sendpackage(pid,"item","additem",{
		item = item:pack(),
		type = typ,
	})
end

function S2C.allitem(pid,type,items)
	local params = {}
	local itemlst = {}
	local num = 0
	local len = table.count(items)
	for _,item in pairs(items) do
		table.insert(itemlst,item:pack())
		num = num + 1
		if num % 50 == 0 or num == len then
			table.insert(params,{ 
				type = type,
				items = itemlst
			})
			itemlst = {}
		end
	end
	for _,param in ipairs(params) do
		sendpackage(pid,"item","allitem",param)
	end
	-- 方便客户端
	sendpackage(pid,"item","allitem_end",{type=type})
end

function S2C.delitem(pid,itemid,typ)
	sendpackage(pid,"item","delitem",{
		id = itemid,
		type = typ,
	})
end

function S2C.updateitem(pid,item,typ)
	assert(item.id)
	sendpackage(pid,"item","updateitem",{
		item = item,
		type = typ,
	})
end

-- 背包基本信息(全量更新)
function S2C.bag(pid,bag)
	sendpackage(pid,"item","bag",bag)
end

return netitem
