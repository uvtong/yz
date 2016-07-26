netshop = netshop or {
	C2S = {},
	S2C = {},
}

local C2S = netshop.C2S
local S2C = netshop.S2C

function C2S.buygoods(player,request)
	local shopname = assert(request.shopname)
	local goods_id = assert(request.goods_id)
	local buynum = assert(request.num)
	local shop = player.shopdb[shopname]
	-- try get from global shop ?
	if shop and shop.buygoods then
		shop:buygoods(player,goods_id,buynum)
	end
end

function C2S.refresh(player,request)
	local shopname = assert(request.shopname)
	local shop = player.shopdb[shopname]
	if shop and shop.refresh then
		shop:refresh()
	end
	-- dosomething()
end

-- s2c

return netshop
