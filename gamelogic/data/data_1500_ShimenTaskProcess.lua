--<<data_1500_ShimenTaskProcess 导表开始>>
data_1500_ShimenTaskProcess = {

	[10200101] = {
		id = 10200101,
		type = 1,
		name = "协会请援",
		accept = {
			{ cmd = 'addnpc', args = { nid = 10201, }, },
			{ cmd = 'findnpc', args = { nid = 10201, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = nil, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1000,
		award = -1,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "寻人任务1",
		executed_desc = "回到协会提交任务",
	},

	[10200102] = {
		id = 10200102,
		type = 1,
		name = "协会请援",
		accept = {
			{ cmd = 'addnpc', args = { nid = 10202, }, },
			{ cmd = 'findnpc', args = { nid = 10202, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = nil, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1000,
		award = -2,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "寻人任务2",
		executed_desc = "回到协会提交任务",
	},

	[10200103] = {
		id = 10200103,
		type = 1,
		name = "协会请援",
		accept = {
			{ cmd = 'addnpc', args = { nid = 10203, }, },
			{ cmd = 'findnpc', args = { nid = 10203, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = nil, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1000,
		award = -1,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "寻人任务3",
		executed_desc = "回到协会提交任务",
	},

	[10200104] = {
		id = 10200104,
		type = 1,
		name = "协会请援",
		accept = {
			{ cmd = 'findnpc', args = { nid = 20001002, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = nil, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1000,
		award = -2,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "寻人任务4",
		executed_desc = "回到协会提交任务",
	},

	[10200105] = {
		id = 10200105,
		type = 1,
		name = "协会请援",
		accept = {
			{ cmd = 'findnpc', args = { nid = 20001003, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = nil, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1000,
		award = -1,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "寻人任务5",
		executed_desc = "回到协会提交任务",
	},

	[10200201] = {
		id = 10200201,
		type = 2,
		name = "协会请援",
		accept = {
			{ cmd = 'addnpc', args = { nid = 10204, }, },
			{ cmd = 'needitem', args = { type = 101001, num = 1, nid = 10204, }, },
		},
		execution = {
			{ cmd = 'handinitem', args = {}, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1500,
		award = -2,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "寻物任务1",
		executed_desc = "回到协会提交任务",
	},

	[10200202] = {
		id = 10200202,
		type = 2,
		name = "协会请援",
		accept = {
			{ cmd = 'addnpc', args = { nid = 10205, }, },
			{ cmd = 'needitem', args = { type = 101002, num = 2, nid = 10205, }, },
		},
		execution = {
			{ cmd = 'handinitem', args = {}, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1500,
		award = -1,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "寻物任务2",
		executed_desc = "回到协会提交任务",
	},

	[10200203] = {
		id = 10200203,
		type = 2,
		name = "协会请援",
		accept = {
			{ cmd = 'addnpc', args = { nid = 10206, }, },
			{ cmd = 'needitem', args = { type = 101003, num = 3, nid = 10206, }, },
		},
		execution = {
			{ cmd = 'handinitem', args = {}, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1500,
		award = -2,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "寻物任务3",
		executed_desc = "回到协会提交任务",
	},

	[10200204] = {
		id = 10200204,
		type = 2,
		name = "协会请援",
		accept = {
			{ cmd = 'needitem', args = { type = 101004, num = 4, nid = 20001002, }, },
		},
		execution = {
			{ cmd = 'handinitem', args = {}, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1500,
		award = -1,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "寻物任务4",
		executed_desc = "回到协会提交任务",
	},

	[10200205] = {
		id = 10200205,
		type = 2,
		name = "协会请援",
		accept = {
			{ cmd = 'needitem', args = { type = 101005, num = 5, nid = 20001003, }, },
		},
		execution = {
			{ cmd = 'handinitem', args = {}, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1500,
		award = -2,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "寻物任务5",
		executed_desc = "回到协会提交任务",
	},

	[10200301] = {
		id = 10200301,
		type = 3,
		name = "协会请援",
		accept = {
			{ cmd = 'addnpc', args = { nid = 10207, }, },
			{ cmd = 'findnpc', args = { nid = 10207, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = -1, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 500,
		award = -1,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "战斗任务1",
		executed_desc = "回到协会提交任务",
	},

	[10200302] = {
		id = 10200302,
		type = 3,
		name = "协会请援",
		accept = {
			{ cmd = 'addnpc', args = { nid = 10208, }, },
			{ cmd = 'findnpc', args = { nid = 10208, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = -2, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 500,
		award = -2,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "战斗任务2",
		executed_desc = "回到协会提交任务",
	},

	[10200303] = {
		id = 10200303,
		type = 3,
		name = "协会请援",
		accept = {
			{ cmd = 'addnpc', args = { nid = 10209, }, },
			{ cmd = 'findnpc', args = { nid = 10209, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = -1, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 500,
		award = -1,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "战斗任务3",
		executed_desc = "回到协会提交任务",
	},

	[10200304] = {
		id = 10200304,
		type = 3,
		name = "协会请援",
		accept = {
			{ cmd = 'findnpc', args = { nid = 20001002, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = -2, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 500,
		award = -2,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "战斗任务4",
		executed_desc = "回到协会提交任务",
	},

	[10200305] = {
		id = 10200305,
		type = 3,
		name = "协会请援",
		accept = {
			{ cmd = 'findnpc', args = { nid = 20001003, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = -1, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 500,
		award = -1,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "战斗任务5",
		executed_desc = "回到协会提交任务",
	},

	[10200401] = {
		id = 10200401,
		type = 4,
		name = "协会请援",
		accept = {
			{ cmd = 'setpatrol', args = { posid = 21001001, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = -2, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 500,
		award = -2,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "巡逻任务1",
		executed_desc = "回到协会提交任务",
	},

	[10200402] = {
		id = 10200402,
		type = 4,
		name = "协会请援",
		accept = {
			{ cmd = 'setpatrol', args = { posid = 21001002, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = -1, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 500,
		award = -1,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "巡逻任务2",
		executed_desc = "回到协会提交任务",
	},

	[10200403] = {
		id = 10200403,
		type = 4,
		name = "协会请援",
		accept = {
			{ cmd = 'setpatrol', args = { posid = 21001003, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = -2, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 500,
		award = -2,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "巡逻任务3",
		executed_desc = "回到协会提交任务",
	},

	[10200404] = {
		id = 10200404,
		type = 4,
		name = "协会请援",
		accept = {
			{ cmd = 'setpatrol', args = { posid = 21001004, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = -1, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 500,
		award = -1,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "巡逻任务4",
		executed_desc = "回到协会提交任务",
	},

	[10200405] = {
		id = 10200405,
		type = 4,
		name = "协会请援",
		accept = {
			{ cmd = 'setpatrol', args = { posid = 21001005, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = -2, }, },
		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 500,
		award = -2,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "巡逻任务5",
		executed_desc = "回到协会提交任务",
	},

	[10200501] = {
		id = 10200501,
		type = 5,
		name = "协会请援",
		accept = {
			{ cmd = 'setcollect', args = { posid = 21001001,  name = nil, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1000,
		award = -1,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "采集任务1",
		executed_desc = "回到协会提交任务",
	},

	[10200502] = {
		id = 10200502,
		type = 5,
		name = "协会请援",
		accept = {
			{ cmd = 'setcollect', args = { posid = 21001002,  name = nil, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1000,
		award = -2,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "采集任务2",
		executed_desc = "回到协会提交任务",
	},

	[10200503] = {
		id = 10200503,
		type = 5,
		name = "协会请援",
		accept = {
			{ cmd = 'setcollect', args = { posid = 21002001,  name = nil, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1000,
		award = -1,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "采集任务3",
		executed_desc = "回到协会提交任务",
	},

	[10200504] = {
		id = 10200504,
		type = 5,
		name = "协会请援",
		accept = {
			{ cmd = 'setcollect', args = { posid = 21002002,  name = nil, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1000,
		award = -2,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "采集任务4",
		executed_desc = "回到协会提交任务",
	},

	[10200505] = {
		id = 10200505,
		type = 5,
		name = "协会请援",
		accept = {
			{ cmd = 'setcollect', args = { posid = 21002003,  name = nil, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		acceptnpc = 20001001,
		submitnpc = 20001001,
		recommendteam = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1000,
		award = -1,
		nexttask = "other",
		chapterid = 0,
		icon_id = 0,
		desc = "完成测试任务,描述之后搞",
		accepted_desc = "采集任务5",
		executed_desc = "回到协会提交任务",
	},

}
return data_1500_ShimenTaskProcess
--<<data_1500_ShimenTaskProcess 导表结束>>