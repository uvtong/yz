netunion = netunion or {
	C2S = {},
	S2C = {},
}

local C2S = netunion.C2S
local S2C = netunion.S2C

function C2S.createunion(player,request)
	local name = assert(request.name)
	local purpose = assert(request.purpose)
	local badge = assert(request.badge)
	local isok,data = playeraux.isopen(player.lv,"公会")
	if not isok then
		net.msg.S2C.notify(player.pid,language.format(data.tips_text))
		return
	end
	if not unionaux.isvalid_badge(badge) then
		net.msg.S2C.notify(player.pid,language.format("非法徽章构成"))
		return
	end
	local param = {
		name = name,
		purpose = {
			msg = purpose,
		},
		badge = badge,
		leader = cunionmgr.packmember(player.pid,unionaux.jobid("会长")),
		srvname = globalmgr.home_srvname(player.pid),
	}
	if player:unionid() then
		net.msg.S2C.notify(player.pid,language.format("你已经有公会了"))
		return
	end
	local costgold = data_1800_UnionVar.CreateUnionCostGold
	if not player:validpay("gold",costgold,true) then
		return
	end

	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._createunion(param)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._createunion",param)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	end
	player:addres("gold",-costgold,"createunion",true)
end

function C2S._createunion(param)
	local pid = param.leader.pid
	local unionid = unionmgr:unionid(pid)
	if unionid then
		return false,language.format("你已经有公会了")
	end
	local isok,errmsg = unionmgr:isvalid_name(param.name,param.srvname)
	if not isok then
		return false,errmsg
	end
	-- check more
	local union = unionmgr:addunion(param)
	local srvnames = unionmgr:samezone_srvnames(param.srvname)
	for i,srvname in ipairs(srvnames) do
		skynet.fork(rpc.pcall,srvname,"rpc","net.msg.sendquickmsg",
			language.format("#<Y>{1}#在此宣布{2}公会#<Y>{3}#创建成功！{4}",
				language.untranslate(union:memberget(pid,"name")),
				richtext("badge",union.badge),
				language.untranslate(union.name),
				richtext("button_lookunion",{unionid=union.id})))
	end
	return true,union:pack()
end

function C2S.changeleader(player,request)
	local pid = assert(request.pid)
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._changeleader(player.pid,pid)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._changeleader",player.pid,pid)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	end
end

