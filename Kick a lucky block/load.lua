-- =====================================================
-- KysHub | Kick A Lucky Block v1.5.2
-- UI: ModernV2 Framework (local MainV2.lua confirmed)
-- =====================================================

local ok, result = pcall(require, "./src/Init")
local ModernV2 = ok and result or nil
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
            return
        end
    end
end
if not ModernV2 then return end
if not game:IsLoaded() then game.Loaded:Wait() end

local version = "v1.5.3"
getgenv().KysHubTier = "Premium"

ModernV2:AddTheme({
    Name = "Lumi red",
    Accent = Color3.fromRGB(255, 0, 0),
    Background = Color3.fromRGB(8, 8, 13),
    Surface = Color3.fromRGB(20, 22, 27),
    Outline = Color3.fromRGB(45, 48, 58),
    Text = Color3.fromRGB(255, 255, 255),
    Placeholder = Color3.fromRGB(140, 140, 155),
    Button = Color3.fromRGB(255, 0, 0),
    Icon = Color3.fromRGB(255, 255, 255),
})

local MenuIcon = ModernV2:CreateMenuIcon({
    Image = "rbxassetid://80891639562743",
    Size = 48,
    IconColor = Color3.fromRGB(255, 255, 255),
    BGColor = Color3.fromRGB(20, 22, 27),
    StrokeColor = ModernV2.AccentColor,
    StrokeThick = 1.5,
    Draggable = true,
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Window = ModernV2:Window({
    Title = "KysHub crack",
    Content = "Kick A Lucky Block " .. version,
    Image = "80891639562743",
    Color = Color3.fromRGB(255, 0, 0),
    Uitransparent = 0.15,
    ShowUser = true,
    Search = true,
    ConfigEnabled = true,
    NotifyOnCallbackError = false,
    LoadingScreen = false,
    Enable3DRenderer = false,
    Keybind = "RightControl",
    Size = UDim2.fromOffset(520, 330),
    Config = {
        ConfigFolder = "KysHubKaLB",
        AutoSaveFile = "KYS_KaLB",
        AutoSave = false,
        AutoLoad = false,
        Overwrite = true,
        Format = "JSON",
        ShowAutoSaveToggle = true,
        TextGradient = true,
    },
})

Window:AttachMenuIcon(MenuIcon)

Window:SetAccount({
    Username = LocalPlayer.DisplayName,
    Profile = ModernV2.UserProfile,
    Expires = "cracked by @inlawry",
})

Window:CreateHomeTab({
    Name = "Dashboard",
    Icon = "lucide:layout-dashboard",
    Content = "KysHub crack Kick A Lucky Block Script",
    DiscordInvite = "",
    SupportedExecutors = { "Delta", "Synapse X", "Krnl", "Codex", "Arceus X" },
    UnsupportedExecutors = { "Roblox Studio" },
    Segments = {
        Details = { Text = "Details", Icon = "lucide:grid-2x2" },
        Script = { Text = "Script Logs", Icon = "lucide:code" },
        UI = { Text = "UI Logs", Icon = "lucide:file-text", Show = true },
    },
    Changelog = {
        {
            Title = "KysHub crack KaLB v1.5.3",
            Date = "v1.5.3",
            Description = "Added physical Aimbot/Auto-Steer for new Meteor Event. Removed patched God Mode & Freeze Wave (Server Math bypass). Restructured Event features into the Exclusive tab.",
        },
        {
            Title = "KysHub crack KaLB v1.5.2",
            Date = "v1.5.2",
            Description = "Added Event Sniper Features, new Kick Styles, new Barbells, and fixed Auto Farm completely (native GameHandler kick, God Mode dodge, v1/v2/v3).",
        },
        {
            Title = "KysHub crack KaLB v1.5.1",
            Date = "v1.5.1",
            Description = "Removed expired Block Cup event features, fixed missing module execution errors, updated UI loader to Vercel mirror, disabled AutoSave/AutoLoad.",
        },
        {
            Title = "KysHub crack KaLB v1.5.0",
            Date = "v1.5.0",
            Description = "Added Auto Upgrade Block Cup Stats, Auto Buy Potions from Cup Shop, Auto Claim BattlePass, and Auto Claims & Spins.",
        },
        {
            Title = "KysHub crack KaLB v1.4",
            Date = "v1.4",
            Description = "Migrated to ModernV2 UI framework. Improved tab layout with Double column sections. Added proper Dropdown and TextInput support.",
        },
        {
            Title = "KysHub crack KaLB v1.3",
            Date = "v1.3",
            Description = "Added Auto Filter Brainrot, Auto Teleport Collect, Auto Place Best Brainrot.",
        },
    },
    UIChangelog = {
        {
            Title = "ModernV2 Style",
            Description = "Redesigned with Double-column layout, sections, dropdowns, and text inputs.",
        },
    },
})

-- =====================================================
-- TABS
-- =====================================================
local Tabs = {
    Main      = Window:AddTab({ Name = "Main",      Icon = "lucide:gamepad-2",      Type = "Single" }),
    Farm      = Window:AddTab({ Name = "Farm",      Icon = "lucide:leaf",           Type = "Single" }),
    Exclusive = Window:AddTab({ Name = "Exclusive", Icon = "lucide:star",           Type = "Single" }),
    Social    = Window:AddTab({ Name = "Social",    Icon = "lucide:users",          Type = "Single" }),
    Shop      = Window:AddTab({ Name = "Shop",      Icon = "lucide:shopping-cart",  Type = "Single" }),
    Upgrade   = Window:AddTab({ Name = "Upgrade",   Icon = "lucide:arrow-up",       Type = "Single" }),
    Player    = Window:AddTab({ Name = "Player",    Icon = "lucide:user",           Type = "Single" }),
}

local function addCenterFeatureTabbox(tab, name, entries)
    local tabbox = tab:AddCenterTabbox(name)
    local created = {}
    for _, entry in ipairs(entries) do
        local handler = tabbox:AddTab({
            Name = entry.Name,
            Icon = entry.Icon,
        })
        -- Inject AddSection into the handler so existing code like
        -- "local sec = handler:AddSection({Name=...})" works unchanged.
        -- We convert AddSection into AddDivider (visual header) and return
        -- the handler itself so all subsequent :AddButton/:AddToggle calls
        -- go directly to the tabbox sub-tab.
        rawset(handler, "AddSection", function(self, cfg)
            if cfg and cfg.Name then
                pcall(function() handler:AddDivider({ Text = cfg.Name }) end)
            end
            return handler
        end)
        created[entry.Key] = handler
    end
    return created
end


local mainTabbox = addCenterFeatureTabbox(Tabs.Main, "Main Features", {
    { Key = "AutoKick", Name = "Auto Kick", Icon = "lucide:footprints" },
    { Key = "Extras", Name = "X2 & Equip", Icon = "lucide:mouse-pointer-click" }
})

local farmTabbox = addCenterFeatureTabbox(Tabs.Farm, "Farm Features", {
    { Key = "Collect", Name = "Collect", Icon = "lucide:package" },
    { Key = "Base", Name = "Base", Icon = "lucide:tent" },
    { Key = "Rebirth", Name = "Rebirth & Offline", Icon = "lucide:refresh-cw" }
})

local exclusiveTabbox = addCenterFeatureTabbox(Tabs.Exclusive, "Exclusive Features", {
    { Key = "Sniper", Name = "Event Sniper", Icon = "lucide:crosshair" },
    { Key = "Dupe", Name = "Dupe Weight", Icon = "lucide:layers" }
})

local socialTabbox = addCenterFeatureTabbox(Tabs.Social, "Social Features", {
    { Key = "Gift", Name = "Gift", Icon = "lucide:gift" },
    { Key = "Webhook", Name = "Webhook", Icon = "lucide:webhook" },
    { Key = "Monitor", Name = "Monitor", Icon = "lucide:backpack" }
})

local shopTabbox = addCenterFeatureTabbox(Tabs.Shop, "Shop Features", {
    { Key = "Sell", Name = "Sell", Icon = "lucide:tag" },
    { Key = "WeightSpeed", Name = "Weight & Speed", Icon = "lucide:shopping-bag" },
    { Key = "KickStyle", Name = "Kick Style", Icon = "lucide:footprints" }
})

local upgradeTabbox = addCenterFeatureTabbox(Tabs.Upgrade, "Upgrade Features", {
    { Key = "Brainrot", Name = "Brainrot", Icon = "lucide:arrow-up-circle" },
    { Key = "Base", Name = "Base", Icon = "lucide:tent" },
    { Key = "Volcano", Name = "Volcano", Icon = "lucide:flame" }
})


local playerTabbox = addCenterFeatureTabbox(Tabs.Player, "Player Features", {
    { Key = "Player", Name = "Player", Icon = "lucide:person-standing" },
    { Key = "Misc", Name = "Misc", Icon = "lucide:package" },
    { Key = "Movement", Name = "Movement", Icon = "lucide:move" }
})


-- =====================================================
-- GAME VARIABLES (pcall-protected for game updates)
-- =====================================================
local function safeRequire(path)
    local ok, result = pcall(function() return require(path) end)
    if ok then return result end
    warn("[KysHub] Failed to require: " .. tostring(path) .. " — " .. tostring(result))
    return nil
end

local KickServiceClient = safeRequire(ReplicatedStorage.Modules.ServicesLoader.KickServiceClient)
local WaveData = safeRequire(ReplicatedStorage.Shared.Data.WaveData)
local VFXService = safeRequire(ReplicatedStorage.Modules.ServicesLoader.VFXService)
local AnimationController = safeRequire(ReplicatedStorage.Modules.ControllerLoader.AnimationController)
local EntitiesData = safeRequire(ReplicatedStorage.Shared.Data.EntitiesData)
local InfiniteMath = safeRequire(ReplicatedStorage.Shared.Utility.InfiniteMath)
local ClientPlotService = safeRequire(ReplicatedStorage.Modules.ServicesLoader.ClientPlotService)
local GameMutationData = safeRequire(ReplicatedStorage.Shared.Data.MutationData)
local GameNetwork = safeRequire(ReplicatedStorage.Shared.Packages.Network)
local defaultKickSpeed = KickServiceClient and KickServiceClient.Multipliers and KickServiceClient.Multipliers.Speed or 1
local originalWaveSpeeds = {}
local originalPlayVFX = VFXService and VFXService.PlayVFX or function() end
local originalPlayAnim = AnimationController and AnimationController.PlayAnim or function() end
if WaveData and WaveData.Data then
    for i, wave in pairs(WaveData.Data) do
        originalWaveSpeeds[i] = wave.Speed
    end
end

local tweenSpeed = 50
local rewardCheckDistance = 26
local kickValues = {
    Perfect = 1,
    Excellent = 0.8670379929244518,
    Great = 0.6358855310827494,
    Mid = 0.2641407661139965,
    Bad = 0.06738599948585033
}
local currentKickPower = "Perfect"
local kickModeList = {"Kys Method V1", "Kys Method V2", "Kys Method V3 (Risk!)"}
local kickPowerList = {"Perfect", "Excellent", "Great", "Mid", "Bad"}
local kickMode = (getgenv().KysHubTier == "Premium") and kickModeList[1] or kickModeList[2]

local MutationData = {
    "Golden", "Diamond", "Plasma", "Radioactive", "Molten",
    "Void", "Shadow", "Electrified", "Rainbow", "Virus",
    "Volcanic", "Wet", "Alien", "Bacon", "Enchanted",
    "Phantom", "Astral", "Heavenly", "Carnival", "Block Cup",
    "Undead", "Jungle", "Frozen"
}

local BrainrotData = {
    "1x1x1x1","67","Alessio","Agarrini La Palini","Anpali Babel","Astro Tim","Baba Yaga",
    "Ballerina Cappuccina","Bambini Crostini","Bananita Dolphinita","Bangello","Beluga Beluga",
    "Blackhole Goat","Bobrito Bandito","Bombardiro Crocodilo","Bombini Gusini","Boneca Ambalabu",
    "Brr Brr Patapim","Burbaloni Luliloli","Burguro","Cacto Hipopotamo","Cactus Pingu",
    "Capi Taco","Cappuccino Assassino","Cappuccino Clownino","Capybara Eggplant","Cavallo Virtuso",
    "Chef Crabracadabra","Chicleteira Bicicleteira","Chillin Chilli","Chimpanzini Bananini",
    "Cocofanto Elefanto","Compactoroni Diskaloni","Corn Sahur","Crazylone Pizaione",
    "Dipperi Chiperini","Dragonfrutina Dolphinita","Elefanto Frigo","Elefantucci Bananucci",
    "Espresso Signora","Frigo Camelo","Fruli Frula","Fryuro","Gangster Footera","Garamararam",
    "Gattatino Nyanino","Girafa Celeste","Glorbo Fruttodrillo","Gorillo Watermelondrillo",
    "Guerriro Digitale","Guest666","John Pork","Karkerkar Kurkur","Ketupat Kepat","Kicky",
    "Krupuk Pagi Pagi","La Vacca Saturno Saturnita","Lirili Larila","Los Primos","Los Primos Blue",
    "Madung","Mangolini Parrocini","Mastodontico Telepiedone","Matteo","Meowl",
    "Noobini Pizzanini","Nuclearo Dinossauro","Octopusini Bluberini","Orangutini Ananasini",
    "Orcalero","Pandaccini Bananini","Pannaburro","Peant Jarro","Penguino Cocosino",
    "Pesto Mortioni","Pipi Kiwi","Plan Blue","Plan Red","Pot Hotspot","Professora 67",
    "Rexosaurus","Rhino Toasterino","Rinooccio Verdini","SWAG SODA","Salamino Pinguino",
    "Sigma Boy","Stoppo Luminino","Strawberelli Flamingelli","Strawberry Elephant",
    "Svinina Bombardino","Ta Ta Ta Ta Sahur","Talpa Di Fero","Tictac Sahur","Tim Cheese",
    "Torrtuginni Dragonfrutini","Tralaledon","Tralalero Tralala","Tralalerita Tralala",
    "Tripi Tropi Tropa Tripa","Trippi Troppi","Trulimero Trulicina","Tuff Toucan",
    "Udin Din Din Dun","Waterdino","Zibra Zubra Zibralini"
}


local autofarm = false
local farmThread = nil
local currentTween = nil
local safeZone = CFrame.new(690.45, 2.79, 230.67)
local KICK_POS = CFrame.new(692, 3, 231)
local x2Delay = 0.2
local selectedEquip = "Wooden Stick"
local equipList = {
    "Wooden Stick", "Bone Barbell", "Stone Block", "Copper Plate", "Iron Plate",
    "Ice Barbell", "Donut Barbell", "Golden Barbell", "Heaven Plate",
    "Mega Golden Barbell", "Neon Pulse", "Giant Gold Star Barbell",
    "Emerald Barbell", "Planet Barbell", "Big Jupiter", "Black Hole Barbell"
}
local kickStyleList = {
    "Default", "Stomp", "Mule", "Retro", "Acrobatic", "Ballerina", "Chest", 
    "Flip", "Karate", "Lava", "Meteor", "Rainbow", "Spartan", "Super", "Tornado"
}
local selectedKickStyle = kickStyleList[1]
local selectedIndex = 1
local collectDelay = 0.5
local Delay = 0.5
local AfterDelay = 3
local autoX2 = false
local autoClaimFree = false
local autoGroupClaim = false
local autoOfflineClaim = false
local brainrotLoop = false
local AutoCollect = false
local rebirthLoop = false
local offlineLoop = false
local sellLoop = false
local sellAllLoop = false
local instantPlace = false
local autoPlaceBest = false
local autoUnplace = false
local AutoMeteor = false
local infJump = false
local noclip = false
local antiAFK = false
local afkConnection = nil
local autoReconnect = false
local upgradeLoop = false
local bsLoop = false
local autoBuyKickStyle = false
local AutoGift = false
local SelectedPlayer = nil
local selectedGiftIndex = 1
local webhookEnabled = false
local sentCache = {}
local WebhookURL = ""
local dupeWeightLoopExclusive = false
local lastResolvedKickDataValue = 0
local peakKickDataValue = 0
local dupeBaseInterval = 0.18
local dupeFastInterval = 0.12
local dupeSlowInterval = 0.35
local dupeCurrentInterval = dupeBaseInterval
local selectedLevel = 1
local selectedSpeed = 1
local cachedPlot = nil
local defaultWalk = 16
local defaultJump = 50
local currentWalk = defaultWalk
local currentJump = defaultJump
local autoVolcanoUpgrade = false
local selectedVolcanoUpgrades = {}
local volcanoUpgradeList = {"OreMultipliers", "OreSize", "SpecialOres", "VolcanicMutation", "VolcanicMutationChance"}
local autoPinata = false
local autoRedButton = false
local autoMightyChest = false


-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================
local function findFloor(cf, partToIgnore)
    local rayOrigin = cf.Position + Vector3.new(0, 10, 0)
    local rayDir = Vector3.new(0, -1000, 0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local excludeList = {}
    if partToIgnore then table.insert(excludeList, partToIgnore) end
    if LocalPlayer and LocalPlayer.Character then table.insert(excludeList, LocalPlayer.Character) end
    params.FilterDescendantsInstances = excludeList
    params.RespectCanCollide = true
    local result = Workspace:Raycast(rayOrigin, rayDir, params)
    if result then
        local pos = result.Position + Vector3.new(0, 3.5, 0)
        return CFrame.new(pos) * (cf - cf.Position)
    end
    return CFrame.new(Vector3.new(cf.Position.X, 3.5, cf.Position.Z)) * (cf - cf.Position)
end

local function getSafeZoneCFrame()
    local lobby = Workspace:FindFirstChild("Lobby")
    local safe = lobby and lobby:FindFirstChild("Safe")
    local baseCf = safeZone
    local partToIgnore = nil
    if safe then
        partToIgnore = safe
        if safe:IsA("BasePart") then baseCf = safe.CFrame
        elseif safe:IsA("Model") then
            local primary = safe.PrimaryPart or safe:FindFirstChildWhichIsA("BasePart")
            if primary then baseCf = primary.CFrame; partToIgnore = primary end
        end
    end
    return findFloor(baseCf, partToIgnore)
end

local function getKickReadyCFrame()
    local areas = Workspace:FindFirstChild("Areas")
    local kickReady = areas and areas:FindFirstChild("KickReady")
    local baseCf = KICK_POS
    local partToIgnore = nil
    if kickReady then
        partToIgnore = kickReady
        if kickReady:IsA("BasePart") then baseCf = kickReady.CFrame
        elseif kickReady:IsA("Model") then
            local primary = kickReady.PrimaryPart or kickReady:FindFirstChildWhichIsA("BasePart")
            if primary then baseCf = primary.CFrame; partToIgnore = primary end
        end
    end
    return findFloor(baseCf, partToIgnore)
end

local function stabilizeAt(hrp, targetCf)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = targetCf
end

local function stabilizeAtSafe(hrp) stabilizeAt(hrp, getSafeZoneCFrame()) end

local function setInstantMode(state)
    if state then
        if KickServiceClient and KickServiceClient.Multipliers then KickServiceClient.Multipliers.Speed = 1e6 end
        if WaveData and WaveData.Data then for _, wave in pairs(WaveData.Data) do wave.Speed = 0 end end
        VFXService.PlayVFX = function(name, ...)
            if name == "AnimateBrainrots" then return end
            return originalPlayVFX(name, ...)
        end
        AnimationController.PlayAnim = function(name)
            local track = originalPlayAnim(name)
            if track then track:AdjustSpeed(1000) end
            return track
        end
    else
        if KickServiceClient and KickServiceClient.Multipliers then KickServiceClient.Multipliers.Speed = defaultKickSpeed end
        if not WaveFreeze and WaveData and WaveData.Data then
            for i, wave in pairs(WaveData.Data) do wave.Speed = originalWaveSpeeds[i] end
        end
        VFXService.PlayVFX = originalPlayVFX
        AnimationController.PlayAnim = originalPlayAnim
    end
end

local function getCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    return char, hrp
end

local function unequipAllTools()
    local char = getCharacter()
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:UnequipTools()
    end
end

local function stopTween()
    if currentTween then currentTween:Cancel(); currentTween = nil end
end

local function tweenTo(cf, hrp)
    stopTween()
    local distance = (hrp.Position - cf.Position).Magnitude
    local duration = math.max(distance / tweenSpeed, 0.05)
    currentTween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = cf})
    currentTween:Play()
    currentTween.Completed:Wait()
    currentTween = nil
end

local function walkTo(hrp, targetCf)
    local dist = (hrp.Position - targetCf.Position).Magnitude
    local timeout = tick() + math.max(15, (dist / 16) + 10)
    local rewardMode = false
    local rewardHoldDone = false
    while tick() < timeout and autofarm do
        local currentChar, currentHrp = getCharacter()
        local humanoid = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
        if not currentHrp then task.wait(0.1)
        else
            local distToSafe = (currentHrp.Position - targetCf.Position).Magnitude
            if not rewardMode and distToSafe <= rewardCheckDistance then rewardMode = true end
            if currentHrp.Position.Y < -25 then stabilizeAt(currentHrp, targetCf); break end
            if distToSafe <= 5 then
                if rewardMode and not rewardHoldDone then
                    local holdUntil = tick() + 1.2
                    while tick() < holdUntil and autofarm do
                        if humanoid and humanoid.Parent then humanoid:MoveTo(targetCf.Position) end
                        task.wait(0.12)
                    end
                    rewardHoldDone = true
                end
                if currentHrp then
                    currentHrp.AssemblyLinearVelocity = Vector3.zero
                    currentHrp.AssemblyAngularVelocity = Vector3.zero
                end
                break
            end
            if humanoid then
                if rewardMode then humanoid.Jump = true end
                humanoid:MoveTo(targetCf.Position)
            else tweenTo(targetCf, currentHrp); stabilizeAt(currentHrp, targetCf); break end
            task.wait(0.15)
        end
    end
    local _, finalHrp = getCharacter()
    if finalHrp then
        finalHrp.AssemblyLinearVelocity = Vector3.zero
        finalHrp.AssemblyAngularVelocity = Vector3.zero
    end
end

local function walkToSafe(hrp) walkTo(hrp, getSafeZoneCFrame()) end
local function walkToKick(hrp) walkTo(hrp, getKickReadyCFrame()) end

local function sendToSafeZone(hrp, mode)
    local safeCf = getSafeZoneCFrame()
    if mode == "teleport" then hrp.CFrame = safeCf else tweenTo(safeCf, hrp) end
    stabilizeAtSafe(hrp)
end

local function sendToKickZone(hrp, mode)
    local kickCf = getKickReadyCFrame()
    if mode == "teleport" then hrp.CFrame = kickCf else tweenTo(kickCf, hrp) end
    stabilizeAt(hrp, kickCf)
end

local function moveBeforeKick(hrp)
    if kickMode == "Kys Method V3 (Risk!)" then sendToKickZone(hrp, "teleport")
    elseif kickMode == "Kys Method V2" then walkToKick(hrp)
    else sendToKickZone(hrp, "tween") end
end

local function fireDupeWeight()
    local ok = pcall(function()
        local evt = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Network"):WaitForChild("rev_TaviMishkal")
        if firesignal and evt and evt.OnClientEvent then firesignal(evt.OnClientEvent, 2) end
    end)
    return ok
end

local function fireKickData(value)
    if type(value) ~= "number" or value <= 0 then return false end
    local ok = pcall(function()
        local evt = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Network"):WaitForChild("rev_KickData")
        if firesignal and evt and evt.OnClientEvent then firesignal(evt.OnClientEvent, value) end
    end)
    return ok
end

local function getResolvedKickDataValue()
    local resolved = nil
    pcall(function()
        local dataNode = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):FindFirstChild("KickData")
        if not dataNode then return end
        if dataNode:IsA("IntValue") or dataNode:IsA("NumberValue") then resolved = tonumber(dataNode.Value); return end
        if dataNode:IsA("Folder") or dataNode:IsA("Configuration") then
            local target = dataNode:FindFirstChild(tostring(LocalPlayer.UserId)) or dataNode:FindFirstChild(LocalPlayer.Name)
            if target then
                if target:IsA("IntValue") or target:IsA("NumberValue") then resolved = tonumber(target.Value); return end
                local valueObj = target:FindFirstChild("Value") or target:FindFirstChild("KickData") or target:FindFirstChild("Power") or target:FindFirstChild("Stats")
                if valueObj and (valueObj:IsA("IntValue") or valueObj:IsA("NumberValue")) then resolved = tonumber(valueObj.Value); return end
            end
        end
    end)
    if (not resolved or resolved <= 0) and LocalPlayer then
        for _, container in ipairs({LocalPlayer:FindFirstChild("leaderstats"), LocalPlayer:FindFirstChild("Stats"), LocalPlayer:FindFirstChild("Data")}) do
            if container then
                for _, key in ipairs({"KickPower", "Power", "KickData", "Stats"}) do
                    local node = container:FindFirstChild(key)
                    if node and (node:IsA("IntValue") or node:IsA("NumberValue")) then resolved = tonumber(node.Value); break end
                end
            end
            if resolved and resolved > 0 then break end
        end
    end
    return resolved
