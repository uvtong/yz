ccarddb = class("ccarddb",citemdb)

function ccarddb:init(conf)
	citemdb.init(self,conf)
	self.opencards = {}			-- 开启的卡片
end

function ccarddb:load(data)
	citemdb.load(self,data)
	for id,card in pairs(self.objs) do
		if card.isopen then
			self.opencards[id] = true
		end
	end
end

function ccarddb:addcardbytype(cardtype,num,reason)
	self:additembytype(cardtype,num,nil,reason)
end

ccarddb.costcardbytype = ccarddb.costitembytype
ccarddb.costcardbyid = ccarddb.costitembyid
ccarddb.addcardbyid = ccarddb.additembyid
ccarddb.getcard = ccarddb.getitem

function ccarddb:getcardbytype(cardtype)
	local items = self:getitemsbytype(cardtype)
	if next(items) then
		assert(#items == 1)
		return items[1]
	end
	return nil
end

-- 卡片获取后就永不删除，即使数量变成0也不删除
function ccarddb:delitem(itemid,reason)
end

-- 开启一个卡片(开启后就永久开启，无法取消开启）
function ccarddb:opencard(cardid)
	local card = self:getcard(cardid)
	if not card then
		return
	end
	logger.log("info","item",string.format("[opencard] pid=%s itemid=%s",player.pid,card.id))
	self:update(card.id,{
		isopen = true,
	})
	self.opencards[card.id] = true
end

return ccarddb