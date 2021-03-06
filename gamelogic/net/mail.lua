
netmail = netmail or {
	C2S = {},
	S2C = {}
}

local C2S = netmail.C2S
local S2C = netmail.S2C

function C2S.openmailbox(player)
	local pid = player.pid
	local mailbox = mailmgr.getmailbox(pid)
	local mails = mailbox:getmails()    -- will del exceedtime's mail
	--local allmail = {}
	--for _,mail in ipairs(mails) do
	--	table.insert(allmail,mail:pack())
	--end
	--netmail.S2C.allmail(pid,allmail)
end

function C2S.readmail(player,request)
	local pid = player.pid
	local mailid = assert(request.mailid)
	local mailbox = mailmgr.getmailbox(pid)
	local mail = mailbox:getmail(mailid)
	if not mail then
		return
	end
	mail.readtime = os.time()
	if mail:can_autodel() then
		mailbox:delmail(mailid)
	else
		net.mail.S2C.updatemail(pid,{
			mailid = mail.mailid,
			readtime = mail.readtime,
		})
	end
end

function C2S.delmail(player,request)
	local pid = player.pid
	local mailid = assert(request.mailid)
	local mailbox = mailmgr.getmailbox(pid)
	local mail = mailbox:delmail(mailid)
end

function C2S.getattach(player,request)
	local pid = player.pid
	local mailid = assert(request.mailid)
	local mailbox = mailmgr.getmailbox(pid)
	mailbox:getattach(mailid)
end

function C2S.sendmail(player,request)
	local pid = player.pid
	local targetid = assert(request.to)
	local title = request.title or ""
	local content = request.content or ""
	local attach = request.attach or {}
	if pid == targetid then
		return
	end
	if not globalmgr.home_srvname(targetid) then
		net.msg.S2C.notify(pid,string.format("找不到id为%d的玩家",targetid))
		return
	end
	-- 玩家自己发送的邮件无须翻译，原样发送即可
	mailmgr.sendmail(targetid,{
		srcid = pid,
		author = player:query("name"),
		title = title,
		content = content,
		attach = attach,
	})

end

function C2S.delallmail(player,request)
	local pid = player.pid
	local mailbox = mailmgr.getmailbox(pid)
	mailbox:delallmail()
	netmail.S2C.allmail(pid,{})
end

function C2S.respondanswer(player,request)
	local pid = player.pid
	local mailid = assert(request.mailid)
	local answer = assert(request.answer)
	local mailbox = mailmgr.getmailbox(pid)
	local mail = mailbox:getmail(mailid)
	if not mail then
		return
	end
	if not mail.callback then
		return
	end
	local func = unpack_function(mail.callback)
	if func then
		func(player,mail,answer)
	end
end

function C2S._respondanswer(player,mail,answer)
	if mail.title == "公会会长竞选" then
		if answer ~= 2 then -- 我要反对
			return
		end
		local unionid = player:unionid()
		if not unionid then
			net.msg.S2C.notify(player.pid,language.format("你没有公会"))
			return
		end
		local isok,errmsg
		if cserver.isunionsrv() then
			isok,errmsg = net.union.C2S._voteto("竞选会长",player.pid)
		else
			isok,errmsg = rpc.call(cserver.unionsrv(),"rpc","net.union.C2S._voteto","竞选会长",player.pid)
		end
		if not isok then
			if errmsg then
				net.msg.S2C.notify(player.pid,errmsg)
			end
			return
		else
			net.msg.S2C.notify(player.pid,language.format("已成功投票"))
		end
	end
end

-- s2c
function S2C.syncmail(pid,mail)
	sendpackage(pid,"mail","syncmail",{
		mail = mail,
	})
end

function S2C.allmail(pid,mails)
	sendpackage(pid,"mail","allmail",{
		mails = mails,
	})
end

function S2C.delmail(pid,mailid)
	sendpackage(pid,"mail","delmail",{
		mailid = mailid
	})
end

function S2C.updatemail(pid,mail)
	sendpackage(pid,"mail","updatemail",{
		mail = mail,
	})
end

return netmail
