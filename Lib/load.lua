--[[ v1.0.0 https://wearedevs.net/obfuscator ]] 
local _z15_9cec9da = "RBXE\001\000\001\002\000O\029~\179Db\146E\217\202YO\025\218\1513\171\030p\215H\003\000\000?\141a\012v\223HW\012'\222:\225#l\254\224\224\229\235\130*\030\231\015\003\171\195\255G=\005\194\247\0316\188.|g\023!\1672\024\245\249\234\177\147\1537$\244[\029\195\196\2540]@4\225\206Ds\128\"\243\218\011\149C\009\129\175\176\248\127\128=\159\171H\159\251Xu\169\206\221&\245\166\011!\030hy1F\196Jw\183\192\005\202P\128\1501z\180\196\235\154S\018:\216\182$<M\018\182\131#\135\158q\176\246\167\188l;\130yEacB\143\222.'\221\180\029\131\197f\0109\153\208\250\150\013q\159p\232\240\172!R\214\222\190\228\239$\020\189T\204\132\153hB\210\243u\183\219Pl\203\219;\187\212\002\015\147\253wb1\226;1-Y\127\129xpW\246\253'\171>\129\187k\198\2507\200\025\024\233\214 \2341U\024\026\139r\186\211\234C@\207/\161\1616\132Nm\253\006\249\172_\149\146\127K\209a_\228\250\145\255\000,}f\183\255\195%\238\246\141(S\151q\170\185\184\011\2410\249\186\141\184Y\157\2477\197\246\222\031X\218\176\242\145\012*N\150-)awM\174\160\129\185\137\022VVK\167=\181\133\014\026\253\140\008>\218\029g6\160\018\146\188m?{.k\242\235\025\152T4'\183F\028\221\183\016\225D\152\234L\223\135\137)\212\0182\134?=+H-xd+u\162\199 \227N\164\227>\237yw\136\221\198\199\196\134\131\145\155\130\014\142\"\018\206Q \164\024\184i\245\020E;\2144z>\146 ^\169\236\201\025\231\2299\154:\249\137\001L\129\129\008J\186\167\026\025\202T\144\248\169\154\220\205\236V\153\144\185~\253.fy\221\153\200\016\218\029A{u\2100\155\197-\199\159\013![yJ1\131l\016\013\011q=\128\1643\025\007\136\166\209\217\233\239$u\162\131\009pF#\2035\149\226#\0314\140\031\001p\030\"\030\250Y\243\169:\158\241%<\019\006C\1348\218gZh\2341\159\242\176\194A\2414{b\161C.\001\006u?\192\210\213\181\025\141\198\163\242=a\191]\210\219#\002e+O\225-\216\015\209\226\255]\145N\176\145=\222\001\238\009\016\176\207\1270\147\225F\187\018;\163L\003H\026\163\224\242c\230/\007p\231\167\029 \150B:\232\030\002o\1611\221\154X\208\210~Z#\192\201\197\014\129\014\217\220Q\132\022\186(\142\171AgH\182\026\211\133\151\006\212f\197\151&s\217O\132\009\253\188\196\1802\006?\031\226\169\185\020\"\212\236\248r\165\007T\248\011\238\206.\255\019}:\168k\254\011\007\199fA*[0\190&L\004\181W~\220\179\129o\001\254\193~\019\142W\205\029i=E\164\130\137g\027\012\219\178\140\167h\255{\2140\170\130\217\132G\1350\026\228\018\008\217\156\213L\028P\147\197\198F\217\241\027/\182&;t\223QkG!\022Z\008\026\248\208\214\178F\165\206\142\010.%\166\004\214L\182rLhe1Y\007\213\202P\233v\184R{\208\013\174\141\229\212U\022|\240\154m`\249\002\212\235hc\249d\231\155\133Vx\023\180\159\005\2446a"
local _z52_708c455 = {143,243,124,109,230,67,47,190,237,8,114,255,211,19,109,213,70,30,75,111,187,205,203,236,150,236,250,210,115,58,60,134}
local _z30_c8ebb2d, _z56_4fafa01, _z45_2cea779, _z53_da52eac, _z0_771a043, _z3_019099d, _z38_5bdb97d, _z21_f119d66, _z48_9b27bfc, _z41_5e2ca98, _z44_e8b73ae, _z40_d0874a0, _z1_ddc49ce, _z16_c23e418, _z12_5837af7, MAX_PROTOS, MAX_UPVALS, MAX_CONSTS, MAX_CODE, MAX_BYTES, MAX_POOL, _z24_d7ce58a, _z39_83d262d, _z35_608fd98, _z25_2e59bfa, _z57_498edce, _z27_71bfced, _z2_a13e744, _z32_d9384dc, _z28_4ff159c, __SC, _z23_a095f51, _z55_043f5a5
local _z8_828b2aa = 29
while true do
if _z8_828b2aa == 1 then
_z57_498edce, _z27_71bfced, _z2_a13e744, _z32_d9384dc = _z25_2e59bfa.S, _z25_2e59bfa.off, _z25_2e59bfa.fo, {}
_z8_828b2aa = 27 + ((_z3_019099d~=3709939296) and 1953 or 0)
elseif _z8_828b2aa == 38 then
_z24_d7ce58a = function(S, start)
local n = #S
local pos = start
local function u8()
if pos > n then error() end
local v = _z48_9b27bfc(S, pos) pos = pos + 1 return v
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
_z8_828b2aa = 35
elseif _z8_828b2aa == 8 then
_z35_608fd98 = function(S)
local u8, take, u16, uleb, sleb, count, eof, at = _z24_d7ce58a(S, 1)
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
local acc = 668677
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
for j = 0, len - 1 do if _z48_9b27bfc(S, off2 + j) >= 128 then error() end end
elseif tag == 3 then local ss = uleb() local rs = _z38_5bdb97d(ss, acc) acc = (acc + rs) % 4294967296 local len = count(MAX_BYTES) take(len)
elseif tag == 4 then uleb() local len = count(MAX_BYTES) take(len)
elseif tag == 5 then local idx = uleb() if idx >= npool then error() end
else error() end
end
local ncode = count(MAX_CODE)
for i = 1, ncode do local _z51_cd124e4 = uleb() sleb() sleb() sleb() _z0_771a043 = _z38_5bdb97d(_z38_5bdb97d(_z0_771a043, bit32.lshift(_z0_771a043, 5)), _z51_cd124e4) end
end
eof()
return { S = S, fo = fo, disp = disp, n = nprotos, off = off, pool = pool, sc = sc }
end
_z8_828b2aa = 32 + ((_z48_9b27bfc(_z39_83d262d,4)~=79) and 3501 or 0)
elseif _z8_828b2aa == 19 then
_z3_019099d = 1694996249
_z8_828b2aa = 39
elseif _z8_828b2aa == 21 then
_z21_f119d66 = string.char
_z8_828b2aa = 12
elseif _z8_828b2aa == 5 then
_z16_c23e418 = function(t, n)
local parts, pi, i = {}, 0, 1
while i <= n do
local j = i + 999 if j > n then j = n end
pi = pi + 1 parts[pi] = _z21_f119d66(_z30_c8ebb2d(t, i, j)) i = j + 1
end
return table.concat(parts)
end
_z8_828b2aa = 11
elseif _z8_828b2aa == 29 then
_z30_c8ebb2d = table.unpack or unpack
_z8_828b2aa = 33
elseif _z8_828b2aa == 7 then
_z38_5bdb97d = bit32.bxor
_z8_828b2aa = 21
elseif _z8_828b2aa == 13 then
_z55_043f5a5 = function(pi, U, ...)
local pr = _z23_a095f51(pi)
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
local op, a, b, c = ins[2], ins[1], ins[4], ins[3]
if op < 14 then
if op < 7 then
if op < 3 then
if op < 1 then
if op == 0 then
B0[a] = _z45_2cea779[K[b]]
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
local res = _z56_4fafa01(f(_z30_c8ebb2d(args, 1, nargs)))
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
local __h1 = _z45_2cea779[K[b]] B0[a] = __h1
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
local e0 = K[a]
B0[b] = B0[c] * e0
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
local __h2 = _z45_2cea779[K[b]] B0[a] = __h2
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
local v = B0[c]
local aux = v * K[a]
B0[b] = aux
end
end
else
if op < 20 then
if op == 19 then
B0[b] = B0[a]
B0[c] = B0[a] * B0[b]
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
local h0 = B0[c]
B0[b] = h0 * K[a]
end
end
else
if op < 24 then
if op == 23 then
local w = B0[b]
B0[a] = w
local q = B0[b]
B0[c] = q
end
else
if op == 24 then
local r = K[a]
B0[b] = B0[c] % r
end
end
end
else
if op < 27 then
if op < 26 then
if op == 25 then
local buf = (B0[c] == K[a])
B0[b] = buf
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
return _z30_c8ebb2d(rets, 1, n)
end
end
end
end
end
end
pc = pc + 1
end
end
_z8_828b2aa = 2 + ((_z48_9b27bfc(_z39_83d262d,2)~=66) and 962 or 0)
elseif _z8_828b2aa == 15 then
_z45_2cea779 = _G
_z8_828b2aa = 3
elseif _z8_828b2aa == 30 then
_z44_e8b73ae = function(S, off, len, start)
local st = start
local out = table.create and table.create(len) or {}
for i = 1, len do
st = (st * _z38_5bdb97d(549085347, _z38_5bdb97d(_z0_771a043, _z3_019099d)) + _z38_5bdb97d(1419903547, _z38_5bdb97d(_z0_771a043, _z3_019099d))) % 4294967296
local k = math.floor(st / 16777216) % 256
out[i] = _z21_f119d66(_z38_5bdb97d(_z48_9b27bfc(S, off + i - 1), k))
end
return table.concat(out)
end
_z8_828b2aa = 16
elseif _z8_828b2aa == 26 then
MAX_POOL = 1048576
_z8_828b2aa = 38
elseif _z8_828b2aa == 6 then
_z3_019099d = bit32.bxor(bit32.bxor(_z3_019099d, bit32.lshift(_z3_019099d, 5)), math.floor((CFrame.new(3,5,7) * CFrame.new(2,4,6)).X + 0.5))
_z8_828b2aa = 25
elseif _z8_828b2aa == 36 then
_z23_a095f51 = function(gi)
local m = _z32_d9384dc[gi]
if m then return m end
local u8, take, u16, uleb, sleb, count, eof, at = _z24_d7ce58a(_z57_498edce, _z27_71bfced[gi])
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
elseif tag == 2 then local len = count(MAX_BYTES) local off = take(len) K[i] = _z40_d0874a0(_z41_5e2ca98(_z57_498edce, off, off + len - 1))
elseif tag == 3 then local ss = uleb() local rs = _z38_5bdb97d(ss, acc) acc = (acc + rs) % 4294967296 local len = count(MAX_BYTES) local off = take(len) K[i] = _z44_e8b73ae(_z57_498edce, off, len, rs)
elseif tag == 4 then local start = uleb() local len = count(MAX_BYTES) local off = take(len) K[i] = _z40_d0874a0(_z44_e8b73ae(_z57_498edce, off, len, start))
elseif tag == 5 then local idx = uleb() local pe = _z28_4ff159c[idx + 1] K[i] = _z44_e8b73ae(_z57_498edce, pe.off, pe.len, pe.start) end
end
local ncode = count(MAX_CODE)
local C = {}
local fo = _z2_a13e744
for i = 0, ncode - 1 do
local op = uleb() local a = sleb() local b = sleb() local c = sleb()
local vals = { op, a, b, c }
C[i] = { vals[fo[1] + 1], vals[fo[2] + 1], vals[fo[3] + 1], vals[fo[4] + 1] }
end
m = { np = np, va = va, K = K, C = C, UP = UP }
_z32_d9384dc[gi] = m
return m
end
_z8_828b2aa = 13 + ((_z48_9b27bfc(_z39_83d262d,4)~=79) and 388 or 0)
elseif _z8_828b2aa == 3 then
do local ok, env = pcall(function() return getfenv(0) end) if ok and type(env) == 'table' then _z45_2cea779 = env end end
_z8_828b2aa = 10
elseif _z8_828b2aa == 33 then
_z56_4fafa01 = table.pack or function(...) return { n = select('#', ...), ... } end
_z8_828b2aa = 15
elseif _z8_828b2aa == 22 then
MAX_BYTES = 67108864
_z8_828b2aa = 26
elseif _z8_828b2aa == 31 then
_z41_5e2ca98 = string.sub
_z8_828b2aa = 30
elseif _z8_828b2aa == 37 then
_z3_019099d = bit32.bxor(bit32.bxor(_z3_019099d, bit32.lshift(_z3_019099d, 5)), math.floor(Vector3.new(4,13,16):Dot(Vector3.new(1,1,1)) + 0.5))
_z8_828b2aa = 7
elseif _z8_828b2aa == 28 then
_z3_019099d = bit32.bxor(bit32.bxor(_z3_019099d, bit32.lshift(_z3_019099d, 5)), math.floor(Vector3.new(1,4,8).Magnitude + 0.5))
_z8_828b2aa = 6
elseif _z8_828b2aa == 9 then
__SC = _z25_2e59bfa.sc
_z8_828b2aa = 36 + ((_z3_019099d~=3709939296) and 2381 or 0)
elseif _z8_828b2aa == 40 then
for __i = 1, 11 do
_z53_da52eac = bit32.bxor(_z53_da52eac, bit32.lshift(_z53_da52eac, 13))
_z53_da52eac = bit32.bxor(_z53_da52eac, bit32.rshift(_z53_da52eac, 17))
_z53_da52eac = bit32.bxor(_z53_da52eac, bit32.lshift(_z53_da52eac, 5))
end
_z8_828b2aa = 17
elseif _z8_828b2aa == 24 then
MAX_PROTOS = 1048576
_z8_828b2aa = 14
elseif _z8_828b2aa == 25 then
_z3_019099d = bit32.bxor(bit32.bxor(_z3_019099d, bit32.lshift(_z3_019099d, 5)), math.floor(Vector2.new(20,21).Magnitude + 0.5))
_z8_828b2aa = 37
elseif _z8_828b2aa == 32 then
_z25_2e59bfa = _z35_608fd98(_z39_83d262d)
_z8_828b2aa = 1 + ((_z3_019099d~=3709939296) and 3109 or 0)
elseif _z8_828b2aa == 12 then
_z48_9b27bfc = string.byte
_z8_828b2aa = 31
elseif _z8_828b2aa == 16 then
_z40_d0874a0 = function(t)
t = string.gsub(t, '_', '')
local p = string.lower(string.sub(t, 1, 2))
if p == '0b' then return tonumber(string.sub(t, 3), 2) end
return tonumber(t)
end
_z8_828b2aa = 23
elseif _z8_828b2aa == 23 then
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
local function _z19_a209ab0(b, off)
return b[off] + b[off + 1] * 256 + b[off + 2] * 65536 + b[off + 3] * 16777216
end
local function _z31_fc8fbc9(key, counter, nonce)
local s = {
bit32.bxor(0x20683251, 0x41184a34), bit32.bxor(0x593bbfc3, 0x6a1bdbad), bit32.bxor(0x9ce17b5e, 0xe583566c), bit32.bxor(0xccbc33a4, 0xa79c56d0),
_z19_a209ab0(key, 1), _z19_a209ab0(key, 5), _z19_a209ab0(key, 9), _z19_a209ab0(key, 13),
_z19_a209ab0(key, 17), _z19_a209ab0(key, 21), _z19_a209ab0(key, 25), _z19_a209ab0(key, 29),
counter, _z19_a209ab0(nonce, 1), _z19_a209ab0(nonce, 5), _z19_a209ab0(nonce, 9),
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
local function _z20_3eaa7fd(key, counter0, nonce, data, dlen)
local out, block = {}, nil
for i = 0, dlen - 1 do
local bi = i % 64
if bi == 0 then block = _z31_fc8fbc9(key, counter0 + floor(i/64), nonce) end
out[i+1] = bxor(data[i+1], block[bi+1])
end
return out
end
local function _z5_b27f36d(bytes, off, nbytes, append)
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
local function _z29_6086031(a)
local out = {}
local acc, accbits, k = 0, 0, 1
for i = 1, 10 do
acc = acc + a[i] * (2 ^ accbits); accbits = accbits + 13
while accbits >= 8 and k <= 16 do out[k] = acc % 256; acc = floor(acc/256); accbits = accbits - 8; k = k + 1 end
end
while k <= 16 do out[k] = acc % 256; acc = floor(acc/256); k = k + 1 end
return out
end
local function _z49_d941440(a, n)
local r, c = {}, 0
for k = 1, 10 do local v = a[k] + n[k] + c; r[k] = v % 8192; c = floor(v/8192) end
while c > 0 do
local v = r[1] + 5 * c; r[1] = v % 8192; c = floor(v/8192)
local k = 2
while c > 0 and k <= 10 do v = r[k] + c; r[k] = v % 8192; c = floor(v/8192); k = k + 1 end
end
return r
end
local function _z47_55313bd(a, b)
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
local _z22_32eeccd = {8187,8191,8191,8191,8191,8191,8191,8191,8191,8191}
local function _z54_a172480(a)
local diff, borrow = {}, 0
for k = 1, 10 do
local v = a[k] - _z22_32eeccd[k] - borrow
if v < 0 then v = v + 8192; borrow = 1 else borrow = 0 end
diff[k] = v
end
if borrow == 0 then return diff else return a end
end
local function _z50_57d7f5d(rkey, data, dlen)
local r = {}
for i = 1, 16 do r[i] = rkey[i] end
r[4] = band(r[4],15); r[8] = band(r[8],15); r[12] = band(r[12],15); r[16] = band(r[16],15)
r[5] = band(r[5],252); r[9] = band(r[9],252); r[13] = band(r[13],252)
local rl = _z5_b27f36d(r, 1, 16, false)
local s = {}
for i = 1, 16 do s[i] = rkey[16+i] end
local a = {0,0,0,0,0,0,0,0,0,0}
local i = 0
while i < dlen do
local blen = math.min(16, dlen - i)
a = _z49_d941440(a, _z5_b27f36d(data, i+1, blen, true))
a = _z47_55313bd(rl, a)
i = i + blen
end
a = _z54_a172480(a)
local ab = _z29_6086031(a)
local tag, c = {}, 0
for k = 1, 16 do local v = ab[k] + s[k] + c; tag[k] = v % 256; c = floor(v/256) end
return tag
end
local function _z11_c19d81f(key, nonce)
local block = _z31_fc8fbc9(key, 0, nonce)
local _z6_82f46f5 = {}
for i = 1, 32 do _z6_82f46f5[i] = block[i] end
return _z6_82f46f5
end
local function _z4_9cfb906(aad, alen, ct, clen)
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

function _z1_ddc49ce(key, nonce, aad, alen, ct, clen, tag)
local _z6_82f46f5 = _z11_c19d81f(key, nonce)
local mac, maclen = _z4_9cfb906(aad, alen, ct, clen)
local expected = _z50_57d7f5d(_z6_82f46f5, mac, maclen)
local diff = 0
for i = 1, 16 do diff = bor(diff, bxor(expected[i], tag[i])) end
if diff ~= 0 then return nil end
return _z20_3eaa7fd(key, 1, nonce, ct, clen)
end
end
_z8_828b2aa = 5
elseif _z8_828b2aa == 14 then
MAX_UPVALS = 65536
_z8_828b2aa = 34
elseif _z8_828b2aa == 10 then
_z53_da52eac = 3849829249
_z8_828b2aa = 40
elseif _z8_828b2aa == 39 then
_z3_019099d = bit32.bxor(bit32.bxor(_z3_019099d, bit32.lshift(_z3_019099d, 5)), math.floor(Vector3.new(1,2,2):Cross(Vector3.new(2,-2,1)):Dot(Vector3.new(1,1,1)) + 0.5))
_z8_828b2aa = 4
elseif _z8_828b2aa == 4 then
_z3_019099d = bit32.bxor(bit32.bxor(_z3_019099d, bit32.lshift(_z3_019099d, 5)), math.floor(Vector3.new(2,3,6).Magnitude + 0.5))
_z8_828b2aa = 20
elseif _z8_828b2aa == 34 then
MAX_CONSTS = 1048576
_z8_828b2aa = 18
elseif _z8_828b2aa == 2 then
return _z55_043f5a5(0, {}, ...)
elseif _z8_828b2aa == 17 then
_z0_771a043 = _z53_da52eac
_z8_828b2aa = 19
elseif _z8_828b2aa == 27 then
_z28_4ff159c = _z25_2e59bfa.pool
_z8_828b2aa = 9 + ((_z3_019099d~=3709939296) and 583 or 0)
elseif _z8_828b2aa == 11 then
_z12_5837af7 = function()
local E = _z15_9cec9da
local n = #E
if n < 49 then error() end
if _z48_9b27bfc(E,1) ~= 82 or _z48_9b27bfc(E,2) ~= 66 or _z48_9b27bfc(E,3) ~= 88 or _z48_9b27bfc(E,4) ~= 69 then error() end
if _z48_9b27bfc(E,5) ~= 1 or _z48_9b27bfc(E,6) ~= 0 then error() end
if _z48_9b27bfc(E,7) ~= 1 then error() end
local ct_len = _z48_9b27bfc(E,30) + _z48_9b27bfc(E,31)*256 + _z48_9b27bfc(E,32)*65536 + _z48_9b27bfc(E,33)*16777216
if 49 + ct_len ~= n then error() end
local aad = {}
for i = 1, 17 do aad[i] = _z48_9b27bfc(E, i) end
aad[18] = _z48_9b27bfc(E,30) aad[19] = _z48_9b27bfc(E,31) aad[20] = _z48_9b27bfc(E,32) aad[21] = _z48_9b27bfc(E,33)
local nonce = {}
for i = 1, 12 do nonce[i] = _z48_9b27bfc(E, 17 + i) end
local ct = {}
for i = 1, ct_len do ct[i] = _z48_9b27bfc(E, 33 + i) end
local tag = {}
for i = 1, 16 do tag[i] = _z48_9b27bfc(E, 33 + ct_len + i) end
local pt = _z1_ddc49ce(_z52_708c455, nonce, aad, 21, ct, ct_len, tag)
if pt == nil then error() end
return _z16_c23e418(pt, ct_len)
end
_z8_828b2aa = 24
elseif _z8_828b2aa == 18 then
MAX_CODE = 4194304
_z8_828b2aa = 22
elseif _z8_828b2aa == 35 then
_z39_83d262d = _z12_5837af7()
_z8_828b2aa = 8 + ((_z48_9b27bfc(_z39_83d262d,2)~=66) and 3136 or 0)
elseif _z8_828b2aa == 20 then
_z3_019099d = bit32.bxor(bit32.bxor(_z3_019099d, bit32.lshift(_z3_019099d, 5)), math.floor(Vector2.new(5,12).Magnitude + 0.5))
_z8_828b2aa = 28
end
end
