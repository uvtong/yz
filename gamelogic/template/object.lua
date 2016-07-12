require "gamelogic.base.class"
require "gamelogic.base.databaseable"

local cresourcemgr = class("cresourcemgr",cdatabaseable)

function cresourcemgr:init(templ,playunit)
	self.template = templ
	self.playunit = playunit
	cdatabaseable.init(self,{
		pid = self.playunit.owner,
		flag = string.format("templateres_%d",self.template.templateid)
	})
	self.data = {}
	self.npclist = {}
	self.scenelist = {}
end

function cresourcemgr:save()
	local data = {}
	data.npc = {}
	for _,npc in pairs(self.npclist) do
		table.insert(data.npc,npc:save())
	end
	data.scene = {}
	for _,scene in pairs(self.scenelist) do
		table.insert(data.scene,scene:save())
	end
	data.data = self.data
	return data
end

function cresourcemgr:load(data)
	if not data or not next(data) then
		return
	end
	local templateid = self.template.templateid
	local owner = self.playunit.pid
	for npcinfo in data.npc do
		local npc = self.template:instance_npc()
		npc:load(npcinfo)
		self:addnpc(npc)
	end
	for sceneinfo in data.scene do
		local scene = self.template:instance_scene()
		scene:load(sceneinfo)
		sefl:addscene(scene)
	end
	self.data = data.data or {}
	for _,npc in pairs(self.npclist) do
		if not npc:isclientnpc() then
			npc:enterscene()
		end
	end
end

function cresourcemgr:addnpc(npc)
	self.npclist[npc.id] = npc
end

function cresourcemgr:addscene(scene)
	self.scenelist[scene.id] = scene
end

function cresourcemgr:release()
	for _,npc in pairs(self.npclist) do
		npc:release()
	end
	for _,scene in pairs(self.scenelist) do
		scene:release()
	end
	self.template = nil
	self.playunit = nil
	self.npclist = nil
	self.scenelist = nil
end


local g_npcid = g_npcid or 0
local g_sceneid = g_sceneid or 0

--临时处理
local function gennpcid()
	if g_npcid > 0xfffff then
		g_npcid = 0
	end
	g_npcid = g_npcid + 1
	return g_npcid
end

local function genscid()
	if g_sceneid > 0xfffff then
		g_sceneid = 0
	end
	g_sceneid = g_sceneid + 1
	return g_sceneid
end


local ctemplnpc = class("ctemplnpc")
function ctemplnpc:init(templateid)
	self.templateid = templateid
	self.id = gennpcid()
	self.scene = 0
	self.x = 0
	self.y = 0
end

function ctemplnpc:config(conf)
	self.nid = conf.nid
	self.clientnpc = conf.clientnpc
	self.type = conf.type
	self.name = conf.name
end

function ctemplnpc:save()
	local data = {}
	data.nid = self.nid
	data.type = self.type
	data.name = self.name
	data.clientnpc = self.clientnpc
	data.scene = self.scene
	data.x = self.x
	data.y = self.y
	return data
end

function ctemplnpc:pack()
	local data = {}
	data.id= self.id
	data.type = self.type
	data.name = self.name
	data.sceneid = self.scene
	data.pos = { x = self.x, y = self.y }
	return data
end

function ctemplnpc:load(data)
	if not data or not next(data) then
		return
	end
	self.nid = data.nid
	self.type = data.type
	self.name = data.name
	self.clientnpc = data.clientnpc
	self.scene = data.scene
	self.x = data.x
	self.y = data.y
end

function ctemplnpc:release()
end

function ctemplnpc:setlocation(scid,x,y)
	self.scene = scid
	self.x = x
	self.y = y
end

function ctemplnpc:isclientnpc()
	return self.clientnpc == 1
end

function ctemplnpc:enterscene()
end

function ctemplnpc:say()
end


local ctemplscene = class("ctemplscene")
function ctemplscene:init(templateid)
	self.templateid = templateid
	self.id = genscid()
end

function ctemplscene:config(conf)
	self.scid = conf.scid
	self.name = conf.name
	self.mapid = conf.mapid
	self.id = genscid()
end

function ctemplscene:save()
	local data = {}
	data.scid = self.scid
	data.name = self.name
	data.mapid = self.mapid
	return data
end

function ctemplscene:load(data)
	if not data or not next(data) then
		return
	end
	self.scid = data.scid
	self.name = data.name
	self.mapid = data.mapid
end

function ctemplscene:release()
end


local ctemplwar = class("ctemplwar")
function ctemplwar:init(templateid)
	self.templateid = templateid
end

function ctemplwar:config(conf)
	self.warid = conf.warid
	self.templateid = conf.templateid
	--cwar.init(self,conf)
end

function ctemplwar:start()
end


object = {
	cresourcemgr = cresourcemgr,
	cnpc = ctemplnpc,
	cscene = ctemplscene,
	cwar = ctemplwar,
}

return object

