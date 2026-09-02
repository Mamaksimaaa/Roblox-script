--[[ v1.0.0 https://wearedevs.net/obfuscator ]] 
local _z30_8471573 = "RBXE\001\000\001\002\000\184\251\173\004\189\008\131=|\241eG\130\0311jm5\216Z\007\003\000\000\002j@C\2334\016\155!\229\239\185A\173ZH'\232\236\168\241\163?g\130\136\138\227\185\169T'\150\183\149\013\214\141.l\159\182'\143\1354H\008\141\009\230\023\001\177\200N\131\021\129\218,\029/\150\025\222\016\229\010\148\237\171Z\197r\204\168\160\133K;\159&Dm\253\193\014\182\004\214\131\189?\143\0061\216\248\186\018s\255\198h\233\255\193nh\170\239V/\242]\156^e\185\239D\177e?\174\197\183V\016\150J\164%\236\181\247\010]\157QE\213\002\202\"w@I\1324Q\220\008\192\009`\181\225l>;Jd\016\216\018\245\136\019dNq\167z8j0c\180h\208\020m\182^Y\156\198\204\233I\184U\151\222M\232\129:\175\164\223f\189\244\211\172\168\246\180\\\157U\128\221\188\156\233\191\196P\026\228\144VK;/\180#b\171M\201y-[$\253}\021\1930\024i\161%\237^\028]'\130\001\195\029\231\013\248\149\022\229\254\139\170\230^\236\171p\143\143\186(9\188\242y\222\192\135~l\024\127\230t\031\157\181\138'\031\141-\247\235ss\139\135?\211\029:\133\020\014\242\244b\250I\238S]W\167\020\129\231\229\019\148\200\251\187\025\243\248\167\012x\198\210\137\240\196i\1493U\133\185S\184\173\002B\219\142\028\141]<\145LD\140\232Q\245Z\021%}B6\016\236\180q\199\222i\179\160\201n\172\244{\240v\145!u\191\199^\240JZ\211OG\179\132*\131\212\216<MJm!\228\168m\157\2495\220\143>Q\213\009\234\143\156\172+\161\172`%\209\184qiD9\028\175\016\183\178\151S`}\154i\131\1437\027\149\155\193\223i\187\000~\145\227\252~W\031\244j6x\162L\235>L\133\245\182VF\235\134\127\025!sm\242\027\158*\023\135\167&M(\001\1802Ce\223\178\203D\225_E\195\236\005\016\162\208\216\1343\232\008\252\030\2234\182\2013U\132\184\153!\130F\009\0276\229s\196e\227\130\190o\012\017S\231\145Bv\019\029\226\163\001\184(\181\183#\002\157i\210z\195$\134\003\028\152\214\141tj\001Q\217\214\143\211\1710\191\001%\166\144\144\014k\162\000\166\006\154\208i\213\203?\221\166\160\002\177\165f\218\210\228\180\175\197x\138\252\183\253\199\159\249\145\245\003-\140\168\1294nl\186)\145\025\016\204\192Hg>\0165\208\201\220\155\182\239\195q{N+\005\030\129\023\225\134r-\197\130\218\010\243\168\221\027\172\235\205\172\235\235/0\231\133\152L\173w|\022\166w\190{\204\220\\fV\167\025\207\149m\010\191\185\200\020{\226=\000\000\249`&S,.7\176\243\210G\232\212\238#\153\135e\225\196\031\232G\238s\145{\234#O\212\193\027-\204\222\165\234\176\139\214\231\213@\175k\016\158\242\2157b\170z_\208\186\153\1580s\183\181_\245(p\205\0260\024\187Hd2<\238\165\131c"
local _z10_1603b72 = {106,91,213,133,166,121,228,24,145,189,29,219,222,11,234,133,240,152,39,107,57,68,169,56,133,78,203,52,26,123,192,53}
local _z31_2b4df4d, _z23_8b4e4fd, _z41_17c1fd5, _z25_8450505, _z21_1ff804e, _z12_6254869, _z34_c800dd9, _z32_7b92cad, _z19_0dfa4c5, _z46_6393f09, _z8_3e9564c, _z2_df2d43d, _z20_0a3a448, _z38_654b36c, _z52_c00214f, MAX_PROTOS, MAX_UPVALS, MAX_CONSTS, MAX_CODE, MAX_BYTES, MAX_POOL, _z17_8e3f0bc, _z54_b2d580a, _z43_3dc7258, _z9_721da8d, _z57_213f633, _z24_05e0a40, _z16_dd5084d, _z15_b04987d, _z56_c35e19e, __SC, _z28_8670cef, _z39_5aae8c5
local _z7_ebf193e = 10
while true do
if _z7_ebf193e == 14 then
_z12_6254869 = bit32.bxor(bit32.bxor(_z12_6254869, bit32.lshift(_z12_6254869, 5)), math.floor(Vector3.new(1,4,8).Magnitude + 0.5))
_z7_ebf193e = 8
elseif _z7_ebf193e == 33 then
_z12_6254869 = 3081925407
_z7_ebf193e = 1
elseif _z7_ebf193e == 40 then
_z12_6254869 = bit32.bxor(bit32.bxor(_z12_6254869, bit32.lshift(_z12_6254869, 5)), math.floor(Vector2.new(20,21).Magnitude + 0.5))
_z7_ebf193e = 31
elseif _z7_ebf193e == 25 then
_z43_3dc7258 = function(S)
local u8, take, u16, uleb, sleb, count, eof, at = _z17_8e3f0bc(S, 1)
if u8() ~= 82 or u8() ~= 66 or u8() ~= 88 or u8() ~= 79 then error() end
if u16() ~= 2 then error() end
local fo = { u8(), u8(), u8(), u8() }
local seen = {}
for i = 1, 4 do local f = fo[i] if f > 3 or seen[f] then error() end seen[f] = true end
local disp = u8() if disp > 1 then error() end
local npool = count(MAX_POOL)
local pool = {}
for i = 1, npool do local ps = uleb() local plen = count(MAX_BYTES) local poff = take(plen) pool[i] = { start = ps, off = poff, len = plen } end
local nprotos = count(MAX_PROTOS)
local off = {}
local sc = {}
local acc = 585665
for gi = 0, nprotos - 1 do
off[gi] = at()
sc[gi] = acc
uleb() u8()
local nup = count(MAX_UPVALS)
for i = 1, nup do local kind = u8() if kind > 1 then error() end uleb() end
local nk = count(MAX_CONSTS)
for i = 1, nk do
local tag = u8()
if tag == 0 then
elseif tag == 1 then u8()
elseif tag == 2 then
local len = count(MAX_BYTES) local off2 = take(len)
for j = 0, len - 1 do if _z19_0dfa4c5(S, off2 + j) >= 128 then error() end end
elseif tag == 3 then local ss = uleb() local rs = _z34_c800dd9(ss, acc) acc = (acc + rs) % 4294967296 local len = count(MAX_BYTES) take(len)
elseif tag == 4 then uleb() local len = count(MAX_BYTES) take(len)
elseif tag == 5 then local idx = uleb() if idx >= npool then error() end
else error() end
end
local ncode = count(MAX_CODE)
for i = 1, ncode do local _z33_ef8e5f9 = uleb() sleb() sleb() sleb() _z21_1ff804e = _z34_c800dd9(_z34_c800dd9(_z21_1ff804e, bit32.lshift(_z21_1ff804e, 5)), _z33_ef8e5f9) end
end
eof()
return { S = S, fo = fo, disp = disp, n = nprotos, off = off, pool = pool, sc = sc }
end
_z7_ebf193e = 9 + ((_z19_0dfa4c5(_z54_b2d580a,4)~=79) and 377 or 0)
elseif _z7_ebf193e == 34 then
_z39_5aae8c5 = function(pi, U, ...)
local pr = _z28_8670cef(pi)
local K, C = pr.K, pr.C
local B0 = {}
local top = 0
local np = pr.np
for i = 0, np - 1 do B0[i] = select(i + 1, ...) end
local VA, VAn = {}, 0
if pr.va then
VAn = select('#', ...) - np
if VAn < 0 then VAn = 0 end
for i = 1, VAn do VA[i] = select(np + i, ...) end
end
local pc = 0
while true do
local ins = C[pc]
local op, a, b, c = ins[2], ins[4], ins[3], ins[1]
if op < 14 then
if op < 7 then
if op < 3 then
if op < 1 then
if op == 0 then
B0[a] = _z41_17c1fd5[K[b]]
end
else
if op < 2 then
if op == 1 then
B0[a] = K[b]
end
else
if op == 2 then
local pa = a + (0)
if b < 0 then
for i = 1, VAn do B0[pa + i - 1] = VA[i] end
top = a + VAn
else
for i = 0, b - 1 do B0[pa + i] = VA[i + 1] end
end
end
end
end
else
if op < 5 then
if op < 4 then
if op == 3 then
local pa = a + (0)
local f = B0[pa]
local nargs = b
if nargs < 0 then nargs = top - a - 1 end
local args = {}
for i = 1, nargs do args[i] = B0[pa + i] end
local res = _z23_8b4e4fd(f(_z31_2b4df4d(args, 1, nargs)))
if c < 0 then
for i = 1, res.n do B0[pa + i - 1] = res[i] end
top = a + res.n
else
for i = 0, c - 1 do B0[pa + i] = res[i + 1] end
end
end
else
if op == 4 then
B0[a] = B0[b][B0[c]]
end
end
else
if op < 6 then
if op == 5 then
B0[a] = B0[b]
end
else
if op == 6 then
B0[a] = B0[b] * B0[c]
end
end
end
end
else
if op < 10 then
if op < 8 then
if op == 7 then
local __h1 = _z41_17c1fd5[K[b]] B0[a] = __h1
end
else
if op < 9 then
if op == 8 then
local __h1 = K[b] B0[a] = __h1
end
else
if op == 9 then
local __h1 = B0[b][B0[c]] B0[a] = __h1
end
end
end
else
if op < 12 then
if op < 11 then
if op == 10 then
B0[a] = B0[b] + B0[c]
end
else
if op == 11 then
B0[a] = (B0[b] ~= B0[c])
end
end
else
if op < 13 then
if op == 12 then
if not B0[a] then pc = b continue end
end
else
if op == 13 then
local m = K[a]
B0[b] = B0[c] * m
end
end
end
end
end
else
if op < 21 then
if op < 17 then
if op < 15 then
if op == 14 then
pc = a
continue
end
else
if op < 16 then
if op == 15 then
local __h2 = _z41_17c1fd5[K[b]] B0[a] = __h2
end
else
if op == 16 then
local __h2 = K[b] B0[a] = __h2
end
end
end
else
if op < 19 then
if op < 18 then
if op == 17 then
local __h2 = B0[b][B0[c]] B0[a] = __h2
end
else
if op == 18 then
local cur = B0[c] * K[a]
B0[b] = cur
end
end
else
if op < 20 then
if op == 19 then
local g0 = B0[a]
local reg = g0
B0[b] = reg
local arg = g0 * B0[b]
B0[c] = arg
end
else
if op == 20 then
B0[a] = B0[b] % B0[c]
end
end
end
end
else
if op < 25 then
if op < 23 then
if op < 22 then
if op == 21 then
B0[a] = (B0[b] == B0[c])
end
else
if op == 22 then
local b0 = B0[c] * K[a]
B0[b] = b0
end
end
else
if op < 24 then
if op == 23 then
local reg = B0[b]
local hold = B0[b]
B0[a] = hold
local j1 = reg
B0[c] = j1
end
else
if op == 24 then
local j1 = K[a]
B0[b] = B0[c] % j1
end
end
end
else
if op < 27 then
if op < 26 then
if op == 25 then
local r = (B0[c] == K[a])
B0[b] = r
end
else
if op == 26 then
local __h1 = B0[b] B0[a] = __h1
end
end
else
if op < 28 then
if op == 27 then
local __h2 = B0[b] B0[a] = __h2
end
else
if op == 28 then
local pa = a + (0)
local n = b
if n < 0 then n = top - a end
local rets = {}
for i = 0, n - 1 do rets[i + 1] = B0[pa + i] end
return _z31_2b4df4d(rets, 1, n)
end
end
end
end
end
end
pc = pc + 1
end
end
_z7_ebf193e = 6 + ((_z21_1ff804e~=3650969966) and 3880 or 0)
elseif _z7_ebf193e == 17 then
_z57_213f633, _z24_05e0a40, _z16_dd5084d, _z15_b04987d = _z9_721da8d.S, _z9_721da8d.off, _z9_721da8d.fo, {}
_z7_ebf193e = 7 + ((_z19_0dfa4c5(_z54_b2d580a,2)~=66) and 3313 or 0)
elseif _z7_ebf193e == 7 then
_z56_c35e19e = _z9_721da8d.pool
_z7_ebf193e = 39 + ((_z12_6254869~=2967163558) and 239 or 0)
elseif _z7_ebf193e == 32 then
_z32_7b92cad = string.char
_z7_ebf193e = 19
elseif _z7_ebf193e == 13 then
_z2_df2d43d = function(t)
t = string.gsub(t, '_', '')
local p = string.lower(string.sub(t, 1, 2))
if p == '0b' then return tonumber(string.sub(t, 3), 2) end
return tonumber(t)
end
_z7_ebf193e = 29
elseif _z7_ebf193e == 28 then
_z46_6393f09 = string.sub
_z7_ebf193e = 21
elseif _z7_ebf193e == 36 then
do local ok, env = pcall(function() return getfenv(0) end) if ok and type(env) == 'table' then _z41_17c1fd5 = env end end
_z7_ebf193e = 27
elseif _z7_ebf193e == 2 then
_z54_b2d580a = _z52_c00214f()
_z7_ebf193e = 25 + ((_z12_6254869~=2967163558) and 3362 or 0)
elseif _z7_ebf193e == 27 then
_z25_8450505 = 45975455
_z7_ebf193e = 23
elseif _z7_ebf193e == 23 then
for __i = 1, 11 do
_z25_8450505 = bit32.bxor(_z25_8450505, bit32.lshift(_z25_8450505, 13))
_z25_8450505 = bit32.bxor(_z25_8450505, bit32.rshift(_z25_8450505, 17))
_z25_8450505 = bit32.bxor(_z25_8450505, bit32.lshift(_z25_8450505, 5))
end
_z7_ebf193e = 26
elseif _z7_ebf193e == 18 then
_z52_c00214f = function()
local E = _z30_8471573
local n = #E
if n < 49 then error() end
if _z19_0dfa4c5(E,1) ~= 82 or _z19_0dfa4c5(E,2) ~= 66 or _z19_0dfa4c5(E,3) ~= 88 or _z19_0dfa4c5(E,4) ~= 69 then error() end
if _z19_0dfa4c5(E,5) ~= 1 or _z19_0dfa4c5(E,6) ~= 0 then error() end
if _z19_0dfa4c5(E,7) ~= 1 then error() end
local ct_len = _z19_0dfa4c5(E,30) + _z19_0dfa4c5(E,31)*256 + _z19_0dfa4c5(E,32)*65536 + _z19_0dfa4c5(E,33)*16777216
if 49 + ct_len ~= n then error() end
local aad = {}
for i = 1, 17 do aad[i] = _z19_0dfa4c5(E, i) end
aad[18] = _z19_0dfa4c5(E,30) aad[19] = _z19_0dfa4c5(E,31) aad[20] = _z19_0dfa4c5(E,32) aad[21] = _z19_0dfa4c5(E,33)
local nonce = {}
for i = 1, 12 do nonce[i] = _z19_0dfa4c5(E, 17 + i) end
local ct = {}
for i = 1, ct_len do ct[i] = _z19_0dfa4c5(E, 33 + i) end
local tag = {}
for i = 1, 16 do tag[i] = _z19_0dfa4c5(E, 33 + ct_len + i) end
local pt = _z20_0a3a448(_z10_1603b72, nonce, aad, 21, ct, ct_len, tag)
if pt == nil then error() end
return _z38_654b36c(pt, ct_len)
end
_z7_ebf193e = 5
elseif _z7_ebf193e == 22 then
_z12_6254869 = bit32.bxor(bit32.bxor(_z12_6254869, bit32.lshift(_z12_6254869, 5)), math.floor(Vector2.new(5,12).Magnitude + 0.5))
_z7_ebf193e = 14
elseif _z7_ebf193e == 4 then
MAX_BYTES = 67108864
_z7_ebf193e = 3
elseif _z7_ebf193e == 31 then
_z12_6254869 = bit32.bxor(bit32.bxor(_z12_6254869, bit32.lshift(_z12_6254869, 5)), math.floor(Vector3.new(4,13,16):Dot(Vector3.new(1,1,1)) + 0.5))
_z7_ebf193e = 35
elseif _z7_ebf193e == 19 then
_z19_0dfa4c5 = string.byte
_z7_ebf193e = 28
elseif _z7_ebf193e == 39 then
__SC = _z9_721da8d.sc
_z7_ebf193e = 30 + ((_z12_6254869~=2967163558) and 868 or 0)
elseif _z7_ebf193e == 6 then
return _z39_5aae8c5(0, {}, ...)
elseif _z7_ebf193e == 24 then
_z38_654b36c = function(t, n)
local parts, pi, i = {}, 0, 1
while i <= n do
local j = i + 999 if j > n then j = n end
pi = pi + 1 parts[pi] = _z32_7b92cad(_z31_2b4df4d(t, i, j)) i = j + 1
end
return table.concat(parts)
end
_z7_ebf193e = 18
elseif _z7_ebf193e == 30 then
_z28_8670cef = function(gi)
local m = _z15_b04987d[gi]
if m then return m end
local u8, take, u16, uleb, sleb, count, eof, at = _z17_8e3f0bc(_z57_213f633, _z24_05e0a40[gi])
local np = uleb()
local va = u8() ~= 0
local nup = count(MAX_UPVALS)
local UP = {}
for i = 1, nup do local kind = u8() UP[i] = { kind, uleb() } end
local nk = count(MAX_CONSTS)
local K = {}
local acc = __SC[gi]
for i = 0, nk - 1 do
local tag = u8()
if tag == 1 then K[i] = u8() ~= 0
elseif tag == 2 then local len = count(MAX_BYTES) local off = take(len) K[i] = _z2_df2d43d(_z46_6393f09(_z57_213f633, off, off + len - 1))
elseif tag == 3 then local ss = uleb() local rs = _z34_c800dd9(ss, acc) acc = (acc + rs) % 4294967296 local len = count(MAX_BYTES) local off = take(len) K[i] = _z8_3e9564c(_z57_213f633, off, len, rs)
elseif tag == 4 then local start = uleb() local len = count(MAX_BYTES) local off = take(len) K[i] = _z2_df2d43d(_z8_3e9564c(_z57_213f633, off, len, start))
elseif tag == 5 then local idx = uleb() local pe = _z56_c35e19e[idx + 1] K[i] = _z8_3e9564c(_z57_213f633, pe.off, pe.len, pe.start) end
end
local ncode = count(MAX_CODE)
local C = {}
local fo = _z16_dd5084d
for i = 0, ncode - 1 do
local op = uleb() local a = sleb() local b = sleb() local c = sleb()
local vals = { op, a, b, c }
C[i] = { vals[fo[1] + 1], vals[fo[2] + 1], vals[fo[3] + 1], vals[fo[4] + 1] }
end
m = { np = np, va = va, K = K, C = C, UP = UP }
_z15_b04987d[gi] = m
return m
end
_z7_ebf193e = 34 + ((_z19_0dfa4c5(_z54_b2d580a,1)~=82) and 1395 or 0)
elseif _z7_ebf193e == 5 then
MAX_PROTOS = 1048576
_z7_ebf193e = 37
elseif _z7_ebf193e == 8 then
_z12_6254869 = bit32.bxor(bit32.bxor(_z12_6254869, bit32.lshift(_z12_6254869, 5)), math.floor((CFrame.new(3,5,7) * CFrame.new(2,4,6)).X + 0.5))
_z7_ebf193e = 40
elseif _z7_ebf193e == 21 then
_z8_3e9564c = function(S, off, len, start)
local st = start
local out = table.create and table.create(len) or {}
for i = 1, len do
st = (st * _z34_c800dd9(1766775817, _z34_c800dd9(_z21_1ff804e, _z12_6254869)) + _z34_c800dd9(3399547697, _z34_c800dd9(_z21_1ff804e, _z12_6254869))) % 4294967296
local k = math.floor(st / 16777216) % 256
out[i] = _z32_7b92cad(_z34_c800dd9(_z19_0dfa4c5(S, off + i - 1), k))
end
return table.concat(out)
end
_z7_ebf193e = 13
elseif _z7_ebf193e == 38 then
MAX_CONSTS = 1048576
_z7_ebf193e = 20
elseif _z7_ebf193e == 10 then
_z31_2b4df4d = table.unpack or unpack
_z7_ebf193e = 15
elseif _z7_ebf193e == 20 then
MAX_CODE = 4194304
_z7_ebf193e = 4
elseif _z7_ebf193e == 35 then
_z34_c800dd9 = bit32.bxor
_z7_ebf193e = 32
elseif _z7_ebf193e == 37 then
MAX_UPVALS = 65536
_z7_ebf193e = 38
elseif _z7_ebf193e == 15 then
_z23_8b4e4fd = table.pack or function(...) return { n = select('#', ...), ... } end
_z7_ebf193e = 16
elseif _z7_ebf193e == 9 then
_z9_721da8d = _z43_3dc7258(_z54_b2d580a)
_z7_ebf193e = 17 + ((_z12_6254869~=2967163558) and 3143 or 0)
elseif _z7_ebf193e == 16 then
_z41_17c1fd5 = _G
_z7_ebf193e = 36
elseif _z7_ebf193e == 11 then
_z12_6254869 = bit32.bxor(bit32.bxor(_z12_6254869, bit32.lshift(_z12_6254869, 5)), math.floor(Vector3.new(2,3,6).Magnitude + 0.5))
_z7_ebf193e = 22
elseif _z7_ebf193e == 12 then
_z17_8e3f0bc = function(S, start)
local n = #S
local pos = start
local function u8()
if pos > n then error() end
local v = _z19_0dfa4c5(S, pos) pos = pos + 1 return v
end
local function take(k)
if pos + k - 1 > n then error() end
local off = pos pos = pos + k return off
end
local function u16() local lo = u8() local hi = u8() return lo + hi * 256 end
local function uleb()
local result, shift, cnt = 0, 1, 0
while true do
local b = u8() cnt = cnt + 1
if cnt > 5 then error() end
result = result + (b % 128) * shift
if b < 128 then
if result > 4294967295 then error() end
return result
end
shift = shift * 128
end
end
local function sleb()
local result, shift, cnt = 0, 1, 0
while true do
local b = u8() cnt = cnt + 1
if cnt > 5 then error() end
result = result + (b % 128) * shift
shift = shift * 128
if b < 128 then
if b % 128 >= 64 then result = result - shift end
if result < -2147483648 or result > 2147483647 then error() end
return result
end
end
end
local function count(max)
local c = uleb()
if c > max then error() end
if c > n - pos + 1 then error() end
return c
end
local function eof() if pos ~= n + 1 then error() end end
local function at() return pos end
return u8, take, u16, uleb, sleb, count, eof, at
end
_z7_ebf193e = 2
elseif _z7_ebf193e == 3 then
MAX_POOL = 1048576
_z7_ebf193e = 12
elseif _z7_ebf193e == 29 then
do

local bxor, lrot, band, bor = bit32.bxor, bit32.lrotate, bit32.band, bit32.bor
local floor = math.floor
local function u32(x) return x % 4294967296 end
local function qr(s, a, b, c, d)
s[a] = u32(s[a] + s[b]); s[d] = lrot(bxor(s[d], s[a]), 16)
s[c] = u32(s[c] + s[d]); s[b] = lrot(bxor(s[b], s[c]), 12)
s[a] = u32(s[a] + s[b]); s[d] = lrot(bxor(s[d], s[a]), 8)
s[c] = u32(s[c] + s[d]); s[b] = lrot(bxor(s[b], s[c]), 7)
end
local function _z48_5262f27(b, off)
return b[off] + b[off + 1] * 256 + b[off + 2] * 65536 + b[off + 3] * 16777216
end
local function _z29_27ccf12(key, counter, nonce)
local s = {
bit32.bxor(0xb3867564, 0xd2f60d01), bit32.bxor(0x0b3d4d3a, 0x381d2954), bit32.bxor(0x42e7561d, 0x3b857b2f), bit32.bxor(0x930ae3dc, 0xf82a86a8),
_z48_5262f27(key, 1), _z48_5262f27(key, 5), _z48_5262f27(key, 9), _z48_5262f27(key, 13),
_z48_5262f27(key, 17), _z48_5262f27(key, 21), _z48_5262f27(key, 25), _z48_5262f27(key, 29),
counter, _z48_5262f27(nonce, 1), _z48_5262f27(nonce, 5), _z48_5262f27(nonce, 9),
}
local w = {}
for i = 1, 16 do w[i] = s[i] end
for _ = 1, 10 do
qr(w,1,5,9,13); qr(w,2,6,10,14); qr(w,3,7,11,15); qr(w,4,8,12,16)
qr(w,1,6,11,16); qr(w,2,7,12,13); qr(w,3,8,9,14); qr(w,4,5,10,15)
end
local out = {}
for i = 1, 16 do
local v = u32(w[i] + s[i])
local b = (i - 1) * 4
out[b+1] = v % 256; out[b+2] = floor(v/256) % 256
out[b+3] = floor(v/65536) % 256; out[b+4] = floor(v/16777216) % 256
end
return out
end
local function _z35_cc1f3f6(key, counter0, nonce, data, dlen)
local out, block = {}, nil
for i = 0, dlen - 1 do
local bi = i % 64
if bi == 0 then block = _z29_27ccf12(key, counter0 + floor(i/64), nonce) end
out[i+1] = bxor(data[i+1], block[bi+1])
end
return out
end
local function _z22_fb70fb8(bytes, off, nbytes, append)
local L = {0,0,0,0,0,0,0,0,0,0}
local acc, accbits, li = 0, 0, 1
for i = 0, nbytes - 1 do
acc = acc + bytes[off+i] * (2 ^ accbits); accbits = accbits + 8
while accbits >= 13 do L[li] = acc % 8192; acc = floor(acc/8192); accbits = accbits - 13; li = li + 1 end
end
if append then
acc = acc + (2 ^ accbits); accbits = accbits + 1
while accbits >= 13 and li <= 10 do L[li] = acc % 8192; acc = floor(acc/8192); accbits = accbits - 13; li = li + 1 end
end
if li <= 10 then L[li] = L[li] + acc end
return L
end
local function _z14_6b4eb5f(a)
local out = {}
local acc, accbits, k = 0, 0, 1
for i = 1, 10 do
acc = acc + a[i] * (2 ^ accbits); accbits = accbits + 13
while accbits >= 8 and k <= 16 do out[k] = acc % 256; acc = floor(acc/256); accbits = accbits - 8; k = k + 1 end
end
while k <= 16 do out[k] = acc % 256; acc = floor(acc/256); k = k + 1 end
return out
end
local function _z42_4c67042(a, n)
local r, c = {}, 0
for k = 1, 10 do local v = a[k] + n[k] + c; r[k] = v % 8192; c = floor(v/8192) end
while c > 0 do
local v = r[1] + 5 * c; r[1] = v % 8192; c = floor(v/8192)
local k = 2
while c > 0 and k <= 10 do v = r[k] + c; r[k] = v % 8192; c = floor(v/8192); k = k + 1 end
end
return r
end
local function _z37_3cec2a9(a, b)
local d = {}
for k = 1, 19 do d[k] = 0 end
for i = 1, 10 do
local ai = a[i]
if ai ~= 0 then for j = 1, 10 do d[i+j-1] = d[i+j-1] + ai * b[j] end end
end
for k = 19, 11, -1 do d[k-10] = d[k-10] + 5 * d[k]; d[k] = 0 end
local c = 0
for k = 1, 10 do local v = d[k] + c; d[k] = v % 8192; c = floor(v/8192) end
while c > 0 do
local v = d[1] + 5 * c; d[1] = v % 8192; c = floor(v/8192)
local k = 2
while c > 0 and k <= 10 do v = d[k] + c; d[k] = v % 8192; c = floor(v/8192); k = k + 1 end
end
local r = {}
for k = 1, 10 do r[k] = d[k] end
return r
end
local _z13_8119778 = {8187,8191,8191,8191,8191,8191,8191,8191,8191,8191}
local function _z1_e7c10aa(a)
local diff, borrow = {}, 0
for k = 1, 10 do
local v = a[k] - _z13_8119778[k] - borrow
if v < 0 then v = v + 8192; borrow = 1 else borrow = 0 end
diff[k] = v
end
if borrow == 0 then return diff else return a end
end
local function _z3_bf7c051(rkey, data, dlen)
local r = {}
for i = 1, 16 do r[i] = rkey[i] end
r[4] = band(r[4],15); r[8] = band(r[8],15); r[12] = band(r[12],15); r[16] = band(r[16],15)
r[5] = band(r[5],252); r[9] = band(r[9],252); r[13] = band(r[13],252)
local rl = _z22_fb70fb8(r, 1, 16, false)
local s = {}
for i = 1, 16 do s[i] = rkey[16+i] end
local a = {0,0,0,0,0,0,0,0,0,0}
local i = 0
while i < dlen do
local blen = math.min(16, dlen - i)
a = _z42_4c67042(a, _z22_fb70fb8(data, i+1, blen, true))
a = _z37_3cec2a9(rl, a)
i = i + blen
end
a = _z1_e7c10aa(a)
local ab = _z14_6b4eb5f(a)
local tag, c = {}, 0
for k = 1, 16 do local v = ab[k] + s[k] + c; tag[k] = v % 256; c = floor(v/256) end
return tag
end
local function _z5_b24f1e4(key, nonce)
local block = _z29_27ccf12(key, 0, nonce)
local _z53_85215cd = {}
for i = 1, 32 do _z53_85215cd[i] = block[i] end
return _z53_85215cd
end
local function _z26_2f1da75(aad, alen, ct, clen)
local mac, mi = {}, 0
for i = 1, alen do mi = mi + 1; mac[mi] = aad[i] end
local pa = alen % 16
if pa ~= 0 then for _ = 1, 16 - pa do mi = mi + 1; mac[mi] = 0 end end
for i = 1, clen do mi = mi + 1; mac[mi] = ct[i] end
local pc = clen % 16
if pc ~= 0 then for _ = 1, 16 - pc do mi = mi + 1; mac[mi] = 0 end end
local function le64(len)
local x = len
for _ = 1, 4 do mi = mi + 1; mac[mi] = x % 256; x = floor(x/256) end
for _ = 1, 4 do mi = mi + 1; mac[mi] = 0 end
end
le64(alen); le64(clen)
return mac, mi
end

function _z20_0a3a448(key, nonce, aad, alen, ct, clen, tag)
local _z53_85215cd = _z5_b24f1e4(key, nonce)
local mac, maclen = _z26_2f1da75(aad, alen, ct, clen)
local expected = _z3_bf7c051(_z53_85215cd, mac, maclen)
local diff = 0
for i = 1, 16 do diff = bor(diff, bxor(expected[i], tag[i])) end
if diff ~= 0 then return nil end
return _z35_cc1f3f6(key, 1, nonce, ct, clen)
end
end
_z7_ebf193e = 24
elseif _z7_ebf193e == 1 then
_z12_6254869 = bit32.bxor(bit32.bxor(_z12_6254869, bit32.lshift(_z12_6254869, 5)), math.floor(Vector3.new(1,2,2):Cross(Vector3.new(2,-2,1)):Dot(Vector3.new(1,1,1)) + 0.5))
_z7_ebf193e = 11
elseif _z7_ebf193e == 26 then
_z21_1ff804e = _z25_8450505
_z7_ebf193e = 33
end
end
