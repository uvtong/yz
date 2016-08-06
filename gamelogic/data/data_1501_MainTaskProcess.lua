--<<data_1501_MainTaskProcess 导表开始>>
data_1501_MainTaskProcess = {

	[10000101] = {
		type = 3,
		name = "初战",
		accept = {
			{ cmd = 'addnpc', args = { nid = 1001, }, },
			{ cmd = 'talkto', args = { textid = 1100001, }, },
			{ cmd = 'findnpc', args = { nid = 1002, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1100002, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 1001,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 1,
		award = 101,
		nexttask = 10100102,
		chapterid = 10001,
		icon_id = 0,
		desc = "主线测试1",
		accepted_desc = "击败吉祥物",
		executed_desc = "与伊菲对话",
	},

	[10000102] = {
		type = 3,
		name = "花儿为何这样红",
		accept = {
			{ cmd = 'addnpc', args = { nid = 1003, }, },
			{ cmd = 'talkto', args = { textid = 1100003, }, },
			{ cmd = 'findnpc', args = { nid = 1003, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1100004, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 1001,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000101.0},
		ratio = 1,
		award = 102,
		nexttask = 10100103,
		chapterid = 10002,
		icon_id = 0,
		desc = "主线测试2",
		accepted_desc = "击败熊孩子",
		executed_desc = "与熊孩子对话",
	},

	[10000103] = {
		type = 3,
		name = "论熊孩子的养成",
		accept = {
			{ cmd = 'addnpc', args = { nid = 1004, }, },
			{ cmd = 'findnpc', args = { nid = 1004, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1100005, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 1004,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000102.0},
		ratio = 1,
		award = 103,
		nexttask = 10100104,
		chapterid = 10003,
		icon_id = 0,
		desc = "主线测试3",
		accepted_desc = "击败村民",
		executed_desc = "与村民对话",
	},

	[10000104] = {
		type = 3,
		name = "路见不平一声吼",
		accept = {
			{ cmd = 'addnpc', args = { nid = 1005, }, },
			{ cmd = 'findnpc', args = { nid = 1005, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1100006, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 1005,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000103.0},
		ratio = 1,
		award = 104,
		nexttask = 10100105,
		chapterid = 10004,
		icon_id = 0,
		desc = "主线测试4",
		accepted_desc = "击败村民",
		executed_desc = "与女勇者对话",
	},

	[10000105] = {
		type = 3,
		name = "有理也得拳头硬",
		accept = {
			{ cmd = 'addnpc', args = { nid = 1006, }, },
			{ cmd = 'findnpc', args = { nid = 1006, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1100007, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 1006,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000104.0},
		ratio = 1,
		award = 105,
		nexttask = 10100106,
		chapterid = 10005,
		icon_id = 0,
		desc = "主线测试5",
		accepted_desc = "击败村长",
		executed_desc = "与村长对话",
	},

	[10000106] = {
		type = 3,
		name = "这个世界我不懂",
		accept = {
			{ cmd = 'addnpc', args = { nid = 1005, }, },
			{ cmd = 'talkto', args = { textid = 1100008, }, },
			{ cmd = 'findnpc', args = { nid = 1005, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1100009, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 1005,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000105.0},
		ratio = 1,
		award = 106,
		nexttask = 10100107,
		chapterid = 10006,
		icon_id = 0,
		desc = "主线测试6",
		accepted_desc = "击败蘑菇",
		executed_desc = "与女勇者对话",
	},

	[10000107] = {
		type = 3,
		name = "要不要这么夸张",
		accept = {
			{ cmd = 'addnpc', args = { nid = 1007, }, },
			{ cmd = 'talkto', args = { textid = 1100010, }, },
			{ cmd = 'findnpc', args = { nid = 1007, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1100011, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 1007,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000106.0},
		ratio = 1,
		award = 107,
		nexttask = 10100108,
		chapterid = 10007,
		icon_id = 0,
		desc = "主线测试7",
		accepted_desc = "击败士兵",
		executed_desc = "与士兵对话",
	},

	[10000108] = {
		type = 3,
		name = "兄弟咱是一伙的",
		accept = {
			{ cmd = 'addnpc', args = { nid = 1007, }, },
			{ cmd = 'findnpc', args = { nid = 1007, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1100012, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 1008,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000107.0},
		ratio = 1,
		award = 108,
		nexttask = 10100109,
		chapterid = 10008,
		icon_id = 0,
		desc = "主线测试8",
		accepted_desc = "击败士兵",
		executed_desc = "与剑士对话",
	},

	[10000109] = {
		type = 3,
		name = "原来是想吃独食",
		accept = {
			{ cmd = 'addnpc', args = { nid = 1008, }, },
			{ cmd = 'findnpc', args = { nid = 1008, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1100013, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 1008,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000108.0},
		ratio = 1,
		award = 109,
		nexttask = 10100110,
		chapterid = 10009,
		icon_id = 0,
		desc = "主线测试9",
		accepted_desc = "击败剑士",
		executed_desc = "与剑士对话",
	},

	[10000110] = {
		type = 3,
		name = "好人真是不太多",
		accept = {
			{ cmd = 'addnpc', args = { nid = 1008, }, },
			{ cmd = 'findnpc', args = { nid = 1008, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1100014, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 1009,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000109.0},
		ratio = 1,
		award = 110,
		nexttask = nil,
		chapterid = 10010,
		icon_id = 0,
		desc = "主线测试10",
		accepted_desc = "击败剑士",
		executed_desc = "与爱拉忒对话",
	},

}
return data_1501_MainTaskProcess
--<<data_1501_MainTaskProcess 导表结束>>