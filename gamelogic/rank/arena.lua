-- 竞技场（比武)
carenarank = class("carenarank")

function carenarank:init()
	self.ranks = {}
	for lv,data in pairs(data_1100_ArenaRank) do
		local name = string.format("arena#%s",lv)
		local ranks = cranks.new(name,{"pid",},{"score",},{desc=true})
		ranks.lv = lv
		self.ranks[lv] = ranks
	end
	self.loadstate = "unload"
	self.savename = "rank:arena"
	autosave(self)
end

function carenarank:clear()
	logger.log("info","arena","clear")
	for i,ranks in ipairs(self.ranks) do
		ranks:clear()
	end
end

function carenarank:loadfromdatabase()
	if self.loadstate ~= "unload" then
		return
	end
	self.loadstate = "loading"
	local db = dbmgr.getdb()
	for lv in pairs(data_1100_ArenaRank) do
		local data = db:get(db:key("rank","arena",lv))
		local ranks = self.ranks[lv]
		ranks:load(data)
	end
	self.loadstate = "loaded"
end

function carenarank:savetodatabase()
	if not cserver.isgamesrv() then
		return
	end
	if self.loadstate ~= "loaded" then
		return
	end
	local db = dbmgr.getdb()
	for lv in pairs(data_1100_ArenaRank) do
		local ranks = self.ranks[lv]
		local data = ranks:save()
		db:set(db:key("rank","arena",lv),data)
	end
end

function carenarank:onlogin(player)
end

function carenarank:onlogoff(player,reason)
end

function carenarank:onfivehourupdate()
	local weekday = getweekday()
	if weekday == 1 then
		-- dosomething
		self:clear()
	end
end

function carenarank:get(pid)
	for i,ranks in ipairs(self.ranks) do
		local rank = ranks:get(pid)
		if rank then
			return rank,ranks
		end
	end
end

function carenarank:addscore(pid,score)
	local rank,ranks = self:get(pid)
	if not rank then
		local maxlv = #data_1100_ArenaRank
		ranks = self.ranks[maxlv]
		rank = ranks:add({
			pid = pid,
			score = 0,
		})
	end
	local new_score = math.max(0,rank.score + score)
	local pre_lv
	for lv=ranks.lv-1,1,-1 do
		local rankdata = self:getrankdata(lv)
		if new_score >= rankdata.score then
			pre_lv = lv
		end
	end
	print(pid,new_score,pre_lv)
	if pre_lv then
		local pre_ranks = self.ranks[pre_lv]
		logger.log("info","arena",string.format("[deladd] pid=%s lv=%s->%s score=+%s->%s",pid,ranks.lv,pre_ranks.lv,score,new_score))
		rank.score = new_score
		ranks:del(pid)
		pre_ranks:add(rank)
	else
		logger.log("info","arena",string.format("[update] pid=%s lv=%s score=+%s->%s",pid,ranks.lv,score,new_score))
		ranks:update({
			pid = pid,
			score = new_score,
		})
	end
end

function carenarank:refresh_opponents(player)
	local pid = player.pid
	local old_opponents = player:query("arena.opponents") or {}
	local rank,ranks = self:get(pid)
	local hitpids = {}
	local lv = ranks.lv
	local pos_step = 0
	local lv_step = 0
	while #hitpids < 5 do
		pos_step = pos_step + 1
		local front_rank = ranks:getbypos(rank.pos+pos_step)
		if front_rank and not table.find(old_opponents,front_rank.pid) then
			table.insert(hitpids,front_rank.pid)
		end
		local behind_rank  = ranks:getbypos(rank.pos-pos_step)
		if behind_rank and not table.find(old_opponents,behind_rank.pid) then
			table.insert(hitpids,behind_rank.pid)
		end
		--print(lv_step,rank.pos,pos_step,front_rank,behind_rank)
		if not front_rank and not behind_rank then
			lv_step = lv_step + 1
			ranks = self.ranks[lv+lv_step] or self.ranks[lv-lv_step]
			if not ranks then
				break
			end
		end
	end
	player:set("arena.opponents",hitpids)
end

function carenarank:pk(player,targetid)
	local pid = player.pid
	local fighters,errmsg = player:getfighters()
	if not fighters then
		net.msg.S2C.notify(pid,errmsg)
		return
	end
	if #fighters > 1 then
		net.msg.S2C.notify(pid,language.format("组队状态下无法和对手PK"))
		return
	end
	local old_opponents = player:query("arena.opponents") or {}
	if not table.find(old_opponents,targetid) then
		net.msg.S2C.notify(pid,language.format("对手不在你的匹配列表中"))
		return
	end
	local opponent = self:get(targetid)
	if not opponent then
		net.msg.S2C.notify(pid,language.format("对手不存在"))
		return
	end
	if opponent.warid then
		net.msg.S2C.notify(pid,language.format("对手正在战斗中"))
		return
	end
	warmgr.startwar({
		attackers = fighters,
		defensers = {targetid},
		wartype = PVP_ARENA_RANK,
	})
end

function carenarank:onwarend(war,result)
	if warmgr.iswin(result) then
		for i,pid in ipairs(war.attackers) do
			self:addscore(pid,10)
		end
		for i,pid in ipairs(war.defensers) do
			self:addscore(pid,-10)
		end
	elseif warmgr.islose(result) then
		for i,pid in ipairs(war.attackers) do
			self:addscore(pid,-10)
		end
		for i,pid in pairs(war.defensers) do
			self:addscore(pid,10)
		end
	else
		for i,pid in ipairs(war.attackers) do
			self:addscore(pid,5)
		end
		for i,pid in pairs(war.defensers) do
			self:addscore(pid,5)
		end
	end
end

function carenarank:getrankdata(lv)
	return data_1100_ArenaRank[lv]
end

return carenarank
