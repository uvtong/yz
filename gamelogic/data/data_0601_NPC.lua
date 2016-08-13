--<<data_0601_NPC 导表开始>>
data_0601_NPC = {

	[90022] = {
		name = "黑市商人",
		shape = 20043,
		transparency = 0,
		posid = "8101001",
		button_ids = {},
		header_flag = 0,
		appear_time = {},
		disappear_time = {},
		is_festival_npc = 0,
		is_fix_npc = 1,
		dir = 3,
		talk = "请把愿望写在许愿卡里,再绑到圣诞树的树枝上。",
	},

	[90023] = {
		name = "糟老头",
		shape = 30011,
		transparency = 0,
		posid = "8101002",
		button_ids = {},
		header_flag = 0,
		appear_time = {},
		disappear_time = {},
		is_festival_npc = 0,
		is_fix_npc = 1,
		dir = 5,
		talk = "你想变得像我一样酷？那就戴上圣诞帽吧！",
	},

	[90024] = {
		name = "市场总管",
		shape = 30013,
		transparency = 0,
		posid = "8101003",
		button_ids = {1074},
		header_flag = 0,
		appear_time = {},
		disappear_time = {},
		is_festival_npc = 0,
		is_fix_npc = 1,
		dir = 5,
		talk = "我找到有关于月光宝盒的线索了！",
	},

	[90025] = {
		name = "皇城守将",
		shape = 11002,
		transparency = 0,
		posid = "8101004",
		button_ids = {1071,1072,1124},
		header_flag = 8,
		appear_time = {},
		disappear_time = {},
		is_festival_npc = 0,
		is_fix_npc = 1,
		dir = 5,
		talk = "人间功名利禄尽在我掌控之中。",
	},

	[90026] = {
		name = "圣诞熊猫",
		shape = 20008,
		transparency = 0,
		posid = "8101005",
		button_ids = {1067,1179,1068,1088  },
		header_flag = 0,
		appear_time = {year=2016,mon=06,day=29,hour=05,min=0,sec=0},
		disappear_time = {year=2016,mon=06,day=29,hour=08,min=0,sec=0},
		is_festival_npc = 0,
		is_fix_npc = 1,
		dir = 5,
		talk = "人间福气分配都由我所掌控。",
	},

}
return data_0601_NPC
--<<data_0601_NPC 导表结束>>