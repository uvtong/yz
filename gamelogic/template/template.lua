require "gamelogic.award.init"

ctemplate = class("ctemplate")

function ctemplate:init(conf)
	self.name = assert(conf.name)
	self.type = assert(conf.type)
	self.script_handle = {
		talkto = true,
		addnpc = true,
		delnpc = true,
		raisewar = true,
	}
end

function ctemplate:loadres(playunit,data)
	if not playunit.resourcemgr then
		local resmgr = cresourcemgr.new(self,playunit)
		playunit.resourcemgr = resmgr
	end
	playunit.resourcemgr:load(data)
end

function ctemplate:saveres(playunit)
	if not playunit.resourcemgr then
		return
	end
	return playunit.resourcemgr:save()
end

function ctemplate:doscript(playunit,script,pid,...)
	local cmd = script.cmd
	local args = script.args
	if self.script_handle[cmd] then
		local func = self[cmd]
		if func ~= nil and type(func) == "function" then
			return func(self,playunit,args,pid,...)
		end
	end
	return self:customexec(playunit,cmd,args,pid,...)
end

function ctemplate:getnpc(playunit,npcid)
	local npc = playunit.resourcemgr.npclist[npcid]
	if not npc then
		npc = data_0601_NPC[npcid]
	end
	return npc
end

function ctemplate:getnpc_bynid(playunit,nid)
	for _,npc in pairs(playunit.resourcemgr.npclist) do
		if npc.nid == nid then
			return npc
		end
	end
	return data_0601_NPC[nid]
end

function ctemplate:createscene(playunit,mapid)
	local scene = playunit.resourcemgr:addscene(mapid)
	scene = self.transscene(playunit,scene)
	return scene
end

function ctemplate:createnpc(playunit,nid)
	local npcdata = self:getformdata("npc")[nid]
	local newnpc = {
		nid = nid,
		type = npcdata.type,
		name = npcdata.name,
		mapid = npcdata.mapid,
		pos = npcdata.pos,
		isclient = npcdata.isclient,
	}
	newnpc = self:transnpc(playunit,newnpc)
	playunit.resourcemgr:addnpc(newnpc)
	return newnpc
end

function ctemplate:isnearby(player,npc,dis)
	if player.testman then
		return true
	end
	if not player or not npc then
		return false
	end
	dis = dis or MAX_NEAR_DISTANCE
	if dis ~= "ignore" and getdistance(player.pos,npc.pos) > dis then
		return false
	end
	return true
end

function ctemplate:raisepvpwar(playunit,pid,target)
end

--<<  可重写方法  >>
function ctemplate:getformdata(formname)
end

function ctemplate:transnpc(playunit,npc)
	return npc
end

function ctemplate:transscene(playunit,scene)
	return scene
end

function ctemplate:transwar(playunit,war,attackers,defensers)
	return war,attackers,defensers
end

function ctemplate:customexec(playunit,sc,arg,pid)
	self:log("err","err",string.format("unsc,script=%s pid=%d",sc,pid))
end

function ctemplate:transtext(text,pid)
	return text
end

function ctemplate:transcode(value,pid)
	if type(value) ~= "string" then
		return value
	end
	return value
end

function ctemplate:getfakedata(fakeid,faketype)
	local fakedata = self:getformdata("fake")[fakeid]
	if not fakedata then
		return
	end
	return fakedata[faketype]
end

function ctemplate:onwarend(warid,result)
end


--<<  脚本方法  >>
function ctemplate:talkto(playunit,args,pid)
	local nid = args.nid
	local textid = args.textid
	local npc = self:getnpc_bynid(playunit,nid)
	local text = self:getformdata("text")[textid]
	text = self:transtext(text,pid,npc)
	net.msg.S2C.npcsay(pid,npc,text)
end

function ctemplate:addnpc(playunit,args)
	local nid = args.nid
	local npc = self:createnpc(playunit,nid)
	if not npc.isclient then
		playunit.resourcemgr:enterscene(newnpc)
	end
end

function ctemplate:delnpc(playunit,args)
	local nid = args.nid
	local npc = self:getnpc_bynid(playunit,nid)
	if npc then
		playunit.resourcemgr:delnpc(npc)
	end
end

function ctemplate:raisewar(playunit,args,pid)
	local warid = args.warid
	if warid < 0 then
		warid = self:getfakedata(-warid,"war")
	end
	local war = {
		wardataid = warid,
		attack_helpers = {},
		defense_helpers = {},
	}
	local attackers = {pid,}
	local defensers = {}
	local player = playermgr.getplayer(pid)
	if player:teamstate() == TEAM_STATE_CAPTAIN then
		local team = teammgr.getteam(player.teamid)
		table.extend(attackers,team.members())
	end
	war,attackers,defensers = self:transwar(playunit,war,attackers,defensers)
	warmgr.startwar(attackers,defensers,war)
end


function ctemplate:doaward(awardid,pid)
	if type(awardid) == "table" then
		awardid = choosekey(awardid)
	end
	local award = nil
	if awardid < 0 then
		award = self:getfakedata(-awardid,"award")
	else
		award = self:getformdata("award")[awardid]
	end
	award = deepcopy(award)
	for res,value in pairs(award) do
		value = self:transcode(value,pid)
		award[res] = value
	end
	self:log("info","award",string.format("tplaward,pid=%d,rid=%d",pid,awardid))
	--doaward("player",pid,award,string.format("%s.template",self.name))
end

function ctemplate:release(playunit)
	if not playunit.resourcemgr then
		return
	end
	playunit.resourcemgr:release()
end

function ctemplate:log(levelmode,filename,...)
	local msg = table.concat({...},"\t")
	msg = string.format("[%s] %s",self.name,msg)
	logger.log(levelmode,filename,msg)
end

return ctemplate
