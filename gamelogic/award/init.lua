
--[[
奖励项格式：
{
	gold = 金币,
	silver = 银币,
	coin = 铜钱,
	items = {
		物品类型,
		...
	},
	pets = {
		宠物类型,
		...
	},
}
]]

award = award or {}
function award.orgaward(orgid,reward)
end

local BASE_RATIO = BASE_RATIO or 1000000
function award.__player(pid,bonus,reason,btip)
	local player = playermgr.getplayer(pid)
	if player then
		local has_lackbonus = false
		local lackbonus = {
		}
		for id,name in pairs(RESTYPE) do -- RESTYPE
			if type(name) == "string" then
				name = string.lower(name)
				local resnum = bonus[name]
				if resnum and resnum > 0 then
					local hasbonus_num = player:addres(name,resnum,reason,btip)
					if resnum - hasbonus_num > 0 then
						lackbonus[name] = resnum - hasbonus_num
					end
				end
			end
		end
		if not table.isempty(bonus.items) then
			lackbonus.items = {}
			for i,item in ipairs(bonus.items) do
				item = deepcopy(item)
				local itemdb = player:getitemdb(item.type)
				local hasbonus_num = itemdb:additem2(item,reason)
				if btip and hasbonus_num > 0 then
					local itemdata = itemaux.getitemdata(item.type)
					net.msg.S2C.notify(pid,language.format("获得 #<II{1}># #<O>【{2}】+{3}#",item.type,itemdata.name,hasbonus_num))
				end
				item.num = item.num - hasbonus_num
				if item.num > 0 then
					has_lackbonus = true
					table.insert(lackbonus.items,item)
				end
			end
		end
		if not table.isempty(bonus.pets) then
			lackbonus.pets = {}
			for i,pet in ipairs(bonus.pets) do
				pet = deepcopy(pet)
				-- dosomething
			end
		end
		if has_lackbonus and not table.isempty(lackbonus) then
			return lackbonus
		else
			return {}
		end
	else
		return deepcopy(bonus)
	end
end

function award.player(pid,bonus,reason,btip)
	local lackbonus = award.__player(pid,bonus,reason,btip)
	-- 1.玩家不在线，2.由于背包不足/资源过剩没有加到的资源/物品,需要发邮件
	if not table.isempty(lackbonus) then
		local attach = lackbonus
		mailmgr.sendmail(pid,{
			srcid = SYSTEM_MAIL,
			author = language.format("系统"),
			title = language.format("奖励"),
			content = language.format("奖励"),
			attach = attach,
		})
	end
end

function award.org(orgid,bonus,reason,btip)
end

function award.mergebonus(bonuss)
	local merge_bonus = {
		exp = 0,
		jobexp = 0,
		gold = 0,
		silver = 0,
		coin = 0,
		union_offer = 0,
		union_money = 0,
		items = {},
		pets = {}
	}
	for i,bonus in ipairs(bonuss) do
		merge_bonus.exp = merge_bonus.gold + (bonus.exp or 0)
		merge_bonus.jobexp = merge_bonus.jobexp + (bonus.jobexp or 0)
		merge_bonus.gold = merge_bonus.gold + (bonus.gold or 0)
		merge_bonus.silver = merge_bonus.silver + (bonus.silver or 0)
		merge_bonus.coin = merge_bonus.coin + (bonus.coin or 0)
		merge_bonus.union_offer = merge_bonus.union_offer + (bonus.union_offer or 0 )
		merge_bonus.union_money = merge_bonus.union_money + (bonus.union_money or 0)
		if not table.isempty(bonus.items) then
			table.extend(merge_bonus.items,bonus.items)
		end
		if not table.isempty(bonus.pets) then
			table.extend(merge_bonus.pets,bonus.pets)
		end
	end
	return merge_bonus
end

-- rewards: 奖励控制表
function award.getaward(formdata,bonusid,func)
	local final_bonuss = {}
	local bonuss = formdata[bonusid].awardtable
	local ratiotype = formdata[bonusid].ratiotype
	if ratiotype == 1 then -- 独立概率
		for i,bonus in ipairs(bonuss) do
			local ratio = func and func(i,bonus) or bonus.ratio
			assert(ratio)
			if ishit(ratio,BASE_RATIO) then
				table.insert(final_bonuss,bonus)
			end
		end
	else
		assert(ratiotype == 2)
		local id = choosekey(bonuss,function (i,bonus)
			return func and func(i,bonus) or bonus.ratio
		end)
		local bonus = bonuss[id]
		table.insert(final_bonuss,bonus)
	end
	return final_bonuss
end

function doaward(typ,id,reward,reason,btip)
	local func = assert(award[typ],"Invalid type:" .. tostring(typ))
	if table.isarray(reward) then
		reward = award.mergebonus(reward)
	end
	local srvname = getsrvname(typ,id)
	logger.log("info","award",format("[doaward] srvname=%s typ=%s id=%d reward=%s reason=%s btip=%s",srvname,typ,id,reward,reason,btip))
	return func(id,reward,reason,btip)
end

function getsrvname(typ,id)
	if typ == "player" then
		return globalmgr.home_srvname(id)
	elseif typ == "org" then
		-- TODO:
	end
end

function isres(typ)
	return data_GameID.resource.startid <= typ and typ < data_GameID.resource.endid
end

function isitem(typ)
	return data_GameID.item.startid <= typ and typ < data_GameID.item.endid
end

-- just for test
function getawarddata(awardid)
	local data = data_TemplAward[awardid]
	if data then
		return data.award
	end
end

return award
