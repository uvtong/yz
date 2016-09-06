--------------------------------------------------
--函数包装器
--用法:
--local func = functor(print,1,2,nil,nil)
-- func(4,5)	-- 1,2,nil,nil,4,5
-- func(7,8)	-- 1,2,nil,nil,7,8
-- func(7,nil,9,nil,nil)	-- 1,2,nil,nil,7,nil,9,nil,nil
-- local func2 = functor(func,4,5,nil)
-- func2(5,nil,6,nil)	-- 1,2,nil,nil,4,5,nil,5,nil,6,nil
--------------------------------------------------
local callmeta = {}
callmeta.__call = function (func,...)
	local args = table.pack(...)
	if type(func) == "function" then
		return func(...)
	elseif type(func) ~= "table" then
		error("not callable")
	else
		local n = func.__args.n
		local allargs = {}
		for i = 1,n do
			allargs[i] = func.__args[i]
		end
		for i = 1,args.n do
			allargs[n+i] = args[i]
		end
		n = n + args.n
		return func.__fn(table.unpack(allargs,1,n))
	end
end

function functor(func,...)
	assert(func,"cann't wrapper a nil func")
	local args = table.pack(...)
	local wrap = {}
	wrap.__fn = func
	wrap.__args = args
	wrap.__name = "functor"  -- flag
	setmetatable(wrap,callmeta)
	return wrap
end

-- function test()
-- 	local func = functor(print,1,2,nil,nil)
-- 	func(4,5)	-- 1,2,nil,nil,4,5
-- 	func(7,8)	-- 1,2,nil,nil,7,8
-- 	func(7,nil,9,nil,nil)	-- 1,2,nil,nil,7,nil,9,nil,nil
-- 	local func2 = functor(func,4,5,nil)
-- 	func2(5,nil,6,nil)	-- 1,2,nil,nil,4,5,nil,5,nil,6,nil
-- end

--test()