function C2S._changeleader(pid,topid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member1 = union:member(pid)
	local jobid1 = unionaux.jobid("会长")
	local jobid2 = unionaux.jobid("副会长")
	if member1.jobid ~= jobid1 then
		return false,language.format("只有会长才能进行此操作")
	end
	local member2 = union:member(topid)
	if not member2 then
		return false,language.format("对方不是本公会成员")
	end
	if member2.jobid ~= jobid2 then
		return false,language.format("对方不是副会长")
	end
	local resume = resumemgr.getresume(topid)
	local now = os.time()
	local logofftime = resume:get("logofftime")
	local logoffday = 3
	if logofftime and now - logofftime > logoffday * DAY_SECS then
		return false,language.format("该副会长离线超过{1}天,无法更改会长",logoffday)
	end
	union:changeleader(member2)
	return true
end

function C2S.changename(player,request)
	local name = assert(request.name)
	local costgold = data_1800_UnionVar.ChangeNameCostGold
	if not player:validpay("gold",costgold,true) then
		return
	end
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._changename(player.pid,name)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._changename",player.pid,name)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	end
	player:addres("gold",-costgold,"union.changename",true)
end

function C2S._changename(pid,name)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member = union:member(pid)
	if not unionaux.cando(member.jobid,"changename") then
		return false,language.format("你没有权限进行此项操作")
	end
	local isok,errmsg = unionmgr:isvalid_name(name,unionmgr:srvname(unionid))
	if not isok then
		return false,errmsg
	end
	union:changename(name)
	return true
end

function C2S.changebadge(player,request)
	local badge = assert(request.badge)
	if not unionaux.isvalid_badge(badge) then
		net.msg.S2C.notify(player.pid,language.format("非法徽章构成"))
		return
	end
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._changebadge({pid=player.pid,gold=player.gold},badge)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._changebadge",{pid=player.pid,gold=player.gold},badge)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	else
		local costgold = errmsg
		if costgold > 0 then
			player:addres("gold",-costgold,"changebadge",true)
		end
	end
end

function C2S._changebadge(player,badge)
	local pid = player.pid
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member = union:member(pid)
	if not unionaux.cando(member.jobid,"changebadge") then
		return false,language.format("你没有权限进行此项操作")
	end
	local diff_badge = {}
	for k,v in pairs(union.badge) do
		if v ~= badge[k] then
			diff_badge[k] = badge[k]
		end
	end
	local sumgold = data_1800_UnionVar.ChangeBadgeCostGold
	for badge_type,badge_id in pairs(diff_badge) do
		local data = data_1800_UnionBadge[badge_id][badge_type]
		local costgold = data.gold
		if not costgold or costgold < 0 then
			return false,language.format("非法徽章构成")
		else
			local cond = data.cond
			local isok,errmsg = unionaux.build_lv_isok(union,cond)
			if not isok then
				return false,errmsg
			end
			sumgold = sumgold + costgold
		end
	end
	if sumgold > 0 and player.gold < sumgold then
		local resname = getresname(RESTYPE.GOLD)
		return false,language.format("{1}不足{2}",resname,sumgold)
	end
	union:changebadge(badge)
	return true,sumgold
end

function C2S.upgradebuild(player,request)
	local type = assert(request.type)
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._upgradebuild(player.pid,type)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._upgradebuild",player.pid,type)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	end
end

function C2S._upgradebuild(pid,typ)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member = union:member(pid)
	if not unionaux.cando(member.jobid,"upgrade_build") then
		return false,language.format("你没有权限进行此项操作")
	end
	local lv_key = string.format("%s_lv",typ)
	local oldlv = union[lv_key]
	if not oldlv then
		return false,language.format("非法建筑类型")
	end
	if typ ~= "dating" and oldlv >= union.dating_lv then
		return false,language.format("{1}的等级不能超过公会大厅",unionaux.buildname(typ))
	end
	local next_lv = oldlv + 1
	local costdata = data_1800_UnionUpgradeBuildCost[next_lv]
	if not costdata then
		return false,language.format("公会等级已达到最高级")
	end
	local cost_key = string.format("%s_cost",typ)
	local cost = costdata[cost_key]
	for restype,v in pairs(cost) do
		if restype == "money" then
			if union.money < v then
				return false,language.format("公会资金不足{1}",v)
			end
		else
			assert(restype == "items")
			for i,item in ipairs(v) do
				if union.cangku:getnumbytype(item.type) < item.num then

					return false,language.format("{1}数量不足#<R>{2}#个",itemaux.itemlink(item.type),item.num)
				end
			end
		end
	end
	local reason = "upgradeskill"
	for restype,v in pairs(cost) do
		if restype == "money" then
			union:addmoney(-v,reason)
		else
			assert(restype == "items")
			for i,item in ipairs(v) do
				union.cangku:costitembytype(item.type,item.num,reason)
			end
		end
	end
	union:update({
		[lv_key] = next_lv,
	})
	return true
end

function C2S.changejob(player,request)
	local pid = assert(request.pid)
	local jobid = assert(request.jobid)
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._changejob(player.pid,pid,jobid)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._changejob",player.pid,pid,jobid)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	end
end

function C2S._changejob(pid,tid,jobid)
	if not data_1800_UnionJob[jobid] then
		return false,language.format("非法职位")
	end
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member2 = union:member(tid)
	if not member2 then
		return false,language.format("对方不是本公会成员")
	end
	local member1 = union:member(pid)
	local cando,jobids = unionaux.cando(member1.jobid,"changejob")
	if not cando then
		return false,language.format("你没有权限进行此项操作")
	end
	if not table.find(jobids,jobid) then
		return false,language.format("你没有权限进行此项操作")
	end
	if member1.jobid >= jobid then
		return false,language.format("你没有权限进行此项操作")
	end
	local pids = union.job_members[jobid] or {}
	local limit = data_1800_UnionJob[jobid].limit
	if limit > 0 and #pids >= limit then
		return false,language.format("该职位人数已满")
	end
	union:changejob(member2,jobid)
	local msg = language.format("#<Y>{1}#将#<Y>{2}#的公会职位调整为#<Y>{3}#",
				language.untranslate(union:memberget(member1.pid,"name")),
				language.untranslate(union:memberget(member2.pid,"name")),
				unionaux.jobname(member2.jobid))
	union:sendmsg({pid = SENDER.UNION},msg)
	return true
end

function C2S.edit_purpose(player,request)
	local purpose = assert(request.purpose)
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._edit_purpose(player.pid,purpose)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._edit_purpose",player.pid,purpose)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	else
		net.msg.S2C.notify(player.pid,language.format("保存成功"))
	end
end

function C2S._edit_purpose(pid,purpose)
	local isok,errmsg = _isvalid_name(purpose)
	if not isok then
		return false,language.format("包含非法字符")
	end
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member = union:member(pid)
	if not unionaux.cando(member.jobid,"edit_purpose") then
		return false,language.format("你没有权限进行此项操作")
	end
	local len = string.utf8len(purpose)
	if len < 1 then
		return false,language.format("字符数少于{1}个",1)
	end
	local maxlen = data_1800_UnionVar.PurposeMaxChar
	if len > maxlen then
		return false,language.format("字符数大于{1}个",maxlen)
	end
	union:edit_purpose({
		changer = {
			time = os.time(),
			jobid = member.jobid,
			name = union:memberget(member.pid,"name"),
		},
		msg = purpose,
	})
	return true
end

function C2S.publish_purpose(player,request)
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._publish_purpose(player.pid)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._publish_purpose",player.pid)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	else
		net.msg.S2C.notify(player.pid,language.format("发布成功"))
	end
end

function C2S._publish_purpose(pid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member = union:member(pid)
	if not unionaux.cando(member.jobid,"edit_purpose") then
		return false,language.format("你没有权限进行此项操作")
	end
	if not union.purpose or string.len(union.purpose.msg) == 0 then
		return false,language.format("无法发布空宗旨")
	end
	local cost = data_1800_UnionVar.PublishPurposeCost
	for restype,v in pairs(cost) do
		if restype == "money" then
			if union.money < v then
				return false,language.format("公会资金不足{1}",v)
			end
		else
			assert(restype == "items")
			for i,item in ipairs(v) do
				if union.cangku:getnumbytype(item.type) < item.num then

					return false,language.format("{1}数量不足#<R>{2}#个",itemaux.itemlink(item.type),item.num)
				end

			end
		end
	end
	local reason = "publish_purpose"
	for restype,v in pairs(cost) do
		if restype == "money" then
			union:addmoney(-v,reason)
		else
			assert(restype == "items")
			for i,item in ipairs(v) do
				union.cangku:costitembytype(item.type,item.num,reason)
			end
		end
	end
	local srvnames = unionmgr:samezone_srvnames(unionmgr:srvname(unionid))
	for i,srvname in ipairs(srvnames) do
		skynet.fork(rpc.pcall,srvname,"rpc","net.union.S2C.publish_purpose",
			language.format("公会{1}现正火热招募公会成员中！{2}!请大家踊跃加入{3}",
				language.untranslate(union.name),
				language.untranslate(union.purpose.msg),
				richtext("button_lookunion",{unionid=union.id})))
	end
	return true
end

function C2S.edit_notice(player,request)
	local notice = assert(request.notice)
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._edit_notice(player.pid,notice)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._edit_notice",player.pid,notice)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	else
		net.msg.S2C.notify(player.pid,language.format("保存成功"))
	end
end

function C2S._edit_notice(pid,notice)
	local isok,errmsg = _isvalid_name(notice)
	if not isok then
		return false,language.format("包含非法字符")
	end
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member = union:member(pid)
	if not unionaux.cando(member.jobid,"edit_notice") then
		return false,language.format("你没有权限进行此项操作")
	end
	local len = string.utf8len(notice)
	if len < 1 then
		return false,language.format("字符数少于{1}个",1)
	end
	local maxlen = data_1800_UnionVar.NoticeMaxChar
	if len > maxlen then
		return false,language.format("字符数大于{1}个",maxlen)
	end

	union:edit_notice({
		changer = {
			time = os.time(),
			jobid = member.jobid,
			name = union:memberget(member.pid,"name"),
		},
		msg = notice,
	})
	local msg = language.format("公会公告：{1} 编辑人:{2} {3} {4}",
				language.untranslate(union.notice.msg),
				language.untranslate(union.notice.changer.name),
				unionaux.jobname(union.notice.changer.jobid),
				os.date("%m/%d",union.notice.changer.time))
	union:sendmsg({pid = SENDER.UNION},msg)
	return true
end

function C2S.publish_notice(player,request)
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._publish_notice(player.pid)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._publish_notice",player.pid)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	else
		net.msg.S2C.notify(player.pid,language.format("发布成功"))
	end
end

function C2S._publish_notice(pid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member = union:member(pid)
	if not unionaux.cando(member.jobid,"edit_notice") then
		return false,language.format("你没有权限进行此项操作")
	end
	if not union.notice or string.len(union.notice.msg) == 0 then
		return false,language.format("无法发布空公告")
	end
	local incd,exceedtime = union.thistemp:query("publish_notice.cd")
	if incd then
		local lefttime = exceedtime - os.time()
		return false,language.format("CD中,剩余{1}秒",lefttime)
	end
	local cd = data_1800_UnionVar.PublishNoticeCD
	union.thistemp:set("publish_notice.cd",true,cd)
	local msg = language.format("公会公告：{1} 编辑人:{2} {3} {4}",
			language.untranslate(union.notice.msg),
			language.untranslate(union.notice.changer.name),
			unionaux.jobname(member.jobid),
			os.date("%m/%d",union.notice.changer.time))
	union:sendmsg({pid = SENDER.UNION},msg)
	return true
end

function C2S.apply_join(player,request)
	local unionid = assert(request.unionid)
	local isok,data = playeraux.isopen(player.lv,"公会")
	if not isok then
		net.msg.S2C.notify(player.pid,language.format(data.tips_text))
		return
	end
	if player:unionid() then
		net.msg.S2C.notify(player.pid,language.format("你已经有公会了"))
		return
	end
	local incd_unionid,exceedtime = player.thistemp:query("apply_join_cd")
	if incd_unionid and incd_unionid ~= unionid then
		local lefttime = exceedtime - os.time()
		local date = dhms_time({hour=true,min=true,sec=true},lefttime)
		net.msg.S2C.notify(player.pid,language.format("申请入会CD中，剩余时间:{1}小时{2}分钟{3}秒",date.hour,date.min,date.sec))
		return
	end
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._apply_join(player.pid,unionid)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._apply_join",player.pid,unionid)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	else
		net.msg.S2C.notify(player.pid,language.format("已经发送申请，请耐心等待"))
	end
end

function C2S._apply_join(pid,unionid)
	if unionmgr:unionid(pid) then
		return false,language.format("你已经有公会了")
	end
	local union = unionmgr:getunion(unionid)
	if not union then
		return false,language.format("该公会不存在")
	end
	assert(union:member(pid) == nil)
	if table.find(union.applyers,pid) then
		return false,language.format("你已经申请过该公会了")
	end
	union:addapplyer(pid)
	return true
end

function C2S.invite_join(player,request)
	local isok,data = playeraux.isopen(player.lv,"公会")
	if not isok then
		net.msg.S2C.notify(player.pid,language.format(data.tips_text))
		return
	end
	local tid = assert(request.pid)
	local unionid = player:unionid()
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end

	local self_srvname = cserver.getsrvname()
	local now_srvname,isonline = globalmgr.now_srvname(tid)
	if now_srvname == self_srvname then
		local target = playermgr.getplayer(tid)
		if not target then
			net.msg.S2C.notify(player.pid,language.format("对方不在线"))
			player:delfrom_union_recommendlist(tid)
			return
		end
		if target:unionid() then
			net.msg.S2C.notify(player.pid,language.format("对方已经有公会"))
			player:delfrom_union_recommendlist(tid)
			return
		end
		if not playeraux.isopen(target.lv,"公会") then
			net.msg.S2C.notify(player.pid,language.format("对方等级不足,无法加入公会"))
			player:delfrom_union_recommendlist(tid)
			return
		end
		local incd_unionid,exceedtime = target.thistemp:query("apply_join_cd")
		if incd_unionid and incd_unionid ~= unionid then
			local lefttime = exceedtime - os.time()
			local date = dhms_time({hour=true,min=true,sec=true},lefttime)
			net.msg.S2C.notify(player.pid,language.format("对方申请入会CD中，剩余时间:{1}小时{2}分钟{3}秒",date.hour,date.min,date.sec))
			player:delfrom_union_recommendlist(tid)
			return
		end
	else
		if not isonline then
			net.msg.S2C.notify(player.pid,language.format("对方不在线"))
			player:delfrom_union_recommendlist(tid)
			return
		end
		local target = cproxyplayer.new(tid,now_srvname)
		if target:unionid() then
			net.msg.S2C.notify(player.pid,language.format("对方已经有公会"))
			player:delfrom_union_recommendlist(tid)
			return
		end
		local lv = target:getlv()
		if not playeraux.isopen(lv,"公会") then
			net.msg.S2C.notify(player.pid,language.format("对方等级不足,无法加入公会"))
			player:delfrom_union_recommendlist(tid)
			return
		end
		local incd_unionid,exceedtime = target.thistemp:query("apply_join_cd")
		if incd_unionid and incd_unionid ~= unionid then
			local lefttime = exceedtime - os.time()
			local date = dhms_time({hour=true,min=true,sec=true},lefttime)
			net.msg.S2C.notify(player.pid,language.format("对方申请入会CD中，剩余时间:{1}小时{2}分钟{3}秒",date.hour,date.min,date.sec))
			player:delfrom_union_recommendlist(tid)
			return
		end
	end
	local unioninfo = unionaux.getunion(unionid)
	if not unioninfo then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local incd,lefttime = player:limit_frequence("union.invite_join",tid,60)
	if incd then
		net.msg.S2C.notify(player.pid,language.format("入会邀请已发送，请耐心等待"))
		return
	end
	net.msg.S2C.notify(player.pid,language.format("入会邀请已发送，请耐心等待"))
	player:delfrom_union_recommendlist(tid)
	local pid = player.pid
	openui.messagebox(tid,{
		type = MB_INVITE_JOIN_UNION,
		title = language.format("邀请入会"),
		content = language.format("#<Y>{1}#邀请你加入\n#<Y>{2}#公会。",
					language.untranslate(player:getname()),
					language.untranslate(unioninfo.name)),
		buttons = {
			openui.button(language.format("拒绝")),
			openui.button(language.format("查看")),  -- 查看后可以选择加入公会
		},
		attach = {
			unioninfo = unioninfo,
		},
		forward = true,
		},
		function (uid,request,response)
			local answer = response.answer
			if answer ~= 2 then
				return
			end
			local isok,errmsg
			if cserver.isunionsrv() then
				isok,errmsg = net.union.C2S._agree_invite_join(uid,unionid,pid)
			else
				isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._agree_invite_join",uid,unionid,pid)
			end
			if not isok then
				if errmsg then
					net.msg.S2C.notify(uid,errmsg)
				end
				return
			end
		end)
end

function C2S._agree_invite_join(uid,unionid,pid)
	local union = unionmgr:getunion(unionid)
	if not union then
		return false,language.format("该公会不存在")
	end
	local addto_applyer = false
	local member = union:member(pid)
	if not member or not unionaux.cando(member.jobid,"add") then
		addto_applyer = true
	end
	if addto_applyer then
		return net.union.C2S._apply_join(uid,unionid)
	else
		if unionmgr:unionid(uid) then
			return false,language.format("你已经有公会了")
		end
		if union:member(uid) then
			return false,language.format("你已是该公会成员")
		end
		if union:reachlimit() then
			return false,language.format("该公会人数已满")
		end
		union:add(cunionmgr.packmember(uid))
		return true
	end
end

function C2S.agree_join(player,request)
	local tid = assert(request.pid)
	if not player:unionid() then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._agree_join(player.pid,tid)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._agree_join",player.pid,tid)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	end
end

function C2S._agree_join(pid,tid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	if unionmgr:unionid(tid) then
		return false,language.format("对方已经有公会了")
	end
	local union = unionmgr:getunion(unionid)
	local member = union:member(pid)
	if not unionaux.cando(member.jobid,"add") then
		return false,language.format("你没有权限进行此项操作")
	end
	if union:reachlimit() then
		return false,language.format("公会人数已满")
	end
	union:add(cunionmgr.packmember(tid))
	return true
end

function C2S.disagree_join(player,request)
	local tid = request.pid
	if not player:unionid() then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._disagree_join(player.pid,tid)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._disagree_join",player.pid,tid)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	end
end

function C2S._disagree_join(pid,tid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member = union:member(pid)
	-- add -- 批准入会的权限/同时具有删除申请列表的权限
	if not unionaux.cando(member.jobid,"add") then
		return false,language.format("你没有权限进行此项操作")
	end
	local remove_applyers
	if tid then
		remove_applyers = {tid}
	else
		remove_applyers = deepcopy(union.applyers)
	end
	if table.isempty(remove_applyers) then
		return false,language.format("空申请列表")
	end
	union:delapplyer(remove_applyers)
	return true
end

function C2S.kick_member(player,request)
	local tid = assert(request.pid)
	if not player:unionid() then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._kick_member(player.pid,tid)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._kick_member",player.pid,tid)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	end
end

function C2S._kick_member(pid,tid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member2 = union:member(tid)
	if not member2 then
		return false,language.format("对方不是你公会成员")
	end
	local member1 = union:member(pid)
	local cando,jobids = unionaux.cando(member1.jobid,"del")
	if not cando then
		return false,language.format("你没有权限进行此项操作")
	end
	if not table.find(jobids,member2.jobid) then
		return false,language.format("你没有权限进行此项操作")
	end
	union:del(tid)
	mailmgr.sendmail(tid,{
		srcid = SYSTEM_MAIL,
		author = language.format("公会管理员"),
		title = language.format("离开公会通知"),
		content = language.format("你被#<Y>{1}#踢出了#<Y>{2}#",
					language.untranslate(union:memberget(pid,"name")),
					language.untranslate(union.name)),
	})
	local msg = language.format("#<Y>{1}#将#<Y>{2}#踢出了公会",
					language.untranslate(union:memberget(member1.pid,"name")),
					language.untranslate(union:memberget(member2.pid,"name")))
	union:sendmsg({pid = SENDER.UNION},msg)
	return true
end

function C2S.openui(player,request)
	local type = assert(request.type)
	local cmd = string.format("openui_%s",type)
	local func = net.union.C2S[cmd]
	if func then
		return func(player)
	end
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._openui(player.pid,type)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._openui",player.pid,type)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	end
end

function C2S._openui(pid,type)
	local cmd = string.format("_openui_%s",type)
	local func = net.union.C2S[cmd]
	if not func then
		return
	end
	return func(pid)
end

function C2S._openui_union(pid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	union.openui_pids[pid] = true
	unionmgr:sendpackage(pid,"union","sync_union",{
		union = union:pack(),
	})
	return true
end

function C2S._openui_applyer(pid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	unionmgr:sendpackage(pid,"union","applyers",{
		applyers = union.applyers,
	})
	return true
end

function C2S.openui_inviter(player)
	local unionid = player:unionid()
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local inviters = player:union_recommendlist()
	sendpackage(player.pid,"union","inviters",{
		inviters = inviters,
	})
end

function C2S._openui_member(pid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local members = {}
	for pid,member in pairs(union.members.objs) do
		table.insert(members,union:member(pid))
	end
	unionmgr:sendpackage(pid,"union","members",{
		members = members,
	})
	return true
end

function C2S.openui_huodong_paoshang(player)
	local unionid = player:unionid()
	if not unionid then
		return false,language.format("你没有公会")
	end
	local member = unionaux.unionmethod(unionid,":member",player.pid)
	sendpackage(player.pid,"union","huodong_paoshang",{
		offer = member.offer,
		paoshangcnt = unionaux.unionmethod(unionid,".today:query","union.huodong.paoshangcnt") or 0,
	})
end

function C2S.openui_weekfuli(player)
	local unionid = player:unionid()
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local all_finishcnt = player.thisweek:query("union.weekfuli.finishcnt")
	local pack_finishcnt = {}
	for name,cnt in pairs(all_finishcnt) do
		table.insert(pack_finishcnt,{
			name = name,
			cnt = cnt,
		})
	end
	sendpackage(player.pid,"union","weekfuli",{
		finishcnt = pack_finishcnt,
		isbonus = player.thisweek:query("union.weekfuli.isbonus"),
	})
end

function C2S.openui_cangku(player)
	local unionid = player:unionid()
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local items = unionaux.unionmethod(unionid,"cangku:allitem")
	sendpackage(player.pid,"union","allitem",{
		items = items,
	})
end

function C2S.openui_jika(player,request)
	local unionid = player:unionid()
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local sessions = unionaux.unionmethod(unionid,":all_collect_card")
	sendpackage(player.pid,"union","all_collect_card",{
		sessions = sessions,
	})
end

function C2S.openui_collectitem(player,request)
	local unionid = player:unionid()
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local unioninfo = unionaux.getunion(unionid)
	if not unioninfo then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local needlv = data_1800_UnionCollectItemVar.NeedUnionLv
	if unioninfo.dating_lv < needlv then
		net.msg.S2C.notify(player.pid,language.format("公会等级不足#<R>{1}#级",needlv))
		return
	end
	local huodong = unionaux.gethuodong_collectitem(player)
	sendpackage(player.pid,"union","collectitem_alltask",huodong)
end

function C2S.closeui(player,request)
	local type = assert(request.type)
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._closeui(player.pid,type)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._closeui",player.pid,type)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	end

end

function C2S._closeui(pid,type)
	local cmd = string.format("_closeui_%s",type)
	local func = net.union.C2S[cmd]
	if not func then
		return
	end
	return func(pid)
end


function C2S._closeui_union(pid)
	local unionid = unionmgr:unionid(pid)
	local union = unionmgr:getunion(unionid)
	if not union then
		return false
	end
	union.openui_pids[pid] = nil
	return true
end

function C2S.quit(player,request)
	if not player:unionid() then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._quit(player.pid)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._quit",player.pid)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	end
end

function C2S._quit(pid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member = union:member(pid)
	if member.jobid == unionaux.jobid("会长") then
		if union.members.len == 1 then
			unionmgr:delunion(unionid)
			return true
		else
			return false,language.format("会长无法退出公会")
		end
	else
		union:del(pid)
		local msg = language.format("#<Y>{1}#脱离了公会",
						language.untranslate(union:memberget(member.pid,"name")))
		union:sendmsg({pid = SENDER.UNION},msg)
		return true
	end
end

function C2S.look_union(player,request)
	local unionid = assert(request.unionid)
	local unioninfo = unionaux.getunion(unionid)
	if not unioninfo then
		net.msg.S2C.notify(player.pid,language.format("该公会不存在"))
		return
	else
		sendpackage(player.pid,"union","look_union",{
			unioninfo = unioninfo,
		})
	end
end

function C2S.scan_unions(player,request)
	local startpos = assert(request.startpos)
	local len = assert(request.len)
	assert(len <= 20)
	local ret_unions,next_startpos
	if cserver.isunionsrv() then
		ret_unions,next_startpos = net.union.C2S._scan_unions(startpos,len,player.pid)
	else
		ret_unions,next_startpos = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._scan_unions",startpos,len,player.pid)
	end
	sendpackage(player.pid,"union","scan_unions",{
		unioninfos = ret_unions,
		next_startpos = next_startpos,
	})
end

function C2S._scan_unions(startpos,len,pid)
	local srvname = globalmgr.home_srvname(pid)
	local srv = data_RoGameSrvList[srvname]
	local sort_unions = unionmgr:scan_unions()
	local maxlen = #sort_unions
	local next_startpos = -1
	local ret_unions = {}
	for i=startpos,maxlen do
		next_startpos = i + 1
		local u = sort_unions[i]
		local union = unionmgr:getunion(u.id)
		local srvname2 = unionmgr:srvname(union.id)
		local srv2 = data_RoGameSrvList[srvname2]
		if union and srv.zonename == srv2.zonename then
			table.insert(ret_unions,union:pack(true))
			if #ret_unions >= len then
				break
			end
		end
	end
	if next_startpos > maxlen then
		next_startpos = -1
	end
	return ret_unions,next_startpos
end

-- 竞选会长
function C2S.runfor_leader(player,request)
	if not player:unionid() then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._runfor_leader(player.pid)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._runfor_leader",player.pid)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	else
		net.msg.S2C.notify(player.pid,language.format("已成功发起竞选会长投票"))
	end
end

function C2S._runfor_leader(pid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member = union:member(pid)
	if member.jobid ~= unionaux.jobid("副会长") then
		return false,language.format("只有副会长才能竞选会长")
	end
	local now = os.time()
	local needday = data_1800_UnionVar.RunForLeaderNeedLogoffTime
	local leader = union:leader()
	if union:memberget(leader.pid,"online") then
		return false,language.format("现任会长离线时间未超过{1}天，无法发起会长竞选",needday)
	end
	local logofftime = union:memberget(leader.pid,"logofftime")
	--if not logofftime or (now - logofftime) < needday * DAY_SECS then
	--	return false,language.format("现任会长离线时间未超过{1}天，无法发起会长竞选",needday)
	--end
	if not logofftime or (now - logofftime) < 60 then
		return false,language.format("现任会长离线时间未超过{1}天，无法发起会长竞选",needday)
	end

	local incd,exceedtime = union.thistemp:query(string.format("runfor_leader.%s",pid))
	if incd then
		local lefttime = exceedtime - now
		local date = dhms_time({day=true,hour=true,min=true,sec=true},lefttime)
		return false,language.format("竞选会长CD中，剩余{1}天{2}小时{3}分钟{4}秒",date.day,date.hour,date.min,date.sec)
	end
	if union:getvote("竞选会长") then
		return false,language.format("竞选会长正在进行中,等本次投票结束后再试")
	end
	local cd = 300--data_1800_UnionVar.RunForLeaderCD * DAY_SECS
	union.thistemp:set(string.format("runfor_leader.%s",pid),true,cd)
	local member_vote = {}
	local pids = union.job_members[unionaux.jobid("副会长")]
	for i,uid in ipairs(pids) do
		member_vote[uid] = 1
	end
	local lifetime = 240--data_1800_UnionVar.RunForLeaderVoteTime * DAY_SECS
	local vote = union.votemgr:newvote({
		exceedtime = now + lifetime,
		member_vote = member_vote,
		must_timeout_endvote = true,
		creater = pid,
		unionid = unionid,
		callback = pack_function("unionmgr:onendvote"),
	})
	-- 竞选会长采取：投反对票形式
	local voteid = union.votemgr:addvote("竞选会长",vote)
	local date = dhms_time({hour=true,min=true,sec=true},lifetime)
	for uid in pairs(member_vote) do
		if uid ~= pid then
			mailmgr.sendmail(uid,{
				srcid = SYSTEM_MAIL,
				author = language.format("公会管理员"),
				title = language.format("公会会长竞选"),
				content = language.format([[由于#<R>{1}#会长#<R>{2}#长时间不在线，副会长#<R>{3}#正式发起会长竞选，
申请成为本公会的公会会长，请问你是否反对？]],
							language.untranslate(union.name),
							language.untranslate(union:memberget(leader.pid,"name")),
							language.untranslate(union:memberget(pid,"name"))),
				lifetime = lifetime,
				buttons = {language.format("【考虑一下】"),language.format("【我要反对】"),language.format("【竞选规则】"),},
				callback = pack_function("net.mail.C2S._respondanswer"),
				autodel = false,
			})

		end
	end
	return true
end

function C2S._voteto(typ,pid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	if typ == "竞选会长" then
		local member = union:member(pid)
		if member.jobid ~= unionaux.jobid("副会长") then
			return false,language.format("只有副会长才有投票资格")
		end
		if not union:getvote(typ) then
			return false,language.format("本次竞选已结束")
		end
		return union.votemgr:voteto(typ,pid)
	end
end

function C2S.upgradeskill(player,request)
	local union = player:unionid()
	if not union then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local pid = player.pid
	local skillid = assert(request.skillid)
	local skilldata = unionaux.getskilldata(skillid)
	if not skilldata then
		return
	end
	local key = string.format("union.skill.%s",skillid)
	local skill = player:query(key) or {}
	local oldlv = skill.lv or 0
	local next_lv = oldlv + 1
	local lv_skilldata = skilldata[next_lv]
	if not lv_skilldata then
		net.msg.S2C.notify(pid,language.format("该技能已达到最高等级"))
		return
	end
	local preskill = lv_skilldata.preskill
	if preskill then
		local has_preskill = player:query(string.format("union.skill.%s",preskill.id))
		if not has_preskill or has_preskill.lv < preskill.lv then
			net.msg.S2C.notify(player.pid,language.format("前置技能等级不足#<R>{1}#级",preskill.lv))
			return
		end
	end
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._upgradeskill(pid,skillid,next_lv)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._upgradeskill",pid,skillid,next_lv)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
	else
		skill.lv = next_lv
		skill.skillid = skillid
		player:set(key,skill)
		sendpackage(pid,"union","update_skill",{
			skill = skill,
		})
	end
end

function C2S._upgradeskill(pid,skillid,next_lv)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local member = union:member(pid)
	local skilldata = unionaux.getskilldata(skillid)
	if not skilldata then
		return false,language.format("非法技能ID")
	end
	local lv_skilldata = skilldata[next_lv]
	if not lv_skilldata then
		return false,language.format("该技能已达到最高等级")
	end
	local isok,errmsg = unionaux.build_lv_isok(union,lv_skilldata.cond)	
	if not isok then
		return false,errmsg
	end
	for i,item in ipairs(lv_skilldata.cost.items) do
		if union.cangku:getnumbytype(item.type) < item.num then

			return false,language.format("{1}数量不足#<R>{2}#个",itemaux.itemlink(item.type),item.num)
		end

	end
	local reason = string.format("upgradeskill.%s",skillid)
	local costoffer = lv_skilldata.cost.offer
	if member.offer < costoffer then
		return false,language.format("贡献度不足{1}",costoffer)
	end
	for i,item in ipairs(lv_skilldata.cost.items) do
		union.cangku:costitembytype(item.type,item.num,reason)
	end
	union:addoffer(pid,-costoffer,reason)
	return true
end

function C2S.weekfuli_getbonus(player,request)
	local unionid = player:unionid()
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local isbonus = player.thisweek:query("bonus.weekfuli.isbonus")
	if isbonus then
		net.msg.S2C.notify(player.pid,language.format("你已经领取了本周福利"))
		return
	end
	local all_finishcnt = player.thisweek:query("union.weekfuli.finishcnt") or {}
	local score = 0
	for name,cnt in pairs(all_finishcnt) do
		local data = data_1800_UnionFinishCnt2Score[name]
		if cnt >= data.needcnt then
			score = score + data.score
		end
	end
	if score > 0 then
		local maxk
		for k,v in pairs(data_1800_UnionScoreBonus) do
			if score >= k then
				if not maxk or k > maxk then
					maxk = k
				end
			end
		end
		local bonus = data_1800_UnionScoreBonus[maxk]
		local reward = {
			items = bonus.items
		}
		local unioninfo = unionaux.getunion(unionid)
		if not unioninfo then
			return
		end
		local member = unionaux.member(unionid,player.pid)
		reward.exp = execformula(data_1800_UnionVar.FuliExpFormula,{
			baseexp = bonus.baseexp,
			playerlv = player.lv,
			cangku_addn = data_1800_UnionCangKu[unioninfo.cangku_lv].fuli_addn,
			job_addn = data_1800_UnionJob[member.jobid].fuli_addn,
		})
		reward.exp = math.floor(reward.exp)
		player.thisweek:set("union.weekfuli.isbonus",true)
		doaward("player",player.pid,reward,"union.weekfuli",true)
	else
		net.msg.S2C.notify(player.pid,language.format("你没有上周公会活动记录，请下周再来领取"))
	end
end

function C2S.search_union(player,request)
	local unionid = assert(request.unionid)
	local home_srvname = globalmgr.home_srvname(player.pid)
	local unions
	if cserver.isunionsrv() then
		unions = net.union.C2S._search_union(unionid,home_srvname)
	else
		unions = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._search_union",unionid,home_srvname)
	end
	sendpackage(player.pid,"union","search_union_result",{
		unions = unions,
	})
end

function C2S._search_union(unionid,home_srvname)
	local name = unionid
	unionid = tonumber(unionid)
	local unions = {}
	if unionid then
		local union = unionmgr:getunion(unionid)
		if union then
			table.insert(unions,union:pack(true))
		end
	end
	for unionid,union in pairs(unionmgr.objs) do
		if string.get_similar(union.name,name) >= 0.5 then
			table.insert(unions,union:pack(true))
		end
	end
	if home_srvname then
		local ret_unions = {}
		local srv = data_RoGameSrvList[home_srvname]
		for i,union in ipairs(unions) do
			local srvname = unionmgr:srvname(union.id)
			local srv2 = data_RoGameSrvList[srvname]
			if srv.zonename == srv2.zonename then
				table.insert(ret_unions,union)
			end
		end
		return ret_unions
	else
		return unions
	end
end

function C2S.banspeak(player,request)
	local tid = assert(request.pid)
	local unionid = player:unionid()
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._banspeak(player.pid,tid)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._banspeak",player.pid,tid)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
	end
end

function C2S._banspeak(pid,tid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local isok,errmsg = union:can_banspeak(pid,tid)
	if not isok then
		return false,errmsg
	end
	union:banspeak(tid)
	local msg = language.format("#<Y>{1}#被#<Y>{2}#禁言了30分钟",
					language.untranslate(union:memberget(tid,"name")),
					language.untranslate(union:memberget(pid,"name")))
	union:sendmsg({pid=SENDER.UNION},msg)
	return true
end

function C2S.unbanspeak(player,request)
	local tid = assert(request.pid)
	local unionid = player:unionid()
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = net.union.C2S._unbanspeak(player.pid,tid)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._unbanspeak",player.pid,tid)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
	end
end


function C2S._unbanspeak(pid,tid)
	local unionid = unionmgr:unionid(pid)
	if not unionid then
		return false,language.format("你没有公会")
	end
	local union = unionmgr:getunion(unionid)
	local isok,errmsg = union:can_banspeak(pid,tid)
	if not isok then
		return false,errmsg
	end
	union:unbanspeak(tid)
	local msg = language.format("#<Y>{1}#被#<Y>{2}#解除了禁言",
					language.untranslate(union:memberget(tid,"name")),
					language.untranslate(union:memberget(pid,"name")))
	union:sendmsg({pid=SENDER.UNION},msg)

	return true
end

function C2S.collect_card(player,request)
	local cardtype = assert(request.cardtype)
	local unionid = player:unionid(player.pid)
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local carddata = itemaux.getitemdata(cardtype)
	if not carddata then
		net.msg.S2C.notify(player.pid,language.format("非法卡片类型"))
		return
	end
	local maintype = itemaux.getmaintype(cardtype)
	if ItemMainType.CARD ~= maintype then
		net.msg.S2C.notify(player.pid,language.format("非法卡片类型"))
		return
	end
	local card = player.carddb:getcardbytype(cardtype)
	local neednum = 1
	if not card or card.num < neednum then
		net.msg.S2C.notify(player.pid,language.format("请先自行收集到{1}个碎片激活卡牌后再发起集卡请求",neednum))
		return
	end
	local collect_cnt = player.thisweek:query("union.collect_card.cnt") or 0
	local collect_maxcnt = data_1800_UnionVar.CollectCardSumCnt
	if collect_cnt >= collect_maxcnt then
		net.msg.S2C.notify(player.pid,language.format("本周集卡已超过#<R>{1}#次",collect_maxcnt))
		return
	end
	local incd,exceedtime = player.thistemp:query("union.collect_card.cd")
	if incd then
		local lefttime = exceedtime - os.time()
		local date = dhms_time({hour=true,min=true,sec=true},lefttime)
		net.msg.S2C.notify(player.pid,language.format("集卡CD中，剩余时间:{1}小时{2}分钟{3}秒",date.hour,date.min,date.sec))
		return
	end
	local quality = carddata.quality
	local num = data_1800_UnionVar.CollectCardMaxNumPerTime[quality]
	local isok,errmsg = unionaux.unionmethod(unionid,":collect_card",player.pid,cardtype,num)
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
	else
		player.thistemp:set("union.collect_card.cd",true,data_1800_UnionVar.CollectCardCD)
		player.thisweek:add("union.collect_card.cnt",1)
	end
end

function C2S.donate_card(player,request)
	local id = assert(request.id)
	local cardid = assert(request.cardid)
	local num = 1
	local unionid = player:unionid(player.pid)
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end

	local card = player.carddb:getcard(cardid)
	if not card then
		net.msg.S2C.notify(player.pid,language.format("你没有对应卡片"))
		return
	end
	if card.num < num then
		net.msg.S2C.notify(player.pid,language.format("没有足够的卡牌碎片，无法捐献"))
		return
	end
	local has_donate_thisweek = player.thisweek:query("union.collect_card.donate") or 0
	local max_donate_thisweek = data_1800_UnionVar.DonateCardMaxNum
	if has_donate_thisweek >= max_donate_thisweek then
		net.msg.S2C.notify(player.pid,language.format("本周集卡捐献数量已超过#<R>{1}个",max_donate_thisweek))
		return
	end
	frozen(card)
	local isok,errmsg = unionaux.unionmethod(unionid,":donate_card",id,player.pid,card.type,num)
	unfrozen(card)
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
	else
		player.carddb:costcardbyid(card.id,num,"donate_card")
		player.thisweek:add("union.collect_card.donate",num)
	end
end

function C2S.collectitem_askfor_help(player,request)
	local taskid = assert(request.taskid)
	local unionid = player:unionid()
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local task = unionaux.gettask_collectitem(player,taskid)
	if not task then
		return
	end
	if task.hasnum >= task.neednum then
		net.msg.S2C.notify(player.pid,language.format("该任务无须求助了"))
		return
	end
	if task.isbonus then
		net.msg.S2C.notify(player.pid,language.format("该任务已领取过奖励了"))
		return
	end
	if task.inhelp then
		net.msg.S2C.notify(player.pid,language.format("该任务已处于求助中"))
		return
	end
	local askfor_help_cnt = player.today:query("union.collectitem.askfor_help_cnt") or 0
	local askfor_help_maxcnt = data_1800_UnionCollectItemVar.AskForHelpMaxCnt
	if askfor_help_cnt > askfor_help_maxcnt then
		net.msg.S2C.notify(player.pid,language.format("公会收集每日求助次数不能超过#<R>{1}次",askfor_help_maxcnt))
		return
	end
	task.inhelp = true
	player.today:add("union.collectitem.askfor_help_cnt",1)
	unionaux.unionmethod(unionid,":broadcast","members","union","collectitem_askfor_help_task",{
		pid = player.pid,
		task = task,
	})
end

function C2S.collectitem_donate(player,request)
	local tid = assert(request.pid)
	local taskid = assert(request.taskid)
	local itemtype = assert(request.itemtype)
	local itemnum = assert(request.itemnum)
	if player.pid == tid then
		net.msg.S2C.notify(player.pid,language.format("无法给自己捐献物品"))
		return
	end
	local unionid = player:unionid()
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local donate_cnt = player.today:query("union.collectitem.donate_cnt") or 0
	local donate_maxcnt = data_1800_UnionCollectItemVar.DonateMaxCnt
	if donate_cnt >= donate_maxcnt then
		net.msg.S2C.notify(player.pid,language.format("公会收集每日捐献次数不能超过#<R>{1}次",donate_maxcnt))
		return
	end

	local hasnum = player.itemdb:getnumbytype(itemtype)
	if hasnum < itemnum then
		net.msg.S2C.notify(player.pid,language.format("{1}数量不足#<R>{2}#个",itemaux.itemlink(itemtype),itemnum))
		return
	end
	local items = player.itemdb:getitemsbytype(itemtype)
	for i,item in ipairs(items) do
		frozen(item)
	end
	local isok,errmsg = rpc.callplayer(tid,"playermethod",tid,":union_collectitem_donate",{
		unionid = unionid,
		pid = player.pid,
		taskid = taskid,
		itemtype = itemtype,
		itemnum = itemnum
	})
	for i,item in ipairs(items) do
		unfrozen(item)
	end
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
	else
		local reason = "union.collectitem_donate"
		player.today:add("union.collectitem.donate_cnt",1)
		player.itemdb:costitembytype(itemtype,itemnum,reason)
		net.msg.S2C.notify(player.pid,language.format("消耗#<II{1}>#{2}-{3}",itemtype,itemaux.itemlink(itemtype),itemnum))
		local bonus = data_1800_UnionCollectItemAward[player.lv]
		doaward("player",player.pid,bonus,reason,true)
	end
end

function C2S.collectitem_submit(player,request)
	local taskid = assert(request.taskid)
	local itemtype = assert(request.itemtype)
	local itemnum = assert(request.itemnum)
	local unionid = player:unionid()
	if not unionid then
		net.msg.S2C.notify(player.pid,language.format("你没有公会"))
		return
	end
	local hasnum = player.itemdb:getnumbytype(itemtype)
	if hasnum < itemnum then
		net.msg.S2C.notify(player.pid,language.format("{1}数量不足#<R>{2}#个",itemaux.itemlink(itemtype),itemnum))
		return
	end
	local isok,errmsg = player:union_collectitem_submit({
		taskid = taskid,
		itemtype = itemtype,
		itemnum = itemnum,
	})
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
	else
		local reason = "union.collectitem_submit"
		player.itemdb:costitembytype(itemtype,itemnum,reason)
		net.msg.S2C.notify(player.pid,language.format("消耗#<II{1}>#{2}-{3}",itemtype,itemaux.itemlink(itemtype),itemnum))
	end
end

function C2S.collectitem_finishtask(player,request)
	local taskid = assert(request.taskid)
	local isok,errmsg = player:union_collectitem_finishtask(taskid)
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
	else
	end
end

function C2S.checkname(player,request)
	local name = assert(request.name)
	local srvname = globalmgr.home_srvname(player.pid)
	local isok,errmsg
	if cserver.isunionsrv() then
		isok,errmsg = unionmgr:isvalid_name(name,srvname)
	else
		isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","unionmgr:isvalid_name",name,srvname)
	end
	sendpackage(player.pid,"union","checkname_result",{
		result = isok,
	})
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return
	end
end

-- s2c
function S2C.publish_purpose(msg)
	local pack = {
		sender = {
			pid = SENDER.UNION,
		},
	}
	for i,pid in ipairs(playermgr.allplayer()) do
		local player = playermgr.getplayer(pid)
		if player and not player:unionid() then
			local translate_msg
			if type(msg) == "table" then
				local lang = playeraux.getlanguage(pid)
				translate_msg = language.translateto(msg,lang)
			else
				translate_msg = msg
			end
			pack.msg = translate_msg
			sendpackage(pid,"msg","unionmsg",pack)
		end
	end
end

return netunion
