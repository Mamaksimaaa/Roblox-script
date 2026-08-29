local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local supportedMaps = {["121864768012064"] = "Fish it"}
local success, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
local mapName = success and info.Name or "Unknown"
local isSupported = supportedMaps[tostring(game.PlaceId)] ~= nil
local WindUI = {}
local ModernV2 = nil
local MenuIcon = nil
local Window = nil

local windLoadOk, windLoadErr = pcall(function()
    local ok, result = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/Kys-lol/KysHubNewUI/refs/heads/main/MainV2.lua")
    if not ok or not result then error("HttpGet gagal: " .. tostring(result)) end
    local fn, err = loadstring(result)
    if not fn then error("loadstring gagal: " .. tostring(err)) end
    ModernV2 = fn()
end)

if not windLoadOk or not ModernV2 then
    warn("[KysHub] CRITICAL: ModernV2 failed to load: " .. tostring(windLoadErr))
    local emergencyGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local emergencyLabel = Instance.new("TextLabel", emergencyGui)
    emergencyLabel.Size = UDim2.new(1, 0, 0, 60)
    emergencyLabel.Position = UDim2.new(0, 0, 0, 0)
    emergencyLabel.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    emergencyLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    emergencyLabel.Text = "[KysHub] ModernV2 failed to load.\nError: " .. tostring(windLoadErr):sub(1, 100)
    emergencyLabel.TextWrapped = true
    emergencyLabel.Font = Enum.Font.GothamBold
    emergencyLabel.TextSize = 14
    return
end

-- TEMA KysHub PURPLE
pcall(function()
    ModernV2:AddTheme({
        Name        = "KysHub red",
        Accent      = Color3.fromRGB(255, 0, 0),
        Background  = Color3.fromRGB(8, 8, 13),
        Surface     = Color3.fromRGB(20, 22, 27),
        Outline     = Color3.fromRGB(45, 48, 58),
        Text        = Color3.fromRGB(255, 255, 255),
        Placeholder = Color3.fromRGB(140, 140, 155),
        Button      = Color3.fromRGB(255, 0, 0),
        Icon        = Color3.fromRGB(255, 255, 255),
    })
end)

-- MENU ICON
pcall(function()
    MenuIcon = ModernV2:CreateMenuIcon({
        Image = "rbxassetid://80891639562743", Size = 48,
        IconColor = Color3.fromRGB(255, 255, 255), BGColor = Color3.fromRGB(20, 22, 27),
        StrokeColor = Color3.fromRGB(255, 0, 0), StrokeThick = 1.5, Draggable = true,
    })
end)

-- Emulators removed, calling ModernV2 directly


local winOk, winErr = pcall(function()
    Window = ModernV2:Window({
        Title = "KysHub crack", Content = "Fish It v1.2",
        Image = "80891639562743", Color = Color3.fromRGB(255, 0, 0),
        Uitransparent = 0.15, ShowUser = true, Search = true, ConfigEnabled = true,
        NotifyOnCallbackError = false, LoadingScreen = false, Enable3DRenderer = false,
        Keybind = "RightControl", Size = UDim2.fromOffset(540, 340),
        Config = {
            ConfigFolder = "KysHubFishIt", AutoSaveFile = "fish-it",
            AutoSave = true, AutoLoad = true, Overwrite = true,
            Format = "JSON", ShowAutoSaveToggle = true, TextGradient = true
        },
    })
    
    if MenuIcon then
        Window:AttachMenuIcon(MenuIcon)
    end
    
    Window:SetAccount({
        Username = game:GetService("Players").LocalPlayer.DisplayName,
        Profile = ModernV2.UserProfile,
        Expires = "cracked by @inlawry",
    })
    
    Window:CreateHomeTab({
        Name = "Dashboard", Icon = "lucide:layout-dashboard",
        Content = "KysHub crack by inlawry Fish It Script",
        DiscordInvite = "",
        SupportedExecutors = {"Delta","Synapse X","Krnl","Codex","Arceus X"},
        UnsupportedExecutors = {"Roblox Studio"},
        Segments = {
            Details = { Text = "Details", Icon = "lucide:layout-grid", Show = true },
            Script = { Text = "Script Logs", Icon = "lucide:code", Show = true },
            UI = { Text = "UI Logs", Icon = "lucide:file-text", Show = true }
        },
        Changelog = {
            {Title="Fish It v1.2", Date="v1.2", Description="Removed Trade tab and trade automation, added Teleport to NPC."},
            {Title="Fish It v1.1", Date="v1.1", Description="Fixed Clean Screen error spam, Removed broken Rename Pet & Cosmetics Quick Equip."},
            {Title="Fish It v1.0", Date="v1.0", Description="New Auto Crafting GUI dropdown, fixed Rarity Webhook, fixed Auto/Instant Craft bugs."},
            {Title="Fish It v0.5", Date="v0.5", Description="Improvement Features."},
        },
    })
end)

if not winOk or not Window then
    warn("[KysHub] Window creation failed: " .. tostring(winErr))
    return
end

-- Tag ignored

local function SafeCreate(creationFunc, errorPrefix)
    local ok, result = pcall(creationFunc)
    if not ok then warn("[KysHub] " .. (errorPrefix or "UI Error") .. ": " .. tostring(result)); return nil end
    return result
end
-- TABS
local function cleanDropdownValues(vals)
    if type(vals) ~= "table" then return vals end
    local clean = {}
    for _, v in ipairs(vals) do
        if type(v) == "table" and v.Title then
            table.insert(clean, v.Title)
        else
            table.insert(clean, tostring(v))
        end
    end
    return clean
end

local function cleanDefaultValue(val)
    if type(val) == "table" and val.Title then
        return val.Title
    elseif type(val) == "table" then
        local list = {}
        for k, v in pairs(val) do
            if type(v) == "table" and v.Title then
                table.insert(list, v.Title)
            else
                table.insert(list, tostring(k))
            end
        end
        return list
    end
    return val
end

local function wrapDropdownCallback(cb, multi)
    return function(val)
        if multi then
            local originalVal = {}
            if type(val) == "table" then
                for opt, selected in pairs(val) do
                    if selected then
                        table.insert(originalVal, { Title = opt })
                    end
                end
            else
                table.insert(originalVal, { Title = tostring(val) })
            end
            cb(originalVal)
        else
            cb({ Title = tostring(val) })
        end
    end
end

function WindUI:Notify(config)
    pcall(function()
        if not Window or not Window.Notify then return end
        local icon = config.Icon or "lucide:bell"
        if type(icon) == "string" and not string.find(icon, ":") then
            icon = "lucide:" .. icon
        end
        Window:Notify({
            Title = config.Title or "Notification",
            Content = config.Content or "",
            Duration = config.Duration or 3,
            Icon = icon
        })
    end)
end

local PlayersTab_Tabbox1, PlayersTab_Tabbox2, PlayersTab_Tabbox3, PlayersTab_Tabbox4, PlayersTab_Tabbox5
local MainTab_Tabbox1, MainTab_Tabbox2, MainTab_Tabbox3, MainTab_Tabbox4, MainTab_Tabbox5
local ExclusiveTab_Tabbox1, ExclusiveTab_Tabbox2, ExclusiveTab_Tabbox3, ExclusiveTab_Tabbox4, ExclusiveTab_Tabbox5
local CraftAbilityTab_Tabbox1, CraftAbilityTab_Tabbox2, CraftAbilityTab_Tabbox3, CraftAbilityTab_Tabbox4, CraftAbilityTab_Tabbox5
local AquariumTab_Tabbox1, AquariumTab_Tabbox2, AquariumTab_Tabbox3, AquariumTab_Tabbox4, AquariumTab_Tabbox5
local TeleportTab_Tabbox1, TeleportTab_Tabbox2, TeleportTab_Tabbox3, TeleportTab_Tabbox4, TeleportTab_Tabbox5
local ShopTab_Tabbox1, ShopTab_Tabbox2, ShopTab_Tabbox3, ShopTab_Tabbox4, ShopTab_Tabbox5
local EventTab_Tabbox1, EventTab_Tabbox2, EventTab_Tabbox3, EventTab_Tabbox4, EventTab_Tabbox5
local MiscTab_Tabbox1, MiscTab_Tabbox2, MiscTab_Tabbox3, MiscTab_Tabbox4, MiscTab_Tabbox5
local PlayersTab   = SafeCreate(function() return Window:AddTab({ Name = "Player", Title = "Player", Icon = "lucide:user", Border = true, Columns = true, Single = true })          end, "PlayersTab")
local MainTab      = SafeCreate(function() return Window:AddTab({ Name = "Automaly", Title = "Automaly", Icon = "lucide:settings", Border = true, Columns = true, Single = true })           end, "MainTab")
local ExclusiveTab = SafeCreate(function() return Window:AddTab({ Name = "Auto Fishing", Title = "Auto Fishing", Icon = "lucide:fish", Border = true, Columns = true, Single = true })         end, "ExclusiveTab")
local CraftAbilityTab = SafeCreate(function() return Window:AddTab({ Name = "Craft", Title = "Craft", Icon = "lucide:hammer", Border = true, Columns = true, Single = true }) end, "CraftAbilityTab")
local AquariumTab  = SafeCreate(function() return Window:AddTab({ Name = "Aquarium", Title = "Aquarium", Icon = "lucide:waves", Border = true, Columns = true, Single = true })     end, "AquariumTab")
local TeleportTab  = SafeCreate(function() return Window:AddTab({ Name = "Teleport", Title = "Teleport", Icon = "lucide:map-pin", Border = true, Columns = true, Single = true })      end, "TeleportTab")
local ShopTab      = SafeCreate(function() return Window:AddTab({ Name = "Shop", Title = "Shop", Icon = "lucide:shopping-cart", Border = true, Columns = true, Single = true }) end, "ShopTab")
local EventTab     = SafeCreate(function() return Window:AddTab({ Name = "Event", Title = "Event", Icon = "lucide:calendar", Border = true, Columns = true, Single = true })     end, "EventTab")
local MiscTab      = SafeCreate(function() return Window:AddTab({ Name = "Misc", Title = "Misc", Icon = "lucide:menu", Border = true, Columns = true, Single = true })     end, "MiscTab")
-- SERVICES
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")
local Stats             = game:GetService("Stats")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local CoreGui           = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer       = Players.LocalPlayer
local isMobile          = UserInputService.TouchEnabled

local function NotifySuccess(title, text)
    pcall(function() if Window and Window.Notify then Window:Notify({ Title = "[OK] "   .. title, Content = text, Duration = 3, Icon = "lucide:check-circle" }) end end)
end
local function NotifyWarning(title, text)
    pcall(function() if Window and Window.Notify then Window:Notify({ Title = "[WARN] " .. title, Content = text, Duration = 3, Icon = "lucide:triangle-alert" }) end end)
end
local function NotifyError(title, text)
    pcall(function() if Window and Window.Notify then Window:Notify({ Title = "[ERR] "  .. title, Content = text, Duration = 3, Icon = "lucide:circle-x" }) end end)
end
local function NotifyInfo(title, text)
    pcall(function() if Window and Window.Notify then Window:Notify({ Title = "[INFO] " .. title, Content = text, Duration = 3, Icon = "lucide:info" }) end end)
end

