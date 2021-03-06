return {
	p = "navigation",
	si = 7100, --[7100,7200)
	src = [[

.ActivityType {
	hid 0 : integer
	progress 1 : integer #活动进度
	awarded 2 : boolean #活动奖励是否领取
}

.DailyStatType {
	id 0 : integer
	cnt 1 : integer		# 当天完成次数
	limit 2 : integer	# 当天次数上限
}

# 全量更新活动导航数据
navigation_sendactivitydata 7100 {
	request {
		base 0 : basetype
		activities 1 : *ActivityType
		liveness 2 : integer
		livenessawarded 3 : *integer
	}
}

# 活动数据更新标记
navigation_needupdate 7101 {
	request {
		base 0 : basetype
	}
}

# 活动按钮红点显示
navigation_showredpoint 7102 {
	request {
		base 0 : basetype
	}
}

# 每日统计数据
navigation_dailystat 7103 {
	request {
		base 0 : basetype
		stats 1 : *DailyStatType
	}
}

]]
}
