if not game:IsLoaded() then game.Loaded:Wait() end

loadstring(game:HttpGet("https://raw.githubusercontent.com/Mamaksimaaa/Roblox-script/refs/heads/main/Evade/Round%20timer.lua"))()

local MinecraftLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mamaksimaaa/Roblox-script/refs/heads/main/Lib/load.lua"))()

local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local Lighting            = game:GetService("Lighting")
local VirtualUser         = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UIS                 = game:GetService("UserInputService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local Workspace           = game:GetService("Workspace")
local TweenService        = game:GetService("TweenService")
local Camera              = Workspace.CurrentCamera
local lp                  = Players.LocalPlayer

local NextbotFolders = {"Players"}

local function IsInsideNextbotFolder(instance)
    for _, folderName in ipairs(NextbotFolders) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder and instance:IsDescendantOf(folder) then
            return true
        end
    end
    return false
end

local function IsNextbot(model)
    return model
        and model:IsA("Model")
        and model ~= lp.Character
        and IsInsideNextbotFolder(model)
        and model:GetAttribute("Team") == "Nextbot"
        and (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Root") or model.PrimaryPart) ~= nil
end

local function GetNextbots()
    local nextbots = {}
    for _, folderName in ipairs(NextbotFolders) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, instance in ipairs(folder:GetDescendants()) do
                if IsNextbot(instance) then
                    nextbots[instance] = true
                end
            end
        end
    end
    return nextbots
end

local function GetNextbotInfo(model)
    local botType = model:GetAttribute("Type")
        or model:GetAttribute("BotType")
        or model:GetAttribute("NextbotType")
    local botName = model:GetAttribute("DisplayName")
        or model:GetAttribute("Name")

    for _, child in ipairs(model:GetChildren()) do
        if not botType and (child.Name == "Type" or child.Name == "BotType" or child.Name == "NextbotType")
            and child:IsA("StringValue") then
            botType = child.Value
        end
        if not botName and (child.Name == "DisplayName" or child.Name == "Name")
            and child:IsA("StringValue") then
            botName = child.Value
        end
    end

    return tostring(botType or "Nextbot"), tostring(botName or model.Name)
end

local vu = game:GetService("VirtualUser")
lp.Idled:Connect(function()
    pcall(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

-- ============================================================
-- СОСТОЯНИЕ
-- ============================================================

local Speeds            = false
local Power             = 48
local JumpEnabled       = false
local JumpPower         = 50
local OriginalJumpPower = 50
local ESP               = false
local DownedESP         = false
local NextbotESP        = false
local Safe              = false
local AutoRevive        = false
local AutoFollow        = true
local LastPos           = nil
local Plate             = nil

-- ESP цвета
local ESPColor          = Color3.fromRGB(0, 200, 255)
local DownedESPColor    = Color3.fromRGB(255, 50, 50)
local NextbotESPColor   = Color3.fromRGB(255, 0, 0)

-- Ссылки на элементы UI
local safeZoneToggle      = nil
local flyToggle           = nil
local autoReviveToggle    = nil
local autoFollowToggle    = nil
local speedToggle         = nil
local jumpToggle          = nil
local avoidToggle         = nil
local playerESPToggle     = nil
local downedESPToggle     = nil
local nextbotESPToggle    = nil
local fpsToggle           = nil
local fogToggle           = nil
local skyToggle           = nil
local speedSlider         = nil
local jumpSlider          = nil
local flySpeedSlider      = nil
local avoidDistanceSlider = nil
local avoidSpeedSlider    = nil

local AutoFarm         = false
local autoFarmToggle   = nil
local farmDelay        = 0.1
local FarmMode         = 1
local RemoteHitbox     = nil
local farmModeDropdown = nil
local ignoreTeleport   = false
local ignoreTeleportTimer = nil
local IsRevivingNow    = false
local IsFollowing      = false
local followBodyPos    = nil
local followBodyGyro   = nil
local followConnection = nil
local followNoclipConn = nil
local SkyEnabled       = false
local FPSBoosted       = false
local FogDisabled      = false
local REVIVE_HEIGHT    = -4.2
local HOLD_DURATION    = 3.35
local REVIVE_INTERVAL  = 0.05
local RAGDOLL_DELAY    = 1.0

local AvoidNextbots = false
local AvoidDistance = 25
local AvoidSpeed    = 60

local ReviveBlacklist     = {}
local ReviveBlacklistTime = {}
local speedometerLabel    = nil
local originalSpeedText   = nil
local lastSpeedPosition   = nil

-- ============================================================
-- HELPERS
-- ============================================================

local function GetSpeedometerLabel()
    if speedometerLabel and speedometerLabel.Parent then
        return speedometerLabel
    end
    local playerGui  = lp:FindFirstChildOfClass("PlayerGui")
    local gameGui    = playerGui and playerGui:FindFirstChild("Game")
    local hud        = gameGui and gameGui:FindFirstChild("HUD")
    local overlay    = hud and hud:FindFirstChild("Overlay")
    local status     = overlay and overlay:FindFirstChild("CharacterStatus")
    local bottomLeft = status and status:FindFirstChild("BottomLeft")
    local speedometer = bottomLeft and bottomLeft:FindFirstChild("Speedometer")
    local label      = speedometer and speedometer:FindFirstChild("Speed")
    if label and label:IsA("TextLabel") then
        speedometerLabel    = label
        originalSpeedText   = label.Text
        return label
    end
    return nil
end

local function RestoreSpeedometer()
    local label = GetSpeedometerLabel()
    if label and originalSpeedText then
        label.Text = originalSpeedText
    end
    lastSpeedPosition = nil
end

local Original = {
    Brightness    = Lighting.Brightness,
    FogStart      = Lighting.FogStart,
    FogEnd        = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Quality       = settings().Rendering.QualityLevel,
}
local EffectsBackup = {}

local function SaveGraphics()
    Original.Brightness    = Lighting.Brightness
    Original.FogStart      = Lighting.FogStart
    Original.FogEnd        = Lighting.FogEnd
    Original.GlobalShadows = Lighting.GlobalShadows
    Original.Quality       = settings().Rendering.QualityLevel
    table.clear(EffectsBackup)
    for _, v in ipairs(Lighting:GetDescendants()) do
        if v:IsA("PostEffect") then EffectsBackup[v] = v.Enabled end
    end
end

local function FPSBooster(state)
    if state then
        SaveGraphics()
        Lighting.GlobalShadows = false
        Lighting.FogEnd        = 999999
        Lighting.Brightness    = 2
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        for effect in pairs(EffectsBackup) do
            if effect and effect.Parent then effect.Enabled = false end
        end
    else
        Lighting.GlobalShadows = Original.GlobalShadows
        Lighting.FogEnd        = Original.FogEnd
        Lighting.Brightness    = Original.Brightness
        pcall(function() settings().Rendering.QualityLevel = Original.Quality end)
        for effect, val in pairs(EffectsBackup) do
            if effect and effect.Parent then effect.Enabled = val end
        end
    end
end

local function DisableFog(state)
    if state then
        Lighting.FogStart = 999999
        Lighting.FogEnd   = 999999
    else
        Lighting.FogStart = Original.FogStart
        Lighting.FogEnd   = Original.FogEnd
    end
end

lp.CharacterAdded:Connect(function(character)
    task.wait(0.2)
    local hum = character:WaitForChild("Humanoid", 5)
    if hum then
        Camera.CameraType    = Enum.CameraType.Custom
        Camera.CameraSubject = hum
        if JumpEnabled then
            hum.UseJumpPower  = true
            OriginalJumpPower = hum.JumpPower
            hum.JumpPower     = JumpPower
        end
    end
    IsRevivingNow = false
    IsFollowing   = false
    table.clear(ReviveBlacklist)
    table.clear(ReviveBlacklistTime)
end)

-- ============================================================
-- FLY
-- ============================================================

local flying          = false
local flySpeed        = 150
local flyMaxSpeed     = 150
local flyCurrentSpeed = 0
local flyAcceleration = 7
local flyBrakeForce   = 8
local bodyVelocity, bodyGyro
local flyConnection, noclipConnection
local moveVector = Vector3.zero
local W, A, S, D = false, false, false, false
local UP, DOWN, LEFT, RIGHT = false, false, false, false
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local joystickFrame, thumb
local dragging, dragInput = false, nil

local flyGui = Instance.new("ScreenGui")
flyGui.Name         = "inlawry_FLY"
flyGui.ResetOnSpawn = false
flyGui.Parent       = lp:WaitForChild("PlayerGui")

joystickFrame = Instance.new("Frame")
joystickFrame.Size                   = UDim2.new(0, 170, 0, 170)
joystickFrame.Position               = UDim2.new(0.08, 0, 0.42, 0)
joystickFrame.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
joystickFrame.BackgroundTransparency = 0.90
joystickFrame.Visible                = false
joystickFrame.Parent                 = flyGui
Instance.new("UICorner", joystickFrame).CornerRadius = UDim.new(1, 0)

thumb = Instance.new("Frame")
thumb.Size                   = UDim2.new(0, 55, 0, 55)
thumb.Position               = UDim2.new(0.5, -27, 0.5, -27)
thumb.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
thumb.BackgroundTransparency = 0.60
thumb.Parent                 = joystickFrame
Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W or key == Enum.KeyCode.Z then W = true
    elseif key == Enum.KeyCode.S     then S     = true
    elseif key == Enum.KeyCode.A or key == Enum.KeyCode.Q then A = true
    elseif key == Enum.KeyCode.D     then D     = true
    elseif key == Enum.KeyCode.Up    then UP    = true
    elseif key == Enum.KeyCode.Down  then DOWN  = true
    elseif key == Enum.KeyCode.Left  then LEFT  = true
    elseif key == Enum.KeyCode.Right then RIGHT = true
    end
end)

UIS.InputEnded:Connect(function(input)
    local key = input.KeyCode
    if key == Enum.KeyCode.W or key == Enum.KeyCode.Z then W = false
    elseif key == Enum.KeyCode.S     then S     = false
    elseif key == Enum.KeyCode.A or key == Enum.KeyCode.Q then A = false
    elseif key == Enum.KeyCode.D     then D     = false
    elseif key == Enum.KeyCode.Up    then UP    = false
    elseif key == Enum.KeyCode.Down  then DOWN  = false
    elseif key == Enum.KeyCode.Left  then LEFT  = false
    elseif key == Enum.KeyCode.Right then RIGHT = false
    end
end)

joystickFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local center    = joystickFrame.AbsolutePosition + joystickFrame.AbsoluteSize / 2
        local delta     = Vector2.new(input.Position.X - center.X, input.Position.Y - center.Y)
        local radius    = joystickFrame.AbsoluteSize.X / 2
        local distance  = math.min(delta.Magnitude, radius)
        local direction = delta.Magnitude > 0 and delta.Unit or Vector2.zero
        thumb.Position  = UDim2.new(0.5, direction.X * distance - 27, 0.5, direction.Y * distance - 27)
        moveVector      = Vector3.new(direction.X, 0, -direction.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input == dragInput then
        dragging   = false
        dragInput  = nil
        thumb.Position = UDim2.new(0.5, -27, 0.5, -27)
        moveVector = Vector3.zero
    end
end)

local function startFly()
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if isMobile then joystickFrame.Visible = true end

    bodyVelocity           = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce  = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.P         = 50000
    bodyVelocity.Velocity  = Vector3.zero
    bodyVelocity.Parent    = root

    bodyGyro               = Instance.new("BodyGyro")
    bodyGyro.MaxTorque     = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P             = 50000
    bodyGyro.D             = 1000
    bodyGyro.CFrame        = root.CFrame
    bodyGyro.Parent        = root

    hum.PlatformStand = true

    noclipConnection = RunService.Stepped:Connect(function()
        if not flying then return end
        local charNow = lp.Character
        if not charNow then return end
        for _, v in pairs(charNow:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)

    flyCurrentSpeed = 0
    flyMaxSpeed     = flySpeed

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not bodyVelocity then return end
        local camCF     = Camera.CFrame
        local forward   = camCF.LookVector
        local right     = camCF.RightVector
        local finalMove = Vector3.zero

        if isMobile and moveVector.Magnitude > 0 then
            finalMove = (right * moveVector.X) + (forward * moveVector.Z)
        else
            if W or UP    then finalMove = finalMove + forward end
            if S or DOWN  then finalMove = finalMove - forward end
            if A or LEFT  then finalMove = finalMove - right   end
            if D or RIGHT then finalMove = finalMove + right   end
        end

        if finalMove.Magnitude > 0 then
            finalMove       = finalMove.Unit
            flyCurrentSpeed = math.min(flyCurrentSpeed + flyAcceleration, flyMaxSpeed)
            bodyVelocity.Velocity = finalMove * flyCurrentSpeed
            bodyGyro.CFrame       = CFrame.lookAt(bodyVelocity.Parent.Position, bodyVelocity.Parent.Position + finalMove)
        else
            flyCurrentSpeed = math.max(0, flyCurrentSpeed - flyBrakeForce)
            bodyVelocity.Velocity = flyCurrentSpeed > 0
                and bodyGyro.CFrame.LookVector * flyCurrentSpeed
                or Vector3.zero
        end
    end)
end

local function stopFly()
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    if flyConnection    then flyConnection:Disconnect()    flyConnection    = nil end
    if isMobile and joystickFrame then joystickFrame.Visible = false end
    flyCurrentSpeed = 0
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro     then bodyGyro:Destroy()     bodyGyro     = nil end
    local char = lp.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end

-- ============================================================
-- SAFE ZONE
-- ============================================================

local function DisableSafeZone()
    if Plate then Plate:Destroy() Plate = nil end
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if LastPos and root then root.CFrame = LastPos LastPos = nil end
end

local function EnableSafeZone()
    if IsRevivingNow or IsFollowing then return end
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if not LastPos and root.Position.Y > -500 then LastPos = root.CFrame end
    if not Plate or not Plate.Parent then
        Plate              = Instance.new("Part")
        Plate.Name         = "inlawry_PLATE"
        Plate.Size         = Vector3.new(500, 1, 500)
        Plate.Anchored     = true
        Plate.Transparency = 0.3
        Plate.BrickColor   = BrickColor.new("Bright blue")
        Plate.CanCollide   = true
        Plate.Parent       = Workspace
    end
    Plate.Position = Vector3.new(root.Position.X, -800, root.Position.Z)
    root.CFrame    = Plate.CFrame + Vector3.new(0, 3, 0)
end

local function GoToSafeZone()
    if Plate and Plate.Parent then
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = Plate.CFrame + Vector3.new(0, 3, 0) end
    end
end

local function ignoreTeleportFor(ms)
    ignoreTeleport = true
    if ignoreTeleportTimer then task.cancel(ignoreTeleportTimer) end
    ignoreTeleportTimer = task.delay(ms / 1000, function()
        ignoreTeleport      = false
        ignoreTeleportTimer = nil
    end)
end

-- ============================================================
-- NEXTBOT / PLAYER HELPERS
-- ============================================================

local function IsNextbotNear(position, radius)
    radius = radius or 40
    for model in pairs(GetNextbots()) do
        local part = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Root") or model.PrimaryPart
        if part and (part.Position - position).Magnitude <= radius then
            return true
        end
    end
    return false
end

local function IsPlayerBeingCarried(player)
    if not player or not player.Character then return false end
    local char = player.Character
    return char:GetAttribute("Carried") ~= nil or char:FindFirstChild("Carried") ~= nil
end

local function IsPlayerDowned(player)
    if not player or not player.Parent then return false end
    if player == lp then return false end
    local char = player.Character
    if not char or not char.Parent then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or root.Position.Y < -500 then return false end
    if IsPlayerBeingCarried(player) then return false end
    if char:GetAttribute("Downed") or char:FindFirstChild("Downed") then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.MaxHealth > 0 then
        if hum.Health <= 0 or (hum.Health / hum.MaxHealth) <= 0.05 then return true end
    end
    for _, child in ipairs(char:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            local text = child.ActionText:lower()
            if text:find("revive") or text:find("réanimer") or text:find("reanimer") then return true end
        end
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local now = tick()
            for plr, t in pairs(ReviveBlacklistTime) do
                if now - t >= 10 then
                    ReviveBlacklist[plr]     = nil
                    ReviveBlacklistTime[plr] = nil
                end
            end
        end)
    end
end)

local DownedCache     = {}
local DownedCacheTime = {}

task.spawn(function()
    while true do
        task.wait(0.05)
        pcall(function()
            if not AutoRevive then
                table.clear(DownedCache)
                table.clear(DownedCacheTime)
                return
            end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp then
                    if not plr or not plr.Parent or not plr.Character or not plr.Character.Parent then
                        DownedCache[plr]     = nil
                        DownedCacheTime[plr] = nil
                        continue
                    end
                    local downed = IsPlayerDowned(plr)
                    if downed then
                        if not DownedCacheTime[plr] then DownedCacheTime[plr] = tick() end
                        DownedCache[plr] = (tick() - DownedCacheTime[plr]) >= RAGDOLL_DELAY or nil
                    else
                        DownedCache[plr]     = nil
                        DownedCacheTime[plr] = nil
                    end
                end
            end
        end)
    end
end)

local function GetDownedPlayer()
    local best, bestDist = nil, math.huge
    local myChar = lp.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for plr in pairs(DownedCache) do
        if ReviveBlacklist[plr] then continue end
        if not plr or not plr.Parent or not plr.Character or not plr.Character.Parent then
            DownedCache[plr] = nil DownedCacheTime[plr] = nil continue
        end
        if not IsPlayerDowned(plr) then
            DownedCache[plr] = nil DownedCacheTime[plr] = nil continue
        end
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if root and root.Parent and not IsNextbotNear(root.Position, 35) then
            local dist = (root.Position - myRoot.Position).Magnitude
            if dist < bestDist then bestDist = dist best = plr end
        end
    end
    return best
end

local function GetClosestAliveTeammate()
    local myChar = lp.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local closest, closestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Parent then
            local char = plr.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 and not char:GetAttribute("Downed") and root.Parent then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < closestDist then closestDist = dist closest = root end
            end
        end
    end
    return closest
end

local StopFollowing

local function StartFollowing()
    if IsFollowing or flying or IsRevivingNow then return end
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    IsFollowing = true
    DisableSafeZone()

    hum.PlatformStand = true
    hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Running,   false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,   false)
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end

    followBodyPos          = Instance.new("BodyPosition")
    followBodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    followBodyPos.P        = 30000
    followBodyPos.D        = 800
    followBodyPos.Parent   = root

    followBodyGyro           = Instance.new("BodyGyro")
    followBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    followBodyGyro.P         = 30000
    followBodyGyro.Parent    = root

    followNoclipConn = RunService.PreSimulation:Connect(function()
        if not IsFollowing then
            if followNoclipConn then followNoclipConn:Disconnect() followNoclipConn = nil end
            return
        end
        local c = lp.Character
        if c then
            for _, v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

    followConnection = RunService.PreSimulation:Connect(function()
        if not IsFollowing or not AutoFollow then
            StopFollowing()
            return
        end
        local target = GetClosestAliveTeammate()
        if not target or not target.Parent then
            StopFollowing()
            return
        end
        followBodyPos.Position = target.Position + Vector3.new(2, 0, 2)
        followBodyGyro.CFrame  = target.CFrame
        local charNow = lp.Character
        if charNow then
            for _, v in pairs(charNow:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
end

StopFollowing = function()
    IsFollowing = false
    if followConnection  then followConnection:Disconnect()  followConnection  = nil end
    if followNoclipConn  then followNoclipConn:Disconnect()  followNoclipConn  = nil end
    if followBodyPos     then followBodyPos:Destroy()         followBodyPos     = nil end
    if followBodyGyro    then followBodyGyro:Destroy()        followBodyGyro    = nil end
    local char = lp.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Running,   true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,   true)
        end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
    EnableSafeZone()
    GoToSafeZone()
end

-- ============================================================
-- AUTO REVIVE
-- ============================================================

local function PerformRevive(targetPlayer)
    if not targetPlayer or not targetPlayer.Parent or not targetPlayer.Character then return end
    if IsRevivingNow then return end
    IsRevivingNow = true
    DisableSafeZone()

    local myChar = lp.Character
    if not myChar then IsRevivingNow = false return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHum  = myChar:FindFirstChildOfClass("Humanoid")
    local tRoot  = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not myHum or not tRoot then IsRevivingNow = false return end

    pcall(function()
        myHum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        myHum:SetStateEnabled(Enum.HumanoidStateType.Running,   false)
        myHum:SetStateEnabled(Enum.HumanoidStateType.Jumping,   false)
        myHum.PlatformStand = true
    end)
    for _, v in ipairs(myChar:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide               = false
            v.AssemblyLinearVelocity   = Vector3.zero
            v.AssemblyAngularVelocity  = Vector3.zero
        end
    end

    local offsetY = REVIVE_HEIGHT
    myRoot.CFrame                  = tRoot.CFrame * CFrame.new(0, offsetY, 0)
    myRoot.AssemblyLinearVelocity  = Vector3.zero
    myRoot.AssemblyAngularVelocity = Vector3.zero

    local bp         = Instance.new("BodyPosition")
    bp.MaxForce      = Vector3.new(math.huge, math.huge, math.huge)
    bp.P             = 250000
    bp.D             = 5000
    bp.Position      = tRoot.Position + Vector3.new(0, offsetY, 0)
    bp.Parent        = myRoot

    local bg         = Instance.new("BodyGyro")
    bg.MaxTorque     = Vector3.new(math.huge, math.huge, math.huge)
    bg.P             = 250000
    bg.CFrame        = tRoot.CFrame
    bg.Parent        = myRoot

    local lockConn
    lockConn = RunService.PreSimulation:Connect(function()
        if not IsRevivingNow or not targetPlayer.Parent or not targetPlayer.Character or not targetPlayer.Character.Parent then
            if lockConn then lockConn:Disconnect() lockConn = nil end
            return
        end
        local curRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if curRoot and bp and bg then
            bp.Position = curRoot.Position + Vector3.new(0, offsetY, 0)
            bg.CFrame   = curRoot.CFrame
            if (myRoot.Position - bp.Position).Magnitude > 0.2 then
                myRoot.CFrame = curRoot.CFrame * CFrame.new(0, offsetY, 0)
            end
            myRoot.AssemblyLinearVelocity  = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end
        for _, v in ipairs(myChar:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide             = false
                v.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)

    local reviveStart  = tick()
    local stuckCheck   = tick()
    local lastCheckPos = myRoot.Position

    while tick() - reviveStart < HOLD_DURATION and AutoRevive and IsPlayerDowned(targetPlayer) and IsRevivingNow do
        if not targetPlayer.Parent or not targetPlayer.Character or not targetPlayer.Character.Parent then break end
        if not IsPlayerDowned(targetPlayer) then break end
        if tick() - stuckCheck >= 9.5 then
            if (myRoot.Position - lastCheckPos).Magnitude < 2.0 then
                ReviveBlacklist[targetPlayer]     = true
                ReviveBlacklistTime[targetPlayer] = tick()
                break
            else
                stuckCheck   = tick()
                lastCheckPos = myRoot.Position
            end
        end
        for _, obj in ipairs(targetPlayer.Character:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                pcall(function() obj:InputHoldBegin() task.wait(0.04) obj:InputHoldEnd() end)
                pcall(function() fireproximityprompt(obj) end)
            end
        end
        pcall(function()
            VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.E, false, game)
            task.wait(0.04)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
        pcall(function()
            if ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Revive") then
                ReplicatedStorage.Events.Revive:FireServer(targetPlayer.Name)
            end
            if ReplicatedStorage:FindFirstChild("Revive") then
                ReplicatedStorage.Revive:FireServer(targetPlayer)
            end
        end)
        task.wait(REVIVE_INTERVAL)
    end

    if lockConn then lockConn:Disconnect() lockConn = nil end
    if bp then bp:Destroy() bp = nil end
    if bg then bg:Destroy() bg = nil end

    pcall(function()
        myHum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        myHum:SetStateEnabled(Enum.HumanoidStateType.Running,   true)
        myHum:SetStateEnabled(Enum.HumanoidStateType.Jumping,   true)
        myHum.PlatformStand = false
    end)
    IsRevivingNow = false
    EnableSafeZone()
    GoToSafeZone()
end

task.spawn(function()
    while true do
        task.wait(0.05)
        pcall(function()
            local char = lp.Character
            if not char then return end
            local hum  = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not hum or not root then return end

            local isDowned = char:GetAttribute("Downed") == true or hum.Health <= 0

            if AutoFollow and isDowned and not flying and not IsRevivingNow then
                if not IsFollowing then StartFollowing() end
                return
            end

            if IsFollowing and (not AutoFollow or not isDowned or flying or IsRevivingNow) then
                StopFollowing()
            end

            if AutoRevive and not isDowned then
                if IsFollowing then StopFollowing() end
                local target = GetDownedPlayer()
                if target then
                    PerformRevive(target)
                elseif not IsRevivingNow and not IsFollowing and not flying then
                    EnableSafeZone()
                    GoToSafeZone()
                end
            end
        end)
    end
end)

-- ============================================================
-- SKY / ENVIRONMENT
-- ============================================================

local function ApplyWarmSky()
    if not SkyEnabled then return end
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj.Name == "inlawry_WARM_SKY" or obj:IsA("Atmosphere") or obj:IsA("BloomEffect")
        or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") then
            obj:Destroy()
        end
    end
    Lighting.Brightness    = 5
    Lighting.ClockTime     = 14
    Lighting.GlobalShadows = false
    Lighting.FogEnd        = 999999
    local Sky = Instance.new("Sky")
    Sky.Name      = "inlawry_WARM_SKY"
    Sky.SkyboxBk  = "rbxassetid://7018684000"
    Sky.SkyboxDn  = "rbxassetid://7018689553"
    Sky.SkyboxFt  = "rbxassetid://7018684206"
    Sky.SkyboxLf  = "rbxassetid://7018685653"
    Sky.SkyboxRt  = "rbxassetid://7018684934"
    Sky.SkyboxUp  = "rbxassetid://7018686777"
    Sky.Parent    = Lighting
    Instance.new("Atmosphere", Lighting).Color           = Color3.fromRGB(199, 172, 120)
    Instance.new("BloomEffect", Lighting).Intensity      = 0.15
    Instance.new("SunRaysEffect", Lighting).Intensity    = 0.08
    Instance.new("ColorCorrectionEffect", Lighting).TintColor = Color3.fromRGB(255, 220, 180)
    Lighting.ClockTime = 17.8
end

local function ToggleSky(value)
    SkyEnabled = value
    if value then
        task.spawn(ApplyWarmSky)
    else
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj.Name == "inlawry_WARM_SKY" or obj:IsA("Atmosphere") or obj:IsA("BloomEffect")
            or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") then
                obj:Destroy()
            end
        end
        Lighting.ClockTime     = 12
        Lighting.Brightness    = 2
        Lighting.FogEnd        = 100000
        Lighting.GlobalShadows = true
    end
end

task.spawn(function()
    while true do
        task.wait(5)
        if SkyEnabled then
            pcall(function()
                local hasSky, hasAtm = false, false
                for _, obj in pairs(Lighting:GetChildren()) do
                    if obj:IsA("Sky")        and obj.Name == "inlawry_WARM_SKY" then hasSky = true end
                    if obj:IsA("Atmosphere") then hasAtm = true end
                end
                if not hasSky or not hasAtm or Lighting.Brightness ~= 5 then ApplyWarmSky() end
            end)
        end
    end
end)

-- ============================================================
-- MOVEMENT LOOP (ФИЗИЧЕСКАЯ СКОРОСТЬ EVADE)
-- ============================================================

local BACKWARD_MULTIPLIER = 0.5

local function specialAnimationPlaying(character)
    if not character then return false end
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("Animator") then
            for _, track in ipairs(obj:GetPlayingAnimationTracks()) do
                if track.IsPlaying and track.Priority.Value >= Enum.AnimationPriority.Action.Value then
                    return true
                end
            end
        end
    end
    return false
end

RunService.Heartbeat:Connect(function()
    local char = lp.Character
    if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    local moveDir = hum.MoveDirection

    if AvoidNextbots and not flying and not IsFollowing and not IsRevivingNow and not Safe then
        local pos     = root.Position
        local nearest = nil
        local minDist = AvoidDistance
        for model in pairs(GetNextbots()) do
            local part = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Root") or model.PrimaryPart
            if part then
                local d = (part.Position - pos).Magnitude
                if d < minDist then
                    minDist = d
                    nearest = part
                end
            end
        end
        if nearest then
            local dir = (pos - nearest.Position) * Vector3.new(1, 0, 1)
            if dir.Magnitude > 0.1 then
                moveDir = dir.Unit
            end
        end
    end

    if Speeds and not flying and not IsFollowing and not IsRevivingNow and not Safe then
        local isBlocked = hum.Health <= 0 
            or hum.Sit 
            or hum.PlatformStand 
            or specialAnimationPlaying(char)

        if not isBlocked and moveDir.Magnitude > 0.05 then
            local flat = Vector3.new(moveDir.X, 0, moveDir.Z)
            if flat.Magnitude > 0.05 then
                local forward = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
                local backward = forward.Magnitude > 0.05 and flat.Unit:Dot(forward.Unit) < -0.35
                local applied = Power
                if backward then
                    applied = Power * BACKWARD_MULTIPLIER
                end
                local wanted = flat.Unit * applied
                local current = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(wanted.X, current.Y, wanted.Z)
            end
        end
    else
        if AvoidNextbots and not flying and not IsFollowing and not IsRevivingNow and not Safe then
            if moveDir.Magnitude > 0 then
                local mv = moveDir * (AvoidSpeed / 45)
                root.CFrame = root.CFrame + mv
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(deltaTime)
    if not Speeds then
        lastSpeedPosition = nil
        return
    end
    local root  = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local label = GetSpeedometerLabel()
    if not root or not label or deltaTime <= 0 then
        lastSpeedPosition = nil
        return
    end
    if lastSpeedPosition then
        local delta = root.Position - lastSpeedPosition
        local horizontalSpeed = Vector3.new(delta.X, 0, delta.Z).Magnitude / deltaTime
        if horizontalSpeed <= 500 then
            label.Text = string.format("%.1f", horizontalSpeed)
        end
    end
    lastSpeedPosition = root.Position
end)

-- ============================================================
-- INFINITE JUMP
-- ============================================================

local lastInfiniteJump = 0

local function DoInfiniteJump()
    if not JumpEnabled or tick() - lastInfiniteJump < 0.08 then return end
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 or hum.Sit then return end
    lastInfiniteJump = tick()
    hum.UseJumpPower = true
    hum.JumpPower    = JumpPower
    hum.Jump         = true
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end

UIS.JumpRequest:Connect(DoInfiniteJump)

-- ============================================================
-- ESP v2
-- ============================================================

local ESP_REFRESH_RATE = 0.1
local ESP_MAX_DISTANCE = 2000

type ESPStyle = {
	highlight: string,
	tag: string,
	label: string,
}

local AliveStyle: ESPStyle = {
	highlight = "ESP_Highlight",
	tag = "ESP_Name",
	label = "ALIVE",
}

local DownedStyle: ESPStyle = {
	highlight = "DownedESP_Highlight",
	tag = "DownedESP_Name",
	label = "DOWNED",
}

type TagParts = {
	stroke: UIStroke,
	avatarStroke: UIStroke,
	name: TextLabel,
	info: TextLabel,
	percent: TextLabel,
	fill: Frame,
}

local tagParts: { [BillboardGui]: TagParts } = setmetatable({}, { __mode = "k" }) :: any

local function Make(className: string, props: { [string]: any }, parent: Instance?): any
	local instance = Instance.new(className)
	for key, value in props do
		(instance :: any)[key] = value
	end
	instance.Parent = parent
	return instance
end

local function HealthColor(pct: number): Color3
	-- 0 = красный, 1 = зелёный
	return Color3.fromHSV(math.clamp(pct, 0, 1) * 0.33, 0.85, 1)
end

-- ---------- карточка над игроком ----------

local function CreateTag(player: Player, character: Model, root: BasePart, tagName: string, accent: Color3): BillboardGui
	local tag = Make("BillboardGui", {
		Name = tagName,
		Adornee = root,
		AlwaysOnTop = true,
		MaxDistance = ESP_MAX_DISTANCE,
		Size = UDim2.fromOffset(128, 38),
		StudsOffset = Vector3.new(0, 3.6, 0),
	}, character)

	local card = Make("Frame", {
		Name = "Card",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(14, 14, 20),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
	}, tag)
	Make("UICorner", { CornerRadius = UDim.new(0, 9) }, card)
	Make("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(165, 170, 185)),
	}, card)
	local stroke = Make("UIStroke", {
		Color = accent,
		Thickness = 1.5,
		Transparency = 0.15,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, card)

	local avatar = Make("ImageLabel", {
		Name = "Avatar",
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Color3.fromRGB(30, 30, 40),
		BorderSizePixel = 0,
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=60&h=60",
	}, card)
	Make("UICorner", { CornerRadius = UDim.new(1, 0) }, avatar)
	local avatarStroke = Make("UIStroke", {
		Color = accent,
		Thickness = 1.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, avatar)

	local name = Make("TextLabel", {
		Name = "Name",
		Position = UDim2.fromOffset(38, 3),
		Size = UDim2.new(1, -44, 0, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = player.DisplayName,
	}, card)

	local info = Make("TextLabel", {
		Name = "Info",
		Position = UDim2.fromOffset(38, 17),
		Size = UDim2.new(1, -44, 0, 11),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		RichText = true,
		TextColor3 = Color3.fromRGB(170, 176, 190),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, card)

	local percent = Make("TextLabel", {
		Name = "Percent",
		Position = UDim2.new(1, -40, 0, 25),
		Size = UDim2.fromOffset(34, 12),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = accent,
		Text = "",
	}, card)

	local barBack = Make("Frame", {
		Name = "BarBack",
		Position = UDim2.fromOffset(38, 29),
		Size = UDim2.new(1, -80, 0, 4),
		BackgroundColor3 = Color3.fromRGB(40, 40, 52),
		BorderSizePixel = 0,
	}, card)
	Make("UICorner", { CornerRadius = UDim.new(1, 0) }, barBack)

	local fill = Make("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
	}, barBack)
	Make("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)
	Make("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(190, 190, 190)),
	}, fill)

	tagParts[tag] = {
		stroke = stroke,
		avatarStroke = avatarStroke,
		name = name,
		info = info,
		percent = percent,
		fill = fill,
	}

	return tag
end

local function RenderPlayerESP(
	player: Player,
	character: Model,
	humanoid: Humanoid,
	root: BasePart,
	style: ESPStyle,
	accent: Color3,
	colorByHealth: boolean
)
	local pct = if humanoid.MaxHealth > 0 then math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) else 0
	local distance = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
	local barColor = if colorByHealth then HealthColor(pct) else accent

	local highlight = character:FindFirstChild(style.highlight)
	if highlight == nil then
		highlight = Make("Highlight", {
			Name = style.highlight,
			Adornee = character,
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
			FillTransparency = 0.8,
			OutlineTransparency = 0.1,
		}, character)
	end
	(highlight :: Highlight).FillColor = accent;
	(highlight :: Highlight).OutlineColor = accent

	local tag = character:FindFirstChild(style.tag)
	if tag == nil then
		tag = CreateTag(player, character, root, style.tag, accent)
	end

	local parts = tagParts[tag :: BillboardGui]
	if parts == nil then
		return
	end

	parts.stroke.Color = accent
	parts.avatarStroke.Color = accent
	parts.name.Text = player.DisplayName
	parts.percent.Text = string.format("%d%%", math.floor(pct * 100))
	parts.percent.TextColor3 = barColor
	parts.info.Text = string.format(
		'<font color="#%s">●</font> %s  <font color="#8f96a8">%dm</font>',
		accent:ToHex(),
		style.label,
		distance
	)

	TweenService:Create(parts.fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Size = UDim2.fromScale(pct, 1),
		BackgroundColor3 = barColor,
	}):Play()
end

local function ClearESPByStyle(character: Model?, style: ESPStyle)
	if character == nil then
		return
	end

	local highlight = character:FindFirstChild(style.highlight)
	if highlight ~= nil then
		highlight:Destroy()
	end

	local tag = character:FindFirstChild(style.tag)
	if tag ~= nil then
		tag:Destroy()
	end
end

local function ClearPlayerESP(character: Model?)
	ClearESPByStyle(character, AliveStyle)
end

local function ClearDownedESP(character: Model?)
	ClearESPByStyle(character, DownedStyle)
end

task.spawn(function()
	while true do
		task.wait(ESP_REFRESH_RATE)

		for _, player in Players:GetPlayers() do
			if player == lp then
				continue
			end

			local character = player.Character
			if character == nil then
				continue
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local root = character:FindFirstChild("HumanoidRootPart")
			if humanoid == nil or root == nil then
				ClearPlayerESP(character)
				ClearDownedESP(character)
				continue
			end

			local downed = (ESP or DownedESP) and IsPlayerDowned(player)
			local alive = humanoid.Health > 0 and not downed

			if ESP and alive then
				RenderPlayerESP(player, character, humanoid, root, AliveStyle, ESPColor, true)
			else
				ClearPlayerESP(character)
			end

			if DownedESP and downed then
				RenderPlayerESP(player, character, humanoid, root, DownedStyle, DownedESPColor, false)
			else
				ClearDownedESP(character)
			end
		end
	end
end)

-- ============================================================
-- NEXTBOT ESP (Drawing): угловые рамки + tracer + подпись
-- ============================================================

local nextbotDrawings = {}
local nextbotCache = {}
local nextbotCacheTime = 0

-- GetNextbots обходит все Players-descendants, поэтому не дёргаем его каждый кадр.
local function GetNextbotsCached()
	local now = os.clock()
	if now - nextbotCacheTime >= 0.5 then
		nextbotCache = GetNextbots()
		nextbotCacheTime = now
	end
	return nextbotCache
end

local function SetDataVisible(data, visible: boolean)
	if data.Square ~= nil then
		data.Square.Visible = visible
	end
	if data.Label ~= nil then
		data.Label.Visible = visible
	end
	for _, line in data.Lines do
		line.Visible = visible
	end
end

local function RemoveData(data)
	if data.Square ~= nil then
		data.Square:Remove()
	end
	if data.Label ~= nil then
		data.Label:Remove()
	end
	for _, line in data.Lines do
		line:Remove()
	end
end

local function ClearNextbotDrawings()
	for _, data in nextbotDrawings do
		RemoveData(data)
	end
	table.clear(nextbotDrawings)
end

local function CreateNextbotDrawing()
	local square = Drawing.new("Square")
	square.Filled = true
	square.Color = NextbotESPColor
	square.Transparency = 0.1
	square.Thickness = 0

	-- Lines[1..8] — уголки рамки, Lines[9] — tracer
	local lines = {}
	for index = 1, 9 do
		local line = Drawing.new("Line")
		line.Color = NextbotESPColor
		line.Thickness = if index == 9 then 1 else 2
		line.Transparency = if index == 9 then 0.55 else 1
		table.insert(lines, line)
	end

	local label = Drawing.new("Text")
	label.Center = true
	label.Outline = true
	label.Color = NextbotESPColor
	label.Font = 2
	label.Size = 13

	return { Square = square, Lines = lines, Label = label }
end

local function UpdateNextbotESP_Drawing()
	if not NextbotESP then
		if next(nextbotDrawings) ~= nil then
			ClearNextbotDrawings()
		end
		return
	end

	local models = GetNextbotsCached()

	for model, data in nextbotDrawings do
		if models[model] == nil or model.Parent == nil then
			RemoveData(data)
			nextbotDrawings[model] = nil
		end
	end

	local viewport = Camera.ViewportSize

	for model in models do
		local primary = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Root")
		if primary == nil then
			continue
		end

		local boxCFrame, boxSize = model:GetBoundingBox()
		local half = boxSize * 0.5
		local minX, minY = math.huge, math.huge
		local maxX, maxY = -math.huge, -math.huge
		local visiblePoint = false

		for _, sx in { -1, 1 } do
			for _, sy in { -1, 1 } do
				for _, sz in { -1, 1 } do
					local worldPoint = (boxCFrame * CFrame.new(half.X * sx, half.Y * sy, half.Z * sz)).Position
					local point, onScreen = Camera:WorldToViewportPoint(worldPoint)
					if onScreen and point.Z > 0 then
						visiblePoint = true
						minX, minY = math.min(minX, point.X), math.min(minY, point.Y)
						maxX, maxY = math.max(maxX, point.X), math.max(maxY, point.Y)
					end
				end
			end
		end

		local data = nextbotDrawings[model]

		if not visiblePoint then
			if data ~= nil then
				SetDataVisible(data, false)
			end
			continue
		end

		if data == nil then
			data = CreateNextbotDrawing()
			nextbotDrawings[model] = data
		end

		local padding = math.clamp((maxY - minY) * 0.04, 3, 10)
		local x, y = minX - padding, minY - padding
		local width = (maxX - minX) + padding * 2
		local height = (maxY - minY) + padding * 2
		local corner = math.clamp(math.min(width, height) * 0.28, 6, 22)

		data.Square.Color = NextbotESPColor
		data.Square.Position = Vector2.new(x, y)
		data.Square.Size = Vector2.new(width, height)
		data.Square.Visible = true

		local segments = {
			{ Vector2.new(x, y), Vector2.new(x + corner, y) },
			{ Vector2.new(x, y), Vector2.new(x, y + corner) },
			{ Vector2.new(x + width, y), Vector2.new(x + width - corner, y) },
			{ Vector2.new(x + width, y), Vector2.new(x + width, y + corner) },
			{ Vector2.new(x, y + height), Vector2.new(x + corner, y + height) },
			{ Vector2.new(x, y + height), Vector2.new(x, y + height - corner) },
			{ Vector2.new(x + width, y + height), Vector2.new(x + width - corner, y + height) },
			{ Vector2.new(x + width, y + height), Vector2.new(x + width, y + height - corner) },
		}
		for index, segment in segments do
			local line = data.Lines[index]
			line.Color = NextbotESPColor
			line.From = segment[1]
			line.To = segment[2]
			line.Visible = true
		end

		local tracer = data.Lines[9]
		tracer.Color = NextbotESPColor
		tracer.From = Vector2.new(viewport.X / 2, viewport.Y)
		tracer.To = Vector2.new(x + width / 2, y + height)
		tracer.Visible = true

		local distance = (Camera.CFrame.Position - primary.Position).Magnitude
		local botType, botName = GetNextbotInfo(model)
		data.Label.Color = NextbotESPColor
		data.Label.Text = string.format("%s\n%s  [%dm]", botName, botType, math.floor(distance))
		data.Label.Position = Vector2.new(x + width / 2, y - 30)
		data.Label.Visible = true
	end
end

RunService.RenderStepped:Connect(UpdateNextbotESP_Drawing)

-- ============================================================
-- AUTO FARM
-- ============================================================

local function GetTicketVisuals()
    local found   = {}
    local effects = Workspace:FindFirstChild("Effects")
    local tickets = effects and effects:FindFirstChild("Tickets")
    if not tickets then return found end
    for _, obj in ipairs(tickets:GetDescendants()) do
        if obj.Name == "Visual" then table.insert(found, obj) end
    end
    return found
end

local function GetObjectCFrame(obj)
    if not obj or not obj.Parent then return nil end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.CFrame end
        local cf = obj:GetBoundingBox()
        return cf
    elseif obj:IsA("BasePart") then
        return obj.CFrame
    end
    return nil
end

local function FarmPullMode()
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local targetCF = root.CFrame
    for _, visual in ipairs(GetTicketVisuals()) do
        pcall(function()
            if not visual or not visual.Parent then return end
            if visual:IsA("Model") then
                if visual.PrimaryPart then
                    visual:PivotTo(targetCF)
                else
                    for _, p in ipairs(visual:GetDescendants()) do
                        if p:IsA("BasePart") then p.CFrame = targetCF end
                    end
                end
            elseif visual:IsA("BasePart") then
                visual.CFrame = targetCF
            end
        end)
    end
end

local function DestroyRemoteHitbox()
    RemoteHitbox = nil
end

local function FarmFastSwapMode()
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local visuals = GetTicketVisuals()
    if #visuals == 0 then return end

    local savedCF      = root.CFrame
    local savedCamCF   = Camera.CFrame
    local savedCamType = Camera.CameraType

    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame     = savedCamCF
    hum.PlatformStand = true
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.AssemblyLinearVelocity  = Vector3.zero
            p.AssemblyAngularVelocity = Vector3.zero
        end
    end

    for _, visual in ipairs(visuals) do
        if not AutoFarm then break end
        if not visual or not visual.Parent then continue end
        local cf = GetObjectCFrame(visual)
        if not cf then continue end

        local touchFired = false
        pcall(function()
            local parts = visual:IsA("BasePart") and {visual} or visual:GetDescendants()
            for _, p in ipairs(parts) do
                if p:IsA("BasePart") then
                    firetouchinterest(root, p, 0)
                    firetouchinterest(root, p, 1)
                    touchFired = true
                end
            end
        end)

        if not touchFired then
            root.CFrame = cf * CFrame.new(0, 2, 0)
            root.AssemblyLinearVelocity = Vector3.zero
            task.wait(0.04)
            root.CFrame = savedCF
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end

    root.CFrame = savedCF
    root.AssemblyLinearVelocity = Vector3.zero
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.AssemblyLinearVelocity  = Vector3.zero
            p.AssemblyAngularVelocity = Vector3.zero
        end
    end
    hum.PlatformStand = false
    task.wait(0.05)
    Camera.CameraType = savedCamType
end

local function FarmWorldPilotMode()
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, visual in ipairs(GetTicketVisuals()) do
        if not AutoFarm then break end
        local cf = GetObjectCFrame(visual)
        if cf then
            local targetPos = cf.Position + Vector3.new(0, 3, 0)
            local piloted = false
            pcall(function()
                if WorldPilot then
                    WorldPilot:Navigate(targetPos)
                    piloted = true
                end
            end)
            if not piloted then root.CFrame = CFrame.new(targetPos) end
            task.wait(farmDelay)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(farmDelay)
        pcall(function()
            if not AutoFarm then return end
            if IsRevivingNow or Safe or flying then return end
            local char = lp.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            if FarmMode == 1 then FarmPullMode()
            elseif FarmMode == 2 then FarmFastSwapMode()
            elseif FarmMode == 3 then FarmWorldPilotMode()
            end
        end)
    end
end)

lp.CharacterAdded:Connect(function()
    task.wait(0.1)
    DestroyRemoteHitbox()
end)

-- ============================================================
-- UI
-- ============================================================

local Window = MinecraftLib:CreateWindow({
    Title        = "IRY HUB | Evade",
    Theme        = "Nether",
    ToggleKey    = "RightShift",
    ConfigFolder = "inlawry_Evade",
    AutoSave     = false,
    AutoLoad     = false,
})

Window:SetWatermark(true, "IRY HUB v2.0")

local MainTab   = Window:AddTab("Main")
local VisualTab = Window:AddTab("Visual")
local OptTab    = Window:AddTab("Optim")
local ConfigTab = Window:AddTab("Configs")
local AboutTab  = Window:AddTab("inlawry")

-- ============================================================
-- MAIN TAB
-- ============================================================

local moveSec = MainTab:AddSection("Movement")

speedToggle = moveSec:AddToggle({
    Name    = "Speed Hack",
    Default = false,
    Flag    = "speed_hack",
    Callback = function(value)
        Speeds = value
        if not value then
            RestoreSpeedometer()
        else
            lastSpeedPosition = nil
            GetSpeedometerLabel()
        end
    end,
})

speedSlider = moveSec:AddSlider({
    Name     = "Speed Value",
    Min      = 1,
    Max      = 200,
    Default  = 48,
    Step     = 1,
    Flag     = "speed_value",
    Callback = function(value) Power = value end,
})

jumpToggle = moveSec:AddToggle({
    Name    = "Infinite Jump",
    Default = false,
    Flag    = "inf_jump",
    Callback = function(value)
        JumpEnabled = value
        local Hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if Hum then
            if value then
                OriginalJumpPower = Hum.JumpPower
                Hum.UseJumpPower  = true
                Hum.JumpPower     = JumpPower
            else
                Hum.JumpPower = OriginalJumpPower
            end
        end
    end,
})

jumpSlider = moveSec:AddSlider({
    Name     = "Jump Power",
    Min      = 1,
    Max      = 100,
    Default  = 50,
    Step     = 1,
    Flag     = "jump_power",
    Callback = function(value)
        JumpPower = value
        if JumpEnabled then
            local Hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
            if Hum then Hum.JumpPower = value end
        end
    end,
})

local flySec = MainTab:AddSection("Fly")

flyToggle = flySec:AddToggle({
    Name    = "Fly",
    Default = false,
    Flag    = "fly_enabled",
    Callback = function(value)
        flying = value
        if value then startFly() else stopFly() end
    end,
})

flySpeedSlider = flySec:AddSlider({
    Name     = "Fly Speed",
    Min      = 50,
    Max      = 175,
    Default  = 150,
    Step     = 1,
    Flag     = "fly_speed",
    Callback = function(value)
        flySpeed    = value
        flyMaxSpeed = value
    end,
})

flySec:AddKeybind({
    Name     = "Fly Key",
    Default  = "X",
    Mode     = "Press",
    Flag     = "fly_key",
    Callback = function()
        flying = not flying
        if flying then startFly() else stopFly() end
        if flyToggle then flyToggle:Set(flying) end
    end,
})

local safeSec = MainTab:AddSection("Safety & Auto")

safeZoneToggle = safeSec:AddToggle({
    Name    = "Safe Zone",
    Default = false,
    Flag    = "safe_zone",
    Callback = function(value)
        Safe = value
        if value then
            if flying then
                flying = false
                if flyToggle then flyToggle:Set(false) end
                stopFly()
            end
            ignoreTeleportFor(500)
            EnableSafeZone()
        else
            DisableSafeZone()
        end
    end,
})

autoFollowToggle = safeSec:AddToggle({
    Name    = "Auto Follow [Beta]",
    Default = true,
    Flag    = "auto_follow",
    Callback = function(value)
        AutoFollow = value
        if not value and IsFollowing then StopFollowing() end
    end,
})

autoReviveToggle = safeSec:AddToggle({
    Name    = "Auto Revive [Beta]",
    Default = false,
    Flag    = "auto_revive",
    Callback = function(value)
        AutoRevive = value
        if not value then
            IsRevivingNow = false
            table.clear(DownedCache)
            table.clear(DownedCacheTime)
            table.clear(ReviveBlacklist)
            table.clear(ReviveBlacklistTime)
            pcall(function()
                local char = lp.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.PlatformStand = false
                        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
                        hum:SetStateEnabled(Enum.HumanoidStateType.Running,   true)
                        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,   true)
                    end
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = true end
                    end
                end
            end)
            DisableSafeZone()
        end
    end,
})

safeSec:AddButton({
    Name    = "Beta Message",
    Callback = function()
        Window:Notify({
            Title   = "Auto Revive — Beta",
            Content = "Not 100% AFK. E may fire multiple times — this is normal and helps complete the revive. Still in development.",
            Duration = 12,
        })
    end,
})

safeSec:AddKeybind({
    Name     = "Safe Zone Key",
    Default  = "V",
    Mode     = "Press",
    Flag     = "safe_key",
    Callback = function()
        Safe = not Safe
        if Safe then
            if flying then
                flying = false
                if flyToggle then flyToggle:Set(false) end
                stopFly()
            end
            ignoreTeleportFor(500)
            EnableSafeZone()
        else
            DisableSafeZone()
        end
        if safeZoneToggle then safeZoneToggle:Set(Safe) end
    end,
})

local avoidSec = MainTab:AddSection("Avoid Nextbots")

avoidToggle = avoidSec:AddToggle({
    Name    = "Avoid Nextbots",
    Default = false,
    Flag    = "avoid_nextbots",
    Callback = function(value) AvoidNextbots = value end,
})

avoidDistanceSlider = avoidSec:AddSlider({
    Name     = "Avoid Distance",
    Min      = 10,
    Max      = 50,
    Default  = 25,
    Step     = 1,
    Suffix   = " studs",
    Flag     = "avoid_dist",
    Callback = function(value) AvoidDistance = value end,
})

avoidSpeedSlider = avoidSec:AddSlider({
    Name     = "Avoid Speed",
    Min      = 30,
    Max      = 150,
    Default  = 60,
    Step     = 1,
    Flag     = "avoid_speed",
    Callback = function(value) AvoidSpeed = value end,
})

-- ============================================================
-- VISUAL TAB
-- ============================================================

local farmSec = VisualTab:AddSection("Auto Farm")

farmModeDropdown = farmSec:AddDropdown({
    Name    = "Farm Mode",
    Options = {
        "1: Models to Player (DONT WORK)",
        "2: Quick swap  (DONT WORK)",
        "3: TELEPORT (recommended)",
    },
    Default  = "3: TELEPORT (recommended)",
    Flag     = "farm_mode",
    Callback = function(value)
        if value:sub(1, 1) == "1" then FarmMode = 1
        elseif value:sub(1, 1) == "2" then FarmMode = 2
        else FarmMode = 3 end
        if FarmMode ~= 2 then DestroyRemoteHitbox() end
    end,
})

autoFarmToggle = farmSec:AddToggle({
    Name    = "Auto Farm [EVENT COINS]",
    Default = false,
    Flag    = "auto_farm",
    Callback = function(value)
        AutoFarm = value
        if value then
            local count   = #GetTicketVisuals()
            local modeStr = FarmMode == 1 and "Pull Models" or FarmMode == 2 and "Fast Swap" or "Teleport"
            Window:Notify({
                Title   = "Auto Farm",
                Content = "Mode: " .. modeStr .. " | Visuals: " .. count,
                Duration = 4,
            })
        else
            if FarmMode == 2 then DestroyRemoteHitbox() end
        end
    end,
})

farmSec:AddButton({
    Name    = "Check Visual models",
    Callback = function()
        local count = #GetTicketVisuals()
        Window:Notify({
            Title   = "Auto Farm",
            Content = "Found: " .. count .. " visuals (Workspace.Effects.Tickets)",
            Duration = 4,
        })
    end,
})

farmSec:AddButton({
    Name    = "Delete Hitbox",
    Callback = function()
        DestroyRemoteHitbox()
        Window:Notify({Title = "Auto Farm", Content = "Hitbox removed.", Duration = 2})
    end,
})

local envSec = VisualTab:AddSection("Environment")

skyToggle = envSec:AddToggle({
    Name    = "Sky Mode + FullBright",
    Default = false,
    Flag    = "sky_mode",
    Callback = function(value) ToggleSky(value) end,
})

-- ====== ESP ======

local espSec = VisualTab:AddSection("Player ESP")

playerESPToggle = espSec:AddToggle({
    Name    = "ESP Players",
    Default = false,
    Flag    = "esp_players",
    Callback = function(value)
        ESP = value
        if not value then
            for _, x in pairs(Players:GetPlayers()) do ClearPlayerESP(x.Character) end
        end
    end,
})

espSec:AddColorPicker({
    Name    = "Player ESP Color",
    Default = Color3.fromRGB(0, 200, 255),
    Flag    = "esp_color",
    Tooltip = "Цвет highlight-а живых игроков",
    Callback = function(color)
        ESPColor = color
    end,
})

local downedSec = VisualTab:AddSection("Downed ESP")

downedESPToggle = downedSec:AddToggle({
    Name    = "Downed Player ESP",
    Default = false,
    Flag    = "esp_downed",
    Callback = function(value)
        DownedESP = value
        if not value then
            for _, player in ipairs(Players:GetPlayers()) do ClearDownedESP(player.Character) end
        end
    end,
})

downedSec:AddColorPicker({
    Name    = "Downed ESP Color",
    Default = Color3.fromRGB(255, 50, 50),
    Flag    = "esp_downed_color",
    Tooltip = "Цвет highlight-а упавших игроков",
    Callback = function(color)
        DownedESPColor = color
    end,
})

local nextbotSec = VisualTab:AddSection("Nextbot ESP")

nextbotESPToggle = nextbotSec:AddToggle({
    Name    = "Nextbot ESP (Drawing)",
    Default = false,
    Flag    = "esp_nextbot",
    Callback = function(value)
        NextbotESP = value
        if not value then ClearNextbotDrawings() end
    end,
})

nextbotSec:AddColorPicker({
    Name    = "Nextbot ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag    = "esp_nextbot_color",
    Tooltip = "Цвет Drawing-боксов nextbot-ов",
    Callback = function(color)
        NextbotESPColor = color
        for _, data in pairs(nextbotDrawings) do
            if data.Square then data.Square.Color = color end
            if data.Lines  then
                for _, line in ipairs(data.Lines) do line.Color = color end
            end
            if data.Label  then data.Label.Color  = color end
        end
    end,
})

-- ============================================================
-- OPTIM TAB
-- ============================================================

local perfSec = OptTab:AddSection("Performance")

fpsToggle = perfSec:AddToggle({
    Name    = "FPS Booster",
    Default = false,
    Flag    = "fps_boost",
    Callback = function(value)
        FPSBoosted = value
        FPSBooster(value)
    end,
})

fogToggle = perfSec:AddToggle({
    Name    = "Disable Fog",
    Default = false,
    Flag    = "no_fog",
    Callback = function(value)
        FogDisabled = value
        DisableFog(value)
    end,
})

perfSec:AddButton({
    Name    = "Anti GamePaused",
    Callback = function()
        task.spawn(function()
            Window:Notify({Title = "Anti GamePaused", Content = "Unlocking game...", Duration = 2})
            repeat task.wait() until lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            Window:Notify({Title = "Anti GamePaused", Content = "Done!", Duration = 3, Type = "Success"})
        end)
    end,
})

-- ============================================================
-- CONFIGS TAB
-- Замени этим блоком всё от заголовка "CONFIGS TAB" до заголовка
-- "ABOUT / INLAWRY TAB" (старые SaveConfig/LoadConfig/DeleteConfig,
-- configOptions, оба task.defer с autoload и т.д. — удалить).
--
-- Сохранение/загрузка идёт через встроенную систему MinecraftLib
-- (Window:SaveConfig / LoadConfig / GetConfigs / DeleteConfig),
-- она сама собирает ВСЕ элементы с Flag: тумблеры, слайдеры,
-- кейбинды, цвета ESP и режим Farm Mode.
-- ============================================================

local AUTOLOAD_FOLDER = "inlawry_Evade"
local AUTOLOAD_PATH = AUTOLOAD_FOLDER .. "/autoload.txt"
local NO_CONFIGS = "No saved configs"

local hasFileApi = isfolder ~= nil
	and makefolder ~= nil
	and isfile ~= nil
	and readfile ~= nil
	and writefile ~= nil
	and listfiles ~= nil

local configNameBox
local configDropdown
local autoloadToggle
local lastConfigList = ""

-- Те же правила, что и SafeName в библиотеке, чтобы имя файла совпадало.
local function NormalizeConfigName(name): string
	local text = tostring(name or "")
	text = string.gsub(text, "[^%w_%- ]", "")
	text = string.gsub(text, "^%s+", "")
	text = string.gsub(text, "%s+$", "")
	return string.sub(text, 1, 32)
end

local function Notice(content: string, kind: string?)
	Window:Notify({
		Title = "Configs",
		Content = content,
		Duration = 3,
		Type = kind,
	})
end

local function GetConfigNames(): { string }
	local ok, names = pcall(function()
		return Window:GetConfigs()
	end)
	if not ok or type(names) ~= "table" then
		return {}
	end
	return names
end

-- Обновляет dropdown. Вызывается после Save / Delete / Load,
-- по кнопке и автоматически, если список файлов изменился.
local function RefreshConfigList(selectName: string?)
	local names = GetConfigNames()
	local options = if #names > 0 then names else { NO_CONFIGS }

	configDropdown:Refresh(options, true)

	if selectName ~= nil and table.find(options, selectName) ~= nil then
		configDropdown:Set(selectName, true)
	end

	lastConfigList = table.concat(names, "|")
end

local function CurrentConfigName(): string
	local typed = NormalizeConfigName(configNameBox:Get())
	if typed ~= "" then
		return typed
	end

	local picked = configDropdown:Get()
	if picked == nil or picked == NO_CONFIGS then
		return ""
	end
	return NormalizeConfigName(picked)
end

-- ---------- autoload ----------

local function ReadAutoloadName(): string?
	if not hasFileApi or not isfile(AUTOLOAD_PATH) then
		return nil
	end

	local ok, content = pcall(function()
		return readfile(AUTOLOAD_PATH)
	end)
	if not ok or type(content) ~= "string" then
		return nil
	end

	local name = NormalizeConfigName(content)
	if name == "" then
		return nil
	end
	return name
end

local function WriteAutoloadName(name: string?)
	if not hasFileApi then
		return
	end

	if name == nil then
		if delfile ~= nil and isfile(AUTOLOAD_PATH) then
			delfile(AUTOLOAD_PATH)
		end
		return
	end

	if not isfolder(AUTOLOAD_FOLDER) then
		makefolder(AUTOLOAD_FOLDER)
	end
	writefile(AUTOLOAD_PATH, name)
end

-- ---------- actions ----------

local function SaveConfig(name: string)
	if not hasFileApi then
		Notice("Executor does not support file saving.", "Error")
		return
	end
	if name == "" then
		Notice("Enter a config name first.", "Warning")
		return
	end

	local ok, err = Window:SaveConfig(name)
	if not ok then
		Notice("Save failed: " .. tostring(err), "Error")
		return
	end

	configNameBox:Set(name, true)
	RefreshConfigList(name)
	Notice("Saved: " .. name, "Success")
end

local function LoadConfig(name: string, silent: boolean?): boolean
	if not hasFileApi then
		if silent ~= true then
			Notice("Executor does not support file loading.", "Error")
		end
		return false
	end
	if name == "" then
		if silent ~= true then
			Notice("Choose a config first.", "Warning")
		end
		return false
	end

	local ok, err = Window:LoadConfig(name)
	if not ok then
		if silent ~= true then
			Notice("Load failed: " .. tostring(err), "Error")
		end
		RefreshConfigList(nil)
		return false
	end

	configNameBox:Set(name, true)
	RefreshConfigList(name)
	if silent ~= true then
		Notice("Loaded: " .. name, "Success")
	end
	return true
end

local function DeleteConfig(name: string)
	if name == "" then
		Notice("Choose a config first.", "Warning")
		return
	end

	Window:Dialog({
		Title = "Delete config",
		Content = "Delete config '" .. name .. "'? This can't be undone.",
		Buttons = {
			{
				Text = "Delete",
				Callback = function()
					local deleted = Window:DeleteConfig(name)
					if not deleted then
						Notice("Config not found: " .. name, "Error")
						RefreshConfigList(nil)
						return
					end

					if ReadAutoloadName() == name then
						WriteAutoloadName(nil)
						autoloadToggle:Set(false, true)
					end

					configNameBox:Set("", true)
					RefreshConfigList(nil)
					Notice("Deleted: " .. name, "Warning")
				end,
			},
			{ Text = "Cancel" },
		},
	})
end

-- ---------- UI ----------
-- ВАЖНО: у этих элементов нет Flag, иначе они сами попадали бы в конфиг.

local initialNames = GetConfigNames()
local initialOptions = if #initialNames > 0 then initialNames else { NO_CONFIGS }

local cfgManagerSec = ConfigTab:AddSection("Configuration Manager")

configNameBox = cfgManagerSec:AddTextbox({
	Name = "Config Name",
	Placeholder = "example: legit",
})

configDropdown = cfgManagerSec:AddDropdown({
	Name = "Saved Configs",
	Options = initialOptions,
	Callback = function(name)
		if name == nil or name == NO_CONFIGS then
			return
		end
		configNameBox:Set(name, true)
	end,
})
lastConfigList = table.concat(initialNames, "|")

cfgManagerSec:AddButton({
	Name = "Save Config",
	Callback = function()
		SaveConfig(CurrentConfigName())
	end,
})

cfgManagerSec:AddButton({
	Name = "Load Config",
	Callback = function()
		LoadConfig(CurrentConfigName())
	end,
})

cfgManagerSec:AddButton({
	Name = "Delete Config",
	Callback = function()
		DeleteConfig(CurrentConfigName())
	end,
})

cfgManagerSec:AddButton({
	Name = "Refresh List",
	Callback = function()
		RefreshConfigList(nil)
		Notice("List updated: " .. #GetConfigNames() .. " config(s)")
	end,
})

local autoloadSec = ConfigTab:AddSection("Autoload")

autoloadToggle = autoloadSec:AddToggle({
	Name = "Autoload on Startup",
	Default = false,
	Callback = function(value)
		if not hasFileApi then
			Notice("Executor does not support file saving.", "Error")
			autoloadToggle:Set(false, true)
			return
		end

		if not value then
			WriteAutoloadName(nil)
			Notice("Autoload disabled.")
			return
		end

		local name = CurrentConfigName()
		if name == "" or table.find(GetConfigNames(), name) == nil then
			Notice("Save or choose a config first.", "Warning")
			autoloadToggle:Set(false, true)
			return
		end

		WriteAutoloadName(name)
		Notice("Autoload set: " .. name)
	end,
})

autoloadSec:AddButton({
	Name = "Load Autoload Config",
	Callback = function()
		local name = ReadAutoloadName()
		if name == nil then
			Notice("Autoload is not configured.", "Warning")
			return
		end
		LoadConfig(name)
	end,
})

-- ---------- startup ----------

-- Автозагрузка (после того как весь UI уже создан)
task.delay(1, function()
	local name = ReadAutoloadName()
	if name == nil then
		return
	end

	if table.find(GetConfigNames(), name) == nil then
		WriteAutoloadName(nil)
		return
	end

	autoloadToggle:Set(true, true)
	if LoadConfig(name, true) then
		Notice("Autoloaded: " .. name, "Success")
	end
end)

-- Страховка: если файлы конфигов изменились не через UI, dropdown всё равно обновится.
task.spawn(function()
	while true do
		task.wait(2)
		local names = GetConfigNames()
		if table.concat(names, "|") ~= lastConfigList then
			pcall(function()
				RefreshConfigList(nil)
			end)
		end
	end
end)

-- ============================================================
-- ABOUT / INLAWRY TAB
-- ============================================================

local communitySec = AboutTab:AddSection("Community")

communitySec:AddButton({
    Name    = "Copy Telegram",
    Callback = function()
        setclipboard("https://t.me/inlawryDEV")
        Window:Notify({Title = "Telegram", Content = "Link copied to clipboard!", Duration = 2})
    end,
})

local securitySec = AboutTab:AddSection("Security")

securitySec:AddButton({
    Name    = "Mod Detector (Auto-Leave)",
    Callback = function()
        Players.PlayerAdded:Connect(function(plr)
            if plr.UserId == game.CreatorId then lp:Kick("Moderator Joined") end
        end)
        Window:Notify({Title = "Mod Detector", Content = "Active — auto-leave if moderator joins", Duration = 3})
    end,
})

local infoSec = AboutTab:AddSection("Info")

infoSec:AddLabel("Anti AFK active in background")
infoSec:AddLabel("IRY HUB | Evade — Minecraft UI Port")

-- ============================================================
-- KEYBINDS
-- ============================================================

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.R then
        Window:ToggleVisible()
    end
end)

-- ============================================================
-- STARTUP
-- ============================================================

task.delay(1, function()
    Window:Notify({
        Title   = "IRY HUB | Evade",
        Content = "Loaded! RightShift / R — toggle UI",
        Duration = 4,
        Type    = "Success",
    })
end)

print("[IRY HUB] Evade Loaded have a good use")