end

local function fireDupeWeightReal()
    local beforeValue = getResolvedKickDataValue()
    fireDupeWeight()
    task.wait(0.06)
    local liveValue = getResolvedKickDataValue()
    local currentValue = math.max(beforeValue or 0, liveValue or 0)
    if currentValue > peakKickDataValue then peakKickDataValue = currentValue end
    if currentValue <= 0 then return end
    local targetValue = currentValue
    local delta = targetValue - (lastResolvedKickDataValue or 0)
    local dropFromLast = (lastResolvedKickDataValue or 0) - targetValue
    if dropFromLast > 0 then
        dupeCurrentInterval = math.min(dupeSlowInterval, dupeCurrentInterval + 0.08); return
    end
    if delta >= 250 then dupeCurrentInterval = dupeFastInterval
    elseif delta <= 0 then dupeCurrentInterval = math.min(dupeSlowInterval, dupeCurrentInterval + 0.03)
    else dupeCurrentInterval = math.max(dupeBaseInterval, dupeCurrentInterval - 0.02) end
    fireKickData(targetValue)
    lastResolvedKickDataValue = targetValue
end

local function clickX2()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("KickUpgrades")
    if not gui then return end
    for _, v in pairs(gui:GetDescendants()) do
        if v.Name == "Bonus" and (v:IsA("ImageButton") or v:IsA("TextButton")) then
            pcall(function() firesignal(v.Activated); firesignal(v.MouseButton1Click) end)
        end
    end
