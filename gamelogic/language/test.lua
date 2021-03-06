local data_language = {
	[1] = {
		cn = "#<G>{1}#等级不足#<R>{2}转{3}级#",
		en = "level has not enough #<R>{2} zhuan {3} ji# with #<G>{1}#",
		ja = "#<G>{1}#等级不足#<R>{2}转{3}级#--假装这是日文",
	},
	[2] = {
		cn = "未翻译语句",
		en = "",
		ja = "",
	},
	[3] = {
		cn = "{target}<=>目标,{npc}<=>npc",
		en = "{target}<=>target,{npc}<=>npc",
		ja = "{target}<=>target,{npc}<=>npc--假装这是日文",
	},

}

local function test()
	local language = require "language.init"
	language.init({
		language_from = "cn",
		language_to = "en",
		-- 不传翻译表，底层会用全局翻译表:data_language
		translate_table = data_language,
	})

	local packstr = language.format("#<G>{1}#等级不足#<R>{2}转{3}级#","$玩家名",1,60)
	local str = language.translateto(packstr)
	print(str)
	local str = language.translateto(packstr,"en")
	print(str)
	local str = language.translateto(packstr,"ja")
	print(str)
	local packstr = language.format("无参数翻译语句也要用language.format")
	local str = language.translateto(packstr,"en")
	print(str)
	local packstr = language.format("无参数翻译语句也要用language.format,{1}","需要翻译的参数")
	local str = language.translateto(packstr,"en")
	print(str)
	local packstr = language.format("未翻译语句,{1}","未翻译语句")
	local str = language.translateto(packstr,"en")
	print(str)

	local packstr = language.format("未翻译语句,{1}",string.format("未翻译语句1"),language.format("未翻译的语句2"))
	local str = language.translateto(packstr,"en")
	print(str)

	local packstr = language.format('单引号括住的翻译语句',string.format('单引号括住的翻译语句1'),language.format('单引号括住的翻译语句2'))
	local str = language.translateto(packstr,"en")
	print(str)

	print("--------------")
	local str = language.formatto("en","#<G>{1}#等级不足#<R>{2}转{3}级#","$玩家名",1,60)
	print(str)
	-- 翻译成默认语言
	local str = language.format2("#<G>{1}#等级不足#<R>{2}转{3}级#","$玩家名",1,60)
	print(str)

	-- 未翻译的字符串，最后少了一个"#"
	local packstr = language.format("#<G>{1}#等级不足#<R>{2}转{3}级","$玩家名",1,60)
	local str = language.translateto(packstr,"en")
	print(str)

	-- 翻译两个相同串
	local packstr = language.format("#<G>{1}#等级不足#<R>{2}转{3}级#","#<G>{1}#等级不足#<R>{2}转{3}级#",1,60)
	local str = language.translateto(packstr,"en")
	print(str)

	-- 传递字典参数进行翻译
	local packstr = language.format("{target}<=>目标,{npc}<=>npc",{target="目标",npc="npc90001"})
	local str = language.translateto(packstr,"en")
	print(str)
end

-- test by: lua language/test.lua
test()

