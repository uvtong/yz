openui = openui or {}

--[[
function onbuysomething(pid,request,response)
	local player = playermgr.getplayer(pid)
	local answer = response.answer
	--if not answer or answer == 0 then	-- timeout
	--elseif answer == -1 then			-- close window
	if openui.istimeout(answer) then
	elseif openui.isclose(answer) then
	elseif answer == 1 then				-- button 1
	elseif answer == 2 then				-- button 2
	end
end

openui.messagebox(10001,{
				type = MB_LACK_CONDITION,
				title = "条件不足",
				content = "是否花费100金币购买:",
				buttons = {
					openui.button("确认"),
					openui.button("取消",10),
				},
				attach = {
					lackres = {
						silver = 1000,
						items = {
							{
								itemid = 14101,
								num = 3,
							},
							{
								itemid = 14201,
								num = 2,
							},
						},
					},
					costgold = 100,
				}}
				,onbuysomething)
--]]


function openui.messagebox(pid,request,callback)
	local now_srvname,isonline = globalmgr.now_srvname(pid)
	local self_srvname = cserver.getsrvname()
	if not isonline then
		return
	end
	local id = reqresp.req(pid,request,callback)
	if now_srvname == self_srvname then
		openui._messagebox(pid,request,id)
	else
		rpc.call(now_srvname,"rpc","openui._messagebox",pid,request,id)
	end
	return id
end

function openui._messagebox(pid,request,id)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	local lang = playeraux.getlanguage(player.pid)
	local pack_request = {}
	pack_request.type = assert(request.type)
	if request.title then
		pack_request.title = assert(language.translateto(request.title,lang))
	end
	if request.content then
		pack_request.content = assert(language.translateto(request.content,lang))
	end
	if request.attach then
		pack_request.attach = cjson.encode(request.attach)
	end
	pack_request.buttons = {}
	for i,button in ipairs(request.buttons) do
		local content = button.content
		if type(content) == "table" then
			content = language.translateto(button.content,lang)
		end
		pack_request.buttons[i] = {
			content = content,
			timeout = button.timeout,
		}
	end
	pack_request.forward = request.forward
	pack_request.id = id
	sendpackage(pid,"msg","messagebox",pack_request)
end


function openui.button(content,timeout)
	return {
		content = content,
		timeout = timeout,
	}
end

function openui.istimeout(answer)
	return (not answer or answer == 0)
end

function openui.isclose(answer)
	return answer == -1
end

-- 一些其他弹框杂项
-- 打造物品成功
function openui.produceequip_succ(pid,itemid)
	sendpackage(pid,"item","produceequip_succ",{
		itemid = itemid,
	})
end

return openui
