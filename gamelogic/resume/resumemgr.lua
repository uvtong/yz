
resumemgr = resumemgr or {}

function resumemgr.init()
	resumemgr.objs = {}
end

function resumemgr.create(pid,data)
	local resume = cresume.new(pid)
	resume:create(data)
	return resume
end

function resumemgr.onlogin(player)
	local pid = player.pid
	local resume = resumemgr.getresume(pid)
	local data = player:packresume()
	data.now_srvname = cserver.getsrvname()
	data.online = true
	resume:set(data)
end

function resumemgr.onlogoff(player,reason)
	local pid = player.pid
	local resume = resumemgr.getresume(pid)
	local data = player:packresume()
	data.now_srvname = cserver.getsrvname()
	data.online = false
	data.logofftime = os.time()
	resume:set(data)
end

function resumemgr.push(pid,data)
	local resume = resumemgr.getresume(pid)
	resume:set(data)
end

function resumemgr.get(pid,attr)
	local player = playermgr.getplayer(pid)
	if player then
		return player[attr]
	end
	local resume = resumemgr.getresume(pid)
	return resume:get(attr)
end

function resumemgr.loadresume(pid)
	local resume = cresume.new(pid)
	resume:loadfromdatabase()
	return resume
end

function resumemgr.getresume(pid)
	if not resumemgr.objs[pid] then
		local resume = cresume.new(pid)
		resume.waitloaded = {}
		resumemgr.objs[pid] = resume
		-- may block
		pcall(resume.loadfromdatabase,resume)
		local waitloaded = resume.waitloaded
		resume.waitloaded = nil
		resumemgr.objs[pid] = nil
		if resume.loadstate == "loaded" then
			resumemgr.addresume(pid,resume)
		end
		if waitloaded and next(waitloaded) then
			for i,co in ipairs(waitloaded) do
				skynet.wakeup(co)
			end
		end
	end
	local resume = resumemgr.objs[pid]
	if resume and resume.waitloaded then
		local co = coroutine.running()
		table.insert(resume.waitloaded,co)
		skynet.wait(co)
	end
	if resume and resume.loadstate == "loaded" then
		return resume
	else
		-- resume non exist
		return
	end
end

-- 恢复数据中心玩家简介的服务器引用
function resumemgr.recover_refs()
	local pids = table.keys(resumemgr.objs)
	if not table.isempty(pids) then
		skynet.fork(pcall,rpc.call,cserver.datacenter(),"resumemgr","recover",pids)
	end
end

function resumemgr.addresume(pid,resume)
	logger.log("info","resume",format("[addresume] pid=%d resume=%s",pid,resume:save()))
	resumemgr.objs[pid] = resume
	resume.savename = string.format("%s.%s",resume.flag,resume.pid)
	autosave(resume)
end

function resumemgr.delresume(pid)
	local resume = resumemgr.objs[pid]
	if resume then
		logger.log("info","resume",format("[delresume] pid=%d",pid))
		resumemgr.objs[pid] = nil
		closesave(resume)
		resume:savetodatabase()
		local srvname = cserver.getsrvname()
		if cserver.isdatacenter(srvname) then
		else
			rpc.pcall(cserver.datacenter(),"resumemgr","delref",pid)
		end
	end
end


-- request
local CMD = {}
-- gamesrv --> datacenter
function CMD.query(srvname,pid,key)
	local resume = resumemgr.getresume(pid)
	if not resume then
		logger.log("warning","resume",string.format("[no resume] [query] srvname=%s pid=%s key=%s",srvname,pid,key))
		return
	end
	resume:addref(srvname)
	local data = {}
	if key == "*" then
		data = resume:save()
	else
		data[key] = resume:query(key)
	end
	logger.log("debug","resume",format("[query] srvname=%s pid=%d key=%s data=%s",srvname,pid,key,data))
	return data
end

-- gamesrv -> datacenter
function CMD.delref(srvname,pid)
	logger.log("debug","resume",string.format("[delref] srvname=%s pid=%d",srvname,pid))
	local resume = resumemgr.getresume(pid)
	if not resume then
		return
	end
	resume:delref(srvname)
end

-- gamesrv -> datacenter
function CMD.create(srvname,pid,data)
	data.pid = pid
	resumemgr.create(pid,data)
end

-- datacenter <-> gamesrv
-- 增量同步
function CMD.sync(srvname,pid,data)
	logger.log("debug","resume",format("[sync] srvname=%s pid=%d data=%s",srvname,pid,data))
	data.pid = pid
	local resume = resumemgr.getresume(pid)
	if not resume then
		return
	end
	resume:set(data,true)
	if cserver.isdatacenter() then
		-- syncto gamesrv
		for srvname2,_ in pairs(resume.srvname_ref) do
			if srvname2 ~= srvname then
				-- 防止部分服断开连接后影响其他服的同步
				-- 服务器断开连接的情况可能有： 1. 停服了 2. 网络不好
				if clustermgr.isconnect(srvname2) then
					skynet.fork(rpc.pcall,srvname2,"resumemgr","sync",resume.pid,data)
				end
			end
		end
	end
end

function CMD.delete(srvname,pid)
	logger.log("debug","resume",string.format("[delete] srvname=%s pid=%d",srvname,pid))
	local resume = resumemgr.getresume(pid)
	if resume then
		resumemgr.delresume(pid)
		resume:deletefromdatabase()
	end
end

-- gamesrv -> datacenter
function CMD.recover(srvname,pids)
	logger.log("debug","resume",string.format("[recover] srvname=%s pidcnt=%d",srvname,#pids))
	for _,pid in ipairs(pids) do
		local resume = resumemgr.getresume(pid)
		if resume then
			resume:addref(srvname)
		end
	end
end

function resumemgr.dispatch(srvname,cmd,...)
	assert(type(srvname)=="string","Invalid srvname:" .. tostring(srvname))
	local func = assert(CMD[cmd],"Unknow cmd:" .. tostring(cmd))
	return func(srvname,...)
end

return resumemgr

