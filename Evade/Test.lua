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
local HttpService      = game:GetService("HttpService")
local Camera           = Workspace.CurrentCamera
local lp               = Players.LocalPlayer

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

local Speeds            = false
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
local speedToggle      = nil
local jumpToggle       = nil
local avoidToggle      = nil
local playerESPToggle  = nil
local downedESPToggle  = nil
local nextbotESPToggle = nil
local fpsToggle        = nil
local fogToggle        = nil
local skyToggle        = nil
local roundTimerToggle = nil
local iryHubUsersToggle = nil
local speedSlider      = nil
local jumpSlider       = nil
local flySpeedSlider   = nil
local avoidDistanceSlider = nil
local avoidSpeedSlider = nil
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
local RoundTimerEnabled = false
local roundTimerGui    = nil
local roundTimerConnection = nil
local roundTimerGeneration = 0
local ROUND_TIMER_LOGO_URL = "https://i.postimg.cc/wv2hpwyM/Bez-nazvania8-20260824103816.png"

local IRY_LOGO_URL = "https://i.postimg.cc/wv2hpwyM/Bez-nazvania8-20260824103816.png"
local IRY_HUB_PRESENCE_URL = "https://hajinertym-serverlogic.hf.space/"
local IRYHubUsersESP = false
local IRY_HUB_TAG_NAME = "IRY_HUB_USER_TAG"
local REVIVE_HEIGHT    = -4.2
local HOLD_DURATION    = 3.35
local REVIVE_INTERVAL  = 0.05
local RAGDOLL_DELAY    = 1.0

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

local function DisableRoundTimer()
    if roundTimerConnection then
        roundTimerConnection:Disconnect()
        roundTimerConnection = nil
    end
    if roundTimerGui then
        roundTimerGui:Destroy()
        roundTimerGui = nil
    end

    local playerGui = lp:FindFirstChildOfClass("PlayerGui")
    local oldTimer = playerGui and playerGui:FindFirstChild("IRY_RoundTimerGui")
    if oldTimer then oldTimer:Destroy() end
end

local function GetRoundTimerLogo()
    local getAsset = getcustomasset or getsynasset
    local logoPath = "inlawry_Evade/round_timer_logo.png"
    if getAsset and writefile and isfile and makefolder and isfolder then
        if not isfolder("inlawry_Evade") then makefolder("inlawry_Evade") end
        if not isfile(logoPath) then
            pcall(function()
                writefile(logoPath, game:HttpGet(ROUND_TIMER_LOGO_URL))
            end)
        end
        if isfile(logoPath) then
            local ok, asset = pcall(getAsset, logoPath)
            if ok then return asset end
        end
    end
    return ROUND_TIMER_LOGO_URL
end

local function ToggleRoundTimer(enabled)
    RoundTimerEnabled = enabled
    roundTimerGeneration = roundTimerGeneration + 1
    local generation = roundTimerGeneration
    DisableRoundTimer()
    if not enabled then return end

    task.spawn(function()
        local playerGui = lp:WaitForChild("PlayerGui", 15)
        if not playerGui or not RoundTimerEnabled or generation ~= roundTimerGeneration then return end

        local timerGui = Instance.new("ScreenGui")
        timerGui.Name = "IRY_RoundTimerGui"
        timerGui.ResetOnSpawn = false
        timerGui.DisplayOrder = 999
        timerGui.IgnoreGuiInset = true
        timerGui.Parent = playerGui
        roundTimerGui = timerGui

        local logo = Instance.new("ImageLabel")
        logo.Name = "RoundTimerLogo"
        logo.Position = UDim2.new(0, 16, 0, 16)
        logo.Size = UDim2.new(0, 48, 0, 48)
        logo.BackgroundTransparency = 1
        logo.Image = GetRoundTimerLogo()
        logo.ScaleType = Enum.ScaleType.Fit
        logo.ZIndex = 10
        logo.Parent = timerGui

        local timerLabel = Instance.new("TextLabel")
        timerLabel.Name = "RoundTimer"
        timerLabel.Position = UDim2.new(0.5, 0, 0.05, 0)
        timerLabel.AnchorPoint = Vector2.new(0.5, 0)
        timerLabel.Size = UDim2.new(0, 130, 0, 38)
        timerLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        timerLabel.BackgroundTransparency = 0.35
        timerLabel.BorderSizePixel = 0
        timerLabel.Text = "--:--"
        timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        timerLabel.Font = Enum.Font.GothamBold
        timerLabel.TextScaled = true
        timerLabel.ZIndex = 10
        timerLabel.Parent = timerGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = timerLabel

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 8)
        padding.PaddingRight = UDim.new(0, 8)
        padding.Parent = timerLabel

        local eventsFolder = ReplicatedStorage:WaitForChild("Events", 15)
        local roundEvent = eventsFolder and eventsFolder:WaitForChild("UpdateServerStateRegistryUnreliable", 15)
        if not roundEvent or not RoundTimerEnabled or generation ~= roundTimerGeneration then
            if roundTimerGui == timerGui then DisableRoundTimer() else timerGui:Destroy() end
            return
        end

        roundTimerConnection = roundEvent.OnClientEvent:Connect(function(key, value)
            if key ~= "Time" or type(value) ~= "number" or not timerLabel.Parent then return end
            local seconds = math.max(0, math.floor(value))
            timerLabel.Text = string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
            if seconds <= 30 then
                timerLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            elseif seconds <= 60 then
                timerLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
            else
                timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)
    end)
