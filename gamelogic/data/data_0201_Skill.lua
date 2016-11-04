data_0201_Skill = {
	[100001] = {
		name = "物理攻击",
		des = "普通物理攻击(占位用，实现逻辑单独处理)",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 0,
		maxLv = 0,
		attackType = 2,
		excuType = 0,
		singTime = 0,
		minSingTime = 0,
		cdTime = 0,
		skilleffect = {},
		jobID = 0,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[100011] = {
		name = "英勇意志",
		des = "增加999点生命值",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 0,
		maxLv = 6,
		attackType = 1,
		excuType = 0,
		singTime = 0,
		minSingTime = 0,
		cdTime = 0,
		skilleffect = {900002},
		jobID = 10001,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[100012] = {
		name = "重击",
		des = "对敌人单体造成999%攻击力+999点物理伤害",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 0,
		maxLv = 1,
		attackType = 2,
		excuType = 0,
		singTime = 1.5,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900012},
		jobID = 10001,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[100013] = {
		name = "火焰冲击",
		des = "对敌人单体造成999%法术强度+999点法术伤害",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 0,
		maxLv = 1,
		attackType = 13,
		excuType = 0,
		singTime = 1.5,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900013},
		jobID = 10001,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[100014] = {
		name = "急救",
		des = "对自己回复999%法术强度+999点生命值",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 0,
		maxLv = 1,
		attackType = 31,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900014},
		jobID = 10001,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[101000] = {
		name = "单手剑修炼",
		des = "使用单手剑时增加999攻击力",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 1,
		excuType = 0,
		singTime = 0,
		minSingTime = 0,
		cdTime = 0,
		skilleffect = {901000.0},
		jobID = 10002,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[101010] = {
		name = "双手剑修炼",
		des = "使用双手剑时增加999攻击力",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 1,
		excuType = 0,
		singTime = 0,
		minSingTime = 0,
		cdTime = 0,
		skilleffect = {901010.0},
		jobID = 10002,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[101020] = {
		name = "快速回复",
		des = "受到治疗的效果增加999%",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 1,
		excuType = 0,
		singTime = 0,
		minSingTime = 0,
		cdTime = 0,
		skilleffect = {901020.0},
		jobID = 10002,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[101030] = {
		name = "狂击",
		des = "对敌人单体造成999%攻击力+999点物理伤害,并有999%概率使敌人陷入昏迷状态",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {901030},
		jobID = 10002,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[101040] = {
		name = "怒爆",
		des = "对范围敌人造成999%攻击力+999点火属性伤害",
		skillPre = 101030,
		skillPreLv = 5,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 13,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {901040.0},
		jobID = 10002,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[101050] = {
		name = "挑衅",
		des = "使敌人强制攻击自己,仅对物理攻击有效，持续1回合",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 99,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {901050.0},
		jobID = 10002,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[101060] = {
		name = "盾墙",
		des = "减少受到的40%近战物理伤害,并增加自身999点防御,持续1回合.装备盾牌时才能使用.",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 99,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {901060},
		jobID = 10002,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[101070] = {
		name = "霸体",
		des = "增加防御力999点,免疫状态变化,持续1回合",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 99,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {901070.0},
		jobID = 10002,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[102000] = {
		name = "天使之力",
		des = "增加自身面对魔鬼系和不死系敌人时的攻击力999点,法术强度999点，防御力999点",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 1,
		excuType = 0,
		singTime = 0,
		minSingTime = 0,
		cdTime = 0,
		skilleffect = {902000,902001,902002},
		jobID = 10003,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[102010] = {
		name = "天使之心",
		des = "使用治疗法术时，法术强度增加999点",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 1,
		excuType = 0,
		singTime = 0,
		minSingTime = 0,
		cdTime = 0,
		skilleffect = {902010.0},
		jobID = 10003,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[102020] = {
		name = "光猎",
		des = "召唤光球寻找敌方潜行单位,造成999%法术强度+999点圣属性伤害",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 5,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10003,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[102030] = {
		name = "神圣之光",
		des = "对敌人单体造成999%法术强度+999点圣属性伤害.并且可以击破障壁.",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10003,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[102040] = {
		name = " 治疗术",
		des = "回复一个友方单体999%法术强度+999点生命值",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 31,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {902040.0},
		jobID = 10003,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[102050] = {
		name = " 复活术",
		des = "复活一个友方单位,复活后拥有999%法术强度+999点生命值",
		skillPre = 102040,
		skillPreLv = 5,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10003,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[102060] = {
		name = "守护光环",
		des = "增加全体友方单体999点防御力,自身法力上限、法力回复降低10%.队伍内只能生效一种同类光环",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 99,
		excuType = 1,
		singTime = 0,
		minSingTime = 0,
		cdTime = 1.5,
		skilleffect = {902060.0},
		jobID = 10003,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[102070] = {
		name = "力量光环",
		des = "增加全体友方单体999点攻击力与法术强度,自身法力上限、法力回复降低10%.队伍内只能生效一种同类光环",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 99,
		excuType = 1,
		singTime = 0,
		minSingTime = 0,
		cdTime = 1.5,
		skilleffect = {902070.0},
		jobID = 10003,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[102080] = {
		name = "速度光环",
		des = "增加全体友方单体999点攻击速度,自身法力上限、法力回复降低10%.队伍内只能生效一种同类光环",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 99,
		excuType = 1,
		singTime = 0,
		minSingTime = 0,
		cdTime = 1.5,
		skilleffect = {902080.0},
		jobID = 10003,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[102090] = {
		name = "缓速术",
		des = "降低一个敌方单体999点攻击速度,持续1回合",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10003,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[102100] = {
		name = "光之障壁",
		des = "给友方单体施放一面保护膜,吸收999%法术强度+999点伤害,持续999回合",
		skillPre = 102040,
		skillPreLv = 5,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10003,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[103000] = {
		name = "禅心",
		des = "使用法杖增加999攻击力,并增加自身999点魔法值回复",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 1,
		excuType = 0,
		singTime = 0,
		minSingTime = 0,
		cdTime = 0,
		skilleffect = {903000,903001},
		jobID = 10004,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[103010] = {
		name = "冰箭术",
		des = "对敌人单体造成999%法术强度+999点水属性伤害,并有999%概率冻结敌人.冰冻后受到雷系伤害提高",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 11,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {903010},
		jobID = 10004,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[103020] = {
		name = " 霜冻之术",
		des = "对敌人群体造成999%法术强度+999点水属性伤害,并有999%概率冻结敌人.冰冻后受到雷系伤害提高",
		skillPre = 103010,
		skillPreLv = 5,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 11,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {903020.0},
		jobID = 10004,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[103030] = {
		name = "火箭术",
		des = "召唤火箭对敌人单体造成999%法术强度+999点火属性伤害",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 13,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {903030.0},
		jobID = 10004,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[103040] = {
		name = "火球术",
		des = "召唤火球对敌人群体造成999%法术强度+999点火属性伤害,相邻敌人受到伤害会衰减",
		skillPre = 103030,
		skillPreLv = 5,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 13,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {903040.0},
		jobID = 10004,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[103050] = {
		name = "火猎",
		des = "召唤火球寻找敌方潜行单位,造成999%法术强度+999点火属性伤害",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 5,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {},
		jobID = 10004,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[103060] = {
		name = "雷击术",
		des = "召唤雷电对敌人单体造成999%法术强度+999点雷属性伤害",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 14,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {903060.0},
		jobID = 10004,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[103070] = {
		name = "雷爆术",
		des = "召唤雷电对敌人群体造成999%法术强度+999点雷属性伤害,相邻敌人受到伤害会衰减",
		skillPre = 103060,
		skillPreLv = 5,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 14,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {903070.0},
		jobID = 10004,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[103080] = {
		name = "圣灵召唤",
		des = "使用念力对敌人单体造成999%法术强度+999点念属性伤害",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 18,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {903080.0},
		jobID = 0,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[103090] = {
		name = "心灵爆破",
		des = "使用念力对敌人群体造成999%法术强度+999点念属性伤害,相邻敌人受到伤害会衰减",
		skillPre = 103080,
		skillPreLv = 5,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 18,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {903090.0},
		jobID = 0,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[103100] = {
		name = "石化术",
		des = "对敌人单体造成999%法术强度+999点土属性伤害,并有999%概率石化敌人.石化后受到火系伤害提高",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10004,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[103110] = {
		name = "能量外套",
		des = "吸收999%法术强度+999点伤害,持续999回合",
		skillPre = 103090,
		skillPreLv = 5,
		skillPrePt = 9,
		maxLv = 1,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10004,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[104000] = {
		name = "二刀连击",
		des = "使用短剑或拳刃时有999%概率进行一次额外攻击,造成50%攻击力的伤害",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 1,
		excuType = 0,
		singTime = 0,
		minSingTime = 0,
		cdTime = 0,
		skilleffect = {904000},
		jobID = 10005,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[104010] = {
		name = " 残影",
		des = "增加自身999点躲闪.",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 1,
		excuType = 0,
		singTime = 0,
		minSingTime = 0,
		cdTime = 0,
		skilleffect = {904010.0},
		jobID = 10005,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[104020] = {
		name = "施毒",
		des = "对敌人单体造成999%攻击力+999点毒伤害,并有999%概率使敌人中毒",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {904020},
		jobID = 10005,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[104030] = {
		name = "投石",
		des = "对敌人单体造成999%攻击力+999物理伤害,并有999%概率使敌人昏迷",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 3,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {904030},
		jobID = 10005,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[104040] = {
		name = "喷沙",
		des = "对敌人单体造成999%攻击力+999物理伤害,并有999%概率使敌人沉默",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 3,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {904040},
		jobID = 10005,
		costMP = 1.5,
		buffPro = 0,
		implflag = 1,
	},

	[104050] = {
		name = "偷窃",
		des = "随机偷取敌人身上,攻击、防御、法术强度、法术防御其中一项属性999点,持续99秒",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 99,
		excuType = 0,
		singTime = 0.1,
		minSingTime = 0,
		cdTime = 1.4,
		skilleffect = {904050},
		jobID = 10005,
		costMP = 0,
		buffPro = 0,
		implflag = 1,
	},

	[104060] = {
		name = "潜行",
		des = "进入隐身状态,持续1回合.隐身期间无法攻击，使用技能后解除，隐身结束后第一次物理攻击伤害增加999%",
		skillPre = 104050,
		skillPreLv = 5,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10005,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[105000] = {
		name = " 苍鹰之眼",
		des = "使用弓箭时增加999攻击力",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10007,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[105010] = {
		name = "二连矢",
		des = "连续射出两支箭,对敌人单体造成999%攻击力+999点物理伤害",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10007,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[105020] = {
		name = " 箭雨",
		des = "连续射出多支箭,每支箭对敌人造成999%攻击力+999点物理伤害,攻击同一个单位时伤害会下降",
		skillPre = 105010,
		skillPreLv = 5,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10007,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[105030] = {
		name = " 冲锋箭",
		des = "对敌人单体造成999%攻击力+999点物理伤害,并有999%概率击退敌人",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10007,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[105040] = {
		name = "定身箭",
		des = "对敌人单体造成999%攻击力+999点物理伤害,并有999%概率使敌人定身",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10007,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[105050] = {
		name = "心神凝聚",
		des = "增加自身999点躲闪与命中,持续1回合",
		skillPre = 105000,
		skillPreLv = 5,
		skillPrePt = 9,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10007,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[106000] = {
		name = "长矛使修炼",
		des = "使用长矛时增加999攻击力",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10008,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[106010] = {
		name = "乘骑术",
		des = "允许乘骑大嘴鸟,对大型魔物伤害+999",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10008,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[106020] = {
		name = "骑乘攻击",
		des = "对范围敌人造成999%攻击力+999点物理伤害,且装备长矛时才能使用.",
		skillPre = 106010,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10008,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[106030] = {
		name = "连刺攻击",
		des = "连续攻击敌人,敌人体型越大连击次数越多.每次攻击对敌人单体造成999%攻击力+999点物理伤害,装备长矛时才能使用.",
		skillPre = 106000,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10008,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[106040] = {
		name = "投掷长矛",
		des = "对敌人单体造成999%攻击力+999点远程物理伤害,备长矛时才能使用.",
		skillPre = 106000,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10008,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[106050] = {
		name = "冲击",
		des = "对敌人单体造成999%攻击力+999点物理伤害,并有999%概率击退敌人",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10008,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[106060] = {
		name = " 怪物互击",
		des = "使敌人与敌人互相撞击,对敌人单体造成999%攻击力+999点物理伤害.装备单手剑或双手剑时才能使用.",
		skillPre = 106070,
		skillPreLv = 10,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10008,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[106070] = {
		name = "双手剑加速",
		des = "使用双手剑时攻击速度+999,持续1回合",
		skillPre = 101010,
		skillPreLv = 10,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10008,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[106080] = {
		name = "反击",
		des = "受到下一次近战物理攻击时进行反击,增加+999点物理伤害.必须装备双手剑才能使用.",
		skillPre = 101010,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10008,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[107000] = {
		name = "锤修炼",
		des = "使用锤时增加999攻击力",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10010,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[107010] = {
		name = "沉默之术",
		des = "有999%概率使敌人沉默,持续1回合",
		skillPre = 102020,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10010,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[107020] = {
		name = "转生术",
		des = "对不死系敌人造成999%法术强度+999点，并有999%概率一击消灭不死系敌人",
		skillPre = 102030,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10010,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[107030] = {
		name = "十字驱魔",
		des = "对敌人群体造成999%法术强度+999点圣属性伤害",
		skillPre = 107020,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10010,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[107040] = {
		name = "天使之怒",
		des = "使敌人受到的下一次技能伤害增加999%",
		skillPre = 102070,
		skillPreLv = 10,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10010,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[107050] = {
		name = "撒水祈福",
		des = "使一个友方单位的武器变为圣属性，攻击力增加999,持续1回合.",
		skillPre = 102070,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10010,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[107060] = {
		name = "幸运光环",
		des = "增加全体友方单体999点躲闪,999点暴击,持续1回合,自身法力上限、法力回复降低10%.队伍内只能生效一种同类光环",
		skillPre = 102060,
		skillPreLv = 10,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10010,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[107070] = {
		name = "暗之障壁",
		des = "给友方单体施放一面念力墙,免疫近战物理攻击,持续1回合或抵挡999次伤害有失效.每个服侍在同一时间内,只能给队友施放一种障壁效果.",
		skillPre = 102100,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 0,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[107080] = {
		name = "霸邪障壁",
		des = "给友方单体施放一面保护膜,吸收999%法术+999点伤害,持续1回合.每个服侍在同一时间内,只能给队友施放一种障壁效果.",
		skillPre = 107070,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 0,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[107090] = {
		name = " 群体治疗",
		des = "释放光芒回复群体单位999%法术强度+999点生命值",
		skillPre = 102040,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10010,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[107100] = {
		name = "净化",
		des = "清除一个友方单位的负面魔法效果,并回复999%法术强度+999点生命值",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 58,
		maxLv = 5,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10010,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[108000] = {
		name = "咒文加速",
		des = "增加999点咏唱速度",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10012,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[108010] = {
		name = " 地震术",
		des = "触发地震对敌人群体造成999%法术强度+999点地属性伤害,并有999%概率石化敌人，相邻敌人受到伤害会衰减",
		skillPre = 103100,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10012,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[108020] = {
		name = " 泥沼地",
		des = "触发地震对敌人全体造成999%法术强度+999点地属性伤害,并有999%概率石化敌人，相邻敌人受到伤害会衰减",
		skillPre = 108010,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10012,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[108030] = {
		name = "火焰之墙",
		des = "给友方单体施放一面火墙,有999%概率抵挡近战攻击的敌人,并造成999%法术强度+999点火属性伤害.",
		skillPre = 103040,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10012,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[108040] = {
		name = "暴风雪",
		des = "召唤暴风雪对敌人全体造成999%法术强度+999点水属性伤害,并有999%概率使敌人冰冻",
		skillPre = 103020,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10012,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[108050] = {
		name = "火陨石",
		des = "召唤火陨石对敌人全体造成999%法术强度+999点水属性伤害,并有999%概率使敌人昏迷",
		skillPre = 103040,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10012,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[108060] = {
		name = "怒雷强击",
		des = "召唤雷击对敌人全体造成999%法术强度+999点雷属性伤害,并有999%概率使敌人陷入黑暗状态",
		skillPre = 103070,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10012,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[109000] = {
		name = "拳刃修练",
		des = "使用拳刃时增加999攻击力",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10014,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[109010] = {
		name = "短剑修炼",
		des = "使用短剑时增加999攻击力",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10014,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[109020] = {
		name = " 无影之牙",
		des = "对敌人单体造成999%攻击力+999点物理伤害,潜行时使用不会现形",
		skillPre = 109000,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10014,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[109030] = {
		name = " 音速投掷",
		des = "对敌人单体造成999%攻击力+999点物理伤害,并有999%概率使敌人昏迷",
		skillPre = 109020,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10014,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[109040] = {
		name = " 毒性感染",
		des = "对敌人群体造成999%攻击力+999点毒伤害,并有999%概率使敌人中毒,相邻敌人受到伤害会衰减",
		skillPre = 104020,
		skillPreLv = 10,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10014,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[109050] = {
		name = "涂毒",
		des = "使一个友方单位的武器变为毒属性,物理攻击时有999%使敌人中毒,持续1回合",
		skillPre = 104020,
		skillPreLv = 10,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10014,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[109060] = {
		name = "毒性外衣",
		des = "被近战攻击时,对敌人造成999%攻击力+999点毒属性伤害.并免疫毒性伤害,持续1回合",
		skillPre = 104020,
		skillPreLv = 10,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10014,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[110000] = {
		name = "驯鹰术",
		des = "召唤猎鹰助战,并增加猎鹰闪电冲击时999点伤害。射击时猎鹰有概率自动攻击,自动释放概率与幸运值相关",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10018,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[110010] = {
		name = "动物杀手",
		des = "增加自身面对野兽系和龙系敌人时的攻击力999点,防御力999点",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10018,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[110020] = {
		name = "闪电冲击",
		des = "利用猎鹰对群体敌人造成造成999%攻击力+999点物理伤害",
		skillPre = 110000,
		skillPreLv = 1,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10018,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[110030] = {
		name = "猎鹰寻敌",
		des = "利用猎鹰攻击潜行的敌人,对敌人单体造成999%攻击力+999点远程物理伤害",
		skillPre = 110000,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 5,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10018,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[110040] = {
		name = "地雷陷阱",
		des = "埋下陷阱,队友被近战攻击时触发.造成999%攻击力+999点火属性伤害.每个猎人在同一时间内,只能给队友施放一种陷阱效果.",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10018,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[110050] = {
		name = "定身陷阱",
		des = "埋下陷阱,队友被近战攻击时触发.造成999%攻击力+999点地伤害,并使敌人被定身.每个猎人在同一时间内,只能给队友施放一种陷阱效果.",
		skillPre = 110040,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10018,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[110060] = {
		name = "强光陷阱",
		des = "埋下陷阱,队友被近战攻击时触发.造成999%攻击力+999点雷属性伤害,并使敌人陷入黑暗.每个猎人在同一时间内,只能给队友施放一种陷阱效果.",
		skillPre = 110040,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10018,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[110070] = {
		name = "霜冻陷阱",
		des = "埋下陷阱,队友被近战攻击时触发.造成999%攻击力+999点水属性伤害,并使敌人被冰冻.每个猎人在同一时间内,只能给队友施放一种陷阱效果.",
		skillPre = 110040,
		skillPreLv = 5,
		skillPrePt = 58,
		maxLv = 10,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 10018,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

	[110080] = {
		name = "陷阱移除",
		des = "让猎鹰随机拆除敌人的一个陷阱",
		skillPre = 0,
		skillPreLv = 0,
		skillPrePt = 58,
		maxLv = 1,
		attackType = 2,
		excuType = 0,
		singTime = 2.8,
		minSingTime = 1,
		cdTime = 1.5,
		skilleffect = {900001},
		jobID = 0,
		costMP = 1.5,
		buffPro = 0,
		implflag = 0,
	},

}

