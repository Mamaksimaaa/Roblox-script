--[[
    IRY HUB - Dead Rails
    Адаптировано под MinecraftLib
    Создатель: @hodbush
    Discord: https://discord.gg/YvZaukBdu
]]

-- Загрузка библиотеки
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mamaksimaaa/Roblox-script/refs/heads/main/Lib/load.lua"))()

-- Создание окна
local Window = Library:CreateWindow("IRY HUB", {
    Theme = "Overworld" -- Overworld / Nether / End
})

-- ==================== ВКЛАДКИ ====================
local MainTab = Window:AddTab("Main")
local PlayerTab = Window:AddTab("Player")
local FarmTab = Window:AddTab("Auto Farm")
local AimbotTab = Window:AddTab("Aimbot")
local VisualTab = Window:AddTab("Visual")
local TeleportTab = Window:AddTab("Teleport")

-- ==================== MAIN ====================
MainTab:AddLabel("IRY HUB - Dead Rails")
MainTab:AddSeparator("Information")
MainTab:AddLabel("Создатель: @hodbush")
MainTab:AddLabel("Discord: IRY HUB (discord.gg/YvZaukBdu)")

MainTab:AddSeparator("Discord")
MainTab:AddButton("Копировать Discord ссылку", function()
    local link = "https://discord.gg/YvZaukBdu"
    pcall(function() setclipboard(link) end)
    Window:Notify("Discord", "Ссылка скопирована: " .. link, 3)
end)

-- ==================== PLAYER ====================
PlayerTab:AddLabel("Player Functions")
PlayerTab:AddSeparator("Movement")

PlayerTab:AddSlider("Walk Speed", 0, 400, 16, function(val)
    pcall(function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end)
end)

PlayerTab:AddSlider("Jump Power", 0, 400, 50, function(val)
    pcall(function()
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = val
    end)
end)

PlayerTab:AddButton("Infinite Jump", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/hG4nGivq"))()
    Window:Notify("Player", "Infinite Jump загружен", 2)
end)

PlayerTab:AddButton("Noclip", function()
    local Noclip = nil
    local Clip = false
    function noclip()
        Clip = false
        local function Nocl()
            if Clip == false and game.Players.LocalPlayer.Character ~= nil then
                for _,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if v:IsA('BasePart') and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
            wait(0.21)
        end
        Noclip = game:GetService('RunService').Stepped:Connect(Nocl)
    end
    function clip()
        if Noclip then Noclip:Disconnect() end
        Clip = true
    end
    noclip()
    Window:Notify("Player", "Noclip включен", 2)
end)

PlayerTab:AddButton("Fly V3", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    Window:Notify("Player", "Fly V3 загружен", 2)
end)

PlayerTab:AddButton("Removing delay", function()
    while true do
        wait(0.3)
        for i,v in ipairs(game:GetService("Workspace"):GetDescendants()) do
            if v.ClassName == "ProximityPrompt" then
                v.HoldDuration = 0
            end
        end
    end
    Window:Notify("Player", "Задержка убрана", 2)
end)

