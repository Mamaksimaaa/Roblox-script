--[[
=====================================================================
   KysHub CRACK  -   Grow A Garden 2 v1.5
   ModernV2 UI, Lumi red accents.
   Right Shift toggles UI.
=====================================================================
]]

--========================== SERVICES ==============================--
local Players          = game:GetService("Players")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CollectionService= game:GetService("CollectionService")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer

--========================== GAME API ==============================--
local Net = (function() local ok,m = pcall(function() return require(ReplicatedStorage.SharedModules.Networking) end) return ok and m or nil end)()
local PSC = (function() local ok,m = pcall(function() return require(ReplicatedStorage.ClientModules.PlayerStateClient) end) return ok and m or nil end)()
if not Net then warn("[KysHub] Networking module missing - aborting."); return end

local SeedData = (function() local ok,d = pcall(function() return require(ReplicatedStorage.SharedModules.SeedData) end) return ok and d or {} end)()
local SeedPrice = {}
for _, e in ipairs(SeedData) do
    if type(e) == "table" and e.SeedName then SeedPrice[e.SeedName] = tonumber(e.PurchasePrice) or math.huge end
end
local FruitValueCalc = (function() local ok,m = pcall(function() return require(ReplicatedStorage.SharedModules.FruitValueCalc) end) return (ok and type(m) == "function") and m or nil end)()
-- FruitValueCalc can't be called from spawned loop threads (executor capability),
-- so precompute each crop's base value here on the main thread and cache it.
local SeedBaseValue = {}
if FruitValueCalc then
    for _, e in ipairs(SeedData) do
        if type(e) == "table" and e.SeedName then
            local ok, v = pcall(FruitValueCalc, e.SeedName, 1, nil, LocalPlayer, nil)
            SeedBaseValue[e.SeedName] = (ok and type(v) == "number") and v or 0
        end
    end
end
local MUT_BONUS = 2.35  -- rough multiplier for any mutation (gold/rainbow/etc.)
local SIZE_EXP  = 2.65  -- FruitValueCalc scales value by size^2.65
local function sizeMul(sz) sz = tonumber(sz) or 1 return sz ^ SIZE_EXP end
local PetData = (function() local ok,m = pcall(function() return require(ReplicatedStorage.SharedData.PetData) end) return ok and m or {} end)()
local function getAnimalOptions()
    local list = {}
    for k, v in pairs(PetData) do if type(v) == "table" and type(k) == "string" then list[#list + 1] = k end end
    table.sort(list); return list
end

--========================== LIFECYCLE =============================--
local Hub = { running = true, conns = {} }
local genv = (getgenv and getgenv()) or _G
local oldUnloadKey = "GAG" .. "360_unload"
if genv[oldUnloadKey] then pcall(genv[oldUnloadKey]) end
if genv.KysHub_unload then pcall(genv.KysHub_unload) end
local function track(conn) table.insert(Hub.conns, conn); return conn end
local function spawnLoop(interval, fn)
    task.spawn(function()
        while Hub.running do
            task.wait(interval)
            if not Hub.running then break end
            pcall(fn)
        end
    end)
end

--========================== STATE =================================--
local S = {
    autoBuySeed = false, buySeeds = {},
    autoPlant = false, plantSeeds = {}, plantReserve = 0, maxPerCycle = 40, plantDelay = 0.14, plantLoop = 1.2, smartReplant = false, autoExpand = false,
    plantPattern = "Fill", plantSource = "My Seeds", autoBuild = false, removeCrops = {},
    autoCollect = false, harvestCrops = {}, harvestMutsOnly = false, perFruitDelay = 0.05, harvestLoop = 1,
    autoSell = false, sellSpamDelay = 0.15, sellOnFull = false,
    autoSteal = false, stealReturn = true, stealMult = 1,
    panicHarvest = false, retaliate = false,
    autoGrabPacks = false, grabRareOnly = true, packReturn = true, notifyRare = true,
    autoBuyGear = false, buyGears = {}, autoBuyCrate = false,
    autoEggs = false, autoCrates = false, autoPacks = false,
    autoTame = false, tameAnimals = {}, autoEquipPets = false, equipPets = {},
    autoSellPets = false, autoSellMinRarity = "Rare",
    autoWater = false,
    walkSpeed = 16, jumpPower = 50, infJump = false, noclip = false, fly = false, flySpeed = 60,
    antiAfk = true, optimize = false, autoProgress = false,
    highlightReady = false, highlightRare = false, rareNotify = false,
    webhookUrl = "", whRareSeed = false, whBigHarvest = false, autoHopRare = false,
    -- MAIL (auto send)
    autoMail = false, mailRecipient = "", mailInterval = 45, mailNote = "",
    mailItemType = "Gears", mailItemName = "", mailCount = 1, mailSendAll = false,
    -- V1.5 ADDITIONS
    autoBuyAuction = false, auctionSnipeMode = "Min Price Only", auctionMaxPrice = 5000, buyAuctionTypes = {},
    autoMergeEclipse = false, autoCastWeatherStaff = false, weatherStaffTarget = "Any", autoClaimMail = false,
}

-- settings persistence: save S to disk, restore it on next load (toggles, sliders, picks)
local SAVE_FILE = "KysHub_GrowAGarden2.json"
local HttpService = game:GetService("HttpService")
local function saveSettings()
    if not writefile then return end
    pcall(function() writefile(SAVE_FILE, HttpService:JSONEncode(S)) end)
end
local function loadSettings()
    if not (readfile and isfile) then return end
    local ok, raw = pcall(function() return isfile(SAVE_FILE) and readfile(SAVE_FILE) or nil end)
    if not (ok and raw) then return end
    local good, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not (good and type(data) == "table") then return end
    for k, v in pairs(data) do
        if S[k] ~= nil then
            if type(S[k]) == "table" and type(v) == "table" then
                table.clear(S[k]); for kk, vv in pairs(v) do S[k][kk] = vv end  -- keep the table reference the UI holds
            elseif type(S[k]) == type(v) then
                S[k] = v
            end
        end
    end
end
loadSettings()

--========================== HELPERS ===============================--
local function getReplica() if not PSC then return nil end local ok,r = pcall(function() return PSC:GetLocalReplica() end) return ok and r or nil end
local function getData()    local r = getReplica() return r and r.Data or nil end
local function getSheckles() local d = getData() return d and d.Sheckles or 0 end
local function myPlot()
    local g = Workspace:FindFirstChild("Gardens"); if not g then return nil end
    for _, plot in ipairs(g:GetChildren()) do if plot:GetAttribute("OwnerUserId") == LocalPlayer.UserId then return plot end end
end
local function isNight() local n = ReplicatedStorage:FindFirstChild("Night") return n and n.Value == true end
local function char()     return LocalPlayer.Character end
local function hrp()      local c = char() return c and c:FindFirstChild("HumanoidRootPart") end
local function humanoid() local c = char() return c and c:FindFirstChildOfClass("Humanoid") end
local function fire(pkt, ...) local a = {...} return pcall(function() return pkt:Fire(table.unpack(a)) end) end
local function teleportTo(pos) local r = hrp() if r and pos then r.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end end
local toast  -- cool in-hub slide-in notification (assigned once the GUI exists)
local function notify(t, title, col) if toast then toast(title or "KysHub", t, col) end pcall(function() Net.Notification:Fire("KysHub", t) end) end

local function setCharCollide(on)
    local c = char(); if not c then return end
    for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide = on end) end end
end
local HOP = 70
local function reach(pos)
    local r = hrp(); if not (r and pos) then return end
    local target = pos + Vector3.new(0, 3, 0)
    setCharCollide(false)  -- noclip while teleporting so we never snag on fences/geometry
    for _ = 1, 60 do
        local cur = r.Position; local delta = target - cur
        if delta.Magnitude <= HOP then r.CFrame = CFrame.new(target); break end
        r.CFrame = CFrame.new(cur + delta.Unit * HOP); RunService.Heartbeat:Wait()
    end
    if not S.noclip then setCharCollide(true) end  -- restore unless permanent noclip is on
end
local function fruitValue(m)
    local base = SeedBaseValue[m:GetAttribute("CorePartName") or m:GetAttribute("SeedName")] or 0
    return base * sizeMul(m:GetAttribute("SizeMulti") or 1) * (m:GetAttribute("Mutation") and MUT_BONUS or 1)
end
-- a fruit/plant is ready when its Age has reached MaxAge (reliable + cheap);
-- fall back to the presence of a HarvestPrompt-tagged prompt inside it.
local function modelRipe(m)
    local age = tonumber(m:GetAttribute("Age")); local mx = tonumber(m:GetAttribute("MaxAge"))
    if age and mx then return age >= mx - 0.001 end
    for _, d in ipairs(m:GetDescendants()) do
        if d:IsA("ProximityPrompt") and CollectionService:HasTag(d, "HarvestPrompt") then return true end
    end
    return false
