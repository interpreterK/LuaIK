local LuaIK = {}
LuaIK.__index = LuaIK

local Lua = getfenv()
local function Interpreter()
	local LuaIK_Env = {
		vars = {},
		funcs = {},
		ints = {}
	}
	-- new libraries --
	local function newvar(Name)
		if type(Name) == 'string' then
			return function(t_callb)
				LuaIK_Env.vars[Name] = t_callb
			end
		end
	end
	local function newfunc(Name)
		if type(Name) == 'string' then
			return function(t_callb)
				if t_callb and t_callb[1] and type(t_callb[1]) == 'function' then
					LuaIK_Env.funcs[Name] = t_callb[1]
				end
			end
		end
	end
	local function newint(Name)
		if type(Name) == 'string' then
			return function(n)
				if n and n[1] and type(n[1]) == "number" then
					if math.floor(n[1]) == n[1] then
						LuaIK_Env.ints[Name] = n[1]
					end
				end
			end
		end
	end
	local function new(Type)
		if Type == 'array' then
			return function(n)
				return table.create(n[1] or 1)
			end
		elseif Type == 'userdata' then
			return function(addmt)
				return newproxy(addmt)
			end
		end
	end
	----
	-- libraries --
	local function include(lib)
		return Lua[lib]
	end
	local function var(Name)
		if not LuaIK_Env.vars[Name] then
			warn("No var's named: \""..Name.."\" t:", debug.traceback(), "VAR ENV:", LuaIK_Env.vars)
			return nil
		end
		return LuaIK_Env.vars[Name][1]
	end
	local function func(Name, args)
		if not LuaIK_Env.funcs[Name] then
			warn("No functions's named: \""..Name.."\" t:", debug.traceback(), "FUNC ENV:", LuaIK_Env.funcs)
			return nil
		end
		return LuaIK_Env.funcs[Name](unpack(args))
	end
	local function int(Name)
		if not LuaIK_Env.ints[Name] then
			warn("No functions's named: \""..Name.."\" t:", debug.traceback(), "FUNC ENV:", LuaIK_Env.funcs)
			return nil
		end
		return LuaIK_Env.ints[Name]
	end
	--
	return {
		include = include,
		newvar = newvar,
		newfunc = newfunc,
		var = var,
		func = func,
		new = new,
		newint = newint,
		int = int
	}
end

function LuaIK.new(envLevel)
	envLevel = envLevel or 2
	setfenv(envLevel, Interpreter())
end

return LuaIK