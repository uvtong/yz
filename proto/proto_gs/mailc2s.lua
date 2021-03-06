return {
	p = "mail",
	si = 2000, -- [2000,2500)
	src = [[

mail_openmailbox 2000 {
	request {
		base 0 : basetype
	}
}

mail_readmail 2001 {
	request {
		base 0 : basetype
		mailid 1 : integer
	}
}

mail_delmail 2002 {
	request {
		base 0 : basetype
		mailid 1 : integer
	}
}

mail_getattach 2003 {
	request {
		base 0 : basetype
		mailid 1 : integer
	}
}

mail_sendmail 2004 {
	request {
		base 0 : basetype
		to 1 : integer		# 收件人玩家ID
		title 2 : string
		content 3 : string
		attach 4 : AttachType
	}
}

mail_delallmail 2005 {
	request {
		base 0 : basetype
	}
}

# 邮件按钮选项回复
mail_respondanswer 2006 {
	request {
		base 0 : basetype
		mailid 1 : integer
		answer 2 : integer # 选项ID
	}
}
]]
}
