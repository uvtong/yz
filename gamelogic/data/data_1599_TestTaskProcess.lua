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
		submitnpc = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 10,
		award = {[101]=10},
		nexttask = nil,
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事",
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
		submitnpc = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 10,
		award = {[101]=10,[102]=10},
		nexttask = nil,
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事",
	},

	[90000003] = {
		type = 3,
		name = "测试战斗",
		accept = {
			{ cmd = 'setpatrol', args = { mapid = 1001, pos = { x = 10, y = 10, }, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 101, }, },
		},
		finishbyclient = 0,
		submitnpc = 1001,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 10,
		award = {[103]=10},
		nexttask = "other",
		chapterid = 0,
		icon_id = 93051,
		desc = "长安似乎发生了些什么怪事",
	},

}
return data_1599_TestTaskProcess
--<<data_1599_TestTaskProcess 导表结束>>