--<<data_1599_TestTaskProcess 导表开始>>
data_1599_TestTaskProcess = {

	[90000001] = {
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
		acceptnpc = 0,
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
		type = 2,
		name = "测试寻物",
		accept = {
			{ cmd = 'needitem', args = { type = 501001, num = 1, }, },
			{ cmd = 'addnpc', args = { nid = 102, }, },
			{ cmd = 'talkto', args = { textid = 102, }, },
		},
		execution = {
			{ cmd = 'handinitem', args = { nid = 102, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
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
		type = 4,
		name = "测试战斗",
		accept = {
			{ cmd = 'setpatrol', args = { posid = "8101001", }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 101, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
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

}
return data_1599_TestTaskProcess
--<<data_1599_TestTaskProcess 导表结束>>