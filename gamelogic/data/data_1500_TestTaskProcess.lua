--<<data_1500_TestTaskProcess 导表开始>>
data_1500_TestTaskProcess = {

	[90000001] = {
		id = 90000001,
		type = 1,
		name = "测试找人",
		accept = {
			{ cmd = 'addnpc', args = { nid = 101, }, },
			{ cmd = 'findnpc', args = { nid = 101, }, },
			{ cmd = 'talkto', args = { textid = 101, }, },
		},
		execution = {

		},
		finishbyclient = 1,
		acceptnpc = 90023,
		submitnpc = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 10,
		award = 101,
		nexttask = nil,
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事1",
		accepted_desc = "nil",
		executed_desc = "nil",
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
		acceptnpc = 90023,
		submitnpc = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 10,
		award = 102,
		nexttask = nil,
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事2",
		accepted_desc = "nil",
		executed_desc = "nil",
	},

	[90000003] = {
		id = 90000003,
		type = 4,
		name = "测试战斗",
		accept = {
			{ cmd = 'setpatrol', args = { posid = 8101001, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 101, }, },
		},
		finishbyclient = 0,
		acceptnpc = 90023,
		submitnpc = 90023,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 10,
		award = 103,
		nexttask = "other",
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事3",
		accepted_desc = "nil",
		executed_desc = "nil",
	},

	[90000004] = {
		id = 90000004,
		type = 1,
		name = "测试找人2",
		accept = {
			{ cmd = 'addnpc', args = { nid = 101, }, },
			{ cmd = 'findnpc', args = { nid = 101, }, },
		},
		execution = {
			{ cmd = 'confirmtalk', args = { textid = 101, }, },
			{ cmd = 'delnpc', args = { nid = 101, }, },
		},
		finishbyclient = 0,
		acceptnpc = 90023,
		submitnpc = 90023,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 0,
		award = 101,
		nexttask = nil,
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事4",
		accepted_desc = "nil",
		executed_desc = "nil",
	},

	[90000005] = {
		id = 90000005,
		type = 3,
		name = "测试战斗2",
		accept = {
			{ cmd = 'addnpc', args = { nid = 104, }, },
			{ cmd = 'findnpc', args = { nid = 104, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 101, }, },
			{ cmd = 'addnpc', args = { nid = 103, }, },
		},
		finishbyclient = 0,
		acceptnpc = 90023,
		submitnpc = 103,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 0,
		award = 102,
		nexttask = nil,
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事5",
		accepted_desc = "nil",
		executed_desc = "nil",
	},

	[90000006] = {
		id = 90000006,
		type = 5,
		name = "测试采集",
		accept = {
			{ cmd = 'setcollect', args = { posid = { 8101001,8101002 }, rand = 1, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		acceptnpc = 90023,
		submitnpc = 90023,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 10,
		award = 101,
		nexttask = nil,
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事5",
		accepted_desc = "nil",
		executed_desc = "nil",
	},

}
return data_1500_TestTaskProcess
--<<data_1500_TestTaskProcess 导表结束>>