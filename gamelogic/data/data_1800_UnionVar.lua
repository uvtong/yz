--<<data_1800_UnionVar 导表开始>>
data_1800_UnionVar = {

	CreateUnionCostGold = 1000, 		-- 创建公会消耗的金币

	NoticeMaxChar = 30, 		-- 公告最大字符数

	PurposeMaxChar = 30, 		-- 宗旨最大字符数

	PublishPurposeCost = {money=30,items={type=601001,num=1}}, 		-- 发布公告消耗资金+公会物品

	ApplyerMaxLimit = 30, 		-- 申请列表最大人数

	JoinUnoinCDAfterQuit = 72000, 		-- 20小时(XXX秒)

	ChangeNameCostGold = 500, 		-- 改名消耗金币

	PublishNoticeCD = 5, 		-- 发布公告CD

	RunForLeaderVoteTime = 2, 		-- 竞选会长投票持续天数

	RunForLeaderCD = 7, 		-- 竞选会长CD天数

	RunForLeaderNeedLogoffTime = 5, 		-- 需要会长离线超过多少天才能竞选会长

	FuliExpFormula = "baseexp * playerlv * cangku_addn * job_addn", 		-- 每周福利经验奖励公司(baseexp--基本经验,playerlv--玩家等级,cangku_addn--仓库加成,job_addn--公会职位加成）

	UnionShopRefreshNum = {[0]=10,[1]=12,[2]=14,[3]=16,[4]=18,[5]=20}, 		-- 公会商店刷出物品数量

	QuitUnionCDNeedLv = 25, 		-- 大于/等于指定等级的玩家退出公会玩家才有申请公会CD

}
return data_1800_UnionVar
--<<data_1800_UnionVar 导表结束>>