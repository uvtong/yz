--<<data_1500_ShiMoShiLianTaskVar 导表开始>>
data_1500_ShiMoShiLianTaskVar = {

	StartWarNeedNum = 1, 		-- 发起战斗至少需要的成员数

	StartWarNeedLv = 10, 		-- 发起战斗需要的等级

	RingLimit = 10, 		-- 10环为一轮

	LookNpcType = 9002, 		-- 10环时需要跳转到的NPC类型

	GiveItemToCaptainAt10Ring = {type=401001,num=1}, 		-- 10环给队长的物品

	QuickFinishNeedLeftCnt = 20, 		-- 快速完成10环任务需要的剩余任务次数

	QuickFinishNeedItem = {type=401001,num=1}, 		-- 快速完成10环任务需要消耗的物品

}
return data_1500_ShiMoShiLianTaskVar
--<<data_1500_ShiMoShiLianTaskVar 导表结束>>