end

-- ============================================================
--  УНИВЕРСАЛЬНЫЙ HTTP-ЗАПРОС (с отладкой)
-- ============================================================

local function HttpRequest(options)
    local method = options.Method or "GET"
    local url = options.Url
    local headers = options.Headers or {}
    local body = options.Body

    print("[IRY] Requesting", method, url)

    local sendFunctions = {
        -- Способ 1: HttpService:RequestAsync (встроенный)
        function()
            local http = game:GetService("HttpService")
            local req = {
                Url = url,
                Method = method,
                Headers = headers,
            }
            if body and method ~= "GET" then
                req.Body = body
            end
            local response = http:RequestAsync(req)
            return {
                StatusCode = response.StatusCode,
                Body = response.Body,
            }
        end,
        -- Способ 2: syn.request (если есть)
        function()
            if syn and syn.request then
                local response = syn.request({
                    Url = url,
                    Method = method,
                    Headers = headers,
                    Body = body,
                })
                return {
                    StatusCode = response.StatusCode,
                    Body = response.Body,
                }
            end
            return nil
        end,
        -- Способ 3: http_request (если есть)
        function()
            if http_request then
                local response = http_request({
                    Url = url,
                    Method = method,
                    Headers = headers,
                    Body = body,
                })
                return {
                    StatusCode = response.StatusCode,
                    Body = response.Body,
                }
            end
            return nil
        end,
        -- Способ 4: game:HttpGet (только GET)
        function()
            if method == "GET" then
                local body = game:HttpGet(url)
                return {
                    StatusCode = 200,
                    Body = body,
                }
            end
            return nil
        end,
    }

    for _, fn in ipairs(sendFunctions) do
        local ok, result = pcall(fn)
        if ok and result and result.Body then
            print("[IRY] Response status", result.StatusCode)
            print("[IRY] Response body", result.Body:sub(1, 500))
            return result
        end
    end
    print("[IRY] All request methods failed")
    return nil
end

local function IsPresenceConfigured()
    return not IRY_HUB_PRESENCE_URL:find("YOUR%-HF%-USERNAME", 1, false)
end

local function PresenceRequest(method, path, body)
    if not IsPresenceConfigured() then
        print("[IRY] URL not configured")
        return nil
    end
    -- Убираем лишние слеши
    local base = IRY_HUB_PRESENCE_URL:gsub("/$", "")
    local fullUrl = base .. "/" .. path:gsub("^/", "")
    print("[IRY] Sending", method, fullUrl)
    local response = HttpRequest({
        Url = fullUrl,
        Method = method,
        Headers = { ["Content-Type"] = "application/json" },
        Body = body,
    })
    return response
end

-- ============================================================
--  IRY HUB TAG
-- ============================================================

local function DrawIRYHubTag(player)
    if player == lp then return end
    local character = player.Character
    if not character then
        print("[IRY] No character for", player.Name)
        return
    end

    local oldTag = character:FindFirstChild(IRY_HUB_TAG_NAME)
    if oldTag then oldTag:Destroy() end

    local adornee = character:FindFirstChild("HumanoidRootPart")
    if not adornee then
        adornee = character:FindFirstChild("Head")
    end
    if not adornee then
        print("[IRY] No adornee for", player.Name)
        return
    end

    local tag = Instance.new("BillboardGui")
    tag.Name = IRY_HUB_TAG_NAME
    tag.Adornee = adornee
    tag.Size = UDim2.new(0, 140, 0, 32)
    tag.StudsOffset = Vector3.new(0, 4, 0)
    tag.AlwaysOnTop = true
    tag.MaxDistance = 1000
    tag.Parent = character

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "🔹 IRY HUB"
    label.TextColor3 = Color3.fromRGB(90, 210, 255)
    label.TextStrokeTransparency = 0.25
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = tag

    print("[IRY] Tag added for", player.Name)