end

local function getMyPlot()
    local plots = workspace:WaitForChild("Plots")
    for _, plot in pairs(plots:GetChildren()) do
        local deco = plot:FindFirstChild("Decorations")
        if deco then
            local owner = deco:FindFirstChild("PlotOwner")
            if owner then
                local gui = owner:FindFirstChild("OwnerGUI")
                if gui then
                    local label = gui:FindFirstChild("TextLabel")
                    if label and label.Text == LocalPlayer.Name then return plot end
                end
            end
        end
    end
end

local collectEvent = {
    FireServer = function(_, slotNum)
        if GameNetwork then
            GameNetwork.FireServer("B_Collect", slotNum)
        end
    end
}

local function parseCPS(text)
    if type(text) ~= "string" then return -1 end
    local raw = text:gsub("<[^>]+>", ""):lower():gsub("%$", ""):gsub("/s", ""):gsub(",", ""):gsub("%s+", "")
    local numStr, suffix = raw:match("^(%d+%.?%d*)([a-z]*)$")
    if not numStr then return -1 end
    local num = tonumber(numStr)
    if not num then return -1 end
    local mult = {k=1e3, m=1e6, b=1e9, t=1e12, qd=1e15, qn=1e18}
    if mult[suffix] then num = num * mult[suffix] end
    return num
end

