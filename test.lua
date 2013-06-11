require 'lpeg'
local peg = require 'peg'

-- testing grammar from: http://www.inf.puc-rio.br/~roberto/lpeg/#grammar

local p = [[
S <- 'a' B / 'b' A / ''
A <- 'a' S / 'b' A A
B <- 'b' S / 'a' B B
]]

equalcount = lpeg.P{
  "S";   -- initial rule name
  S = ("a" * lpeg.V"B") + ("b" * lpeg.V"A") + (""),
  A = ("a" * lpeg.V"S") + ("b" * lpeg.V"A") * (lpeg.V"A"),
  B = ("b" * lpeg.V"S") + ("a" * lpeg.V"B") * (lpeg.V"B"),
} * -1

local test_str = [[aabb]]
local pattern = peg.compile(p, "S", -1)

print(equalcount:match(test_str))
print(pattern:match(test_str))