end

local function RemoveIRYHubTag(character)
    if not character then return end
    local tag = character:FindFirstChild(IRY_HUB_TAG_NAME)
    if tag then tag:Destroy() end
end

local function ClearIRYHubTags()
    for _, player in ipairs(Players:GetPlayers()) do
        RemoveIRYHubTag(player.Character)
    end
end

local function SendIRYHubPresence()
    if game.JobId == "" then
        print("[IRY] JobId empty, skipping send")
        return
    end
    local payload = HttpService:JSONEncode({
        user_id = lp.UserId,
        username = lp.Name,
        place_id = game.PlaceId,
        job_id = game.JobId,
    })
    print("[IRY] Sending presence for", lp.Name)
    PresenceRequest("POST", "/presence", payload)
end

local function RefreshIRYHubTags()
    if not IRYHubUsersESP then
        print("[IRY] ESP disabled, skipping refresh")
        return
    end
    if game.JobId == "" then
        print("[IRY] JobId empty, skipping refresh")
        return
    end
    local path = "/presence?place_id=" .. game.PlaceId .. "&job_id=" .. HttpService:UrlEncode(game.JobId)
    local response = PresenceRequest("GET", path)
    if not response or not response.Body then
        print("[IRY] No response from server")
        return
    end

    local ok, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
    if not ok or type(data) ~= "table" or type(data.users) ~= "table" then
        print("[IRY] Invalid JSON:", response.Body)
        return
    end

    print("[IRY] Active users:", #data.users)
    local activeUsers = {}
    for _, user in ipairs(data.users) do
        if type(user) == "table" and type(user.user_id) == "number" then
            activeUsers[user.user_id] = true
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp then
            if activeUsers[player.UserId] then
                DrawIRYHubTag(player)
            else
                RemoveIRYHubTag(player.Character)
            end
        end
    end
end

task.spawn(function()
    while true do
        pcall(function()
            SendIRYHubPresence()
            RefreshIRYHubTags()
        end)
        task.wait(20)
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if IRYHubUsersESP then
            RefreshIRYHubTags()
        end
    end)
end)

-- ============================================================
--  ОСТАЛЬНОЙ КОД (движение, флай, ревайв, ESP, автофарм)
-- ============================================================

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
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    if flyConnection    then flyConnection:Disconnect(); flyConnection    = nil end
    if isMobile and joystickFrame then joystickFrame.Visible = false end
    flyCurrentSpeed = 0
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro     then bodyGyro:Destroy(); bodyGyro     = nil end
    local char = lp.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end

local function DisableSafeZone()
    if Plate then Plate:Destroy(); Plate = nil end
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if LastPos and root then root.CFrame = LastPos; LastPos = nil end
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
            DownedCache[plr] = nil; DownedCacheTime[plr] = nil; continue
        end
        if not IsPlayerDowned(plr) then
            DownedCache[plr] = nil; DownedCacheTime[plr] = nil; continue
        end
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if root and root.Parent and not IsNextbotNear(root.Position, 35) then
            local dist = (root.Position - myRoot.Position).Magnitude
            if dist < bestDist then bestDist = dist; best = plr end
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
                if dist < closestDist then closestDist = dist; closest = root end
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

    followBodyGyro             = Instance.new("BodyGyro")
    followBodyGyro.MaxTorque   = Vector3.new(math.huge, math.huge, math.huge)
    followBodyGyro.P           = 30000
    followBodyGyro.Parent      = root

    followNoclipConn = RunService.PreSimulation:Connect(function()
        if not IsFollowing then
            if followNoclipConn then followNoclipConn:Disconnect(); followNoclipConn = nil end
            return
        end
        local charNow = lp.Character
        if charNow then
            for _, v in pairs(charNow:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

    followConnection = RunService.RenderStepped:Connect(function()
        if not IsFollowing or not followBodyPos then return end
        local target = GetClosestAliveTeammate()
        if not target or not target.Parent then
            if StopFollowing then StopFollowing() end
            return
        end
        followBodyPos.Position = target.Position
        followBodyGyro.CFrame = CFrame.lookAt(followBodyPos.Parent.Position, target.Position)
    end)
end

StopFollowing = function()
    IsFollowing = false
    if followConnection then followConnection:Disconnect(); followConnection = nil end
    if followNoclipConn then followNoclipConn:Disconnect(); followNoclipConn = nil end
    if followBodyPos then followBodyPos:Destroy(); followBodyPos = nil end
    if followBodyGyro then followBodyGyro:Destroy(); followBodyGyro = nil end
    local char = lp.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false; hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true); hum:SetStateEnabled(Enum.HumanoidStateType.Running, true); hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end
