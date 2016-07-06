return {
	p = "team",
	si = 4000, -- [4000,4500)
	src = [[
team_createteam 4000 {
	request {
		base 0 : basetype
		target 1 : integer
		lv 2 : integer #等级
	}
}

# 已作废
team_dismissteam 4001 {
}

team_publishteam 4002 {
	request {
		base 0 : basetype
		target 1 : integer
		lv 2 : integer
		time 3 : integer # 发布时间
		captain 4 : MemberType  # 队长信息
	}
}

team_jointeam 4003 {
	request {
		base 0 : basetype
		teamid 1 : integer
	}
}

team_leaveteam 4004 {
	request {
		base 0 : basetype
	}
}

team_quitteam 4005 {
	request {
		base 0 : basetype
	}

}

team_backteam 4006 {
	request {
		base 0 : basetype
	}

}

team_recallmember 4007 {
	request {
		base 0 : basetype
	}

}

team_apply_become_captain 4008 {
	request {
		base 0 : basetype
	}
}

team_agree_jointeam 4009 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

team_changecaptain 8010 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

team_invite_jointeam 8011 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

#请求同步一个队伍数据
team_syncteam 8012 {
	request {
		base 0 : basetype
		teamid 1 : integer
	}
}

# 打开组队界面
team_openui_team 8013 {
	request {
		base 0 : basetype
	}
}

team_automatch 8014 {
	request {
		base 0 : basetype
	}
}

team_unautomatch 8015 {
	request {
		base 0 : basetype
	}
}

team_changetarget 8016 {
	request {
		base 0 : basetype
		target 1 : integer
		lv 2 : integer
	}
}

team_apply_jointeam 8017 {
	request {
		base 0 : basetype
		teamid 1 : integer
	}
}

team_delapplyers 8018 {
	request {
		base 0 : basetype
		# 发空表示清空所有申请者
		pids 1 : *integer
	}
}

# 查看发布的队伍
team_look_publishteams 8019 {
	request {
		base 0 : basetype
	}
}
]]
}