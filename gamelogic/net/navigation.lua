netnavigation = netnavigation or {
	C2S = {},
	S2C = {},
}

local C2S = netnavigation.C2S
local S2C = netnavigation.S2C

-- C2S
function C2S.activitydata(player,request)
	navigation.open_navigationui(player)
end

function C2S.activityaward(player,request)
	local hid = assert(request.hid)
	navigation.do_activityaward(player,hid)
end

function C2S.livenessaward(player,request)
	local awardid = assert(request.awardid)
	navigation.do_livenessaward(player,awardid)
end

function C2S.lookstat(player,request)
	navigation.lookstat(player)
end


-- S2C
function S2C.sendactivitydata(player,data)
	player.navigation_updated = nil
	sendpackage(player.pid,"navigation","sendactivitydata",{
		activities = data.activities,
		liveness = data.liveness,
		livenessawarded = data.awardrecord,
	})
end

function S2C.needupdate(player)
	sendpackage(player.pid,"navigation","needupdate",{})
end

function S2C.showredpoint(pid)
	sendpackage(pid,"navigation","showredpoint",{})
end

return netnavigation
