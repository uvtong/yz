
gm = require "gamelogic.gm.init"

--- 指令: test
--- 用法: test test_filename json_str
function gm.test(args)
	local isok,args = checkargs(args,"string","string")
	if not isok then
		gm.notify("用法: test test_filename json_str")
		return
	end
	local test_filename = args[1]
	local func = require ("gamelogic.test." .. test_filename)
	local tbl = cjson.decode(args[2])
	print(format("test %s %s",test_filename,tbl))
	func(table.unpack(tbl))
	print(string.format("test %s ok",test_filename))
end

function gm.testfunc(args)
	local choice = tonumber(args[1]) or 1
	local mail = {
		srcid = SYSTEM_MAIL,
		author = language.format("公会管理员"),
		title = language.format("公会会长竞选"),
		content = language.format([[由于#<R>{1}#会长#<R>{2}#长时间不在线，副会长#<R>{3}#正式发起会长竞选，
申请成为本公会的公会会长，请问你是否反对？
投票剩余时间：{4}小时{5}分]],1,2,3,4,5),
	}
	if choice == 1 then
	elseif choice == 2 then
		mail.attach = {
			gold = 10,
			coin = 20,
			items = {
				{type=801001,num=10},
				{type=801002,num=10},
			}
		}
	elseif choice == 3 then
		buttons = {language.format("【考虑一下】"),language.format("【我要反对】"),language.format("【竞选规则】"),}
		callback = pack_function("net.msg.S2C.notify",master_pid,"已收到回复")
	end
	mailmgr.sendmail(master_pid,mail)
end

function gm.testfunc2(args)
	local packmsg = {
		sender = {
			pid = tonumber(args[1]) or 0,
		},
		msg = "test"
	}
	channel.publish("world",{
		p = "msg",
		s = "worldmsg",
		a = packmsg,
	})
end

return gm