end
-- scan only MY plot (fast + reliable) instead of every tagged prompt on the server
local function ownHarvestTargets(respectFilter)
    local useCrop = respectFilter and next(S.harvestCrops) ~= nil
    local out = {}
    local plot = myPlot(); if not plot then return out end
    local plants = plot:FindFirstChild("Plants"); if not plants then return out end
    local function consider(m)
        if not m:GetAttribute("PlantId") then return end
        local crop = m:GetAttribute("CorePartName") or m:GetAttribute("SeedName")
        local mutOk = (not respectFilter) or (not S.harvestMutsOnly) or (m:GetAttribute("Mutation") ~= nil)
        if ((not useCrop) or (crop and S.harvestCrops[crop] == true)) and mutOk then out[#out + 1] = m end
    end
    for _, plant in ipairs(plants:GetChildren()) do
        local fr = plant:FindFirstChild("Fruits")
        local fruits = fr and fr:GetChildren() or {}
        if #fruits > 0 then
            for _, m in ipairs(fruits) do if modelRipe(m) then consider(m) end end  -- multi-fruit crops
        elseif modelRipe(plant) then
            consider(plant)  -- single-harvest crops (carrot/tulip/bamboo) - the plant is the unit
        end
    end
    return out
end
local function stealTargets()
    local out = {}
    for _, p in ipairs(CollectionService:GetTagged("StealPrompt")) do
        local m = p.Parent and p.Parent:FindFirstAncestorWhichIsA("Model")
        if m then
            local uid = tonumber(m:GetAttribute("UserId"))
            if uid and uid ~= LocalPlayer.UserId and m:GetAttribute("PlantId") then out[#out + 1] = { model = m, value = fruitValue(m) } end
        end
    end
    table.sort(out, function(a, b) return a.value > b.value end)
    return out
end
local function collectModel(m)
    if not m or not m.Parent then return end
    local pid = m:GetAttribute("PlantId"); if not pid then return end
    reach(m:GetPivot().Position); task.wait(S.perFruitDelay)
    fire(Net.Garden.CollectFruit, pid, m:GetAttribute("FruitId") or "")
end
-- bulk harvest: stand at plot centre once, then fire CollectFruit for every ripe
-- fruit (own crops sit within ~20 studs of centre) - no per-fruit teleporting
local function harvestAll(respectFilter)
    local plot = myPlot(); local ref = plot and plot:FindFirstChild("PlotSizeReference"); local r = hrp()
    if ref and r and (Vector3.new(r.Position.X,0,r.Position.Z) - Vector3.new(ref.Position.X,0,ref.Position.Z)).Magnitude > 16 then
        reach(ref.Position); task.wait(0.12)
    end
    local t = ownHarvestTargets(respectFilter); local n = 0
    for _, m in ipairs(t) do
        local pid = m:GetAttribute("PlantId")
        if pid then fire(Net.Garden.CollectFruit, pid, m:GetAttribute("FruitId") or ""); n = n + 1; task.wait(S.perFruitDelay) end
    end
    return n
end
local function stealModel(m, mult, skipReach)
    if not m or not m.Parent then return end
    local uid = tonumber(m:GetAttribute("UserId")); local pid = m:GetAttribute("PlantId")
    if not (uid and pid) then return end
    if not skipReach then reach(m:GetPivot().Position); task.wait(0.05) end
    fire(Net.Steal.BeginSteal, uid, pid, m:GetAttribute("FruitId") or "")
    -- you can carry multiple fruits per steal - fire CompleteSteal mult times
    for _ = 1, math.max(1, mult or 1) do fire(Net.Steal.CompleteSteal) end
end

local function stockItems(shop)
    local sv = ReplicatedStorage:FindFirstChild("StockValues"); sv = sv and sv:FindFirstChild(shop)
    return sv and sv:FindFirstChild("Items")
end
local function seedStockItems() return stockItems("SeedShop") end
local function gearStockItems() return stockItems("GearShop") end
local function stockOf(shop, name) local it = stockItems(shop); local v = it and it:FindFirstChild(name) return (v and v:IsA("ValueBase")) and v.Value or 0 end
local function seedStockOf(name) return stockOf("SeedShop", name) end
local function gearStockOf(name) return stockOf("GearShop", name) end
local function getGearOptions()
    local it = gearStockItems(); local list = {}
    if it then for _, sv in ipairs(it:GetChildren()) do list[#list + 1] = sv.Name end end
    table.sort(list); return list
end
local function getSeedOptions()
    local seen = {}
    for _, e in ipairs(SeedData) do if e.SeedName then seen[e.SeedName] = tonumber(e.SeedShopDisplayOrder) or 900 end end
    local it = seedStockItems(); if it then for _, sv in ipairs(it:GetChildren()) do if seen[sv.Name] == nil then seen[sv.Name] = 899 end end end
    local list = {} for name, ord in pairs(seen) do list[#list + 1] = { name, ord } end
    table.sort(list, function(a, b) if a[2] == b[2] then return a[1] < b[1] end return a[2] < b[2] end)
    local names = {} for _, x in ipairs(list) do names[#names + 1] = x[1] end
    return names
end
-- ONLY the seeds currently in your inventory (live-updates with the shop dropdown loop)
local function getOwnedSeedOptions()
    local d = getData(); local order = {}
    for _, e in ipairs(SeedData) do if e.SeedName then order[e.SeedName] = tonumber(e.SeedShopDisplayOrder) or 900 end end
    local list = {}
    if d and d.Inventory and d.Inventory.Seeds then
        for n, c in pairs(d.Inventory.Seeds) do if (c or 0) > 0 then list[#list + 1] = n end end
    end
    table.sort(list, function(a, b) local oa, ob = order[a] or 900, order[b] or 900 if oa == ob then return a < b end return oa < ob end)
    return list
end
-- distinct crop types currently PLANTED in your garden (for the remove picker)
local function getPlantedOptions()
    local plot = myPlot(); local seen = {}
    if plot then local plants = plot:FindFirstChild("Plants")
        if plants then for _, pl in ipairs(plants:GetChildren()) do local s = pl:GetAttribute("SeedName") or pl:GetAttribute("CorePartName") if s then seen[s] = true end end end
    end
    local list = {} for k in pairs(seen) do list[#list + 1] = k end table.sort(list); return list
end
local function getHarvestOptions()
    local seen = {}
    local plot = myPlot()
    if plot then local plants = plot:FindFirstChild("Plants") if plants then for _, pl in ipairs(plants:GetChildren()) do local s = pl:GetAttribute("SeedName") or pl:GetAttribute("CorePartName") if s then seen[s] = true end end end end
    local d = getData(); if d and d.Inventory and d.Inventory.Seeds then for n in pairs(d.Inventory.Seeds) do seen[n] = true end end
    local list = {} for k in pairs(seen) do list[#list + 1] = k end table.sort(list); return list
end
local function getPetOptions()
    local d = getData(); local seen = {}
    if d and d.Inventory and d.Inventory.Pets then
        for _, info in pairs(d.Inventory.Pets) do local nm = (type(info) == "table" and (info.PetType or info.Name)) or tostring(info) if nm and nm ~= "" then seen[nm] = true end end
    end
    local list = {} for k in pairs(seen) do list[#list + 1] = k end table.sort(list); return list
end
local function maxEquip() return tonumber(LocalPlayer:GetAttribute("MaxEquippedPets")) or 3 end

-- most valuable seed you currently own (uses cached base values)
local function bestOwnedSeed()
    local d = getData(); local seeds = d and d.Inventory and d.Inventory.Seeds; if not seeds then return nil end
    local best, bestV
    for name, count in pairs(seeds) do
        if (count or 0) > 0 then local v = SeedBaseValue[name] or 0 if not bestV or v > bestV then best, bestV = name, v end end
    end
    return best, bestV
end
-- estimated worth of harvested fruit in your backpack (cached base * size * mutation)
local function inventoryValue()
    local total, n = 0, 0
    local function scan(c) if not c then return end for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") and (t:GetAttribute("HarvestedFruit") or t:GetAttribute("Fruit")) then
            n = n + 1
            local base = SeedBaseValue[t:GetAttribute("Fruit") or t:GetAttribute("CorePartName")] or 0
            total = total + base * sizeMul(t:GetAttribute("SizeMultiplier") or t:GetAttribute("SizeMulti") or 1) * (t:GetAttribute("Mutation") and MUT_BONUS or 1)
        end
    end end
    scan(LocalPlayer:FindFirstChild("Backpack")); scan(char())
    return total, n
end
local function abbrev(n)
    n = tonumber(n) or 0
    if n >= 1e9 then return string.format("%.2fB", n/1e9) end
    if n >= 1e6 then return string.format("%.2fM", n/1e6) end
    if n >= 1e3 then return string.format("%.1fK", n/1e3) end
    return tostring(math.floor(n))
end

local EVENT_NAME = { Moon = "Moonlit", Bloodmoon = "Blood Moon", Goldmoon = "Gold Moon",
    ["Rainbow Moon"] = "Rainbow Moon", ["Chained Moon"] = "Chained Moon", ["Pizza Moon"] = "Pizza Moon", Sunset = "Sunset", Day = "Day" }
local EVENT_COLOR = {
    Day = Color3.fromRGB(255,214,90), Sunset = Color3.fromRGB(255,150,90), Moon = Color3.fromRGB(190,150,255),
    Bloodmoon = Color3.fromRGB(176,32,32), Goldmoon = Color3.fromRGB(255,205,70), ["Rainbow Moon"] = Color3.fromRGB(255,120,200),
    ["Chained Moon"] = Color3.fromRGB(150,150,162), ["Pizza Moon"] = Color3.fromRGB(232,120,60) }
local function eventColorOf(r) return EVENT_COLOR[r] or Color3.fromRGB(225,225,230) end
local function eventNameOf(r) return EVENT_NAME[r] or tostring(r or "-") end
local function currentEvent() return workspace:GetAttribute("ActiveWeather"), workspace:GetAttribute("ActivePhase"), tonumber(workspace:GetAttribute("PhaseDuration")) end
local function fmtClock(s) s = math.max(0, math.floor(s or 0)) return string.format("%d:%02d", s // 60, s % 60) end
local function restockIn(shop)
    local sv = ReplicatedStorage:FindFirstChild("StockValues"); sv = sv and sv:FindFirstChild(shop)
    local nx = sv and sv:FindFirstChild("UnixKystRestock")
    return nx and math.max(0, nx.Value - os.time()) or nil
end

--====================== GUI THEME (KysHub MODERNV2) ================--
local C = {
    bg     = Color3.fromRGB(17,17,20),  panel  = Color3.fromRGB(23,23,27),  card  = Color3.fromRGB(29,29,34),
    cardHi = Color3.fromRGB(36,36,42),  inset  = Color3.fromRGB(15,15,18),  stroke= Color3.fromRGB(46,46,53),
    white  = Color3.fromRGB(240,240,245), text = Color3.fromRGB(223,223,229), sub  = Color3.fromRGB(138,138,148),
    head   = Color3.fromRGB(120,120,130),
    accent = Color3.fromRGB(255, 0, 0),  accentDim = Color3.fromRGB(88, 0, 130),  accentText = Color3.fromRGB(205, 150, 255),
    green = Color3.fromRGB(80,220,130),  count = Color3.fromRGB(150,150,160),  rowOn = Color3.fromRGB(72,22,96),
}
-- number / money formatting
local function commafy(n)
    local neg = n < 0; local s = tostring(math.floor(math.abs(n) + 0.5))
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    return (neg and "-" or "") .. out
end
local function money(n) return "$" .. commafy(n) end
-- compact price tag with the game's coin sign, e.g. 700K¢ / 1.2M¢ / 5,000¢
local function fmtPrice(n)
    n = tonumber(n); if not n or n <= 0 or n == math.huge then return "" end
    local s
    if n >= 1e9 then s = string.format("%.1fB", n/1e9)
    elseif n >= 1e6 then s = string.format("%.1fM", n/1e6)
    elseif n >= 1e3 then s = string.format("%.0fK", n/1e3)
    else s = commafy(n) end
    s = s:gsub("%.0(%a)", "%1")
    return s .. "\xc2\xa2"
end
local function seedPriceTag(nm) return fmtPrice(SeedPrice[nm]) end

local function getWateringCan()
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and string.find(item.Name, "Watering Can") then return item end
        end
    end
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and string.find(item.Name, "Watering Can") then return item end
        end
    end
    return nil
end

local function equipWateringCan()
    local tool = getWateringCan()
    if not tool then return nil end
    local char = LocalPlayer.Character
    if tool.Parent ~= char then
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(tool)
            local elapsed = 0
            while tool.Parent ~= char and elapsed < 1 and Hub.running and S.autoWater do
                task.wait(0.05)
                elapsed = elapsed + 0.05
            end
        end
    end
    return tool
end

local function waterPlants()
    local plot = myPlot()
    local plants = plot and plot:FindFirstChild("Plants")
    if not plants then return end

    local tool = equipWateringCan()
    if not tool then return end

    for _, plant in ipairs(plants:GetChildren()) do
        if not Hub.running or not S.autoWater then break end
        local growth = plant:GetAttribute("Growth") or 0
        if growth < 1 then
            local targetCF = plant:GetPivot()
            reach(targetCF.Position + Vector3.new(0, 3, 0))
            task.wait(0.12)
            
            pcall(function() tool:Activate() end)
            
            local rayOrigin = targetCF.Position + Vector3.new(0, 15, 0)
            local rayDirection = Vector3.new(0, -30, 0)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = { LocalPlayer.Character, plant }
            local hit = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            local position = hit and hit.Position or targetCF.Position
            local waterPos = position - Vector3.new(0, 0.3, 0)
            
            local canType = tool:GetAttribute("WateringCan") or tool.Name
            fire(Net.WateringCan.UseWateringCan, waterPos, canType, tool)
            task.wait(0.15)
        end
    end
end

local RARITY_ORDER = {
    Common = 1, Uncommon = 2, Rare = 3,
    Epic = 4, Legendary = 5, Mythic = 6, Super = 7, Divine = 8
}

local function getRarity(petName)
    if PetData[petName] then return PetData[petName].Rarity or "Common" end
    local key = petName:gsub("%s+", "")
    if PetData[key] then return PetData[key].Rarity or "Common" end
    for k, v in pairs(PetData) do
        if string.lower(k) == string.lower(key) or string.lower(k) == string.lower(petName) then
            return v.Rarity or "Common"
        end
    end
    return "Common"
end

local function findPetMerchant()
    local npcs = workspace:FindFirstChild("NPCs") or workspace:FindFirstChild("NPCS")
    if npcs then
        local steven = npcs:FindFirstChild("Steven")
        if steven then return steven end
    end
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and string.find(string.lower(child.Name), "steven") then
            return child
        end
    end
    return nil
end

local function sellInventoryPets()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    if not bp then return end

    local minRarity = S.autoSellMinRarity or "Rare"
    local wantRank = RARITY_ORDER[minRarity] or 3

    local targets = {}
    local function scan(container)
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local petName = tool:GetAttribute("Pet")
                local petId = tool:GetAttribute("PetId")
                if petName and petId then
                    local rarity = getRarity(petName)
                    local gotRank = RARITY_ORDER[rarity] or 1
                    if gotRank < wantRank then
                        table.insert(targets, { tool = tool, name = petName, id = petId })
                    end
                end
            end
        end
    end

    scan(bp)
    if char then scan(char) end

    if #targets == 0 then return end

    local hrp = hrp()
    local oldCF = hrp and hrp.CFrame
    local npc = findPetMerchant()
    local anyTeleported = false

    if npc and hrp then
        local npcCF = npc:GetPivot()
        if npcCF then
            reach(npcCF.Position + Vector3.new(0, 3, 0))
            task.wait(0.35)
            anyTeleported = true
        end
    end

    for _, target in ipairs(targets) do
        if not Hub.running or not S.autoSellPets then break end
        
        if char and target.tool.Parent ~= char then
            pcall(function() target.tool.Parent = char end)
            task.wait(0.4)
        end

        local ok, result = fire(Net.NPCS.SellPet, target.id)
        if ok then
            pcall(function() target.tool:Destroy() end)
        end
        task.wait(0.3)
    end

    if anyTeleported and hrp and oldCF then
        reach(oldCF.Position)
    end
end

local FB, FM, FR = Enum.Font.GothamBold, Enum.Font.GothamMedium, Enum.Font.Gotham

local function guiParent()
    local p; pcall(function() p = gethui and gethui() end)
    if not p then pcall(function() p = game:GetService("CoreGui") end) end
    return p or LocalPlayer:WaitForChild("PlayerGui")
end
pcall(function() local old = guiParent():FindFirstChild("KysHub_Runtime") if old then old:Destroy() end end)

local ScreenGui = Instance.new("Folder")
ScreenGui.Name = "KysHub_Runtime"
ScreenGui.Parent = guiParent()

local ModernV2
local okModern, modernResult = pcall(require, "./src/Init")
ModernV2 = okModern and modernResult or nil
if not ModernV2 then
    -- Primary: Vercel mirror (no rate limit)
    local loaderOk, loaderResult = pcall(function()
        local source = game:HttpGet("https://raw.githubusercontent.com/Kys-lol/KysHubNewUI/refs/heads/main/ModernLua.txt")
        local fn, compileErr = loadstring(source)
        if not fn then error(compileErr) end
        return fn()
    end)
    if loaderOk then
        ModernV2 = loaderResult
    else
        warn("[KysHub] Vercel mirror failed, trying GitHub fallback:", loaderResult)
        -- Fallback: GitHub raw (may be rate-limited)
        local fallbackOk, fallbackResult = pcall(function()
            local source = game:HttpGet("https://raw.githubusercontent.com/Kys-lol/KysHubNewUI/refs/heads/main/MainV2.lua")
            local fn, compileErr = loadstring(source)
            if not fn then error(compileErr) end
            return fn()
        end)
        if fallbackOk then
            ModernV2 = fallbackResult
        else
            warn("[KysHub] Failed to load ModernV2 from all sources:", fallbackResult)
        end
    end
end

if ModernV2 then
    pcall(function()
        ModernV2:AddTheme({
            Name = "Lumi red",
            Accent = Color3.fromRGB(255, 0, 0),
            Outline = Color3.fromRGB(255, 0, 0),
            Text = Color3.fromRGB(255, 255, 255),
            PlaceholderText = Color3.fromRGB(200, 200, 200)
        })
    end)
end

local MenuIcon, Window
if ModernV2 and ModernV2.CreateMenuIcon then
    MenuIcon = ModernV2:CreateMenuIcon({
        Image = "rbxassetid://80891639562743",
        Size = 48,
        IconColor = Color3.fromRGB(255, 255, 255),
        BGColor = Color3.fromRGB(20, 22, 27),
        StrokeColor = Color3.fromRGB(255, 0, 0),
        StrokeThick = 1.5,
        Draggable = true,
    })
end

if ModernV2 then
    Window = ModernV2:Window({
        Title = "KysHub CRACK",
        Content = "Grow A Garden 2 v1.5",
        Uitransparent = 0.15,
        Size = UDim2.fromOffset(470, 300),
        Color = Color3.fromRGB(255, 0, 0),
        Image = "80891639562743",
        ShowUser = true,
        Search = true,
        ConfigEnabled = true,
        NotifyOnCallbackError = false,
        Loadingscreen = false,
        Enable3DRenderer = false,
        Keybind = "RightShift",
        Config = {
            ConfigFolder = "KysHubGrowAGarden2",
            AutoSaveFile = "KysHub_UI",
            AutoSave = true,
            AutoLoad = false,
            Overwrite = true,
            Format = "JSON",
            ShowAutoSaveToggle = true,
            TextGradient = true,
        }
    })
    if MenuIcon and Window.AttachMenuIcon then pcall(function() Window:AttachMenuIcon(MenuIcon) end) end
    pcall(function()
        Window:SetAccount({
            Username = LocalPlayer.DisplayName,
            Profile = ModernV2.UserProfile,
            Expires = "Cracked by @inlawry",
        })
    end)
    pcall(function()
        Window:CreateHomeTab({
            Name = "Dashboard",
            Icon = "lucide:layout-dashboard",
            Content = "KysHub crack - Grow A Garden 2 v1.5",
            DiscordInvite = "",
            SupportedExecutors = { "Delta", "Synapse X", "Krnl", "Codex", "Arceus X" },
            UnsupportedExecutors = { "Roblox Studio" },
            Segments = {
                Details = { Text = "Details", Icon = "lucide:grid-2x2" },
                Script = { Text = "Script Logs", Icon = "lucide:code" },
                UI = { Text = "UI Logs", Icon = "lucide:file-text", Show = true },
            },
            Changelog = {{
                Title = "Change-log V1.5",
                Date = "Latest",
                Description = "Added Auction Stand Sniper, Auto Merge Eclipse Blooms, and Auto Cast Weather Staff.",
            }},
            UIChangelog = {{ Title = "ModernV2 Framework", Date = "Latest", Description = "Using KysHub-style Lumi red UI" }},
        })
    end)
end

local StatusText = "ready"
local function setStatus(t)
    StatusText = tostring(t or "")
    print("[KysHub] " .. StatusText)
end

toast = function(title, msg, col)
    if Window and Window.Notify then
        pcall(function()
            Window:Notify({
                Title = tostring(title or "KysHub"),
                Content = tostring(msg or ""),
                Duration = 5,
                Color = col or C.accent,
            })
        end)
    end
end

--========================= MODERNV2 ADAPTER =======================--
local tabGroups = {}
local currentGroup = nil
local function addGroup(title)
    currentGroup = tostring(title or "Main")
    tabGroups[currentGroup] = tabGroups[currentGroup] or {}
end

local tabIconByName = {
    Farm = "lucide:leaf", Shop = "lucide:shopping-cart", Steal = "lucide:moon", Defense = "lucide:shield",
    Event = "lucide:sparkles", Timers = "lucide:timer", Items = "lucide:package", Pets = "lucide:paw-print",
    Mail = "lucide:mail", Stats = "lucide:activity", Teleport = "lucide:map-pin", Visual = "lucide:eye",
    Player = "lucide:user", Misc = "lucide:settings", Server = "lucide:globe",
}

local pages = {}
local function ensureSection(parent)
    if not parent then return nil end
    if parent._section then return parent._section end
    local tab = parent._tab or parent
    if tab and tab.AddSection then
        local ok, section = pcall(function()
            return tab:AddSection({
                Position = parent._position or "Center",
                Name = parent._sectionName or "General",
                Icon = parent._sectionIcon or "lucide:settings",
                Box = true,
                BoxBorder = true,
                Opened = true,
            })
        end)
        if ok and section then parent._section = section end
    end
    return parent._section or tab
end

local function addTab(name, icon)
    local tab
    if Window and Window.AddTab then
        local ok, created = pcall(function()
            return Window:AddTab({ Name = name, Icon = tabIconByName[name] or "lucide:circle", Type = "Single" })
        end)
        if ok then tab = created end
    end
    local page = { Name = name, Visible = true, Parent = { Visible = true }, _tab = tab, _group = currentGroup, _position = "Center" }
    pages[name] = page
    if currentGroup then table.insert(tabGroups[currentGroup], page) end
    return page
end

local function selectTab(_) end
local function column(page, _, _)
    return { Name = page.Name, Visible = true, Parent = { Visible = true }, _tab = page._tab, _group = page._group, _position = "Center" }
end
local function twoCol(page)
    return { Name = page.Name, Visible = true, Parent = { Visible = true }, _tab = page._tab, _group = page._group, _position = "Left" },
           { Name = page.Name, Visible = true, Parent = { Visible = true }, _tab = page._tab, _group = page._group, _position = "Right" }
end
local function oneCol(page) return column(page, 1, 0) end

local function setParagraphContent(paragraph, content)
    if not paragraph then return false end
    local methods = { "SetContent", "SetText", "SetDesc", "SetDescription", "Update" }
    for _, method in ipairs(methods) do
        if type(paragraph[method]) == "function" then
            local ok = pcall(function() paragraph[method](paragraph, content) end)
            if ok then return true end
        end
    end
    return false
end

local function colTitle(_, _) end
local function subTitle(parent, txt)
    if parent then
        parent._sectionName = tostring(txt or "General")
        parent._section = nil
        ensureSection(parent)
    end
    return parent
end
local function howItWorks(parent, text)
    local section = ensureSection(parent)
    if section and section.AddParagraph then
        pcall(function() section:AddParagraph({ Name = "Info", Content = tostring(text or "") }) end)
    elseif section and section.AddDivider then
        pcall(function() section:AddDivider({ Text = "Info" }) end)
    end
    return parent
end

local function modernCall(parent, method, cfg)
    local section = ensureSection(parent)
    if section and type(section[method]) == "function" then
        local ok, res = pcall(function() return section[method](section, cfg) end)
        if ok then return res end
    end
end

local function labelRow(parent, text, wrapped)
    local control = modernCall(parent, "AddLabel", {
        Text = tostring(text or "-"),
        Wrap = wrapped == true,
        AutomaticSize = wrapped == true,
    })
    if control and control.SetText then
        return control
    end
    return {
        _text = tostring(text or "-"),
        SetText = function(self, v) self._text = tostring(v or "") end,
        GetText = function(self) return self._text end,
    }
end

local function toggleRow(parent, name, desc, key, cb)
    modernCall(parent, "AddToggle", {
        Default = key and S[key] or false,
        Name = name,
        Flag = "KysHub_" .. tostring(key or name),
        Callback = function(v)
            if key then S[key] = v end
            if cb then pcall(cb, v) end
            saveSettings()
        end
    })
    if cb and key and S[key] then task.spawn(function() cb(true) end) end
end

local function sliderRow(parent, name, mn, mx, default, decimals, setFn)
    local inc = (decimals and decimals > 0) and (1 / (10 ^ decimals)) or 1
    modernCall(parent, "AddSlider", {
        Name = name,
        Flag = "KysHub_" .. name,
        Min = mn,
        Max = mx,
        Default = default,
        Value = default,
        Increment = inc,
        Rounding = decimals or 0,
        Callback = function(v)
            if setFn then setFn(v) end
            saveSettings()
        end
    })
end

local function actionRow(parent, name, desc, cb)
    modernCall(parent, "AddButton", {
        Name = name,
        Callback = function()
            if cb then task.spawn(cb) end
        end
    })
end

local function toggleRowPremium(parent, name, desc, key, cb)
    local isLocked = false
    modernCall(parent, "AddToggle", {
        Default = key and S[key] or false,
        Name = name,
        Flag = "KysHub_" .. tostring(key or name),
        Locked = isLocked,
        TextLocked = "Premium Required",
        Callback = function(v)
            if v and false then
                pcall(function() toast("Premium Required ✨", "Fitur ini hanya untuk pengguna Key Premium!") end)
                return
            end
            if key then S[key] = v end
            if cb then pcall(cb, v) end
            saveSettings()
        end
    })
    if cb and key and S[key] and not isLocked then
        task.spawn(function() cb(true) end)
    end
end

local function actionRowPremium(parent, name, desc, cb)
    local isLocked = false
    modernCall(parent, "AddButton", {
        Name = name,
        Locked = isLocked,
        TextLocked = "Premium Required",
        Callback = function()
            if false then
                pcall(function() toast("Premium Required ✨", "Fitur ini hanya untuk pengguna Key Premium!") end)
                return
            end
            if cb then task.spawn(cb) end
        end
    })
end

local function normalizeSelection(value)
    local out = {}
    if type(value) == "table" then
        for k, v in pairs(value) do
            if type(k) == "number" then out[tostring(v)] = true elseif v then out[tostring(k)] = true end
        end
    elseif value ~= nil then
        out[tostring(value)] = true
    end
    return out
end

local function selectedNames(selectedSet)
    local names = {}
    for k, v in pairs(selectedSet or {}) do if v then names[#names + 1] = tostring(k) end end
    table.sort(names)
    return names
end

local function dropdownRow(parent, name, desc, getOptions, selectedSet, getStockFn, maxSelectFn, priceFn)
    local optionNameByLabel, optionLabelByName = {}, {}
    local function makeLabel(nm)
        local label = tostring(nm)
        local extra = ""
        if getStockFn then local s = getStockFn(nm); if s and s > 0 then extra = extra .. " x" .. tostring(s) end end
        if priceFn then local p = priceFn(nm); if p and p ~= "" then extra = extra .. " " .. p end end
        return label .. extra
    end
    local function values()
        local out = {}
        optionNameByLabel, optionLabelByName = {}, {}
        for _, nm in ipairs(getOptions()) do
            local label = makeLabel(nm)
            optionNameByLabel[label] = nm
            optionLabelByName[tostring(nm)] = label
            out[#out + 1] = label
        end
        return out
    end
    local function selectedLabels()
        local out = {}
        for k, v in pairs(selectedSet or {}) do
            if v then
                local label = optionLabelByName[tostring(k)] or tostring(k)
                out[#out + 1] = label
            end
        end
        table.sort(out)
        return out
    end
    local function pruneSelection()
        local allowed, changed = {}, false
        for _, nm in ipairs(getOptions()) do allowed[tostring(nm)] = true end
        for k in pairs(selectedSet) do
            if not allowed[tostring(k)] then selectedSet[k] = nil; changed = true end
        end
        if changed then saveSettings() end
        return changed
    end
    local initialValues = values()
    pruneSelection()
    local control = modernCall(parent, "AddDropdown", {
        Name = name,
        Flag = "KysHub_" .. name,
        Values = initialValues,
        Default = selectedLabels(),
        Multi = true,
        Callback = function(v)
            table.clear(selectedSet)
            local picked = normalizeSelection(v)
            local allowed = {}
            for _, nm in ipairs(getOptions()) do allowed[tostring(nm)] = nm end
            local n = 0
            for raw in pairs(picked) do
                local rawText = tostring(raw)
                local original = optionNameByLabel[rawText]
                if original == nil then
                    local clean = rawText:gsub("%s+x%d+.*$", ""):gsub("%s+[%d%.]+[KMB]?\194\162.*$", "")
                    original = allowed[clean]
                end
                if original and ((not maxSelectFn) or n < maxSelectFn()) then selectedSet[original] = true; n = n + 1 end
            end
            saveSettings()
        end
    })
    local function syncDropdown()
        local newValues = values()
        pruneSelection()
        if control and control.SetValues then pcall(function() control:SetValues(newValues) end) end
        if control then
            if next(selectedSet) == nil then
                if control.Clear then pcall(function() control:Clear() end) end
            elseif control.SetValue then
                pcall(function() control:SetValue(selectedLabels()) end)
            end
        end
    end
    spawnLoop(4, syncDropdown)
    return {
        selectAll = function(v)
            for _, nm in ipairs(getOptions()) do selectedSet[nm] = v or nil end
            saveSettings()
            syncDropdown()
        end,
        clear = function()
            table.clear(selectedSet)
            saveSettings()
            if control and control.Clear then pcall(function() control:Clear() end) end
        end,
        sync = syncDropdown,
    }
end

local function inputRow(parent, name, desc, default, placeholder, onSet)
    modernCall(parent, "AddTextInput", {
        Name = name,
        Flag = "KysHub_" .. name,
        Default = default or "",
        Placeholder = placeholder or "",
        Callback = function(value)
            if onSet then onSet(tostring(value or "")) end
            saveSettings()
        end
    })
    return { Text = default or "" }
end

local function choiceRow(parent, name, desc, getOptions, getSel, onPick)
    local control = modernCall(parent, "AddDropdown", {
        Name = name,
        Flag = "KysHub_" .. name,
        Values = getOptions(),
        Default = getSel(),
        Multi = false,
        Callback = function(v)
            local picked = type(v) == "table" and (v[1] or next(v)) or v
            if picked ~= nil and onPick then onPick(tostring(picked)) end
            saveSettings()
        end
    })
    spawnLoop(3, function()
        if control and control.SetValues then pcall(function() control:SetValues(getOptions()) end) end
    end)
    return { refresh = function() end }
end

-- Compatibility shims for legacy dynamic label blocks that are no longer rendered manually.
local function corner(i, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 8) c.Parent = i return c end
local function stroke(i, col, t) local s = Instance.new("UIStroke") s.Color = col or C.stroke s.Thickness = t or 1 s.Parent = i return s end
local function padAll(i, l,r,t,b) local u = Instance.new("UIPadding") u.PaddingLeft = UDim.new(0,l) u.PaddingRight = UDim.new(0,r or l) u.PaddingTop = UDim.new(0,t or l) u.PaddingBottom = UDim.new(0,b or t or l) u.Parent = i return u end
local function vlist(i, p) local l = Instance.new("UIListLayout") l.Padding = UDim.new(0,p or 8) l.SortOrder = Enum.SortOrder.LayoutOrder l.Parent = i return l end
local function nextOrder(p) local n = (p:GetAttribute("_o") or 0) + 1 p:SetAttribute("_o", n) return n end
local function card(_, h)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,h or 1)
    f.BackgroundTransparency = 1
    f.Parent = ScreenGui
    return f
end

--========================== UNLOAD ================================--
function Hub.unload()
    if not Hub.running then return end
    saveSettings()
    Hub.running = false
    for _, c in ipairs(Hub.conns) do pcall(function() c:Disconnect() end) end
    Hub.conns = {}
    if Hub.stopFly then pcall(Hub.stopFly) end
    local h = humanoid(); if h then h.WalkSpeed = 16; h.UseJumpPower = true; h.JumpPower = 50; h.PlatformStand = false end
    local c = char(); if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide = true end) end end end
    for k, v in pairs(S) do if type(v) == "boolean" then S[k] = false end end
    pcall(function() if Window and Window.Destroy then Window:Destroy() end end)
    pcall(function() if MenuIcon and MenuIcon.Destroy then MenuIcon:Destroy() end end)
    pcall(function() ScreenGui:Destroy() end)
    print("[KysHub] unloaded.")
end
genv.KysHub_unload = Hub.unload
genv.KysHub_notify = function(msg, title, col) notify(msg, title, col) end

--========================== FEATURE LOOPS =========================--
-- The actual plantable soil is the CollectionService "PlantArea" parts (two ~44x50
-- columns, centred ~12 studs off the PlotSizeReference centre). Grid over those, not a
-- guessed rectangle, so planting covers the WHOLE garden. Patterns sub-select cells.
local PLANT_PATTERNS = { "Fill", "Checkerboard", "Rows", "Columns", "Diagonal", "Spaced" }
local function patternKeep(pat, gx, gz)
    if pat == "Checkerboard" then return (gx + gz) % 2 == 0
    elseif pat == "Rows" then return gz % 2 == 0
    elseif pat == "Columns" then return gx % 2 == 0
    elseif pat == "Diagonal" then return (gx - gz) % 3 == 0
    elseif pat == "Spaced" then return gx % 2 == 0 and gz % 2 == 0 end
    return true  -- Fill
end
local function plantAreas(plot)
    local areas = {}
    for _, p in ipairs(CollectionService:GetTagged("PlantArea")) do
        if p:IsA("BasePart") and p:IsDescendantOf(plot) and p.Size.X * p.Size.Z > 400 then areas[#areas + 1] = p end
    end
    if #areas == 0 then local ref = plot:FindFirstChild("PlotSizeReference"); if ref then areas = { ref } end end
    return areas
end
local function plantPositions(plot)
    local pat = S.plantPattern or "Fill"
    local step = 6
    local seen, list = {}, {}
    for _, area in ipairs(plantAreas(plot)) do
        local cf, sz = area.CFrame, area.Size
        local topY = area.Position.Y + sz.Y/2 + 0.3
        local hx, hz = sz.X/2 - 3, sz.Z/2 - 3
        local nx, nz = math.floor((2*hx)/step), math.floor((2*hz)/step)
        for ix = 0, nx do for iz = 0, nz do
            local w = (cf * CFrame.new(-hx + ix*step, 0, -hz + iz*step)).Position
            local gx, gz = math.floor(w.X/step + 0.5), math.floor(w.Z/step + 0.5)
            if patternKeep(pat, gx, gz) then
                local key = math.floor(w.X/4 + 0.5) .. "," .. math.floor(w.Z/4 + 0.5)
                if not seen[key] then seen[key] = true; list[#list + 1] = Vector3.new(w.X, topY, w.Z) end
            end
        end end
    end
    return list
end
local function freePlantPositions(plot)
    local grid = plantPositions(plot); local plants = plot:FindFirstChild("Plants"); local occ = {}
    if plants then for _, pl in ipairs(plants:GetChildren()) do local ok, pv = pcall(function() return pl:GetPivot().Position end) if ok then occ[#occ+1] = pv end end end
    local free = {}
    for _, pos in ipairs(grid) do
        local clear = true
        for _, o in ipairs(occ) do if (Vector3.new(o.X,0,o.Z) - Vector3.new(pos.X,0,pos.Z)).Magnitude < 6 then clear = false break end end
        if clear then free[#free+1] = pos end
    end
    return free
end

--======================= GARDEN SNAPSHOTS ========================--
-- Capture another player's garden (which seeds + how many, and its buildings) to a named
-- snapshot, then replant the same seeds/amounts (and optionally rebuild the layout) on yours.
local SNAP_FILE = "KysHub_GrowAGarden2_Snapshots.json"
local Snapshots = {}
local function saveSnapshots() if writefile then pcall(function() writefile(SNAP_FILE, HttpService:JSONEncode(Snapshots)) end) end end
do
    if readfile and isfile then
        local ok, raw = pcall(function() return isfile(SNAP_FILE) and readfile(SNAP_FILE) or nil end)
        if ok and raw then local g, d = pcall(function() return HttpService:JSONDecode(raw) end) if g and type(d) == "table" then Snapshots = d end end
    end
end
local function snapshotNames()
    local list = {} for n in pairs(Snapshots) do list[#list + 1] = n end table.sort(list); return list
end
-- the garden the player is standing in / nearest to
local function gardenNearPlayer()
    local g = Workspace:FindFirstChild("Gardens"); local r = hrp(); if not (g and r) then return nil end
    local best, bestD
    for _, plot in ipairs(g:GetChildren()) do
        local ref = plot:FindFirstChild("PlotSizeReference")
        if ref then local d = (Vector3.new(ref.Position.X,0,ref.Position.Z) - Vector3.new(r.Position.X,0,r.Position.Z)).Magnitude
            if not bestD or d < bestD then best, bestD = plot, d end end
    end
    return best
end
-- the building folders a plot can hold (placed props/sprinklers/pots/gnomes)
local BUILD_FOLDERS = { "Props", "Sprinklers", "Gnomes", "PottedPlants", "Pots", "Objects", "Decor" }
local function captureSnapshot(name)
    local plot = gardenNearPlayer(); if not plot then return false, "no garden nearby" end
    local ref = plot:FindFirstChild("PlotSizeReference"); local center = ref and ref.Position or Vector3.zero
    local snap = { seeds = {}, buildings = {}, owner = plot:GetAttribute("OwnerUserId") }
    -- plants -> seed counts
    local plants = plot:FindFirstChild("Plants")
    if plants then for _, pl in ipairs(plants:GetChildren()) do
        local s = pl:GetAttribute("SeedName") or pl:GetAttribute("CorePartName")
        if s then snap.seeds[s] = (snap.seeds[s] or 0) + 1 end
    end end
    -- buildings -> type + position relative to plot centre (best-effort; folders vary)
    for _, fname in ipairs(BUILD_FOLDERS) do
        local f = plot:FindFirstChild(fname)
        if f then for _, b in ipairs(f:GetChildren()) do
            local ok, piv = pcall(function() return b:GetPivot().Position end)
            if ok then
                local kind = b:GetAttribute("PropName") or b:GetAttribute("ItemName") or b:GetAttribute("Name") or b:GetAttribute("Type") or b.Name
                snap.buildings[#snap.buildings + 1] = { kind = tostring(kind), folder = fname,
                    rx = piv.X - center.X, ry = piv.Y - center.Y, rz = piv.Z - center.Z,
                    rot = (select(2, (b:GetPivot()):ToOrientation()) or 0) }
            end
        end end
    end
    Snapshots[name] = snap; saveSnapshots()
    local nSeeds = 0 for _ in pairs(snap.seeds) do nSeeds = nSeeds + 1 end
    return true, ("captured %d seed types, %d buildings"):format(nSeeds, #snap.buildings)
end

--====================== REMOVE / BUILD ===========================--
-- the shovel must be EQUIPPED and passed to UseShovel(plantId, fruitId, shovelAttr, shovelTool)
local function findShovel()
    local function scan(cont) if cont then for _, c in ipairs(cont:GetChildren()) do if c:IsA("Tool") and (c:GetAttribute("Shovel") ~= nil or c.Name:lower():find("shovel")) then return c end end end end
    return scan(char()) or scan(LocalPlayer:FindFirstChild("Backpack"))
end
local function equipShovel()
    local sh = findShovel(); if not sh then return nil end
    local h = humanoid()
    if h and sh.Parent ~= char() then pcall(function() h:EquipTool(sh) end); task.wait(0.3) end
    return sh
end
local function waitPlantGone(pl, timeout)
    local t0 = os.clock()
    while pl and pl.Parent and os.clock() - t0 < (timeout or 1.2) do task.wait(0.08) end
    return (not pl) or (not pl.Parent)
end
local function useShovelOnPlant(pl)
    if not (pl and pl.Parent) then return false end
    local pid = pl:GetAttribute("PlantId")
    if not pid then return false end
    local ok, pos = pcall(function() return pl:GetPivot().Position end)
    if ok then reach(pos); task.wait(0.12) end
    for _ = 1, 4 do
        if not (pl and pl.Parent) then return true end
        local sh = equipShovel()
        if not sh then return false end
        local sa = sh:GetAttribute("Shovel")
        pcall(function() sh:Activate() end)
        pcall(function() Net.Shovel.UseShovel:Fire(pid, "", sa, sh) end)
        if waitPlantGone(pl, 0.55) then return true end
        task.wait(0.18)
    end
    return not (pl and pl.Parent)
end
-- remove plants matching matchFn(cropName) (nil = remove everything)
local function removePlants(matchFn)
    local plot = myPlot(); if not plot then return 0 end
    local plants = plot:FindFirstChild("Plants"); if not plants then return 0 end
    local sh = equipShovel(); if not sh then setStatus("equip a shovel first"); return 0 end
    local targets, n = {}, 0
    for _, pl in ipairs(plants:GetChildren()) do
        local crop = pl:GetAttribute("SeedName") or pl:GetAttribute("CorePartName")
        if pl:GetAttribute("PlantId") and ((not matchFn) or matchFn(crop)) then
            targets[#targets + 1] = pl
        end
    end
    for i, pl in ipairs(targets) do
        if pl and pl.Parent then
            setStatus(("removing plants... %d/%d"):format(i, #targets))
            if useShovelOnPlant(pl) then n = n + 1 end
            task.wait(0.15)
        end
    end
    return n
end
local function removeAllPlants() return removePlants(nil) end
local function removeSelectedPlants() return removePlants(function(crop) return crop and S.removeCrops[crop] == true end) end
local function removeAllBuildings()
    local plot = myPlot(); if not plot then return 0 end
    local n = 0
    for _, fname in ipairs(BUILD_FOLDERS) do
        local f = plot:FindFirstChild(fname)
        if f then for _, b in ipairs(f:GetChildren()) do
            pcall(function()
                if Net.Prop and Net.Prop.PickupProp then Net.Prop.PickupProp:Fire(b) end
                if Net.PotPlacement and Net.PotPlacement.PickUpPottedPlant then Net.PotPlacement.PickUpPottedPlant:Fire(b) end
                if fname == "Gnomes" and Net.Place and Net.Place.RemoveGnome then Net.Place.RemoveGnome:Fire(b) end
            end)
            n = n + 1; task.wait(0.06)
        end end
    end
    return n
end

spawnLoop(1.5, function()
    if not S.autoWater then return end
    waterPlants()
end)

spawnLoop(3, function()
    if not S.autoSellPets then return end
    sellInventoryPets()
end)

spawnLoop(2, function()
    if not S.autoBuySeed then return end
    local it = seedStockItems(); if not it then return end
    local anySel = next(S.buySeeds) ~= nil  -- nothing picked = buy everything in stock
    for _, sv in ipairs(it:GetChildren()) do
        if sv:IsA("ValueBase") and sv.Value > 0 and ((not anySel) or S.buySeeds[sv.Name] == true) then
            if getSheckles() >= (SeedPrice[sv.Name] or 0) then fire(Net.SeedShop.PurchaseSeed, sv.Name); task.wait(0.08) end
        end
    end
end)

spawnLoop(0.6, function()
    if not S.autoPlant then return end
    task.wait(math.max(0, S.plantLoop - 0.6))
    if not S.autoPlant then return end
    local plot = myPlot(); if not plot then return end
    local d = getData(); local seeds = d and d.Inventory and d.Inventory.Seeds; if not seeds then return end
    local useFilter = next(S.plantSeeds) ~= nil
    local toPlant = {}
    local snap = (S.plantSource and S.plantSource ~= "My Seeds") and Snapshots[S.plantSource] or nil
    if snap then
        -- replant to match the snapshot's seed counts (capped by what you own)
        local have = {}
        local plf = plot:FindFirstChild("Plants")
        if plf then for _, pl in ipairs(plf:GetChildren()) do local s = pl:GetAttribute("SeedName") or pl:GetAttribute("CorePartName") if s then have[s] = (have[s] or 0) + 1 end end end
        for seed, target in pairs(snap.seeds) do
            local need = math.min((target or 0) - (have[seed] or 0), seeds[seed] or 0)
            for _ = 1, math.max(0, need) do toPlant[#toPlant + 1] = seed end
        end
    elseif S.smartReplant then
        local best = bestOwnedSeed()
        if best and ((not useFilter) or S.plantSeeds[best]) then
            local keep = S.plantReserve or 0
            for _ = 1, math.min(math.max(0, (seeds[best] or 0) - keep), 80) do toPlant[#toPlant + 1] = best end
        end
    else
        for name, count in pairs(seeds) do
            if (not useFilter) or S.plantSeeds[name] == true then
                local keep = S.plantReserve or 0
                for _ = 1, math.min(math.max(0, (count or 0) - keep), 40) do toPlant[#toPlant + 1] = name end
            end
        end
    end
    if #toPlant == 0 then return end
    local free = freePlantPositions(plot); if #free == 0 then return end
    local cap = math.min(#free, #toPlant, S.maxPerCycle); local planted = 0
    for i = 1, cap do
        fire(Net.Plant.PlantSeed, free[i], toPlant[i], plot); planted = planted + 1; task.wait(S.plantDelay)
    end
    if planted > 0 then setStatus("planted " .. planted) end
end)

-- auto-expand the garden (server gates on cost, so just fire when toggled)
spawnLoop(6, function()
    if not S.autoExpand then return end
    local plot = myPlot(); if not plot then return end
    local before = tonumber(plot:GetAttribute("GardenExpansion")) or 0
    fire(Net.Actions.ExpandGarden)
    task.wait(1)
    local after = tonumber(plot:GetAttribute("GardenExpansion")) or before
    if after > before then setStatus("garden expanded to size " .. after) end
end)

-- auto-build: recreate the selected snapshot's building layout on your plot (best-effort)
local function buildSnapshot()
    local snap = (S.plantSource and S.plantSource ~= "My Seeds") and Snapshots[S.plantSource] or nil
    if not (snap and snap.buildings and #snap.buildings > 0) then setStatus("pick a snapshot (with buildings) as the source") return 0 end
    local plot = myPlot(); if not plot then return 0 end
    local ref = plot:FindFirstChild("PlotSizeReference"); local center = ref and ref.Position or Vector3.zero
    local n = 0
    for _, b in ipairs(snap.buildings) do
        local pos = Vector3.new(center.X + (b.rx or 0), center.Y + (b.ry or 0), center.Z + (b.rz or 0))
        pcall(function() if Net.Prop and Net.Prop.PlaceProp then Net.Prop.PlaceProp:Fire(pos, b.kind, b.rot or 0, b.rot or 0) end end)
        n = n + 1; task.wait(0.15)
    end
    setStatus("auto-build: attempted " .. n .. " buildings")
    return n
end
spawnLoop(8, function()
    if not S.autoBuild then return end
    local snap = (S.plantSource and S.plantSource ~= "My Seeds") and Snapshots[S.plantSource] or nil
    if not (snap and snap.buildings and #snap.buildings > 0) then return end
    local plot = myPlot(); if not plot then return end
    local built = 0
    for _, fname in ipairs(BUILD_FOLDERS) do local f = plot:FindFirstChild(fname) if f then built = built + #f:GetChildren() end end
    if built < #snap.buildings then buildSnapshot() end
end)

spawnLoop(0.4, function()
    if not S.autoCollect then return end
    task.wait(math.max(0, S.harvestLoop - 0.4))
    if not S.autoCollect then return end
    local n = harvestAll(true)
    if n > 0 then setStatus("harvested " .. n) end
end)

spawnLoop(1, function()
    if S.sellOnFull then
        local fc = LocalPlayer:GetAttribute("FruitCount") or 0
        local mx = LocalPlayer:GetAttribute("MaxFruitCapacity") or 100
        if fc >= mx - 1 then fire(Net.NPCS.SellAll); setStatus("sold (backpack full)") end
    end
end)
-- spam-click sell: while on, fires SellAll back-to-back (like mashing the sell button)
-- instead of waiting for a timer; S.sellSpamDelay is the only pause between fires and
-- can be tuned live from the slider, since this loop reads it fresh every iteration.
task.spawn(function()
    while Hub.running do
        if S.autoSell then
            fire(Net.NPCS.SellAll)
            task.wait(math.max(0.05, tonumber(S.sellSpamDelay) or 0.15))
        else
            task.wait(0.25)
        end
    end
end)

spawnLoop(0.8, function()
    if not S.autoSteal then return end
    if not isNight() then setStatus("steal: waiting for night") return end
    local home = hrp() and hrp().Position
    local t = stealTargets(); local n = 0; local lastPos
    for _, e in ipairs(t) do
        if not S.autoSteal or not isNight() then break end
        local m = e.model; local pos = (m and m.Parent) and m:GetPivot().Position or nil
        local skip = (lastPos and pos and (pos - lastPos).Magnitude <= 12) or false  -- same plant cluster -> don't re-teleport
        if pos and not skip then lastPos = pos end
        stealModel(m, S.stealMult, skip); n = n + 1
        setStatus(string.format("steal: %d/%d  (worth %d)", n, #t, math.floor(e.value))); task.wait(0.03)
    end
    if n > 0 then setStatus(("stole %d fruit this pass"):format(n)) end
    if S.stealReturn and home then reach(home - Vector3.new(0,3,0)) end
end)

-- event seeds: gold/rainbow seeds + seed packs randomly spawn around the map; you walk
-- to them and HOLD E (a server-added ProximityPrompt) to collect. We TP over + fire it.
local function packKind(loc)
    if loc:GetAttribute("GoldSeed") == true then return "Gold Seed" end
    if loc:GetAttribute("RainbowSeed") == true then return "Rainbow Seed" end
    if loc:GetAttribute("SeedPack") ~= nil then return tostring(loc:GetAttribute("SeedPack")) end
    return nil
end
local function isRarePack(loc)
    if loc:GetAttribute("GoldSeed") == true or loc:GetAttribute("RainbowSeed") == true then return true end
    local sp = loc:GetAttribute("SeedPack")
    return type(sp) == "string" and (sp:lower():find("gold") ~= nil or sp:lower():find("rainbow") ~= nil)
end
local function firePrompt(d)
    pcall(function()
        local hold = tonumber(d.HoldDuration) or 0
        if fireproximityprompt then
            if hold > 0 then fireproximityprompt(d, hold) else fireproximityprompt(d) end
        else
            d:InputHoldBegin(); task.wait(hold + 0.1); d:InputHoldEnd()
        end
    end)
end
local function packLocations()
    local map = Workspace:FindFirstChild("Map"); local f = map and map:FindFirstChild("SeedPackSpawnServerLocations")
    return f and f:GetChildren() or {}
end
-- hold every collect-prompt on / near a spawned seed (server adds the hold-E prompt)
local function holdSeedPrompts(pos)
    local map = Workspace:FindFirstChild("Map")
    for _, cont in ipairs({ map and map:FindFirstChild("SeedPackSpawnServerLocations"), map and map:FindFirstChild("SeedPackSpawnClient"), Workspace:FindFirstChild("Temporary") }) do
        if cont then for _, d in ipairs(cont:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                local p = d.Parent; local ok, pp = pcall(function() return p.Position end)
                if (not ok) or (pp - pos).Magnitude <= 35 then firePrompt(d) end
            end
        end end
    end
end
local function locPart(loc) return loc:IsA("BasePart") and loc or loc:FindFirstChildWhichIsA("BasePart", true) end
local function locPos(loc)
    if loc:IsA("BasePart") then return loc.Position end
    local ok, cf = pcall(function() return loc:GetPivot() end); if ok then return cf.Position end
    local bp = locPart(loc); return bp and bp.Position or nil
end
-- stand on the seed and collect it: fire its hold-E prompt, any nearby prompt, AND touch it
local function grabPack(loc)
    local landed = false
    for _ = 1, 90 do
        if not (loc and loc.Parent) then break end
        local pos = locPos(loc); if not pos then break end
        local r = hrp()
        if (not landed) or (r and (r.Position - pos).Magnitude > 6) then reach(pos); landed = true end
        for _, d in ipairs(loc:GetDescendants()) do if d:IsA("ProximityPrompt") then firePrompt(d) end end  -- prompt on the seed itself
        holdSeedPrompts(pos)                                                                                   -- + any prompt nearby (client visual)
        local part = locPart(loc)
        if firetouchinterest and part and hrp() then pcall(function() firetouchinterest(hrp(), part, 0); firetouchinterest(hrp(), part, 1) end) end  -- touch-to-collect fallback
        task.wait(0.12)
    end
end
do
    local grabbing = {}
    spawnLoop(0.6, function()
        if not S.autoGrabPacks then return end
        for _, loc in ipairs(packLocations()) do
            if loc.Parent and not grabbing[loc] then
                local rare = isRarePack(loc)
                if S.notifyRare and rare then local k = packKind(loc) or "Rare seed"; setStatus("EVENT: " .. k .. " spawned!"); notify(k .. " spawned on the map - grabbing it now!", "✦ Rare Seed Spawned", C.accent) end
                if (not S.grabRareOnly) or rare then
                    grabbing[loc] = true
                    task.spawn(function() grabPack(loc); grabbing[loc] = nil end)
                end
            end
        end
    end)
end
do
    local wasNight = false
    spawnLoop(1, function()
        local n = isNight()
        if S.packReturn and S.autoGrabPacks and wasNight and not n then
            local plot = myPlot(); local sp = plot and plot:FindFirstChild("SpawnPoint")
            if sp then reach(sp.Position); setStatus("event over - returned to garden") end
        end
        wasNight = n
    end)
end

do
    local wasNight = false
    spawnLoop(0.5, function()
        local n = isNight()
        if S.panicHarvest and n and not wasNight then
            setStatus("defense: panic harvesting")
            harvestAll(false)
        end
        wasNight = n
    end)
end
spawnLoop(0.6, function()
    if not S.retaliate then return end
    local plot = myPlot(); local ref = plot and plot:FindFirstChild("PlotSizeReference"); if not ref then return end
    local center, size = ref.Position, ref.Size
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local r = pl.Character:FindFirstChild("HumanoidRootPart")
            if r and math.abs(r.Position.X - center.X) < size.X/2 + 4 and math.abs(r.Position.Z - center.Z) < size.Z/2 + 4 then fire(Net.Shovel.HitPlayer, pl.UserId) end
        end
    end
end)

spawnLoop(3, function()
    if not S.autoBuyCrate then return end
    local it = stockItems("CrateShop"); if not it then return end
    for _, sv in ipairs(it:GetChildren()) do if sv:IsA("ValueBase") and sv.Value > 0 then fire(Net.CrateShop.PurchaseCrate, sv.Name); task.wait(0.1) end end
end)
spawnLoop(3, function()
    if not S.autoBuyGear then return end
    local it = gearStockItems(); if not it then return end
    local anySel = next(S.buyGears) ~= nil
    for _, sv in ipairs(it:GetChildren()) do
        if sv:IsA("ValueBase") and sv.Value > 0 and ((not anySel) or S.buyGears[sv.Name] == true) then fire(Net.GearShop.PurchaseGear, sv.Name); task.wait(0.1) end
    end
end)

local function openAll(invKey, pkt, flag)
    spawnLoop(2.5, function()
        if not S[flag] then return end
        local d = getData(); local bag = d and d.Inventory and d.Inventory[invKey]; if not bag then return end
        for name, count in pairs(bag) do local n = (type(count) == "number") and count or 1 for _ = 1, n do task.spawn(function() fire(pkt, name) end) task.wait(0.15) end end
    end)
end
openAll("Eggs", Net.Egg.OpenEgg, "autoEggs")
openAll("Crates", Net.Crate.OpenCrate, "autoCrates")
openAll("SeedPacks", Net.SeedPack.OpenSeedPack, "autoPacks")

spawnLoop(1.2, function()
    if not S.autoTame then return end
    local map = Workspace:FindFirstChild("Map"); local refs = map and map:FindFirstChild("WildPetRef"); if not refs then return end
    local anySel = next(S.tameAnimals) ~= nil
    for _, pet in ipairs(refs:GetChildren()) do
        if not S.autoTame then break end
        local owner = tonumber(pet:GetAttribute("OwnerUserId")) or 0
        local species = pet:GetAttribute("PetName")
        if ((not anySel) or (species and S.tameAnimals[species] == true)) and (owner == 0 or owner == LocalPlayer.UserId) and pet:IsA("BasePart") then
            reach(pet.Position); setStatus("taming " .. tostring(species))
            for _ = 1, 6 do if not S.autoTame then break end pcall(function() Net.Pets.WildPetTame:Fire(pet) end) task.wait(0.08) end
        end
    end
end)
-- AUTO PROGRESS: hands-off progression. Harvest -> sell -> buy the best seeds you can
-- afford -> plant them everywhere -> tame valuable pets when they spawn. Snowballs coins.
local GOOD_PETS = {
    Raccoon = true, Dragonfly = true, ["Dragon Fly"] = true, Dragonling = true, Mimic = true,
    ["Disco Bee"] = true, ["Queen Bee"] = true, Kitsune = true, ["Red Fox"] = true, Fox = true,
    Owl = true, ["Night Owl"] = true, Bear = true, ["Polar Bear"] = true, Butterfly = true,
    ["Golden Lab"] = true, Cat = true, ["Red Giant Ant"] = true, Snail = true,
    Firefly = true, GoldenDragonfly = true, ["Golden Dragonfly"] = true, BaldEagle = true, ["Bald Eagle"] = true,
}
local function progressBuy()
    local it = seedStockItems(); if not it then return end
    local money = getSheckles(); local best, bestV
    for _, sv in ipairs(it:GetChildren()) do
        if sv:IsA("ValueBase") and sv.Value > 0 then
            local price, val = SeedPrice[sv.Name] or math.huge, SeedBaseValue[sv.Name] or 0
            if price <= money * 0.5 and (not bestV or val > bestV) then best, bestV = sv.Name, val end
        end
    end
    if best then for _ = 1, 6 do if getSheckles() < (SeedPrice[best] or 0) then break end fire(Net.SeedShop.PurchaseSeed, best); task.wait(0.1) end end
    return best
end
local function progressPlant()
    local plot = myPlot(); if not plot then return 0 end
    local d = getData(); local seeds = d and d.Inventory and d.Inventory.Seeds; if not seeds then return 0 end
    local toPlant = {}
    for name, count in pairs(seeds) do for _ = 1, math.min(count or 0, 30) do toPlant[#toPlant + 1] = name end end
    if #toPlant == 0 then return 0 end
    local free = freePlantPositions(plot); local cap = math.min(#free, #toPlant); local n = 0
    for i = 1, cap do fire(Net.Plant.PlantSeed, free[i], toPlant[i], plot); n = n + 1; task.wait(0.08) end
    return n
end
spawnLoop(4, function()
    if not S.autoProgress then return end
    local h = harvestAll(false)
    if (LocalPlayer:GetAttribute("FruitCount") or 0) > 0 then fire(Net.NPCS.SellAll); task.wait(0.2) end
    progressBuy()
    local p = progressPlant()
    setStatus(("auto progress: +%d harvest, +%d plant, %s"):format(h, p, money(getSheckles())))
end)
spawnLoop(1.5, function()
    if not S.autoProgress then return end
    local map = Workspace:FindFirstChild("Map"); local refs = map and map:FindFirstChild("WildPetRef"); if not refs then return end
    for _, pet in ipairs(refs:GetChildren()) do
        if not S.autoProgress then break end
        local species = pet:GetAttribute("PetName"); local owner = tonumber(pet:GetAttribute("OwnerUserId")) or 0
        if species and GOOD_PETS[species] and (owner == 0 or owner == LocalPlayer.UserId) and pet:IsA("BasePart") then
            reach(pet.Position); setStatus("auto progress: taming " .. species)
            for _ = 1, 6 do if not S.autoProgress then break end pcall(function() Net.Pets.WildPetTame:Fire(pet) end) task.wait(0.08) end
        end
    end
end)
spawnLoop(5, function()
    if not S.autoEquipPets then return end
    local n, mx = 0, maxEquip()
    for name in pairs(S.equipPets) do if n >= mx then break end fire(Net.Pets.RequestEquipByName, tostring(name)); n = n + 1; task.wait(0.15) end
end)

-- fly + movement
local flyBV, flyBG
local function stopFly()
    if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
    local h = humanoid(); if h then h.PlatformStand = false end
end
Hub.stopFly = stopFly
local function startFly()
    local r = hrp(); if not r then return end
    stopFly()
    flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(1,1,1)*9e9; flyBV.Velocity = Vector3.zero; flyBV.Parent = r
    flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.new(1,1,1)*9e9; flyBG.P = 1e5; flyBG.CFrame = r.CFrame; flyBG.Parent = r
end
track(RunService.Heartbeat:Connect(function()
    if not Hub.running then return end
    local h = humanoid()
    if h then
        if S.walkSpeed ~= 16 then h.WalkSpeed = S.walkSpeed end
        if S.jumpPower ~= 50 then h.UseJumpPower = true; h.JumpPower = S.jumpPower end
    end
    if S.noclip then local c = char() if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end end end
    if S.fly then
        local r = hrp(); local cam = Workspace.CurrentCamera
        if r and cam then
            if not flyBV then startFly() end
            if h then h.PlatformStand = true end
            local d = Vector3.zero
            local function k(c) return UserInputService:IsKeyDown(c) end
            if k(Enum.KeyCode.W) then d = d + cam.CFrame.LookVector end
            if k(Enum.KeyCode.S) then d = d - cam.CFrame.LookVector end
            if k(Enum.KeyCode.D) then d = d + cam.CFrame.RightVector end
            if k(Enum.KeyCode.A) then d = d - cam.CFrame.RightVector end
            if k(Enum.KeyCode.Space) then d = d + Vector3.new(0,1,0) end
            if k(Enum.KeyCode.LeftControl) then d = d - Vector3.new(0,1,0) end
            if flyBV then flyBV.Velocity = (d.Magnitude > 0 and d.Unit or Vector3.zero) * S.flySpeed end
            if flyBG then flyBG.CFrame = cam.CFrame end
        end
    elseif flyBV then stopFly() end
end))
track(UserInputService.JumpRequest:Connect(function() if S.infJump then local h = humanoid() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end))

-- anti-afk: VirtualUser click on the Idled signal (fires just before the 20-min
-- idle kick). Non-disruptive - only acts when you are actually idle.
do
    local VU = game:GetService("VirtualUser")
    track(LocalPlayer.Idled:Connect(function()
        if not S.antiAfk then return end
        pcall(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end))
end

-- webhook + server hopper
local HttpService = game:GetService("HttpService")
local TPS = game:GetService("TeleportService")
local httpRequest = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or (typeof(request) == "function" and request) or http_request
local function sendWebhook(content)
    if not (S.webhookUrl and S.webhookUrl ~= "" and httpRequest) then return false end
    task.spawn(function()
        pcall(function()
            httpRequest({ Url = S.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({ username = "KysHub", content = content }) })
        end)
    end)
    return true
end
local function fetchServers()
    local ok, res = pcall(function()
        local raw = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        return HttpService:JSONDecode(raw)
    end)
    return (ok and res and res.data) or {}
end
local function serverHop(lowPop)
    setStatus("finding a server...")
    local servers = fetchServers(); local pick
    for _, s in ipairs(servers) do
        if s.id ~= game.JobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers then
            if lowPop then if not pick or s.playing < pick.playing then pick = s end
            else pick = s; break end
        end
    end
    if pick then setStatus("hopping (" .. pick.playing .. " players)..."); pcall(function() TPS:TeleportToPlaceInstance(game.PlaceId, pick.id, LocalPlayer) end)
    else setStatus("no server found - retrying may help") end
end
local function rareSeedInStock()
    local it = seedStockItems(); if not it then return false end
    for _, sv in ipairs(it:GetChildren()) do if sv:IsA("ValueBase") and sv.Value > 0 and (SeedPrice[sv.Name] or 0) >= 5000 then return true, sv.Name end end
    return false
end
-- hop between servers until a rare seed is in stock
spawnLoop(20, function()
    if not S.autoHopRare then return end
    if not rareSeedInStock() then serverHop(false) end
end)

-- profit tracker (net sheckles, rolling 60s rate)
local Profit = { startS = nil, session = 0, perMin = 0, perHr = 0, win = {} }
spawnLoop(2, function()
    local s = getSheckles()
    if Profit.startS == nil then Profit.startS = s end
    Profit.session = s - Profit.startS
    table.insert(Profit.win, { t = os.clock(), s = s })
    while #Profit.win > 1 and (os.clock() - Profit.win[1].t) > 60 do table.remove(Profit.win, 1) end
    local f = Profit.win[1]; local dt = os.clock() - f.t
    if dt > 4 then Profit.perMin = (s - f.s)/dt*60; Profit.perHr = Profit.perMin*60 end
end)

-- highlight ESP (own ready crops + mutated fruit, distance-capped)
local hlFolder = Instance.new("Folder"); hlFolder.Name = "KysHub_HL"; hlFolder.Parent = ScreenGui
local function clearHL() for _, h in ipairs(hlFolder:GetChildren()) do h:Destroy() end end
local function addHL(model, col)
    if not model or not model.Parent then return end
    local h = Instance.new("Highlight"); h.Adornee = model; h.FillColor = col; h.FillTransparency = 0.55
    h.OutlineColor = col; h.OutlineTransparency = 0; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.Parent = hlFolder
end
spawnLoop(1, function()
    if not (S.highlightReady or S.highlightRare) then if #hlFolder:GetChildren() > 0 then clearHL() end return end
    clearHL()
    local root = hrp(); local rp = root and root.Position
    if S.highlightReady then for _, m in ipairs(ownHarvestTargets()) do addHL(m, C.accent) end end
    if S.highlightRare and rp then
        local count = 0
        for _, p in ipairs(CollectionService:GetTagged("StealPrompt")) do
            if count >= 50 then break end
            local m = p.Parent and p.Parent:FindFirstAncestorWhichIsA("Model")
            if m and m:GetAttribute("Mutation") then
                local ok, piv = pcall(function() return m:GetPivot().Position end)
                if ok and (piv - rp).Magnitude < 220 then addHL(m, Color3.fromRGB(255,205,70)); count = count + 1 end
            end
        end
    end
end)
table.insert(Hub.conns, { Disconnect = function() pcall(clearHL) pcall(function() hlFolder:Destroy() end) end })

-- rare seed restock notifier (fires once when an expensive seed appears in stock)
do
    local prev = {}
    spawnLoop(3, function()
        if not S.rareNotify then return end
        local it = seedStockItems(); if not it then return end
        for _, sv in ipairs(it:GetChildren()) do
            if sv:IsA("ValueBase") then
                local now = sv.Value > 0
                if now and not prev[sv.Name] and (SeedPrice[sv.Name] or 0) >= 5000 then
                    setStatus("RARE SEED IN STOCK: " .. sv.Name); notify(sv.Name .. " just restocked - " .. sv.Value .. "x available (" .. fmtPrice(SeedPrice[sv.Name]) .. ")", "✦ Rare Seed In Stock", C.green)
                    if S.whRareSeed then sendWebhook("**Rare seed in stock:** " .. sv.Name .. " (" .. sv.Value .. "x)  -  " .. LocalPlayer.Name) end
                end
                prev[sv.Name] = now
            end
        end
    end)
end

-- performance optimizer: flat textures, grey sky, no effects (FPS boost)
local Lighting = game:GetService("Lighting")
local optConns, optOrig
local function optimizeInstance(o)
    pcall(function()
        if o:IsA("BasePart") then
            o.Material = Enum.Material.SmoothPlastic; o.Reflectance = 0; o.CastShadow = false
        elseif o:IsA("Decal") or o:IsA("Texture") then
            o.Transparency = 1
        elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") then
            o.Enabled = false
        elseif o:IsA("PostEffect") then
            o.Enabled = false
        end
    end)
end
local function setOptimize(on)
    if on then
        optOrig = optOrig or { gs = Lighting.GlobalShadows, fc = Lighting.FogColor, fs = Lighting.FogStart, fe = Lighting.FogEnd, br = Lighting.Brightness, oa = Lighting.OutdoorAmbient, am = Lighting.Ambient }
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogColor = Color3.fromRGB(131,133,139); Lighting.FogStart = 220; Lighting.FogEnd = 780  -- grey sky via fog
            Lighting.OutdoorAmbient = Color3.fromRGB(140,140,146); Lighting.Ambient = Color3.fromRGB(122,122,128)  -- neutralise colour tint
        end)
        for _, e in ipairs(Lighting:GetDescendants()) do
            if e:IsA("Atmosphere") or e:IsA("Clouds") or e:IsA("PostEffect") then pcall(function() e.Enabled = false end) end
            if e:IsA("Sky") then pcall(function() e.CelestialBodiesShown = false end) end
        end
        pcall(function() Workspace.Terrain.Decoration = false end)
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        for _, o in ipairs(Workspace:GetDescendants()) do optimizeInstance(o) end
        -- keep optimizing ANYTHING that streams in later (new plants, players, effects, etc.)
        if optConns then for _, c in ipairs(optConns) do pcall(function() c:Disconnect() end) end end
        local function onAdd(o) if S.optimize then task.defer(optimizeInstance, o) end end
        optConns = { Workspace.DescendantAdded:Connect(onAdd), Lighting.DescendantAdded:Connect(onAdd) }
        for _, c in ipairs(optConns) do track(c) end
        setStatus("optimized - flat textures, grey sky, effects off")
    else
        if optConns then for _, c in ipairs(optConns) do pcall(function() c:Disconnect() end) end optConns = nil end
        if optOrig then pcall(function()
            Lighting.GlobalShadows = optOrig.gs; Lighting.FogColor = optOrig.fc; Lighting.FogStart = optOrig.fs; Lighting.FogEnd = optOrig.fe; Lighting.Brightness = optOrig.br
            Lighting.OutdoorAmbient = optOrig.oa; Lighting.Ambient = optOrig.am
        end) end
        for _, e in ipairs(Lighting:GetDescendants()) do
            if e:IsA("Atmosphere") or e:IsA("Clouds") or e:IsA("PostEffect") then pcall(function() e.Enabled = true end) end
            if e:IsA("Sky") then pcall(function() e.CelestialBodiesShown = true end) end
        end
        pcall(function() Workspace.Terrain.Decoration = true end)
        for _, o in ipairs(Workspace:GetDescendants()) do
            if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") then pcall(function() o.Enabled = true end)
            elseif o:IsA("Decal") or o:IsA("Texture") then pcall(function() o.Transparency = 0 end) end
        end
        setStatus("optimizer off (rejoin to restore textures fully)")
    end
end

--========================== MAIL SYSTEM ==========================--
-- Discovery: walk ReplicatedStorage looking for the mailbox RemoteEvent.
-- GAG2 uses Net (SharedModules.Networking), so check its Mailbox sub-table first,
-- then fall back to a name-search so it keeps working across game updates.
local MailNet = nil
pcall(function()
    if Net.Mailbox then MailNet = Net.Mailbox
    elseif Net.Mail   then MailNet = Net.Mail end
end)
local function discoverMailRemote(name)
    local function search(parent, depth)
        if depth > 4 then return nil end
        for _, child in ipairs(parent:GetChildren()) do
            local n = child.Name:lower()
            if n:find(name) then
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then return child end
            end
            local found = search(child, depth + 1)
            if found then return found end
        end
        return nil
    end
    return search(ReplicatedStorage, 0)
end

local function getMailInventory()
    -- Returns { [itemName] = count } for the selected item type
    local d = getData(); if not d or not d.Inventory then return {} end
    local key = S.mailItemType  -- "Seeds", "Gears", "Eggs", "Crates", etc.
    local bag = d.Inventory[key]
    if type(bag) ~= "table" then return {} end
    return bag
end

local function getMailItemOptions()
    local list = {}
    for name, count in pairs(getMailInventory()) do
        if (count or 0) > 0 then list[#list + 1] = name end
    end
    table.sort(list); return list
end

-- Core send function; tries every plausible remote path.
local function sendMail(recipient, itemType, itemName, count, note)
    if not recipient or recipient == "" then return false, "no recipient" end
    if not itemName  or itemName  == "" then return false, "no item"      end
    count = math.max(1, math.floor(tonumber(count) or 1))
    note  = tostring(note or "")

    -- Attempt 1 – via Net.Mailbox table (most common in GAG2)
    local tried = false
    pcall(function()
        if MailNet then
            for _, evName in ipairs({"SendItem","Send","SendMail","MailItem","PostItem","SendGift"}) do
                local ev = MailNet[evName]
                if ev and (ev.Fire or ev.InvokeServer) then
                    if ev.Fire then ev:Fire(recipient, itemType, itemName, count, note)
                    else ev:InvokeServer(recipient, itemType, itemName, count, note) end
                    tried = true; return
                end
            end
        end
    end)
    if tried then return true end

    -- Attempt 2 – discover by name in ReplicatedStorage
    local rem = discoverMailRemote("mail") or discoverMailRemote("send")
    if rem then
        pcall(function()
            if rem.Fire then rem:Fire(recipient, itemType, itemName, count, note)
            elseif rem.InvokeServer then rem:InvokeServer(recipient, itemType, itemName, count, note) end
        end)
        return true
    end

    -- Attempt 3 – try to call MailboxController's Send function directly
    pcall(function()
        local mc = LocalPlayer.PlayerScripts:FindFirstChild("Controllers", true)
        if mc then
            local ctrl = mc:FindFirstChild("MailboxController")
            if ctrl then
                -- Look for a BindableFunction that exposes Send
                for _, child in ipairs(ctrl:GetChildren()) do
                    if child:IsA("BindableFunction") and child.Name:lower():find("send") then
                        pcall(function() child:Invoke(recipient, itemType, itemName, count, note) end)
                    end
                end
            end
        end
    end)

    return false, "could not find mailbox remote – update the script if the game changed"
end

-- Auto-mail loop
local mailAcc = 0
spawnLoop(1, function()
    if not S.autoMail then return end
    mailAcc = mailAcc + 1
    if mailAcc < S.mailInterval then return end
    mailAcc = 0
    if S.mailRecipient == "" then setStatus("mail: set a recipient first"); return end
    if S.mailSendAll then
        -- Send every item of the chosen type
        local inv = getMailInventory(); local sent = 0
        for name, count in pairs(inv) do
            if (count or 0) > 0 then
                local ok = sendMail(S.mailRecipient, S.mailItemType, name, count, S.mailNote)
                if ok then sent = sent + 1 end
                task.wait(0.3)
            end
        end
        setStatus(("mail: sent %d stacks → %s"):format(sent, S.mailRecipient))
    else
        if S.mailItemName == "" then setStatus("mail: pick an item"); return end
        local inv = getMailInventory()
        local have = (inv[S.mailItemName] or 0)
        if have <= 0 then setStatus("mail: out of " .. S.mailItemName); return end
        local cnt = math.min(S.mailCount, have)
        local ok, err = sendMail(S.mailRecipient, S.mailItemType, S.mailItemName, cnt, S.mailNote)
        if ok then
            setStatus(("mail: sent %dx %s → %s"):format(cnt, S.mailItemName, S.mailRecipient))
        else
            setStatus("mail: " .. tostring(err)); S.autoMail = false
        end
    end
end)

-- Auto-mail loop (v1.5 SendBatch Optimized)
do
    local mailAcc = 0
    spawnLoop(1, function()
        if not S.autoMail then return end
        mailAcc = mailAcc + 1
        if mailAcc < S.mailInterval then return end
        mailAcc = 0
        if S.mailRecipient == "" then setStatus("mail: set a recipient first"); return end
        
        local ok, uid = pcall(function() return Net.Mailbox.LookupPlayer:Fire(S.mailRecipient) end)
        if not ok or not uid or uid <= 0 then
            setStatus("mail: username resolve failed")
            return
        end
        
        if S.mailSendAll then
            local inv = getMailInventory(); local items = {}
            for name, count in pairs(inv) do
                if (count or 0) > 0 then
                    table.insert(items, {
                        Category = S.mailItemType,
                        ItemKey = name,
                        Count = count
                    })
                end
            end
            if #items > 0 then
                local okBatch, success = pcall(function() return Net.Mailbox.SendBatch:Fire(uid, items, S.mailNote) end)
                if okBatch and success then
                    setStatus(("mail: sent %d stacks → %s"):format(#items, S.mailRecipient))
                else
                    setStatus("mail: batch send failed")
                end
            end
        else
            if S.mailItemName == "" then setStatus("mail: pick an item"); return end
            local inv = getMailInventory()
            local have = (inv[S.mailItemName] or 0)
            if have <= 0 then setStatus("mail: out of " .. S.mailItemName); return end
            local cnt = math.min(S.mailCount, have)
            
            local items = {
                {
                    Category = S.mailItemType,
                    ItemKey = S.mailItemName,
                    Count = cnt
                }
            }
            local okBatch, success = pcall(function() return Net.Mailbox.SendBatch:Fire(uid, items, S.mailNote) end)
            if okBatch and success then
                setStatus(("mail: sent %dx %s → %s"):format(cnt, S.mailItemName, S.mailRecipient))
            else
                setStatus("mail: send failed"); S.autoMail = false
            end
        end
    end)
end

-- Auto Claim Mailbox Loop
spawnLoop(5, function()
    if not S.autoClaimMail then return end
    if not getgenv().KysHubTier or false then return end
    
    local ok, inbox = pcall(function() return Net.Mailbox.OpenInbox:Fire() end)
    if ok and type(inbox) == "table" then
        for id, mail in pairs(inbox) do
            if type(mail) == "table" then
                local claimOk = pcall(function() return Net.Mailbox.Claim:Fire(id) end)
                if claimOk then
                    setStatus("claimed mail: " .. tostring(mail.From or id))
                    task.wait(0.2)
                end
            end
        end
    end
end)

--========================== V1.5 AUTOMATION LOOPS ====================--
--========================== V1.5 AUTOMATION LOOPS ====================--
do
    local AuctionLots = {}
    local AuctionStock = {}

    local function updateLotsFromSnapshot(snapshot)
        if type(snapshot) == "table" and snapshot.manifest and type(snapshot.manifest.lots) == "table" then
            AuctionLots = snapshot.manifest.lots
            AuctionStock = snapshot.stock or {}
        end
    end

    pcall(function()
        if Net and Net.Auctioneer then
            Net.Auctioneer.Snapshot.OnClientEvent:Connect(function(snapshot)
                updateLotsFromSnapshot(snapshot)
            end)
            Net.Auctioneer.StockUpdate.OnClientEvent:Connect(function(stockData)
                if type(stockData) == "table" and type(stockData.stock) == "table" then
                    AuctionStock = stockData.stock
                end
            end)
        end
    end)

    task.spawn(function()
        task.wait(2)
        pcall(function()
            if Net and Net.Auctioneer then
                local ok, snapshot = pcall(function() return Net.Auctioneer.RequestSnapshot:Fire() end)
                if ok and snapshot then
                    updateLotsFromSnapshot(snapshot)
                end
            end
        end)
    end)

    local function getServerTimeNow()
        local ok, t = pcall(function() return workspace:GetServerTimeNow() end)
        return ok and t or os.time()
    end

    local function getLotPrice(lot)
        if not lot then return math.huge end
        if not lot.decrementIntervalSeconds or lot.decrementIntervalSeconds <= 0 then
            return lot.startPrice or 0
        end
        local elapsed = getServerTimeNow() - (lot.rolledAt or 0)
        local intervals = math.floor((elapsed < 0 and 0 or elapsed) / lot.decrementIntervalSeconds)
        local decAmount = math.round((lot.startPrice or 0) * (lot.decrementPercent or 0) / 100)
        local price = (lot.startPrice or 0) - decAmount * intervals
        if price < (lot.minPrice or 0) then
            price = lot.minPrice or 0
        end
        return price
    end

    local function isLotActive(lot)
        if not lot then return false end
        if (lot.expiresAt or 0) <= getServerTimeNow() then return false end
        local stock = AuctionStock[lot.lotId]
        if lot.stockQuantity ~= nil and stock ~= nil and stock <= 0 then
            return false
        end
        return true
    end

    local function lotMatchesFilter(lot)
        if not lot then return false end
        local categories = S.buyAuctionTypes or {}
        if next(categories) == nil then
            return true
        end
        return categories[lot.category] == true
    end

    local function findAuctionStand()
        local stand = Workspace:FindFirstChild("AuctionStand")
        if stand then return stand end
        for _, child in ipairs(Workspace:GetChildren()) do
            if child.Name == "AuctionStand" or string.find(string.lower(child.Name), "auction") then
                return child
            end
        end
        return nil
    end

    local isSniping = false
    local function autoSnipeAuctionLogic()
        if not S.autoBuyAuction or isSniping then return end
        if not getgenv().KysHubTier or false then return end
        
        local stand = findAuctionStand()
        if not stand then return end
        
        for _, lot in ipairs(AuctionLots) do
            if isLotActive(lot) and lotMatchesFilter(lot) then
                local price = getLotPrice(lot)
                if getSheckles() >= price then
                    local shouldBuy = false
                    if S.auctionSnipeMode == "Instant" then
                        if S.auctionMaxPrice <= 0 or price <= S.auctionMaxPrice then
                            shouldBuy = true
                        end
                    elseif S.auctionSnipeMode == "Min Price Only" then
                        if price <= (lot.minPrice or 0) + 1 then
                            shouldBuy = true
                        end
                    elseif S.auctionSnipeMode == "Below Max Price" then
                        if price <= S.auctionMaxPrice then
                            shouldBuy = true
                        end
                    end
                    
                    if shouldBuy then
                        isSniping = true
                        task.spawn(function()
                            local char = LocalPlayer.Character
                            local hrpPart = char and char:FindFirstChild("HumanoidRootPart")
                            if hrpPart then
                                local oldPos = hrpPart.Position
                                reach(stand:GetPivot().Position + Vector3.new(0, 0, 4))
                                task.wait(0.12)
                                fire(Net.Auctioneer.PurchaseLot, lot.lotId, price)
                                task.wait(0.15)
                                reach(oldPos)
                                setStatus("sniped auction: " .. tostring(lot.item))
                            end
                            isSniping = false
                        end)
                        break
                    end
                end
            end
        end
    end

    local function autoMergeEclipseBlooms()
        if not S.autoMergeEclipse then return end
        local activeWeather = workspace:GetAttribute("ActiveWeather") or "None"
        if string.lower(activeWeather) ~= "eclipse" then return end
        
        local plot = myPlot()
        if not plot then return end
        local plantsFolder = plot:FindFirstChild("Plants")
        if not plantsFolder then return end
        
        local sunBlooms = {}
        local moonBlooms = {}
        
        for _, pl in ipairs(plantsFolder:GetChildren()) do
            if pl:IsA("Model") and pl:GetAttribute("UserId") == LocalPlayer.UserId then
                local seedName = pl:GetAttribute("SeedName")
                local plantId = pl:GetAttribute("PlantId")
                local age = pl:GetAttribute("Age")
                local maxAge = pl:GetAttribute("MaxAge")
                
                if seedName and plantId and age and maxAge and age >= maxAge then
                    local isPotted = pl:GetAttribute("IsPotted") == true
                    if not isPotted then
                        if seedName == "Sun Bloom" then
                            table.insert(sunBlooms, { id = plantId, pos = pl:GetPivot().Position })
                        elseif seedName == "Moon Bloom" then
                            table.insert(moonBlooms, { id = plantId, pos = pl:GetPivot().Position })
                        end
                    end
                end
            end
        end
        
        local range = 25
        local merged = false
        
        for _, sun in ipairs(sunBlooms) do
            for _, moon in ipairs(moonBlooms) do
                if (sun.pos - moon.pos).Magnitude <= range then
                    local success, err = fire(Net.Garden.RequestMerge, sun.id, moon.id)
                    if success then
                        merged = true
                        setStatus("merged sun & moon bloom into eclipse bloom")
                        task.wait(0.2)
                        break
                    end
                end
            end
            if merged then break end
        end
    end

    local lastWeatherCast = 0
    local function autoWeatherStaffLogic()
        if not S.autoCastWeatherStaff then return end
        if not getgenv().KysHubTier or false then return end
        
        local activeWeather = workspace:GetAttribute("ActiveWeather") or "None"
        if S.weatherStaffTarget ~= "Any" and string.lower(activeWeather) == string.lower(S.weatherStaffTarget) then
            return
        end
        
        if os.clock() - lastWeatherCast < 12 then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local staff = LocalPlayer.Backpack:FindFirstChild("Weather Staff") or char:FindFirstChild("Weather Staff")
        if not staff then return end
        
        if staff.Parent == LocalPlayer.Backpack then
            staff.Parent = char
            task.wait(0.1)
        end
        
        local success = fire(Net.WeatherStaff.TriggerWeather)
        if success then
            lastWeatherCast = os.clock()
            setStatus("cast weather staff (cycling to: " .. S.weatherStaffTarget .. ")")
        end
    end

    spawnLoop(0.5, autoSnipeAuctionLogic)
    spawnLoop(1.5, autoMergeEclipseBlooms)
    spawnLoop(1.5, autoWeatherStaffLogic)
end

--========================== PAGES =================================--
addGroup("Automation")
-- FARM
do
    local p = addTab("Farm", "🌱")
    local L, R = twoCol(p)
    -- Planting
    colTitle(L, "Planting"); subTitle(L, "Auto Plant")
    howItWorks(L, "Equips each owned seed and plants it across your plot's soil. Leave the picker empty to plant every seed you own, or choose specific ones.")
    toggleRow(L, "Auto Plant", "Plants your owned seeds on a loop.", "autoPlant")
    local plantSeedPicker = dropdownRow(L, "Seeds To Plant", "Only seeds in your inventory. Empty = plant them all.", getOwnedSeedOptions, S.plantSeeds, nil, nil, seedPriceTag)
    actionRow(L, "Plant All Seeds", "Clear the seed filter so Auto Plant uses every seed in your backpack.", function()
        if plantSeedPicker and plantSeedPicker.clear then plantSeedPicker.clear() else table.clear(S.plantSeeds); saveSettings() end
        setStatus("plant filter cleared - using all seeds")
    end)
    choiceRow(L, "Plant Pattern", "How seeds are laid out on the soil.", function() return PLANT_PATTERNS end, function() return S.plantPattern end, function(v) S.plantPattern = v end)
    choiceRow(L, "Plant Source", "My Seeds, or replant a saved garden snapshot.", function() local t={"My Seeds"} for _,n in ipairs(snapshotNames()) do t[#t+1]=n end return t end, function() return S.plantSource end, function(v) S.plantSource = v end)
    toggleRow(L, "Smart Replant", "Only plant the most profitable seed you own.", "smartReplant")
    actionRow(L, "Plant Once Now", "Run a single planting pass.", function()
        local plot = myPlot(); if not plot then return end
        local d = getData(); local seeds = d and d.Inventory and d.Inventory.Seeds; if not seeds then return end
        local useF = next(S.plantSeeds) ~= nil; local tp = {}
        for n, c in pairs(seeds) do if (not useF) or S.plantSeeds[n] then for _=1,math.min(c or 0,40) do tp[#tp+1]=n end end end
        local free = freePlantPositions(plot)
        for i = 1, math.min(#free, #tp) do fire(Net.Plant.PlantSeed, free[i], tp[i], plot) task.wait(S.plantDelay) end
        setStatus("planted " .. math.min(#free, #tp))
    end)
    subTitle(L, "Garden Size")
    toggleRow(L, "Auto Expand Garden", "Buys the next expansion whenever you can afford it.", "autoExpand")
    actionRow(L, "Expand Garden Now", "Buy one garden expansion.", function()
        local plot = myPlot(); if not plot then return end
        local before = tonumber(plot:GetAttribute("GardenExpansion")) or 0
        fire(Net.Actions.ExpandGarden); task.wait(0.8)
        local after = tonumber(plot:GetAttribute("GardenExpansion")) or before
        setStatus(after > before and ("expanded to size " .. after) or "can't expand (need more money or maxed)")
    end)
    subTitle(L, "Timing")
    sliderRow(L, "Keep In Reserve (per seed)", 0, 25, S.plantReserve, 0, function(v) S.plantReserve = v end)
    sliderRow(L, "Max Plants / Cycle", 1, 80, S.maxPerCycle, 0, function(v) S.maxPerCycle = v end)
    sliderRow(L, "Plant Delay", 0.05, 1, S.plantDelay, 2, function(v) S.plantDelay = v end)
    sliderRow(L, "Loop Delay", 0.5, 10, S.plantLoop, 1, function(v) S.plantLoop = v end)
    
    subTitle(L, "Watering")
    toggleRow(L, "Auto Water Soil", "Automatically waters dry plants.", "autoWater")
    -- Harvest
    colTitle(R, "Harvest"); subTitle(R, "Auto Harvest")
    howItWorks(R, "Collects grown fruit on your plot by firing CollectFruit for each. Use the filters below to only pick up certain crops or mutations.")
    toggleRow(R, "Auto Harvest", "Collects all ready fruit on your plot on a loop.", "autoCollect")
    dropdownRow(R, "Only These Crops", "Empty = harvest every crop type.", getHarvestOptions, S.harvestCrops, nil, nil)
    toggleRow(R, "Only Harvest Mutated Fruit", "Skips any fruit that has no mutation.", "harvestMutsOnly")
    sliderRow(R, "Per-Fruit Delay", 0.02, 0.5, S.perFruitDelay, 2, function(v) S.perFruitDelay = v end)
    sliderRow(R, "Loop Delay", 0.5, 10, S.harvestLoop, 1, function(v) S.harvestLoop = v end)
    actionRow(R, "Harvest Now", "Collect every ready fruit immediately.", function()
        setStatus("harvested " .. harvestAll(false))
    end)
    subTitle(R, "Eclipse Merging")
    toggleRow(R, "Auto Merge Eclipse Blooms", "Merges mature Sun & Moon blooms during Eclipse.", "autoMergeEclipse")
    subTitle(R, "Sell")
    toggleRow(R, "Auto Sell (spam)", "Rapid-fires Sell All nonstop while this is on - like mashing the sell button.", "autoSell")
    sliderRow(R, "Spam Delay (s)", 0.05, 1, S.sellSpamDelay, 2, function(v) S.sellSpamDelay = v end)
    toggleRow(R, "Sell When Backpack Full", "Auto-sells the moment your backpack fills.", "sellOnFull")
    actionRow(R, "Sell All Now", "Sell every harvested fruit.", function() fire(Net.NPCS.SellAll); setStatus("sold all") end)
end

-- SHOP
do
    local p = addTab("Shop", "🛒")
    local L, R = twoCol(p)
    subTitle(L, "Seeds")
    howItWorks(L, "Buys the seeds you tick the instant they restock. Empty picker = buy every seed in stock you can afford.")
    toggleRow(L, "Auto Buy Seeds", "Buys selected seeds (or all if empty).", "autoBuySeed")
    dropdownRow(L, "Seeds To Buy", "Empty = buy everything in stock.", getSeedOptions, S.buySeeds, seedStockOf, nil, seedPriceTag)
    actionRow(L, "Buy Now", "Buy your picked seeds (or all if empty) in stock.", function()
        local it = seedStockItems(); if not it then return end
        local anySel = next(S.buySeeds) ~= nil
        for _, sv in ipairs(it:GetChildren()) do if sv:IsA("ValueBase") and sv.Value > 0 and ((not anySel) or S.buySeeds[sv.Name] == true) then fire(Net.SeedShop.PurchaseSeed, sv.Name) task.wait(0.08) end end
        setStatus("bought seeds")
    end)
    
    subTitle(L, "Live Panel")
    local RestockLivePanel = modernCall(L, "AddParagraph", {
        Name = "Restock Watch",
        Content = "Loading restock data..."
    })

    subTitle(L, "Auction Stand Sniper")
    howItWorks(L, "Auto snipes seeds/items listed by Steven at the Auction Stand.")
    toggleRowPremium(L, "Auto Snipe Auction", "Buy item lots automatically from Steven.", "autoBuyAuction")
    choiceRow(L, "Snipe Mode", "Conditions to trigger purchase.", function() return {"Instant", "Min Price Only", "Below Max Price"} end, function() return S.auctionSnipeMode end, function(v) S.auctionSnipeMode = v; saveSettings() end)
    sliderRow(L, "Below Max Price (Sheckles)", 0, 1000000, S.auctionMaxPrice, 0, function(v) S.auctionMaxPrice = v; saveSettings() end)
    dropdownRow(L, "Snipe Categories", "Empty = buy all categories.", function() return {"Seeds", "HarvestedFruits", "Gears", "Pets"} end, S.buyAuctionTypes, nil, nil)

    subTitle(R, "Gear & Crates")
    howItWorks(R, "Buys gear (sprinklers, mushrooms, pots, traps...) on restock. Empty gear picker = buy EVERY gear in stock.")
    toggleRow(R, "Auto Buy Gears", "Buys selected gear (or all if empty).", "autoBuyGear")
    dropdownRow(R, "Gear To Buy", "Empty = buy everything in stock.", getGearOptions, S.buyGears, gearStockOf, nil)
    toggleRow(R, "Auto Buy Crates", "Buys every crate in stock on restock.", "autoBuyCrate")
    
    subTitle(R, "Live Panel")
    local GearRestockLivePanel = modernCall(R, "AddParagraph", {
        Name = "Gear Restock Watch",
        Content = "Loading gear restock data..."
    })
    local CrateRestockLivePanel = modernCall(R, "AddParagraph", {
        Name = "Crate Restock Watch",
        Content = "Loading crate restock data..."
    })

    -- Helper functions for panels
    local function buildRestockPanelText()
        local lines = {}
        local rem = restockIn("SeedShop")
        table.insert(lines, "Seed Restock")
        if rem then
            table.insert(lines, " Kyst: " .. fmtClock(rem))
        else
            table.insert(lines, " Kyst: unknown")
        end
        table.insert(lines, "")

        local targetSet = S.buySeeds or {}
        local anySel = next(targetSet) ~= nil
        local targetAvailable = {}
        local available = {}

        local it = seedStockItems()
        if it then
            for _, sv in ipairs(it:GetChildren()) do
                if sv:IsA("ValueBase") and sv.Value > 0 then
                    local txt = sv.Name .. " x" .. tostring(sv.Value)
                    table.insert(available, txt)
                    if targetSet[sv.Name] then
                        table.insert(targetAvailable, txt)
                    end
                end
            end
        end

        table.insert(lines, "Target In Stock")
        if #targetAvailable > 0 then
            for i = 1, math.min(#targetAvailable, 8) do
                table.insert(lines, "  " .. targetAvailable[i])
            end
            if #targetAvailable > 8 then
                table.insert(lines, "  +" .. tostring(#targetAvailable - 8) .. " more")
            end
        else
            table.insert(lines, "  " .. (anySel and "(none)" or "(all seeds targetted)"))
        end
        table.insert(lines, "")

        table.insert(lines, "All In Stock")
        if not it then
            table.insert(lines, "  StockValues not found")
        elseif #available > 0 then
            for i = 1, math.min(#available, 12) do
                table.insert(lines, "  " .. available[i])
            end
            if #available > 12 then
                table.insert(lines, "  +" .. tostring(#available - 12) .. " more")
            end
        else
            table.insert(lines, "  (none)")
        end

        return (string.gsub(table.concat(lines, "\n"), "%s+$", ""))
    end

    local function buildGearRestockPanelText()
        local lines = {}
        local rem = restockIn("GearShop")
        table.insert(lines, "Gear Restock")
        if rem then
            table.insert(lines, " Kyst: " .. fmtClock(rem))
        else
            table.insert(lines, " Kyst: unknown")
        end
        table.insert(lines, "")

        local targetSet = S.buyGears or {}
        local anySel = next(targetSet) ~= nil
        local targetAvailable = {}
        local available = {}

        local it = gearStockItems()
        if it then
            for _, sv in ipairs(it:GetChildren()) do
                if sv:IsA("ValueBase") and sv.Value > 0 then
                    local txt = sv.Name .. " x" .. tostring(sv.Value)
                    table.insert(available, txt)
                    if targetSet[sv.Name] then
                        table.insert(targetAvailable, txt)
                    end
                end
            end
        end

        table.insert(lines, "Target In Stock")
        if #targetAvailable > 0 then
            for i = 1, math.min(#targetAvailable, 8) do
                table.insert(lines, "  " .. targetAvailable[i])
            end
            if #targetAvailable > 8 then
                table.insert(lines, "  +" .. tostring(#targetAvailable - 8) .. " more")
            end
        else
            table.insert(lines, "  " .. (anySel and "(none)" or "(all gears targetted)"))
        end
        table.insert(lines, "")

        table.insert(lines, "All In Stock")
        if not it then
            table.insert(lines, "  StockValues not found")
        elseif #available > 0 then
            for i = 1, math.min(#available, 12) do
                table.insert(lines, "  " .. available[i])
            end
            if #available > 12 then
                table.insert(lines, "  +" .. tostring(#available - 12) .. " more")
            end
        else
            table.insert(lines, "  (none)")
        end

        return (string.gsub(table.concat(lines, "\n"), "%s+$", ""))
    end

    local function buildCrateRestockPanelText()
        local lines = {}
        local rem = restockIn("CrateShop")
        table.insert(lines, "Crate Restock")
        if rem then
            table.insert(lines, " Kyst: " .. fmtClock(rem))
        else
            table.insert(lines, " Kyst: unknown")
        end
        table.insert(lines, "")

        local available = {}
        local it = stockItems("CrateShop")
        if it then
            for _, sv in ipairs(it:GetChildren()) do
                if sv:IsA("ValueBase") and sv.Value > 0 then
                    table.insert(available, sv.Name .. " x" .. tostring(sv.Value))
                end
            end
        end

        table.insert(lines, "All In Stock")
        if not it then
            table.insert(lines, "  StockValues not found")
        elseif #available > 0 then
            for i = 1, math.min(#available, 12) do
                table.insert(lines, "  " .. available[i])
            end
            if #available > 12 then
                table.insert(lines, "  +" .. tostring(#available - 12) .. " more")
            end
        else
            table.insert(lines, "  (none)")
        end

        return (string.gsub(table.concat(lines, "\n"), "%s+$", ""))
    end

    -- Update loops
    spawnLoop(2, function()
        if not p.Visible then return end
        local ok, text = pcall(buildRestockPanelText)
        if ok then
            setParagraphContent(RestockLivePanel, text)
        else
            setParagraphContent(RestockLivePanel, "Seed Restock\n Error: " .. tostring(text))
        end
    end)

    spawnLoop(2, function()
        if not p.Visible then return end
        local ok, text = pcall(buildGearRestockPanelText)
        if ok then
            setParagraphContent(GearRestockLivePanel, text)
        else
            setParagraphContent(GearRestockLivePanel, "Gear Restock\n Error: " .. tostring(text))
        end
    end)

    spawnLoop(2, function()
        if not p.Visible then return end
        local ok, text = pcall(buildCrateRestockPanelText)
        if ok then
            setParagraphContent(CrateRestockLivePanel, text)
        else
            setParagraphContent(CrateRestockLivePanel, "Crate Restock\n Error: " .. tostring(text))
        end
    end)
end

-- STEAL
do
    local p = addTab("Steal", "🌙")
    local L, R = twoCol(p)
    colTitle(L, "Night Raiding"); subTitle(L, "Auto Steal")
    howItWorks(L, "Steals ripe fruit from every other garden, most valuable first. Grabs multiple fruit per plant in one trip. Works only at NIGHT.")
    toggleRowPremium(L, "Auto Steal", "Raid all gardens by fruit value.", "autoSteal")
    toggleRowPremium(L, "Return Home After", "Teleport back to your garden each pass.", "stealReturn")
    sliderRow(L, "Fruits Per Steal", 1, 10, S.stealMult, 0, function(v) S.stealMult = v end)
    colTitle(R, "Manual"); subTitle(R, "Actions")
    actionRowPremium(R, "Steal Most Valuable", "Grab the single highest-value fruit now.", function()
        if not isNight() then setStatus("not night - cannot steal") return end
        local t = stealTargets(); if t[1] then stealModel(t[1].model, S.stealMult); setStatus("stole fruit worth " .. math.floor(t[1].value)) else setStatus("nothing to steal") end
    end)
end

-- DEFENSE
do
    local p = addTab("Defense", "🛡️")
    local L = oneCol(p)
    colTitle(L, "Protect Your Garden"); subTitle(L, "Defense")
    howItWorks(L, "Panic harvest instantly collects all your ripe crops the moment night begins, before thieves can reach them. Retaliate shovels anyone standing on your plot.")
    toggleRowPremium(L, "Panic Harvest At Night", "Grab all ripe fruit when night starts.", "panicHarvest")
    toggleRowPremium(L, "Retaliate (shovel intruders)", "Hit any non-owner standing in your plot.", "retaliate")
    actionRowPremium(L, "Harvest Everything Now", "Emergency-collect all ripe fruit.", function() setStatus("harvested " .. harvestAll(false)) end)
end

-- EVENT
do
    local p = addTab("Event", "✨")
    local L, R = twoCol(p)
    colTitle(L, "Gold Moon"); subTitle(L, "Seed Pack Grabber")
    howItWorks(L, "During the Gold Moon, Gold/Rainbow seed packs spawn around the map. The hub flies to one and completes its hold-to-claim prompt. It only returns to your garden once the event ends.")
    toggleRowPremium(L, "Auto Grab Seed Packs", "Fly to and claim spawned packs.", "autoGrabPacks")
    toggleRow(L, "Rare Only (Gold / Rainbow)", "Ignore ordinary seed packs.", "grabRareOnly")
    toggleRow(L, "Return When Event Ends", "Go home only after the night ends.", "packReturn")
    toggleRow(L, "Notify On Rare Spawn", "Alert when a Gold/Rainbow spawns.", "notifyRare")
    actionRowPremium(L, "Grab Nearest Pack Now", "Claim the closest spawned pack.", function()
        local root = hrp(); if not root then return end
        local map = Workspace:FindFirstChild("Map"); local locs = map and map:FindFirstChild("SeedPackSpawnServerLocations")
        if not locs or #locs:GetChildren() == 0 then setStatus("no pack spawned right now") return end
        local best, bestD
        for _, loc in ipairs(locs:GetChildren()) do local d = (loc.Position - root.Position).Magnitude if d < (bestD or math.huge) then best, bestD = loc, d end end
        if best then grabPack(best); setStatus("grabbed nearest pack") end
    end)

    colTitle(R, "Weather"); subTitle(R, "Prediction")
    howItWorks(R, "Calculates the next upcoming weather patterns. Emulates the game's internal random seed selection to achieve 100% accuracy.")
    
    local WeatherPredictionPanel = modernCall(R, "AddParagraph", {
        Name = "Phase Information",
        Content = "Loading..."
    })

    subTitle(R, "Weather Staff Automation")
    toggleRowPremium(R, "Auto Cast Weather Staff", "Uses staff to cycle weather until target is active.", "autoCastWeatherStaff")
    choiceRow(R, "Target Weather", "Cycle weather until this becomes active.", function() return {"Any", "Rain", "Lightning", "Rainbow", "Snowfall", "Starfall", "Aurora", "Sunburst", "Eclipse"} end, function() return S.weatherStaffTarget end, function(v) S.weatherStaffTarget = v; saveSettings() end)

    task.spawn(function()
        local timeCycleData = nil
        local weatherData = nil
        local sortedPhases = {}
        
        pcall(function()
            local shared = game:GetService("ReplicatedStorage"):WaitForChild("SharedModules", 5)
            if shared then
                local tcd = shared:FindFirstChild("TimeCycleData")
                if tcd then timeCycleData = require(tcd) end
                local wd = shared:FindFirstChild("WeatherData")
                if wd then weatherData = require(wd) end
            end
        end)

        if timeCycleData and timeCycleData.Data then
            for phaseName, phaseInfo in pairs(timeCycleData.Data) do
                table.insert(sortedPhases, {
                    Name = phaseName,
                    Weathers = phaseInfo.Weathers,
                    Duration = phaseInfo.Lasts,
                    Order = phaseInfo.StartOrder
                })
            end
            table.sort(sortedPhases, function(a, b) return a.Order < b.Order end)
        end

        local function fmtTime(sec)
            if sec <= 0 then return "0s" end
            local m = math.floor(sec / 60)
            local s = math.floor(sec % 60)
            if m > 0 then return string.format("%dm %ds", m, s) end
            return string.format("%ds", s)
        end

        local function findPhaseIndex(phaseName)
            for i, ph in ipairs(sortedPhases) do
                if ph.Name == phaseName then return i end
            end
            return nil
        end

        local totalDuration = 0
        if #sortedPhases > 0 then
            for _, ph in ipairs(sortedPhases) do
                totalDuration = totalDuration + ph.Duration
            end
        end

        local function emulatePickWeather(phase, seed)
            if not phase or not phase.Weathers then return "None" end
            local totalChance = 0
            for _, wInfo in pairs(phase.Weathers) do
                totalChance = totalChance + (wInfo.Chance or 0)
            end
            if totalChance <= 0 then return "None" end
            
            local rand = Random.new(seed)
            local roll = rand:KystNumber() * totalChance
            local current = 0
            for wName, wInfo in pairs(phase.Weathers) do
                current = current + (wInfo.Chance or 0)
                if roll <= current then
                    return wName
                end
            end
            return "None"
        end

        while Hub.running do
            if not p.Visible then task.wait(1) continue end
            local ok, text = pcall(function()
                local lines = {}
                local currentPhase = workspace:GetAttribute("ActivePhase") or "Unknown"
                local activeWeather = workspace:GetAttribute("ActiveWeather") or "None"
                table.insert(lines, "Current Phase: " .. tostring(currentPhase))
                table.insert(lines, "Active Weather: " .. tostring(activeWeather))

                local phaseDuration = workspace:GetAttribute("PhaseDuration")
                if phaseDuration then
                    local serverTime = workspace:GetServerTimeNow()
                    local timeLeft = phaseDuration - serverTime
                    if timeLeft < 0 then timeLeft = 0 end
                    table.insert(lines, "Phase Ends In: " .. fmtTime(timeLeft))
                end

                local weatherValues = game:GetService("ReplicatedStorage"):FindFirstChild("WeatherValues")
                if weatherValues then
                    local activeEffects = {}
                    for k, v in pairs(weatherValues:GetAttributes()) do
                        if string.match(k, "_Playing$") and v == true then
                            table.insert(activeEffects, (string.gsub(k, "_Playing$", "")))
                        end
                    end
                    if #activeEffects > 0 then
                        table.insert(lines, "Active Effects: " .. table.concat(activeEffects, ", "))
                    end
                end

                table.insert(lines, "")

                if #sortedPhases > 0 and totalDuration > 0 then
                    local curIdx = findPhaseIndex(currentPhase)
                    if curIdx then
                        local cycleNumber = math.floor(os.time() / totalDuration)
                        local nextIdx = (curIdx % #sortedPhases) + 1
                        local nextCycle = cycleNumber
                        if nextIdx == 1 then
                            nextCycle = nextCycle + 1
                        end
                        local nextSeed = nextCycle * 1000 + nextIdx
                        local nextPhase = sortedPhases[nextIdx]
                        local predWeather = emulatePickWeather(nextPhase, nextSeed)
                        
                        table.insert(lines, ">> Kyst Phase: " .. nextPhase.Name)
                        table.insert(lines, "   Duration: " .. fmtTime(nextPhase.Duration))
                        table.insert(lines, "   Predicted Weather: " .. predWeather)

                        local nextIdx2 = (nextIdx % #sortedPhases) + 1
                        local nextCycle2 = nextCycle
                        if nextIdx2 == 1 then
                            nextCycle2 = nextCycle2 + 1
                        end
                        local nextSeed2 = nextCycle2 * 1000 + nextIdx2
                        local nextPhase2 = sortedPhases[nextIdx2]
                        local predWeather2 = emulatePickWeather(nextPhase2, nextSeed2)

                        table.insert(lines, ">> After That: " .. nextPhase2.Name)
                        table.insert(lines, "   Predicted Weather: " .. predWeather2)
                    end
                else
                    table.insert(lines, ">> Prediction: TimeCycleData not loaded")
                end

                table.insert(lines, "")

                if weatherData and weatherData.Data then
                    local activeWeatherLower = string.lower(activeWeather)
                    for _, wd in ipairs(weatherData.Data) do
                        if string.lower(wd.Name) == activeWeatherLower then
                            local desc = wd.Description or ""
                            desc = string.gsub(desc, "<[^>]+>", "")
                            table.insert(lines, "Weather Info: " .. desc)
                            table.insert(lines, "Duration: " .. fmtTime(wd.Last or 0))
                            break
                        end
                    end
                end

                return (string.gsub(table.concat(lines, "\n"), "%s+$", ""))
            end)
            if ok then
                setParagraphContent(WeatherPredictionPanel, text)
            else
                setParagraphContent(WeatherPredictionPanel, "Error: " .. tostring(text))
            end
            task.wait(1)
        end
    end)
end

addGroup("Garden")

-- ITEMS
do
    local p = addTab("Items", "📦")
    local L, R = twoCol(p)
    subTitle(L, "Auto Open")
    toggleRow(L, "Auto Open Eggs", "Opens every egg you own on a loop.", "autoEggs")
    toggleRow(L, "Auto Open Crates", "Opens every crate you own on a loop.", "autoCrates")
    toggleRow(L, "Auto Open Seed Packs", "Opens every seed pack on a loop.", "autoPacks")
    actionRow(L, "Open All Eggs", "Open your whole egg inventory now.", function() local d = getData() local b = d and d.Inventory and d.Inventory.Eggs if b then for n in pairs(b) do task.spawn(function() fire(Net.Egg.OpenEgg, n) end) task.wait(0.15) end end setStatus("opened eggs") end)
    actionRow(L, "Open All Crates", "Open your whole crate inventory now.", function() local d = getData() local b = d and d.Inventory and d.Inventory.Crates if b then for n in pairs(b) do task.spawn(function() fire(Net.Crate.OpenCrate, n) end) task.wait(0.15) end end setStatus("opened crates") end)
    actionRow(L, "Open All Seed Packs", "Open your whole seed-pack inventory now.", function() local d = getData() local b = d and d.Inventory and d.Inventory.SeedPacks if b then for n in pairs(b) do task.spawn(function() fire(Net.SeedPack.OpenSeedPack, n) end) task.wait(0.15) end end setStatus("opened packs") end)

    subTitle(R, "Garden Snapshots")
    howItWorks(R, "Stand in any garden and snapshot it to capture exactly which seeds (and how many) plus its building layout. Then pick the snapshot as your Plant Source on the Farm tab to replant it, or use Auto Build to recreate the buildings.")
    local snapName = "Snapshot 1"
    inputRow(R, "Snapshot Name", "Name to save the capture under.", snapName, "Snapshot 1", function(t) if t and t ~= "" then snapName = t end end)
    actionRow(R, "Snapshot This Garden", "Capture the garden you're standing in.", function()
        local ok, msg = captureSnapshot(snapName)
        if ok then notify('Saved "' .. snapName .. '" - ' .. msg, "Garden Snapshot", C.green) else setStatus(tostring(msg)) end
    end)
    subTitle(R, "Auto Build")
    toggleRow(R, "Auto Build Snapshot", "Recreate the source snapshot's buildings (experimental).", "autoBuild")
    actionRow(R, "Build Snapshot Now", "Place the source snapshot's buildings once.", function() buildSnapshot() end)
    subTitle(R, "Cleanup")
    dropdownRow(R, "Plants To Remove", "Pick crop types, then Remove Selected.", getPlantedOptions, S.removeCrops, nil, nil)
    actionRow(R, "Remove Selected", "Shovel only the picked crop types.", function()
        if not next(S.removeCrops) then setStatus("pick crops to remove first") return end
        setStatus("removing selected...") task.spawn(function() local n = removeSelectedPlants() setStatus("removed " .. n .. " plants") end)
    end)
    actionRow(R, "Remove All Plants", "Shovel up every plant on your plot.", function() setStatus("removing plants...") task.spawn(function() local n = removeAllPlants() setStatus("removed " .. n .. " plants") end) end)
    actionRow(R, "Remove All Buildings", "Pick up every building on your plot.", function() setStatus("removing buildings...") task.spawn(function() local n = removeAllBuildings() setStatus("removed " .. n .. " buildings") end) end)
end

-- PETS
do
    local p = addTab("Pets", "🐾")
    local L, R = twoCol(p)
    colTitle(L, "Wild Animals"); subTitle(L, "Auto Tame")
    howItWorks(L, "Sits on wild animals and tames them. Pick which species to chase, or leave empty to tame every wild animal that spawns.")
    toggleRowPremium(L, "Auto Tame Wild Animals", "Tame selected species automatically.", "autoTame")
    dropdownRow(L, "Animals To Tame", "Empty = tame everything.", getAnimalOptions, S.tameAnimals, nil, nil)

    subTitle(L, "Auto Sell Pets")
    howItWorks(L, "Automatically sells inventory pets that are below the selected rarity to the Pet Merchant.")
    toggleRowPremium(L, "Auto Sell Inventory Pets", "Sell pets below the configured rarity.", "autoSellPets")
    choiceRow(L, "Minimum Rarity To Keep", "Pets below this rarity will be automatically sold.",
        function() return { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Divine" } end,
        function() return S.autoSellMinRarity or "Rare" end,
        function(v) S.autoSellMinRarity = v end)

    colTitle(R, "Your Pets"); subTitle(R, "Auto Equip")
    howItWorks(R, "Keeps your chosen pets equipped. You can pick up to your equip slot count - the picker shows 1/3, 2/3, then MAX in red.")
    toggleRow(R, "Auto Equip Pets", "Keeps the selected pets equipped.", "autoEquipPets")
    dropdownRow(R, "Pets To Equip", "Pick up to your slot count.", getPetOptions, S.equipPets, nil, maxEquip)
    actionRow(R, "Equip Now", "Equip the selected pets immediately.", function()
        local n, mx = 0, maxEquip()
        for name in pairs(S.equipPets) do if n >= mx then break end fire(Net.Pets.RequestEquipByName, tostring(name)) n = n + 1 task.wait(0.12) end
        setStatus("equipped " .. n .. " pets")
    end)
end

-- MAIL
do
    local p = addTab("Mail", "✉️")
    local L, R = twoCol(p)
    colTitle(L, "Auto Send Mail"); subTitle(L, "Recipient")
    howItWorks(L, "Automatically sends items from your inventory to another player via the in-game Mailbox. Set the recipient username, pick an item type and name, then enable Auto Send.")
    inputRow(L, "Recipient Username", "Exact Roblox username to mail items to.", S.mailRecipient, "67_GOOD092", function(t) S.mailRecipient = t end)
    inputRow(L, "Note (optional)", "A message to include with each mail.", S.mailNote, "Enjoy!", function(t) S.mailNote = t end)

    subTitle(L, "Schedule")
    toggleRow(L, "Auto Send Mail", "Sends items on the interval below.", "autoMail")
    sliderRow(L, "Send Interval (s)", 10, 300, S.mailInterval, 0, function(v) S.mailInterval = v end)
    actionRow(L, "Send Once Now", "Fire a single mail send right now.", function()
        if S.mailRecipient == "" then setStatus("set a recipient first"); return end
        
        local ok, uid = pcall(function() return Net.Mailbox.LookupPlayer:Fire(S.mailRecipient) end)
        if not ok or not uid or uid <= 0 then
            setStatus("mailbox: player lookup failed")
            return
        end
        
        if S.mailSendAll then
            local inv = getMailInventory(); local items = {}
            for name, count in pairs(inv) do
                if (count or 0) > 0 then
                    table.insert(items, {
                        Category = S.mailItemType,
                        ItemKey = name,
                        Count = count
                    })
                end
            end
            if #items <= 0 then setStatus("mailbox: nothing to send"); return end
            local okBatch, success = pcall(function() return Net.Mailbox.SendBatch:Fire(uid, items, S.mailNote) end)
            if okBatch and success then
                setStatus(("sent %d stacks → %s"):format(#items, S.mailRecipient))
            else
                setStatus("send failed")
            end
        else
            if S.mailItemName == "" then setStatus("pick an item first"); return end
            local inv = getMailInventory(); local have = inv[S.mailItemName] or 0
            local cnt = math.min(S.mailCount, have)
            if cnt <= 0 then setStatus("out of " .. S.mailItemName); return end
            
            local items = {
                {
                    Category = S.mailItemType,
                    ItemKey = S.mailItemName,
                    Count = cnt
                }
            }
            local okBatch, success = pcall(function() return Net.Mailbox.SendBatch:Fire(uid, items, S.mailNote) end)
            if okBatch and success then
                setStatus(("sent %dx %s → %s"):format(cnt, S.mailItemName, S.mailRecipient))
            else
                setStatus("send failed")
            end
        end
    end)

    subTitle(L, "Claim Mailbox")
    toggleRowPremium(L, "Auto Claim Mail", "Automatically accepts all mail gifts.", "autoClaimMail")
    actionRowPremium(L, "Claim All Mail Now", "Instantly claims all items in your inbox.", function()
        local ok, inbox = pcall(function() return Net.Mailbox.OpenInbox:Fire() end)
        if not ok or type(inbox) ~= "table" then setStatus("mailbox: failed to fetch inbox"); return end
        local count = 0
        for id, mail in pairs(inbox) do
            if type(mail) == "table" then
                local success, claimOk = pcall(function() return Net.Mailbox.Claim:Fire(id) end)
                if success and claimOk then count = count + 1; task.wait(0.2) end
            end
        end
        setStatus(("mailbox: claimed %d items"):format(count))
    end)

    colTitle(R, "Item To Send"); subTitle(R, "What To Mail")
    howItWorks(R, "Pick which inventory category and specific item to send. 'Send All' ignores the item picker and sends every item in the chosen category.")
    choiceRow(R, "Item Category", "Which part of your inventory to pull from.",
        function() return { "Seeds", "Gears", "Eggs", "Crates", "SeedPacks" } end,
        function() return S.mailItemType end,
        function(v) S.mailItemType = v; S.mailItemName = "" end)
    choiceRow(R, "Item To Send", "Pick one item from your inventory.",
        getMailItemOptions,
        function() return S.mailItemName ~= "" and S.mailItemName or nil end,
        function(v) S.mailItemName = v end)
    sliderRow(R, "Count Per Send", 1, 999, S.mailCount, 0, function(v) S.mailCount = v end)
    toggleRow(R, "Send All (ignore count)", "Sends every item in the chosen category at once.", "mailSendAll")

    subTitle(R, "Live Stock")
    local sLbl = labelRow(R, "-", true)
    spawnLoop(2, function()
        if not p.Visible then return end
        local inv = getMailInventory(); local parts = {}
        for name, count in pairs(inv) do if (count or 0) > 0 then parts[#parts+1] = name .. " x"..count end end
        table.sort(parts)
        sLbl:SetText(#parts > 0 and table.concat(parts, "\n") or "(nothing in " .. S.mailItemType .. ")")
    end)
end

addGroup("Tools")
-- STATS
do
    local p = addTab("Stats", "📊")
    local L, R = twoCol(p)
    local function statRow(parent, lbl)
        local value = "-"
        local row = labelRow(parent, tostring(lbl or "-") .. ": " .. value)
        return {
            SetText = function(_, v)
                value = tostring(v or "-")
                row:SetText(tostring(lbl or "-") .. ": " .. value)
            end
        }
    end
    subTitle(L, "Profit Tracker")
    local sMin = statRow(L, "Per Minute", C.green); local sHr = statRow(L, "Per Hour", C.green); local sSess = statRow(L, "Session Earned", C.green)
    subTitle(R, "Inventory")
    local sInv = statRow(R, "Backpack Value", C.green); local sCnt = statRow(R, "Fruit Count"); local sBest = statRow(R, "Best Crop To Plant")
    actionRow(R, "Rescan Inventory", "Recalculate backpack worth now.", function() local v, n = inventoryValue() setStatus("inventory worth " .. money(v) .. " (" .. n .. " fruit)") end)
    spawnLoop(1, function()
        if not p.Visible then return end
        sMin:SetText(money(Profit.perMin)); sHr:SetText(money(Profit.perHr)); sSess:SetText(money(Profit.session))
        local v, n = inventoryValue(); sInv:SetText(money(v)); sCnt:SetText(n .. "x")
        local best = bestOwnedSeed(); local d = getData(); local cnt = (best and d and d.Inventory and d.Inventory.Seeds and d.Inventory.Seeds[best]) or 0
        sBest:SetText(best and (best .. "   " .. cnt .. "x") or "-")
    end)
end

-- TELEPORT
do
    local p = addTab("Teleport", "📍")
    local L, R = twoCol(p)
    colTitle(L, "Shops & NPCs"); subTitle(L, "Quick Travel")
    local function tpBtn(parent, label, pad)
        actionRow(parent, label, "Travel to the " .. label .. ".", function()
            local t = Workspace:FindFirstChild("Teleports"); local d = t and t:FindFirstChild(pad)
            if d and d:IsA("BasePart") then reach(d.Position); setStatus("teleported to " .. label) else setStatus(label .. " not found") end
        end, "GO")
    end
    tpBtn(L, "Seed Shop", "Seeds"); tpBtn(L, "Gear Shop", "Gears"); tpBtn(L, "Sell NPC", "Sell"); tpBtn(L, "Props Shop", "Props")
    colTitle(R, "Garden"); subTitle(R, "Home")
    actionRow(R, "My Garden", "Return to your own plot.", function() local plot = myPlot() local sp = plot and plot:FindFirstChild("SpawnPoint") if sp then reach(sp.Position) end setStatus("teleported home") end, "GO")
end

-- VISUAL
do
    local p = addTab("Visual", "👁️")
    local L = oneCol(p)
    colTitle(L, "ESP & Alerts"); subTitle(L, "Visual")
    howItWorks(L, "Outlines crops on screen and pings you about rare stock. Mutated-fruit ESP is distance-capped so it stays light.")
    toggleRow(L, "Highlight Ready Crops", "Outlines your own ripe crops in ruby.", "highlightReady")
    toggleRow(L, "Highlight Mutated Fruit", "Outlines nearby gold/mutated fruit in gold.", "highlightRare")
    toggleRow(L, "Rare Seed Restock Alert", "Notifies when a pricey seed hits the shop.", "rareNotify")
end

addGroup("Player")
do
    local p = addTab("Player", "🏃")
    local L, R = twoCol(p)
    subTitle(L, "Movement")
    howItWorks(L, "The game snaps you back if you move too fast, so keep speeds moderate. The hub also paces its teleports in safe hops.")
    sliderRow(L, "Walk Speed", 16, 120, S.walkSpeed, 0, function(v) S.walkSpeed = v end)
    sliderRow(L, "Jump Power", 50, 250, S.jumpPower, 0, function(v) S.jumpPower = v end)
    toggleRow(L, "Infinite Jump", "Jump again any time mid-air.", "infJump")
    toggleRow(L, "Noclip", "Walk through walls and fences.", "noclip", function(v) if not v then local c = char() if c then for _, pp in ipairs(c:GetDescendants()) do if pp:IsA("BasePart") then pp.CanCollide = true end end end end end)
    subTitle(R, "Fly")
    toggleRow(R, "Fly", "Free-fly with W/A/S/D, Space up, Ctrl down.", "fly", function(v) if not v and Hub.stopFly then Hub.stopFly() end end)
    sliderRow(R, "Fly Speed", 20, 150, S.flySpeed, 0, function(v) S.flySpeed = v end)
    subTitle(R, "Teleport")
    actionRow(R, "Go To My Garden", "Hop back to your own plot.", function() local plot = myPlot() local sp = plot and plot:FindFirstChild("SpawnPoint") if sp then reach(sp.Position) end setStatus("teleported") end)
end

addGroup("Misc")
do
    local p = addTab("Misc", "⚙️")
    local L = oneCol(p)
    colTitle(L, "Utility"); subTitle(L, "Auto Progress")
    howItWorks(L, "Hands-off progression: harvests your crops, sells them, buys the best seeds you can afford, plants them across the whole garden, and tames valuable pets (Raccoon, Dragonfly...) when they spawn. Leave it on and your coins + pets snowball.")
    toggleRowPremium(L, "Auto Progress", "Farm, sell, reinvest and tame - automatically.", "autoProgress")
    subTitle(L, "Performance")
    toggleRow(L, "Optimize", "Flat textures, grey sky, no effects - big FPS boost.", "optimize", setOptimize)
    subTitle(L, "Session")
    toggleRow(L, "Anti-AFK", "Prevents the 20-minute idle kick.", "antiAfk")
    actionRow(L, "Rejoin Server", "Teleport into the same place again.", function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end) end)
    actionRow(L, "Server Hop", "Request a fresh server.", function() pcall(function() Net.AntiAfk.RequestHop:Fire() end) setStatus("requesting new server") end)
    subTitle(L, "Info")
    labelRow(L, "Right Shift toggles the menu.", true)
    labelRow(L, "UserId " .. LocalPlayer.UserId .. " - Plot " .. (myPlot() and myPlot().Name or "?"), true)
    actionRow(L, "Unload Hub", "Stop everything and close.", function() Hub.unload() end)
end

-- SERVER
do
    local p = addTab("Server", "🌐")
    local L, R = twoCol(p)
    subTitle(L, "Server Hop")
    howItWorks(L, "Jump to other servers - handy for finding rare seed stock or fresh events. Low-pop finds the emptiest server.")
    actionRow(L, "Server Hop", "Teleport to a different server.", function() serverHop(false) end)
    actionRow(L, "Low-Pop Hop", "Teleport to the emptiest server.", function() serverHop(true) end)
    toggleRow(L, "Auto-Hop Until Rare Seed", "Keeps hopping until a 5K+ seed is in stock.", "autoHopRare")
    subTitle(R, "Webhook")
    howItWorks(R, "Paste a Discord webhook URL to get pinged about events. Toggle which events to send.")
    inputRow(R, "Webhook URL", "Discord webhook to post to.", S.webhookUrl, "https://discord.com/api/webhooks/...", function(t) S.webhookUrl = t end)
    toggleRow(R, "Notify: Rare Seed In Stock", "Posts when a 5K+ seed restocks.", "whRareSeed")
    actionRow(R, "Send Test Message", "Post a test message to your webhook.", function() if sendWebhook("Test from KysHub - webhook is working!") then setStatus("test sent") else setStatus("set a webhook URL first") end end)
end

--========================== INIT ==================================--
selectTab("Farm")
notify("Loaded successfully - press Right Shift to toggle the menu.", "KysHub crack", C.accent)
setStatus("loaded - Right Shift to toggle")
print("[KysHub crack] loaded.")
-- =============================================
-- UNIVERSAL PATCH (blokir semua notif Premium)
-- =============================================
local function blockPremiumNotifs()
    local oldWarn = warn
    warn = function(msg, ...)
        if msg and tostring(msg):find("[Pp]remium") then return end
        return oldWarn(msg, ...)
    end

    local oldNotify = _G.NotifyWarning or _G.Notify or print
    _G.NotifyWarning = function(title, content, ...)
        if content and tostring(content):find("[Pp]remium") then return end
        return oldNotify(title, content, ...)
    end
    _G.Notify = _G.NotifyWarning

    print("[KysHub] Premium patch aktif.")
end

task.spawn(blockPremiumNotifs)