local function getToolCPS(tool)
    if not EntitiesData or not EntitiesData.Brainrots then return nil end
    
    local cleanName = tool.Name:match("^%s*(.-)%s*$")
    
    -- Get mutation from Roblox Attribute (this game's standard for inventory tools)
    local activeMutation = tool:GetAttribute("Mutation")
    
    -- Fallback to name prefix extraction if attribute is not set
    if (not activeMutation or activeMutation == "None" or activeMutation == "") and GameMutationData and GameMutationData.ValidMutations then
        activeMutation = nil
        for _, mutation in ipairs(GameMutationData.ValidMutations) do
            local pattern = "^" .. mutation:lower() .. "%s+"
            if cleanName:lower():match(pattern) then
                activeMutation = mutation
                cleanName = cleanName:sub(#mutation + 2)
                break
            end
        end
    end
    
    -- Try direct match first
    local info = EntitiesData.Brainrots[cleanName]
    if not info then
        -- Case-insensitive lookup fallback
        for name, data in pairs(EntitiesData.Brainrots) do
            if name:lower() == cleanName:lower() then
                info = data
                break
            end
        end
    end
    
    if info then
        local baseCPS = info.CPS or info.BasePrice
        if baseCPS then
            local multiplier = 1
            if activeMutation and activeMutation ~= "None" and activeMutation ~= "" then
                multiplier = GameMutationData.Buffs[activeMutation] and GameMutationData.Buffs[activeMutation].Value or 1
            end
            
            -- Apply tool level multiplier if set on tool attribute
            local level = tool:GetAttribute("Level") or 1
            local levelMult = 1.25 ^ (level - 1)
            
            return baseCPS * multiplier * levelMult
        end
    end
    return nil
end

local function isCPSEaterThan(cpsA, cpsB)
    local success, result = pcall(function()
        return cpsA > cpsB
    end)
    if success then return result end
    local strA = tostring(cpsA)
    local strB = tostring(cpsB)
    return parseCPS(strA) > parseCPS(strB)
end

local function getBestBrainrotInBackpack()
    local bestTool, bestCPS = nil, nil
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    
    local candidates = {}
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then table.insert(candidates, tool) end
        end
    end
    
    local char = getCharacter()
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then table.insert(candidates, tool) end
        end
    end
    
    for _, tool in ipairs(candidates) do
        local cps = getToolCPS(tool)
        if cps then
            if not bestCPS or isCPSEaterThan(cps, bestCPS) then
                bestCPS = cps
                bestTool = tool
            end
        end
    end
    return bestTool, bestCPS
end

local function getOwningPlot()
    if ClientPlotService and ClientPlotService.Model then
        return ClientPlotService.Model
    end
    if cachedPlot and cachedPlot.Parent then return cachedPlot end
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local char = getCharacter()
    if not char or not char.PrimaryPart then return nil end
    local closestPlot, minDistance = nil, math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") or plot:IsFolder() then
            local slots = plot:FindFirstChild("Slots")
            if slots then
                local slot1 = slots:FindFirstChild("Slot1") or slots:GetChildren()[1]
                if slot1 then
                    local basePart = slot1:IsA("BasePart") and slot1 or slot1:FindFirstChildWhichIsA("BasePart", true)
                    if basePart then
                        local dist = (basePart.Position - char.PrimaryPart.Position).Magnitude
                        if dist < minDistance then minDistance = dist; closestPlot = plot end
                    end
                end
            end
        end
    end
    if minDistance < 150 then cachedPlot = closestPlot; return closestPlot end
    return nil
end

local function isSlotOccupied(slotObj)
    if not slotObj then return false end
    for _, child in ipairs(slotObj:GetChildren()) do
        if child:IsA("Model") then return true end
    end
    local placedPart = slotObj:FindFirstChild("PlacedPart")
    if placedPart then
        for _, child in ipairs(placedPart:GetChildren()) do
            if child:IsA("Model") then return true end
        end
    end
    return false
end

local HttpService = game:GetService("HttpService")
local requestFunction = syn and syn.request or http and http.request or http_request or request
local Network = ReplicatedStorage.Shared.Packages.Network

local function GetPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(list, plr.Name) end
    end
    return list
end

local function SendGiftToTarget()
    if not SelectedPlayer then return end
    local target = Players:FindFirstChild(SelectedPlayer)
    if not target then return end
    pcall(function()
        local giftReq = Network:FindFirstChild("rev_myMarket_gift")
        if giftReq then giftReq:FireServer(target.UserId) end
    end)
end

local function GetBackpackList()
    local items = {}
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then for _, v in ipairs(bp:GetChildren()) do table.insert(items, v.Name) end end
    return #items == 0 and "Empty" or table.concat(items, "\n")
end

local function SendWebhook(status)
    if WebhookURL == "" or not requestFunction then return end
    pcall(function()
        requestFunction({
            Url = WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                username = "xXHaNdEROXx",
                avatar_url = "https://cdn.discordapp.com/attachments/1429845065752117268/1479099416055906334/Tak_berjudul76_20260203000028.png",
                embeds = {{
                    title = "KysHub crack | Kick A Lucky Block",
                    color = 9699539,
                    fields = {
                        { name = "Player", value = LocalPlayer.Name, inline = false },
                        { name = "Status", value = status, inline = false },
                        { name = "Brainrot", value = GetBackpackList(), inline = false }
                    },
                    footer = { text = "KysHub Backpack " .. os.date("%H:%M:%S") }
                }}
            })
        })
    end)
end

local BackpackLabel = nil

local function UpdateBackpackUI()
    if BackpackLabel then
        pcall(function() BackpackLabel:SetContent(GetBackpackList()) end)
    end
end

local function ScanBackpack()
    UpdateBackpackUI()
    local current = GetBackpackList()
    if sentCache[current] then return end
    sentCache[current] = true
    if webhookEnabled then SendWebhook("Connection") end
end

local bpAddedConn, bpRemovedConn
local function SetupBackpackConnections()
    local bp = LocalPlayer:WaitForChild("Backpack", 5)
    if not bp then return end
    if bpAddedConn then bpAddedConn:Disconnect() end
    if bpRemovedConn then bpRemovedConn:Disconnect() end
    bpAddedConn = bp.ChildAdded:Connect(function() task.wait(0.1); table.clear(sentCache); ScanBackpack() end)
    bpRemovedConn = bp.ChildRemoved:Connect(function() task.wait(0.1); table.clear(sentCache); ScanBackpack() end)
end

-- =====================================================
-- AUTO METEOR STEER (AIMBOT) LOGIC
-- =====================================================
local currentBlock = nil
local custom_X_offset = 0

task.spawn(function()
    local GameHandler
    pcall(function()
        GameHandler = require(game:GetService("ReplicatedStorage").Modules.HandlerLoader.GameHandler)
    end)

    if GameHandler and GameHandler.BlockKicked then
        GameHandler.BlockKicked:Connect(function(block)
            currentBlock = block
            custom_X_offset = 0 -- Reset X offset at the start of each kick
        end)
        GameHandler.Landed:Connect(function()
            currentBlock = nil
        end)
    end

    game:GetService("RunService").Heartbeat:Connect(function(dt)
        if not AutoMeteor then return end
        if currentBlock then
            local blockHrp = currentBlock:IsA("Model") and currentBlock.PrimaryPart or currentBlock
            if not blockHrp or not blockHrp:IsA("BasePart") then return end
            
            local kickReady = workspace:FindFirstChild("Areas") and workspace.Areas:FindFirstChild("KickReady")
            if not kickReady then return end
            
            local closestMeteor = nil
            local closestDist = math.huge
            local debris = workspace:FindFirstChild("Debris")
            
            -- Radar: Scan for meteors in front of the block
            if debris then
                for _, obj in ipairs(debris:GetChildren()) do
                    if obj:IsA("Model") and tonumber(obj.Name) then
                        local root = obj:FindFirstChild("RootPart") or obj.PrimaryPart
                        if root then
                            local relPos = blockHrp.CFrame:PointToObjectSpace(root.Position)
                            -- If meteor is in front (Z < 0) and within 1000 studs
                            if relPos.Z < 0 and relPos.Z > -1000 then 
                                local dist = math.abs(relPos.Z)
                                if dist < closestDist then
                                    closestDist = dist
                                    closestMeteor = root
                                end
                            end
                        end
                    end
                end
            end
            
            -- Auto-Steer: Calculate target X
            if closestMeteor then
                local targetRel = kickReady.CFrame:PointToObjectSpace(closestMeteor.Position)
                local targetX = targetRel.X
                
                -- Smoothly steer towards the meteor (150 studs per second laterally)
                local diffX = targetX - custom_X_offset
                local speed = 150 * dt
                if math.abs(diffX) <= speed then
                    custom_X_offset = targetX
                else
                    custom_X_offset = custom_X_offset + math.sign(diffX) * speed
                end
            else
                -- If no meteor found, steer back to center (0)
                local diffX = 0 - custom_X_offset
                local speed = 150 * dt
                if math.abs(diffX) <= speed then
                    custom_X_offset = 0
                else
                    custom_X_offset = custom_X_offset + math.sign(diffX) * speed
                end
            end
            
            -- Apply the new steered X position to the block
            local blockRel = kickReady.CFrame:PointToObjectSpace(blockHrp.Position)
            local newWorldPos = kickReady.CFrame:PointToWorldSpace(Vector3.new(custom_X_offset, blockRel.Y, blockRel.Z))
            
            -- Keep orientation intact, only override position
            blockHrp.CFrame = CFrame.new(newWorldPos) * (blockHrp.CFrame - blockHrp.Position)
        end
    end)
end)



