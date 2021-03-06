-- 玩家辅助函数
playeraux = {}


function playeraux.getmaxlv()
	local openday = globalmgr.server:getopenday()
	local srvinfo = data_SrvLv[openday]
	if not srvinfo then
		return data_GlobalVar.MaxLv
	end
	return srvinfo.maxlv
end

function playeraux.getmaxexp(lv)
	local data = data_1001_LvExp[lv]
	return data.sumexp
end

function playeraux.getmaxjobzs()
	return data_GlobalVar.MaxJobZs
end

function playeraux.getmaxjoblv(zs)
	local maxlv = playeraux.getmaxlv()
	local attr = string.format("jobzs%d_sumexp",zs)
	local maxjoblv_attr = string.format("jobzs%d_maxjoblv",zs)
	if not playeraux[maxjoblv_attr] then
		local maxjoblv = 0
		for lv=1,maxlv do
			local data = data_1001_LvExp[lv]
			local val = data[attr]
			maxjoblv = maxjoblv + 1
			if val == 0 then
				break
			end
		end
		playeraux[maxjoblv_attr] = maxjoblv
	end
	return playeraux[maxjoblv_attr]
end

function playeraux.getmaxjobexp(zs,joblv)
	local data = data_1001_LvExp[joblv]
	local attr = string.format("jobzs%d_sumexp",zs)
	return data[attr]
end

function playeraux.isopen(lv,name)
	local data = data_FunctionOpen[name]
	if not data then
		return false
	end
	if lv < data.open_level then
		return false,data
	end
	return true
end

function playeraux.getlanguage(pid)
	local player = playermgr.getplayer(pid)
	if player then
		return player:getlanguage()
	end
	-- 可能传入的是：连线对象的pid
	local resume = resumemgr.getresume(pid)
	if not resume then
		return language.language_to
	end
	return resume:get("lang") or language.language_to
end

return playeraux