PlayerTab:AddButton("FullBright", function()
    pcall(function()
        local lighting = game:GetService("Lighting")
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.Brightness = 1
        lighting.FogEnd = 1e10
        for i, v in pairs(lighting:GetDescendants()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
            end
        end
        lighting.Changed:Connect(function()
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            lighting.Brightness = 1
            lighting.FogEnd = 1e10
        end)
        spawn(function()
            local character = game:GetService("Players").LocalPlayer.Character
            while wait() do
                repeat wait() until character ~= nil
                if not character.HumanoidRootPart:FindFirstChildWhichIsA("PointLight") then
                    local headlight = Instance.new("PointLight", character.HumanoidRootPart)
                    headlight.Brightness = 1
                    headlight.Range = 60
                end
            end
        end)
    end)
    Window:Notify("Player", "FullBright включен", 2)
end)

PlayerTab:AddSeparator("Spectate")
PlayerTab:AddButton("Spectate Player V1", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/7EAbhifj"))()
    Window:Notify("Spectate", "V1 загружен", 2)
end)
PlayerTab:AddButton("Spectate Player V2", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SpiderScriptRB/Spectate-Player-/refs/heads/main/p1V28yP1.txt"))()
    Window:Notify("Spectate", "V2 загружен", 2)
end)

-- ==================== AUTO FARM ====================
FarmTab:AddLabel("Auto Farm & Bring Items")
FarmTab:AddSeparator("Items")

FarmTab:AddButton("Bring All Items", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/thiennrb7/Script/refs/heads/main/obf_3wug09A9VhQw08S7vh9514KYabKIH8h1V3ec3g5nqoa2k8S0v3Gtzz4Ua8YUBoXi.lua.txt"))()
    Window:Notify("Farm", "Bring All Items запущен", 2)
end)

FarmTab:AddButton("Bring All Items (GUI)", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/1k2vu96h"))()
    Window:Notify("Farm", "Bring All Items (GUI) загружен", 2)
end)

FarmTab:AddButton("Auto Collect Bonds", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Emplic/deathrails/refs/heads/main/bond"))()
    Window:Notify("Farm", "Auto Collect Bonds запущен", 2)
end)

FarmTab:AddButton("Auto Collect Bonds (GUI)", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/cowka/c0wkaHub/refs/heads/main/DeadRails'))()
    Window:Notify("Farm", "Auto Collect Bonds (GUI) загружен", 2)
end)

-- ==================== AIMBOT / KILL AURA ====================
AimbotTab:AddLabel("Aimbot & Kill Aura")
AimbotTab:AddSeparator("Combat")

AimbotTab:AddButton("Aimbot", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/ptjAHccP"))()
    Window:Notify("Aimbot", "Aimbot загружен", 2)
end)

AimbotTab:AddButton("FE Kill-Player (GUI)", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/Fe_Kill_Player_DeadRails"))()
    Window:Notify("Kill", "FE Kill-Player GUI загружен", 2)
end)

AimbotTab:AddButton("Kill Aura V1", function()
    local Players, Workspace = game:GetService("Players"), game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

    local function getTool()
        for _, tool in ipairs(Character:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("MeleeSwing") and tool.Parent == Character then
                return tool
            end
        end
        return nil
    end

    local function checkNPCs()
        local tool = getTool()
        if Humanoid.Health <= 0 or not tool then return end
        local RemoteEvent = tool:FindFirstChild("SwingEvent")
        if not RemoteEvent or tool.Parent ~= Character then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local humanoid, rootPart = obj:FindFirstChild("Humanoid"), obj:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                local targetPos = rootPart and rootPart.Position or humanoid.Position
                if (HumanoidRootPart.Position - targetPos).Magnitude <= 18 then
                    RemoteEvent:FireServer(targetPos)
                end
            end
        end
    end

    task.spawn(function()
        while task.wait(0.3) do checkNPCs() end
    end)
    Window:Notify("Kill Aura", "V1 запущен", 2)
end)

AimbotTab:AddButton("Kill Aura V2", function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)

    local utility = {}
    function utility.getEquippedTool()
        for _, tool in ipairs(Character:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("ClientWeaponState") then
                return tool
            end
        end
        return nil
    end

    function utility.getClosestNPC(maxDistance)
        local closestNPC, minDist = nil, maxDistance or 30
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local root = obj:FindFirstChild("HumanoidRootPart")
            local humanoid = obj:FindFirstChild("Humanoid")
            if root and humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                local distance = (HumanoidRootPart.Position - root.Position).Magnitude
                if distance < minDist then
                    closestNPC, minDist = humanoid, distance
                end
            end
        end
        return closestNPC
    end

    function utility.reloadWeapon(weapon, state)
        local ammo = state:FindFirstChild("CurrentAmmo")
        if ammo and ammo.Value == 0 and not state.IsReloading.Value then
            ReplicatedStorage.Remotes.Weapon.Reload:FireServer(Workspace:GetServerTimeNow(), weapon)
            repeat task.wait() until ammo.Value > 0
        end
    end

    function utility.fireAtNPC(npc, weapon, state)
        if npc and weapon and state then
            local ammo = state:FindFirstChild("CurrentAmmo")
            if ammo and ammo.Value > 0 then
                ReplicatedStorage.Remotes.Weapon.Shoot:FireServer(Workspace:GetServerTimeNow(), weapon, HumanoidRootPart.CFrame, { ["1"] = npc })
            end
        end
    end

    while task.wait(0.2) do
        local npc = utility.getClosestNPC(30)
        local weapon = utility.getEquippedTool()
        if weapon then
            local state = weapon:FindFirstChild("ClientWeaponState")
            if state then
                utility.reloadWeapon(weapon, state)
                utility.fireAtNPC(npc, weapon, state)
            end
        end
    end
    Window:Notify("Kill Aura", "V2 запущен", 2)
end)

AimbotTab:AddLabel("Это лучшие боевые функции 🔥")

-- ==================== VISUAL ====================
VisualTab:AddLabel("ESP Settings")
VisualTab:AddSeparator("ESP")

VisualTab:AddButton("[ESP] Player", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
    Window:Notify("ESP", "Player ESP загружен", 2)
end)

VisualTab:AddButton("[ESP] Mods", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/E4K3k3JA"))()
    Window:Notify("ESP", "Mods ESP загружен", 2)
end)

VisualTab:AddButton("[ESP] Train", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/8mmh00zh"))()
    Window:Notify("ESP", "Train ESP загружен", 2)
end)

VisualTab:AddButton("[ESP] Item", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/n4Gi11s3"))()
    Window:Notify("ESP", "Item ESP загружен", 2)
end)

VisualTab:AddButton("[ESP] Item V2", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/nygwz18h"))()
    Window:Notify("ESP", "Item V2 ESP загружен", 2)
end)

VisualTab:AddLabel("С ESP вы видите объекты сквозь стены 👀")

-- ==================== TELEPORT ====================
TeleportTab:AddLabel("Teleport Locations")
TeleportTab:AddSeparator("TP")

TeleportTab:AddButton("Teleport to Finish", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/ktH3TwME"))()
    Window:Notify("Teleport", "Телепорт к финишу", 2)
end)

TeleportTab:AddButton("Teleport to Start", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(123.53105926513672, 3.050037384033203, 29925.89453125)
    Window:Notify("Teleport", "Телепорт на старт", 2)
end)

TeleportTab:AddButton("Teleport to Player", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/q3NvV48e"))()
    Window:Notify("Teleport", "Телепорт к игроку (GUI)", 2)
end)

-- ==================== СТАРТОВОЕ УВЕДОМЛЕНИЕ ====================
Window:Notify("IRY HUB", "Добро пожаловать! Скрипт загружен.", 5)
print("[IRY HUB] Скрипт загружен успешно!")
