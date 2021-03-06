--<<data_1500_BranchTaskProcess 导表开始>>
data_1500_BranchTaskProcess = {

	[10100100] = {
		id = 10100100,
		type = 1,
		name = "迷路的思莉嘉",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 100011,100021 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 100011, respond = 1, }, },
		},
		execution = {
			{ cmd = 'addnpc', args = { nid = { 100031,100041 }, both = 1, }, },
		},
		finishbyclient = 0,
		autoexec = 1,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 1,
		award = 10100100,
		nexttask = "10100101",
		chapterid = 10100100,
		icon_id = 0,
		desc = "与伊菲对话",
		accepted_desc = "与伊菲对话",
		executed_desc = "与伊菲对话",
	},

	[10100101] = {
		id = 10100101,
		type = 3,
		name = "迷路的思莉嘉",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 101011,101021,101031,101041 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 1011, }, },
			{ cmd = 'findnpc', args = { nid = 101041, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 110101, }, },
			{ cmd = 'talkto', args = { textid = 1012, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10100100},
		ratio = 1,
		award = 10100101,
		nexttask = "10100102",
		chapterid = 10100101,
		icon_id = 0,
		desc = "光天化日居然有人欺负小朋友！过去看看,好好教训他一顿。",
		accepted_desc = "击败恶霸",
		executed_desc = "恶霸对话",
	},

	[10100102] = {
		id = 10100102,
		type = 1,
		name = "迷路的思莉嘉",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 102011,102021,102031 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 1021, }, },
			{ cmd = 'findnpc', args = { nid = 20001003, respond = 1, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1022, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 20001003,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10100101},
		ratio = 1,
		award = 10100102,
		nexttask = "10100103",
		chapterid = 10100102,
		icon_id = 0,
		desc = "这不是思莉嘉吗,她怎么在这里？快去问问吧。",
		accepted_desc = "与肉铺老板对话",
		executed_desc = "与肉铺老板对话",
	},

	[10100103] = {
		id = 10100103,
		type = 5,
		name = "迷路的思莉嘉",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 103011,103021,103031 }, both = 1, }, },
			{ cmd = 'setcollect', args = { posid = 21001003,  name = "交代事情经过", }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1032, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10100102},
		ratio = 1,
		award = 10100103,
		nexttask = "10100104",
		chapterid = 10100103,
		icon_id = 0,
		desc = "从老板处买一些熟牛肉给思莉嘉吃吧。",
		accepted_desc = "与伊菲对话",
		executed_desc = "与伊菲对话",
	},

	[10100104] = {
		id = 10100104,
		type = 5,
		name = "迷路的思莉嘉",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 104011,104021,104031 }, both = 1, }, },
			{ cmd = 'setcollect', args = { posid = 21001001,  name = "张贴布告并等待", }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1042, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10100103},
		ratio = 1,
		award = 10100104,
		nexttask = "10100105",
		chapterid = 10100104,
		icon_id = 0,
		desc = "在王城中张贴布告,帮助思莉嘉寻找失散的亲人。",
		accepted_desc = "张贴布告",
		executed_desc = "与伊菲对话",
	},

	[10100105] = {
		id = 10100105,
		type = 3,
		name = "迷路的思莉嘉",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 105011,105021,105031,105041,105051 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 1051, }, },
			{ cmd = 'findnpc', args = { nid = 105041, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 110102, }, },
			{ cmd = 'talkto', args = { textid = 1052, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10100104},
		ratio = 1,
		award = 10100105,
		nexttask = "10100106",
		chapterid = 10100105,
		icon_id = 0,
		desc = "税官嘉卡又来滋事,让他知道勇者的厉害！",
		accepted_desc = "击败嘉卡",
		executed_desc = "与嘉卡对话",
	},

	[10100106] = {
		id = 10100106,
		type = 1,
		name = "迷路的思莉嘉",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 106011,106021,106031,106041 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 1061, }, },
			{ cmd = 'findnpc', args = { nid = 106031, respond = 1, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1062, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 106031,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10100105},
		ratio = 1,
		award = 10100106,
		nexttask = "nil",
		chapterid = 10100106,
		icon_id = 0,
		desc = "思莉嘉的亲人来了,这个人真的是思莉嘉的姑姑吗？",
		accepted_desc = "与思莉嘉对话",
		executed_desc = "与思莉嘉对话",
	},

	[10100200] = {
		id = 10100200,
		type = 1,
		name = "美味的酬谢",
		accept = {
			{ cmd = 'addnpc', args = { nid = 200011, }, },
			{ cmd = 'findnpc', args = { nid = 200011, respond = 1, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		autoexec = 1,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 1,
		award = 10100200,
		nexttask = "10100201",
		chapterid = 10100200,
		icon_id = 0,
		desc = "小伙伴们都饿坏了,去找点吃的吧~",
		accepted_desc = "找一些事物",
		executed_desc = "与纯色吉祥物首领对话",
	},

	[10100201] = {
		id = 10100201,
		type = 4,
		name = "美味的酬谢",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 201011,201021 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 2011, }, },
			{ cmd = 'setpatrol', args = { posid = 21001003, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 110103, }, },
			{ cmd = 'addnpc', args = { nid = { 201031,201041,201051 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 2012, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10100200},
		ratio = 1,
		award = 10100201,
		nexttask = "10100202",
		chapterid = 10100201,
		icon_id = 0,
		desc = "小伙伴们都饿坏了,去找点吃的吧~",
		accepted_desc = "找一些事物",
		executed_desc = "与纯色吉祥物首领对话",
	},

	[10100202] = {
		id = 10100202,
		type = 4,
		name = "美味的酬谢",
		accept = {
			{ cmd = 'setpatrol', args = { posid = 21001001, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 110104, }, },
			{ cmd = 'addnpc', args = { nid = { 202011,202021,202031 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 2022, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10100201},
		ratio = 1,
		award = 10100202,
		nexttask = "10100203",
		chapterid = 10100202,
		icon_id = 0,
		desc = "到【某地】帮吉祥物采集一些红铜矿吧。",
		accepted_desc = "采集红铜矿",
		executed_desc = "与混色吉祥物首领对话",
	},

	[10100203] = {
		id = 10100203,
		type = 5,
		name = "美味的酬谢",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 203011,203021,203031 }, both = 1, }, },
			{ cmd = 'setcollect', args = { posid = 21001003,  name = "大脚踢飞", }, },
		},
		execution = {
			{ cmd = 'delnpc', args = { nid = 203011, }, },
			{ cmd = 'talkto', args = { textid = 2032, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10100202},
		ratio = 1,
		award = 10100203,
		nexttask = "10100204",
		chapterid = 10100203,
		icon_id = 0,
		desc = "吉祥物首领太过分了,不能放纵这群小家伙。",
		accepted_desc = "踢飞混色吉祥物首领",
		executed_desc = "与混色吉祥物喽啰对话",
	},

	[10100204] = {
		id = 10100204,
		type = 1,
		name = "美味的酬谢",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 204011,204021,204031 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 204011, respond = 1, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 2042, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10100203},
		ratio = 1,
		award = 10100204,
		nexttask = "10100205",
		chapterid = 10100204,
		icon_id = 0,
		desc = "红铜矿到手了,把它交给纯色吉祥物吧",
		accepted_desc = "与纯色吉祥物首领对话",
		executed_desc = "与纯色吉祥物首领对话",
	},

	[10100205] = {
		id = 10100205,
		type = 1,
		name = "美味的酬谢",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 205011,205021 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 205011, respond = 1, }, },
		},
		execution = {
			{ cmd = 'optiontalkto', args = { textid = 2052, option1 = 101002051, option2 = 101002052, option3 = nil, option4 = nil, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 205011,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10100204},
		ratio = 1,
		award = 0,
		nexttask = "nil",
		chapterid = 10100205,
		icon_id = 0,
		desc = "快拿着美味的食物回去找伊菲吧",
		accepted_desc = "与伊菲对话",
		executed_desc = "与伊菲对话",
	},

}
return data_1500_BranchTaskProcess
--<<data_1500_BranchTaskProcess 导表结束>>