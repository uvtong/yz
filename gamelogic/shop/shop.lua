cshop = class("cshop",ccontainer)

-- conf: {pid=xxx,name=xxx}
function cshop:init(conf)
	ccontainer.init(self,conf)
	self.restype = conf.restype
end

-- 生成商品
-- 商品格式:{id=商品ID,itemtype=物品类型,num=单次购买的数量,price=单个商品价格,sumnum=总存量,restype=资源类型,bind=物品是否绑定}
-- 总存量sumnum < 0 表示该商品库存量无限
function cshop:gen_goods(goodslst)
	for i,goods in ipairs(goodslst) do
		assert(goods.itemtype)
		assert(goods.price)
		assert(goods.num)
		goods.sumnum = goods.sumnum or goods.num
		goods.leftnum = goods.leftnum or goods.sumnum
		local id = goods.id or i
		self:add(goods,id)
	end
end

function cshop:buy(player,goods_id,buynum)
	local goods = self:get(goods_id)
	if not goods then
		return false,language.format("非法商品ID")
	end
	buynum = buynum or goods.num
	assert(buynum > 0)
	if goods.sumnum >= 0 and buynum > goods.leftnum then
		return false,language.format("商品存量不足{1}个",buynum)
	end
	if buynum % goods.num ~= 0 then
		return false,language.format("该商品单次出售数量为{1}个",goods.num)
	end
	local restype = goods.restype or self.restype
	assert(restype)
	local costnum = buynum * goods.price
	if not player:validpay(restype,costnum) then
		local resname = getresname(restype)
		return false,language.format("{1}不足{2}",resname,costnum)
	end
	local resaon = string.format("shop_%s.buy",self.name)
	if goods.sumnum >= 0 then
		self:update(goods.id,{
			leftnum = goods.leftnum - buynum,
		})
	end
	player:addres(restype,-costnum,reason)
	player:additembytype(goods.itemtype,goods.num,goods.bind,reason)
	return true
end

return cshop