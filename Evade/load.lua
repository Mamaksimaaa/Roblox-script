-- inlawry | Evade (Minecraft UI v3)
if not game:IsLoaded() then game.Loaded:Wait() end

local MinecraftLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Mamaksimaaa/Roblox-script/refs/heads/main/Lib/load.lua"
))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local VirtualUser      = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UIS              = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace        = game:GetService("Workspace")
local Camera           = Workspace.CurrentCamera
local lp               = Players.LocalPlayer

-- ========== NEXTBOT DETECTION ==========
-- Evade stores bots only under Workspace.Players with Team = "Nextbot".
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

-- ========== ANTI-AFK ==========
local vu = game:GetService("VirtualUser")
lp.Idled:Connect(function()
    pcall(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

-- ========== VARIABLES ==========
local Speeds            = false   -- РїРµСЂРµРёРјРµРЅРѕРІР°РЅРѕ СЃ Speed
local Power            = 50
local JumpEnabled      = false
local JumpPower        = 50
local OriginalJumpPower = 50
local ESP              = false
local DownedESP        = false
local NextbotESP       = false
local Safe             = false
local AutoRevive       = false
local AutoFollow       = true
local LastPos          = nil
local Plate            = nil
local safeZoneToggle   = nil
local flyToggle        = nil
local autoReviveToggle = nil
local autoFollowToggle = nil
local ignoreTeleport   = false
local ignoreTeleportTimer = nil
local IsRevivingNow    = false
local IsFollowing      = false
local followBodyPos    = nil
local followBodyGyro   = nil
local followConnection = nil
local followNoclipConn = nil
local SkyEnabled       = false
local REVIVE_HEIGHT    = -4.2
local HOLD_DURATION    = 3.35
local REVIVE_INTERVAL  = 0.05
local RAGDOLL_DELAY    = 1.0

-- в… РќРћР’Р«Р• РџР•Р Р•РњР•РќРќР«Р• Р”Р›РЇ РР—Р‘Р•Р“РђРќРРЇ
local AvoidNextbots = false
local AvoidDistance = 25
local AvoidSpeed = 60

local ReviveBlacklist     = {}
local ReviveBlacklistTime = {}
local speedCurrent        = 0
local speedAcceleration   = 7
local speedBrakeForce     = 8
local speedometerLabel    = nil
local originalSpeedText   = nil
local lastSpeedPosition   = nil

local function GetSpeedometerLabel()
    if speedometerLabel and speedometerLabel.Parent then
        return speedometerLabel
    end

    local playerGui = lp:FindFirstChildOfClass("PlayerGui")
    local gameGui = playerGui and playerGui:FindFirstChild("Game")
    local hud = gameGui and gameGui:FindFirstChild("HUD")
    local overlay = hud and hud:FindFirstChild("Overlay")
    local status = overlay and overlay:FindFirstChild("CharacterStatus")
    local bottomLeft = status and status:FindFirstChild("BottomLeft")
    local speedometer = bottomLeft and bottomLeft:FindFirstChild("Speedometer")
    local label = speedometer and speedometer:FindFirstChild("Speed")

    if label and label:IsA("TextLabel") then
        speedometerLabel = label
        originalSpeedText = label.Text
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

-- ========== GRAPHICS ==========
local Original = {
    Brightness    = Lighting.Brightness,
    FogStart      = Lighting.FogStart,
    FogEnd        = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Quality       = settings().Rendering.QualityLevel
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

-- ========== CAMERA ==========
lp.CharacterAdded:Connect(function(character)
    task.wait(0.2)
    local hum    = character:WaitForChild("Humanoid", 5)
    if hum then
        Camera.CameraType    = Enum.CameraType.Custom
        Camera.CameraSubject = hum
        if JumpEnabled then
            hum.UseJumpPower = true
            OriginalJumpPower = hum.JumpPower
            hum.JumpPower = JumpPower
        end
    end
    IsRevivingNow = false
    IsFollowing   = false
    table.clear(ReviveBlacklist)
    table.clear(ReviveBlacklistTime)
end)

-- ========== FLY ==========
local flying        = false
local flySpeed      = 150
local flyMaxSpeed   = 150
local flyCurrentSpeed = 0
local flyAcceleration = 7
local flyBrakeForce = 8
local bodyVelocity, bodyGyro
local flyConnection, noclipConnection
local moveVector    = Vector3.zero
local W, A, S, D   = false, false, false, false
local UP, DOWN, LEFT, RIGHT = false, false, false, false
local isMobile      = UIS.TouchEnabled and not UIS.KeyboardEnabled
local joystickFrame, thumb
local dragging, dragInput = false, nil

local flyGui = Instance.new("ScreenGui")
flyGui.Name         = "inlawry_FLY"
flyGui.ResetOnSpawn = false
flyGui.Parent       = lp:WaitForChild("PlayerGui")

joystickFrame = Instance.new("Frame")
joystickFrame.Size                  = UDim2.new(0, 170, 0, 170)
joystickFrame.Position              = UDim2.new(0.08, 0, 0.42, 0)
joystickFrame.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
joystickFrame.BackgroundTransparency = 0.90
joystickFrame.Visible               = false
joystickFrame.Parent                = flyGui
Instance.new("UICorner", joystickFrame).CornerRadius = UDim.new(1, 0)

thumb = Instance.new("Frame")
thumb.Size                  = UDim2.new(0, 55, 0, 55)
thumb.Position              = UDim2.new(0.5, -27, 0.5, -27)
thumb.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
thumb.BackgroundTransparency = 0.60
thumb.Parent                = joystickFrame
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

-- ========== SAFE ZONE ==========
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

-- ========== DETECTION ==========
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
            if text:find("revive") or text:find("rГ©animer") or text:find("reanimer") then return true end
        end
    end
    return false
end

-- Blacklist cleanup
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

-- ========== DOWNED CACHE ==========
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

-- ========== FORWARD DECLARATION ==========
local StopFollowing

-- ========== AUTO FOLLOW ==========
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

    followBodyGyro             = Instance.new("BodyGyro")
    followBodyGyro.MaxTorque   = Vector3.new(math.huge, math.huge, math.huge)
    followBodyGyro.P           = 30000
    followBodyGyro.Parent      = root

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

-- ========== REVIVE ==========
local function PerformRevive(targetPlayer)
    if not targetPlayer or not targetPlayer.Parent or not targetPlayer.Character then return end
    if IsRevivingNow then return end
    IsRevivingNow = true
    DisableSafeZone()

    local myChar  = lp.Character
    if not myChar then IsRevivingNow = false return end
    local myRoot  = myChar:FindFirstChild("HumanoidRootPart")
    local myHum   = myChar:FindFirstChildOfClass("Humanoid")
    local tRoot   = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
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

    local reviveStart    = tick()
    local stuckCheck     = tick()
    local lastCheckPos   = myRoot.Position

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

-- ========== MAIN LOOP ==========
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

-- ========== WARM SKY ==========
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
    Instance.new("Atmosphere", Lighting).Color = Color3.fromRGB(199, 172, 120)
    Instance.new("BloomEffect", Lighting).Intensity = 0.15
    Instance.new("SunRaysEffect", Lighting).Intensity = 0.08
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

-- ========== MOVEMENT (СЃ РїРѕРґРґРµСЂР¶РєРѕР№ Avoid Nextbots) ==========
RunService.RenderStepped:Connect(function()
    local char = lp.Character
    if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    -- Р‘Р°Р·РѕРІРѕРµ РЅР°РїСЂР°РІР»РµРЅРёРµ (РѕС‚ РєР»Р°РІРёС€)
    local moveDir = hum.MoveDirection

    -- в… Р•СЃР»Рё РІРєР»СЋС‡РµРЅРѕ РёР·Р±РµРіР°РЅРёРµ Рё РЅРµ РјРµС€Р°СЋС‚ РґСЂСѓРіРёРµ СЂРµР¶РёРјС‹
    if AvoidNextbots and not flying and not IsFollowing and not IsRevivingNow and not Safe then
        local pos = root.Position
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
            local dir = (pos - nearest.Position) * Vector3.new(1,0,1) -- С‚РѕР»СЊРєРѕ РіРѕСЂРёР·РѕРЅС‚Р°Р»СЊ
            if dir.Magnitude > 0.1 then
                moveDir = dir.Unit
            end
        end
    end

    -- РџСЂРёРјРµРЅСЏРµРј РґРІРёР¶РµРЅРёРµ
    if Speeds then
        if moveDir.Magnitude > 0 then
            speedCurrent = math.min(speedCurrent + speedAcceleration, Power)
            local mv = moveDir * (speedCurrent / 45)
            if mv.Magnitude < 50 then
                root.CFrame = root.CFrame + mv
            else
                speedCurrent = speedCurrent / 2
            end
        else
            speedCurrent = math.max(0, speedCurrent - speedBrakeForce)
            if speedCurrent > 0 then
                local mv = moveDir * (speedCurrent / 45)
                if mv.Magnitude < 50 then
                    root.CFrame = root.CFrame + mv
                else
                    speedCurrent = speedCurrent / 2
                end
            end
        end
    else
        -- Р•СЃР»Рё Speed Hack РІС‹РєР»СЋС‡РµРЅ, РЅРѕ РёР·Р±РµРіР°РЅРёРµ РІРєР»СЋС‡РµРЅРѕ вЂ“ РґРІРёРіР°РµРјСЃСЏ СЃ С„РёРєСЃРёСЂРѕРІР°РЅРЅРѕР№ СЃРєРѕСЂРѕСЃС‚СЊСЋ
        if AvoidNextbots and not flying and not IsFollowing and not IsRevivingNow and not Safe then
            if moveDir.Magnitude > 0 then
                local mv = moveDir * (AvoidSpeed / 45)
                root.CFrame = root.CFrame + mv
            end
        end
    end
end)

-- ========== РЎРџРР”РћРњР•РўР  ==========
RunService.Heartbeat:Connect(function(deltaTime)
    if not Speeds then
        lastSpeedPosition = nil
        return
    end

    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
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

-- ========== INFINITE JUMP ==========
local lastInfiniteJump = 0

local function DoInfiniteJump()
    if not JumpEnabled or tick() - lastInfiniteJump < 0.08 then return end
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 or hum.Sit then return end

    lastInfiniteJump = tick()
    hum.UseJumpPower = true
    hum.JumpPower = JumpPower
    hum.Jump = true
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end

UIS.JumpRequest:Connect(DoInfiniteJump)

-- ========== 2D BOX ESP Р”Р›РЇ NEXTBOT'РѕРІ (DRAWING) ==========
local nextbotDrawings = {}

local function ClearNextbotDrawings()
    for _, data in pairs(nextbotDrawings) do
        if data.Square then data.Square:Remove() end
        if data.Label then data.Label:Remove() end
        if data.Lines then
            for _, line in ipairs(data.Lines) do
                line:Remove()
            end
        end
    end
    table.clear(nextbotDrawings)
end

local function UpdateNextbotESP_Drawing()
    if not NextbotESP then
        ClearNextbotDrawings()
        return
    end

    local camera = Camera
    if not camera then return end

    local models = GetNextbots()

    for model, data in pairs(nextbotDrawings) do
        if not models[model] or not model.Parent then
            if data.Square then data.Square:Remove() end
            if data.Label then data.Label:Remove() end
            if data.Lines then
                for _, line in ipairs(data.Lines) do
                    line:Remove()
                end
            end
            nextbotDrawings[model] = nil
        end
    end

    for model in pairs(models) do
        local primary = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Root")
        if not primary then continue end

        local boxCFrame, boxSize = model:GetBoundingBox()
        local half = boxSize * 0.5
        local minX, minY = math.huge, math.huge
        local maxX, maxY = -math.huge, -math.huge
        local visiblePoint = false
        for _, offset in ipairs({
            Vector3.new(-half.X, -half.Y, -half.Z), Vector3.new(-half.X, -half.Y, half.Z),
            Vector3.new(-half.X, half.Y, -half.Z), Vector3.new(-half.X, half.Y, half.Z),
            Vector3.new(half.X, -half.Y, -half.Z), Vector3.new(half.X, -half.Y, half.Z),
            Vector3.new(half.X, half.Y, -half.Z), Vector3.new(half.X, half.Y, half.Z)
        }) do
            local point, onScreen = camera:WorldToViewportPoint((boxCFrame * CFrame.new(offset)).Position)
            if onScreen and point.Z > 0 then
                visiblePoint = true
                minX, minY = math.min(minX, point.X), math.min(minY, point.Y)
                maxX, maxY = math.max(maxX, point.X), math.max(maxY, point.Y)
            end
        end

        if not visiblePoint then
            local data = nextbotDrawings[model]
            if data then
                if data.Square then data.Square.Visible = false end
                if data.Label then data.Label.Visible = false end
                if data.Lines then
                    for _, line in ipairs(data.Lines) do
                        line.Visible = false
                    end
                end
            end
            continue
        end

        local padding = math.clamp((maxY - minY) * 0.04, 3, 10)
        local x, y = minX - padding, minY - padding
        local width, height = (maxX - minX) + padding * 2, (maxY - minY) + padding * 2

        local data = nextbotDrawings[model]
        if not data then
            data = {}
            local sq = Drawing.new("Square")
            sq.Filled = true
            sq.Color = Color3.fromRGB(255, 0, 0)
            sq.Transparency = 0.18
            sq.Thickness = 0
            local lines = {}
            for i = 1, 4 do
                local line = Drawing.new("Line")
                line.Color = Color3.fromRGB(255, 255, 255)
                line.Thickness = 2
                line.Transparency = 1
                table.insert(lines, line)
            end
            local label = Drawing.new("Text")
            label.Center = true
            label.Outline = true
            label.Color = Color3.fromRGB(255, 80, 80)
            label.Font = 2
            label.Size = 14
            data.Square = sq
            data.Lines = lines
            data.Label = label
            nextbotDrawings[model] = data
        end

        local sq = data.Square
        sq.Position = Vector2.new(x, y)
        sq.Size = Vector2.new(width, height)
        sq.Visible = true

        local distance = (camera.CFrame.Position - primary.Position).Magnitude
        local botType, botName = GetNextbotInfo(model)
        local label = data.Label
        label.Text = string.format("Type: %s\n%s  [%dm]", botType, botName, math.floor(distance))
        label.Position = Vector2.new(x + width / 2, y - 28)
        label.Size = 13
        label.Visible = true

        local lines = data.Lines
        lines[1].From = Vector2.new(x, y)
        lines[1].To = Vector2.new(x + width, y)
        lines[1].Visible = true
        lines[2].From = Vector2.new(x + width, y)
        lines[2].To = Vector2.new(x + width, y + height)
        lines[2].Visible = true
        lines[3].From = Vector2.new(x + width, y + height)
        lines[3].To = Vector2.new(x, y + height)
        lines[3].Visible = true
        lines[4].From = Vector2.new(x, y + height)
        lines[4].To = Vector2.new(x, y)
        lines[4].Visible = true
    end
end

Workspace.DescendantAdded:Connect(function(desc)
    if NextbotESP and desc:IsA("Model") and IsNextbot(desc) then
        task.wait()
        UpdateNextbotESP_Drawing()
    end
end)

RunService.RenderStepped:Connect(UpdateNextbotESP_Drawing)

-- ========== ESP PLAYERS ==========
local function ClearPlayerESP(character)
    if not character then return end
    local highlight = character:FindFirstChild("ESP_Highlight")
    if highlight then highlight:Destroy() end
    local nameTag = character:FindFirstChild("ESP_Name")
    if nameTag then nameTag:Destroy() end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") then
            local cham = child:FindFirstChild("ESP_Cham")
            if cham then cham:Destroy() end
        end
    end
end

local function ClearDownedESP(character)
    if not character then return end
    local highlight = character:FindFirstChild("DownedESP_Highlight")
    if highlight then highlight:Destroy() end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") then
            local cham = child:FindFirstChild("DownedESP_Cham")
            if cham then cham:Destroy() end
        end
    end
    local nameTag = character:FindFirstChild("DownedESP_Name")
    if nameTag then nameTag:Destroy() end
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if not ESP then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= lp and v.Character then
                    ClearPlayerESP(v.Character)
                end
            end
            continue
        end
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character then
                local humT = v.Character:FindFirstChildOfClass("Humanoid")
                if humT and humT.Health > 0 and not IsPlayerDowned(v) then
                    local pct   = humT.Health / humT.MaxHealth
                    local color = pct < 0.3 and Color3.fromRGB(255,165,0) or Color3.fromRGB(0,255,0)
                    local highlight = v.Character:FindFirstChild("ESP_Highlight")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "ESP_Highlight"
                        highlight.Adornee = v.Character
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.OutlineTransparency = 0
                        highlight.FillTransparency = 0.8
                        highlight.Parent = v.Character
                    end
                    highlight.FillColor = color
                    highlight.OutlineColor = color
                    local root = v.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local tag = v.Character:FindFirstChild("ESP_Name")
                        if not tag then
                            tag = Instance.new("BillboardGui")
                            tag.Name = "ESP_Name"
                            tag.Adornee = root
                            tag.AlwaysOnTop = true
                            tag.MaxDistance = 2000
                            tag.Size = UDim2.new(0, 145, 0, 34)
                            tag.StudsOffset = Vector3.new(0, 3.35, 0)
                            tag.Parent = v.Character
                            local label = Instance.new("TextLabel")
                            label.Name = "Label"
                            label.Size = UDim2.fromScale(1, 1)
                            label.BackgroundTransparency = 1
                            label.Font = Enum.Font.GothamBold
                            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            label.TextStrokeTransparency = 0
                            label.TextSize = 12
                            label.Parent = tag
                        end
                        local label = tag:FindFirstChild("Label")
                        local distance = (Camera.CFrame.Position - root.Position).Magnitude
                        if label then
                            label.TextColor3 = color
                            label.Text = string.format("Status: LIVE\n%s  [%dm]", v.DisplayName, math.floor(distance))
                        end
                    end
                else
                    ClearPlayerESP(v.Character)
                end
            end
        end
    end
end)

-- ========== DOWNED PLAYER ESP ==========
task.spawn(function()
    while true do
        task.wait(0.2)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp and player.Character then
                local character = player.Character
                if DownedESP and IsPlayerDowned(player) then
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local highlight = character:FindFirstChild("DownedESP_Highlight")
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "DownedESP_Highlight"
                            highlight.Adornee = character
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.FillTransparency = 0.68
                            highlight.OutlineTransparency = 0
                            highlight.Parent = character
                        end
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 70, 70)

                        local nameTag = character:FindFirstChild("DownedESP_Name")
                        if not nameTag then
                            nameTag = Instance.new("BillboardGui")
                            nameTag.Name = "DownedESP_Name"
                            nameTag.Adornee = root
                            nameTag.AlwaysOnTop = true
                            nameTag.MaxDistance = 2000
                            nameTag.Size = UDim2.new(0, 155, 0, 34)
                            nameTag.StudsOffset = Vector3.new(0, 3.65, 0)
                            nameTag.Parent = character

                            local label = Instance.new("TextLabel")
                            label.Name = "Label"
                            label.Size = UDim2.fromScale(1, 1)
                            label.BackgroundTransparency = 1
                            label.Font = Enum.Font.GothamBold
                            label.TextColor3 = Color3.fromRGB(255, 0, 0)
                            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            label.TextStrokeTransparency = 0
                            label.TextSize = 12
                            label.Parent = nameTag
                        end
                        local label = nameTag:FindFirstChild("Label")
                        local distance = (Camera.CFrame.Position - root.Position).Magnitude
                        if label then label.Text = string.format("Status: DOWNED\n%s  [%dm]", player.DisplayName, math.floor(distance)) end
                    end
                else
                    ClearDownedESP(character)
                end
            end
        end
    end
end)

-- ========== MINECRAFT UI вЂ” WINDOW & TABS ==========
local Window = MinecraftLib:CreateWindow("inlawry | Evade", {Theme = "Nether"})

local MainTab   = Window:AddTab("Main")
local VisualTab = Window:AddTab("Visual")
local OptTab    = Window:AddTab("Optim")
local AboutTab  = Window:AddTab("inlawry")

-- MAIN TAB
MainTab:AddSeparator("Movement")

MainTab:AddToggle("Speed Hack", false, function(value)
    Speeds = value
    if not value then
        speedCurrent = 0
        RestoreSpeedometer()
    else
        lastSpeedPosition = nil
        GetSpeedometerLabel()
    end
end)

MainTab:AddSlider("Speed Value", 16, 105, 50, function(value)
    Power = value
end)

MainTab:AddToggle("Infinite Jump", false, function(value)
    JumpEnabled = value
    local Hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
    if Hum then
        if value then
            OriginalJumpPower = Hum.JumpPower
            Hum.UseJumpPower = true
            Hum.JumpPower = JumpPower
        else
            Hum.JumpPower = OriginalJumpPower
        end
    end
end)

MainTab:AddSlider("Jump Power", 1, 100, 50, function(value)
    JumpPower = value
    if JumpEnabled then
        local Hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if Hum then Hum.JumpPower = value end
    end
end)

MainTab:AddSeparator("Fly")

flyToggle = MainTab:AddToggle("Fly", false, function(value)
    flying = value
    if value then startFly() else stopFly() end
end)

MainTab:AddSlider("Fly Speed", 50, 175, 150, function(value)
    flySpeed    = value
    flyMaxSpeed = value
end)

MainTab:AddKeybind("Fly Key", "X", function()
    flying = not flying
    if flying then startFly() else stopFly() end
    if flyToggle then flyToggle:Set(flying) end
end)

MainTab:AddSeparator("Safety & Auto")

safeZoneToggle = MainTab:AddToggle("Safe Zone", false, function(value)
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
end)

autoFollowToggle = MainTab:AddToggle("Auto Follow [Beta]", true, function(value)
    AutoFollow = value
    if not value and IsFollowing then StopFollowing() end
end)

autoReviveToggle = MainTab:AddToggle("Auto Revive [Beta]", false, function(value)
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
end)

MainTab:AddButton("Beta Message", function()
    Window:Notify(
        "Auto Revive вЂ” Beta",
        "Not 100% AFK. E may fire multiple times вЂ” this is normal and helps complete the revive. Still in development.",
        12
    )
end)

MainTab:AddKeybind("Safe Zone Key", "V", function()
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
end)

-- в… РќРћР’РђРЇ РЎР•РљР¦РРЇ: РР—Р‘Р•Р“РђРќРР• РќР•РљРЎРўР‘РћРўРћР’
MainTab:AddSeparator("Avoid Nextbots")
local avoidToggle = MainTab:AddToggle("Avoid Nextbots", false, function(value)
    AvoidNextbots = value
end)
MainTab:AddSlider("Avoid Distance", 10, 50, 25, function(value)
    AvoidDistance = value
end)
MainTab:AddSlider("Avoid Speed", 30, 150, 60, function(value)
    AvoidSpeed = value
end)

-- VISUAL TAB
VisualTab:AddSeparator("Environment")
VisualTab:AddToggle("Sky Mode + FullBright", false, function(value)
    ToggleSky(value)
end)

VisualTab:AddSeparator("ESP")
VisualTab:AddToggle("ESP Players", false, function(value)
    ESP = value
    if not value then
        for _, x in pairs(Players:GetPlayers()) do
            ClearPlayerESP(x.Character)
        end
    end
end)

VisualTab:AddToggle("Downed Player ESP", false, function(value)
    DownedESP = value
    if not value then
        for _, player in ipairs(Players:GetPlayers()) do
            ClearDownedESP(player.Character)
        end
    end
end)

VisualTab:AddToggle("Nextbot ESP (Drawing)", false, function(value)
    NextbotESP = value
    if not value then
        ClearNextbotDrawings()
    end
end)

-- OPTIM TAB
OptTab:AddSeparator("Performance")
OptTab:AddToggle("FPS Booster", false, function(value)
    FPSBooster(value)
end)
OptTab:AddToggle("Disable Fog", false, function(value)
    DisableFog(value)
end)
OptTab:AddButton("Anti GamePaused", function()
    task.spawn(function()
        Window:Notify("Anti GamePaused", "Unlocking game...", 2)
        repeat task.wait() until lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        Window:Notify("Anti GamePaused", "Done!", 3)
    end)
end)

-- ABOUT TAB
AboutTab:AddSeparator("Community")
AboutTab:AddButton("Copy Telegram", function()
    setclipboard("https://t.me/inlawryDEV")
    Window:Notify("Telegram", "Link copied to clipboard!", 2)
end)

AboutTab:AddSeparator("Security")
AboutTab:AddButton("Mod Detector (Auto-Leave)", function()
    Players.PlayerAdded:Connect(function(plr)
        if plr.UserId == game.CreatorId then lp:Kick("Moderator Joined") end
    end)
    Window:Notify("Mod Detector", "Active вЂ” auto-leave if moderator joins", 3)
end)

AboutTab:AddSeparator("Info")
AboutTab:AddLabel("Anti AFK active in background")
AboutTab:AddLabel("inlawry | Evade вЂ” Minecraft UI Port")

-- UI TOGGLE (R key)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.R then
        Window:ToggleVisible()
    end
end)

-- STARTUP
task.delay(1, function()
    Window:Notify("inlawry | Evade", "Loaded! RightShift / R вЂ” toggle UI", 4)
end)

print("[inlawry] вњ… Evade Loaded вЂ” Nextbot ESP РїРѕ Р°С‚СЂРёР±СѓС‚Сѓ Team, Infinite Jump СЂР°Р±РѕС‚Р°РµС‚ РІСЃРµРіРґР°")