-- =====================================================
-- UI: MAIN TAB
-- =====================================================
do
    -- LEFT: Auto Kick
    local autoKickSec = mainTabbox.AutoKick:AddSection({
        Name = "Auto Kick",
        Position = "Left",
        Icon = "lucide:footprints",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    autoKickSec:AddButton({
        Name = "Teleport Safe Zone",
        Icon = "lucide:shield",
        Callback = function()
            local _, hrp = getCharacter()
            sendToSafeZone(hrp, "teleport")
        end
    })

    autoKickSec:AddToggle({
        Name = "Auto Farm",
        Flag = "AutoFarm",
        Default = false,
        Callback = function(state)
            autofarm = state
            if not state then stopTween(); setInstantMode(false); return end
            if farmThread then return end
            farmThread = task.spawn(function()
                while autofarm do
                    local ok, result = pcall(function()
                        local _, hrp = getCharacter()
                        if not hrp then return "no_char" end
                        local kickPercent = kickValues[currentKickPower] or 1
                        
                        -- Require the game's native GameHandler
                        local GameHandler = require(game:GetService("ReplicatedStorage").Modules.HandlerLoader.GameHandler)
                        
                        -- 1. Move to KickReady zone
                        moveBeforeKick(hrp)
                        task.wait(0.3)
                        
                        -- 2. Trigger the native kick! This will play the animation and handle everything locally.
                        GameHandler:Kick(kickPercent, 1)
                        
                        -- 3. Wait until the game state changes to "Tsunami"
                        -- This means the kick animation finished, the block spawned, and the game automatically teleported us to the block.
                        local timeout = tick() + 20
                        while GameHandler.Status ~= "Tsunami" and autofarm do
                            task.wait(0.1)
                            if tick() > timeout then return "kick_timeout" end
                        end
                        
                        if not autofarm then return "stopped" end
                        task.wait(0.2) -- Small delay to let the tsunami spawn
                        
                        -- 4. Move player back to the Safe Zone (Base)
                        -- The game will detect this and automatically send the KickCollect packet.
                        local _, finalHrp = getCharacter()
                        if finalHrp then
                            if kickMode == "Kys Method V3 (Risk!)" then
                                sendToSafeZone(finalHrp, "teleport")
                            elseif kickMode == "Kys Method V2" then
                                walkToSafe(finalHrp)
                            else
                                sendToSafeZone(finalHrp, "tween")
                            end
                        end
                        
                        -- 5. Wait for the game to process collection and reset state
                        timeout = tick() + 10
                        while GameHandler.InGame and autofarm do
                            task.wait(0.1)
                            if tick() > timeout then return "collect_timeout" end
                        end
                        
                        return "success"
                    end)
                    
                    task.wait(0.5)
                end
                stopTween(); setInstantMode(false); farmThread = nil
            end)
        end
    })



    -- RIGHT: Settings
    local settingsSec = mainTabbox.AutoKick:AddSection({
        Name = "Settings",
        Position = "Right",
        Icon = "lucide:settings",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    settingsSec:AddLabel("Kick Mode"):SetStacked(true):AddDropdown({
        Flag = "KickMode",
        Values = kickModeList,
        Default = (getgenv().KysHubTier == "Premium") and kickModeList[1] or kickModeList[2],
        DisabledOptions = getgenv().KysHubTier ~= "Premium" and {"Kys Method V1", "Kys Method V3 (Risk!)"} or {},
        Callback = function(val)
            if (val == "Kys Method V1" or val == "Kys Method V3 (Risk!)") and getgenv().KysHubTier ~= "Premium" then return end
            kickMode = val
            setInstantMode(false)
        end
    })

    settingsSec:AddLabel("Kick Power"):SetStacked(true):AddDropdown({
        Flag = "KickPower",
        Values = kickPowerList,
        Default = kickPowerList[1],
        Callback = function(val) currentKickPower = val end
    })

    settingsSec:AddLabel("Tween Speed"):SetStacked(true):AddSlider({
        Flag = "TweenSpeed",
        Min = 10, Max = 200, Default = 50, Increment = 1,
        Callback = function(v) tweenSpeed = v end
    })

    settingsSec:AddLabel("Reward Check Dist"):SetStacked(true):AddSlider({
        Flag = "RewardDist",
        Min = 8, Max = 120, Default = 26, Increment = 1,
        Callback = function(v) rewardCheckDistance = v end
    })

    -- CENTER: Auto Click X2
    local x2Sec = mainTabbox.Extras:AddSection({
        Name = "Auto Click X2",
        Position = "Center",
        Icon = "lucide:mouse-pointer-click",
        Box = true,
        BoxBorder = true,
        Opened = false,
    })

    x2Sec:AddToggle({
        Name = "Auto Click X2",
        Flag = "AutoX2",
        Default = false,
        Locked = getgenv().KysHubTier ~= "Premium",
        TextLocked = "Premium Required",
        Callback = function(state)
            if state and getgenv().KysHubTier ~= "Premium" then return end
            autoX2 = state
            if autoX2 then
                task.spawn(function()
                    while autoX2 do clickX2(); task.wait(x2Delay) end
                end)
            end
        end
    })

    x2Sec:AddButton({
        Name = "Click X2 Once",
        Icon = "lucide:mouse-pointer",
        Locked = getgenv().KysHubTier ~= "Premium",
        TextLocked = "Premium Required",
        Callback = function()
            if getgenv().KysHubTier ~= "Premium" then return end
            clickX2()
        end
    })

    x2Sec:AddLabel("Click Delay"):SetStacked(true):AddSlider({
        Flag = "X2Delay",
        Min = 0.05, Max = 2, Default = 0.2, Increment = 0.05,
        Callback = function(v) x2Delay = v end
    })

    -- LEFT: Equip Weight
    local equipSec = mainTabbox.Extras:AddSection({
        Name = "Equip Weight",
        Position = "Left",
        Icon = "lucide:dumbbell",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    equipSec:AddLabel("Select Weight"):SetStacked(true):AddDropdown({
        Flag = "SelectedEquip",
        Values = equipList,
        Default = equipList[1],
        Callback = function(val) selectedEquip = val end
    })

    equipSec:AddButton({
        Name = "Equip Selected Weight",
        Icon = "lucide:zap",
        Callback = function()
            ReplicatedStorage.Shared.Packages.Network.rev_WeightEquip:FireServer(selectedEquip)
            Window:Notify({ Title = "Equip", Content = "Equipped: " .. selectedEquip, Icon = "lucide:check" })
        end
    })

    -- RIGHT: Auto Claims & Spins
    local claimsSec = mainTabbox.Extras:AddSection({
        Name = "Auto Claims & Spins",
        Position = "Right",
        Icon = "lucide:gift",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    claimsSec:AddToggle({
        Name = "Auto Claim Free Store",
        Flag = "AutoClaimFree",
        Default = false,
        Callback = function(state)
            autoClaimFree = state
            if autoClaimFree then
                task.spawn(function()
                    local network = ReplicatedStorage.Shared.Packages.Network
                    while autoClaimFree do
                        network.rev_ClaimFree:FireServer()
                        task.wait(10)
                    end
                end)
            end
        end
    })

    claimsSec:AddToggle({
        Name = "Auto Claim Group Gift",
        Flag = "AutoGroupClaim",
        Default = false,
        Callback = function(state)
            autoGroupClaim = state
            if autoGroupClaim then
                task.spawn(function()
                    local network = ReplicatedStorage.Shared.Packages.Network
                    while autoGroupClaim do
                        network.rev_GroupClaim:FireServer()
                        task.wait(60)
                    end
                end)
            end
        end
    })



end

-- =====================================================
-- UI: FARM TAB
-- =====================================================
do
    -- LEFT: Collect
    local collectSec = farmTabbox.Collect:AddSection({
        Name = "Collect",
        Position = "Left",
        Icon = "lucide:package",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    collectSec:AddToggle({
        Name = "Auto Collect",
        Flag = "AutoCollect_Simple",
        Default = false,
        Locked = getgenv().KysHubTier ~= "Premium",
        TextLocked = "Premium Required",
        Callback = function(state)
            if state and getgenv().KysHubTier ~= "Premium" then return end
            brainrotLoop = state
            if state then
                task.spawn(function()
                    while brainrotLoop do
                        for i = 1, 30 do
                            if not brainrotLoop then break end
                            collectEvent:FireServer(i)
                            task.wait(collectDelay)
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end
    })

    collectSec:AddLabel("Collect Delay"):SetStacked(true):AddSlider({
        Flag = "CollectDelay",
        Min = 0.01, Max = 5, Default = 0.5, Increment = 0.01,
        Locked = getgenv().KysHubTier ~= "Premium",
        TextLocked = "Premium Required",
        Callback = function(v)
            if getgenv().KysHubTier ~= "Premium" then return end
            collectDelay = v
        end
    })

    collectSec:AddToggle({
        Name = "Auto Teleport Collect",
        Flag = "AutoTeleportCollect",
        Default = false,
        Callback = function(state)
            AutoCollect = state
            if AutoCollect then
                task.spawn(function()
                    while AutoCollect do
                        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                        local hrp = char:WaitForChild("HumanoidRootPart")
                        local startPos = hrp.CFrame
                        local plot = getMyPlot()
                        if plot then
                            local slots = plot:FindFirstChild("Slots")
                            if slots then
                                for _, slot in ipairs(slots:GetChildren()) do
                                    if not AutoCollect then break end
                                    local slotNumber = tonumber(string.match(slot.Name, "%d+"))
                                    if slotNumber then
                                        if slot:IsA("BasePart") then hrp.CFrame = slot.CFrame + Vector3.new(0,3,0)
                                        elseif slot:IsA("Model") then hrp.CFrame = slot:GetPivot() + Vector3.new(0,3,0) end
                                        task.wait(0.35)
                                        collectEvent:FireServer(slotNumber)
                                        task.wait(Delay)
                                    end
                                end
                            end
                        end
                        hrp.CFrame = startPos
                        task.wait(AfterDelay)
                    end
                end)
            end
        end
    })

    collectSec:AddLabel("TP Collect Delay"):SetStacked(true):AddSlider({
        Flag = "TPCollectDelay",
        Min = 0.1, Max = 2, Default = 0.5, Increment = 0.1,
        Callback = function(v) Delay = v end
    })

    collectSec:AddLabel("After Collect Delay"):SetStacked(true):AddSlider({
        Flag = "AfterCollectDelay",
        Min = 1, Max = 10, Default = 3, Increment = 1,
        Callback = function(v) AfterDelay = v end
    })

    -- RIGHT: Base
    local baseSec = farmTabbox.Base:AddSection({
        Name = "Base",
        Position = "Right",
        Icon = "lucide:tent",
        Box = true,
        BoxBorder = true,
        Opened = false,
    })

    baseSec:AddToggle({
        Name = "Instant Place Brainrot",
        Flag = "InstantPlace",
        Default = false,
        Callback = function(state)
            instantPlace = state
            if state then
                task.spawn(function()
                    while instantPlace do
                        local plots = Workspace:FindFirstChild("Plots")
                        if plots then
                            for _, prompt in ipairs(plots:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") and prompt.Name == "CustomPrompt" then
                                    prompt.HoldDuration = 0
                                end
                            end
                        end
                        task.wait(1)
                    end
                end)
            else
                local plots = Workspace:FindFirstChild("Plots")
                if plots then
                    for _, prompt in ipairs(plots:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Name == "CustomPrompt" then
                            prompt.HoldDuration = 0.5
                        end
                    end
                end
            end
        end
    })

    baseSec:AddToggle({
        Name = "Auto Place Best Brainrot",
        Flag = "AutoPlaceBest",
        Default = false,
        Locked = getgenv().KysHubTier ~= "Premium",
        TextLocked = "Premium Required",
        Callback = function(state)
            if state and getgenv().KysHubTier ~= "Premium" then return end
            autoPlaceBest = state
            if state then
                task.spawn(function()
                    while autoPlaceBest do
                        local bestTool, _ = getBestBrainrotInBackpack()
                        if not bestTool then
                            task.wait(1)
                        else
                            local interactEvent = ReplicatedStorage.Shared.Packages.Network:FindFirstChild("rev_S_Interact")
                            if not interactEvent then break end
                            
                            local plot = getOwningPlot()
                            local slotsFolder = plot and plot:FindFirstChild("Slots")
                            local totalSlots = slotsFolder and #slotsFolder:GetChildren() or 30
                            
                            local placed = false
                            for slotNum = 1, totalSlots do
                                if not autoPlaceBest then break end
                                
                                local slotObj = slotsFolder and slotsFolder:FindFirstChild("Slot" .. slotNum)
                                local isOccupied = isSlotOccupied(slotObj)
                                
                                if not isOccupied then
                                    -- Re-check we still have a tool
                                    bestTool = getBestBrainrotInBackpack()
                                    if not bestTool then break end
                                    
                                    local char = getCharacter()
                                    if char then
                                        bestTool.Parent = char
                                        task.wait(0.15)
                                        interactEvent:FireServer(slotNum)
                                        placed = true
                                        
                                        -- Wait for server replication
                                        if slotObj then
                                            local waited = 0
                                            while not isSlotOccupied(slotObj) and waited < 3 do
                                                task.wait(0.1)
                                                waited = waited + 0.1
                                            end
                                        else
                                            task.wait(1)
                                        end
                                        task.wait(0.3)
                                    end
                                    break -- go back to outer loop to get next best tool
                                end
                            end
                            
                            if not placed then
                                task.wait(2) -- all slots full, wait before retrying
                            end
                        end
                    end
                end)
            end
        end
    })

    baseSec:AddButton({
        Name = "Unplace All Brainrot",
        Callback = function()
            unequipAllTools()
            task.wait(0.1)
            local interactEvent = ReplicatedStorage.Shared.Packages.Network:FindFirstChild("rev_S_Interact")
            if interactEvent then
                for slotNum = 1, 30 do
                    interactEvent:FireServer(slotNum)
                    task.wait(0.05)
                end
            end
        end
    })

    baseSec:AddToggle({
        Name = "Auto Unplace Brainrot",
        Flag = "AutoUnplace",
        Default = false,
        Callback = function(state)
            autoUnplace = state
            if state then
                task.spawn(function()
                    while autoUnplace do
                        unequipAllTools()
                        task.wait(0.1)
                        local interactEvent = ReplicatedStorage.Shared.Packages.Network:FindFirstChild("rev_S_Interact")
                        if interactEvent then
                            for slotNum = 1, 30 do
                                if not autoUnplace then break end
                                interactEvent:FireServer(slotNum)
                                task.wait(0.05)
                            end
                        end
                        task.wait(1)
                    end
                end)
            end
        end
    })

    baseSec:AddLabel("Slot Number"):SetStacked(true):AddSlider({
        Flag = "SlotNumber",
        Min = 1, Max = 30, Default = 1, Increment = 1,
        Callback = function(v) selectedIndex = v end
    })

    baseSec:AddButton({
        Name = "Pick Up / Place",
        Icon = "lucide:hand",
        Callback = function()
            ReplicatedStorage.Shared.Packages.Network.rev_S_Interact:FireServer(selectedIndex)
        end
    })

    -- LEFT: Rebirth
    local rebirthSec = farmTabbox.Rebirth:AddSection({
        Name = "Rebirth",
        Position = "Left",
        Icon = "lucide:refresh-cw",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    rebirthSec:AddToggle({
        Name = "Auto Rebirth",
        Flag = "AutoRebirth",
        Default = false,
        Callback = function(state)
            rebirthLoop = state
            if rebirthLoop then
                task.spawn(function()
                    while rebirthLoop do
                        ReplicatedStorage.Shared.Packages.Network.rev_RebirthRequest:FireServer()
                        task.wait(1)
                    end
                end)
            end
        end
    })

    rebirthSec:AddButton({
        Name = "Rebirth",
        Icon = "lucide:refresh-cw",
        Callback = function()
            ReplicatedStorage.Shared.Packages.Network.rev_RebirthRequest:FireServer()
        end
    })

    -- RIGHT: Offline Reward
    local offlineSec = farmTabbox.Rebirth:AddSection({
        Name = "Offline Reward",
        Position = "Right",
        Icon = "lucide:gift",
        Box = true,
        BoxBorder = true,
        Opened = false,
    })

    offlineSec:AddButton({
        Name = "Claim Offline Reward",
        Icon = "lucide:gift",
        Callback = function()
            ReplicatedStorage.Shared.Packages.Network.rev_Offline_Claim:FireServer()
        end
    })

    offlineSec:AddToggle({
        Name = "Auto Claim Offline Reward",
        Flag = "AutoOfflineClaim",
        Default = false,
        Callback = function(state)
            offlineLoop = state
            if offlineLoop then
                task.spawn(function()
                    while offlineLoop do
                        ReplicatedStorage.Shared.Packages.Network.rev_Offline_Claim:FireServer()
                        task.wait(5)
                    end
                end)
            end
        end
    })
end

-- =====================================================
-- UI: EXCLUSIVE TAB
-- =====================================================
do
    -- LEFT: Dupe Weight
    local dupeSec = exclusiveTabbox.Dupe:AddSection({
        Name = "Dupe Weight",
        Position = "Left",
        Icon = "lucide:layers",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    dupeSec:AddButton({
        Name = "Dupe Weight (Once)",
        Icon = "lucide:zap",
        Callback = function() fireDupeWeightReal() end
    })

    dupeSec:AddToggle({
        Name = "Auto Dupe Weight",
        Flag = "AutoDupeWeight",
        Default = false,
        Callback = function(state)
            dupeWeightLoopExclusive = state
            if state then
                dupeCurrentInterval = dupeBaseInterval
                lastResolvedKickDataValue = getResolvedKickDataValue() or 0
                peakKickDataValue = lastResolvedKickDataValue
                task.spawn(function()
                    while dupeWeightLoopExclusive do
                        fireDupeWeightReal()
                        task.wait(dupeCurrentInterval)
                    end
                end)
            end
        end
    })




end

-- =====================================================
-- UI: SOCIAL TAB
-- =====================================================
do
    -- LEFT: Send Gift
    local giftSec = socialTabbox.Gift:AddSection({
        Name = "Send Gift",
        Position = "Left",
        Icon = "lucide:gift",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local playerList = GetPlayerList()
    if #playerList > 0 then SelectedPlayer = playerList[1] end

    giftSec:AddLabel("Target Player"):SetStacked(true):AddDropdown({
        Flag = "GiftTarget",
        Values = #playerList > 0 and playerList or {"No players"},
        Default = #playerList > 0 and playerList[1] or nil,
        AllowNil = true,
        Callback = function(val) SelectedPlayer = val end
    })

    giftSec:AddToggle({
        Name = "Auto Gift",
        Flag = "AutoGift",
        Default = false,
        Callback = function(state)
            AutoGift = state
            if AutoGift then
                task.spawn(function()
                    while AutoGift do SendGiftToTarget(); task.wait(1) end
                end)
            end
        end
    })

    giftSec:AddButton({
        Name = "Send Gift",
        Icon = "lucide:send",
        Callback = function() SendGiftToTarget() end
    })

    -- LEFT: Gift Response
    local giftResponseSec = socialTabbox.Gift:AddSection({
        Name = "Gift Response",
        Position = "Left",
        Icon = "lucide:check-circle",
        Box = true,
        BoxBorder = true,
        Opened = false,
    })

    giftResponseSec:AddButton({
        Name = "Accept Gift",
        Icon = "lucide:check",
        Callback = function()
            pcall(function()
                local r = Network:FindFirstChild("rev_myMarket_gift")
                if r then r:FireServer("accept") end
            end)
        end
    })

    giftResponseSec:AddButton({
        Name = "Reject Gift",
        Icon = "lucide:x",
        Callback = function()
            pcall(function()
                local r = Network:FindFirstChild("rev_myMarket_gift")
                if r then r:FireServer("reject") end
            end)
        end
    })

    -- RIGHT: Webhook
    local webhookSec = socialTabbox.Webhook:AddSection({
        Name = "Webhook",
        Position = "Right",
        Icon = "lucide:webhook",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    webhookSec:AddTextInput({
        Name = "Webhook URL",
        Flag = "WebhookURL",
        Default = "",
        Placeholder = "https://discord.com/api/webhooks/...",
        Type = "Textarea",
        Callback = function(val)
            WebhookURL = val or ""
        end
    })

    webhookSec:AddToggle({
        Name = "Enable Webhook",
        Flag = "WebhookEnabled",
        Default = false,
        Callback = function(state)
            webhookEnabled = state
            table.clear(sentCache)
            SendWebhook(state and "Connected" or "Disconnected")
            if state then ScanBackpack() end
        end
    })

    webhookSec:AddButton({
        Name = "Send Now",
        Icon = "lucide:send",
        Callback = function() table.clear(sentCache); SendWebhook("Manual Send") end
    })

    webhookSec:AddButton({
        Name = "Test Webhook",
        Icon = "lucide:test-tube",
        Callback = function()
            if WebhookURL == "" or not requestFunction then
                Window:Notify({ Title = "Webhook", Content = "No URL set!", Icon = "lucide:alert-circle" })
                return
            end
            pcall(function()
                requestFunction({
                    Url = WebhookURL, Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = HttpService:JSONEncode({
                        username = "KysHub",
                        embeds = {{
                            title = "KysHub | KaLB - Test",
                            color = 9699539,
                            fields = {{ name = "Status", value = "Test OK", inline = false }},
                            footer = { text = "KysHub " .. os.date("%H:%M:%S") }
                        }}
                    })
                })
            end)
            Window:Notify({ Title = "Webhook", Content = "Test sent!", Icon = "lucide:check" })
        end
    })

    -- CENTER: Backpack Monitor
    local webhookBackpackSec = socialTabbox.Monitor:AddSection({
        Name = "Backpack Monitor",
        Position = "Center",
        Icon = "lucide:backpack",
        Box = true,
        BoxBorder = true,
        Opened = false,
    })

    BackpackLabel = webhookBackpackSec:AddParagraph({
        Name = "Backpack Contents",
        Content = "Empty"
    })
end

-- =====================================================
-- UI: SHOP TAB
-- =====================================================
do
    -- RIGHT: Sell Brainrot
    local sellSec = shopTabbox.Sell:AddSection({
        Name = "Sell Brainrot",
        Position = "Right",
        Icon = "lucide:tag",
        Box = true,
        BoxBorder = true,
        Opened = false,
    })

    sellSec:AddButton({
        Name = "Sell Brainrot",
        Icon = "lucide:dollar-sign",
        Callback = function()
            ReplicatedStorage.Shared.Packages.Network.ref_B_Sell:InvokeServer()
        end
    })

    sellSec:AddButton({
        Name = "Sell All Brainrot",
        Icon = "lucide:dollar-sign",
        Callback = function()
            ReplicatedStorage.Shared.Packages.Network.ref_B_SellAll:InvokeServer()
        end
    })

    sellSec:AddToggle({
        Name = "Auto Sell Brainrot",
        Flag = "AutoSell",
        Default = false,
        Callback = function(state)
            sellLoop = state
            if sellLoop then
                task.spawn(function()
                    while sellLoop do
                        ReplicatedStorage.Shared.Packages.Network.ref_B_Sell:InvokeServer()
                        task.wait(1)
                    end
                end)
            end
        end
    })

    sellSec:AddToggle({
        Name = "Auto Sell All Brainrot",
        Flag = "AutoSellAll",
        Default = false,
        Callback = function(state)
            sellAllLoop = state
            if sellAllLoop then
                task.spawn(function()
                    while sellAllLoop do
                        ReplicatedStorage.Shared.Packages.Network.ref_B_SellAll:InvokeServer()
                        task.wait(2)
                    end
                end)
            end
        end
    })

    -- LEFT: Weight Shop
    local weightShopSec = shopTabbox.WeightSpeed:AddSection({
        Name = "Weight Shop",
        Position = "Left",
        Icon = "lucide:shopping-bag",
        Box = true,
        BoxBorder = true,
        Opened = false,
    })

    weightShopSec:AddLabel("Select Item"):SetStacked(true):AddDropdown({
        Flag = "ShopItem",
        Values = equipList,
        Default = equipList[1],
        Callback = function(val) selectedEquip = val end
    })

    weightShopSec:AddButton({
        Name = "Buy Selected Item",
        Icon = "lucide:shopping-cart",
        Callback = function()
            ReplicatedStorage.Shared.Packages.Network.rev_Shop_Buy:FireServer("WeightShop", selectedEquip)
            Window:Notify({ Title = "Shop", Content = "Bought: " .. selectedEquip, Icon = "lucide:check" })
        end
    })

    -- LEFT: Speed Shop
    local speedShopSec = shopTabbox.WeightSpeed:AddSection({
        Name = "Speed Shop",
        Position = "Left",
        Icon = "lucide:zap",
        Box = true,
        BoxBorder = true,
        Opened = false,
    })

    speedShopSec:AddLabel("Speed Level"):SetStacked(true):AddSlider({
        Flag = "SpeedLevel",
        Min = 1, Max = 11, Default = 1, Increment = 1,
        Callback = function(v) selectedSpeed = v end
    })

    speedShopSec:AddButton({
        Name = "Upgrade Speed",
        Icon = "lucide:trending-up",
        Callback = function()
            ReplicatedStorage.Shared.Packages.Network.rev_SPEED_UPGRADE:FireServer(selectedSpeed)
        end
    })

    -- RIGHT: Kick Style Shop
    local kickStyleSec = shopTabbox.KickStyle:AddSection({
        Name = "Kick Style Shop",
        Position = "Right",
        Icon = "lucide:footprints",
        Box = true,
        BoxBorder = true,
        Opened = false,
    })

    kickStyleSec:AddLabel("Select Kick Style"):SetStacked(true):AddDropdown({
        Flag = "KickStyle",
        Values = kickStyleList,
        Default = kickStyleList[1],
        Callback = function(val) selectedKickStyle = val end
    })

    kickStyleSec:AddButton({
        Name = "Buy Kick Style",
        Icon = "lucide:shopping-cart",
        Callback = function()
            ReplicatedStorage.Shared.Packages.Network.rev_Shop_Buy:FireServer("KickStyles", selectedKickStyle)
        end
    })

    kickStyleSec:AddToggle({
        Name = "Auto Buy Kick Style",
        Flag = "AutoBuyKickStyle",
        Default = false,
        Callback = function(state)
            autoBuyKickStyle = state
            if autoBuyKickStyle then
                task.spawn(function()
                    while autoBuyKickStyle do
                        ReplicatedStorage.Shared.Packages.Network.rev_Shop_Buy:FireServer("KickStyles", selectedKickStyle)
                        task.wait(1)
                    end
                end)
            end
        end
    })
end

-- =====================================================
-- UI: UPGRADE TAB
-- =====================================================
do
    -- LEFT: Upgrade Brainrot
    local upgradeBrainrotSec = upgradeTabbox.Brainrot:AddSection({
        Name = "Upgrade Brainrot",
        Position = "Left",
        Icon = "lucide:arrow-up-circle",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    upgradeBrainrotSec:AddLabel("Brainrot Slot"):SetStacked(true):AddSlider({
        Flag = "UpgradeSlot",
        Min = 1, Max = 30, Default = 1, Increment = 1,
        Callback = function(v) selectedLevel = v end
    })

    upgradeBrainrotSec:AddButton({
        Name = "Upgrade Brainrot",
        Icon = "lucide:arrow-up",
        Callback = function()
            ReplicatedStorage.Shared.Packages.Network.rev_B_Upgrade:FireServer(selectedLevel)
        end
    })

    upgradeBrainrotSec:AddToggle({
        Name = "Auto Upgrade Brainrot",
        Flag = "AutoUpgradeBrainrot",
        Default = false,
        Callback = function(state)
            upgradeLoop = state
            if upgradeLoop then
                task.spawn(function()
                    while upgradeLoop do
                        ReplicatedStorage.Shared.Packages.Network.rev_B_Upgrade:FireServer(selectedLevel)
                        task.wait(0.5)
                    end
                end)
            end
        end
    })

    -- RIGHT: Upgrade Base
    local upgradeBaseSec = upgradeTabbox.Base:AddSection({
        Name = "Upgrade Base",
        Position = "Right",
        Icon = "lucide:tent",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    upgradeBaseSec:AddButton({
        Name = "Upgrade Base",
        Icon = "lucide:arrow-up",
        Callback = function()
            ReplicatedStorage.Shared.Packages.Network.rev_bs_upgrade:FireServer()
        end
    })

    upgradeBaseSec:AddToggle({
        Name = "Auto Upgrade Base",
        Flag = "AutoUpgradeBase",
        Default = false,
        Callback = function(state)
            bsLoop = state
            if bsLoop then
                task.spawn(function()
                    while bsLoop do
                        ReplicatedStorage.Shared.Packages.Network.rev_bs_upgrade:FireServer()
                        task.wait(0.5)
                    end
                end)
            end
        end
    })

    -- RIGHT: Volcano Upgrades
    local volcanoSec = upgradeTabbox.Volcano:AddSection({
        Name = "Volcano Upgrades",
        Position = "Right",
        Icon = "lucide:flame",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    volcanoSec:AddLabel("Select Upgrades"):SetStacked(true):AddDropdown({
        Flag = "VolcanoUpgrades",
        Values = volcanoUpgradeList,
        Default = nil,
        Multi = true,
        AllowNil = true,
        Callback = function(val)
            selectedVolcanoUpgrades = val or {}
        end
    })

    volcanoSec:AddButton({
        Name = "Upgrade Selected Now",
        Icon = "lucide:zap",
        Callback = function()
            local buyEvent = Network:FindFirstChild("rev_Shop_Buy")
            if not buyEvent then return end
            for upgradeName, selected in pairs(selectedVolcanoUpgrades) do
                if selected == true then
                    pcall(function()
                        buyEvent:FireServer(upgradeName)
                    end)
                    task.wait(0.3)
                end
            end
        end
    })

    volcanoSec:AddToggle({
        Name = "Auto Upgrade Volcano",
        Flag = "AutoVolcanoUpgrade",
        Default = false,
        Callback = function(state)
            autoVolcanoUpgrade = state
            if autoVolcanoUpgrade then
                task.spawn(function()
                    local buyEvent = Network:FindFirstChild("rev_Shop_Buy")
                    while autoVolcanoUpgrade do
                        if buyEvent then
                            for upgradeName, selected in pairs(selectedVolcanoUpgrades) do
                                if selected == true and autoVolcanoUpgrade then
                                    pcall(function()
                                        buyEvent:FireServer(upgradeName)
                                    end)
                                    task.wait(0.5)
                                end
                            end
                        end
                        task.wait(1)
                    end
                end)
            end
        end
    })
end

-- =====================================================
-- UI: EVENTS TAB
-- =====================================================
do
    local sniperSec = exclusiveTabbox.Sniper:AddSection({
        Name = "Event Snipers",
        Position = "Left",
        Icon = "lucide:crosshair",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    sniperSec:AddToggle({
        Name = "Auto Snipe Meteors (Aimbot)",
        Flag = "AutoMeteor",
        Default = false,
        Locked = getgenv().KysHubTier ~= "Premium",
        TextLocked = "Premium Required",
        Callback = function(state)
            if state and getgenv().KysHubTier ~= "Premium" then return end
            AutoMeteor = state
        end
    })

    sniperSec:AddToggle({
        Name = "Auto Hit Piñata",
        Flag = "AutoPinata",
        Default = false,
        Callback = function(state)
            autoPinata = state
            if autoPinata then
                task.spawn(function()
                    while autoPinata do
                        pcall(function()
                            local debris = workspace:FindFirstChild("Debris")
                            local pinata = debris and debris:FindFirstChild("Giant Piñata")
                            if pinata then
                                local hitEvent = Network:FindFirstChild("rev_PiniataHit")
                                if hitEvent then hitEvent:FireServer() end
                            end
                        end)
                        task.wait(0.25)
                    end
                end)
            end
        end
    })

    sniperSec:AddToggle({
        Name = "Auto Press Red Button",
        Flag = "AutoRedButton",
        Default = false,
        Callback = function(state)
            autoRedButton = state
            if autoRedButton then
                task.spawn(function()
                    while autoRedButton do
                        pcall(function()
                            for _, btn in pairs(game:GetService("CollectionService"):GetTagged("RedButton")) do
                                local b = btn:FindFirstChild("Button")
                                if b and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    if firetouchinterest then
                                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, b, 0)
                                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, b, 1)
                                    else
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = b.CFrame
                                    end
                                end
                            end
                        end)
                        task.wait(1)
                    end
                end)
            end
        end
    })

    sniperSec:AddToggle({
        Name = "Auto Mighty Chest",
        Flag = "AutoMightyChest",
        Default = false,
        Callback = function(state)
            autoMightyChest = state
            if autoMightyChest then
                task.spawn(function()
                    while autoMightyChest do
                        pcall(function()
                            local chestFound = false
                            local debris = workspace:FindFirstChild("Debris")
                            if debris then
                                for _, v in pairs(debris:GetChildren()) do
                                    if v.Name == "MightyChest" then
                                        chestFound = true
                                        break
                                    end
                                end
                            end
                            if chestFound then
                                local chestEvent = Network:FindFirstChild("rev_mightyChest")
                                if chestEvent then chestEvent:FireServer() end
                            end
                        end)
                        task.wait(1)
                    end
                end)
            end
        end
    })
end

-- =====================================================
-- UI: PLAYER TAB
-- =====================================================
do
    -- LEFT: Local Player
    local localPlayerSec = playerTabbox.Player:AddSection({
        Name = "Local Player",
        Position = "Left",
        Icon = "lucide:person-standing",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    localPlayerSec:AddLabel("Walk Speed"):SetStacked(true):AddSlider({
        Flag = "WalkSpeed",
        Min = 0, Max = 200, Default = 16, Increment = 1,
        Callback = function(v)
            currentWalk = v
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = v end
        end
    })

    localPlayerSec:AddLabel("Jump Power"):SetStacked(true):AddSlider({
        Flag = "JumpPower",
        Min = 0, Max = 300, Default = 50, Increment = 1,
        Callback = function(v)
            currentJump = v
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = v end
        end
    })

    localPlayerSec:AddButton({
        Name = "Reset Default",
        Icon = "lucide:rotate-ccw",
        Callback = function()
            currentWalk = defaultWalk; currentJump = defaultJump
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = defaultWalk
                char.Humanoid.JumpPower = defaultJump
            end
        end
    })


    -- RIGHT: Misc
    local miscSec = playerTabbox.Misc:AddSection({
        Name = "Misc",
        Position = "Right",
        Icon = "lucide:package",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    miscSec:AddButton({
        Name = "FPS Boost",
        Icon = "lucide:gauge",
        Callback = function()
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.Plastic; v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
            end
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end
    })

    miscSec:AddToggle({
        Name = "Anti AFK",
        Flag = "AntiAFK",
        Default = false,
        Callback = function(state)
            antiAFK = state
            if antiAFK then
                local vu = game:GetService("VirtualUser")
                afkConnection = LocalPlayer.Idled:Connect(function()
                    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            else
                if afkConnection then afkConnection:Disconnect(); afkConnection = nil end
            end
        end
    })

    miscSec:AddToggle({
        Name = "Auto Reconnect",
        Flag = "AutoReconnect",
        Default = false,
        Callback = function(state)
            autoReconnect = state
            if autoReconnect then
                local ts = game:GetService("TeleportService")
                game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
                    if autoReconnect and child.Name == "ErrorPrompt" then
                        task.wait(2); ts:Teleport(game.PlaceId, LocalPlayer)
                    end
                end)
            end
        end
    })

    miscSec:AddButton({
        Name = "Rejoin",
        Icon = "lucide:log-in",
        Callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end
    })

    miscSec:AddButton({
        Name = "Server Hop",
        Icon = "lucide:shuffle",
        Callback = function()
            local ts = game:GetService("TeleportService")
            local placeId = game.PlaceId
            pcall(function()
                local servers = HttpService:JSONDecode(
                    game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
                )
                for _, v in pairs(servers.data) do
                    if v.playing < v.maxPlayers then
                        ts:TeleportToPlaceInstance(placeId, v.id, LocalPlayer); break
                    end
                end
            end)
        end
    })
    -- CENTER: Movement
    local moveSec = playerTabbox.Movement:AddSection({
        Name = "Movement",
        Position = "Center",
        Icon = "lucide:move",
        Box = true,
        BoxBorder = true,
        Opened = false,
    })

    moveSec:AddToggle({
        Name = "Infinite Jump",
        Flag = "InfiniteJump",
        Default = false,
        Callback = function(state) infJump = state end
    })

    moveSec:AddToggle({
        Name = "Noclip",
        Flag = "Noclip",
        Default = false,
        Callback = function(state) noclip = state end
    })
end

-- =====================================================
-- RUNTIME LOOPS
-- =====================================================
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

game:GetService("RunService").Stepped:Connect(function()
    if noclip then
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.spawn(SetupBackpackConnections)
end)
task.spawn(SetupBackpackConnections)
UpdateBackpackUI()

Window:Notify({
    Title = "KysHub crack",
    Content = "Kick A Lucky Block " .. version .. " loaded!",
    Icon = "lucide:check-circle",
    Duration = 4
})

local function blockPremium()
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
end
task.spawn(blockPremium)
