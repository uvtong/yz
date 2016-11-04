--<<data_1500_TestTaskProcess 导表开始>>
data_1500_TestTaskProcess = {

	[90000001] = {
		id = 90000001,
		type = 1,
		name = "测试找人",
		accept = {
			{ cmd = 'addnpc', args = { nid = 101, }, },
			{ cmd = 'findnpc', args = { nid = 101, respond = 0, }, },
			{ cmd = 'talkto', args = { textid = 101, }, },
		},
		execution = {

		},
		finishbyclient = 1,
		autoexec = 0,
		acceptnpc = 20001001,
		submitnpc = 0,
		recommendteam = 2,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 10,
		award = 101,
		nexttask = "nil",
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事1",
		accepted_desc = "测试找人",
		executed_desc = "回去提交",
	},

	[90000002] = {
		id = 90000002,
		type = 2,
		name = "测试寻物",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 102,101 }, both = 1, }, },
			{ cmd = 'needitem', args = { type = 501001, num = 1, nid = 102, }, },
			{ cmd = 'talkto', args = { textid = 102, }, },
		},
		execution = {
			{ cmd = 'handinitem', args = {}, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 20001001,
		submitnpc = 0,
		recommendteam = 2,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 10,
		award = 102,
		nexttask = "nil",
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事2",
		accepted_desc = "测试寻物",
		executed_desc = "回去提交",
	},

	[90000003] = {
		id = 90000003,
		type = 4,
		name = "测试战斗",
		accept = {
			{ cmd = 'setpatrol', args = { posid = 21001001, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 101, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 1,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 10,
		award = 103,
		nexttask = "other",
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事3",
		accepted_desc = "测试战斗",
		executed_desc = "回去提交",
	},

	[90000004] = {
		id = 90000004,
		type = 1,
		name = "测试找人2",
		accept = {
			{ cmd = 'addnpc', args = { nid = 101, }, },
			{ cmd = 'findnpc', args = { nid = 101, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 101, }, },
			{ cmd = 'delnpc', args = { nid = 101, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 2,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 0,
		award = 101,
		nexttask = "nil",
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事4",
		accepted_desc = "测试找人2",
		executed_desc = "回去提交",
	},

	[90000005] = {
		id = 90000005,
		type = 3,
		name = "测试战斗2",
		accept = {
			{ cmd = 'addnpc', args = { nid = 104, }, },
			{ cmd = 'findnpc', args = { nid = 104, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 101, }, },
			{ cmd = 'addnpc', args = { nid = 103, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 20001001,
		submitnpc = 103,
		recommendteam = 1,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 0,
		award = 102,
		nexttask = "nil",
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事5",
		accepted_desc = "测试战斗2",
		executed_desc = "回去提交",
	},

	[90000006] = {
		id = 90000006,
		type = 5,
		name = "测试采集",
		accept = {
			{ cmd = 'setcollect', args = { posid = { 21001001,21001002 },  name = nil, rand = 1, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 2,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 10,
		award = 101,
		nexttask = "nil",
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事5",
		accepted_desc = "测试采集",
		executed_desc = "回去提交",
	},

	[90000007] = {
		id = 90000007,
		type = 6,
		name = "测试答题",
		accept = {
			{ cmd = 'talkto', args = { textid = 102, }, },
			{ cmd = 'findnpc', args = { nid = 20001001, respond = 0, }, },
		},
		execution = {
			{ cmd = 'taskdati', args = { mincorrect = 2, maxcnt = 3, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 0,
		award = 101,
		nexttask = "nil",
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事5",
		accepted_desc = "测试答题",
		executed_desc = "回去提交",
	},

	[90000008] = {
		id = 90000008,
		type = 6,
		name = "测试答题2",
		accept = {
			{ cmd = 'talkto', args = { textid = 102, }, },
			{ cmd = 'findnpc', args = { nid = 20001001, respond = 0, }, },
		},
		execution = {
			{ cmd = 'taskdati', args = { mincorrect = nil, maxcnt = nil, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 0,
		award = 101,
		nexttask = "nil",
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事5",
		accepted_desc = "测试答题",
		executed_desc = "回去提交",
	},

	[90000009] = {
		id = 90000009,
		type = 2,
		name = "测试寻物",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 102,101 }, both = 1, }, },
			{ cmd = 'needitem', args = { type = 1002, num = 15, nid = 102, }, },
			{ cmd = 'talkto', args = { textid = 102, }, },
		},
		execution = {
			{ cmd = 'handinitem', args = {}, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 20001001,
		submitnpc = 0,
		recommendteam = 2,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 10,
		award = 102,
		nexttask = "nil",
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事2",
		accepted_desc = "测试寻物",
		executed_desc = "回去提交",
	},

	[90000010] = {
		id = 90000010,
		type = 1,
		name = "测试找人2",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 102,101 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 101, respond = 0, }, },
		},
		execution = {
			{ cmd = 'optiontalkto', args = { textid = 106, option1 = 101, option2 = 102, option3 = 103, option4 = 104, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 20001001,
		submitnpc = 0,
		recommendteam = 2,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 10,
		award = 101,
		nexttask = "nil",
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事2",
		accepted_desc = "测试寻物",
		executed_desc = "回去提交",
	},

	[90000011] = {
		id = 90000011,
		type = 1,
		name = "测试找人2",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 102,101 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 101, respond = 0, }, },
		},
		execution = {
			{ cmd = 'openui', args = { buttonid = 10001, }, },
			{ cmd = 'dingzhi', args = {}, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 20001001,
		submitnpc = 0,
		recommendteam = 2,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 10,
		award = 101,
		nexttask = "nil",
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事2",
		accepted_desc = "测试寻物",
		executed_desc = "回去提交",
	},

}
return data_1500_TestTaskProcess
--<<data_1500_TestTaskProcess 导表结束>>