local cloneref = (cloneref or clonereference or function(i) return i end)
local net
pcall(function()
    net = ReplicatedStorage:WaitForChild("Packages", 10)
        :WaitForChild("_Index", 10)
        :WaitForChild("sleitnick_net@0.2.0", 10)
        :WaitForChild("net", 10)
end)
if net then pcall(function() print("[QH] Remotes: " .. #net:GetChildren()) end) end

local function GetServerRemote(targetName)
    if not net then return nil end
    local allRemotes = net:GetChildren()
    for i, remote in ipairs(allRemotes) do
        if remote.Name == targetName then
            if allRemotes[i + 1] then return allRemotes[i + 1] end
        end
    end
    return nil
end

local function GetServerRemoteReverse(targetName)
    if not net then return nil end
    local allRemotes = net:GetChildren()
    for i, remote in ipairs(allRemotes) do
        if remote.Name == targetName then
            if allRemotes[i - 1] then return allRemotes[i - 1] end
        end
    end
    return nil
end

local function CallRemote(remote, ...)
    if not remote then return false end
    local ok = false
    if remote:IsA("RemoteFunction") then
        ok = pcall(function(...) remote:InvokeServer(...) end, ...)
    elseif remote:IsA("RemoteEvent") then
        ok = pcall(function(...) remote:FireServer(...) end, ...)
    end
    return ok
end
-- PING MONITOR
local PingMonitor = {History={}, MaxSamples=10, CurrentPing=50, AveragePing=50, Jitter=0, LastSample=tick()}
function PingMonitor:GetPing()
    local networkStats = Stats:FindFirstChild("Network")
    if networkStats and networkStats:FindFirstChild("ServerStatsItem") then
        local pingData = networkStats.ServerStatsItem:FindFirstChild("Data Ping")
        if pingData then local val = pingData:GetValue(); if val then return math.floor(val) end end
    end
    return 50
end
function PingMonitor:Update()
    local now = tick()
    if now - self.LastSample < 0.5 then return end
    self.LastSample = now
    local currentPing = self:GetPing()
    self.CurrentPing = currentPing
    table.insert(self.History, currentPing)
    if #self.History > self.MaxSamples then table.remove(self.History, 1) end
    local total, minP, maxP = 0, math.huge, 0
    for _, p in ipairs(self.History) do
        total = total + p
        if p < minP then minP = p end
        if p > maxP then maxP = p end
    end
    self.AveragePing = math.floor(total / #self.History)
    self.Jitter = maxP - minP
end
function PingMonitor:IsStable() return self.Jitter < 30 and self.AveragePing < 150 end
-- PLAYER DATA
local Replion, PlayerData, ItemUtility, TierUtility
local Controllers = {}
pcall(function()
    Replion = require(ReplicatedStorage.Packages.Replion)
    PlayerData = Replion.Client:WaitReplion("Data")
    ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
    TierUtility = require(ReplicatedStorage:WaitForChild("Shared", 5):WaitForChild("TierUtility", 5))
end)

if isMobile then
    pcall(function()
        local ctrl = ReplicatedStorage:WaitForChild("Controllers", 5)
        if ctrl then
            local notifCtrl = ctrl:FindFirstChild("NotificationController")
            if notifCtrl then Controllers.Notification = require(notifCtrl) end
            local vfxCtrl = ctrl:FindFirstChild("VFXController")
            if vfxCtrl then Controllers.VFX = require(vfxCtrl) end
            local cutCtrl = ctrl:FindFirstChild("CutsceneController")
            if cutCtrl then Controllers.Cutscene = require(cutCtrl) end
            local fishCtrl = ctrl:FindFirstChild("FishingController")
            if fishCtrl then Controllers.Fishing = require(fishCtrl) end
            local backCtrl = ctrl:FindFirstChild("BackpackController")
            if backCtrl then Controllers.Backpack = require(backCtrl) end
        end
    end)
end

local origPlaySmallItemObtained
pcall(function()
    if isMobile and Controllers.Notification and Controllers.Notification.PlaySmallItemObtained then
        origPlaySmallItemObtained = Controllers.Notification.PlaySmallItemObtained
    end
end)
-- LOAD REMOTES (FIXED + BARU)
local Events = {}
local function loadRemotes()
    local loaded, failed = 0, 0
    local remoteList = {
-- FISHING CORE
        {key="equip",                   name="RE/EquipToolFromHotbar"},
        {key="unequip",                 name="RE/UnequipToolFromHotbar"},
        {key="equipItem",               name="RE/EquipItem"},
        {key="CancelFishing",           name="RF/CancelFishingInputs"},
        {key="charge",                  name="RF/ChargeFishingRod"},
        {key="minigame",                name="RF/RequestFishingMinigameStarted"},
        {key="UpdateAutoFishing",       name="RF/UpdateAutoFishingState"},
        {key="fishing",                 name="RF/CatchFishCompleted"},
        {key="fishingRE",               name="RE/CatchFishCompleted"},
        {key="exclaimEvent",            name="RE/ReplicateTextEffect"},
        {key="sell",                    name="RF/SellAllItems"},
        {key="SellItem",                name="RF/SellItem"},
        {key="favorite",                name="RE/FavoriteItem"},
        -- Tambah di bagian FISHING CORE
        {key="CaughtFishVisual",  name="RE/CaughtFishVisual"},
        {key="FishCaughtRE",      name="RE/FishCaught"},
-- TOTEM & NOTIF
        {key="SpawnTotem",              name="RE/SpawnTotem"},
        {key="TextNotification",        name="RE/TextNotification"},
        {key="fishNotif",               name="RE/ObtainedNewFishNotification"},
        {key="systemMessage",           name="RE/DisplaySystemMessage"},
-- ENCHANT
        {key="activateAltar",           name="RE/ActivateEnchantingAltar"},
        {key="activateAltar2",          name="RE/ActivateEnchantingAltar2"},
        {key="equipItemRemote",         name="RE/EquipItem"},
        {key="equipToolRemote",         name="RE/EquipToolFromHotbar"},
-- CAVE & EVENTS
        {key="searchItemPickedUp",      name="RF/SearchItemPickedUp"},
        {key="gainAccessToMaze",        name="RE/GainAccessToMaze"},
        {key="claimPirateChest",        name="RE/ClaimPirateChest"},
-- WEATHER & CRYSTAL
        {key="BuyWeather",              name="RF/PurchaseWeatherEvent"},
        {key="ConsumeCaveCrystal",      name="RF/ConsumeCaveCrystal"},
-- ATLANTIS (FIX)
        {key="SacrificeAtlantisFish",   name="RF/SacrificeAtlantisFish"},
        {key="SacrificeAtlantisSellAll",name="RF/SacrificeAtlantisSellAll"},
-- CLASSIC MACHINE
        {key="ClassicMachineActivate",  name="RF/ClassicMachineActivate"},
-- MISC REMOTES
        {key="ConsumePotion",           name="RF/ConsumePotion"},
        {key="ClaimDailyLogin",         name="RF/ClaimDailyLogin"},
        {key="RedeemCode",              name="RF/RedeemCode"},
        {key="ClaimBounty",             name="RF/ClaimBounty"},
        {key="RequestSpin",             name="RF/RequestSpin"},
        {key="ServerHop",               name="RE/ServerHop"},
        {key="ReconnectPlayer",         name="RE/ReconnectPlayer"},
        {key="TradePlazaTeleport",      name="RE/TradePlazaTeleport"},
        {key="UpdateAutoSellThreshold", name="RF/UpdateAutoSellThreshold"},
        {key="UpdateFishingRadar",      name="RF/UpdateFishingRadar"},
-- CRAFTING (BARU)
        {key="StartCrafting",           name="RF/StartCrafting"},
        {key="ConfirmCrafting",         name="RF/ConfirmCrafting"},
        {key="CancelCrafting",          name="RF/CancelCrafting"},
        {key="InstantCraft",            name="RE/InstantCraft"},
        {key="GetDrops",                name="RF/GetDrops"},
        {key="RenderDrop",              name="RE/RenderDrop"},
        {key="DestroyDrop",             name="RE/DestroyDrop"},
        {key="DestroyAllDrops",         name="RE/DestroyAllDrops"},
-- AQUARIUM (BARU)
        {key="AquariumGetState",        name="RF/AquariumGetState"},
        {key="AquariumGetDirectory",    name="RF/AquariumGetDirectory"},
        {key="AquariumSetPublic",       name="RF/AquariumSetPublic"},
        {key="AquariumLike",            name="RF/AquariumLike"},
        {key="AquariumUnlockZone",      name="RF/AquariumUnlockZone"},
        {key="AquariumUnlockTank",      name="RF/AquariumUnlockTank"},
        {key="AquariumSetTankFish",     name="RF/AquariumSetTankFish"},
        {key="AquariumRemoveTankFish",  name="RF/AquariumRemoveTankFish"},
        {key="AquariumStateUpdated",    name="RE/AquariumStateUpdated"},
-- PETS & EGGS (NO MACHINE)
        {key="PetEquip",              name="RF/Pets/Equip"},
        {key="PetUnequip",            name="RF/Pets/Unequip"},
        {key="PetRename",             name="RF/Pets/Rename"},
        {key="OpenEgg",               name="RF/Pets/OpenEgg"},
        {key="StartEgg",              name="RF/Pets/StartEgg"},
        {key="OpenReadyEgg",          name="RF/Pets/OpenReadyEgg"},
        {key="InstantHatch",          name="RF/Pets/InstantHatch"},
        {key="PurchaseEgg",           name="RF/Pets/PurchaseEgg"},
-- PERCENTILE REWARD (BARU)
        {key="ClaimPercentileReward",   name="RF/ClaimPercentileReward"},
-- EGG MACHINE
        {key="ExchangeEggMachine",      name="RF/ExchangeEggMachine"},
        {key="ActivateEggMachineEgg",   name="RF/ActivateEggMachineEgg"},
-- PLAYER DATA
        {key="GetPlayerData",           name="RF/GetPlayerData"},
-- MEGALODON QUEST
        {key="ClaimMegalodonQuest",     name="RF/RF_ClaimMegalodonQuest"},
-- New
{key="FishingMinigameChanged",  name="RE/FishingMinigameChanged"}, -- event timing fix
{key="MarkAutoFishingUsed",     name="RF/MarkAutoFishingUsed"},
{key="FishingStopped",          name="RE/FishingStopped"},
{key="UpdateChargeState",       name="RE/UpdateChargeState"},
-- Boat System
{key="SpawnBoat",               name="RF/SpawnBoat"},
{key="DespawnBoat",             name="RF/DespawnBoat"},
{key="PurchaseBoat",            name="RF/PurchaseBoat"},
{key="BoatTeleport",            name="RE/BoatTeleport"},
-- Ability System 
{key="RequestAbilityRoll",      name="RF/RequestAbilityRoll"},
{key="ConvertAbilityShards",    name="RF/ConvertAbilityShards"},
{key="ClaimAbilityReward",      name="RF/ClaimAbilityRewardProgress"},
{key="EquipAbility",            name="RE/EquipAbility"},
{key="UnequipAbility",          name="RE/UnequipAbility"},
-- Oxygen & Submarine
{key="EquipOxygenTank",         name="RF/EquipOxygenTank"},
{key="UnequipOxygenTank",       name="RF/UnequipOxygenTank"},
{key="TriggerSubmarine",        name="RE/TriggerSubmarine"},
{key="SubmarineTP2",            name="RF/SubmarineTP2"},
-- Transcended Stone & Enchant
{key="CreateTranscendedStone",  name="RF/CreateTranscendedStone"},
{key="ActivateSecondAltar",     name="RE/ActivateSecondEnchantingAltar"},
{key="UpdateEnchantState",      name="RE/UpdateEnchantState"},
{key="RollEnchant",             name="RE/RollEnchant"},
-- Rod Crafting Minigame
{key="StartRodCraft",           name="RF/StartRodCraftingMinigame"},
{key="RodCraftClick",           name="RF/RodCraftingMinigameClick"},
{key="FinishRodCraft",          name="RF/FinishRodCraftingMinigame"},
{key="CancelRodCraft",          name="RF/CancelRodCraftingMinigame"},
{key="PlayRodCraft",            name="RE/PlayRodCraftingMinigame"},
{key="InstantCraftRE",          name="RE/InstantCraft"},
-- Cosmetics
{key="EquipCharm",              name="RE/EquipCharm"},
{key="UnequipCharm",            name="RE/UnequipCharm"},
{key="EquipRodSkin",            name="RE/EquipRodSkin"},
{key="EquipBaitSkin",           name="RE/EquipBaitSkin"},
{key="EquipLantern",            name="RE/EquipLantern"},
{key="EquipHalo",               name="RE/EquipHalo"},
{key="ChangeHaloColor",         name="RE/ChangeHaloColor"},
-- Luck
{key="ActivateExistingLuck",    name="RE/ActivateExistingLuck"},
{key="ClaimRelic",              name="RE/ClaimRelic"},
{key="ConsumeItem",             name="RF/ConsumeItem"},
{key="PetsCaughtFishVisual",    name="RE/Pets/CaughtFishVisual"},
{key="PurchaseMarketItem",      name="RF/PurchaseMarketItem"},
    }
    for _, r in ipairs(remoteList) do
        local remote = GetServerRemote(r.name)
        Events[r.key] = remote
        if remote then loaded = loaded + 1
        else failed = failed + 1; warn("[KysHub] Remote gagal: " .. r.name) end
    end
    print("[KysHub] Loaded: " .. loaded .. " | Failed: " .. failed)
    return loaded, failed
end
local loadedCount, failedCount = loadRemotes()
-- CONFIG
local Config = {
    AutoCatch = false, CatchDelay = 0.7,
    UB = {Active = false, Settings = {CompleteDelay = 2.798, CancelDelay = 0.3}, Remotes = {}, Stats = {castCount = 0, startTime = 0.0}},
    amblatant = false, antiOKOK = false, autoFishing = false,
    AutoSellState = false, AutoSellMethod = "Delay", AutoSellValue = 50,
    AutoFavoriteState = false, AutoUnfavoriteState = false,
    SelectedRarities = {}, SelectedMutations = {},
    AutoTotem = false, SelectedTotemID = 0,
    CustomWebhook = false, CustomWebhookUrl = "", WebhookRarities = {},
    DisableAnimations = false, HookNotif = false,
    DisableObtained = false, DisablePopUp = false,
    WalkOnWater = false, HideNametag = false,
    SelectedEmote = "",
    AutoEvent = false, NotifDelay = 0.1,
    NotifCount = 1, UBNotifDurationMult = 2.0,
    CatchQuality = "Perfect",

    AutoSpin = false,
    AutoConsumePotion = false,
    AutoClaimBounty = false,
    FishingRadar = false,
-- BARU
    AutoCrafting = false,
    InstantCraftEnabled = false,
    -- Crafting config
    SelectedCraftRecipe = nil,
    CraftingDelay = 1.5,
    -- Ability config
    DropCollectRadius = 50,
    -- Aquarium config
    AquariumAutoFill = false,
    AquariumAutoPublic = false,
    autoForgotten = false,
    autoSecret = false,
    -- Quantum Max (YTTA) Config
    YTTA = {
        Active = false, 
        Settings = {KysHubDelay = 0.3}, 
        NotifCount = 3, 
        NotifDelay = 0.1,
        -- FIXED: Rainbow/Golden/Fish counter per visual catch
        RainbowCounter = 0,
        GoldenCounter = 0,
        FishCounter = 0,
        -- FIXED: Visual rotation system for varied notifications
        VisualRotationIndex = 0,
        -- FIXED: Force unique notif per catch (no doubling)
        ForceSeparateNotif = true,
    },
}

_G.QHBetaAnimSpeed = false
pcall(function()
-- MULTI-INSTANCE SUPPORT (untuk 2x script execution)
local _instanceId = math.random(1, 999999)
local _logPrefix = "[KysHub_" .. _instanceId .. "]"

local Tasks = {}
local needCast = true
local skip = false
local isCaught = false
local lastTimeFishCaught = nil
local blatantFishCycleCount = 1
local saveCount = 0
local lastValidFishCaught = {}
local lastValidCaughtVisual = {}
local lastValidFishNotif = {}
local lastValidCaughtVisualHistory = {} -- Track visual history untuk rotasi
local _hookedRemotes = {}
local _catchHistory = {}
local _lastCatchTimestamps = {}
local _sessionCatchCount = 0
local _sessionStartTime = tick()
local rainbowCount = 0
local goldenCount = 0
local fishCount = 0
local _lastVisualIndex = 0 -- Track current visual index untuk rotasi
-- FISH NOTIF HISTORY (untuk varied notif, tidak kembar)
local _fishNotifHistory = {}
local _maxFishHistory = 10
-- REPLION HOOK (RAINBOW/GOLDEN) - FIXED VERSION
-- FIXED: Counter nambah +1 PER catch visual, tidak stuck
pcall(function()
    local replionFolder = ReplicatedStorage:FindFirstChild("Packages")
    if not replionFolder then return end
    local idx = replionFolder:FindFirstChild("_Index")
    if not idx then return end
    local replionMod
    for _, child in ipairs(idx:GetChildren()) do
        if child.Name:find("ytrev_replion") then
            replionMod = child:FindFirstChild("replion"); break
        end
    end
    if not replionMod then return end
    local remotes = replionMod:FindFirstChild("Remotes")
    if not remotes then return end
    local Event = remotes:FindFirstChild("Set")
    if not Event then return end

    -- FIXED: Counter lokal yang nambah PER catch visual
    local _visualRainbowCount = 0
    local _visualGoldenCount = 0
    local _visualFishCount = 0

    for _, Connection in getconnections(Event.OnClientEvent) do
        local old; old = hookfunction(Connection.Function, function(...)
            local Args = {...}

            if type(Args[2]) == "table" then
                local category = Args[2][1]
                local subCategory = Args[2][2]

                -- FIXED: Setiap kali dipanggil, counter nambah 1 (tidak stuck)
                if category == "Modifiers" and subCategory == "Rainbow" then
                    _visualRainbowCount = _visualRainbowCount + 1
                    if _visualRainbowCount > 999 then _visualRainbowCount = 0 end
                    Config.YTTA.RainbowCounter = _visualRainbowCount
                    old(Args[1], Args[2], _visualRainbowCount)
                    isCaught = true
                    return

                elseif category == "Modifiers" and subCategory == "Golden" then
                    _visualGoldenCount = _visualGoldenCount + 1
                    if _visualGoldenCount > 999 then _visualGoldenCount = 0 end
                    Config.YTTA.GoldenCounter = _visualGoldenCount
                    old(Args[1], Args[2], _visualGoldenCount)
                    isCaught = true
                    return

                elseif category == "InventoryNotifications" and subCategory == "Fish" then
                    _visualFishCount = _visualFishCount + 1
                    if _visualFishCount > 9999 then _visualFishCount = 0 end
                    Config.YTTA.FishCounter = _visualFishCount
                    old(Args[1], Args[2], _visualFishCount)
                    isCaught = true
                    return
                end
            end

            return old(...)
        end)
    end
end)

-- Instance-specific storage untuk multi-instance support
_G.QHInstances = _G.QHInstances or {}
_G.QHInstances[_instanceId] = _G.QHInstances[_instanceId] or {
    SavedData = {FishCaught = {}, CaughtVisual = {}, FishNotif = {}},
    NotifQueue = {},
    NotifActive = 0
}

-- Fallback ke global untuk backward compatibility
_G.SavedData = _G.SavedData or {FishCaught = {}, CaughtVisual = {}, FishNotif = {}}
_G.NotifQueue = _G.NotifQueue or {}
_G.NotifActive = _G.NotifActive or 0
-- FREE CAM SYSTEM
local FreeCam = {}
do
    local Camera = workspace.CurrentCamera
    local isActive = false
    local renderConn = nil
    local onMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local cameraPos = Vector3.new()
    local cameraRot = Vector2.new()
    local cameraFov = 70
    local rotating = false
    local touchMoveStart, touchRotStart, touchMoveFinger, touchRotFinger = nil, nil, nil, nil
    _G.FreeCamSpeed = _G.FreeCamSpeed or 5
    local VEL_STIFFNESS, PAN_STIFFNESS, FOV_STIFFNESS = 1.5, 1.0, 4.0
    local NAV_GAIN = Vector3.new(1, 1, 1) * 64
    local PAN_GAIN = Vector2.new(0.75, 1) * 8
    local FOV_GAIN = 300
    local PITCH_LIMIT = math.rad(90)

    local Spring = {}
    Spring.__index = Spring
    function Spring.new(freq, pos)
        local self = setmetatable({}, Spring)
        self.f = freq; self.p = pos; self.v = pos * 0
        return self
    end
    function Spring:Update(dt, goal)
        local f = self.f * 2 * math.pi
        local p0, v0 = self.p, self.v
        local offset = goal - p0
        local decay = math.exp(-f * dt)
        local p1 = goal + (v0 * dt - offset * (f * dt + 1)) * decay
        local v1 = (f * dt * (offset * f - v0) + v0) * decay
        self.p = p1; self.v = v1
        return p1
    end
    function Spring:Reset(pos) self.p = pos; self.v = pos * 0 end

    local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())
    local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
    local fovSpring = Spring.new(FOV_STIFFNESS, 0)

    local savedCameraType, savedCameraCFrame, savedCameraFov = nil, nil, nil
    local savedMouseBehavior, savedMouseIcon, savedSubject = nil, nil, nil
    local savedWalkSpeed, savedJumpPower, savedAutoRotate, savedPlatformStand = nil, nil, nil, nil
    local inputBeganConn, inputEndedConn, inputChangedConn = nil, nil, nil

    local function thumbstickCurve(x)
        local K_CURVATURE, K_DEADZONE = 2.0, 0.15
        local function fCurve(v) return (math.exp(K_CURVATURE * v) - 1) / (math.exp(K_CURVATURE) - 1) end
        local function fDeadzone(v) return fCurve((v - K_DEADZONE) / (1 - K_DEADZONE)) end
        return math.sign(x) * math.clamp(fDeadzone(math.abs(x)), 0, 1)
    end

    local Input = {}
    Input.keyboard = {W=0,A=0,S=0,D=0,E=0,Q=0,U=0,H=0,J=0,K=0,I=0,Y=0,Up=0,Down=0,LeftShift=0,RightShift=0}
    Input.gamepad = {ButtonX=0,ButtonY=0,DPadDown=0,DPadUp=0,ButtonL2=0,ButtonR2=0,Thumbstick1=Vector2.new(),Thumbstick2=Vector2.new()}
    Input.mouse = {Delta=Vector2.new(), MouseWheel=0}

    function Input.Vel(dt)
        local navSpeed = math.clamp(_G.FreeCamSpeed / 5, 0.01, 4)
        local kGamepad = Vector3.new(thumbstickCurve(Input.gamepad.Thumbstick1.X), thumbstickCurve(Input.gamepad.ButtonR2) - thumbstickCurve(Input.gamepad.ButtonL2), thumbstickCurve(-Input.gamepad.Thumbstick1.Y))
        local kKeyboard = Vector3.new(Input.keyboard.D-Input.keyboard.A+Input.keyboard.K-Input.keyboard.H, Input.keyboard.E-Input.keyboard.Q+Input.keyboard.I-Input.keyboard.Y, Input.keyboard.S-Input.keyboard.W+Input.keyboard.J-Input.keyboard.U)
        local shift = Input.keyboard.LeftShift > 0 or Input.keyboard.RightShift > 0
        return (kGamepad + kKeyboard) * (navSpeed * (shift and 0.25 or 1))
    end
    function Input.Pan(dt)
        local kGamepad = Vector2.new(thumbstickCurve(Input.gamepad.Thumbstick2.Y), thumbstickCurve(-Input.gamepad.Thumbstick2.X)) * (math.pi / 8)
        local kMouse = Input.mouse.Delta * Vector2.new(1, 1) * (math.pi / 64)
        Input.mouse.Delta = Vector2.new()
        return kGamepad + kMouse
    end
    function Input.Fov(dt)
        local kGamepad = (Input.gamepad.ButtonX - Input.gamepad.ButtonY) * 0.25
        local kMouse = Input.mouse.MouseWheel * 1.0
        Input.mouse.MouseWheel = 0
        return kGamepad + kMouse
    end
    function Input.Zero(t)
        for k, v in pairs(t) do
            if typeof(v) == "Vector2" then t[k] = Vector2.new()
            elseif typeof(v) == "Vector3" then t[k] = Vector3.new()
            else t[k] = v * 0 end
        end
    end

    local TOUCH_MOVE_ZONE = 0.4
    local function getTouchZone(pos) return pos.X < Camera.ViewportSize.X * TOUCH_MOVE_ZONE and "move" or "rotate" end
    local function handleMobileTouchBegan(input)
        local zone = getTouchZone(input.Position)
        if zone == "move" and not touchMoveFinger then touchMoveFinger = input; touchMoveStart = input.Position
        elseif zone == "rotate" and not touchRotFinger then touchRotFinger = input; touchRotStart = input.Position; rotating = true end
    end
    local function handleMobileTouchEnded(input)
        if touchMoveFinger and touchMoveFinger == input then
            touchMoveFinger = nil; touchMoveStart = nil
            Input.keyboard.W = 0; Input.keyboard.A = 0; Input.keyboard.S = 0; Input.keyboard.D = 0
        end
        if touchRotFinger and touchRotFinger == input then touchRotFinger = nil; touchRotStart = nil; rotating = false end
    end
    local function handleMobileTouchMoved(input)
        if touchMoveFinger and touchMoveFinger == input and touchMoveStart then
            local delta = input.Position - touchMoveStart
            local threshold = 5
            if math.abs(delta.X) > threshold then if delta.X < 0 then Input.keyboard.A = 1; Input.keyboard.D = 0 else Input.keyboard.A = 0; Input.keyboard.D = 1 end else Input.keyboard.A = 0; Input.keyboard.D = 0 end
            if math.abs(delta.Y) > threshold then if delta.Y < 0 then Input.keyboard.W = 1; Input.keyboard.S = 0 else Input.keyboard.W = 0; Input.keyboard.S = 1 end else Input.keyboard.W = 0; Input.keyboard.S = 0 end
        end
        if touchRotFinger and touchRotFinger == input and touchRotStart then
            local delta = input.Position - touchRotStart
            Input.mouse.Delta = Vector2.new(-delta.Y, -delta.X) * 0.8
            touchRotStart = input.Position
        end
    end

    local function onInputBegan(input, gameProcessed)
        if gameProcessed then return end
        local keyName = input.KeyCode.Name
        if Input.keyboard[keyName] ~= nil then Input.keyboard[keyName] = 1 end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then rotating = true end
        if input.UserInputType == Enum.UserInputType.Touch then handleMobileTouchBegan(input) end
        if input.KeyCode == Enum.KeyCode.ButtonX then Input.gamepad.ButtonX = 1 end
        if input.KeyCode == Enum.KeyCode.ButtonY then Input.gamepad.ButtonY = 1 end
        if input.KeyCode == Enum.KeyCode.ButtonL2 then Input.gamepad.ButtonL2 = 1 end
        if input.KeyCode == Enum.KeyCode.ButtonR2 then Input.gamepad.ButtonR2 = 1 end
    end
    local function onInputEnded(input, gameProcessed)
        local keyName = input.KeyCode.Name
        if Input.keyboard[keyName] ~= nil then Input.keyboard[keyName] = 0 end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then rotating = false end
        if input.UserInputType == Enum.UserInputType.Touch then handleMobileTouchEnded(input) end
        if input.KeyCode == Enum.KeyCode.ButtonX then Input.gamepad.ButtonX = 0 end
        if input.KeyCode == Enum.KeyCode.ButtonY then Input.gamepad.ButtonY = 0 end
        if input.KeyCode == Enum.KeyCode.ButtonL2 then Input.gamepad.ButtonL2 = 0 end
        if input.KeyCode == Enum.KeyCode.ButtonR2 then Input.gamepad.ButtonR2 = 0 end
    end
    local function onInputChanged(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if rotating then Input.mouse.Delta = Vector2.new(-input.Delta.Y, -input.Delta.X) end
        elseif input.UserInputType == Enum.UserInputType.Touch then handleMobileTouchMoved(input)
        elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
            if input.KeyCode == Enum.KeyCode.Thumbstick1 then Input.gamepad.Thumbstick1 = input.Position
            elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then Input.gamepad.Thumbstick2 = input.Position end
        end
    end

    local function GetFocusDistance(cameraFrame)
        local znear = 0.1
        local viewport = Camera.ViewportSize
        local projy = 2 * math.tan(math.rad(cameraFov / 2))
        local projx = viewport.X / viewport.Y * projy
        local fx, fy, fz = cameraFrame.RightVector, cameraFrame.UpVector, cameraFrame.LookVector
        local minVect, minDist = Vector3.new(), 512
        for x = 0, 1, 0.5 do for y = 0, 1, 0.5 do
            local cx, cy = (x - 0.5) * projx, (y - 0.5) * projy
            local offset = fx * cx - fy * cy + fz
            local origin = cameraFrame.Position + offset * znear
            local result = workspace:Raycast(origin, offset.Unit * minDist)
            local dist = result and (result.Position - origin).Magnitude or minDist
            if minDist > dist then minDist = dist; minVect = offset.Unit end
        end end
        return fz:Dot(minVect) * minDist
    end

    local function StepFreecam(dt)
        local vel = velSpring:Update(dt, Input.Vel(dt))
        local pan = panSpring:Update(dt, Input.Pan(dt))
        local fov = fovSpring:Update(dt, Input.Fov(dt))
        local zoomFactor = math.sqrt(math.tan(math.rad(70 / 2)) / math.tan(math.rad(cameraFov / 2)))
        cameraFov = math.clamp(cameraFov + fov * FOV_GAIN * (dt / zoomFactor), 1, 120)
        cameraRot = cameraRot + pan * PAN_GAIN * (dt / zoomFactor)
        cameraRot = Vector2.new(math.clamp(cameraRot.X, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.Y % (2 * math.pi))
        local cameraCFrame = CFrame.new(cameraPos) * CFrame.fromOrientation(cameraRot.X, cameraRot.Y, 0) * CFrame.new(vel * NAV_GAIN * dt)
        cameraPos = cameraCFrame.Position
        Camera.CFrame = cameraCFrame
        Camera.Focus = cameraCFrame * CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
        Camera.FieldOfView = cameraFov
    end

    local function FreezeCharacter()
        local char = LocalPlayer.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then savedWalkSpeed = hum.WalkSpeed; savedJumpPower = hum.JumpPower; savedAutoRotate = hum.AutoRotate; savedPlatformStand = hum.PlatformStand; hum.WalkSpeed = 0; hum.JumpPower = 0; hum.AutoRotate = false; hum.PlatformStand = true end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Anchored = true end
        for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Anchored = true end end
    end
    local function UnfreezeCharacter()
        local char = LocalPlayer.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = savedWalkSpeed or 16; hum.JumpPower = savedJumpPower or 50; hum.AutoRotate = savedAutoRotate ~= false; hum.PlatformStand = savedPlatformStand or false end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Anchored = false end
        for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Anchored = false end end
    end

    function FreeCam.Enable()
        if isActive then return end; isActive = true
        savedCameraType = Camera.CameraType; savedCameraCFrame = Camera.CFrame; savedCameraFov = Camera.FieldOfView
        savedMouseBehavior = UserInputService.MouseBehavior; savedMouseIcon = UserInputService.MouseIconEnabled; savedSubject = Camera.CameraSubject
        Camera.CameraType = Enum.CameraType.Scriptable
        cameraPos = savedCameraCFrame.Position
        cameraRot = Vector2.new(math.asin(savedCameraCFrame.LookVector.Y), math.atan2(-savedCameraCFrame.LookVector.X, -savedCameraCFrame.LookVector.Z))
        cameraFov = savedCameraFov or 70
        velSpring:Reset(Vector3.new()); panSpring:Reset(Vector2.new()); fovSpring:Reset(0)
        if not onMobile then UserInputService.MouseBehavior = Enum.MouseBehavior.Default; UserInputService.MouseIconEnabled = true end
        inputBeganConn = UserInputService.InputBegan:Connect(onInputBegan)
        inputEndedConn = UserInputService.InputEnded:Connect(onInputEnded)
        inputChangedConn = UserInputService.InputChanged:Connect(onInputChanged)
        renderConn = RunService.RenderStepped:Connect(StepFreecam)
        FreezeCharacter()
    end
    function FreeCam.Disable()
        if not isActive then return end; isActive = false
        if renderConn then renderConn:Disconnect(); renderConn = nil end
        if inputBeganConn then inputBeganConn:Disconnect(); inputBeganConn = nil end
        if inputEndedConn then inputEndedConn:Disconnect(); inputEndedConn = nil end
        if inputChangedConn then inputChangedConn:Disconnect(); inputChangedConn = nil end
        Input.Zero(Input.keyboard); Input.Zero(Input.gamepad); Input.Zero(Input.mouse)
        rotating = false; touchMoveFinger = nil; touchRotFinger = nil; touchMoveStart = nil; touchRotStart = nil
        Camera.CameraType = savedCameraType or Enum.CameraType.Custom
        Camera.CFrame = savedCameraCFrame or Camera.CFrame
        Camera.FieldOfView = savedCameraFov or 70
        Camera.CameraSubject = savedSubject or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid"))
        if not onMobile then UserInputService.MouseBehavior = savedMouseBehavior or Enum.MouseBehavior.Default; UserInputService.MouseIconEnabled = savedMouseIcon ~= false end
        UnfreezeCharacter()
    end
    function FreeCam.Toggle() if isActive then FreeCam.Disable() else FreeCam.Enable() end; return isActive end
    function FreeCam.IsActive() return isActive end
    function FreeCam.SetSpeed(speed) _G.FreeCamSpeed = math.clamp(speed, 1, 20) end
-- CHARACTER MOVEMENT MODE
    local charModeActive = false
    local charModeConn = nil
    local charModeSubject = nil

    local function StepCharacterMode(dt)
        local pan = panSpring:Update(dt, Input.Pan(dt))
        local fov = fovSpring:Update(dt, Input.Fov(dt))
        local zoomFactor = math.sqrt(math.tan(math.rad(70 / 2)) / math.tan(math.rad(cameraFov / 2)))
        cameraFov = math.clamp(cameraFov + fov * FOV_GAIN * (dt / zoomFactor), 1, 120)
        cameraRot = cameraRot + pan * PAN_GAIN * (dt / zoomFactor)
        cameraRot = Vector2.new(math.clamp(cameraRot.X, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.Y % (2 * math.pi))
        -- Kamera tetap diam, hanya pan dan zoom saja
        Camera.CFrame = CFrame.new(cameraPos) * CFrame.fromOrientation(cameraRot.X, cameraRot.Y, 0)
        Camera.Focus = Camera.CFrame * CFrame.new(0, 0, -GetFocusDistance(Camera.CFrame))
        Camera.FieldOfView = cameraFov
        -- Character bisa berjalan normal
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
            end
        end
    end

    function FreeCam.EnableCharacterMode()
        if isActive then FreeCam.Disable() end
        charModeActive = true
        savedCameraType = Camera.CameraType; savedCameraCFrame = Camera.CFrame; savedCameraFov = Camera.FieldOfView
        savedMouseBehavior = UserInputService.MouseBehavior; savedMouseIcon = UserInputService.MouseIconEnabled; savedSubject = Camera.CameraSubject
        Camera.CameraType = Enum.CameraType.Scriptable
        cameraPos = savedCameraCFrame.Position
        cameraRot = Vector2.new(math.asin(savedCameraCFrame.LookVector.Y), math.atan2(-savedCameraCFrame.LookVector.X, -savedCameraCFrame.LookVector.Z))
        cameraFov = savedCameraFov or 70
        velSpring:Reset(Vector3.new()); panSpring:Reset(Vector2.new()); fovSpring:Reset(0)
        if not onMobile then UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter; UserInputService.MouseIconEnabled = false end
        inputBeganConn = UserInputService.InputBegan:Connect(onInputBegan)
        inputEndedConn = UserInputService.InputEnded:Connect(onInputEnded)
        inputChangedConn = UserInputService.InputChanged:Connect(onInputChanged)
        -- Unfreeze character so it can move
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 0; hum.JumpPower = 0; hum.AutoRotate = false; hum.PlatformStand = false end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored = false end
        end
        renderConn = RunService.RenderStepped:Connect(StepCharacterMode)
        isActive = true
    end

    function FreeCam.DisableCharacterMode()
        charModeActive = false
        FreeCam.Disable()
    end
end
_G.FreeCam = FreeCam

local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function equipRod()
    task.wait(0.1)
    pcall(function() if Events.equip then CallRemote(Events.equip, 1) end end)
    task.wait(0.1)
    if Config.autoFishing or Config.AutoCatch then
        pcall(function() if Events.UpdateAutoFishing then CallRemote(Events.UpdateAutoFishing, true) end end)
    end
end

local function safeFire(func)
    task.spawn(function()
        local ok, err = pcall(func)
        if not ok then warn("[KysHub] safeFire error: " .. tostring(err)) end
    end)
end

local function FireLocalEvent(remote, ...)
    if not remote then return end
    local args = {...}
    pcall(function()
        local signal = remote.OnClientEvent
        if not signal then return end
        local conns = {}
        pcall(function() conns = getconnections(signal) end)
        for _, connection in ipairs(conns) do
            if connection and connection.Function then
                task.spawn(function() pcall(function() connection.Function(unpack(args)) end) end)
            end
        end
    end)
end

local function deepCopyArr(t)
    local out = {}
    for i, v in ipairs(t) do
        if type(v) == "table" then local c = {}; for k, val in pairs(v) do c[k] = val end; out[i] = c
        else out[i] = v end
    end
    return out
end

local function HookRemote(humanName, storageKey)
    if _hookedRemotes[humanName] then return true end
    local remote = GetServerRemote(humanName)
    if remote then
        _hookedRemotes[humanName] = true
        pcall(function()
            remote.OnClientEvent:Connect(function(...)
                _G.SavedData[storageKey] = {...}
                local args = {...}
                if storageKey == "FishCaught" and tostring(args[1]) == tostring(LocalPlayer.Name) then
                    saveCount = saveCount + 1
                    _sessionCatchCount = _sessionCatchCount + 1
                    table.insert(_lastCatchTimestamps, tick())
                    if #_lastCatchTimestamps > 60 then table.remove(_lastCatchTimestamps, 1) end
                end
            end)
        end)
        return true
    end
    return false
end

task.spawn(function()
    task.wait(1)
    pcall(function()
        -- Hook langsung tanpa GetServerRemote (lebih reliable)
        local xr_fishcaught = net and net:FindFirstChild("RE/FishCaught") 
            or ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent", true)
        
        -- Scan semua children di net untuk find by name
        if net then
            for _, remote in ipairs(net:GetChildren()) do
                if remote.Name == "RE/FishCaught" then
                    _hookedRemotes["RE/FishCaught"] = true
                    remote.OnClientEvent:Connect(function(...)
                        _G.SavedData.FishCaught = {...}
                        local args = {...}
                        if tostring(args[1]) == tostring(LocalPlayer.Name) then
                            saveCount += 1
                            _sessionCatchCount += 1
                            table.insert(_lastCatchTimestamps, tick())
                            if #_lastCatchTimestamps > 60 then 
                                table.remove(_lastCatchTimestamps, 1) 
                            end
                        end
                    end)
                end
                
                if remote.Name == "RE/CaughtFishVisual" then
                    _hookedRemotes["RE/CaughtFishVisual"] = true
                    remote.OnClientEvent:Connect(function(...)
                        _G.SavedData.CaughtVisual = {...}
                        -- Simpan ke history visual
                        table.insert(lastValidCaughtVisualHistory, deepCopyArr({...}))
                        if #lastValidCaughtVisualHistory > 20 then
                            table.remove(lastValidCaughtVisualHistory, 1)
                        end
                        lastValidCaughtVisual = deepCopyArr({...})
                    end)
                end
                
                if remote.Name == "RE/ObtainedNewFishNotification" then
                    _hookedRemotes["RE/ObtainedNewFishNotification"] = true
                    remote.OnClientEvent:Connect(function(...)
                        _G.SavedData.FishNotif = {...}
                    end)
                end
            end
        end
    end)
end)

local function CalculateCPM()
    local now = tick()
    local recentCatches = 0
    for _, timestamp in ipairs(_lastCatchTimestamps) do
        if now - timestamp < 60 then recentCatches = recentCatches + 1 end
    end
    return recentCatches
end
-- INSTANT BOBBER
local InstantBobberState = {
    instantOverrideActive = false, instantOverrideSetupDone = false,
    activeBaitsByUserId = nil, cosmeticFolder = nil,
    baitCastConn = nil, baitDestroyedConn = nil, renderConn = nil,
}

local function patchInstantBaitOverrideToCastPosition(enabled)
    if not enabled then
        InstantBobberState.instantOverrideActive = false
        if InstantBobberState.activeBaitsByUserId then table.clear(InstantBobberState.activeBaitsByUserId) end
        return
    end
    InstantBobberState.instantOverrideActive = true
    InstantBobberState.activeBaitsByUserId = InstantBobberState.activeBaitsByUserId or {}
    table.clear(InstantBobberState.activeBaitsByUserId)
    if InstantBobberState.instantOverrideSetupDone then return end
    InstantBobberState.instantOverrideSetupDone = true
    local okCosmetic, cosmeticFolder = pcall(function() return workspace:WaitForChild("CosmeticFolder", 5) end)
    if not okCosmetic or not cosmeticFolder then InstantBobberState.instantOverrideSetupDone = false; InstantBobberState.instantOverrideActive = false; return end
    InstantBobberState.cosmeticFolder = cosmeticFolder
    local baitCastVisual = GetServerRemote("RE/BaitCastVisual") or GetServerRemote("BaitCastVisual")
    local baitDestroyed = GetServerRemote("RE/BaitDestroyed") or GetServerRemote("BaitDestroyed")
    if not baitCastVisual or not baitCastVisual:IsA("RemoteEvent") then InstantBobberState.instantOverrideSetupDone = false; InstantBobberState.instantOverrideActive = false; return end
    if not baitDestroyed or not baitDestroyed:IsA("RemoteEvent") then InstantBobberState.instantOverrideSetupDone = false; InstantBobberState.instantOverrideActive = false; return end
    local function safeConnect(signal, callback)
        if not signal then return nil end
        local ok, conn = pcall(function() return signal:Connect(callback) end)
        if not ok then return nil end
        return conn
    end
    InstantBobberState.baitCastConn = safeConnect(baitCastVisual.OnClientEvent, function(player, data)
        if not InstantBobberState.instantOverrideActive then return end
        if not player or not player.UserId then return end
        if not data or not data.CastPosition or typeof(data.CastPosition) ~= "Vector3" then return end
        InstantBobberState.activeBaitsByUserId[player.UserId] = {pivot = CFrame.new(data.CastPosition), expiresAt = tick() + 0.8}
    end)
    InstantBobberState.baitDestroyedConn = safeConnect(baitDestroyed.OnClientEvent, function(player)
        if not InstantBobberState.instantOverrideActive then return end
        if not player or not player.UserId then return end
        InstantBobberState.activeBaitsByUserId[player.UserId] = nil
    end)
    InstantBobberState.renderConn = RunService.RenderStepped:Connect(function()
        if not InstantBobberState.instantOverrideActive then return end
        local now = tick()
        local cf = InstantBobberState.cosmeticFolder
        if not cf then return end
        for userId, entry in pairs(InstantBobberState.activeBaitsByUserId) do
            if now > entry.expiresAt then InstantBobberState.activeBaitsByUserId[userId] = nil
            else
                local model = cf:FindFirstChild(tostring(userId))
                if model and model.PivotTo then
                    model:PivotTo(entry.pivot)
                    if model:IsA("Model") and model.PrimaryPart then model.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, -75, 0)
                    elseif model:IsA("BasePart") then model.AssemblyLinearVelocity = Vector3.new(0, -75, 0) end
                end
            end
        end
    end)
end

pcall(function()
-- SKIN ANIMATION (IMPROVED - Smooth transitions + proper cleanup)
local SkinAnimation = (function()
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid", 5)

    -- DATABASE SKIN LENGKAP - Semua FishCaught animation ID resmi dari Fish It
    local SkinDatabase = {
        -- ORIGINAL
        ["Eclipse"]              = "rbxassetid://107940819382815",
        ["HolyTrident"]         = "rbxassetid://128167068291703",
        ["SoulScythe"]          = "rbxassetid://82259219343456",
        ["OceanicHarpoon"]      = "rbxassetid://76325124055693",
        ["BinaryEdge"]          = "rbxassetid://109653945741202",
        ["Vanquisher"]          = "rbxassetid://93884986836266",
        ["KrampusScythe"]       = "rbxassetid://134934781977605",
        ["BanHammer"]           = "rbxassetid://96285280763544",
        ["CorruptionEdge"]      = "rbxassetid://126613975718573",
        ["PrincessParasol"]     = "rbxassetid://99143072029495",
        -- BARU
        ["AetherMonarch"]       = "rbxassetid://74447876553309",
        ["CloudWeaver"]         = "rbxassetid://121026156047780",
        ["Overdrive"]           = "rbxassetid://71232649901855",
        ["VoidGuitar"]          = "rbxassetid://79346352464845",
        ["KittyGuitar"]         = "rbxassetid://132530630982956",
        ["DraconicSoul"]        = "rbxassetid://109818439508879",
        ["DivineStaff"]         = "rbxassetid://107412232735920",
        ["EmpyreanStaff"]       = "rbxassetid://101971777673013",
        ["GoldenClockwork"]     = "rbxassetid://126346193348309",
        ["BunnySummoner"]       = "rbxassetid://101318598176860",
        ["EasterParasol"]       = "rbxassetid://90572706842137",
        ["SerpentTrident"]      = "rbxassetid://140142098810185",
        ["CrimsonRetribution"]  = "rbxassetid://108205633866814",
        ["DarkMatterScythe"]    = "rbxassetid://106846315932087",
        ["EtherealSword"]       = "rbxassetid://110866636674655",
        ["CupidHarp"]           = "rbxassetid://93542218938956",
        ["AurelianBow"]         = "rbxassetid://89083607138153",
        ["VoidKraken"]          = "rbxassetid://71093335229963",
        ["CelestialScythe"]     = "rbxassetid://125568004947137",
        ["KitsuneGreatsword"]   = "rbxassetid://139914168110430",
        ["ChromaticKatana"]     = "rbxassetid://75078942392746",
        ["CrescendoScythe"]     = "rbxassetid://101593515409348",
        ["BlackholeSword"]      = "rbxassetid://88993991486322",
        ["EternalFlower"]       = "rbxassetid://119567958965696",
        ["GingerbreadKatana"]   = "rbxassetid://107940819382815",
        ["ChristmasParasol"]    = "rbxassetid://99143072029495",
        ["EnergyBlaster"]       = "rbxassetid://128051680962035",
        ["ButterflySword"]      = "rbxassetid://128847574673285",
        ["ElectricGuitar"]      = "rbxassetid://139089375187802",
        ["DefaultCatch"]        = "rbxassetid://117319000848286",
    }

    local CurrentSkin = nil
    local AnimationPool = {}
    local IsEnabled = false
    local speedUpConn = nil
    local animPlayedConn = nil
    local charAddedConn = nil
    local currentAnimator = nil
    local FADE_TIME = 0.15 -- Smooth fade duration

    local function getAnimator()
        local c = player.Character
        if not c then return nil end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h then return nil end
        local a = h:FindFirstChildOfClass("Animator")
        if not a then
            a = Instance.new("Animator")
            a.Parent = h
        end
        currentAnimator = a
        return a
    end

    local function CleanupPool()
        for _, track in ipairs(AnimationPool) do
            pcall(function()
                if track.IsPlaying then track:Stop(FADE_TIME) end
            end)
            pcall(function() track:Destroy() end)
        end
        AnimationPool = {}
    end

    local function LoadAnimationPool(skinId)
        local animId = SkinDatabase[skinId]
        if not animId then return false end

        CleanupPool()

        local animator = getAnimator()
        if not animator then return false end

        local anim = Instance.new("Animation")
        anim.AnimationId = animId
        for i = 1, 3 do
            local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
            if ok and track then
                track.Priority = Enum.AnimationPriority.Action4
                track.Name = "KysHub_SKIN_" .. i
                table.insert(AnimationPool, track)
            end
        end
        anim:Destroy()
        return #AnimationPool > 0
    end

    local function IsFishCaughtAnimation(track)
        local name = string.lower(track.Name or "")
        local id = ""
        pcall(function() id = string.lower(track.Animation and track.Animation.AnimationId or "") end)
        return name:find("fishcaught") or name:find("caught") or name:find("reel")
            or id:find("117319000848286") -- Default FishCaught ID
    end

    local function SmoothReplace(originalTrack)
        if #AnimationPool == 0 then return end
        -- Pilih track dari pool secara round-robin
        local poolIndex = math.random(1, #AnimationPool)
        local nextTrack = AnimationPool[poolIndex]
        if not nextTrack then return end

        pcall(function()
            -- Fade out original smoothly
            originalTrack:Stop(FADE_TIME)
            -- Fade in replacement smoothly
            nextTrack:Play(FADE_TIME, 1, 1)
        end)
    end

    local function SetupHooks()
        -- Disconnect existing hooks
        if animPlayedConn then pcall(function() animPlayedConn:Disconnect() end) end
        if speedUpConn then pcall(function() speedUpConn:Disconnect() end) end

        local c = player.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h then return end

        -- Hook AnimationPlayed untuk detect FishCaught
        animPlayedConn = h.AnimationPlayed:Connect(function(track)
            -- Speed up hook (untuk fitur lain)
            if _G.QHBetaAnimSpeed then
                local animName = string.lower(track.Name or "")
                if animName:find("fishcaught") or animName:find("caught") or animName:find("reel") then
                    pcall(function() track:AdjustSpeed(15.0) end)
                end
            end

            -- Custom skin replacement
            if IsEnabled and IsFishCaughtAnimation(track) then
                -- Cek apakah ini bukan track kita sendiri
                local trackName = track.Name or ""
                if not trackName:find("KysHub_SKIN_") then
                    task.defer(function()
                        SmoothReplace(track)
                    end)
                end
            end
        end)
    end

    -- Initial setup
    if humanoid then
        getAnimator()
        SetupHooks()
    end

    -- Re-hook saat respawn
    charAddedConn = player.CharacterAdded:Connect(function(newChar)
        task.delay(1, function()
            humanoid = newChar:WaitForChild("Humanoid", 5)
            if humanoid then
                getAnimator()
                SetupHooks()
                -- Re-load pool jika sedang enabled
                if IsEnabled and CurrentSkin then
                    LoadAnimationPool(CurrentSkin)
                end
            end
        end)
    end)

    local API = {}
    function API.SwitchSkin(id)
        CurrentSkin = id
        if IsEnabled then
            return LoadAnimationPool(id)
        end
        return true
    end

    function API.Enable()
        if not CurrentSkin then return false end
        IsEnabled = LoadAnimationPool(CurrentSkin)
        return IsEnabled
    end

    function API.Disable()
        IsEnabled = false
        -- Stop semua track yang sedang playing dari pool
        for _, track in ipairs(AnimationPool) do
            pcall(function()
                if track.IsPlaying then
                    track:Stop(FADE_TIME)
                end
            end)
        end
        return true
    end

    function API.DisconnectSpeedUp()
        if speedUpConn then
            pcall(function() speedUpConn:Disconnect() end)
            speedUpConn = nil
        end
        if animPlayedConn then
            pcall(function() animPlayedConn:Disconnect() end)
            animPlayedConn = nil
        end
        CleanupPool()
    end

    return API
end)()

-- LOCATIONS
local LOCATIONS = {
    ["Fisherman"]=CFrame.new(32.452701568603516,9.8837251663208,2811.386962890625,0.99053555727005,3.863859632247113e-08,0.1372562050819397,-4.9611127650450726e-08,1,7.652105438182843e-08,-0.1372562050819397,-8.260626316314301e-08,0.99053555727005),
    ["Sisyphus Statue"]=CFrame.new(-3732.14013671875,-135.07444763183594,-1013.1876831054688,-0.955187201499939,-1.1046745740372899e-09,-0.2960023581981659,1.4209726728608985e-09,1,-8.317398325630165e-09,0.2960023581981659,-8.365283576949878e-09,-0.955187201499939),
    ["Coral Reefs"]=CFrame.new(-3299.224853515625,123.38948059082031,2223.6123046875,0.9714493155479431,-3.932468217726637e-08,-0.23724719882011414,2.3648508928886258e-08,1,-6.89211745452667e-08,0.23724719882011414,6.134288099701735e-08,0.9714493155479431),
    ["Esoteric Depths"]=CFrame.new(3271.66064453125,-1301.5306396484375,1381.4456787109375,0.4031963646411896,-1.698047213949394e-08,-0.9151135087013245,6.24907769974925e-09,1,-1.5802264385911258e-08,0.9151135087013245,6.528004248274044e-10,0.4031963646411896),
    ["Crater Island 1"]=CFrame.new(1060.8260498046875,2.5815768241882324,5131.58740234375,0.6491144299507141,-4.685521304281792e-08,0.7606907486915588,-7.2682522223033175e-09,1,6.779777095289319e-08,-0.7606907486915588,-4.953740528890194e-08,0.6491144299507141),
    ["Crater Island 2"]=CFrame.new(1040.036,55.714,5131.443),
    ["Lost Isle"]=CFrame.new(-3618.157,240.837,-1317.458),
    ["Weather Machine"]=CFrame.new(-1488.512,83.173,1876.303),
    ["Tropical Grove"]=CFrame.new(-2152.160888671875,53.48600769042969,3619.32861328125,-0.9894322156906128,-3.306193363528109e-08,0.14499624073505402,-2.7268503899335883e-08,1,4.194314229266638e-08,-0.14499624073505402,3.75460658119664e-08,-0.9894322156906128),
    ["Treasure Room"]=CFrame.new(-3648.86328125,-268.6123352050781,-1662.415283203125,-0.08403428643941879,4.124477470668353e-08,-0.996462881565094,1.8866575857146017e-08,1,3.980011342719081e-08,0.996462881565094,-1.5455267288189134e-08,-0.08403428643941879),
    ["Kohana"]=CFrame.new(-658.2866821289062,17.244775772094727,510.14471435546875,-0.42606961727142334,-6.305730693156875e-08,-0.9046903848648071,-4.856544677522834e-08,1,-4.6828223077000075e-08,0.9046903848648071,-2.398461163011234e-08,-0.42606961727142334),
    ["Kohana Volcano"]=CFrame.new(-424.0745544433594,7.2453107833862305,124.14938354492188,0.5406834483146667,-5.706213812572969e-08,0.8412261605262756,6.439024247129055e-08,1,2.644639529592041e-08,-0.8412261605262756,3.9867625645229054e-08,0.5406834483146667),
    ["Underground Cellar"]=CFrame.new(2139.544677734375,-91.19776916503906,-766.829833984375,-0.9832987785339355,-4.776161133257517e-10,0.181998610496521,-4.769880601607213e-10,1,4.722218796548994e-11,-0.181998610496521,-4.0377642201994135e-11,-0.9832987785339355),
    ["Ancient Jungle"]=CFrame.new(1484.5361328125,11.14309024810791,-300.48779296875,0.4785112142562866,-4.932040909011448e-08,-0.8780814409255981,6.106117211857054e-08,1,-2.2893040352300886e-08,0.8780814409255981,-4.266210495984524e-08,0.4785112142562866),
    ["Sacred Temple"]=CFrame.new(1421.6331787109375,4.8749680519104,-659.717041015625,-0.1609015166759491,1.0546634854335935e-07,0.9869704842567444,-6.794437013013521e-09,1,-1.079663363157124e-07,-0.9869704842567444,-2.40778543769693e-08,-0.1609015166759491),
    ["Ancient Ruins"]=CFrame.new(6096.15966796875,-585.9248046875,4664.01611328125,0.09696821123361588,6.360328796972681e-08,0.9952874779701233,-2.087845096809815e-08,1,-6.187030976434471e-08,-0.9952874779701233,-1.4780606960584919e-08,0.09696821123361588),
    ["Pirate Cove"]=CFrame.new(3399.018798828125,4.191970348358154,3475.293701171875,0.12555743753910065,5.9513890704465666e-08,-0.9920863509178162,-5.7514718321272085e-08,1,5.270961267456187e-08,0.9920863509178162,5.0441482102314694e-08,0.12555743753910065),
    ["Pirate Treasure Room"]=CFrame.new(3324.074,-306.476,3087.999),
    ["Crystal Depth"]=CFrame.new(5504.767578125,-904.9680786132812,15290.484375,-0.9885009527206421,-5.751004295007078e-08,-0.1512146145105362,-7.093211706887814e-08,1,8.336772339134768e-08,0.1512146145105362,9.313504278907203e-08,-0.9885009527206421),
    ["Lava Basin"]=CFrame.new(950.876,85.282,-10199.427),
    ["Planetary Observatory"]=CFrame.new(460.5227966308594,24.145477294921875,2204.85546875,0.31723323464393616,-8.052414735004731e-09,0.9483475685119629,-5.833442529024069e-08,1,2.8004535579384537e-08,-0.9483475685119629,-6.420528109174484e-08,0.31723323464393616),
    ["Underwater City"]=CFrame.new(-3100.5361328125,-644.4927978515625,-10585.369140625,0.9756958484649658,8.328454015327225e-08,-0.21912924945354462,-8.53786374932497e-08,1,-8.691408009964263e-11,0.21912924945354462,1.8793759437585322e-08,0.9756958484649658),
    ["sewer"]=CFrame.new(-1387.8677978515625,-1041.593994140625,-10436.0390625,0.6749362945556641,5.8742899433639195e-09,-0.7378759980201721,8.491160663481878e-09,1,1.5727957602962306e-08,0.7378759980201721,-1.6880791875450996e-08,0.6749362945556641),
    ["Copper Canyon"]=CFrame.new(-4147.4873046875, 6.7726263999938965, 614.3461303710938, 0.3586901128292084, 0.030515363439917564, 0.9329577684402466, -1.9739960777087617e-09, 0.9994655251502991, -0.032690711319446564, -0.9334567189216614, 0.011725833639502525, 0.3584984242916107),
    ["Enchanting Altar"]=CFrame.new(3244.42138671875, -1301.1806640625, 1395.0330810546875, -0.4685245156288147, -3.482493937667641e-08, 0.8834505081176758, -5.064358532536062e-08, 1, 1.2561176987446743e-08, -0.8834505081176758, -3.885588384378025e-08, -0.4685245156288147),
    ["Copper Canyon Mines"]=CFrame.new(-4046, -551, 486),
    ["Starfall Gardens"]=CFrame.new(-22231, -252, -8049),
    ["Stingray Shores"]=CFrame.new(-2128, 17, -850),
    ["Trench"]=CFrame.new(-9276, -240, -67),
}


local function teleportTo(locationName)
    local cf = LOCATIONS[locationName]
    local hrp = getHRP()
    if not hrp or not cf then return end
    hrp.CFrame = cf + Vector3.new(0, 3, 0)
end

-- UB INIT & LOOP
local function UB_init()
    Config.UB.Remotes.equip              = GetServerRemote("RE/EquipToolFromHotbar")
    Config.UB.Remotes.ChargeFishingRod   = GetServerRemote("RF/ChargeFishingRod")
    Config.UB.Remotes.RequestMinigame    = GetServerRemote("RF/RequestFishingMinigameStarted")
    Config.UB.Remotes.CancelFishingInputs= GetServerRemote("RF/CancelFishingInputs")
    Config.UB.Remotes.UpdateAutoFishing  = GetServerRemote("RF/UpdateAutoFishingState")
    Config.UB.Remotes.FishingCompleted   = GetServerRemote("RF/CatchFishCompleted") 
    Config.UB.Remotes.FishingCompletedRE = GetServerRemote("RE/CatchFishCompleted")  
    Config.UB.Remotes.MinigameChanged    = GetServerRemote("RE/FishingMinigameChanged")

    -- Debug: print status remotes
    print("[KysHub] equip remote: " .. tostring(Config.UB.Remotes.equip ~= nil))
    print("[KysHub] catchRE remote: " .. tostring(Config.UB.Remotes.FishingCompletedRE ~= nil))
    print("[KysHub] minigame remote: " .. tostring(Config.UB.Remotes.MinigameChanged ~= nil))
    return true
end

local NOTIF_DELAY_DURATION = 21
local _notifDelayActive = false
local _notifHooksApplied = false

local function setupNotifDelayHooks()
    if _notifHooksApplied then return end
    _notifHooksApplied = true
    if not isMobile then return end
    pcall(function()
        local ctrlFolder = ReplicatedStorage:FindFirstChild("Controllers")
        if not ctrlFolder then return end
        local TextNotifCtrl = require(ctrlFolder:WaitForChild("TextNotificationController", 5))
        if TextNotifCtrl and TextNotifCtrl.DeliverNotification then
            local oldDeliver = TextNotifCtrl.DeliverNotification
            TextNotifCtrl.DeliverNotification = function(self, data, ...)
                if _notifDelayActive and data and type(data) == "table" then data.Duration = NOTIF_DELAY_DURATION; data.CustomDuration = NOTIF_DELAY_DURATION end
                return oldDeliver(self, data, ...)
            end
        end
    end)
end

local function enableNotifDelay() if not _notifHooksApplied then setupNotifDelayHooks() end; _notifDelayActive = true end
local function disableNotifDelay() _notifDelayActive = false end

_G._QHBetaBlockNotif = false
local _origFireLocalEvent = FireLocalEvent
FireLocalEvent = function(remote, ...)
    if _G._QHBetaBlockNotif and remote and remote.Name and remote.Name:find("ObtainedNewFishNotification") then return end
    return _origFireLocalEvent(remote, ...)
end
local function enableBlockNotif() _G._QHBetaBlockNotif = true end
local function disableBlockNotif() _G._QHBetaBlockNotif = false end

local function updateReplionInventory(notifData)
    -- Update Replion player data untuk inventory count
    pcall(function()
        if PlayerData and notifData and #notifData > 0 then
            -- Update inventory dengan fish yang di-catch
            local data = PlayerData:GetValue()
            if data and data.Inventory then
                -- Ensure inventory exists
                if not data.Inventory[notifData[1]] then
                    data.Inventory[notifData[1]] = 0
                end
                data.Inventory[notifData[1]] = data.Inventory[notifData[1]] + 1
            end
        end
    end)
end

-- Cache replion Set event - load sekali, pakai terus
if not _G._KysHub_ReplionSetEvent then
    task.spawn(function()
        task.wait(2)
        pcall(function()
            local p = ReplicatedStorage:FindFirstChild("Packages")
            if not p then return end
            local idx = p:FindFirstChild("_Index")
            if not idx then return end
            for _, child in ipairs(idx:GetChildren()) do
                if child.Name:find("ytrev_replion") then
                    local m = child:FindFirstChild("replion")
                    if m then
                        local r = m:FindFirstChild("Remotes")
                        if r then
                            _G._KysHub_ReplionSetEvent = r:FindFirstChild("Set")
                            print("[KysHub] Replion Set event cached!")
                        end
                    end
                end
            end
        end)
    end)
end

local function triggerRainbowGoldenUpdate(notifData, forceIncrement)
    if not notifData or #notifData == 0 then return end
    local ev = _G._KysHub_ReplionSetEvent
    if not ev then return end

    -- Fish counter nambah tiap catch
    Config.YTTA.FishCounter = Config.YTTA.FishCounter + 1
    pcall(function()
        FireLocalEvent(ev, LocalPlayer,
            {"InventoryNotifications", "Fish"},
            Config.YTTA.FishCounter)
    end)

    -- Golden: increment + pastikan >= requirement 10
    if Config.YTTA.GoldenCounter > 0 or forceIncrement then
        Config.YTTA.GoldenCounter = Config.YTTA.GoldenCounter + 1
        pcall(function()
            FireLocalEvent(ev, LocalPlayer,
                {"Modifiers", "Golden"},
                math.max(Config.YTTA.GoldenCounter, GOLDEN_REQ))
        end)
    end

    -- Rainbow: increment + pastikan >= requirement 40
    if Config.YTTA.RainbowCounter > 0 or forceIncrement then
        Config.YTTA.RainbowCounter = Config.YTTA.RainbowCounter + 1
        pcall(function()
            FireLocalEvent(ev, LocalPlayer,
                {"Modifiers", "Rainbow"},
                math.max(Config.YTTA.RainbowCounter, RAINBOW_REQ))
        end)
    end
end

local function GetRemoteDirect(targetName)
    if not net then return nil end
    for _, remote in ipairs(net:GetChildren()) do
        if remote.Name == targetName then return remote end
    end
    return nil
end

local function replayAmblatantNotif()
    task.spawn(function()
        local xr_caught = GetRemoteDirect("RE/FishCaught")
        local xr_visual = GetRemoteDirect("RE/CaughtFishVisual")
        local xr_notif = Events.fishNotif

        -- FIXED: Reset rotation index setiap cycle baru
        Config.YTTA.VisualRotationIndex = 0

        if xr_caught and #lastValidFishCaught > 0 then 
            pcall(function() FireLocalEvent(xr_caught, unpack(lastValidFishCaught)) end) 
        end

        task.wait(0.002)

        if xr_notif and #lastValidFishNotif > 0 then
            for i = 1, Config.YTTA.NotifCount do
                -- FIXED: Pilih notif yang BERBEDA dari history (rotasi)
                local notifData = lastValidFishNotif

                if #_fishNotifHistory > 1 then
                    -- Rotasi index untuk variasi ikan
                    Config.YTTA.VisualRotationIndex = Config.YTTA.VisualRotationIndex + 1
                    local historyIdx = ((Config.YTTA.VisualRotationIndex - 1) % #_fishNotifHistory) + 1
                    notifData = _fishNotifHistory[historyIdx]
                end

                -- FIXED: Kirim notif sebagai notif TERPISAH (bukan digabung)
                pcall(function() FireLocalEvent(xr_notif, unpack(notifData)) end)

                -- Update inventory
                updateReplionInventory(notifData)

                -- FIXED: Trigger visual dan rainbow/golden dengan increment
                if xr_visual and #lastValidCaughtVisual > 0 then
                    -- Rotasi visual juga jika ada history visual
                    local visualData = lastValidCaughtVisual
                    if #lastValidCaughtVisualHistory > 1 then
                        local visualIdx = ((Config.YTTA.VisualRotationIndex - 1) % #lastValidCaughtVisualHistory) + 1
                        visualData = lastValidCaughtVisualHistory[visualIdx]
                    end
                    pcall(function() FireLocalEvent(xr_visual, unpack(visualData)) end)

                    -- FIXED: Increment rainbow/golden PER catch visual
                    pcall(function() triggerRainbowGoldenUpdate(notifData, true) end)
                end

                task.wait(0.001)

                if xr_caught and #lastValidFishCaught > 0 then
                    pcall(function() FireLocalEvent(xr_caught, unpack(lastValidFishCaught)) end)
                end

                -- FIXED: Delay antar notif (pisah, bukan bersamaan)
                if i < Config.YTTA.NotifCount and Config.YTTA.NotifDelay > 0 then 
                    task.wait(Config.YTTA.NotifDelay) 
                end
            end
        end
    end)
end

-- Minigame Hook
local _minigameReady     = false
local _minigameHookConn  = nil
local _perfectionHooked  = false

Config.autoPerfection = Config.autoPerfection or false
Config.YTTA.Settings.MinigameResponseDelay = 0.03  -- 30ms setelah minigame start

local function SetupMinigameHook()
    if _minigameHookConn then return end
    if not net then
        warn("[KysHub] net nil, cannot hook FishingMinigameChanged")
        return
    end

    for _, remote in ipairs(net:GetChildren()) do
        if remote.Name == "RE/FishingMinigameChanged" then
            _minigameHookConn = remote.OnClientEvent:Connect(function(minigameData)
                -- Server memberitahu minigame telah benar-benar dimulai
                _minigameReady = true

                -- Auto Perfection: langsung fire catch dengan quality PERFECT
                -- ketika minigame mulai, sebelum timer habis
                if Config.autoPerfection and Config.UB.Active and Config.amblatant then
                    task.spawn(function()
                        task.wait(Config.YTTA.Settings.MinigameResponseDelay)
                        pcall(function()
                            if Config.UB.Remotes.FishingCompletedRE then
                                -- Kirim quality 5 = PERFECT (dari CatchQualityData)
                                Config.UB.Remotes.FishingCompletedRE:FireServer(5)
                            end
                        end)
                    end)
                end
            end)
            print("[KysHub] FishingMinigameChanged hooked! Extreme mode siap.")
            break
        end
    end

    if not _minigameHookConn then
        warn("[KysHub] FishingMinigameChanged tidak ditemukan di net!")
    end
end

-- Hook New
local GOLDEN_REQ  = 10
local RAINBOW_REQ = 40

pcall(function()
    local replionFolder = ReplicatedStorage:FindFirstChild("Packages")
    if not replionFolder then return end
    local idx = replionFolder:FindFirstChild("_Index")
    if not idx then return end
    local replionMod
    for _, child in ipairs(idx:GetChildren()) do
        if child.Name:find("ytrev_replion") then
            replionMod = child:FindFirstChild("replion"); break
        end
    end
    if not replionMod then return end
    local remotes = replionMod:FindFirstChild("Remotes")
    if not remotes then return end
    local Event = remotes:FindFirstChild("Set")
    if not Event then return end

    local _vRainbow, _vGolden, _vFish = 0, 0, 0

    for _, Connection in getconnections(Event.OnClientEvent) do
        local old; old = hookfunction(Connection.Function, function(...)
            local Args = {...}
            if type(Args[2]) == "table" then
                local cat, sub = Args[2][1], Args[2][2]

                if cat == "Modifiers" and sub == "Golden" then
                    _vGolden = _vGolden + 1
                    if _vGolden > 9999 then _vGolden = 0 end
                    Config.YTTA.GoldenCounter = _vGolden
                    -- PENTING: kirim value >= requirement (10)!
                    old(Args[1], Args[2], math.max(_vGolden, GOLDEN_REQ))
                    isCaught = true
                    return

                elseif cat == "Modifiers" and sub == "Rainbow" then
                    _vRainbow = _vRainbow + 1
                    if _vRainbow > 9999 then _vRainbow = 0 end
                    Config.YTTA.RainbowCounter = _vRainbow
                    -- PENTING: kirim value >= requirement (40)!
                    old(Args[1], Args[2], math.max(_vRainbow, RAINBOW_REQ))
                    isCaught = true
                    return

                elseif cat == "InventoryNotifications" and sub == "Fish" then
                    _vFish = _vFish + 1
                    if _vFish > 99999 then _vFish = 0 end
                    Config.YTTA.FishCounter = _vFish
                    old(Args[1], Args[2], _vFish)
                    isCaught = true
                    return
                end
            end
            return old(...)
        end)
    end
    print("[KysHub] Replion hook OK! Rainbow req=" .. RAINBOW_REQ .. " Golden req=" .. GOLDEN_REQ)
end)
                        
local function ub_loop()
    -- Setup minigame hook saat loop mulai
    SetupMinigameHook()

    while Config.UB.Active do
        local ok, err = pcall(function()
            local currentTime = tick()

            -- Update auto fishing state
            if Config.autoFishing then
                pcall(function()
                    if Events.UpdateAutoFishing then
                        CallRemote(Events.UpdateAutoFishing, true)
                    end
                end)
            end

            -- Base wait sebelum cast
            local baseWait = needCast and 0.02 or Config.UB.Settings.CancelDelay
            if Config.antiOKOK then
                baseWait = baseWait + math.random(3, 15) / 100
            end
            task.wait(baseWait)
            needCast = false

            -- Charge Rod
            local serverTime = workspace:GetServerTimeNow()
            local chargeTime = math.floor(serverTime - 1)
            local speed = Random.new(chargeTime):KystInteger(4, 10)
            
            local alpha = 1.0
            if Config.antiOKOK then
                local qualities = {0.3, 0.6, 0.8, 1.0}
                alpha = qualities[math.random(1, #qualities)]
            end
            
            local duration = (math.pi * alpha) / speed
            local castTime = chargeTime + duration
            local castPower = (1 - math.cos(alpha * math.pi)) / 2

            safeFire(function()
                if Config.UB.Remotes.ChargeFishingRod then
                    pcall(function()
                        Config.UB.Remotes.ChargeFishingRod:InvokeServer(nil, nil, chargeTime, nil)
                    end)
                end
            end)

            if Config.antiOKOK then
                task.wait(math.random(5, 10) / 100)
            else
                task.wait(0.1)
            end

            -- Request Minigame
            _minigameReady = false

            safeFire(function()
                if Config.UB.Remotes.RequestMinigame then
                    pcall(function()
                        Config.UB.Remotes.RequestMinigame:InvokeServer(1, castPower, castTime)
                    end)
                end
            end)

            -- 3 Timing
            if Config.amblatant then
                -- Tunggu sampai server konfirmasi minigame mulai
                -- Timeout maksimal 3 detik (jika hook tidak setup, fallback ke delay)
                local waited = 0
                local maxWait = 3.0
                local checkInterval = 0.01

                while not _minigameReady and waited < maxWait and Config.UB.Active do
                    task.wait(checkInterval)
                    waited = waited + checkInterval
                end

                -- Jika hook tidak bekerja, fallback ke delay minimal
                if not _minigameReady then
                    -- Minigame tidak terdeteksi, pakai delay fallback
                    task.wait(Config.YTTA.Settings.KysHubDelay or 0.5)
                else
                    -- Minigame terdeteksi! Tunggu sedikit untuk stabilitas
                    task.wait(Config.YTTA.Settings.MinigameResponseDelay or 0.03)
                end
                _minigameReady = false

            else
                -- legit mode pakai delay normal
                local completeDelay = Config.UB.Settings.CompleteDelay
                if Config.antiOKOK then
                    completeDelay = completeDelay + math.random(-8, 8) / 100
                end
                task.wait(math.max(completeDelay, 0.02))
            end

            -- Fire Catch
            if not skip then
                -- Fire dengan quality PERFECT jika autoPerfection aktif
                local quality = Config.autoPerfection and 5 or nil

                pcall(function()
                    if Config.UB.Remotes.FishingCompletedRE then
                        if quality then
                            Config.UB.Remotes.FishingCompletedRE:FireServer(quality)
                        else
                            Config.UB.Remotes.FishingCompletedRE:FireServer()
                        end
                    end
                end)

                -- proses hasil catch (untuk Extreme/Amblatant)
                if Config.amblatant then
                    isCaught = false
                    local waitedCatch = 0
                    while not isCaught and waitedCatch < 0.5 do
                        task.wait(0.01)
                        waitedCatch = waitedCatch + 0.01
                    end

                    if isCaught then
                        isCaught = false

                        -- Simpan data catch terbaru
                        if #(_G.SavedData.FishCaught or {}) > 0 then
                            lastValidFishCaught = deepCopyArr(_G.SavedData.FishCaught)
                        end
                        if #(_G.SavedData.CaughtVisual or {}) > 0 then
                            lastValidCaughtVisual = deepCopyArr(_G.SavedData.CaughtVisual)
                            table.insert(lastValidCaughtVisualHistory, deepCopyArr(_G.SavedData.CaughtVisual))
                            if #lastValidCaughtVisualHistory > 20 then
                                table.remove(lastValidCaughtVisualHistory, 1)
                            end
                        end
                        if #(_G.SavedData.FishNotif or {}) > 0 then
                            lastValidFishNotif = deepCopyArr(_G.SavedData.FishNotif)
                            table.insert(_fishNotifHistory, deepCopyArr(_G.SavedData.FishNotif))
                            if #_fishNotifHistory > _maxFishHistory then
                                table.remove(_fishNotifHistory, 1)
                            end
                        end

                        -- Fire visual events
                        if #lastValidFishNotif > 0 then
                            task.spawn(function()
                                local xr_caught = GetRemoteDirect("RE/FishCaught")
                                local xr_visual = GetRemoteDirect("RE/CaughtFishVisual")
                                local xr_notif  = Events.fishNotif

                                Config.YTTA.VisualRotationIndex = 0

                                if xr_caught and #lastValidFishCaught > 0 then
                                    pcall(function() FireLocalEvent(xr_caught, unpack(lastValidFishCaught)) end)
                                end

                                task.wait(0.005)

                                for i = 1, Config.YTTA.NotifCount do
                                    local notifData = lastValidFishNotif
                                    if #_fishNotifHistory > 1 then
                                        Config.YTTA.VisualRotationIndex = Config.YTTA.VisualRotationIndex + 1
                                        local histIdx = ((Config.YTTA.VisualRotationIndex - 1) % #_fishNotifHistory) + 1
                                        notifData = _fishNotifHistory[histIdx]
                                    end

                                    if xr_notif then
                                        pcall(function() FireLocalEvent(xr_notif, unpack(notifData)) end)
                                    end

                                    updateReplionInventory(notifData)

                                    if xr_visual and #lastValidCaughtVisual > 0 then
                                        local visualData = lastValidCaughtVisual
                                        if #lastValidCaughtVisualHistory > 1 then
                                            local vIdx = ((Config.YTTA.VisualRotationIndex - 1) % #lastValidCaughtVisualHistory) + 1
                                            visualData = lastValidCaughtVisualHistory[vIdx]
                                        end
                                        pcall(function() FireLocalEvent(xr_visual, unpack(visualData)) end)
                                        pcall(function() triggerRainbowGoldenUpdate(notifData, true) end)
                                    end

                                    -- Fire exclaim "!"
                                    pcall(function()
                                        if Events.exclaimEvent then
                                            local char = LocalPlayer.Character
                                            if char then
                                                local head = char:FindFirstChild("Head")
                                                if head then
                                                    FireLocalEvent(Events.exclaimEvent, {
                                                        UUID = HttpService:GenerateGUID(false),
                                                        Channel = "All",
                                                        TextData = {
                                                            AttachTo = "Head",
                                                            Text = "!",
                                                            EffectType = "Exclaim",
                                                            TextColor = Color3.fromRGB(0, 195, 255),
                                                        },
                                                        Duration = 0.5,
                                                        Container = head,
                                                    })
                                                end
                                            end
                                        end
                                    end)

                                    task.wait(0.01)

                                    if xr_caught and #lastValidFishCaught > 0 then
                                        pcall(function() FireLocalEvent(xr_caught, unpack(lastValidFishCaught)) end)
                                    end

                                    if i < Config.YTTA.NotifCount and Config.YTTA.NotifDelay > 0 then
                                        task.wait(Config.YTTA.NotifDelay)
                                    end
                                end
                            end)
                        end
                    else
                        -- Catch timeout, lanjut ke cast berikutnya
                        needCast = true
                    end
                else
                    if isCaught then
                        isCaught = false
                        if #(_G.SavedData.FishNotif or {}) > 0 then
                            lastValidFishNotif = deepCopyArr(_G.SavedData.FishNotif)
                        end
                    end
                end
            end

            blatantFishCycleCount = blatantFishCycleCount + 1
        end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end

        if not ok then
            warn("[KysHub] UB error: " .. tostring(err))
            task.wait(0.05)
        end
    end
end
                                        
local function UB_start()
    if Config.UB.Active then return end
    _G.QHBetaAnimSpeed = true
    UB_init(); Config.UB.Active = true; needCast = true
    _G.NotifQueue = {}; _G.NotifActive = 0; isCaught = false
    Config.UB.Stats.startTime = tick()
    Tasks.ubtask = task.spawn(ub_loop)
    NotifySuccess("Fishing Ultra", "Aktif!")
end

local function UB_stop()
    if not Config.UB.Active then return end
    _G.QHBetaAnimSpeed = false
    Config.UB.Active = false; _G.NotifQueue = {}; _G.NotifActive = 0
    -- Disconnect animation speed-up when Quantum Fishing Beta stops
    pcall(function() SkinAnimation.DisconnectSpeedUp() end)
    safeFire(function() if Config.UB.Remotes.CancelFishingInputs then CallRemote(Config.UB.Remotes.CancelFishingInputs) end end)
    task.wait(0.3)
    if Tasks.ubtask then pcall(function() task.cancel(Tasks.ubtask) end); Tasks.ubtask = nil end
    NotifyWarning("Fishing Ultra", "Dimatikan.")
end

local function onToggleUB(value)
    if value then
        enableNotifDelay(); enableBlockNotif()
        pcall(function() if isMobile and Controllers.Notification and origPlaySmallItemObtained then Controllers.Notification.PlaySmallItemObtained = function() return end end end)
        patchInstantBaitOverrideToCastPosition(true); equipRod(); task.wait(0.5); UB_start()
    else
        UB_stop(); patchInstantBaitOverrideToCastPosition(false); disableNotifDelay(); disableBlockNotif()
        pcall(function() if isMobile and Controllers.Notification and origPlaySmallItemObtained then Controllers.Notification.PlaySmallItemObtained = origPlaySmallItemObtained end end)
    end
end

-- Separate handler for Quantum YTTA (FIXED VERSION)
local function onToggleYTTA(value)
    Config.amblatant = value
    if value then
        -- FIXED: Reset counter saat aktif
        Config.YTTA.RainbowCounter = 0
        Config.YTTA.GoldenCounter = 0
        Config.YTTA.FishCounter = 0
        Config.YTTA.VisualRotationIndex = 0

        enableNotifDelay(); enableBlockNotif()
        pcall(function() if isMobile and Controllers.Notification and origPlaySmallItemObtained then Controllers.Notification.PlaySmallItemObtained = function() return end end end)
        patchInstantBaitOverrideToCastPosition(true); equipRod(); task.wait(0.5)
        saveCount = 0; needCast = true
        UB_init(); Config.UB.Active = true; needCast = true
        _G.NotifQueue = {}; _G.NotifActive = 0; isCaught = false
        Config.UB.Stats.startTime = tick()
        Tasks.ubtask = task.spawn(ub_loop)
        NotifySuccess("Fishing Extreme", "Aktif! Rainbow counter reset.")
    else
        Config.UB.Active = false; _G.NotifQueue = {}; _G.NotifActive = 0
        patchInstantBaitOverrideToCastPosition(false); disableNotifDelay(); disableBlockNotif()
        pcall(function() if isMobile and Controllers.Notification and origPlaySmallItemObtained then Controllers.Notification.PlaySmallItemObtained = origPlaySmallItemObtained end end)
        safeFire(function() if Config.UB.Remotes.CancelFishingInputs then CallRemote(Config.UB.Remotes.CancelFishingInputs) end end)
        task.wait(0.3)
        if Tasks.ubtask then pcall(function() task.cancel(Tasks.ubtask) end); Tasks.ubtask = nil end
        NotifyWarning("Fishing Extreme", "Dimatikan.")
    end
end

UB_init()

task.spawn(function()
    while true do
        task.wait(5)
        if Config.UB.Active and lastTimeFishCaught ~= nil and os.clock() - lastTimeFishCaught >= 20 and blatantFishCycleCount > 1 then
            needCast = true; saveCount = 0; blatantFishCycleCount = 1; lastTimeFishCaught = os.clock()
            safeFire(function() if Config.UB.Remotes.CancelFishingInputs then CallRemote(Config.UB.Remotes.CancelFishingInputs) end end)
        end
    end
end)
-- AUTO SELL
local function RunAutoSellLoop()
    if Tasks.AutoSellThread then pcall(function() task.cancel(Tasks.AutoSellThread) end); Tasks.AutoSellThread = nil end
    Tasks.AutoSellThread = task.spawn(function()
        while Config.AutoSellState do
            if not Events.sell or not Events.sell.Parent then
                Events.sell = GetServerRemote("RF/SellAllItems")
                if not Events.sell then NotifyError("Auto Sell", "Remote tidak ditemukan!"); task.wait(3); continue end
            end
            if Config.AutoSellMethod == "Delay" then
                local delaySeconds = math.clamp(Config.AutoSellValue, 1, 9999)
                task.wait(delaySeconds)
                if Config.AutoSellState then
                    local ok = pcall(function()
                        if Events.sell:IsA("RemoteFunction") then Events.sell:InvokeServer()
                        elseif Events.sell:IsA("RemoteEvent") then Events.sell:FireServer() end
                    end)
                    -- Only show success notif silently (no spam)
                    if ok then pcall(function() if WindUI and WindUI.Notify then WindUI:Notify({ Title = "[OK] Auto Sell", Content = "Executed", Duration = 1, Icon = "check" }) end end) end
                end
            elseif Config.AutoSellMethod == "Count" then
                local targetCount = math.clamp(Config.AutoSellValue, 1, 9999)
                local startCount = _sessionCatchCount
                while Config.AutoSellState and (_sessionCatchCount - startCount) < targetCount do task.wait(0.5) end
                if Config.AutoSellState then
                    local ok = pcall(function()
                        if Events.sell:IsA("RemoteFunction") then Events.sell:InvokeServer()
                        elseif Events.sell:IsA("RemoteEvent") then Events.sell:FireServer() end
                    end)
                    -- Only show success notif silently (no spam)
                    if ok then pcall(function() if WindUI and WindUI.Notify then WindUI:Notify({ Title = "[OK] Auto Sell", Content = "Sold " .. targetCount .. " fish", Duration = 1, Icon = "check" }) end end) end
                end
            else task.wait(1) end
        end
    end)
end
-- HELPER FUNCTIONS
local function GetPlayerDataReplion()
    local result = nil
    pcall(function()
        local m = ReplicatedStorage:WaitForChild("Packages", 5):WaitForChild("Replion", 5)
        result = require(m).Client:WaitReplion("Data", 5)
    end)
    return result or PlayerData or nil
end

local function IsFishItem(item)
    local isFish = false
    pcall(function()
        -- Fish items have Weight in metadata
        if item.Metadata and item.Metadata.Weight then isFish = true end
        -- Check via ItemUtility probability data (fish have Probability)
        if ItemUtility then
            local data = ItemUtility:GetItemData(item.Id)
            if data and data.Probability then isFish = true end
            if data and data.Data and data.Data.Type and string.lower(tostring(data.Data.Type)) == "fish" then isFish = true end
        end
    end)
    return isFish
end

local function GetFishNameAndRarity(item)
    local name = item.Identifier or "Unknown"
    local rarity = item.Metadata and item.Metadata.Rarity or "COMMON"
    local itemID = item.Id
    local itemData = nil
    pcall(function()
        if ItemUtility then
            itemData = ItemUtility:GetItemData(itemID)
            if not itemData then local numericID = tonumber(item.Id) or tonumber(item.Identifier); if numericID then itemData = ItemUtility:GetItemData(numericID) end end
        end
    end)
    if itemData and itemData.Data and itemData.Data.Name then name = itemData.Data.Name end
    if item.Metadata and item.Metadata.Rarity then rarity = item.Metadata.Rarity
    elseif itemData and itemData.Probability and itemData.Probability.Chance and TierUtility then
        local tierObj = nil
        pcall(function() tierObj = TierUtility:GetTierFromRarity(itemData.Probability.Chance) end)
        if tierObj and tierObj.Name then rarity = tierObj.Name end
    end
    return name, rarity
end

local function GetItemMutationString(item)
    if item.Metadata and item.Metadata.Shiny == true then return "Shiny" end
    return item.Metadata and item.Metadata.VariantId or ""
end
-- AUTO FAVORITE
local function RunAutoFavLoop(isUnfavorite)
    local replion = GetPlayerDataReplion()
    if not replion then return end
    if not Events.favorite then Events.favorite = GetServerRemote("RE/FavoriteItem"); if not Events.favorite then NotifyError("Auto Fav", "Remote tidak ditemukan!"); return end end
    local ok, invData = pcall(function() return replion:GetExpect("Inventory") end)
    if not ok or not invData or not invData.Items then return end
    local targets = {}
    for _, item in ipairs(invData.Items) do
        local isAlreadyFav = (item.IsFavorite or item.Favorited)
        local shouldProcess = isUnfavorite and isAlreadyFav or (not isUnfavorite and not isAlreadyFav)
        if shouldProcess then
            local _, rarity = GetFishNameAndRarity(item)
            local mutation = GetItemMutationString(item)
            local match = false
            if #Config.SelectedRarities > 0 then for _, r in ipairs(Config.SelectedRarities) do if string.lower(rarity) == string.lower(r) then match = true; break end end end
            if not match and #Config.SelectedMutations > 0 then if table.find(Config.SelectedMutations, mutation) then match = true end end
            if match and item.UUID then table.insert(targets, item.UUID) end
        end
    end
    if #targets > 0 then
        NotifyInfo(isUnfavorite and "Unfavoriting" or "Favoriting", "Memproses " .. #targets .. " ikan...")
        for _, uuid in ipairs(targets) do
            if (isUnfavorite and not Config.AutoUnfavoriteState) or (not isUnfavorite and not Config.AutoFavoriteState) then break end
            pcall(function() if Events.favorite then Events.favorite:FireServer(uuid) end end)
            task.wait(0.3)
        end
    else NotifyInfo(isUnfavorite and "Unfavoriting" or "Favoriting", "Tidak ada ikan yang cocok.") end
end
-- ENCHANT SYSTEM
local STONE_IDS = {["Enchant Stones"]=10, ["Evolved Enchant Stone"]=558}
local enchantIdMap = {
    ["Big Hunter 1"]=3,["Cursed 1"]=12,["Empowered 1"]=9,["Glistening 1"]=1,["Gold Digger 1"]=4,
    ["Leprechaun 1"]=5,["Leprechaun 2"]=6,["Mutation Hunter 1"]=7,["Mutation Hunter 2"]=14,
    ["Prismatic 1"]=13,["Reeler 1"]=2,["Stargazer 1"]=8,["Stormhunter 1"]=11,["XPerienced 1"]=10,
    ["SECRET Hunter"]=16,["Shark Hunter"]=20,["Stargazer II"]=17,["Stormhunter II"]=19,
    ["Leprechaun II"]=6,["Reeler II"]=21,["Mutation Hunter III"]=22,["Fairy Hunter 1"]=15
}

_G.SelectedStoneType = _G.SelectedStoneType or "Enchant Stones"
_G.TargetEnchantBasic = _G.TargetEnchantBasic or "Big Hunter 1"
_G.TargetEnchantEvolved = _G.TargetEnchantEvolved or "Prismatic 1"
_G.AutoEnchant = _G.AutoEnchant or false

local function findEnchantStones()
    local stones = {}
    pcall(function()
        local inv = PlayerData and PlayerData:GetExpect("Inventory")
        if not inv or not inv.Items then return end
        local targetId = STONE_IDS[_G.SelectedStoneType]
        for _, item in ipairs(inv.Items) do if item.Id == targetId then table.insert(stones, {UUID=item.UUID, Id=item.Id}) end end
    end)
    return stones
end

local function countHotbarSlots()
    local count = 5
    pcall(function()
        local backpackGui = LocalPlayer.PlayerGui:FindFirstChild("Backpack")
        if not backpackGui then return end
        local display = backpackGui:FindFirstChild("Display"); if not display then return end
        local c = 0
        for _, child in ipairs(display:GetChildren()) do if child:IsA("ImageButton") then c = c + 1 end end
        count = c
    end)
    return count
end

local function getCurrentRodEnchant()
    local enchantId = nil
    pcall(function()
        if not PlayerData then return end
        local equipped = PlayerData:Get("EquippedItems"); if not equipped then return end
        local rods = PlayerData:GetExpect("Inventory")
        if not rods or not rods["Fishing Rods"] then return end
        for _, uuid in pairs(equipped) do
            for _, rod in ipairs(rods["Fishing Rods"]) do
                if rod.UUID == uuid and rod.Metadata and rod.Metadata.EnchantId then enchantId = rod.Metadata.EnchantId end
            end
        end
    end)
    return enchantId
end
-- EVENT DATA
local megCheckRadius = 150
local autoEventTPEnabled = false
local autoEventThread = nil
local selectedEvents = {}
local createdEventPlatform = nil

local eventData = {
    ["Worm Hunt"]       = {TargetName="Model",           Locations={Vector3.new(2190.85,-1.4,97.575),Vector3.new(-2450.679,-1.4,139.731),Vector3.new(-267.479,-1.4,5188.531),Vector3.new(-327,-1.4,2422)}, PlatformY=107, Priority=1},
    ["Megalodon Hunt"]  = {TargetName="Megalodon Hunt",  Locations={Vector3.new(-1076.3,-1.4,1676.2),Vector3.new(-1191.8,-1.4,3597.3),Vector3.new(412.7,-1.4,4134.4)}, PlatformY=107, Priority=2},
    ["Ghost Shark Hunt"]= {TargetName="Ghost Shark Hunt",Locations={Vector3.new(489.559,-1.35,25.406),Vector3.new(-1358.216,-1.35,4100.556),Vector3.new(627.859,-1.35,3798.081)}, PlatformY=107, Priority=3},
    ["Shark Hunt"]      = {TargetName="Shark Hunt",      Locations={Vector3.new(1.65,-1.35,2095.725),Vector3.new(1369.95,-1.35,930.125),Vector3.new(-1585.5,-1.35,1242.875),Vector3.new(-1896.8,-1.35,2634.375)}, PlatformY=107, Priority=4},
    ["Thunderzilla Hunt"]={TargetName="Shocked",         Locations={Vector3.new(2071.847,-2.673,15.144)}, PlatformY=107, Priority=5},
}

local function destroyEventPlatform()
    if createdEventPlatform then pcall(function() createdEventPlatform:Destroy() end); createdEventPlatform = nil end
end

local function createAndTeleportToPlatform(targetPos, y)
    local character = game.Players.LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local desiredPos = Vector3.new(targetPos.X, y, targetPos.Z)
    if createdEventPlatform and createdEventPlatform.Parent then
        createdEventPlatform.Position = desiredPos
    else
        destroyEventPlatform()
        local platform = Instance.new("Part")
        platform.Size = Vector3.new(5, 1, 5); platform.Position = desiredPos; platform.Anchored = true
        platform.Transparency = 1; platform.CanCollide = true; platform.Color = Color3.fromRGB(0,170,255)
        platform.Name = "EventPlatform"; platform.Parent = Workspace
        createdEventPlatform = platform
    end
    hrp.CFrame = CFrame.new(createdEventPlatform.Position + Vector3.new(0, 3, 0))
end

local function runMultiEventTP()
    while autoEventTPEnabled do
        local sorted = {}
        for _, e in ipairs(selectedEvents) do if eventData[e] then table.insert(sorted, eventData[e]) end end
        table.sort(sorted, function(a, b) return a.Priority < b.Priority end)
        for _, config in ipairs(sorted) do
            if not autoEventTPEnabled then break end
            local foundTarget, foundPos = nil, nil
            if config.TargetName == "Model" then
                local menuRings = Workspace:FindFirstChild("!!! MENU RINGS")
                if menuRings then
                    for _, props in ipairs(menuRings:GetChildren()) do
                        if props.Name == "Props" then
                            local model = props:FindFirstChild("Model")
                            if model and model.PrimaryPart then
                                local modelPos = model.PrimaryPart.Position
                                for _, loc in ipairs(config.Locations) do
                                    if (modelPos - loc).Magnitude <= megCheckRadius then foundTarget, foundPos = model, modelPos; break end
                                end
                            end
                        end
                        if foundTarget then break end
                    end
                end
            else
                for _, d in ipairs(Workspace:GetDescendants()) do
                    if d.Name == config.TargetName then
                        local pos = nil
                        if d:IsA("BasePart") then pos = d.Position elseif d.PrimaryPart then pos = d.PrimaryPart.Position end
                        if pos then
                            for _, loc in ipairs(config.Locations) do
                                if (pos - loc).Magnitude <= megCheckRadius then foundTarget, foundPos = d, pos; break end
                            end
                        end
                    end
                    if foundTarget then break end
                end
            end
            if foundTarget and foundPos then createAndTeleportToPlatform(foundPos, config.PlatformY); break end
        end
        task.wait(0.1)
    end
    destroyEventPlatform()
end

local STONE_IDS = {
    ["Enchant Stones"]        = 10,
    ["Evolved Enchant Stone"] = 558
}

local enchantIdMap = {
    ["Big Hunter 1"] = 3, ["Cursed 1"] = 12, ["Empowered 1"] = 9,
    ["Glistening 1"] = 1, ["Gold Digger 1"] = 4, ["Leprechaun 1"] = 5,
    ["Leprechaun 2"] = 6, ["Mutation Hunter 1"] = 7, ["Mutation Hunter 2"] = 14,
    ["Prismatic 1"] = 13, ["Reeler 1"] = 2, ["Stargazer 1"] = 8,
    ["Stormhunter 1"] = 11, ["XPerienced 1"] = 10,
    ["SECRET Hunter"] = 16, ["Shark Hunter"] = 20, ["Stargazer II"] = 17,
    ["Stormhunter II"] = 19, ["Mutation Hunter II"] = 14, ["Leprechaun II"] = 6,
    ["Reeler II"] = 21, ["Mutation Hunter III"] = 22, ["Fairy Hunter 1"] = 15
}

_G.SelectedStoneType     = _G.SelectedStoneType or "Enchant Stones"
_G.TargetEnchantBasic    = _G.TargetEnchantBasic or "Big Hunter 1"
_G.TargetEnchantEvolved  = _G.TargetEnchantEvolved or "Prismatic 1"
_G.AutoEnchant           = _G.AutoEnchant or false

local basicEnchantNames = {
    "Big Hunter 1", "Cursed 1", "Empowered 1", "Glistening 1",
    "Gold Digger 1", "Leprechaun 1", "Leprechaun 2",
    "Mutation Hunter 1", "Mutation Hunter 2", "Prismatic 1",
    "Reeler 1", "Stargazer 1", "Stormhunter 1", "XPerienced 1"
}

local evolvedEnchantNames = {
    "Prismatic 1", "Cursed 1", "Gold Digger 1", "Empowered 1",
    "SECRET Hunter", "Shark Hunter", "Stargazer II", "Stormhunter II",
    "Mutation Hunter II", "Leprechaun II", "Reeler II", "Mutation Hunter III",
    "Fairy Hunter 1"
}

local function gStone()
    local it = PlayerData and PlayerData:GetExpect("Inventory")
    if not it or not it.Items then return 0 end
    local targetId = STONE_IDS[_G.SelectedStoneType]
    local total = 0
    for _, v in ipairs(it.Items) do
        if v.Id == targetId then
            total = total + (v.Quantity or 1)
        end
    end
    return total
end

local function countEnchantStoneById(stoneId)
    local it = PlayerData and PlayerData:GetExpect("Inventory")
    if not it or not it.Items then return 0 end
    local total = 0
    for _, v in ipairs(it.Items) do
        if v.Id == stoneId then
            total = total + (v.Quantity or 1)
        end
    end
    return total
end

local function countDisplayImageButtons()
    local backpackGui = LocalPlayer.PlayerGui:FindFirstChild("Backpack")
    if not backpackGui then return 0 end
    local display = backpackGui:FindFirstChild("Display")
    if not display then return 0 end
    local count = 0
    for _, child in ipairs(display:GetChildren()) do
        if child:IsA("ImageButton") then 
            count += 1 
        end
    end
    return count
end

local function findEnchantStones()
    local inv = PlayerData and PlayerData:GetExpect("Inventory")
    if not inv or not inv.Items then return {} end
    local targetId = STONE_IDS[_G.SelectedStoneType]
    local stones = {}
    for _, item in ipairs(inv.Items) do
        if item.Id == targetId then
            table.insert(stones, {
                UUID = item.UUID,
                Quantity = item.Quantity or 1,
                Id = item.Id
            })
        end
    end
    return stones
end

local function getEquippedRodName()
    local equipped = PlayerData and PlayerData:Get("EquippedItems")
    if not equipped then return "None" end
    local rods = PlayerData:GetExpect("Inventory")
    if not rods or not rods["Fishing Rods"] then return "None" end
    for _, uuid in pairs(equipped) do
        for _, rod in ipairs(rods["Fishing Rods"]) do
            if rod.UUID == uuid then
                local itemData = ItemUtility and ItemUtility:GetItemData(rod.Id)
                return (itemData and itemData.Data and itemData.Data.Name) or rod.ItemName or "None"
            end
        end
    end
    return "None"
end

local function getCurrentRodEnchant()
    local equipped = PlayerData and PlayerData:Get("EquippedItems")
    if not equipped then return nil end
    local rods = PlayerData:GetExpect("Inventory")
    if not rods or not rods["Fishing Rods"] then return nil end
    for _, uuid in pairs(equipped) do
        for _, rod in ipairs(rods["Fishing Rods"]) do
            if rod.UUID == uuid and rod.Metadata and rod.Metadata.EnchantId then
                return rod.Metadata.EnchantId
            end
        end
    end
    return nil
end

-- Count evolved enchant stones
local function gEvolvedStone()
    return countEnchantStoneById(558)
end

-- ============================================
-- ATLANTIS MACHINE (NEW V2)
local AtlantisConfig = {
    AutoAtlantisMachine = false,
    IsRunning = false,
    MachineThread = nil,
    LastFishingPosition = nil,
    SelectedRarities = { Rare = true, Epic = true },
    SkipFavorited = true
}

-- Koordinat 
local ATLANTIS_MACHINE_CF = CFrame.new(-3173.55419921875, -640.4428100585938, -10449.6025390625, 0.044499535113573074, -6.89831125555429e-08, -0.9990094304084778, 5.832494665014565e-08, 1, -6.645350936196337e-08, 0.9990094304084778, -5.5310017899046215e-08, 0.044499535113573074)

local function OpenAtlantisUI()
    local ok = pcall(function()
        local guiControl = require(ReplicatedStorage.Modules.GuiControl)
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui or not playerGui:FindFirstChild("Atlantis Machine") then
            error("Atlantis Machine GUI belum ada")
        end

        if not guiControl:IsOpen("Atlantis Machine") then
            guiControl:Open("Atlantis Machine")
        end
    end)
    return ok
end

local function GetAtlantisFishCount()
    local count = 0
    pcall(function()
        local replion = GetPlayerDataReplion()
        if not replion then return end
        local inv = replion:GetExpect("Inventory")
        if not inv or not inv.Items then return end
        for _, item in ipairs(inv.Items) do
            local _, rarity = GetFishNameAndRarity(item)
            if rarity and (
                rarity == "Rare" or rarity == "Epic" or
                rarity == "Legendary" or rarity == "Mythic" or
                rarity == "SECRET"
            ) then count = count + 1 end
        end
    end)
    return count
end

local function NormalizeAtlantisRarity(rarity)
    rarity = tostring(rarity or "")
    local lower = string.lower(rarity)
    if lower == "rare" then return "Rare" end
    if lower == "uncommon" then return "Uncommon" end
    if lower == "epic" then return "Epic" end
    if lower == "legendary" then return "Legendary" end
    if lower == "mythic" or lower == "mythical" then return "Mythic" end
    if lower == "secret" then return "SECRET" end
    if lower == "common" then return "Common" end
    return rarity
end

local function IsAtlantisFishAllowed(item)
    if not IsFishItem(item) then return false end
    if AtlantisConfig.SkipFavorited and (item.IsFavorite or item.Favorited) then return false end
    local _, rarity = GetFishNameAndRarity(item)
    rarity = NormalizeAtlantisRarity(rarity)
    return AtlantisConfig.SelectedRarities[rarity] == true
end

local function GetFilteredAtlantisFishCount()
    local count = 0
    pcall(function()
        local replion = GetPlayerDataReplion()
        if not replion then return end
        local inv = replion:GetExpect("Inventory")
        if not inv or not inv.Items then return end
        for _, item in ipairs(inv.Items) do
            if IsAtlantisFishAllowed(item) then
                count += 1
            end
        end
    end)
    return count
end

local function SacrificeAllFishToAtlantis()
    local hrp = getHRP()
    if not hrp then return false end

    -- Simpan posisi awal
    AtlantisConfig.LastFishingPosition = hrp.CFrame

    -- Teleport LANGSUNG ke Atlantis Machine (skip Underwater City)
    NotifyInfo("Atlantis", "Teleport langsung ke Atlantis Machine...")
    local hrp2 = getHRP()
    if hrp2 then
        hrp2.CFrame = ATLANTIS_MACHINE_CF + Vector3.new(0, 5, 0)
    end
    task.wait(0.5)

    -- Buka UI Atlantis 
    local uiOpened = OpenAtlantisUI()
    if uiOpened then
        NotifyInfo("Atlantis", "UI Atlantis terbuka!")
        task.wait(0.3)
    else
        NotifyWarning("Atlantis", "UI remote gagal, lanjut sacrifice...")
    end

    -- Reload remote
    local sacrificeRemote = GetServerRemote("RF/SacrificeAtlantisFish")
    local effectRemote    = GetServerRemote("RE/AtlantisMachineEffect")

    if not sacrificeRemote then
        NotifyError("Atlantis", "Remote Sacrifice tidak ditemukan!")
        local h = getHRP()
        if h and AtlantisConfig.LastFishingPosition then
            h.CFrame = AtlantisConfig.LastFishingPosition
        end
        return false
    end

    -- Kumpulkan UUID ikan sesuai filter Atlantis
    local fishToSacrifice = {}
    pcall(function()
        local replion = GetPlayerDataReplion()
        if not replion then return end
        local inv = replion:GetExpect("Inventory")
        if not inv or not inv.Items then return end
        for _, item in ipairs(inv.Items) do
            if IsAtlantisFishAllowed(item) then
                if item.UUID then table.insert(fishToSacrifice, item.UUID) end
            end
        end
    end)

    if #fishToSacrifice == 0 then
        NotifyWarning("Atlantis", "Tidak ada ikan yang cocok dengan filter Atlantis!")
        local h = getHRP()
        if h and AtlantisConfig.LastFishingPosition then
            h.CFrame = AtlantisConfig.LastFishingPosition
        end
        return false
    end

    NotifyInfo("Atlantis", "Sacrifice " .. #fishToSacrifice .. " ikan...")

    -- Sacrifice satu per satu
    local sacrificedCount = 0
    for _, uuid in ipairs(fishToSacrifice) do
        if AtlantisConfig.AutoAtlantisMachine and not AtlantisConfig.IsRunning then break end
        local ok, result = pcall(function() return sacrificeRemote:InvokeServer(uuid) end)
        if ok and (result == true or (type(result) == "table" and result.Success == true)) then
            sacrificedCount = sacrificedCount + 1
        end
        task.wait(0.25)
    end

    task.wait(1)

    -- Jangan panggil SacrificeAtlantisSellAll di mode filter, supaya Legendary/Mythic/SECRET tidak ikut terkirim.

    -- Fire effect
    if effectRemote then
        pcall(function() FireLocalEvent(effectRemote) end)
    end

    if sacrificedCount > 0 then
        NotifySuccess("Atlantis", "Sacrifice " .. sacrificedCount .. " ikan berhasil!")
    else
        NotifyWarning("Atlantis", "Tidak ada ikan yang berhasil di-sacrifice. Cek filter/favorite/boost aktif.")
    end
    task.wait(1.5)

    return sacrificedCount > 0
end

local function RunAutoAtlantisMachine()
    if AtlantisConfig.MachineThread then
        pcall(function() task.cancel(AtlantisConfig.MachineThread) end)
        AtlantisConfig.MachineThread = nil
    end
    AtlantisConfig.IsRunning = true

    -- SAVE ORIGINAL POSITION
    local originalPos = nil
    local hrp = getHRP()
    if hrp then originalPos = hrp.CFrame end

    AtlantisConfig.MachineThread = task.spawn(function()
        while AtlantisConfig.AutoAtlantisMachine and AtlantisConfig.IsRunning do
            local ok, err = pcall(function()
                local fishCount = GetFilteredAtlantisFishCount()
                if fishCount < 5 then
                    NotifyInfo("Atlantis", "Fish kurang (" .. fishCount .. "/5). Menunggu...")
                    task.wait(5)
                    return
                end
                NotifyInfo("Atlantis", "Fish cukup! (" .. fishCount .. ") Mulai sacrifice...")
                SacrificeAllFishToAtlantis()
            end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end
            if not ok then
                warn("Atlantis error: " .. tostring(err))
            end
            if not AtlantisConfig.AutoAtlantisMachine then break end
            task.wait(5)
        end

        -- RESTORE ORIGINAL POSITION
        if originalPos then
            local h = getHRP()
            if h then
                h.CFrame = originalPos
                NotifySuccess("Atlantis", "Kembali ke posisi semula!")
            end
        end
        AtlantisConfig.IsRunning = false
        NotifyInfo("Atlantis", "Auto Atlantis Machine berhenti.")
    end)
end

local function StopAutoAtlantisMachine()
    AtlantisConfig.AutoAtlantisMachine = false
    AtlantisConfig.IsRunning = false
    if AtlantisConfig.MachineThread then
        pcall(function() task.cancel(AtlantisConfig.MachineThread) end)
        AtlantisConfig.MachineThread = nil
    end
    NotifyWarning("Atlantis", "Dimatikan.")
end
-- PET & EGG SYSTEM
local PetEggConfig = {
    AutoHatch = false,
    AutoHatchThread = nil,
    SelectedEggType = "Founder",
    HatchAmount = 1,
    InstantHatchEnabled = false,
    AutoEquipBest = false,
}

local function PurchaseEgg(eggType, amount)
    if not Events.PurchaseEgg then
        Events.PurchaseEgg = GetServerRemote("RF/Pets/PurchaseEgg")
    end
    if not Events.PurchaseEgg then
        NotifyError("Egg", "Remote PurchaseEgg tidak ditemukan!")
        return 0
    end
    local bought = 0
    for i = 1, amount do
        local ok = pcall(function()
            Events.PurchaseEgg:InvokeServer(eggType)
        end)
        if ok then
            bought = bought + 1
        else
            break
        end
        task.wait(0.3)
    end
    return bought
end

local function OpenEgg(eggType)
    if not Events.OpenEgg then
        Events.OpenEgg = GetServerRemote("RF/Pets/OpenEgg")
    end
    if not Events.OpenEgg then
        NotifyError("Egg", "Remote OpenEgg tidak ditemukan!")
        return false
    end
    local ok = pcall(function()
        Events.OpenEgg:InvokeServer(eggType)
    end)
    return ok
end

local function StartEgg()
    if not Events.StartEgg then
        Events.StartEgg = GetServerRemote("RF/Pets/StartEgg")
    end
    if not Events.StartEgg then return false end
    local ok = pcall(function() Events.StartEgg:InvokeServer() end)
    return ok
end

local function OpenReadyEgg()
    if not Events.OpenReadyEgg then
        Events.OpenReadyEgg = GetServerRemote("RF/Pets/OpenReadyEgg")
    end
    if not Events.OpenReadyEgg then return false end
    local ok = pcall(function() Events.OpenReadyEgg:InvokeServer() end)
    return ok
end

local function InstantHatch()
    if not Events.InstantHatch then
        Events.InstantHatch = GetServerRemote("RF/Pets/InstantHatch")
    end
    if not Events.InstantHatch then
        NotifyError("Hatch", "Remote InstantHatch tidak ditemukan!")
        return false
    end
    local ok = pcall(function() Events.InstantHatch:InvokeServer() end)
    if ok then
        NotifySuccess("Hatch", "Instant Hatch berhasil!")
    end
    return ok
end

local function EquipPet(petUUID)
    if not Events.PetEquip then
        Events.PetEquip = GetServerRemote("RF/Pets/Equip")
    end
    if not Events.PetEquip then return false end
    local ok = pcall(function() Events.PetEquip:InvokeServer(petUUID) end)
    return ok
end

local function UnequipPet(petUUID)
    if not Events.PetUnequip then
        Events.PetUnequip = GetServerRemote("RF/Pets/Unequip")
    end
    if not Events.PetUnequip then return false end
    local ok = pcall(function() Events.PetUnequip:InvokeServer(petUUID) end)
    return ok
end


local function RunAutoHatch()
    if PetEggConfig.AutoHatchThread then
        pcall(function() task.cancel(PetEggConfig.AutoHatchThread) end)
        PetEggConfig.AutoHatchThread = nil
    end
    PetEggConfig.AutoHatchThread = task.spawn(function()
        while PetEggConfig.AutoHatch do
            local ok, err = pcall(function()
                local purchased = PurchaseEgg(PetEggConfig.SelectedEggType, PetEggConfig.HatchAmount)
                if purchased > 0 then
                    NotifyInfo("Auto Hatch", "Purchased " .. purchased .. " " .. PetEggConfig.SelectedEggType .. " Egg(s)")
                    task.wait(0.5)
                end
                if Events.OpenEgg then
                    pcall(function() Events.OpenEgg:InvokeServer(PetEggConfig.SelectedEggType) end)
                    task.wait(0.3)
                end
                if Events.StartEgg then
                    pcall(function() Events.StartEgg:InvokeServer() end)
                    task.wait(0.3)
                end
                if Events.OpenReadyEgg then
                    pcall(function() Events.OpenReadyEgg:InvokeServer() end)
                    task.wait(0.3)
                end
                if PetEggConfig.InstantHatchEnabled and Events.InstantHatch then
                    pcall(function() Events.InstantHatch:InvokeServer() end)
                end
            end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end
            if not ok then
                warn("AutoHatch error: " .. tostring(err))
            end
            task.wait(2)
        end
    end)
end

local function StopAutoHatch()
    PetEggConfig.AutoHatch = false
    if PetEggConfig.AutoHatchThread then
        pcall(function() task.cancel(PetEggConfig.AutoHatchThread) end)
        PetEggConfig.AutoHatchThread = nil
    end
    NotifyWarning("Auto Hatch", "Dimatikan.")
end

-- Founder Egg specific (paid egg)
local FounderEggConfig = {
    AutoBuy = false,
    IsRunning = false,
    Thread = nil,
    EggLocation = CFrame.new(-4295.189453125, 23.265548706054688, 649.7577514648438, -0.6710231304168701, -7.244620547908198e-08, 0.7414363622665405, -1.815789296699677e-08, 1, 8.127715744876696e-08, -0.7414363622665405, 4.1075931989098535e-08, -0.6710231304168701),
}

local function BuyFounderEgg(amount)
    if not Events.PurchaseEgg then
        Events.PurchaseEgg = GetServerRemote("RF/Pets/PurchaseEgg")
    end
    if not Events.PurchaseEgg then
        NotifyError("Founder Egg", "Remote PurchaseEgg tidak ditemukan!")
        return false
    end
    local bought = 0
    for i = 1, amount do
        local ok = pcall(function()
            Events.PurchaseEgg:InvokeServer("Founder")
        end)
        if ok then
            bought = bought + 1
            NotifySuccess("Founder Egg", "Berhasil beli Founder Egg! (" .. bought .. "/" .. amount .. ")")
        else
            NotifyWarning("Founder Egg", "Gagal beli egg ke-" .. i)
            break
        end
        task.wait(0.5)
    end
    return bought > 0
end

local function RunAutoBuyFounderEgg()
    if FounderEggConfig.Thread then
        pcall(function() task.cancel(FounderEggConfig.Thread) end)
        FounderEggConfig.Thread = nil
    end
    FounderEggConfig.IsRunning = true
    FounderEggConfig.Thread = task.spawn(function()
        while FounderEggConfig.AutoBuy and FounderEggConfig.IsRunning do
            local ok, err = pcall(function()
                local hrp = getHRP()
                if hrp then
                    hrp.CFrame = FounderEggConfig.EggLocation + Vector3.new(0, 5, 0)
                end
                task.wait(1)
                BuyFounderEgg(Config.FounderEggAmount or 1)
            end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end
            if not ok then
                warn("FounderEgg error: " .. tostring(err))
            end
            task.wait(5)
        end
        FounderEggConfig.IsRunning = false
    end)
end

local function StopAutoBuyFounderEgg()
    FounderEggConfig.AutoBuy = false
    FounderEggConfig.IsRunning = false
    if FounderEggConfig.Thread then
        pcall(function() task.cancel(FounderEggConfig.Thread) end)
        FounderEggConfig.Thread = nil
    end
    NotifyWarning("Founder Egg", "Auto-buy dimatikan.")
end
-- [BARU] AUTO CRAFTING
local CraftingConfig = {
    RecipeList = {},
    SelectedRecipeId = nil,
    AutoCraftDelay = 2.0,
}

local function GetCraftingRecipes()
    local recipes = {}
    pcall(function()
        local craftingModule = ReplicatedStorage:FindFirstChild("Shared") and ReplicatedStorage.Shared:FindFirstChild("CraftingRecipes")
        if craftingModule then
            local data = require(craftingModule)
            for id, recipe in pairs(data) do
                table.insert(recipes, {Id=id, Name=recipe.Name or tostring(id)})
            end
        end
    end)
    return recipes
end

local function RunAutoCrafting()
    if Tasks.CraftingThread then pcall(function() task.cancel(Tasks.CraftingThread) end); Tasks.CraftingThread = nil end
    Tasks.CraftingThread = task.spawn(function()
        while Config.AutoCrafting do
            local ok, err = pcall(function()
                if not Events.StartCrafting then Events.StartCrafting = GetServerRemote("RF/StartCrafting") end
                if not Events.ConfirmCrafting then Events.ConfirmCrafting = GetServerRemote("RF/ConfirmCrafting") end
                if not Events.InstantCraft then Events.InstantCraft = GetServerRemote("RE/InstantCraft") end
                if not Events.StartCrafting then return end
                -- Mulai crafting dengan recipe yang dipilih
                if CraftingConfig.SelectedRecipeId then
                    pcall(function() Events.StartCrafting:InvokeServer(CraftingConfig.SelectedRecipeId) end)
                    task.wait(CraftingConfig.AutoCraftDelay)
                    -- Instant craft jika tersedia
                    if Events.InstantCraft then
                        pcall(function() Events.InstantCraft:FireServer() end)
                    end
                    if Events.ConfirmCrafting then
                        pcall(function() Events.ConfirmCrafting:InvokeServer() end)
                        NotifySuccess("Auto Craft", "Crafting selesai!")
                    end
                else
                    -- Jika tidak ada recipe dipilih, coba crafting umum
                    pcall(function() Events.StartCrafting:InvokeServer() end)
                    task.wait(CraftingConfig.AutoCraftDelay)
                    if Events.ConfirmCrafting then pcall(function() Events.ConfirmCrafting:InvokeServer() end) end
                end
            end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end
            if not ok then warn("[QH] AutoCrafting error: " .. tostring(err)) end
            task.wait(Config.CraftingDelay)
        end
    end)
end
-- HELPER: Ambil list ikan dari inventory
local function GetFishList()
    local list = {}
    local groups = {}
    pcall(function()
        local replion = GetPlayerDataReplion()
        if not replion then return end
        local inv = replion:GetExpect("Inventory")
        if not inv or not inv.Items then return end
        
        -- Filter ikan yang sudah ada di tank
        local usedUUIDs = {}
        pcall(function()
            local remote = GetServerRemote("RF/AquariumGetState")
            if remote then
                local state = remote:InvokeServer()
                local tData = state.Data or state
                local tanks = tData.Tanks or (tData.State and tData.State.Tanks)
                if tanks then
                    for _, tank in pairs(tanks) do
                        if tank.Fish then
                            for _, f in pairs(tank.Fish) do
                                if f.Id then usedUUIDs[f.Id] = true end
                                if f.UUID then usedUUIDs[f.UUID] = true end
                            end
                        end
                    end
                end
            end
        end)

        for _, item in ipairs(inv.Items) do
            if item.UUID and IsFishItem(item) and not usedUUIDs[item.UUID] then
                local name, rarity = GetFishNameAndRarity(item)
                -- HANYA tampilkan SECRET, FORGOTTEN, MYTHIC
                local allowed = {SECRET=true, FORGOTTEN=true, MYTHIC=true, Mythic=true}
                if not allowed[rarity] then continue end
                local key = name .. "|" .. rarity
                if not groups[key] then
                    groups[key] = {
                        UUID    = item.UUID,
                        Name    = name,
                        Rarity  = rarity,
                        Count   = 0,
                        Items   = {},
                    }
                end
                groups[key].Count = groups[key].Count + 1
                table.insert(groups[key].Items, item.UUID)
            end
        end
    end)
    for key, group in pairs(groups) do
        group.Display = group.Name .. " [" .. group.Rarity .. "] x" .. group.Count
        table.insert(list, group)
    end
    -- sort: rarity desc then name asc
    local rarityOrder = {FORGOTTEN=8,SECRET=7,MYTHIC=6,Mythic=6,Legendary=5,Epic=4,Rare=3,Uncommon=2,Common=1}
    table.sort(list, function(a,b)
        local ra = rarityOrder[a.Rarity] or 0
        local rb = rarityOrder[b.Rarity] or 0
        if ra ~= rb then return ra > rb end
        return a.Name < b.Name
    end)
    return list
end
-- WALK ON WATER
local walkOnWaterConn, waterPlatform = nil, nil
local function SetWalkOnWater(val)
    Config.WalkOnWater = val
    if walkOnWaterConn then walkOnWaterConn:Disconnect(); walkOnWaterConn = nil end
    if waterPlatform then pcall(function() waterPlatform:Destroy() end); waterPlatform = nil end
    if val then
        waterPlatform = Instance.new("Part")
        waterPlatform.Name = "WaterWalkPlatform"; waterPlatform.Size = Vector3.new(12, 0.5, 12)
        waterPlatform.Transparency = 1; waterPlatform.CanCollide = true; waterPlatform.Anchored = true
        waterPlatform.Parent = Workspace
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.IgnoreWater = false
        walkOnWaterConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character; if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            rayParams.FilterDescendantsInstances = {char, waterPlatform}
            -- Raycast ke bawah dari player
            local result = Workspace:Raycast(hrp.Position + Vector3.new(0, 5, 0), Vector3.new(0, -25, 0), rayParams)
            local isOnWater, waterY = false, nil
            if result then
                local hit = result.Instance
                if hit then
                    local hitName = hit.Name:lower()
                    -- Detect water by name, material, or transparency
                    if hitName:find("water") or hitName:find("ocean") or hitName:find("sea") or hitName:find("lake") then
                        isOnWater = true; waterY = result.Position.Y
                    elseif result.Material == Enum.Material.Water then
                        isOnWater = true; waterY = result.Position.Y
                    elseif hit.Transparency > 0.7 and hit.CanCollide == false then
                        -- Likely water part
                        isOnWater = true; waterY = result.Position.Y
                    end
                end
            end
            -- Fallback: if player is low enough, assume water
            if not isOnWater and hrp.Position.Y <= 5 then
                isOnWater = true; waterY = 0
            end
            if isOnWater and waterY then
                waterPlatform.Position = Vector3.new(hrp.Position.X, waterY + 0.3, hrp.Position.Z)
                waterPlatform.CanCollide = true
            else
                waterPlatform.CanCollide = false
                waterPlatform.Position = Vector3.new(0, -500, 0)
            end
        end)
        NotifySuccess("Walk on Water", "Aktif! Platform akan muncul di atas air.")
    else
        NotifyInfo("Walk on Water", "Nonaktif.")
    end
end
-- CUSTOM NAME
local originalDisplayName = LocalPlayer.DisplayName
local customNameActive = false
local customNameCharConnection, customNameDescendantConnection = nil, nil

local function updateCharacterName(char, name)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if hum then pcall(function() hum.DisplayName = name end) end
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("BillboardGui") then for _, child in pairs(obj:GetDescendants()) do if child:IsA("TextLabel") then pcall(function() child.Text = name end) end end
        elseif obj:IsA("TextLabel") and obj.Parent and obj.Parent.Name == "Head" then pcall(function() obj.Text = name end) end
    end
end

local function ApplyCustomName(name)
    if not name or name == "" then NotifyError("Custom Name", "Nama tidak boleh kosong!"); return end
    customNameActive = true; _G.CustomNameText = name
    pcall(function() LocalPlayer.DisplayName = name end)
    if customNameDescendantConnection then pcall(function() customNameDescendantConnection:Disconnect() end) end
    if customNameCharConnection then pcall(function() customNameCharConnection:Disconnect() end) end
    local char = LocalPlayer.Character
    if char then
        updateCharacterName(char, name)
        pcall(function() customNameDescendantConnection = char.DescendantAdded:Connect(function() if customNameActive then task.wait(0.1); updateCharacterName(char, _G.CustomNameText) end end) end)
    end
    pcall(function()
        customNameCharConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
            task.wait(0.5); if customNameActive then
                updateCharacterName(newChar, _G.CustomNameText)
                if customNameDescendantConnection then pcall(function() customNameDescendantConnection:Disconnect() end) end
                pcall(function() customNameDescendantConnection = newChar.DescendantAdded:Connect(function() if customNameActive then task.wait(0.1); updateCharacterName(newChar, _G.CustomNameText) end end) end)
            end
        end)
    end)
    NotifySuccess("Custom Name", "Nama berubah jadi: " .. name)
end

local function RemoveCustomName()
    customNameActive = false; _G.CustomNameText = nil
    pcall(function() LocalPlayer.DisplayName = originalDisplayName end)
    local char = LocalPlayer.Character; if char then updateCharacterName(char, originalDisplayName) end
    if customNameDescendantConnection then pcall(function() customNameDescendantConnection:Disconnect() end); customNameDescendantConnection = nil end
    if customNameCharConnection then pcall(function() customNameCharConnection:Disconnect() end); customNameCharConnection = nil end
    NotifyInfo("Custom Name", "Nama asli dikembalikan.")
end

local _hiddenTag = false
local function SetHideNametag(val)
    _hiddenTag = val
    local char = LocalPlayer.Character; if not char then return end
    local function processChar(c)
        for _, obj in pairs(c:GetDescendants()) do
            if obj:IsA("BillboardGui") or (obj:IsA("TextLabel") and obj.Parent and obj.Parent.Name == "Head") then
                pcall(function() obj.Enabled = not val end)
            end
        end
    end
    processChar(char)
    pcall(function() LocalPlayer.CharacterAdded:Connect(function(newChar) task.wait(1); if _hiddenTag then processChar(newChar) end end) end)
    if val then NotifySuccess("Hide Nametag", "Nama tersembunyi!") else NotifyInfo("Hide Nametag", "Nama terlihat.") end
end
-- EMOTE - Scan dari game Fish It (ReplicatedStorage.Emotes)
local gameEmotes = {}
local selectedEmote = nil
local currentEmoteTrack = nil

local function scanGameEmotes()
    gameEmotes = {}
    pcall(function()
        local emotesFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Emotes")
        if emotesFolder then
            for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
                if emoteModule:IsA("ModuleScript") then
                    local ok, data = pcall(require, emoteModule)
                    if ok and data and data.AnimationId then
                        gameEmotes[emoteModule.Name] = {
                            AnimationId = data.AnimationId,
                            AnimationPriority = data.AnimationPriority or Enum.AnimationPriority.Action2,
                            PlaybackSpeed = data.PlaybackSpeed or 1,
                            Looped = data.Looped == true,
                        }
                    end
                end
            end
        end
    end)
    -- Fallback: tambahkan emote Roblox default jika game emotes kosong
    if next(gameEmotes) == nil then
        local defaultEmotes = {
            ["Wave"]="rbxassetid://12521004586",["Dance"]="rbxassetid://12521009666",
            ["Dance 2"]="rbxassetid://12521151637",["Laugh"]="rbxassetid://12521018724",
            ["Point"]="rbxassetid://12521007694",["Cheer"]="rbxassetid://12521021991",
        }
        for name, id in pairs(defaultEmotes) do
            gameEmotes[name] = {
                AnimationId = id,
                AnimationPriority = Enum.AnimationPriority.Action2,
                PlaybackSpeed = 1,
                Looped = false,
            }
        end
    end
    print("[Emote] Total emote ditemukan: " .. (function() local c=0; for _ in pairs(gameEmotes) do c=c+1 end; return c end)())
    return gameEmotes
end

local function PlayEmote(emoteName)
    local char = LocalPlayer.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local emoteData = gameEmotes[emoteName]
    if not emoteData then NotifyError("Emote", "Emote '" .. emoteName .. "' tidak ditemukan!"); return end

    -- Stop emote sebelumnya
    if currentEmoteTrack then
        pcall(function() currentEmoteTrack:Stop(0.1) end)
        pcall(function() currentEmoteTrack:Destroy() end)
        currentEmoteTrack = nil
    end

    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    local anim = Instance.new("Animation")
    anim.AnimationId = emoteData.AnimationId
    local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
    if ok and track then
        track.Priority = emoteData.AnimationPriority
        track.Looped = emoteData.Looped
        track:Play(0.1, 1, emoteData.PlaybackSpeed)
        currentEmoteTrack = track
        NotifySuccess("Emote", "'" .. emoteName .. "' dimainkan!")
    else
        NotifyError("Emote", "Gagal load animasi!")
    end
end

local function StopEmote()
    if currentEmoteTrack then
        pcall(function() currentEmoteTrack:Stop(0.1) end)
        pcall(function() currentEmoteTrack:Destroy() end)
        currentEmoteTrack = nil
        NotifyInfo("Emote", "Emote dihentikan!")
    end
end

-- Scan emotes on startup
scanGameEmotes()



-- NO ANIMATION
_G.NoAnimationEnabled = false
local noAnimConnection, noAnimCharConnection = nil, nil
local function StopAllAnimations(char)
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local anim = hum:FindFirstChildOfClass("Animator")
    if anim then for _, track in ipairs(anim:GetPlayingAnimationTracks()) do pcall(function() track:Stop(0) end) end end
end
local function SetupNoAnimation(char)
    if not _G.NoAnimationEnabled then return end
    local hum = char:WaitForChild("Humanoid", 5); if not hum then return end
    StopAllAnimations(char)
    if noAnimConnection then pcall(function() noAnimConnection:Disconnect() end) end
    pcall(function()
        noAnimConnection = hum.AnimationPlayed:Connect(function(track)
            if _G.NoAnimationEnabled then pcall(function() track:Stop(0) end) end
        end)
    end)
end
-- AUTO EVENT
local function RunAutoEvent()
    Tasks.AutoEventThread = task.spawn(function()
        while Config.AutoEvent do
            pcall(function()
                local hrp = getHRP(); if not hrp then return end
                local zones = workspace:FindFirstChild("Zones"); if not zones then return end
                local lev = zones:FindFirstChild("Leviathan's Den")
                if lev then hrp.CFrame = CFrame.new(3474.053, -287.775, 3472.634); task.wait(1) end
                local thunder = zones:FindFirstChild("Ancient Jungle")
                if thunder then hrp.CFrame = CFrame.new(2067.866, 2.028, 10.831); task.wait(1) end
            end)
            task.wait(5)
        end
    end)
end
-- DISABLE OBTAINED
local function SetDisableObtained(val)
    Config.DisableObtained = val
    if val then
        pcall(function() if origPlaySmallItemObtained and Controllers.Notification then Controllers.Notification.PlaySmallItemObtained = function() return end end end)
        NotifySuccess("Disable Obtained", "Notif obtained diblokir!")
    else
        pcall(function() if origPlaySmallItemObtained and Controllers.Notification then Controllers.Notification.PlaySmallItemObtained = origPlaySmallItemObtained end end)
        NotifyInfo("Disable Obtained", "Notif obtained normal.")
    end
end
-- FISH NOTIF HOOK
local _fishNotifConnected = false
task.spawn(function()
    task.wait(3)
    if Events.fishNotif and not _fishNotifConnected then
        _fishNotifConnected = true
        pcall(function()
            Events.fishNotif.OnClientEvent:Connect(function(...)
                local args = {...}
                _G.SavedData.FishNotif = args
                lastValidFishNotif = deepCopyArr(args)
                -- Tambahkan ke history ikan untuk varied notif
                table.insert(_fishNotifHistory, deepCopyArr(args))
                if #_fishNotifHistory > _maxFishHistory then table.remove(_fishNotifHistory, 1) end
                lastTimeFishCaught = os.clock(); isCaught = true
                _sessionCatchCount = _sessionCatchCount + 1
                table.insert(_lastCatchTimestamps, tick())
                if #_lastCatchTimestamps > 60 then table.remove(_lastCatchTimestamps, 1) end
                if Config.UB.Active and not Config.amblatant then return end
                local dummyItem = {Id=args[1], Metadata=args[2]}
                local fishName, fishRarity = GetFishNameAndRarity(dummyItem)
                local weight = string.format("%.2fkg", (args[2] and args[2].Weight) or 0)
                if Config.CustomWebhook and Config.CustomWebhookUrl ~= "" then
                    local shouldSend = true
                    if Config.WebhookRarities and #Config.WebhookRarities > 0 then
                        shouldSend = false
                        for _, r in ipairs(Config.WebhookRarities) do
                            if string.upper(fishRarity) == r then
                                shouldSend = true
                                break
                            end
                        end
                    end
                    if shouldSend and typeof(args[3]) == "table" and args[3].InventoryItem and args[3].InventoryItem.UUID then
                        pcall(function()
                            local payload = HttpService:JSONEncode({
                                username = "KysHub",
                                embeds = {{
                                    title = "Fish Caught!",
                                    color = 0x00aaff,
                                    fields = {
                                        {name="Fish",value=tostring(fishName),inline=true},
                                        {name="Rarity",value=tostring(fishRarity),inline=true},
                                        {name="Weight",value=tostring(weight),inline=true},
                                    },
                                    footer = {text = "KysHub Webhook"}
                                }}
                            })
                            if typeof(request) == "function" then
                                request({Url=Config.CustomWebhookUrl, Method="POST", Headers={["Content-Type"]="application/json"}, Body=payload})
                            end
                        end)
                    end
                end
            end)
        end)
    end
end)

local _exclaimConnected = false
task.spawn(function()
    task.wait(2)
    if Events.exclaimEvent and not _exclaimConnected then
        _exclaimConnected = true
        pcall(function()
          Events.exclaimEvent.OnClientEvent:Connect(function(data)
                if Config.amblatant then return end
                if not Config.AutoCatch and not Config.autoFishing then return end
                if not data or not data.TextData then return end
                if data.TextData.EffectType ~= "Exclaim" then return end
                local container = data.Container; if not container then return end
                local char = LocalPlayer.Character; if not char then return end
                local head = char:FindFirstChild("Head"); if not head or container ~= head then return end
                safeFire(function()
                    task.wait(math.max(Config.CatchDelay, 0.3))
                    for i = 1, 5 do
                        if Events.fishing then pcall(function() Events.fishing:InvokeServer() end) end
                        if Events.fishingRE then pcall(function() Events.fishingRE:FireServer() end) end
                        task.wait(0.05)
                    end
                end)
            end)
        end)
    end
end)
-- PLAYERS TAB
if PlayersTab then
    local ok, err = pcall(function()
        
        PlayersTab_Tabbox1 = PlayersTab:AddTabbox({ Name = "Character Controls", Position = "center" })
        local PlayersTab_Sec_CharacterControls = PlayersTab_Tabbox1:AddTab("Character Controls", "lucide:user")
        PlayersTab_Sec_CharacterControls:AddSlider({ Name = "Walk Speed", Min = 16, Max = 200, Default = 16, Callback = function(val) local char = LocalPlayer.Character; if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = val end end end })
        PlayersTab_Sec_CharacterControls:AddSlider({ Name = "Jump Power", Min = 50, Max = 500, Default = 50, Callback = function(val) local char = LocalPlayer.Character; if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.UseJumpPower = true; hum.JumpPower = val end end end })
        PlayersTab_Sec_CharacterControls:AddButton({ Name = "Reset Speed & Jump", Callback = function() local char = LocalPlayer.Character; if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = 16; hum.UseJumpPower = true; hum.JumpPower = 50 end end; NotifySuccess("Reset", "Speed & Jump normal!") end })

        
        local PlayersTab_Sec_SpecialAbilities = PlayersTab_Tabbox1:AddTab("Special Abilities", "lucide:zap")
        PlayersTab_Sec_SpecialAbilities:AddToggle({
            Name = "Infinite Jump", Default = false,
            Callback = function(val) _G.InfiniteJump = val end
        })
        UserInputService.JumpRequest:Connect(function()
            if _G.InfiniteJump then
                local char = LocalPlayer.Character
                if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
            end
        end)
        PlayersTab_Sec_SpecialAbilities:AddToggle({
            Name = "Noclip", Default = false,
            Callback = function(val)
                _G.Noclip = val
                if val then
                    task.spawn(function()
                        while _G.Noclip do
                            task.wait(0.05)
                            local char = LocalPlayer.Character
                            if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end
                        end
                    end)
                end
            end
        })
        local freezeConnP, frozenCFrameP
        PlayersTab_Sec_SpecialAbilities:AddToggle({
            Name = "Freeze Character", Default = false,
            Callback = function(val)
                if val then
                    local hrp = getHRP()
                    if hrp then
                        frozenCFrameP = hrp.CFrame; _G.FreezeCharacter = true
                        freezeConnP = RunService.Heartbeat:Connect(function() if _G.FreezeCharacter and hrp then hrp.CFrame = frozenCFrameP end end)
                    end
                else
                    _G.FreezeCharacter = false
                    if freezeConnP then pcall(function() freezeConnP:Disconnect() end); freezeConnP = nil end
                end
            end
        })
        PlayersTab_Sec_SpecialAbilities:AddToggle({ Name = "Walk on Water", Default = false, Callback = function(val) SetWalkOnWater(val) end })

        
        PlayersTab_Tabbox2 = PlayersTab:AddTabbox({ Name = "Custom Name", Position = "center" })
        local PlayersTab_Sec_CustomName = PlayersTab_Tabbox2:AddTab("Custom Name", "lucide:sparkles")
        PlayersTab_Sec_CustomName:AddTextInput({ Name = "Custom Name", Placeholder = "Masukkan nama...", Default = "", Callback = function(text) _G.PendingCustomName = text end })
        PlayersTab_Sec_CustomName:AddButton({ Name = "Apply Custom Name", Callback = function() if _G.PendingCustomName and _G.PendingCustomName ~= "" then ApplyCustomName(_G.PendingCustomName) else NotifyError("Custom Name", "Masukkan nama dulu!") end end })
        PlayersTab_Sec_CustomName:AddButton({ Name = "Hapus Custom Name", Callback = function() RemoveCustomName() end })

        
        local PlayersTab_Sec_NametagEmote = PlayersTab_Tabbox2:AddTab("Nametag & Emote", "lucide:user")
        PlayersTab_Sec_NametagEmote:AddToggle({ Name = "Hide Nametag", Default = false, Callback = function(val) SetHideNametag(val) end })
        local emoteNames = {}; for n in pairs(gameEmotes) do table.insert(emoteNames, n) end; table.sort(emoteNames)
        local selectedEmote = emoteNames[1]
        local emoteDropdownValues = {}; for _, name in ipairs(emoteNames) do table.insert(emoteDropdownValues, { Title = name, Icon = "smile" }) end
        PlayersTab_Sec_NametagEmote:AddDropdown({ Name = "Pilih Emote", Values = cleanDropdownValues(emoteDropdownValues), Default = cleanDefaultValue(emoteDropdownValues[1]), Multi = false, Callback = wrapDropdownCallback(function(val) selectedEmote = val.Title end, false)})
        PlayersTab_Sec_NametagEmote:AddButton({ Name = "Play Emote", Callback = function() if selectedEmote then PlayEmote(selectedEmote) end end })
        PlayersTab_Sec_NametagEmote:AddButton({ Name = "Stop Emote", Callback = function() StopEmote() end })


        
        PlayersTab_Tabbox3 = PlayersTab:AddTabbox({ Name = "FreeCam", Position = "center" })
        local PlayersTab_Sec_FreeCam = PlayersTab_Tabbox3:AddTab("FreeCam", "lucide:camera")
        PlayersTab_Sec_FreeCam:AddSlider({ Name = "FreeCam Speed", Min = 1, Max = 20, Default = 5, Callback = function(val) _G.FreeCamSpeed = val end })
        _G.FreeCamMode = _G.FreeCamMode or "Camera Movement"
        local freecamModeValues = {
            { Title = "Camera Movement", Icon = "camera" },
            { Title = "Character Movement", Icon = "user" }
        }
        PlayersTab_Sec_FreeCam:AddDropdown({
            Name = "FreeCam Mode",
            Desc = "Sesuaikan Semaunya",
            Values = cleanDropdownValues(freecamModeValues),
            Default = cleanDefaultValue(freecamModeValues[1]),
            Multi = false,
            Callback = wrapDropdownCallback(function(val)
                _G.FreeCamMode = val.Title
                NotifyInfo("FreeCam", "Mode: " .. val.Title)
            end, false)})
        PlayersTab_Sec_FreeCam:AddToggle({
            Name = "Enable FreeCam",
            Default = false,
            Callback = function(val)
                if val then
                    if _G.FreeCamMode == "Character Movement" then
                        FreeCam.EnableCharacterMode()
                    else
                        FreeCam.Enable()
                    end
                else
                    FreeCam.Disable()
                end
            end
        })

        
        local PlayersTab_Sec_CustomSkinAnimation = PlayersTab_Tabbox3:AddTab("Custom Skin Animation", "lucide:sparkles")
        local customSkinNames = {
    -- Original skins
    "Eclipse", "HolyTrident", "SoulScythe", "OceanicHarpoon",
    "BinaryEdge", "Vanquisher", "KrampusScythe", "BanHammer",
    "CorruptionEdge", "PrincessParasol",
    -- New skins dari database resmi
    "AetherMonarch", "CloudWeaver", "Overdrive", "VoidGuitar",
    "KittyGuitar", "DraconicSoul", "DivineStaff", "EmpyreanStaff",
    "GoldenClockwork", "BunnySummoner", "EasterParasol",
    "SerpentTrident", "CrimsonRetribution", "DarkMatterScythe",
    "EtherealSword", "CupidHarp", "AurelianBow", "VoidKraken",
    "CelestialScythe", "KitsuneGreatsword", "ChromaticKatana",
    "CrescendoScythe", "BlackholeSword", "EternalFlower",
    "GingerbreadKatana", "ChristmasParasol", "DefaultCatch"
        }    
        local skinDropdownValues = {}; for _, name in ipairs(customSkinNames) do table.insert(skinDropdownValues, { Title = name, Icon = "sword" }) end
        PlayersTab_Sec_CustomSkinAnimation:AddDropdown({ Name = "Pilih Custom Skin", Values = cleanDropdownValues(skinDropdownValues), Default = cleanDefaultValue(skinDropdownValues[1]), Multi = false, Callback = wrapDropdownCallback(function(val) SkinAnimation.SwitchSkin(val.Title) end, false)})
        PlayersTab_Sec_CustomSkinAnimation:AddToggle({ Name = "Enable Custom Skin Animation", Default = false, Callback = function(val) if val then SkinAnimation.Enable() else SkinAnimation.Disable() end end })

   
    
        PlayersTab_Tabbox4 = PlayersTab:AddTabbox({ Name = "Aura Animation", Position = "center" })
        local PlayersTab_Sec_AuraAnimation = PlayersTab_Tabbox4:AddTab("Aura Animation", "lucide:sparkles")

    -- Aura system variables
    local localAura = nil
    local localAuraName = nil
    local availableAuras = {}
    local auraDropdownRef = nil
    local AURA_MARK_ATTR = "KysHubLocalAura"

    -- FIX: Scan path yang benar untuk Fish It berdasarkan Module FishIt.lua
    -- Path asli game: ReplicatedStorage > Assets > Abilities > CharacterAuras
    local AURA_PATHS = {
        function() 
            local assets = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
            if assets then
                local abilities = assets:FindFirstChild("Abilities")
                if abilities then
                    return abilities:FindFirstChild("CharacterAuras")
                end
            end
            return nil
        end,
        function() return game:GetService("ReplicatedStorage"):FindFirstChild("Assets") and
            game:GetService("ReplicatedStorage").Assets:FindFirstChild("Auras") end,
        function() return game:GetService("ReplicatedStorage"):FindFirstChild("Auras") end,
    }

    local function findAurasFolder()
        for _, pathFn in ipairs(AURA_PATHS) do
            local ok, folder = pcall(pathFn)
            if ok and folder then
                print("[Aura] Folder ditemukan: " .. folder:GetFullName())
                return folder
            end
        end
        return nil
    end

    local function scanAuras()
        availableAuras = {}
        local aurasFolder = findAurasFolder()
        if aurasFolder then
            for _, aura in ipairs(aurasFolder:GetChildren()) do
                table.insert(availableAuras, aura.Name)
            end
            table.sort(availableAuras)
            print("[Aura] Total aura ditemukan: " .. #availableAuras)
        else
            -- Fallback: coba scan semua children ReplicatedStorage
            for _, child in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if (child.Name == "CharacterAuras" or child.Name == "Auras") and (child:IsA("Folder") or child:IsA("Model")) then
                    for _, aura in ipairs(child:GetChildren()) do
                        table.insert(availableAuras, aura.Name)
                    end
                    break
                end
            end
            table.sort(availableAuras)
        end
        return availableAuras
    end

    local function destroyAuraInstance(inst)
        if inst and inst.Parent then
            pcall(function() inst:Destroy() end)
            return 1
        end
        return 0
    end

    local function cleanupLocalAura(clearName)
        local removed = 0
        if localAura then
            if type(localAura) == "table" then
                for _, inst in ipairs(localAura) do
                    removed = removed + destroyAuraInstance(inst)
                end
            else
                removed = removed + destroyAuraInstance(localAura)
            end
        end

        local char = LocalPlayer.Character
        if char then
            for _, inst in ipairs(char:GetDescendants()) do
                local shouldRemove = inst.Name == "KysHubAuraVFX"
                    or inst:GetAttribute(AURA_MARK_ATTR) == true
                    or inst:GetAttribute("AbilityAuraVFX") == true

                if shouldRemove then
                    removed = removed + destroyAuraInstance(inst)
                end
            end
        end

        localAura = nil
        if clearName then
            localAuraName = nil
        end
        return removed
    end

    -- FIX: Apply aura menggunakan metode yang sama dengan game asli (playCharacterAura)
    local function applyLocalAura(auraName)
        -- Hapus aura lama dulu
        cleanupLocalAura(false)
        if not auraName or auraName == "" then return end

        pcall(function()
            local aurasFolder = findAurasFolder()
            if not aurasFolder then
                WindUI:Notify({Title="[WARN] Aura", Content="Folder Auras tidak ditemukan di game ini!", Duration=3})
                return
            end

            local template = aurasFolder:FindFirstChild(auraName)
            if not template then
                WindUI:Notify({Title="[WARN] Aura", Content="Aura '" .. auraName .. "' tidak ditemukan!", Duration=3})
                return
            end

            local char = LocalPlayer.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- Buat folder container seperti game aslinya
            local auraFolder = Instance.new("Folder")
            auraFolder.Name = "KysHubAuraVFX"
            auraFolder:SetAttribute(AURA_MARK_ATTR, true)
            auraFolder:SetAttribute("AbilityVFX", true)
            auraFolder:SetAttribute("AbilityAuraVFX", true)
            auraFolder.Parent = char
            local auraInstances = {auraFolder}

            -- Clone children dari template dan attach ke body parts yang sesuai
            for _, child in ipairs(template:GetChildren()) do
                local targetPart = char:FindFirstChild(child.Name)

                -- Jika child bernama "AttachTo", buat part khusus
                if child.Name == "AttachTo" then
                    local attachPart = Instance.new("Part")
                    attachPart.Name = "AttachTo"
                    attachPart.Size = child:IsA("BasePart") and child.Size or Vector3.new(1, 1, 1)
                    attachPart.CFrame = hrp.CFrame
                    attachPart.Anchored = false
                    attachPart.CanCollide = false
                    attachPart.Massless = true
                    attachPart.Transparency = 1
                    attachPart.CastShadow = false
                    attachPart:SetAttribute(AURA_MARK_ATTR, true)
                    attachPart:SetAttribute("AbilityVFX", true)
                    attachPart:SetAttribute("AbilityAuraVFX", true)
                    
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = attachPart
                    weld.Part1 = hrp
                    weld:SetAttribute(AURA_MARK_ATTR, true)
                    weld.Parent = attachPart
                    attachPart.Parent = auraFolder
                    table.insert(auraInstances, attachPart)
                    table.insert(auraInstances, weld)
                    targetPart = attachPart
                end

                if targetPart then
                    for _, effect in ipairs(child:GetChildren()) do
                        local clone = effect:Clone()
                        clone:SetAttribute(AURA_MARK_ATTR, true)
                        clone:SetAttribute("AbilityVFX", true)
                        clone:SetAttribute("AbilityAuraVFX", true)
                        clone.Parent = targetPart
                        table.insert(auraInstances, clone)

                        -- Aktifkan particle/trail/beam
                        if clone:IsA("ParticleEmitter") then
                            clone.Enabled = true
                        elseif clone:IsA("Trail") then
                            clone.Enabled = true
                        elseif clone:IsA("Beam") then
                            clone.Enabled = true
                        end
                    end
                end
            end

            localAura = auraInstances
            WindUI:Notify({Title="[OK] Aura", Content="Applied: " .. auraName, Duration=3})
        end)

    end

    local function removeLocalAura()
        local removed = cleanupLocalAura(true)
        if removed > 0 then
            WindUI:Notify({Title="[INFO] Aura", Content="Aura dihapus!", Duration=2})
        else
            WindUI:Notify({Title="[WARN] Aura", Content="Tidak ada aura aktif.", Duration=2})
        end
    end

    -- Auto-reapply on respawn
    LocalPlayer.CharacterAdded:Connect(function()
        task.delay(1.5, function()
            if localAuraName then applyLocalAura(localAuraName) end
        end)
    end)

    -- Dropdown (initially empty)
    local auraDropdownValues = {{ Title = "-- Refresh first --", Icon = "refresh-cw" }}
    auraDropdownRef = PlayersTab_Sec_AuraAnimation:AddDropdown({
        Name = "Pilih Aura",
        Desc = "Klik Refresh untuk scan aura dari game",
        Values = cleanDropdownValues(auraDropdownValues),
        Default = cleanDefaultValue(auraDropdownValues[1]),
        Multi = false,
        Callback = wrapDropdownCallback(function(val)
            if val.Title ~= "-- Refresh first --" and val.Title ~= "Tidak ada aura" then
                _G.SelectedAuraName = val.Title
            end
        end, false)})

    PlayersTab_Sec_AuraAnimation:AddButton({
        Name = "Refresh Aura List",
        Desc = "Scan semua aura dari game Fish It",
        Callback = function()
            local auras = scanAuras()
            if #auras == 0 then
                WindUI:Notify({Title="[WARN] Aura", Content="Tidak ada aura ditemukan! Pastikan kamu sudah masuk game.", Duration=4})
                local emptyValues = {{ Title = "Tidak ada aura", Icon = "x" }}
                pcall(function()
                    if auraDropdownRef and auraDropdownRef.SetValues then
                        auraDropdownRef:SetValues(cleanDropdownValues(emptyValues)):SetValue(cleanDefaultValue(emptyValues[1]))
                    end
                end)
                return
            end
            local newValues = {}
            for _, name in ipairs(auras) do
                table.insert(newValues, { Title = name, Icon = "sparkles" })
            end
            pcall(function()
                if auraDropdownRef and auraDropdownRef.SetValues then
                    auraDropdownRef:SetValues(cleanDropdownValues(newValues)):SetValue(cleanDefaultValue(newValues[1]))
                end
            end)
            WindUI:Notify({Title="[OK] Aura", Content="Ditemukan " .. #auras .. " aura!", Duration=3})
        end
    })

    PlayersTab_Sec_AuraAnimation:AddButton({
        Name = "Apply Aura",
        Desc = "Pasang aura ke avatar",
        Callback = function()
            if not _G.SelectedAuraName or _G.SelectedAuraName == "" then
                WindUI:Notify({Title="[ERR] Aura", Content="Pilih aura dulu dari dropdown!", Duration=3})
                return
            end
            localAuraName = _G.SelectedAuraName
            applyLocalAura(localAuraName)
        end
    })

    PlayersTab_Sec_AuraAnimation:AddButton({
        Name = "Remove Aura",
        Desc = "Hapus aura yang sedang aktif",
        Callback = function()
            removeLocalAura()
        end
    })

    end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end -- TUTUP pcall PlayersTab
end -- TUTUP if PlayersTab
                        
-- MAIN TAB (AUTOMATION)
if MainTab then
    local ok, err = pcall(function()
        
        MainTab_Tabbox1 = MainTab:AddTabbox({ Name = "Boat System", Position = "center" })
        local MainTab_Sec_BoatSystem = MainTab_Tabbox1:AddTab("Boat System", "lucide:ship")

        -- Fungsi untuk mendapatkan Boat ID yang dimiliki player
        local _selectedBoatId = nil
        local function getPlayerBoatId()
            if _selectedBoatId then return _selectedBoatId end
            -- Coba dapatkan LastBoatId dari Replion
            local boatId = nil
            pcall(function()
                local Replion = require(game:GetService("ReplicatedStorage").Packages.Replion)
                local data = Replion.Client:WaitReplion("Data")
                boatId = data:Get("LastBoatId")
            end)
            if boatId and boatId ~= -1 then return boatId end
            -- Fallback: coba ID 1 (boat default)
            return 1
        end

        -- Scan boats yang dimiliki player
        local function scanOwnedBoats()
            local owned = {}
            pcall(function()
                local Replion = require(game:GetService("ReplicatedStorage").Packages.Replion)
                local data = Replion.Client:WaitReplion("Data")
                local boats = data:GetExpect({"Inventory", "Boats"})
                if boats then
                    for _, boat in ipairs(boats) do
                        if boat.Id then
                            table.insert(owned, boat.Id)
                        end
                    end
                end
            end)
            if #owned == 0 then
                -- Fallback: tambahkan ID default
                table.insert(owned, 1)
            end
            table.sort(owned)
            return owned
        end

        local ownedBoats = scanOwnedBoats()
        local boatDropdownValues = {}
        for _, id in ipairs(ownedBoats) do
            table.insert(boatDropdownValues, { Title = "Boat #" .. id, Icon = "ship" })
        end
        _selectedBoatId = ownedBoats[1] or 1

        MainTab_Sec_BoatSystem:AddDropdown({
            Name = "Pilih Boat",
            Values = cleanDropdownValues(boatDropdownValues),
            Default = cleanDefaultValue(boatDropdownValues[1]),
            Multi = false,
            Callback = wrapDropdownCallback(function(val)
                local idStr = val.Title:match("#(%d+)")
                if idStr then _selectedBoatId = tonumber(idStr) end
            end, false)})

        MainTab_Sec_BoatSystem:AddToggle({
            Name = "Auto Spawn Boat",
            Desc = "Spawn boat otomatis untuk fishing",
            Default = false,
            Callback = function(val)
                _G.AutoSpawnBoat = val
                if val then
                    task.spawn(function()
                        while _G.AutoSpawnBoat do
                            pcall(function()
                                if Events.SpawnBoat then
                                    local boatId = getPlayerBoatId()
                                    Events.SpawnBoat:InvokeServer(boatId)
                                end
                            end)
                            task.wait(5)
                        end
                    end)
                    NotifySuccess("Boat", "Auto Spawn aktif! (Boat #" .. getPlayerBoatId() .. ")")
                else
                    -- Despawn boat
                    pcall(function()
                        if Events.DespawnBoat then Events.DespawnBoat:InvokeServer() end
                    end)
                    NotifyInfo("Boat", "Boat di-despawn.")
                end
            end
        })

        MainTab_Sec_BoatSystem:AddButton({
            Name = "Spawn Boat Sekarang",
            Callback = function()
                if not Events.SpawnBoat then
                    Events.SpawnBoat = GetServerRemote("RF/SpawnBoat")
                end
                if Events.SpawnBoat then
                    local boatId = getPlayerBoatId()
                    local ok, result = pcall(function() return Events.SpawnBoat:InvokeServer(boatId) end)
                    if ok and result then
                        NotifySuccess("Boat", "Boat #" .. boatId .. " spawned!")
                    else
                        NotifyError("Boat", "Gagal spawn boat! Coba pilih boat lain.")
                    end
                else
                    NotifyError("Boat", "Remote SpawnBoat tidak ditemukan!")
                end
            end
        })

        MainTab_Sec_BoatSystem:AddButton({
            Name = "Despawn Boat",
            Callback = function()
                if not Events.DespawnBoat then
                    Events.DespawnBoat = GetServerRemote("RF/DespawnBoat")
                end
                if Events.DespawnBoat then
                    pcall(function() Events.DespawnBoat:InvokeServer() end)
                    NotifySuccess("Boat", "Boat despawned!")
                else
                    NotifyError("Boat", "Remote DespawnBoat tidak ditemukan!")
                end
            end
        })


        
        local MainTab_Sec_RedeemCode = MainTab_Tabbox1:AddTab("Redeem Code", "lucide:gift")
        MainTab_Sec_RedeemCode:AddTextInput({ Name = "Masukkan Kode", Placeholder = "Ketik kode...", Default = "", Callback = function(text) _G.PendingRedeemCode = text end })
        MainTab_Sec_RedeemCode:AddButton({ Name = "Redeem Code", Callback = function()
            if not _G.PendingRedeemCode or _G.PendingRedeemCode == "" then NotifyError("Redeem", "Masukkan kode dulu!"); return end
            if not Events.RedeemCode then Events.RedeemCode = GetServerRemote("RF/RedeemCode") end
            if Events.RedeemCode then
                local ok = pcall(function() return Events.RedeemCode:InvokeServer(_G.PendingRedeemCode) end)
                if ok then NotifySuccess("Redeem", "Kode dikirim: " .. _G.PendingRedeemCode) else NotifyError("Redeem", "Gagal redeem!") end
            else NotifyError("Redeem", "Remote tidak ditemukan!") end
        end })

                
        MainTab_Tabbox2 = MainTab:AddTabbox({ Name = "Auto Enchant", Position = "center" })
        local MainTab_Sec_AutoEnchant = MainTab_Tabbox2:AddTab("Auto Enchant", "lucide:gem")

        local enchantParagraph = MainTab_Sec_AutoEnchant:AddParagraph({
            Name = "Enchant Status",
            RichText = true,
            Content = "Rod Active = <font color='#FFB6C1'>None</font>\nEnchant Now = <font color='#87CEEB'>None</font>\nBasic Stone = <font color='#FFD700'>0</font>\nEvolved Stone = <font color='#00FF7F'>0</font>\nStone Type = <font color='#DDA0DD'>" .. _G.SelectedStoneType .. "</font>"
        })

        local function getEnchantNameFromId(enchantId)
            if not enchantId then return "None" end
            for name, id in pairs(enchantIdMap) do
                if id == enchantId then
                    return name
                end
            end
            return tostring(enchantId)
        end

        local function setEnchantParagraph(content)
            if not enchantParagraph then return end
            if type(enchantParagraph.SetContent) == "function" then
                enchantParagraph:SetContent(content)
            elseif type(enchantParagraph.SetDesc) == "function" then
                enchantParagraph:SetDesc(content)
            end
        end

        local function updateEnchantStatusPanel()
            local basicStones = countEnchantStoneById(10)
            local evolvedStones = gEvolvedStone()
            local rod = getEquippedRodName()
            local enchantName = getEnchantNameFromId(getCurrentRodEnchant())

            setEnchantParagraph(string.format(
                "Rod Active = <font color='#FFB6C1'>%s</font>\n" ..
                "Enchant Now = <font color='#87CEEB'>%s</font>\n" ..
                "Basic Stone = <font color='#FFD700'>%d</font>\n" ..
                "Evolved Stone = <font color='#00FF7F'>%d</font>\n" ..
                "Stone Type = <font color='#DDA0DD'>%s</font>",
                rod, enchantName, basicStones, evolvedStones, _G.SelectedStoneType
            ))

            return rod, enchantName, basicStones, evolvedStones, _G.SelectedStoneType
        end

        pcall(updateEnchantStatusPanel)

        task.spawn(function()
            local lastRod, lastEnchant, lastBasicStones, lastEvolvedStones, lastType = "", "", -1, -1, ""
            while task.wait(2) do
                pcall(function()
                    local rod = getEquippedRodName()
                    local enchantName = getEnchantNameFromId(getCurrentRodEnchant())
                    local basicStones = countEnchantStoneById(10)
                    local evolvedStones = gEvolvedStone()
                    if rod ~= lastRod or enchantName ~= lastEnchant or basicStones ~= lastBasicStones or evolvedStones ~= lastEvolvedStones or _G.SelectedStoneType ~= lastType then
                        rod, enchantName, basicStones, evolvedStones = updateEnchantStatusPanel()
                        lastRod, lastEnchant, lastBasicStones, lastEvolvedStones, lastType = rod, enchantName, basicStones, evolvedStones, _G.SelectedStoneType
                    end
                end)
            end
        end)

        local stoneTypeValues = {{ Title = "Enchant Stones", Icon = "gem" }, { Title = "Evolved Enchant Stone", Icon = "sparkles" }}
        MainTab_Sec_AutoEnchant:AddDropdown({ Name = "Enchant Stone Type", Values = cleanDropdownValues(stoneTypeValues), Default = cleanDefaultValue(stoneTypeValues[1]), Multi = false, Callback = wrapDropdownCallback(function(val) _G.SelectedStoneType = val.Title; pcall(updateEnchantStatusPanel) end, false)})

        local basicEnchantValues = {
            {Title="Big Hunter 1",Icon="target"},{Title="Cursed 1",Icon="skull"},{Title="Empowered 1",Icon="zap"},
            {Title="Glistening 1",Icon="star"},{Title="Gold Digger 1",Icon="coins"},{Title="Leprechaun 1",Icon="clover"},
            {Title="Leprechaun 2",Icon="clover"},{Title="Mutation Hunter 1",Icon="dna"},{Title="Mutation Hunter 2",Icon="dna"},
            {Title="Prismatic 1",Icon="rainbow"},{Title="Reeler 1",Icon="anchor"},{Title="Stargazer 1",Icon="telescope"},
            {Title="Stormhunter 1",Icon="cloud-lightning"},{Title="XPerienced 1",Icon="trending-up"}
        }
        MainTab_Sec_AutoEnchant:AddDropdown({ Name = "Target (Basic Stones)", Values = cleanDropdownValues(basicEnchantValues), Default = cleanDefaultValue(basicEnchantValues[1]), Multi = false, Callback = wrapDropdownCallback(function(val) _G.TargetEnchantBasic = val.Title end, false)})

        local evolvedEnchantValues = {
            {Title="Prismatic 1",Icon="rainbow"},{Title="Cursed 1",Icon="skull"},{Title="Gold Digger 1",Icon="coins"},
            {Title="Empowered 1",Icon="zap"},{Title="SECRET Hunter",Icon="lock"},{Title="Shark Hunter",Icon="fish"},
            {Title="Stargazer II",Icon="telescope"},{Title="Stormhunter II",Icon="cloud-lightning"},
            {Title="Mutation Hunter II",Icon="dna"},{Title="Leprechaun II",Icon="clover"},
            {Title="Reeler II",Icon="anchor"},{Title="Mutation Hunter III",Icon="dna"},{Title="Fairy Hunter 1",Icon="wand"}
        }
        MainTab_Sec_AutoEnchant:AddDropdown({ Name = "Target (Evolved Stones)", Values = cleanDropdownValues(evolvedEnchantValues), Default = cleanDefaultValue(evolvedEnchantValues[1]), Multi = false, Callback = wrapDropdownCallback(function(val) _G.TargetEnchantEvolved = val.Title end, false)})

        MainTab_Sec_AutoEnchant:AddToggle({
            Name = "Auto Enchant", Default = false,
            Callback = function(val)
                _G.AutoEnchant = val
                if val then
                    task.spawn(function()
                        while _G.AutoEnchant do
                            pcall(function()
                                local targetEnchant = (_G.SelectedStoneType == "Evolved Enchant Stone") 
                                    and _G.TargetEnchantEvolved 
                                    or _G.TargetEnchantBasic
                                
                                local currentId = getCurrentRodEnchant()
                                local targetId = enchantIdMap[targetEnchant]

                                if currentId == targetId then
                                    _G.AutoEnchant = false
                                    WindUI:Notify({
                                        Title = "Auto Enchant",
                                        Content = "Target Tercapai: " .. targetEnchant,
                                        Duration = 5
                                    })
                                    return
                                end

                                local stones = findEnchantStones()
                                if #stones > 0 then
                                    Events.equipItemRemote:FireServer(stones[1].UUID, "Enchant Stones")
                                    task.wait(0.8)

                                    local slot = countDisplayImageButtons() - 2
                                    if slot < 1 then slot = 1 end

                                    Events.equipToolRemote:FireServer(slot)
                                    task.wait(0.8)
                                    Events.activateAltar:FireServer()
                                    task.wait(1)
                                    updateEnchantStatusPanel()
                                end
                            end)
                            task.wait(4)
                        end
                    end)
                end
            end
        })

        MainTab_Sec_AutoEnchant:AddButton({ Name = "Teleport to Altar", Callback = function() teleportTo("Enchanting Altar"); NotifySuccess("TP", "Berhasil ke Enchanting Altar!") end })

        
        local MainTab_Sec_CavePirateEvents = MainTab_Tabbox2:AddTab("Cave & Pirate Events", "lucide:gem")
        local function getTNTSearchSpawns()
            local spawns = {}
            local worldSetup = Workspace:FindFirstChild("WorldSetup")
            local searchRoot = worldSetup and worldSetup:FindFirstChild("!!! SEARCH ITEM SPAWNS")
            local tntFolder = searchRoot and searchRoot:FindFirstChild("TNT")
            if not tntFolder then return spawns end

            for _, spawnPart in ipairs(tntFolder:GetChildren()) do
                table.insert(spawns, {
                    Name = spawnPart.Name,
                    ModelId = spawnPart:GetAttribute("ModelId")
                })
            end
            return spawns
        end

        local function claimTNTSearchItems()
            if not Events.searchItemPickedUp then
                Events.searchItemPickedUp = GetServerRemote("RF/SearchItemPickedUp")
            end
            if not Events.searchItemPickedUp then
                return 0, 0, "Remote SearchItemPickedUp tidak ditemukan"
            end

            local spawns = getTNTSearchSpawns()
            if #spawns == 0 then
                return 0, 0, "Spawn TNT tidak ditemukan di WorldSetup"
            end

            local successCount = 0
            for _, spawnInfo in ipairs(spawns) do
                local ok, result
                if Events.searchItemPickedUp:IsA("RemoteFunction") then
                    ok, result = pcall(function()
                        return Events.searchItemPickedUp:InvokeServer(spawnInfo.Name, spawnInfo.ModelId)
                    end)
                else
                    ok, result = pcall(function()
                        Events.searchItemPickedUp:FireServer(spawnInfo.Name, spawnInfo.ModelId)
                        return true
                    end)
                end

                if ok and result ~= false then
                    successCount += 1
                end
                task.wait(0.25)
            end

            return successCount, #spawns
        end

        local function openMysteriousCaveWall()
            if not Events.gainAccessToMaze then
                Events.gainAccessToMaze = GetServerRemote("RE/GainAccessToMaze")
            end

            local picked, total, err = claimTNTSearchItems()
            if err then
                NotifyError("Cave Wall", err)
                return
            end

            if picked == 0 then
                NotifyWarning("Cave Wall", "TNT gagal diklaim. Pastikan quest Carpenter/Mysterious Cave sudah aktif.")
                return
            end

            task.wait(1)
            local opened = false
            if Events.gainAccessToMaze then
                opened = CallRemote(Events.gainAccessToMaze)
            end

            if opened then
                NotifySuccess("Cave Wall", "TNT diklaim " .. picked .. "/" .. total .. ", akses maze dikirim.")
            else
                NotifyWarning("Cave Wall", "TNT diklaim " .. picked .. "/" .. total .. ", tapi remote GainAccessToMaze gagal/tidak ditemukan.")
            end
        end

        MainTab_Sec_CavePirateEvents:AddButton({
            Name = "Open Mysterious Cave Wall",
            Callback = function()
                task.spawn(function()
                    openMysteriousCaveWall()
                end)
            end
        })
        MainTab_Sec_CavePirateEvents:AddToggle({
            Name = "Auto Open Pirate Chest", Default = false,
            Callback = function(val)
                _G.AutoOpenPirateChest = val
                if val then
                    task.spawn(function()
                        local lastPirateChestNotify = 0
                        while _G.AutoOpenPirateChest do
                            pcall(function()
                                if not Events.claimPirateChest then Events.claimPirateChest = GetServerRemote("RE/ClaimPirateChest") end
                                if not Events.claimPirateChest then
                                    if tick() - lastPirateChestNotify > 5 then
                                        NotifyError("Pirate", "Remote ClaimPirateChest tidak ditemukan!")
                                        lastPirateChestNotify = tick()
                                    end
                                    return
                                end

                                local storage = Workspace:FindFirstChild("PirateChestStorage")
                                if not storage then
                                    if tick() - lastPirateChestNotify > 5 then
                                        NotifyWarning("Pirate", "PirateChestStorage belum ada / belum ada chest spawn.")
                                        lastPirateChestNotify = tick()
                                    end
                                    return
                                end

                                local claimed = 0
                                for _, chest in ipairs(storage:GetChildren()) do
                                    local cover = chest:FindFirstChild("Cover")
                                    local prompt = cover and cover:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if prompt or chest:IsA("Model") then
                                        local ok = CallRemote(Events.claimPirateChest, chest.Name)
                                        if ok then
                                            claimed += 1
                                        end
                                        task.wait(0.35)
                                    end
                                end

                                if claimed > 0 then
                                    NotifySuccess("Pirate", "Kirim claim " .. claimed .. " chest!")
                                elseif tick() - lastPirateChestNotify > 5 then
                                    NotifyWarning("Pirate", "Storage ada, tapi chest valid belum ditemukan.")
                                    lastPirateChestNotify = tick()
                                end
                            end)
                            task.wait(3)
                        end
                    end)
                end
            end
        })

        
        MainTab_Tabbox3 = MainTab:AddTabbox({ Name = "Crystal & Cave", Position = "center" })
        local MainTab_Sec_CrystalCave = MainTab_Tabbox3:AddTab("Crystal & Cave", "lucide:gem")
        MainTab_Sec_CrystalCave:AddButton({
            Name = "Consume Cave Crystal",
            Callback = function()
                if not Events.ConsumeCaveCrystal then Events.ConsumeCaveCrystal = GetServerRemote("RF/ConsumeCaveCrystal") end
                if Events.ConsumeCaveCrystal then
                    pcall(function() Events.ConsumeCaveCrystal:InvokeServer() end)
                    task.wait(1.5); equipRod(); NotifySuccess("Cave Crystal", "Berhasil!")
                else NotifyError("Cave Crystal", "Remote tidak ditemukan!") end
            end
        })
        MainTab_Sec_CrystalCave:AddToggle({
            Name = "Auto Consume Cave Crystal", Default = false,
            Callback = function(val)
                _G.autoConsumeCaveCrystal = val
                if val then
                    if not Events.ConsumeCaveCrystal then Events.ConsumeCaveCrystal = GetServerRemote("RF/ConsumeCaveCrystal") end
                    _G.caveCrystalTask = task.spawn(function()
                        while _G.autoConsumeCaveCrystal do
                            pcall(function() if Events.ConsumeCaveCrystal then Events.ConsumeCaveCrystal:InvokeServer() end end)
                            task.wait(1.5); equipRod(); task.wait(1800)
                        end
                    end)
                    NotifySuccess("Auto Crystal", "Aktif - setiap 30 menit!")
                else
                    if _G.caveCrystalTask then pcall(function() task.cancel(_G.caveCrystalTask) end) end
                end
            end
        })

        
        local MainTab_Sec_FishingRadar = MainTab_Tabbox3:AddTab("Fishing Radar", "lucide:radar")
        MainTab_Sec_FishingRadar:AddToggle({
            Name = "Enable Fishing Radar", Default = false,
            Callback = function(val)
                Config.FishingRadar = val
                if not Events.UpdateFishingRadar then Events.UpdateFishingRadar = GetServerRemote("RF/UpdateFishingRadar") end
                if Events.UpdateFishingRadar then
                    pcall(function() Events.UpdateFishingRadar:InvokeServer(val) end)
                    NotifyInfo("Fishing Radar", val and "Radar aktif!" or "Radar nonaktif.")
                else NotifyError("Fishing Radar", "Remote tidak ditemukan!") end
            end
        })

        
        MainTab_Tabbox4 = MainTab:AddTabbox({ Name = "Auto Atlantis Machine", Position = "center" })
        local MainTab_Sec_AutoAtlantisMachine = MainTab_Tabbox4:AddTab("Auto Atlantis Machine", "lucide:cpu")
        local atlantisRarityValues = {
            {Title="Common"}, {Title="Uncommon"}, {Title="Rare"}, {Title="Epic"}, {Title="Legendary"},
            {Title="Mythic"}, {Title="SECRET"}
        }
        MainTab_Sec_AutoAtlantisMachine:AddDropdown({
            Name = "Sacrifice Rarity Filter",
            Desc = "Default aman: Rare & Epic saja",
            Values = cleanDropdownValues(atlantisRarityValues),
            Default = {"Rare", "Epic"},
            Multi = true,
            Callback = wrapDropdownCallback(function(values)
                AtlantisConfig.SelectedRarities = {}
                for _, rarity in ipairs(values) do
                    local name = NormalizeAtlantisRarity(rarity.Title)
                    if name ~= "" then
                        AtlantisConfig.SelectedRarities[name] = true
                    end
                end
                NotifyInfo("Atlantis", "Filter sacrifice diperbarui.")
            end, true)
        })
        MainTab_Sec_AutoAtlantisMachine:AddToggle({
            Name = "Skip Favorited Fish",
            Desc = "Jangan sacrifice ikan favorit",
            Default = true,
            Callback = function(val)
                AtlantisConfig.SkipFavorited = val
            end
        })
        MainTab_Sec_AutoAtlantisMachine:AddToggle({
            Name = "Auto Atlantis Machine",
            Desc = "Auto: Cek ikan",
            Default = false,
            Callback = function(val)
                AtlantisConfig.AutoAtlantisMachine = val
                if val then
                    local hrp = getHRP()
                    if hrp then AtlantisConfig.LastFishingPosition = hrp.CFrame end
                    RunAutoAtlantisMachine()
                    NotifySuccess("Atlantis", "Auto Atlantis Machine aktif!")
                else
                    StopAutoAtlantisMachine()
                end
            end
        })
        MainTab_Sec_AutoAtlantisMachine:AddButton({
            Name = "Sacrifice (Manual)",
            Desc = "Sacrifice ikan sesuai filter sekarang",
            Callback = function()
                local hrp = getHRP()
                if hrp then AtlantisConfig.LastFishingPosition = hrp.CFrame end
                task.spawn(function()
                    local success = SacrificeAllFishToAtlantis()
                    if not success then
                        NotifyError("Atlantis", "Gagal / tidak ada ikan sesuai filter!")
                    end
                end)
            end
        })

        
        local MainTab_Sec_EventTeleport = MainTab_Tabbox4:AddTab("Event Teleport", "lucide:map-pin")
        MainTab_Sec_EventTeleport:AddButton({ Name = "Teleport Leviathan", Callback = function() local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.new(3474.053,-287.775,3472.634) end end })
        MainTab_Sec_EventTeleport:AddButton({ Name = "Teleport Thunderzilla", Callback = function() local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.new(2067.866,2.028,10.831) end end })
        MainTab_Sec_EventTeleport:AddToggle({ Name = "Auto Event TP", Default = false, Callback = function(val) Config.AutoEvent = val; if val then RunAutoEvent() else if Tasks.AutoEventThread then pcall(function() task.cancel(Tasks.AutoEventThread) end) end end end })

        
        MainTab_Tabbox5 = MainTab:AddTabbox({ Name = "Advanced Event Teleport", Position = "center" })
        local MainTab_Sec_AdvancedEventTeleport = MainTab_Tabbox5:AddTab("Advanced Event Teleport", "lucide:map-pin")
        local eventNames = {}; for name in pairs(eventData) do table.insert(eventNames, name) end; table.sort(eventNames)
        local eventValues = {}; for _, name in ipairs(eventNames) do table.insert(eventValues, { Title = name, Icon = "swords" }) end
        MainTab_Sec_AdvancedEventTeleport:AddDropdown({ Name = "Select Events", Values = cleanDropdownValues(eventValues), Default = cleanDefaultValue({}), Multi = true, Callback = wrapDropdownCallback(function(val) selectedEvents = {}; for _, v in ipairs(val) do table.insert(selectedEvents, v.Title) end end, true)})
        MainTab_Sec_AdvancedEventTeleport:AddToggle({
            Name = "Auto Event Teleport (Platform)", Default = false,
            Callback = function(state)
                autoEventTPEnabled = state
                if state then
                    if #selectedEvents == 0 then NotifyWarning("Event TP", "Pilih minimal 1 event!"); autoEventTPEnabled = false; return end
                    if autoEventThread then pcall(function() task.cancel(autoEventThread) end) end
                    autoEventThread = task.spawn(runMultiEventTP)
                else
                    destroyEventPlatform()
                    if autoEventThread then pcall(function() task.cancel(autoEventThread) end); autoEventThread = nil end
                end
            end
        })
    end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end
end
-- EXCLUSIVE TAB (QH FISHING)
if ExclusiveTab then
    local ok, err = pcall(function()
        
        ExclusiveTab_Tabbox1 = ExclusiveTab:AddTabbox({ Name = "Fishing Ultra", Position = "center" })
        local ExclusiveTab_Sec_FishingUltra = ExclusiveTab_Tabbox1:AddTab("Fishing Ultra", "lucide:fish")
        ExclusiveTab_Sec_FishingUltra:AddTextInput({
            Name = "Complete Delay (detik)", Placeholder = "2.798", Default = "2.798",
            Callback = function(text)
                local num = tonumber(text); if not num or num < 1 then NotifyError("Delay", "Minimal 1 detik!"); return end
                Config.UB.Settings.CompleteDelay = math.clamp(num, 1, 10); NotifySuccess("Delay", "Set ke " .. Config.UB.Settings.CompleteDelay .. "s")
            end
        })
        ExclusiveTab_Sec_FishingUltra:AddToggle({ 
            Name = "Fishing [Beta]", 
            Locked = false,
            TextLocked = "Premium Required",
            Default = false, 
            Callback = function(val) 
                if val and false then
                    NotifyWarning("Premium Required", "Fishing Ultra hanya untuk pengguna Key Premium!")
                    return
                end
                needCast = true; 
                onToggleUB(val) 
            end 
        })
        
        
        local ExclusiveTab_Sec_FishingExtreme = ExclusiveTab_Tabbox1:AddTab("Fishing Extreme", "lucide:fish")

            ExclusiveTab_Sec_FishingExtreme:AddParagraph({
            Name = "How It Works",
            Content = "Event-Based: Catches exactly when the server confirms the minigame starts.\nNo more missed catches from fixed delays!\nRainbow/Golden fish now have the correct thresholds."
        })

        ExclusiveTab_Sec_FishingExtreme:AddToggle({
            Name = "Auto Perfection",
            Desc = "Every cast guarantees a PERFECT quality catch",
            Default = false,
            Callback = function(val)
                Config.autoPerfection = val
                
                -- Hook client-side FishingController to prevent auto cast/reel
                pcall(function()
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local FishingController = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("FishingController"))
                    
                    if not _G.OriginalRequestChargeFishingRod then
                        _G.OriginalRequestChargeFishingRod = FishingController.RequestChargeFishingRod
                        _G.OriginalRequestFishingMinigameClick = FishingController.RequestFishingMinigameClick
                        
                        FishingController.RequestChargeFishingRod = function(self, ...)
                            if Config.autoPerfection then
                                return
                            end
                            return _G.OriginalRequestChargeFishingRod(self, ...)
                        end
                        
                        FishingController.RequestFishingMinigameClick = function(self, ...)
                            if Config.autoPerfection then
                                return
                            end
                            return _G.OriginalRequestFishingMinigameClick(self, ...)
                        end
                    end
                end)
                
                if val then
                    if Config.UB.Remotes.UpdateAutoFishing then
                        pcall(function()
                            Config.UB.Remotes.UpdateAutoFishing:InvokeServer(true)
                        end)
                    end
                    NotifySuccess("Auto Perfection", "Enabled! Every cast = PERFECT quality")
                else
                    if Config.UB.Remotes.UpdateAutoFishing then
                        pcall(function()
                            Config.UB.Remotes.UpdateAutoFishing:InvokeServer(false)
                        end)
                    end
                    NotifyInfo("Auto Perfection", "Disabled")
                end
            end
        })

        ExclusiveTab_Sec_FishingExtreme:AddSlider({
            Name = "Response Delay (ms)",
            Desc = "Delay after minigame starts (30ms = optimal)",
            Min = 10, Max = 200, Default = 30,
            Callback = function(val)
                Config.YTTA.Settings.MinigameResponseDelay = val / 1000
            end
        })

        ExclusiveTab_Sec_FishingExtreme:AddTextInput({
            Name = "Timeout Fallback (seconds)",
            Placeholder = "0.5",
            Default = "0.5",
            Callback = function(text)
                local num = tonumber(text)
                if num and num >= 0.1 then
                    Config.YTTA.Settings.KysHubDelay = num
                end
            end
        })

        ExclusiveTab_Sec_FishingExtreme:AddToggle({
            Name = "Sett Extreme",
            Desc = "Fishing Extreme with event-based timing",
            Locked = true,
            TextLocked = "Maintenance",
            Default = false,
            Callback = function(val)
                if val then
                    NotifyWarning("Maintenance", "Fitur Fishing Extreme sedang dalam perbaikan/maintenance!")
                    return
                end
                onToggleYTTA(val)
            end
        })

        ExclusiveTab_Sec_FishingExtreme:AddSlider({
            Name = "Loop Notif Count",
            Min = 1, Max = 10, Default = 3,
            Callback = function(val) Config.YTTA.NotifCount = val end
        })

        ExclusiveTab_Sec_FishingExtreme:AddToggle({
            Name = "Random Cast (Anti-Detection)",
            Default = false,
            Callback = function(val) Config.antiOKOK = val end
        })

        ExclusiveTab_Sec_FishingExtreme:AddButton({
            Name = "Test Hook Status",
            Desc = "Check if the Minigame hook is active",
            Callback = function()
                if _minigameHookConn then
                    NotifySuccess("Hook", "FishingMinigameChanged hook is ACTIVE!")
                else
                    NotifyError("Hook", "Hook is INACTIVE! Try setting it up again.")
                    SetupMinigameHook()
                end
                local equip = GetServerRemote("RE/EquipToolFromHotbar")
                if equip then
                    NotifySuccess("Equip", "RE/EquipToolFromHotbar found!")
                else
                    NotifyError("Equip", "RE/EquipToolFromHotbar is nil!")
                end
            end
        })
        
        
        ExclusiveTab_Tabbox2 = ExclusiveTab:AddTabbox({ Name = "Legit Fishing", Position = "center" })
        local ExclusiveTab_Sec_LegitFishing = ExclusiveTab_Tabbox2:AddTab("Legit Fishing", "lucide:fish")
        ExclusiveTab_Sec_LegitFishing:AddTextInput({
            Name = "Catch Delay (detik)", Placeholder = "0.5", Default = "0.5",
            Callback = function(text)
                local num = tonumber(text); if not num then return end
                Config.CatchDelay = math.clamp(num, 0, 5)
            end
        })
        ExclusiveTab_Sec_LegitFishing:AddToggle({
            Name = "Legit Fishing", Default = false,
            Callback = function(val)
                Config.AutoCatch = val
                if val then equipRod(); CallRemote(Events.UpdateAutoFishing, true)
                else CallRemote(Events.UpdateAutoFishing, false) end
            end
        })

        
        local ExclusiveTab_Sec_AutoSellFish = ExclusiveTab_Tabbox2:AddTab("Auto Sell Fish", "lucide:dollar-sign")
        local sellMethodValues = {{ Title = "Delay", Icon = "clock" }, { Title = "Count", Icon = "hash" }}
        ExclusiveTab_Sec_AutoSellFish:AddDropdown({ Name = "Metode Sell", Values = cleanDropdownValues(sellMethodValues), Default = cleanDefaultValue(sellMethodValues[1]), Multi = false, Callback = wrapDropdownCallback(function(val) Config.AutoSellMethod = val.Title end, false)})
        ExclusiveTab_Sec_AutoSellFish:AddTextInput({ Name = "Sell Value", Placeholder = "50", Default = "50", Callback = function(text) local num = tonumber(text); if num and num > 0 then Config.AutoSellValue = math.clamp(num, 1, 9999) end end })
        ExclusiveTab_Sec_AutoSellFish:AddToggle({
            Name = "Enable Auto Sell", Default = false,
            Callback = function(val)
                Config.AutoSellState = val
                if val then RunAutoSellLoop()
                else if Tasks.AutoSellThread then pcall(function() task.cancel(Tasks.AutoSellThread) end) end end
            end
        })
        
        
        ExclusiveTab_Tabbox3 = ExclusiveTab:AddTabbox({ Name = "Auto Favorite", Position = "center" })
        local ExclusiveTab_Sec_AutoFavorite = ExclusiveTab_Tabbox3:AddTab("Auto Favorite", "lucide:star")
        local rarityValues = {{Title="Common"},{Title="Uncommon"},{Title="Rare"},{Title="Epic"},{Title="Legendary"},{Title="Mythic"},{Title="SECRET"}}
        ExclusiveTab_Sec_AutoFavorite:AddDropdown({ Name = "Filter Rarity", Values = cleanDropdownValues(rarityValues), Default = cleanDefaultValue({}), Multi = true, Callback = wrapDropdownCallback(function(val) Config.SelectedRarities = {}; for _, v in ipairs(val) do table.insert(Config.SelectedRarities, v.Title) end end, true)})
        local mutationValues = {{Title="Galaxy"},{Title="Corrupt"},{Title="Gemstone"},{Title="Fairy Dust"},{Title="Midnight"},{Title="Color Burn"},{Title="Holographic"},{Title="Lightning"},{Title="Radioactive"},{Title="Ghost"},{Title="Gold"},{Title="Frozen"},{Title="Shiny"}}
        ExclusiveTab_Sec_AutoFavorite:AddDropdown({ Name = "Filter Mutation", Values = cleanDropdownValues(mutationValues), Default = cleanDefaultValue({}), Multi = true, Callback = wrapDropdownCallback(function(val) Config.SelectedMutations = {}; for _, v in ipairs(val) do table.insert(Config.SelectedMutations, v.Title) end end, true)})
        ExclusiveTab_Sec_AutoFavorite:AddToggle({
            Name = "Auto Favorite", Default = false,
            Callback = function(val)
                Config.AutoFavoriteState = val
                if val then Tasks.AutoFavoriteThread = task.spawn(function() while Config.AutoFavoriteState do RunAutoFavLoop(false); task.wait(5) end end)
                else if Tasks.AutoFavoriteThread then pcall(function() task.cancel(Tasks.AutoFavoriteThread) end) end end
            end
        })
        ExclusiveTab_Sec_AutoFavorite:AddToggle({
            Name = "Auto Unfavorite", Default = false,
            Callback = function(val)
                Config.AutoUnfavoriteState = val
                if val then Tasks.AutoUnfavoriteThread = task.spawn(function() while Config.AutoUnfavoriteState do RunAutoFavLoop(true); task.wait(5) end end)
                else if Tasks.AutoUnfavoriteThread then pcall(function() task.cancel(Tasks.AutoUnfavoriteThread) end) end end
            end
        })

        
        local ExclusiveTab_Sec_TotemControls = ExclusiveTab_Tabbox3:AddTab("Totem Controls", "lucide:shapes")
        local totemData = { ["Pilih Totem"] = 0, ["Luck Totem"] = 1, ["Mutation Totem"] = 2, ["Shiny Totem"] = 3, ["Love Totem"] = 5 }
        local totemValues = {{ Title = "Pilih Totem", Icon = "shrub" }, { Title = "Luck Totem", Icon = "clover" }, { Title = "Mutation Totem", Icon = "dna" }, { Title = "Shiny Totem", Icon = "sparkles" }, { Title = "Love Totem", Icon = "heart" }}
        ExclusiveTab_Sec_TotemControls:AddDropdown({ Name = "Choose Totem", Values = cleanDropdownValues(totemValues), Default = cleanDefaultValue(totemValues[1]), Multi = false, Callback = wrapDropdownCallback(function(val) Config.SelectedTotemID = totemData[val.Title] or 0; NotifyInfo("Totem", "Sekarang: " .. val.Title) end, false)})
        ExclusiveTab_Sec_TotemControls:AddToggle({
            Name = "Auto Spawn Totem", Desc = "Spawn otomatis dengan cooldown 1 jam", Default = false,
            Callback = function(Value)
                Config.AutoTotem = Value
                if Value then
                    Tasks.totemTask = task.spawn(function()
                        while Config.AutoTotem do
                            pcall(function()
                                local totemUUID = nil
                                pcall(function()
                                    local replion = GetPlayerDataReplion(); local inv = replion and replion:GetExpect("Inventory")
                                    if inv and inv.Totems then for _, item in ipairs(inv.Totems) do if Config.SelectedTotemID == 0 or item.Id == Config.SelectedTotemID then totemUUID = item.UUID; break end end end
                                end)
                                if totemUUID and Events.SpawnTotem then pcall(function() Events.SpawnTotem:FireServer(totemUUID) end); task.wait(3); equipRod() end
                            end)
                            task.wait(3600)
                        end
                    end)
                else if Tasks.totemTask then pcall(function() task.cancel(Tasks.totemTask) end) end end
            end
        })

        
        ExclusiveTab_Tabbox4 = ExclusiveTab:AddTabbox({ Name = "Auto Mix 3 Totem [BETA]", Position = "center" })
        local ExclusiveTab_Sec_AutoMix3TotemBETA = ExclusiveTab_Tabbox4:AddTab("Auto Mix 3 Totem [BETA]", "lucide:shapes")
        local function TweenTo(targetCFrame, duration)
            local hrp = getHRP()
            if not hrp then return end
            hrp.Anchored = true
            local t = game:GetService("TweenService"):Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
            t:Play(); t.Completed:Wait()
            task.wait(0.1)
        end

        ExclusiveTab_Sec_AutoMix3TotemBETA:AddToggle({
            Name = "Mix 3 Totem", Desc = "Bypass System", Default = false,
            Callback = function(v)
                Config.AutoMixTotem = v
                if v then
                    Tasks.mixTotemThread = task.spawn(function()
                        local REF_CENTER = Vector3.new(93.932, 9.532, 2684.134)
                        local REF_SPOTS = { Vector3.new(45.046, 13.5, 2730.19), Vector3.new(145.64, 13.5, 2721.9), Vector3.new(84.64, 14.2, 2636.05) }
                        local MIX_CONFIG = {{ name = "Shiny Totem", id = 3 }, { name = "Luck Totem", id = 1 }, { name = "Mutation Totem", id = 2 }}

                        while Config.AutoMixTotem do
                            local hrp = getHRP()
                            if not hrp then task.wait(5); continue end
                            local startCFrame = hrp.CFrame

                            for i, config in ipairs(MIX_CONFIG) do
                                if not Config.AutoMixTotem then break end
                                local targetCFrame = CFrame.new(startCFrame.Position + (REF_SPOTS[i] - REF_CENTER))
                                TweenTo(targetCFrame, 0.7)

                                local p = Instance.new("Part", workspace)
                                p.Size = Vector3.new(12, 1, 12)
                                p.Anchored = true
                                p.CFrame = targetCFrame * CFrame.new(0, -3.5, 0)
                                p.Transparency = 1 
                                p.CanCollide = false
                                hrp.Anchored = false; task.wait(0.2)

                                local uuid = nil
                                pcall(function()
                                    local inv = GetPlayerDataReplion():GetExpect("Inventory")
                                    for _, item in ipairs(inv.Totems) do if item.Id == config.id then uuid = item.UUID; break end end
                                end)

                                if uuid and Events.SpawnTotem then
                                    Events.SpawnTotem:FireServer(uuid)
                                    task.spawn(function() for _=1,3 do Events.equip:FireServer(1) task.wait(0.15) end end)
                                end
                                task.wait(1.2); p:Destroy(); hrp.Anchored = true
                            end
                            if Config.AutoMixTotem then
                                TweenTo(startCFrame, 1.5); hrp.Anchored = false
                                NotifySuccess("Mix Totem", "Ritual selesai! Cooldown 1 jam")
                                task.wait(3600)
                            end
                        end
                    end)
                else
                    if Tasks.mixTotemThread then pcall(function() task.cancel(Tasks.mixTotemThread) end) end
                    if LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then 
                        LocalPlayer.Character.HumanoidRootPart.Anchored = false 
                    end
                end
            end
        })

        
        local ExclusiveTab_Sec_Webhook = ExclusiveTab_Tabbox4:AddTab("Webhook", "lucide:webhook")
        ExclusiveTab_Sec_Webhook:AddToggle({ Name = "Enable Custom Webhook", Default = false, Callback = function(val) Config.CustomWebhook = val end })
        ExclusiveTab_Sec_Webhook:AddTextInput({ Name = "Webhook URL", Placeholder = "https://discord.com/api/webhooks/...", Default = "", Callback = function(text) if text and text ~= "" then Config.CustomWebhookUrl = text end end })
        local webhookRarityValues = {{Title="Common"},{Title="Uncommon"},{Title="Rare"},{Title="Epic"},{Title="Legendary"},{Title="Mythic"},{Title="SECRET"}}
        ExclusiveTab_Sec_Webhook:AddDropdown({ Name = "Filter Rarity (Kosong = Semua)", Values = cleanDropdownValues(webhookRarityValues), Default = cleanDefaultValue({}), Multi = true, Callback = wrapDropdownCallback(function(val) Config.WebhookRarities = {}; for _, v in ipairs(val) do table.insert(Config.WebhookRarities, string.upper(v.Title)) end end, true)})

    end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end
end
           
        
        local MainTab_Sec_CrystalMining = MainTab_Tabbox5:AddTab("Crystal Mining", "lucide:gem")

        _G.axeUuid = _G.axeUuid or ""

        local function getAxeUUID()
            local inv = PlayerData and PlayerData:GetExpect("Inventory")
            if inv and inv.Items then
                for _, item in pairs(inv.Items) do
                    local itemData = ItemUtility and ItemUtility:GetItemData(item.Id)
                    if itemData and itemData.Data and (itemData.Data.Name:match("Axe") or itemData.Data.Name:match("Pickaxe")) then
                        _G.axeUuid = item.UUID
                        return item.UUID
                    end
                end
            end
            return nil
        end

        local function getInstancePosition(inst)
            if not inst then return nil end
            if inst:IsA("BasePart") then
                return inst.Position
            elseif inst:IsA("Model") then
                local ok, cf = pcall(function()
                    return inst:GetPivot()
                end)
                if ok and cf then
                    return cf.Position
                end
            end
            return nil
        end

        local function isSafeMiningPosition(pos)
            return typeof(pos) == "Vector3"
                and math.abs(pos.X) < 100000
                and math.abs(pos.Y) < 100000
                and math.abs(pos.Z) < 100000
                and pos.Y > -5000
        end

        local function findNearestGlowingCrystal()
            local hrp = getHRP()
            local bestCrystal, bestPos, bestDistance = nil, nil, math.huge
            for _, crystal in ipairs(CollectionService:GetTagged("GlowingCrystal")) do
                if crystal and crystal:IsDescendantOf(Workspace) then
                    local pos = getInstancePosition(crystal)
                    if isSafeMiningPosition(pos) then
                        local dist = hrp and (hrp.Position - pos).Magnitude or 0
                        if dist < bestDistance then
                            bestCrystal, bestPos, bestDistance = crystal, pos, dist
                        end
                    end
                end
            end
            return bestCrystal, bestPos
        end

        local function equipPickaxe()
            local uuid = getAxeUUID()
            if not uuid then return false end
            if not Events.equipItem then Events.equipItem = GetServerRemote("RE/EquipItem") end
            if not Events.equipItem then return false end
            local ok = CallRemote(Events.equipItem, uuid, "Gears")
            if not ok then
                ok = CallRemote(Events.equipItem, uuid, "Items")
            end
            return ok
        end

        local function safeTeleportToCrystal(pos)
            local hrp = getHRP()
            if not hrp or not isSafeMiningPosition(pos) then return false end
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
            return true
        end

        MainTab_Sec_CrystalMining:AddButton({
            Name = "Manual Mining Crystal",
            Desc = "Teleport ke Glowing Crystal aktif & equip pickaxe",
            Callback = function()
                if not equipPickaxe() then
                    NotifyError("Mining", "Pickaxe tidak ditemukan / gagal equip.")
                    return
                end

                local hrp = getHRP()
                if not hrp then return end
                local savedCFrame = hrp.CFrame
                _G.isMining = true

                local _, crystalPos = findNearestGlowingCrystal()
                if not crystalPos then
                    _G.isMining = false
                    NotifyWarning("Mining", "Tidak ada Glowing Crystal aktif. Tidak teleport agar tidak jatuh ke void.")
                    return
                end

                NotifyInfo("Mining", "Teleport ke Glowing Crystal aktif...")
                if not safeTeleportToCrystal(crystalPos) then
                    _G.isMining = false
                    NotifyError("Mining", "Posisi crystal tidak valid, teleport dibatalkan.")
                    return
                end

                task.wait(6)
                _G.isMining = false
                hrp.CFrame = savedCFrame
                NotifySuccess("Mining", "Selesai! Kembali ke posisi semula.")
            end
        })

        MainTab_Sec_CrystalMining:AddToggle({
            Name = "Auto Mining Crystal",
            Desc = "Otomatis siapkan Axe saat event muncul",
            Default = false,
            Callback = function(state)
                _G.AutoMining = state
                if state then
                    if not equipPickaxe() then
                        NotifyWarning("Mining", "Pickaxe tidak ditemukan, silakan ambil/beli Pickaxe dulu.")
                    else
                        NotifySuccess("Mining", "Siap! Pickaxe sudah di-equip. Cari Glowing Crystal untuk mining.")
                    end
                else
                    NotifyInfo("Mining", "Dimatikan")
                end
            end
        })


-- CRAFT & ABILITY TAB (BARU)
if CraftAbilityTab then
    local ok, err = pcall(function()
        
        CraftAbilityTab_Tabbox1 = CraftAbilityTab:AddTabbox({ Name = "Auto Crafting", Position = "center" })
        local CraftAbilityTab_Sec_AutoCrafting = CraftAbilityTab_Tabbox1:AddTab("Auto Crafting", "lucide:hammer")
        CraftAbilityTab_Sec_AutoCrafting:AddTextInput({
            Name = "Craft Delay", Placeholder = "1.5", Default = "1.5",
            Callback = function(text)
                local num = tonumber(text)
                if num and num >= 0.5 then Config.CraftingDelay = num end
            end
        })
        local craftableItems = {{Title="Winged Charm"}, {Title="Oculus Charm"}, {Title="Anchor Charm"}, {Title="Hook Charm"}, {Title="Withering Rod"}, {Title="Enchant Stone"}, {Title="Super Enchant Stone"}, {Title="Luck I Potion"}, {Title="Luck II Potion"}, {Title="Mutation I Potion"}}
        CraftAbilityTab_Sec_AutoCrafting:AddDropdown({ Name = "Pilih Recipe", Values = cleanDropdownValues(craftableItems), Default = cleanDefaultValue(craftableItems[1]), Multi = false, Callback = wrapDropdownCallback(function(val) 
            CraftingConfig.SelectedRecipeId = val.Title
            NotifyInfo("Crafting", "Recipe set ke: " .. val.Title) 
        end, false)})
        CraftAbilityTab_Sec_AutoCrafting:AddTextInput({
            Name = "Custom Recipe Name (Opsional)", Placeholder = "Contoh: Ethereal Jetski", Default = "",
            Callback = function(text)
                if text and text ~= "" then
                    CraftingConfig.SelectedRecipeId = text
                    NotifyInfo("Crafting", "Recipe set ke: " .. text)
                end
            end
        })
        CraftAbilityTab_Sec_AutoCrafting:AddToggle({
            Name = "Auto Crafting", Desc = "Craft item otomatis", Default = false,
            Callback = function(val)
                Config.AutoCrafting = val
                if val then RunAutoCrafting(); NotifySuccess("Auto Craft", "Aktif!")
                else if Tasks.CraftingThread then pcall(function() task.cancel(Tasks.CraftingThread) end) end; NotifyWarning("Auto Craft", "Dimatikan.") end
            end
        })
        CraftAbilityTab_Sec_AutoCrafting:AddButton({
            Name = "Instant Craft",
            Desc = "Trigger instant craft 1x (Manual)",
            Callback = function()
                if not Events.StartCrafting then Events.StartCrafting = GetServerRemote("RF/StartCrafting") end
                if not Events.ConfirmCrafting then Events.ConfirmCrafting = GetServerRemote("RF/ConfirmCrafting") end
                if Events.StartCrafting then
                    task.spawn(function()
                        if CraftingConfig.SelectedRecipeId then
                            pcall(function() Events.StartCrafting:InvokeServer(CraftingConfig.SelectedRecipeId) end)
                        else
                            pcall(function() Events.StartCrafting:InvokeServer() end)
                        end
                        if Events.ConfirmCrafting then pcall(function() Events.ConfirmCrafting:InvokeServer() end) end
                        NotifySuccess("Instant Craft", "Crafting instan selesai!")
                    end)
                else NotifyError("Craft", "Remote tidak ditemukan!") end
            end
        })        CraftAbilityTab_Sec_AutoCrafting:AddButton({
            Name = "Cancel Crafting",
            Callback = function()
                if not Events.CancelCrafting then Events.CancelCrafting = GetServerRemote("RF/CancelCrafting") end
                if Events.CancelCrafting then pcall(function() Events.CancelCrafting:InvokeServer() end); NotifyInfo("Craft", "Crafting dibatalkan!")
                else NotifyError("Craft", "Remote tidak ditemukan!") end
            end
        })

        
        local CraftAbilityTab_Sec_AbilitySystem = CraftAbilityTab_Tabbox1:AddTab("Ability System", "lucide:zap")

        CraftAbilityTab_Sec_AbilitySystem:AddButton({
            Name = "Roll Ability",
            Desc = "Roll ability baru",
            Callback = function()
                if not Events.RequestAbilityRoll then
                    Events.RequestAbilityRoll = GetServerRemote("RF/RequestAbilityRoll")
                end
                if Events.RequestAbilityRoll then
                    pcall(function() Events.RequestAbilityRoll:InvokeServer() end)
                    NotifySuccess("Ability", "Roll ability dikirim!")
                else
                    NotifyError("Ability", "Remote tidak ditemukan!")
                end
            end
        })

        CraftAbilityTab_Sec_AbilitySystem:AddButton({
            Name = "Convert Ability Shards",
            Desc = "Convert shards jadi ability",
            Callback = function()
                if not Events.ConvertAbilityShards then
                    Events.ConvertAbilityShards = GetServerRemote("RF/ConvertAbilityShards")
                end
                if Events.ConvertAbilityShards then
                    pcall(function() Events.ConvertAbilityShards:InvokeServer() end)
                    NotifySuccess("Ability", "Convert shards dikirim!")
                else
                    NotifyError("Ability", "Remote tidak ditemukan!")
                end
            end
        })

        CraftAbilityTab_Sec_AbilitySystem:AddButton({
            Name = "Claim Ability Reward",
            Desc = "Claim progress reward ability",
            Callback = function()
                if not Events.ClaimAbilityReward then
                    Events.ClaimAbilityReward = GetServerRemote("RF/ClaimAbilityRewardProgress")
                end
                if Events.ClaimAbilityReward then
                    pcall(function() Events.ClaimAbilityReward:InvokeServer() end)
                    NotifySuccess("Ability", "Claim reward dikirim!")
                else
                    NotifyError("Ability", "Remote tidak ditemukan!")
                end
            end
        })

        CraftAbilityTab_Sec_AbilitySystem:AddToggle({
            Name = "Equip Hazmat Suit",
            Desc = "Untuk memancing di area Lava Basin",
            Default = false,
            Callback = function(val)
                if val then
                    if not Events.EquipOxygenTank then Events.EquipOxygenTank = GetServerRemote("RF/EquipOxygenTank") end
                    if Events.EquipOxygenTank then
                        local tankId = nil
                        pcall(function()
                            local replion = GetPlayerDataReplion()
                            if replion then
                                local inv = replion:GetExpect("Inventory")
                                if inv and inv.Items then
                                    for _, item in ipairs(inv.Items) do
                                        local data = ItemUtility and ItemUtility:GetItemData(item.Id)
                                        if data and data.Data and data.Data.Name == "Hazmat Suit" then
                                            tankId = item.Id
                                            break
                                        end
                                    end
                                end
                            end
                        end)
                        if tankId then
                            pcall(function() Events.EquipOxygenTank:InvokeServer(tankId) end)
                            NotifySuccess("Hazmat", "Hazmat Suit equipped!")
                        else
                            NotifyError("Hazmat", "Tidak menemukan Hazmat Suit di tas!")
                        end
                    end
                else
                    if not Events.UnequipOxygenTank then Events.UnequipOxygenTank = GetServerRemote("RF/UnequipOxygenTank") end
                    if Events.UnequipOxygenTank then
                        pcall(function() Events.UnequipOxygenTank:InvokeServer() end)
                        NotifyInfo("Hazmat", "Hazmat Suit unequipped.")
                    end
                end
            end
        })

        CraftAbilityTab_Sec_AbilitySystem:AddToggle({
            Name = "Equip Oxygen Tank",
            Desc = "Untuk fishing di area underwater",
            Default = false,
            Callback = function(val)
                if val then
                    if not Events.EquipOxygenTank then Events.EquipOxygenTank = GetServerRemote("RF/EquipOxygenTank") end
                    if Events.EquipOxygenTank then
                        local tankId = nil
                        pcall(function()
                            local replion = GetPlayerDataReplion()
                            if replion then
                                local inv = replion:GetExpect("Inventory")
                                if inv and inv.Items then
                                    local bestTank = nil
                                    local maxOx = -1
                                    for _, item in ipairs(inv.Items) do
                                        local data = ItemUtility and ItemUtility:GetItemData(item.Id)
                                        if data and data.MaxOxygen then
                                            if data.MaxOxygen > maxOx then
                                                maxOx = data.MaxOxygen
                                                bestTank = item.Id
                                            end
                                        end
                                    end
                                    tankId = bestTank
                                end
                            end
                        end)
                        if tankId then
                            pcall(function() Events.EquipOxygenTank:InvokeServer(tankId) end)
                            NotifySuccess("Oxygen", "Oxygen Tank equipped!")
                        else
                            NotifyError("Oxygen", "Tidak menemukan Oxygen Tank di tas!")
                        end
                    end
                else
                    if not Events.UnequipOxygenTank then Events.UnequipOxygenTank = GetServerRemote("RF/UnequipOxygenTank") end
                    if Events.UnequipOxygenTank then
                        pcall(function() Events.UnequipOxygenTank:InvokeServer() end)
                        NotifyInfo("Oxygen", "Oxygen Tank unequipped.")
                    end
                end
            end
        })

        
        CraftAbilityTab_Tabbox2 = CraftAbilityTab:AddTabbox({ Name = "Transcended Stone (BARU)", Position = "center" })
        local CraftAbilityTab_Sec_TranscendedStoneBARU = CraftAbilityTab_Tabbox2:AddTab("Transcended Stone (BARU)", "lucide:gem")

        CraftAbilityTab_Sec_TranscendedStoneBARU:AddButton({
            Name = "Create Transcended Stone",
            Desc = "Buat Transcended Enchant Stone",
            Callback = function()
                if not Events.CreateTranscendedStone then
                    Events.CreateTranscendedStone = GetServerRemote("RF/CreateTranscendedStone")
                end
                if Events.CreateTranscendedStone then
                    pcall(function() Events.CreateTranscendedStone:InvokeServer() end)
                    NotifySuccess("Transcended", "Create Transcended Stone dikirim!")
                else
                    NotifyError("Transcended", "Remote tidak ditemukan!")
                end
            end
        })

        
        local CraftAbilityTab_Sec_RodCraftingMinigame = CraftAbilityTab_Tabbox2:AddTab("Rod Crafting Minigame", "lucide:hammer")

        CraftAbilityTab_Sec_RodCraftingMinigame:AddToggle({
            Name = "Auto Win Rod Minigame",
            Desc = "Centang ini sebelum ngobrol dengan NPC pembuat Rod",
            Default = false,
            Callback = function(val)
                Config.AutoRodMinigame = val
                if val then
                    task.spawn(function()
                        if not Events.FinishRodCraft then Events.FinishRodCraft = GetServerRemote("RF/FinishRodCraftingMinigame") end
                        while Config.AutoRodMinigame do
                            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                            local gui = pgui and pgui:FindFirstChild("RodCraftingGame")
                            if gui and gui.Enabled then
                                if Events.FinishRodCraft then 
                                    pcall(function() Events.FinishRodCraft:InvokeServer() end) 
                                    NotifySuccess("Minigame", "Rod Crafting dimenangkan otomatis!")
                                    task.wait(2) -- Beri jeda agar minigame tertutup/reset
                                end
                            end
                            task.wait(0.5)
                        end
                    end)
                end
            end
        })

    end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end
end

if AquariumTab then
    local ok, err = pcall(function()

        local AquariumRemotes = {}
        local function LoadAquariumRemotes()
            AquariumRemotes.GetState        = GetServerRemote("RF/AquariumGetState")
            AquariumRemotes.GetDirectory    = GetServerRemote("RF/AquariumGetDirectory")
            AquariumRemotes.SetPublic       = GetServerRemote("RF/AquariumSetPublic")
            AquariumRemotes.Like            = GetServerRemote("RF/AquariumLike")
            AquariumRemotes.UnlockZone      = GetServerRemote("RF/AquariumUnlockZone")
            AquariumRemotes.UnlockTank      = GetServerRemote("RF/AquariumUnlockTank")
            AquariumRemotes.SetTankFish     = GetServerRemote("RF/AquariumSetTankFish")
            AquariumRemotes.RemoveTankFish  = GetServerRemote("RF/AquariumRemoveTankFish")
            AquariumRemotes.PinShelfItem    = GetServerRemote("RF/AquariumPinShelfItem")
            AquariumRemotes.RequestVisit    = GetServerRemote("RF/AquariumRequestVisit")
            AquariumRemotes.VisitLoaded     = GetServerRemote("RF/AquariumVisitLoaded")
            AquariumRemotes.LeaveVisit      = GetServerRemote("RF/AquariumLeaveVisit")
            AquariumRemotes.StateUpdated    = GetServerRemote("RE/AquariumStateUpdated")
            AquariumRemotes.LoadVisit       = GetServerRemote("RE/AquariumLoadVisit")
            AquariumRemotes.VisitEnded      = GetServerRemote("RE/AquariumVisitEnded")

            AquariumRemotes.OpenTankUI = net and net:FindFirstChild(
                "RF/043b17085598df264eeb7c6ab6d4b07bf93d612443347731fa90186c1758b35c"
            )
        end
        LoadAquariumRemotes()

        -- STATE
        local AquaMgr = {
            SelectedTank = 1,       
            SelectedFishUUID = nil, 
            AutoManage = false,
            Thread = nil,
        }

        -- HELPER: Buka UI
        local function OpenTankUI(tankIndex)
            local indexMap = {
                [1]="Tank One", [2]="Tank Two", [3]="Tank Three", [4]="Tank Four", [5]="Tank Five",
                [6]="Tank Six", [7]="Tank Seven", [8]="Tank Eight", [9]="Tank Nine", [10]="Tank Ten",
                [11]="Tank Eleven", [12]="Tank Twelve", [13]="Tank Thirteen", [14]="Tank Fourteen", [15]="Tank Fifteen"
            }
            local tankId = indexMap[tankIndex] or ("Tank " .. tostring(tankIndex))
            
            local ok, err = pcall(function()
                local guiControl = require(ReplicatedStorage.Modules.GuiControl)
                if guiControl and guiControl.Open then
                    guiControl:Open("TankManagement", true, tankId)
                end
            end)
            if ok then
                NotifySuccess("Aquarium", tankId .. " UI dibuka!")
                return true
            else
                NotifyError("Aquarium", "Gagal membuka UI tank!")
                return false
            end
        end

        local function SetFishToTank(tankIndex, fishUUID, targetSlot)
            if not fishUUID then
                NotifyError("Aquarium", "Select a fish first!")
                return false
            end
            if not targetSlot then targetSlot = 1 end
            
            if not AquariumRemotes.SetTankFish then
                AquariumRemotes.SetTankFish = GetServerRemote("RF/AquariumSetTankFish")
            end
            
            local indexMap = {
                [1]="Tank One", [2]="Tank Two", [3]="Tank Three", [4]="Tank Four", [5]="Tank Five",
                [6]="Tank Six", [7]="Tank Seven", [8]="Tank Eight", [9]="Tank Nine", [10]="Tank Ten",
                [11]="Tank Eleven", [12]="Tank Twelve", [13]="Tank Thirteen", [14]="Tank Fourteen", [15]="Tank Fifteen"
            }
            local tankId = indexMap[tankIndex] or ("Tank " .. tostring(tankIndex))

            local ok, err = pcall(function()
                local res = AquariumRemotes.SetTankFish:InvokeServer(tankId, targetSlot, fishUUID)
                if type(res) == "table" and not res.Success then
                    error(tostring(res.Error) or "nil")
                end
            end)
            
            if ok then
                NotifySuccess("Aquarium", "Fish added to " .. tankId .. " (Slot " .. targetSlot .. ")")
                AquaMgr.SelectedFishUUID = nil
                pcall(function()
                    if fishDropdownRef and fishDropdownRef.SetValues then
                        fishDropdownRef:SetValues(cleanDropdownValues({{Title="-- Refresh first --", Icon="refresh-cw"}}))
                    end
                end)
                return true
            else
                local errMsg = tostring(err):gsub(".-:%d+: ", "")
                NotifyError("Aquarium", "Slot " .. targetSlot .. " Gagal: " .. errMsg)
                return false
            end
        end

        local function RemoveFishFromTank(tankIndex)
            if not AquariumRemotes.RemoveTankFish then
                AquariumRemotes.RemoveTankFish = GetServerRemote("RF/AquariumRemoveTankFish")
            end
            if not AquariumRemotes.GetState then
                AquariumRemotes.GetState = GetServerRemote("RF/AquariumGetState")
            end
            if not AquariumRemotes.RemoveTankFish then
                NotifyError("Aquarium", "Remote tidak ditemukan!"); return
            end
            
            local indexMap = {
                [1]="Tank One", [2]="Tank Two", [3]="Tank Three", [4]="Tank Four", [5]="Tank Five",
                [6]="Tank Six", [7]="Tank Seven", [8]="Tank Eight", [9]="Tank Nine", [10]="Tank Ten",
                [11]="Tank Eleven", [12]="Tank Twelve", [13]="Tank Thirteen", [14]="Tank Fourteen", [15]="Tank Fifteen"
            }
            local tankId = indexMap[tankIndex] or ("Tank " .. tostring(tankIndex))

            local state
            pcall(function() state = AquariumRemotes.GetState:InvokeServer() end)
            if not state then return end
            
            local tData = state.Data or state
            local tk = (tData.Tanks and tData.Tanks[tankId]) or (tData.State and tData.State.Tanks and tData.State.Tanks[tankId])
            
            if not tk or type(tk.Fish) ~= "table" then
                -- Tank kosong
                return
            end
            
            local removedCount = 0
            for k, v in pairs(tk.Fish) do
                local slotNum
                if type(k) == "number" then slotNum = k
                elseif type(k) == "string" and tonumber(k) then slotNum = tonumber(k)
                elseif type(v) == "table" and v.Slot then slotNum = tonumber(v.Slot)
                end
                
                if slotNum then
                    pcall(function()
                        AquariumRemotes.RemoveTankFish:InvokeServer(tankId, slotNum)
                        removedCount = removedCount + 1
                    end)
                    task.wait(0.1)
                end
            end
            
            if removedCount > 0 then
                NotifySuccess("Aquarium", removedCount .. " fish successfully removed from " .. tankId)
            end
        end

        local function EnterAquariumManager()
            -- Request visit / load aquarium
            if AquariumRemotes.RequestVisit then
                local ok, result = pcall(function()
                    return AquariumRemotes.RequestVisit:InvokeServer(LocalPlayer.UserId)
                end)
                if ok then
                    task.wait(1.5)
                    if AquariumRemotes.VisitLoaded then
                        pcall(function()
                            AquariumRemotes.VisitLoaded:InvokeServer()
                        end)
                    end
                    NotifySuccess("Aquarium", "Berhasil masuk Aquarium Manager!")
                    return true
                end
            end
            -- Fallback: GetState untuk refresh
            if AquariumRemotes.GetState then
                pcall(function()
                    AquariumRemotes.GetState:InvokeServer()
                end)
                NotifyInfo("Aquarium", "GetState dikirim ke server.")
            end
            return false
        end
-- AUTO AQUARIUM MANAGER LOOP

        -- UI AQUARIUM TAB

        
        AquariumTab_Tabbox1 = AquariumTab:AddTabbox({ Name = "Aquarium Management", Position = "center" })
        local AquariumTab_Sec_AquariumManagement = AquariumTab_Tabbox1:AddTab("Aquarium Management", "lucide:settings")

        AquariumTab_Sec_AquariumManagement:AddButton({
            Name = "Masuk Aquarium Manager",
            Desc = "Open.pintu Aquarium Manager",
            Callback = function()
                task.spawn(function()
                    local ok = EnterAquariumManager()
                    if not ok then
                        -- Fallback teleport ke lokasi aquarium
                        local hrp = getHRP()
                        if hrp then
                            hrp.CFrame = CFrame.new(460.5, 24.1, 2204.8)
                            NotifyInfo("Aquarium", "Teleport ke area aquarium sebagai fallback.")
                        end
                    end
                end)
            end
        })

        local aquariumParagraph = AquariumTab_Sec_AquariumManagement:AddParagraph({
            Name = "Data Aquarium (Read-Only)",
            RichText = true,
            Content = "Belum ada data di-load."
        })

        AquariumTab_Sec_AquariumManagement:AddButton({
            Name = "Load Aquarium",
            Desc = "Ambil data aquarium dan tampilkan di panel atas",
            Callback = function()
                task.spawn(function()
                    if not AquariumRemotes.GetState then
                        AquariumRemotes.GetState = GetServerRemote("RF/AquariumGetState")
                    end
                    if AquariumRemotes.GetState then
                        local result = nil
                        pcall(function() result = AquariumRemotes.GetState:InvokeServer() end)
                        if result then
                            local str = ""
                            if type(result) == "table" then
                                local stateData = result.Data or result
                                local tanksData = stateData.Tanks or (stateData.State and stateData.State.Tanks)
                                if tanksData then
                                    str = "DAFTAR ISI AQUARIUM ANDA:\n"
                                    
                                    local sortedTanks = {}
                                    for tName, _ in pairs(tanksData) do
                                        table.insert(sortedTanks, tostring(tName))
                                    end
                                    local orderMap = {
                                        ["Tank One"]=1, ["Tank Two"]=2, ["Tank Three"]=3, ["Tank Four"]=4, ["Tank Five"]=5, 
                                        ["Tank Six"]=6, ["Tank Seven"]=7, ["Tank Eight"]=8, ["Tank Nine"]=9, ["Tank Ten"]=10, 
                                        ["Tank Eleven"]=11, ["Tank Twelve"]=12, ["Tank Thirteen"]=13
                                    }
                                    table.sort(sortedTanks, function(a, b)
                                        local wa = orderMap[a] or 999
                                        local wb = orderMap[b] or 999
                                        if wa == wb then return a < b else return wa < wb end
                                    end)

                                    for _, tankName in ipairs(sortedTanks) do
                                        local tankData = tanksData[tankName]
                                        str = str .. "\n[" .. tankName .. "]"
                                        local count = 0
                                        if type(tankData) == "table" and type(tankData.Fish) == "table" then
                                            for _, fish in pairs(tankData.Fish) do
                                                if type(fish) == "table" and fish.Id then
                                                    count = count + 1
                                                    local fishName = tostring(fish.Id)
                                                    pcall(function()
                                                        local fd = ItemUtility and ItemUtility:GetItemData(fish.Id)
                                                        if fd and fd.Data and fd.Data.Name then fishName = fd.Data.Name end
                                                    end)
                                                    str = str .. "\n  - " .. fishName
                                                    if fish.Mutated then str = str .. " [Mutated]" end
                                                    if fish.Weight then str = str .. " (" .. string.format("%.1f", fish.Weight) .. "kg)" end
                                                end
                                            end
                                        end
                                        if count == 0 then
                                            str = str .. "\n  (Kosong)"
                                        end
                                    end
                                else
                                    str = "Struktur data tank tidak ditemukan!"
                                end
                            else
                                str = tostring(result)
                            end
                            
                            if str == "" then str = "Data kosong!" end
                            
                            if aquariumParagraph then
                                if type(aquariumParagraph.SetContent) == "function" then
                                    aquariumParagraph:SetContent(str)
                                elseif type(aquariumParagraph.SetDesc) == "function" then
                                    aquariumParagraph:SetDesc(str)
                                end
                            end
                            NotifySuccess("Aquarium", "Data berhasil ditampilkan di UI!")
                        else
                            NotifyWarning("Aquarium", "Data kosong / gagal!")
                        end
                    else
                        NotifyError("Aquarium", "Remote GetState tidak ditemukan!")
                    end
                end)
            end
        })
-- PILIH TANK
        
        local AquariumTab_Sec_ListTank = AquariumTab_Tabbox1:AddTab("List Tank", "lucide:waves")

        local tankValues = {}
        for i = 1, 15 do
            table.insert(tankValues, { Title = "Tank " .. tostring(i), Icon = "box" })
        end
        AquariumTab_Sec_ListTank:AddDropdown({
            Name = "Pilih Tank",
            Desc = "Pilih tank yang ingin dikelola",
            Values = cleanDropdownValues(tankValues),
            Default = cleanDefaultValue(tankValues[1]),
            Multi = false,
            Callback = wrapDropdownCallback(function(val)
                local idx = tonumber(val.Title:match("%d+")) or 1
                AquaMgr.SelectedTank = idx
                NotifyInfo("Aquarium", "Tank " .. idx .. " dipilih.")
            end, false)})


-- ADD IKAN KE TANK
        
        AquariumTab_Tabbox2 = AquariumTab:AddTabbox({ Name = "Add Fish Tou Tank", Position = "center" })
        local AquariumTab_Sec_AddFishTouTank = AquariumTab_Tabbox2:AddTab("Add Fish Tou Tank", "lucide:waves")

        -- Dropdown pilih ikan (direfresh manual)
        local fishDropdownValues = {{ Title = "-- Refresh first --", Icon = "refresh-cw" }}
        local fishDropdownRef = AquariumTab_Sec_AddFishTouTank:AddDropdown({
            Name = "Pilih Fish",
            Desc = "Pilih ikan dari inventory untuk dimasukkan ke tank",
            Values = cleanDropdownValues(fishDropdownValues),
            Default = cleanDefaultValue(fishDropdownValues[1]),
            Multi = false,
            Callback = wrapDropdownCallback(function(val)
                if val.Title == "-- Refresh first --" then return end
                local fishList = GetFishList()
                for _, fish in ipairs(fishList) do
                    if fish.Display == val.Title then
                        -- use first available UUID from the group
                        AquaMgr.SelectedFishUUID = fish.Items[1]
                        NotifyInfo("Aquarium", "Ikan dipilih: " .. fish.Name .. " [" .. fish.Rarity .. "] (" .. fish.Count .. " pcs)")
                        break
                    end
                end
            end, false)})

        AquariumTab_Sec_AddFishTouTank:AddButton({
            Name = "Refresh Daftar Ikan",
            Desc = "Ambil ikan terbaru dari inventory",
            Callback = function()
                local fishList = GetFishList()
                if #fishList == 0 then
                    NotifyWarning("Aquarium", "Tidak ada ikan SECRET/FORGOTTEN/MYTHIC di inventory!")
                    return
                end
                -- Update dropdown values
                local newValues = {}
                for _, fish in ipairs(fishList) do
                    table.insert(newValues, { Title = fish.Display, Icon = "fish" })
                end
                -- WindUI dropdown update (jika supported)
                pcall(function()
                    if fishDropdownRef and fishDropdownRef.SetValues then
                        fishDropdownRef:SetValues(cleanDropdownValues(newValues)):SetValue(cleanDefaultValue(newValues[1]))
                    end
                end)
                NotifySuccess("Aquarium", "Daftar ikan direfresh! (" .. #fishList .. " ikan)")
            end
        })

        AquariumTab_Sec_AddFishTouTank:AddSlider({
            Name = "Select Slot",
            Min = 1,
            Max = 15,
            Default = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Increment = 1,
            ValueName = "Slot",
            Callback = function(Value)
                AquaMgr.SelectedSlot = Value
            end
        })

        AquariumTab_Sec_AddFishTouTank:AddButton({
            Name = "Add Fish to Tank",
            Desc = "Add selected fish to the target tank directly",
            Callback = function()
                if not AquaMgr.SelectedFishUUID then
                    NotifyError("Aquarium", "Select a fish from the dropdown first!")
                    return
                end
                SetFishToTank(AquaMgr.SelectedTank, AquaMgr.SelectedFishUUID, AquaMgr.SelectedSlot or 1)
            end
        })

        -- Tombol cepat per tank
        


        -- HAPUS IKAN
        
        AquariumTab_Tabbox3 = AquariumTab:AddTabbox({ Name = "Remove Fish", Position = "center" })
        local AquariumTab_Sec_RemoveFish = AquariumTab_Tabbox3:AddTab("Remove Fish", "lucide:waves")

        AquariumTab_Sec_RemoveFish:AddButton({
            Name = "Clear Selected Tank",
            Desc = "Remove all fish from the currently selected tank",
            Callback = function()
                RemoveFishFromTank(AquaMgr.SelectedTank)
            end
        })
        
        AquariumTab_Sec_RemoveFish:AddButton({
            Name = "Clear ALL Tanks (1-15)",
            Desc = "Remove all fish from ALL tanks (May take a moment)",
            Callback = function()
                NotifyInfo("Aquarium", "Started clearing 15 tanks...")
                for t = 1, 15 do
                    RemoveFishFromTank(t)
                    task.wait(0.2)
                end
                NotifySuccess("Aquarium", "All tanks successfully cleared!")
            end
        })

        -- AUTO SETTINGS
        
        local AquariumTab_Sec_AutoAquariumManager = AquariumTab_Tabbox3:AddTab("Auto Aquarium Manager", "lucide:settings")

        AquariumTab_Sec_AutoAquariumManager:AddToggle({
            Name = "Set Public",
            Desc = "Set aquarium jadi public otomatis",
            Default = false,
            Callback = function(val)
                Config.AquariumAutoPublic = val
                if val then
                    if not AquariumRemotes.SetPublic then
                        AquariumRemotes.SetPublic = GetServerRemote("RF/AquariumSetPublic")
                    end
                    if AquariumRemotes.SetPublic then
                        pcall(function() AquariumRemotes.SetPublic:InvokeServer(true) end)
                        NotifySuccess("Aquarium", "Set public berhasil!")
                    else
                        NotifyError("Aquarium", "Remote SetPublic tidak ditemukan!")
                    end
                end
            end
        })

        

        

        -- VISIT
        
        AquariumTab_Tabbox4 = AquariumTab:AddTabbox({ Name = "Aquarium Visit", Position = "center" })
        local AquariumTab_Sec_AquariumVisit = AquariumTab_Tabbox4:AddTab("Aquarium Visit", "lucide:eye")

        AquariumTab_Sec_AquariumVisit:AddButton({
            Name = "Leave Visit",
            Callback = function()
                if AquariumRemotes.LeaveVisit then
                    pcall(function() AquariumRemotes.LeaveVisit:InvokeServer() end)
                    NotifyInfo("Aquarium", "Leave visit dikirim.")
                else
                    NotifyError("Aquarium", "LeaveVisit tidak ditemukan!")
                end
            end
        })

        AquariumTab_Sec_AquariumVisit:AddButton({
            Name = "Like This Aquarium",
            Callback = function()
                if not AquariumRemotes.Like then
                    AquariumRemotes.Like = GetServerRemote("RF/AquariumLike")
                end
                if AquariumRemotes.Like then
                    pcall(function() AquariumRemotes.Like:InvokeServer() end)
                    NotifySuccess("Aquarium", "Like dikirim!")
                else
                    NotifyError("Aquarium", "Like tidak ditemukan!")
                end
            end
        })

    end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end
end
-- TELEPORT TAB
if TeleportTab then
    local ok, err = pcall(function()
        
        TeleportTab_Tabbox1 = TeleportTab:AddTabbox({ Name = "Map Locations", Position = "center" })
        local TeleportTab_Sec_MapLocations = TeleportTab_Tabbox1:AddTab("Map Locations", "lucide:map-pin")
        local locationNames = {}; for name in pairs(LOCATIONS) do table.insert(locationNames, name) end; table.sort(locationNames)
        local selectedLocation = locationNames[1]
        local locationValues = {}; for _, name in ipairs(locationNames) do table.insert(locationValues, { Title = name, Icon = "map-pin" }) end
        TeleportTab_Sec_MapLocations:AddDropdown({ Name = "Pilih Lokasi", Values = cleanDropdownValues(locationValues), Default = cleanDefaultValue(locationValues[1]), Multi = false, Callback = wrapDropdownCallback(function(val) selectedLocation = val.Title end, false)})
        TeleportTab_Sec_MapLocations:AddButton({ Name = "Teleport ke Lokasi", Callback = function()
            if selectedLocation and LOCATIONS[selectedLocation] then teleportTo(selectedLocation); NotifySuccess("TP", "Berhasil ke " .. selectedLocation .. "!")
            else NotifyError("TP", "Lokasi tidak ditemukan!") end
        end })
        
        local TeleportTab_Sec_PlayerTeleport = TeleportTab_Tabbox1:AddTab("Player Teleport", "lucide:map-pin")
        local selectedPlayerTP = nil
        local playerList = {}; for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(playerList, p.Name) end end; table.sort(playerList)
        local playerValues = {}; for _, name in ipairs(playerList) do table.insert(playerValues, { Title = name, Icon = "user" }) end
        if #playerValues == 0 then table.insert(playerValues, { Title = "Tidak ada player lain", Icon = "user-x" }) end
        TeleportTab_Sec_PlayerTeleport:AddDropdown({ Name = "Pilih Player", Values = cleanDropdownValues(playerValues), Default = cleanDefaultValue(playerValues[1]), Multi = false, Callback = wrapDropdownCallback(function(val) selectedPlayerTP = val.Title end, false)})
        TeleportTab_Sec_PlayerTeleport:AddButton({ Name = "Teleport ke Player", Callback = function()
            if not selectedPlayerTP or selectedPlayerTP == "Tidak ada player lain" then NotifyError("TP", "Pilih player dulu!"); return end
            local target = Players:FindFirstChild(selectedPlayerTP)
            if not target or not target.Character then NotifyError("TP", "Character tidak ditemukan!"); return end
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart"); local hrp = getHRP()
            if hrp and targetHRP then hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0); NotifySuccess("TP", "Berhasil ke " .. selectedPlayerTP .. "!") end
        end })

        local TeleportTab_Sec_NPCTeleport = TeleportTab_Tabbox1:AddTab("Teleport to NPC", "lucide:users")
        local npcNames = {
            "Alex", "Alien Merchant", "Alyssa", "Amanda", "Archaeologist", "Aura Kid",
            "Bartholomew", "Benthic", "Billy Bob", "Blacksmith", "Boat Expert", "Burt",
            "Capt Jack", "Captain Jones", "Carpenter", "Chad", "Clara", "Corlow",
            "Crabby Guy", "Dead Skeleton", "Deep Sea Researcher", "Diamond Researcher",
            "Dorian", "Duck Boy", "Esoteric Gatekeeper", "Eugene", "Fish Merchant",
            "Fishmonger", "Fishy Researcher", "Forager Jen", "Frog Commander",
            "Ghastly Pirate", "Goalie", "Grandma Starla", "Hank", "Hans", "Hazmat Leader",
            "Jed", "Jeffery", "Jess", "Joe", "Jones", "Jordan", "Kansas", "Lava Dweller",
            "Lava Fisherman", "Lucid", "Magma Fisherman", "Mayor Starfall", "McBoatson",
            "Musician", "Narwhal", "Navigator", "Nervous Prospector", "Null", "Outlaw",
            "Prospector", "Ralph", "Ram", "Ray", "Reactor Man", "Robot Merchant",
            "Rocket Scientist", "Ron", "Sam", "Scientist", "Scott", "Scuba Steve",
            "Seth", "Sheriff", "Silly Fisherman", "Spikey", "Starfall Steward",
            "Submarine Operator", "Temple Guardian", "Tour Guide", "Volcanic Fisherman"
        }
        table.sort(npcNames)
        local selectedNPC = npcNames[1]
        local function buildNPCValues()
            local values = {}
            for _, name in ipairs(npcNames) do
                table.insert(values, { Title = name, Icon = "user" })
            end
            return values
        end
        local function findNPCModel(name)
            local npcFolder = Workspace:FindFirstChild("NPC")
            if not npcFolder then return nil end
            return npcFolder:FindFirstChild(name)
        end
        local function getNPCCFrame(npc)
            if not npc then return nil end
            if npc:IsA("BasePart") then return npc.CFrame end
            if npc:IsA("Model") then
                local part = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart or npc:FindFirstChild("Head") or npc:FindFirstChildWhichIsA("BasePart", true)
                if part then return part.CFrame end
                local ok, pivot = pcall(function() return npc:GetPivot() end)
                if ok then return pivot end
            end
            local part = npc:FindFirstChildWhichIsA("BasePart", true)
            return part and part.CFrame or nil
        end
        local npcValues = buildNPCValues()
        local npcDropdown = TeleportTab_Sec_NPCTeleport:AddDropdown({
            Name = "Pilih NPC",
            Values = cleanDropdownValues(npcValues),
            Default = cleanDefaultValue(npcValues[1]),
            Multi = false,
            Callback = wrapDropdownCallback(function(val) selectedNPC = val.Title end, false)
        })
        TeleportTab_Sec_NPCTeleport:AddButton({
            Name = "Refresh NPC",
            Callback = function()
                local values = buildNPCValues()
                pcall(function()
                    if npcDropdown and npcDropdown.SetValues then
                        npcDropdown:SetValues(cleanDropdownValues(values)):SetValue(selectedNPC or cleanDefaultValue(values[1]))
                    end
                end)
                NotifySuccess("NPC", "Daftar NPC direfresh!")
            end
        })
        TeleportTab_Sec_NPCTeleport:AddButton({
            Name = "Teleport ke NPC",
            Callback = function()
                if not selectedNPC then NotifyError("NPC", "Pilih NPC dulu!"); return end
                local npc = findNPCModel(selectedNPC)
                if not npc then NotifyError("NPC", "NPC '" .. selectedNPC .. "' tidak ditemukan di workspace!"); return end
                local targetCFrame = getNPCCFrame(npc)
                local hrp = getHRP()
                if not hrp then NotifyError("NPC", "HumanoidRootPart player tidak ditemukan!"); return end
                if not targetCFrame then NotifyError("NPC", "Posisi NPC tidak ditemukan!"); return end
                hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
                NotifySuccess("NPC", "Berhasil teleport ke " .. selectedNPC .. "!")
            end
        })
    end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end
end
-- SHOP TAB
if ShopTab then
    local ok, err = pcall(function()
        
        ShopTab_Tabbox1 = ShopTab:AddTabbox({ Name = "Buy Weather Event", Position = "center" })
        local ShopTab_Sec_BuyWeatherEvent = ShopTab_Tabbox1:AddTab("Buy Weather Event", "lucide:shopping-cart")
        local weatherMap = {["Windy (10k)"]="Wind",["Fog (20k)"]="Fog",["Stormy (35k)"]="Storm",["Radiant (50k)"]="Radiant",["Treasure Hunt (750k)"]="Treasure Hunt"}
        local weatherNames = {}; for name in pairs(weatherMap) do table.insert(weatherNames, name) end; table.sort(weatherNames)
        local selectedWeathers = {}
        local weatherValues = {}; for _, name in ipairs(weatherNames) do table.insert(weatherValues, { Title = name, Icon = "cloud" }) end
        ShopTab_Sec_BuyWeatherEvent:AddDropdown({ Name = "Pilih Weather", Values = cleanDropdownValues(weatherValues), Default = cleanDefaultValue({}), Multi = true, Callback = wrapDropdownCallback(function(val) selectedWeathers = {}; for _, v in ipairs(val) do table.insert(selectedWeathers, v.Title) end end, true)})
        ShopTab_Sec_BuyWeatherEvent:AddButton({ Name = "Buy Selected Weather", Callback = function()
            if #selectedWeathers == 0 then NotifyError("Weather", "Pilih weather dulu!"); return end
            if not Events.BuyWeather then Events.BuyWeather = GetServerRemote("RF/PurchaseWeatherEvent") end
            if not Events.BuyWeather then NotifyError("Weather", "Remote tidak ditemukan!"); return end
            
            for _, name in ipairs(selectedWeathers) do 
                local key = weatherMap[name]
                if key then 
                    local pcallSuccess, invokeResult = pcall(function() 
                        return Events.BuyWeather:InvokeServer(key) 
                    end)
                    if pcallSuccess and invokeResult then
                        NotifySuccess("Weather", "Berhasil membeli: " .. name)
                    else
                        local errMsg = tostring(invokeResult)
                        if not pcallSuccess then
                            errMsg = "Error: " .. errMsg
                        elseif invokeResult == nil then
                            errMsg = "Server mengembalikan 'nil' (Ditolak / Delay)"
                        end
                        NotifyError("Weather", "Gagal beli " .. key .. " -> " .. errMsg)
                    end
                    task.wait(2.5) 
                end 
            end
        end })
        -- AUTO BUY 3 WEATHER: CLOUDY + WIND + THUNDER
        ShopTab_Sec_BuyWeatherEvent:AddButton({
            Name = "Buy 3 Weather",
            Desc = "Langsung beli Cloudy, Wind, dan Thunder sekaligus",
            Callback = function()
                if not Events.BuyWeather then Events.BuyWeather = GetServerRemote("RF/PurchaseWeatherEvent") end
                if not Events.BuyWeather then NotifyError("Weather", "Remote tidak ditemukan!"); return end
                local threeWeather = {"Fog", "Wind", "Storm"}
                local bought = 0
                for _, w in ipairs(threeWeather) do
                    local ok = pcall(function() Events.BuyWeather:InvokeServer(w) end)
                    if ok then bought = bought + 1; NotifySuccess("3 Weather", "Purchased: " .. w) end
                    task.wait(0.3)
                end
                if bought == 3 then
                    NotifySuccess("3 Weather", "Semua 3 weather berhasil dibeli!")
                else
                    NotifyWarning("3 Weather", "Hanya " .. bought .. "/3 berhasil dibeli.")
                end
            end
        })
        ShopTab_Sec_BuyWeatherEvent:AddToggle({
            Name = "Buy Weather", Default = false,
            Callback = function(val)
                _G.AutoBuyWeather = val
                if val then
                    task.spawn(function()
                        while _G.AutoBuyWeather do
                            if not Events.BuyWeather then Events.BuyWeather = GetServerRemote("RF/PurchaseWeatherEvent") end
                            for _, name in ipairs(selectedWeathers) do local key = weatherMap[name]; if key and Events.BuyWeather then pcall(function() Events.BuyWeather:InvokeServer(key) end) end; task.wait(0.5) end
                            task.wait(5)
                        end
                    end)
                end
            end
        })
        
        local ShopTab_Sec_BuyFishingRod = ShopTab_Tabbox1:AddTab("Buy Fishing Rod", "lucide:shopping-cart")
        local rods = {["Luck Rod"]=79,["Carbon Rod"]=76,["Grass Rod"]=85,["Demascus Rod"]=77,["Ice Rod"]=78,["Lucky Rod"]=4,["Midnight Rod"]=80,["Steampunk Rod"]=6,["Chrome Rod"]=7,["Astral Rod"]=5,["Ares Rod"]=126,["Angler Rod"]=168,["Bamboo Rod"]=258}
        local rodNames = {"Luck Rod (350 Coins)","Carbon Rod (900 Coins)","Grass Rod (1.5k)","Demascus Rod (3k)","Ice Rod (5k)","Lucky Rod (15k)","Midnight Rod (50k)","Steampunk Rod (215k)","Chrome Rod (437k)","Astral Rod (1M)","Ares Rod (3M)","Angler Rod (8M)","Bamboo Rod (12M)"}
        local rodKeyMap = {["Luck Rod (350 Coins)"]="Luck Rod",["Carbon Rod (900 Coins)"]="Carbon Rod",["Grass Rod (1.5k)"]="Grass Rod",["Demascus Rod (3k)"]="Demascus Rod",["Ice Rod (5k)"]="Ice Rod",["Lucky Rod (15k)"]="Lucky Rod",["Midnight Rod (50k)"]="Midnight Rod",["Steampunk Rod (215k)"]="Steampunk Rod",["Chrome Rod (437k)"]="Chrome Rod",["Astral Rod (1M)"]="Astral Rod",["Ares Rod (3M)"]="Ares Rod",["Angler Rod (8M)"]="Angler Rod",["Bamboo Rod (12M)"]="Bamboo Rod"}
        local selectedRodName = rodNames[1]
        local rodNameValues = {}; for _, name in ipairs(rodNames) do table.insert(rodNameValues, { Title = name, Icon = "anchor" }) end
        ShopTab_Sec_BuyFishingRod:AddDropdown({ Name = "Select Rod", Values = cleanDropdownValues(rodNameValues), Default = cleanDefaultValue(rodNameValues[1]), Multi = false, Callback = wrapDropdownCallback(function(val) selectedRodName = val.Title end, false)})
        ShopTab_Sec_BuyFishingRod:AddButton({ Name = "Buy Selected Rod", Callback = function()
            local key = rodKeyMap[selectedRodName]
            if key and rods[key] then
                local r = GetServerRemote("RF/PurchaseFishingRod")
                if not r then NotifyError("Buy Rod", "Remote tidak ditemukan!"); return end
                pcall(function() r:InvokeServer(rods[key]) end); NotifySuccess("Buy Rod", "Purchased: " .. selectedRodName)
            end
        end })
        
        ShopTab_Tabbox2 = ShopTab:AddTabbox({ Name = "Buy Bait", Position = "center" })
        local ShopTab_Sec_BuyBait = ShopTab_Tabbox2:AddTab("Buy Bait", "lucide:shopping-cart")
        local baits = {["TopWater Bait"]=10,["Lucky Bait"]=2,["Midnight Bait"]=3,["Chroma Bait"]=6,["Dark Matter Bait"]=8,["Corrupt Bait"]=15,["Aether Bait"]=16,["Floral Bait"]=20}
        local baitNames = {"TopWater Bait","Lucky Bait","Midnight Bait","Chroma Bait","Dark Matter Bait","Corrupt Bait","Aether Bait","Floral Bait"}
        local selectedBaitName = baitNames[1]
        local baitNameValues = {}; for _, name in ipairs(baitNames) do table.insert(baitNameValues, { Title = name, Icon = "bug" }) end
        ShopTab_Sec_BuyBait:AddDropdown({ Name = "Select Bait", Values = cleanDropdownValues(baitNameValues), Default = cleanDefaultValue(baitNameValues[1]), Multi = false, Callback = wrapDropdownCallback(function(val) selectedBaitName = val.Title end, false)})
        ShopTab_Sec_BuyBait:AddButton({ Name = "Buy Selected Bait", Callback = function()
            if baits[selectedBaitName] then
                local r = GetServerRemote("RF/PurchaseBait")
                if not r then NotifyError("Buy Bait", "Remote tidak ditemukan!"); return end
                pcall(function() r:InvokeServer(baits[selectedBaitName]) end); NotifySuccess("Buy Bait", "Purchased: " .. selectedBaitName)
            end
        end })
    end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end
end
-- EVENT TAB
if EventTab then
    local ok, err = pcall(function()
EventTab_Tabbox1 = EventTab:AddTabbox({ Name = "Events", Position = "center" })
-- SECTION: EGG SYSTEM
        
        local EventTab_Sec_EggSystem = EventTab_Tabbox1:AddTab("Egg System", "lucide:cpu")

        local eggTypeValues = {
            { Title = "Cat", Icon = "egg" },
            { Title = "Rogue", Icon = "egg" },
            { Title = "Radiant", Icon = "egg" },
            { Title = "Content Creator", Icon = "egg" },
            { Title = "Founder", Icon = "egg" },
        }

        EventTab_Sec_EggSystem:AddDropdown({
            Name = "Tipe Egg",
            Values = cleanDropdownValues(eggTypeValues),
            Default = cleanDefaultValue(eggTypeValues[1]),
            Multi = false,
            Callback = wrapDropdownCallback(function(val)
                PetEggConfig.SelectedEggType = val.Title
                NotifyInfo("Egg", "Tipe egg dipilih: " .. val.Title)
            end, false)})

        EventTab_Sec_EggSystem:AddTextInput({
            Name = "Custom Egg Name (Manual Override)",
            Placeholder = "Ketik nama egg khusus...",
            Default = "",
            Callback = function(text)
                if text and text ~= "" then
                    PetEggConfig.SelectedEggType = text
                    NotifyInfo("Egg", "Tipe custom: " .. text)
                end
            end
        })

        EventTab_Sec_EggSystem:AddTextInput({
            Name = "Jumlah Egg",
            Placeholder = "1",
            Default = "1",
            Callback = function(text)
                local num = tonumber(text)
                if num and num > 0 then
                    PetEggConfig.HatchAmount = math.clamp(num, 1, 100)
                    NotifyInfo("Egg", "Jumlah: " .. PetEggConfig.HatchAmount)
                end
            end
        })

        EventTab_Sec_EggSystem:AddToggle({
            Name = "Enable Instant Hatch",
            Desc = "Purchase Hatch",
            Default = false,
            Callback = function(val)
                PetEggConfig.InstantHatchEnabled = val
                NotifyInfo("Egg", "Instant Hatch: " .. (val and "ON" or "OFF"))
            end
        })

        EventTab_Sec_EggSystem:AddToggle({
            Name = "Auto Hatch Loop",
            Desc = "(loop)",
            Default = false,
            Callback = function(val)
                PetEggConfig.AutoHatch = val
                if val then
                    RunAutoHatch()
                    NotifySuccess("Auto Hatch", "Loop aktif! Egg: " .. PetEggConfig.SelectedEggType)
                else
                    StopAutoHatch()
                end
            end
        })

        EventTab_Sec_EggSystem:AddButton({
            Name = "PurchaseEgg",
            Desc = "Beli egg sekali pakai",
            Callback = function()
                local bought = PurchaseEgg(PetEggConfig.SelectedEggType, PetEggConfig.HatchAmount)
                if bought > 0 then
                    NotifySuccess("Egg", "Berhasil beli " .. bought .. " " .. PetEggConfig.SelectedEggType .. " Egg!")
                else
                    NotifyError("Egg", "Gagal membeli egg!")
                end
            end
        })

        EventTab_Sec_EggSystem:AddButton({
            Name = "OpenEgg",
            Desc = "Trigger OpenEgg",
            Callback = function()
                local ok = OpenEgg(PetEggConfig.SelectedEggType)
                if ok then
                    NotifySuccess("Egg", "OpenEgg berhasil!")
                else
                    NotifyError("Egg", "OpenEgg gagal!")
                end
            end
        })

        EventTab_Sec_EggSystem:AddButton({
            Name = "StartEgg",
            Desc = "Trigger StartEgg",
            Callback = function()
                local ok = StartEgg()
                if ok then
                    NotifySuccess("Egg", "StartEgg berhasil!")
                else
                    NotifyError("Egg", "StartEgg gagal!")
                end
            end
        })

        EventTab_Sec_EggSystem:AddButton({
            Name = "Open ReadyEgg",
            Desc = "Trigger OpenReadyEgg",
            Callback = function()
                local ok = OpenReadyEgg()
                if ok then
                    NotifySuccess("Egg", "OpenReadyEgg berhasil!")
                else
                    NotifyError("Egg", "OpenReadyEgg gagal!")
                end
            end
        })

        EventTab_Sec_EggSystem:AddButton({
            Name = "Instant Hatch",
            Desc = "Trigger InstantHatch",
            Callback = function()
                InstantHatch()
            end
        })
-- SECTION: PET MANAGEMENT
        
        EventTab_Tabbox2 = EventTab:AddTabbox({ Name = "Pet Setting", Position = "center" })
        local EventTab_Sec_PetSetting = EventTab_Tabbox2:AddTab("Pet Setting", "lucide:dog")

        local function GetBestPetUUID()
            local uuidToEquip = nil
            local bestScore = -1
            pcall(function()
                local replion = GetPlayerDataReplion()
                if not replion then return end
                local inv = replion:GetExpect("Inventory")
                if inv and inv.Pets then
                    for _, pet in ipairs(inv.Pets) do
                        local score = 0
                        local data = ItemUtility and ItemUtility:GetItemData(pet.Id)
                        if data and data.Multiplier then score = score + data.Multiplier end
                        if pet.Level then score = score + pet.Level end
                        if score == 0 then score = tonumber(pet.Id) or 1 end
                        if score > bestScore then
                            bestScore = score
                            uuidToEquip = pet.UUID
                        end
                    end
                end
            end)
            return uuidToEquip
        end

        EventTab_Sec_PetSetting:AddButton({
            Name = "Equip Best Pet",
            Desc = "Otomatis memindai dan memakai pet terbaik Anda",
            Callback = function()
                local bestUUID = GetBestPetUUID()
                if bestUUID then
                    local ok = EquipPet(bestUUID)
                    if ok then NotifySuccess("Pet", "Best pet equipped!") else NotifyError("Pet", "Gagal equip best pet!") end
                else
                    NotifyError("Pet", "Tidak ada pet di tas atau inventory belum loading.")
                end
            end
        })

        EventTab_Sec_PetSetting:AddToggle({
            Name = "Auto Equip Best Pet",
            Desc = "Selalu memastikan pet terbaik terpakai (berguna saat Auto Hatch)",
            Default = false,
            Callback = function(val)
                _G.AutoEquipBestPet = val
                if val then
                    task.spawn(function()
                        while _G.AutoEquipBestPet do
                            local bestUUID = GetBestPetUUID()
                            if bestUUID then pcall(function() EquipPet(bestUUID) end) end
                            task.wait(5)
                        end
                    end)
                end
            end
        })


    end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end
end

-- MISC TAB
if MiscTab then
    local ok, err = pcall(function()
        
        MiscTab_Tabbox1 = MiscTab:AddTabbox({ Name = "Visual & Performance", Position = "center" })
        local MiscTab_Sec_VisualPerformance = MiscTab_Tabbox1:AddTab("Visual & Performance", "lucide:user")
        MiscTab_Sec_VisualPerformance:AddToggle({
            Name = "No Animation", Default = false,
            Callback = function(val)
                _G.NoAnimationEnabled = val
                if val then
                    local char = LocalPlayer.Character; if char then SetupNoAnimation(char) end
                    pcall(function() noAnimCharConnection = LocalPlayer.CharacterAdded:Connect(function(newChar) task.wait(0.5); SetupNoAnimation(newChar) end) end)
                else
                    if noAnimConnection then pcall(function() noAnimConnection:Disconnect() end); noAnimConnection = nil end
                    if noAnimCharConnection then pcall(function() noAnimCharConnection:Disconnect() end); noAnimCharConnection = nil end
                end
            end
        })
        MiscTab_Sec_VisualPerformance:AddToggle({
            Name = "FPS Booster", Default = false,
            Callback = function(val)
                _G.UltraFPSActive = val
                if val then
                    -- BRUTAL: Remove all textures, decals, meshes (NO UI DESTROY - excludes ScreenGui and descendants)
                    for _, v in pairs(workspace:GetDescendants()) do
                        pcall(function()
                            if v:IsA("BasePart") then
                                v.CastShadow = false
                                v.Material = Enum.Material.SmoothPlastic
                                v.Reflectance = 0
                            elseif v:IsA("Decal") or v:IsA("Texture") then
                                v:Destroy()
                            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                                v.Enabled = false
                            elseif v:IsA("MeshPart") then
                                v.CastShadow = false
                                v.Material = Enum.Material.SmoothPlastic
                                v.TextureID = ""
                            elseif v:IsA("SpecialMesh") then
                                v.TextureId = ""
                            elseif v:IsA("SpotLight") or v:IsA("PointLight") or v:IsA("SurfaceLight") then
                                v.Enabled = false
                            end
                        end)
                    end
                    -- BRUTAL: Lighting annihilation
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 1e10
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 12
                    Lighting.GeographicLatitude = 0
                    Lighting.EnvironmentDiffuseScale = 0
                    Lighting.EnvironmentSpecularScale = 0
                    for _, e in pairs(Lighting:GetChildren()) do
                        pcall(function()
                            if e:IsA("PostEffect") then e.Enabled = false
                            elseif e:IsA("Atmosphere") then e:Destroy()
                            elseif e:IsA("Sky") then e:Destroy()
                            elseif e:IsA("BloomEffect") then e:Destroy()
                            elseif e:IsA("ColorCorrectionEffect") then e:Destroy()
                            elseif e:IsA("SunRaysEffect") then e:Destroy()
                            elseif e:IsA("BlurEffect") then e:Destroy()
                            end
                        end)
                    end
                    -- BRUTAL: Terrain simplification
                    pcall(function()
                        workspace.Terrain.WaterWaveSize = 0
                        workspace.Terrain.WaterWaveSpeed = 0
                        workspace.Terrain.WaterReflectance = 0
                        workspace.Terrain.WaterTransparency = 1
                    end)
                    -- BRUTAL: Reduce render distance
                    pcall(function() settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04 end)
                    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
                    -- BRUTAL: Lower graphics settings
                    pcall(function()
                        local success, settings = pcall(function() return settings() end)
                        if success and settings.Rendering then
                            settings.Rendering.QualityLevel = Enum.QualityLevel.Level01
                        end
                    end)
                    NotifySuccess("Ultra FPS", "BRUTAL MODE AKTIF! FPS maksimal!")
                else
                    NotifyInfo("Ultra FPS", "Dimatikan. Restart game untuk restore visual.")
                end
            end
        })
        local _cleanScreenBackup = {}
        MiscTab_Sec_VisualPerformance:AddToggle({
            Name = "Screen", Default = false,
            Callback = function(val)
                if val then
                    -- Hide all UI without destroying them to prevent script errors
                    for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
                            if not _cleanScreenBackup[gui] then
                                _cleanScreenBackup[gui] = {visible = gui.Enabled}
                            end
                            gui.Enabled = false
                        end
                    end
                    for _, gui in pairs(CoreGui:GetChildren()) do
                        if gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
                            if not _cleanScreenBackup[gui] then
                                _cleanScreenBackup[gui] = {visible = gui.Enabled}
                            end
                            gui.Enabled = false
                        end
                    end
                    NotifySuccess("Clean Screen", "Semua UI disembunyikan! Tekan lagi untuk memulihkan.")
                else
                    -- Restore UI visibility
                    for gui, data in pairs(_cleanScreenBackup) do
                        pcall(function()
                            if gui then
                                gui.Enabled = data.visible
                            end
                        end)
                    end
                    NotifySuccess("Clean Screen", "UI berhasil dipulihkan.")
                    _cleanScreenBackup = {}
                end
            end
        })
        MiscTab_Sec_VisualPerformance:AddToggle({ Name = "Disable Obtained Notif", Default = false, Callback = function(val) SetDisableObtained(val) end })
        local _backup = setmetatable({}, {__mode = "k"})
        local function DisableController(ctrl)
            if _backup[ctrl] then return end
            local data = {functions = {}}
            for k, v in pairs(ctrl) do if type(v) == "function" then data.functions[k] = v; ctrl[k] = function() end end end
            _backup[ctrl] = data
        end
        local function EnableController(ctrl)
            local data = _backup[ctrl]; if not data then return end
            for k, v in pairs(data.functions) do ctrl[k] = v end
            _backup[ctrl] = nil
        end
        MiscTab_Sec_VisualPerformance:AddToggle({ Name = "Disable VFX", Default = false, Callback = function(val) if Controllers.VFX then if val then DisableController(Controllers.VFX) else EnableController(Controllers.VFX) end end end })
        MiscTab_Sec_VisualPerformance:AddToggle({ Name = "Disable Cutscene", Default = false, Callback = function(val) if Controllers.Cutscene then if val then DisableController(Controllers.Cutscene) else EnableController(Controllers.Cutscene) end end end })
        
        -- Fullbright Feature
        local _fullbrightBackup = {}
        MiscTab_Sec_VisualPerformance:AddToggle({
            Name = "Full bright", Default = false,
            Callback = function(val)
                pcall(function()
                    if val then
                        -- Store original lighting values
                        _fullbrightBackup.Brightness = Lighting.Brightness
                        _fullbrightBackup.ClockTime = Lighting.ClockTime
                        _fullbrightBackup.FogEnd = Lighting.FogEnd
                        _fullbrightBackup.GlobalShadows = Lighting.GlobalShadows
                        _fullbrightBackup.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
                        _fullbrightBackup.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
                        
                        -- Apply fullbright settings
                        Lighting.Brightness = 3
                        Lighting.ClockTime = 12
                        Lighting.FogEnd = 1e10
                        Lighting.GlobalShadows = false
                        Lighting.EnvironmentDiffuseScale = 1
                        Lighting.EnvironmentSpecularScale = 1
                        
                        NotifySuccess("Fullbright", "Aktif!")
                    else
                        -- Restore original lighting values with proper nil checks
                        if _fullbrightBackup.Brightness ~= nil then Lighting.Brightness = _fullbrightBackup.Brightness end
                        if _fullbrightBackup.ClockTime ~= nil then Lighting.ClockTime = _fullbrightBackup.ClockTime end
                        if _fullbrightBackup.FogEnd ~= nil then Lighting.FogEnd = _fullbrightBackup.FogEnd end
                        if _fullbrightBackup.GlobalShadows ~= nil then Lighting.GlobalShadows = _fullbrightBackup.GlobalShadows end
                        if _fullbrightBackup.EnvironmentDiffuseScale ~= nil then Lighting.EnvironmentDiffuseScale = _fullbrightBackup.EnvironmentDiffuseScale end
                        if _fullbrightBackup.EnvironmentSpecularScale ~= nil then Lighting.EnvironmentSpecularScale = _fullbrightBackup.EnvironmentSpecularScale end
                        
                        NotifySuccess("Fullbright", "Dimatikan!")
                    end
                end)
            end
        })
        MiscTab_Sec_VisualPerformance:AddButton({ Name = "Server Hop/AntStaff", Callback = function()
            if not Events.ServerHop then Events.ServerHop = GetServerRemote("RE/ServerHop") end
            if Events.ServerHop then pcall(function() Events.ServerHop:FireServer() end)
            else pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end
            NotifySuccess("ServerHop", "Pindah server!")
        end })
        MiscTab_Sec_VisualPerformance:AddButton({ Name = "Rejoin Server", Callback = function()
            NotifySuccess("Rejoin", "Rejoining..."); task.wait(1)
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end })
        MiscTab_Sec_VisualPerformance:AddButton({ 
            Name = "Rejoin Trade Plaza", 
            Desc = "Rejoin ke server Trade Plaza",
            Callback = function()
                NotifySuccess("Trade Plaza", "Menuju Trade Plaza...")
                task.wait(1)
                pcall(function() 
                    -- Place ID Trade Plaza Fish It
                    TeleportService:Teleport(15532962648, LocalPlayer) 
                end)
                -- Fallback pakai remote
                if Events.TradePlazaTeleport then
                    pcall(function() Events.TradePlazaTeleport:FireServer() end)
                end
            end 
        })
        MiscTab_Sec_VisualPerformance:AddToggle({ Name = "Teleport New Server (Beta)", Default = false, Callback = function(val)
            _G.AutoNewServer = val
            if val then
                task.spawn(function()
                    while _G.AutoNewServer do
                        task.wait(math.random(180, 300))
                        if _G.AutoNewServer then pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end
                    end
                end)
            end
        end })

        
        local MiscTab_Sec_AntiAFK = MiscTab_Tabbox1:AddTab("Anti-AFK", "lucide:shield")
        MiscTab_Sec_AntiAFK:AddToggle({
            Name = "Anti-AFK", Default = false,
            Callback = function(val)
                _G.AntiAFKEnabled = val
                if val then
                    pcall(function()
                        for _, v in pairs(getconnections(LocalPlayer.Idled)) do
                            if v.Disable then v:Disable() elseif v.Disconnect then v:Disconnect() end
                        end
                    end)
                    _G.AntiAFKThread = task.spawn(function()
                        while _G.AntiAFKEnabled do
                            task.wait(60 * 18)
                        end
                    end)
                    NotifySuccess("Anti-AFK", "Aktif!")
                else
                    if _G.AntiAFKThread then pcall(function() task.cancel(_G.AntiAFKThread) end) end
                end
            end
        })

        
        MiscTab_Tabbox2 = MiscTab:AddTabbox({ Name = "Luck System (BARU)", Position = "center" })
        local MiscTab_Sec_LuckSystemBARU = MiscTab_Tabbox2:AddTab("Luck System (BARU)", "lucide:clover")

        MiscTab_Sec_LuckSystemBARU:AddButton({
            Name = "Activate Existing Luck",
            Desc = "Aktifkan luck yang sudah ada",
            Callback = function()
                if not Events.ActivateExistingLuck then
                    Events.ActivateExistingLuck = GetServerRemote("RE/ActivateExistingLuck")
                end
                if Events.ActivateExistingLuck then
                    pcall(function() Events.ActivateExistingLuck:FireServer() end)
                    NotifySuccess("Luck", "Activate Existing Luck dikirim!")
                else
                    NotifyError("Luck", "Remote tidak ditemukan!")
                end
            end
        })

        

    end)
    if not ok then warn('[KysHub] Tab load error: ' .. tostring(err)) end
end

-- INTRO NOTIFICATION
pcall(function()
    if WindUI and WindUI.Notify then
        WindUI:Notify({
            Title = "Kys Hub V1.2",
            Content = "Loaded! Remotes: " .. loadedCount .. " | Failed: " .. failedCount .. " | Map: " .. (isSupported and supportedMaps["121864768012064"] or mapName),
            Duration = 5,
            Icon = "rbxassetid://80891639562743"
        })
    end
end)
end)
end)
-- =============================================
-- ПАТЧ ДЛЯ FISH IT (УБИРАЕТ PREMIUM ПРОВЕРКУ)
-- =============================================
local function patchFishItPremium()
    -- Перехватываем NotifyWarning, чтобы блокировать сообщения о Premium
    local oldNotify = NotifyWarning
    NotifyWarning = function(title, content, duration)
        if content and tostring(content):find("Premium") then return end
        return oldNotify and oldNotify(title, content, duration)
    end

    -- Удаляем параметры Locked/TextLocked у всех UI-элементов (если они есть)
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            local oldIndex = mt.__index
            local oldNewIndex = mt.__newindex
            local blocked = { Locked = true, TextLocked = true }

            setreadonly(mt, false)
            mt.__index = function(t, k)
                if blocked[k] then return nil end
                return oldIndex(t, k)
            end

            mt.__newindex = function(t, k, v)
                if blocked[k] then return end
                return oldNewIndex(t, k, v)
            end
            setreadonly(mt, true)
        end
    end)

    print("[KysHub] Premium-ограничения в Fish It отключены.")
end

task.spawn(patchFishItPremium)
