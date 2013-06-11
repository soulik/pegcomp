require 'lpeg'

--[[
	compile(string <text_grammar_definition>, string <S0 state name>, boolean <optional debug>)

	returns lpeg_pattern
]]--

local function compile(g, S0name, _debug)
	local P = lpeg.P
	local C = lpeg.C
	local Ct = lpeg.Ct
	local V = lpeg.V
	local S = lpeg.S

	local delim = P[[/]]
	local nl = P"\n"
	local _space = S" \t"
	local space0 = _space^0
	local space1 = _space^1
	local nspace = (1 - (_space+delim+nl))^1
	local quot1 = P[[']]
	local quot2 = P[["]]
	local escape = P[[\]]

	local quot = P{
		#quot1*V(2) + #quot2*V(3),
		quot1 * C( ( (escape*quot1) + (1-quot1) )^0) * quot1,
		quot2 * C( ( (escape*quot2) + (1-quot2) )^0) * quot2,
	}
	
	local lines = Ct(
		lpeg.P{
			"line",
			line = ((
				Ct(
					(
						space0 * C(nspace) * space0 
						* "<-" * 
						space0 * V('def_list') * space0
					)^1
				)
				+ nl
			))^0,
			def_list = Ct(
				(
					(V('def') * space0 * delim * space0)
					+ (V('def') * space0)
				)^1
			),
			def = (
				(
					Ct( quot * 
						Ct(
							( space1 * C(
								nspace
							))^1
						)
					)
				)
				+ (
					Ct(quot)
				)

			),
		}
	)
	
	local TI = table.insert
	local empty = lpeg.P(0)
	local t = {}
	local wr = function(...)
		if _debug then
			io.write(string.format(...))
		end
	end

	TI(t, S0name)
	for i,line in ipairs(lines:match(g)) do
		t[line[1]] = (function()
			wr("%q = ", tostring(line[1]))
			local def_list
			for _, _def in ipairs(line[2]) do
				wr("(")
				local _def_list = (function()
					local def = _def[1]
					wr("%q", _def[1])
					if type(_def[2])=="table" then
						for j, state in ipairs(_def[2]) do
							wr(" %s", state)
							def = def * V(state)
						end
					end
					return def
				end)()

				if type(def_list)=="nil" then
					def_list = _def_list
				else
					def_list = def_list + _def_list
				end
				
				wr(")")
			end
			return def_list
		end)()
		wr("\n")
	end
	return P(t) * -1
end

return {
	compile = compile
}