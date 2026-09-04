local MinecraftLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mamaksimaaa/Roblox-script/refs/heads/main/Lib/load.lua"))()

local Window = MinecraftLib:CreateWindow({
    Title = "IRY HUB",
    Theme = "Overworld",
    Size = {X = 570, Y = 370},
    ToggleKey = "LeftAlt",      -- клавиша показа/скрытия
    Transparency = 0.2,         -- не документировано, но оставлено
    Blurring = true,            -- не документировано, но оставлено
})

-- Остальной код без изменений (синтаксически корректен)
local a = game.Players.LocalPlayer
local b = game:GetService('Players')
local c = game:GetService('RunService')
local d = game:GetService('TweenService')
local e = game:GetService('ReplicatedStorage')
local f = false
local g = false
local h = false
local i = nil
local j = nil
local k = {}
local l = false
local m = 'Coin'
local n = false
local o = false
local p = nil

getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

local function setupCharacterCollision(q)
    local function disableCollide(r)
        if f and r:IsA('BasePart') then r.CanCollide = false end
    end
    for _, s in ipairs(q:GetChildren()) do disableCollide(s) end
    local r = q.ChildAdded:Connect(disableCollide)
    local s = c.Stepped:Connect(function()
        if f and q:IsDescendantOf(workspace) then
            for _, part in ipairs(q:GetChildren()) do
                if part:IsA('BasePart') and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
    q.Destroying:Connect(function()
        r:Disconnect()
        s:Disconnect()
    end)
end

local function trackPlayer(q)
    if q == a then return end
    q.CharacterAdded:Connect(setupCharacterCollision)
    if q.Character then setupCharacterCollision(q.Character) end
end

for _, plr in ipairs(b:GetPlayers()) do trackPlayer(plr) end
b.PlayerAdded:Connect(trackPlayer)

local function getPlayerRole()
    local getData = e:FindFirstChild('GetPlayerData', true)
    if not getData then return nil end
    local success, data = pcall(function() return getData:InvokeServer() end)
    if not success or not data then return nil end
    local roleData = data[a.Name]
    if roleData and roleData.Role then return roleData.Role end
    return nil
end

local function isMurderer()
    return getPlayerRole() == 'Murderer'
end

local function getPing()
    return game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()
end

local function findMurderer()
    local getData = e:FindFirstChild('GetPlayerData', true)
    if not getData then return nil end
    local success, data = pcall(function() return getData:InvokeServer() end)
    if not success or not data then return nil end
    for _, plr in ipairs(b:GetPlayers()) do
        if plr ~= a and plr:GetAttribute('Alive') == true then
            local info = data[plr.Name]
            if info and info.Role == 'Murderer' then
                return plr
            end
        end
    end
    return nil
end

local function shootMurderer()
    local gun = nil
    if a.Character and a.Character:FindFirstChild('Gun') then
        gun = a.Character.Gun
    elseif a.Backpack and a.Backpack:FindFirstChild('Gun') then
        gun = a.Backpack.Gun
        gun.Parent = a.Character
    end
    if not gun then return false end

    local murderer = findMurderer()
    if not murderer then return false end
    local char = murderer.Character
    if not char or not char:FindFirstChild('HumanoidRootPart') then return false end

    local rootPart = char.HumanoidRootPart
    local torso = char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
    local hum = char:FindFirstChild('Humanoid')
    if not torso or not hum then return false end
    if not a.Character or not a.Character:FindFirstChild('HumanoidRootPart') then return false end

    local myRoot = a.Character.HumanoidRootPart
    local ping = getPing()
    local delay = (ping / 1000) * 1.25
    local vel = rootPart.Velocity
    local speed = vel.Magnitude
    local targetPos = (speed < 1) and torso.Position or torso.Position + (vel * delay)

    local shootCF
    if ESP_CUSTOMIZATION.MagicBullet then
        shootCF = CFrame.new(torso.Position, targetPos)
    else
        shootCF = CFrame.new(myRoot.Position, targetPos)
    end

    local shootEvent = gun:FindFirstChild('ShootEvent') or gun:FindFirstChild('Shoot')
    if shootEvent then
        shootEvent:FireServer(shootCF, CFrame.new(targetPos))
        return true
    end
    return false
end

local function returncoincontainer()
    for _, child in pairs(workspace:GetChildren()) do
        if child:FindFirstChild('CoinContainer') and child:IsA('Model') then
            return child:FindFirstChild('CoinContainer')
        end
    end
    return nil
end

local function FindNearestCoin(container)
    if not container then return nil, math.huge end
    local nearest, dist = nil, math.huge
    for _, coin in pairs(container:GetChildren()) do
        if coin:GetAttribute('CoinID') == 'Coin' and coin:FindFirstChild('TouchInterest') and coin.Transparency == 1 then
            if a.Character and a.Character:FindFirstChild('HumanoidRootPart') then
                local d = (a.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                if d < dist then
                    nearest = coin
                    dist = d
                end
            end
        end
    end
    return nearest, dist
end

local function findmap()
    for _, child in pairs(workspace:GetChildren()) do
        if child:GetAttribute('MapID') then return child end
    end
    return nil
end

local function spawnItem(itemName)
    local success = pcall(function()
        local profile = require(e.Modules.ProfileData)
        local weapons = profile.Weapons
        local realName = itemName
        for _, v in ipairs(ITEM_LIST) do
            if v.custom == itemName then
                realName = v.original
                break
            end
        end
        if not weapons.Owned[realName] then
            weapons.Owned[realName] = 1
        else
            weapons.Owned[realName] = weapons.Owned[realName] + 1
        end
        profile.Weapons = weapons
        local remotes = e:FindFirstChild('Remotes')
        if remotes then
            local inv = remotes:FindFirstChild('Inventory')
            if inv then
                local change = inv:FindFirstChild('ChangeInventoryItem')
                if change then change:FireServer(realName, 'Add') end
                local dataChanged = inv:FindFirstChild('InventoryDataChanged')
                if dataChanged then dataChanged:Fire() end
            end
        end
    end)
    return success
end

local function SkidFling(targetPlr)
    local myChar = a.Character
    local hum = myChar and myChar:FindFirstChildOfClass('Humanoid')
    local rootPart = hum and hum.RootPart
    local targetChar = targetPlr.Character
    if not targetChar then return end

    local targetHum = targetChar:FindFirstChildOfClass('Humanoid')
    local targetRoot = targetHum and targetHum.RootPart
    local targetHead = targetChar:FindFirstChild('Head')
    local targetHandle = nil
    for _, acc in pairs(targetChar:GetChildren()) do
        if acc:IsA('Accessory') and acc:FindFirstChild('Handle') then
            targetHandle = acc.Handle
            break
        end
    end
    if not targetHandle then
        for _, acc in pairs(targetChar:GetChildren()) do
            if acc:IsA('Accessory') and acc:FindFirstChild('Handle') then
                targetHandle = acc.Handle
                break
            end
        end
    end

    if myChar and hum and rootPart then
        if rootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = rootPart.CFrame
        end
        if targetHum and targetHum.Sit then return end
        if targetHead then
            workspace.CurrentCamera.CameraSubject = targetHead
        elseif targetHandle then
            workspace.CurrentCamera.CameraSubject = targetHandle
        elseif targetHum and targetRoot then
            workspace.CurrentCamera.CameraSubject = targetHum
        end

        if not targetChar:FindFirstChildWhichIsA('BasePart') then return end

        local function applyForce(part, cframeOffset, angle)
            rootPart.CFrame = CFrame.new(part.Position) * cframeOffset * angle
            myChar:SetPrimaryPartCFrame(CFrame.new(part.Position) * cframeOffset * angle)
            rootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            rootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local function flingLoop(part)
            local count, startTime = 2, tick()
            repeat
                if rootPart and targetHum then
                    if part.Velocity.Magnitude < 50 then
                        count = count + 100
                        applyForce(part, CFrame.new(0, 1.5, 0) + targetHum.MoveDirection * part.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(count), 0, 0))
                        task.wait()
                        applyForce(part, CFrame.new(0, -1.5, 0) + targetHum.MoveDirection * part.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(count), 0, 0))
                        task.wait()
                        applyForce(part, CFrame.new(0, 1.5, 0) + targetHum.MoveDirection * part.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(count), 0, 0))
                        task.wait()
                        applyForce(part, CFrame.new(0, -1.5, 0) + targetHum.MoveDirection * part.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(count), 0, 0))
                        task.wait()
                        applyForce(part, CFrame.new(0, 1.5, 0) + targetHum.MoveDirection, CFrame.Angles(math.rad(count), 0, 0))
                        task.wait()
                        applyForce(part, CFrame.new(0, -1.5, 0) + targetHum.MoveDirection, CFrame.Angles(math.rad(count), 0, 0))
                        task.wait()
                    else
                        applyForce(part, CFrame.new(0, 1.5, targetHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        applyForce(part, CFrame.new(0, -1.5, -targetHum.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        applyForce(part, CFrame.new(0, 1.5, targetHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        applyForce(part, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        applyForce(part, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        applyForce(part, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        applyForce(part, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until startTime + 2 < tick() or not o
        end

        workspace.FallenPartsDestroyHeight = 0 / 0
        local bv = Instance.new('BodyVelocity')
        bv.Parent = rootPart
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if targetRoot then flingLoop(targetRoot)
        elseif targetHead then flingLoop(targetHead)
        elseif targetHandle then flingLoop(targetHandle)
        end

        bv:Destroy()
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = hum

        if getgenv().OldPos then
            repeat
                rootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
                myChar:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
                hum:ChangeState('GettingUp')
                for _, part in pairs(myChar:GetChildren()) do
                    if part:IsA('BasePart') then
                        part.Velocity = Vector3.new()
                        part.RotVelocity = Vector3.new()
                    end
                end
                task.wait()
            until (rootPart.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    end
end

local function FindPlayerByPartialName(name)
    if not name or name == '' then return nil end
    local lower = string.lower(name)
    for _, plr in pairs(b:GetPlayers()) do
        if plr ~= a and string.lower(plr.Name) == lower then return plr end
    end
    for _, plr in pairs(b:GetPlayers()) do
        if plr ~= a and string.sub(string.lower(plr.Name), 1, #lower) == lower then return plr end
    end
    for _, plr in pairs(b:GetPlayers()) do
        if plr ~= a and string.find(string.lower(plr.Name), lower, 1, true) then return plr end
    end
    return nil
end

local function getgun()
    pcall(function()
        if not g then return end
        if not a:GetAttribute('Alive') then return end
        if isMurderer() then return end
        local map = findmap()
        if not map then return end
        if map:FindFirstChild('GunDrop') then
            map.GunDrop.CFrame = a.Character.HumanoidRootPart.CFrame
        end
    end)
end

local function enableNoclip()
    if i then return end
    i = c.Stepped:Connect(function()
        if h and a.Character then
            for _, part in pairs(a.Character:GetDescendants()) do
                if part:IsA('BasePart') then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function startFarming()
    if not a.Character or not a.Character:FindFirstChild('HumanoidRootPart') then return end
    if a:GetAttribute('Alive') ~= true then return end
    local root = a.Character.HumanoidRootPart
    local hum = a.Character:FindFirstChild('Humanoid')
    k = {}
    for _, part in pairs(a.Character:GetDescendants()) do
        if part:IsA('BasePart') then
            k[part] = { CanCollide = part.CanCollide, Massless = part.Massless }
        end
    end
    root.CFrame = root.CFrame - Vector3.new(0, 2.5, 0)
    root.CFrame = root.CFrame * CFrame.Angles(math.rad(90), 0, 0)
    if hum then
        hum.PlatformStand = true
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
    l = true
end

local function stopFarming()
    l = false
    if j then j:Cancel(); j = nil end
    if i then i:Disconnect(); i = nil end
    if a.Character then
        for part, data in pairs(k) do
            if part and part.Parent then
                part.CanCollide = data.CanCollide
                part.Massless = data.Massless
            end
        end
        local root = a.Character:FindFirstChild('HumanoidRootPart')
        if root then
            root.Velocity = Vector3.new(0, 0, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
            root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
            root.CFrame = root.CFrame + Vector3.new(0, 2.5, 0)
        end
        local hum = a.Character:FindFirstChild('Humanoid')
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end
    k = {}
end

ESP_SETTINGS = { Murderer = false, Sheriff = false, Innocent = false, Hero = false }
NAME_ESP_SETTINGS = { Murderer = false, Sheriff = false, Innocent = false, Hero = false }
ESP_CUSTOMIZATION = {
    Box2D = false,
    DisplayName = false,
    NormalName = true,
    AvatarDisplay = false,
    MagicBullet = false,
}

local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff  = Color3.fromRGB(0, 0, 255),
    Hero     = Color3.fromRGB(255, 255, 0),
    Innocent = Color3.fromRGB(0, 255, 0),
}

local function CreateESP(plr, color)
    if not plr.Character then return end
    local hl = plr.Character:FindFirstChild('RoleESP')
    if not hl then
        hl = Instance.new('Highlight')
        hl.Name = 'RoleESP'
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Parent = plr.Character
    end
    hl.FillColor = color
    hl.OutlineColor = color
end

local function RemoveESP(plr)
    if plr.Character then
        local hl = plr.Character:FindFirstChild('RoleESP')
        if hl then hl:Destroy() end
    end
end

local function Create2DBox(plr, color)
    if not plr.Character then return end
    local root = plr.Character:FindFirstChild('HumanoidRootPart')
    if not root then return end
    local box = root:FindFirstChild('Box2D')
    if ESP_CUSTOMIZATION.Box2D then
        if not box then
            box = Instance.new('BillboardGui')
            box.Name = 'Box2D'
            box.AlwaysOnTop = true
            box.Size = UDim2.new(4, 0, 5, 0)
            box.StudsOffset = Vector3.new(0, 0, 0)
            box.Parent = root
            local frame = Instance.new('Frame')
            frame.Name = 'BoxFrame'
            frame.BackgroundTransparency = 1
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BorderSizePixel = 2
            frame.Parent = box
            local stroke = Instance.new('UIStroke')
            stroke.Name = 'Stroke'
            stroke.Thickness = 2
            stroke.Parent = frame
        end
        local frame = box:FindFirstChild('BoxFrame')
        if frame then
            local stroke = frame:FindFirstChild('Stroke')
            if stroke then stroke.Color = color end
        end
    else
        if box then box:Destroy() end
    end
end

local function CreateNameESP(plr, color)
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild('Head')
    local root = plr.Character:FindFirstChild('HumanoidRootPart')
    if not head or not root then return end

    local gui = head:FindFirstChild('NameESP')
    if not gui then
        gui = Instance.new('BillboardGui')
        gui.Name = 'NameESP'
        gui.AlwaysOnTop = true
        gui.Size = UDim2.new(0, 200, 0, 80)
        gui.StudsOffset = Vector3.new(0, 2, 0)
        gui.Parent = head

        local avatarFrame = Instance.new('Frame')
        avatarFrame.Name = 'AvatarFrame'
        avatarFrame.BackgroundColor3 = Color3.new(1, 1, 1)
        avatarFrame.Size = UDim2.new(0, 40, 0, 40)
        avatarFrame.Position = UDim2.new(0.5, -20, 0, 0)
        avatarFrame.BorderSizePixel = 2
        avatarFrame.Parent = gui
        local corner = Instance.new('UICorner')
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = avatarFrame

        local avatar = Instance.new('ImageLabel')
        avatar.Name = 'Avatar'
        avatar.BackgroundTransparency = 1
        avatar.Size = UDim2.new(1, 0, 1, 0)
        avatar.Image = b:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        avatar.Parent = avatarFrame
        local corner2 = Instance.new('UICorner')
        corner2.CornerRadius = UDim.new(1, 0)
        corner2.Parent = avatar

        local nameLabel = Instance.new('TextLabel')
        nameLabel.Name = 'NameLabel'
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 1, -20)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Parent = gui
    end

    local avatarFrame = gui:FindFirstChild('AvatarFrame')
    local nameLabel = gui:FindFirstChild('NameLabel')
    if nameLabel then
        if ESP_CUSTOMIZATION.DisplayName then
            nameLabel.Text = plr.DisplayName
        elseif ESP_CUSTOMIZATION.NormalName then
            nameLabel.Text = plr.Name
        else
            nameLabel.Text = ''
        end
        nameLabel.TextColor3 = color
    end
    if avatarFrame then
        avatarFrame.Visible = ESP_CUSTOMIZATION.AvatarDisplay
        avatarFrame.BorderColor3 = color
    end
    Create2DBox(plr, color)
end

local function RemoveNameESP(plr)
    if plr.Character then
        local head = plr.Character:FindFirstChild('Head')
        if head then
            local gui = head:FindFirstChild('NameESP')
            if gui then gui:Destroy() end
        end
        local root = plr.Character:FindFirstChild('HumanoidRootPart')
        if root then
            local box = root:FindFirstChild('Box2D')
            if box then box:Destroy() end
        end
    end
end

local function UpdateESP()
    local getData = e:FindFirstChild('GetPlayerData', true)
    if not getData then return end
    local success, data = pcall(function() return getData:InvokeServer() end)
    if not success then return end
    for _, plr in ipairs(b:GetPlayers()) do
        if plr ~= a and plr:GetAttribute('Alive') == true then
            local role = 'Innocent'
            local info = data[plr.Name]
            if info and info.Role then role = info.Role end
            local color = ROLE_COLORS[role] or ROLE_COLORS.Innocent
            if ESP_SETTINGS[role] == true then
                CreateESP(plr, color)
            else
                RemoveESP(plr)
            end
            if NAME_ESP_SETTINGS[role] == true then
                CreateNameESP(plr, color)
            else
                RemoveNameESP(plr)
            end
        else
            RemoveESP(plr)
            RemoveNameESP(plr)
        end
    end
end

local customWalkSpeedEnabled = false
local customJumpPowerEnabled = false
local walkSpeedValue = 16
local jumpPowerValue = 50
local customFOVEnabled = false
local fovValue = 70
local forceFieldEnabled = false
local autoDanceEnabled = false
local currentDanceId = '127118661424463'
local danceAnim = nil

local DANCE_IDS = {
    ['Dance 1'] = '127118661424463',
    ['Dance 2'] = '82682811348660',
    ['Dance 3'] = '10714340543',
    ['Dance 4'] = '15609995579',
}

local function applyWalkSpeed()
    if customWalkSpeedEnabled and a.Character then
        local hum = a.Character:FindFirstChildOfClass('Humanoid')
        if hum then hum.WalkSpeed = walkSpeedValue end
    end
end

local function applyJumpPower()
    if customJumpPowerEnabled and a.Character then
        local hum = a.Character:FindFirstChildOfClass('Humanoid')
        if hum then hum.JumpPower = jumpPowerValue end
    end
end

local function applyFOV()
    if customFOVEnabled then
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = fovValue end
    end
end

local function applyForceFieldMaterial()
    if not forceFieldEnabled then return end
    if not a.Character then return end
    for _, part in pairs(a.Character:GetDescendants()) do
        if part:IsA('BasePart') or part:IsA('MeshPart') then
            part.Material = Enum.Material.ForceField
        end
    end
end

local function playDance()
    if not a.Character then return end
    local hum = a.Character:FindFirstChildOfClass('Humanoid')
    if not hum then return end
    local animator = hum:FindFirstChildOfClass('Animator')
    if not animator then
        animator = Instance.new('Animator')
        animator.Parent = hum
    end
    if danceAnim then
        pcall(function() danceAnim:Stop() end)
        pcall(function() danceAnim:Destroy() end)
        danceAnim = nil
    end
    task.wait(0.1)
    local anim = Instance.new('Animation')
    anim.AnimationId = 'rbxassetid://' .. tostring(currentDanceId)
    pcall(function()
        danceAnim = animator:LoadAnimation(anim)
        danceAnim.Looped = true
        danceAnim.Priority = Enum.AnimationPriority.Action
        danceAnim:Play(0.1, 1, 1)
    end)
    anim:Destroy()
end

local function stopDance()
    if danceAnim then
        pcall(function() danceAnim:Stop(); danceAnim:Destroy() end)
        danceAnim = nil
    end
end

local coinCollected = e.Remotes.Gameplay.CoinCollected
coinCollected.OnClientEvent:Connect(function(plr, id1, id2)
    if plr == m then
        if tonumber(id1) == tonumber(id2) then
            n = true
            if l then stopFarming() end
        else
            n = false
        end
    end
end)

local roundStart = e.Remotes.Gameplay.RoundStart
local roundEnd = e.Remotes.Gameplay.RoundEndFade
roundStart.OnClientEvent:Connect(function() n = false end)
roundEnd.OnClientEvent:Connect(function()
    n = false
    if l then stopFarming() end
end)

task.spawn(function()
    while true do
        c.Heartbeat:Wait()
        if l and a.Character and a.Character:FindFirstChild('HumanoidRootPart') and a:GetAttribute('Alive') == true then
            local root = a.Character.HumanoidRootPart
            local container = returncoincontainer()
            if container then
                for _, coin in pairs(container:GetChildren()) do
                    if coin:GetAttribute('CoinID') == 'Coin' and coin:FindFirstChild('TouchInterest') and coin.Transparency == 1 then
                        local dist = (root.Position - coin.Position).Magnitude
                        if dist <= 5 then
                            firetouchinterest(root, coin, 0)
                            firetouchinterest(root, coin, 1)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        c.Heartbeat:Wait()
        if h and not n and a:GetAttribute('Alive') == true and a.Character and a.Character:FindFirstChild('HumanoidRootPart') then
            local container = returncoincontainer()
            if container then
                local nearestCoin, dist = FindNearestCoin(container)
                if nearestCoin and nearestCoin.Transparency == 1 and not n then
                    if not l then startFarming() end
                    local root = a.Character.HumanoidRootPart
                    local hum = a.Character:FindFirstChild('Humanoid')
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                    local targetPos = nearestCoin.Position - Vector3.new(0, 2.5, 0)
                    local targetCF = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, 0)
                    enableNoclip()
                    local tweenInfo = TweenInfo.new(dist / 23, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    j = d:Create(root, tweenInfo, { CFrame = targetCF })
                    j:Play()
                    local heartbeatConn
                    heartbeatConn = c.Heartbeat:Connect(function()
                        if h and a:GetAttribute('Alive') == true and root then
                            root.Velocity = Vector3.new(0, 0, 0)
                            root.RotVelocity = Vector3.new(0, 0, 0)
                            if hum then hum.PlatformStand = true end
                        else
                            if heartbeatConn then heartbeatConn:Disconnect() end
                        end
                    end)
                    while nearestCoin and nearestCoin:FindFirstChild('TouchInterest') and nearestCoin.Transparency == 1 and not n and h and a:GetAttribute('Alive') == true do
                        c.Heartbeat:Wait()
                    end
                    if heartbeatConn then heartbeatConn:Disconnect() end
                    if j then j:Cancel() end
                    if root then
                        root.Velocity = Vector3.new(0, 0, 0)
                        root.RotVelocity = Vector3.new(0, 0, 0)
                    end
                else
                    if l then stopFarming() end
                end
            else
                if l then stopFarming() end
            end
        else
            if l then stopFarming() end
        end
    end
end)

task.spawn(function()
    while true do
        c.Heartbeat:Wait()
        UpdateESP()
        getgun()
    end
end)

b.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() UpdateESP() end)
end)

local MainTab = Window:AddTab("Main")

MainTab:AddLabel("=== Murder Functions ===")

local autoKillAll = false
MainTab:AddToggle("Auto Kill All", false, function(state)
    autoKillAll = state
end)

MainTab:AddButton("Kill All", function()
    if not a then return end
    local char = a.Character
    if not char or not char.Parent then return end
    local knife = char:FindFirstChild('Knife')
    if not knife then
        knife = a.Backpack:FindFirstChild('Knife')
        if knife then knife.Parent = char
        else
            Window:Notify("Error", "You need to be the murderer!", 3)
            return
        end
    end
    for _, plr in pairs(b:GetPlayers()) do
        if plr ~= a and plr.Character and plr.Character:FindFirstChild('Head') then
            pcall(function()
                knife.Events.KnifeStabbed:FireServer()
                knife.Events.HandleTouched:FireServer(plr.Character.Head)
            end)
            task.wait(0.05)
        end
    end
    Window:Notify("Kill All", "Attempted to kill all players", 2)
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if autoKillAll and a and a.Character then
            local knife = a.Character:FindFirstChild('Knife') or a.Backpack:FindFirstChild('Knife')
            if knife then
                if knife.Parent == a.Backpack then knife.Parent = a.Character end
                for _, plr in pairs(b:GetPlayers()) do
                    if plr ~= a and plr.Character and plr.Character:FindFirstChild('Head') then
                        pcall(function()
                            knife.Events.KnifeStabbed:FireServer()
                            knife.Events.HandleTouched:FireServer(plr.Character.Head)
                        end)
                        task.wait(0.05)
                    end
                end
            end
        end
    end
end)

MainTab:AddSeparator()
MainTab:AddLabel("=== Sheriff Functions ===")

local autoShoot = false
MainTab:AddToggle("Auto Shoot Murderer", false, function(state)
    autoShoot = state
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if autoShoot then shootMurderer() end
    end
end)

local showShootButton = false
local shootButtonGui = nil
MainTab:AddToggle("Shoot Button", false, function(state)
    showShootButton = state
    if state then
        if not shootButtonGui then
            local sg = Instance.new('ScreenGui')
            sg.Name = 'ShootButtonGui'
            sg.ResetOnSpawn = false
            sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            sg.Parent = game:GetService('CoreGui')
            local btn = Instance.new('ImageButton')
            btn.Name = 'ShootButton'
            btn.Size = UDim2.new(0, 80, 0, 80)
            btn.Position = UDim2.new(0.5, -40, 0.5, -40)
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            btn.BackgroundTransparency = 0.3
            btn.BorderSizePixel = 0
            btn.Parent = sg
            local corner = Instance.new('UICorner')
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = btn
            local label = Instance.new('TextLabel')
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = '🔫'
            label.TextSize = 32
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.Font = Enum.Font.GothamBold
            label.Parent = btn
            local dragging, dragInput, dragStart, startPos
            btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = btn.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)
            btn.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if dragging then
                        local delta = input.Position - dragStart
                        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                end
            end)
            btn.MouseButton1Click:Connect(function()
                if not dragging then shootMurderer() end
            end)
            shootButtonGui = sg
        end
    else
        if shootButtonGui then
            shootButtonGui:Destroy()
            shootButtonGui = nil
        end
    end
end)

MainTab:AddToggle("Magic Bullet", false, function(state)
    ESP_CUSTOMIZATION.MagicBullet = state
end)

MainTab:AddSeparator()
MainTab:AddLabel("=== Innocent Functions ===")

MainTab:AddToggle("Auto Grab Gun", false, function(state)
    g = state
end)

MainTab:AddSeparator()
MainTab:AddLabel("=== Auto Farm ===")

MainTab:AddToggle("Farm Coins", false, function(state)
    h = state
    if not state then
        if l then stopFarming() end
    end
end)

local VisualsTab = Window:AddTab("Visuals")

VisualsTab:AddLabel("=== Chams ===")
VisualsTab:AddToggle("Murderer", false, function(state) ESP_SETTINGS.Murderer = state end)
VisualsTab:AddToggle("Sheriff", false, function(state) ESP_SETTINGS.Sheriff = state end)
VisualsTab:AddToggle("Innocent", false, function(state) ESP_SETTINGS.Innocent = state end)
VisualsTab:AddToggle("Hero", false, function(state) ESP_SETTINGS.Hero = state end)

VisualsTab:AddSeparator()
VisualsTab:AddLabel("=== ESP ===")
VisualsTab:AddToggle("Murderer", false, function(state) NAME_ESP_SETTINGS.Murderer = state end)
VisualsTab:AddToggle("Sheriff", false, function(state) NAME_ESP_SETTINGS.Sheriff = state end)
VisualsTab:AddToggle("Innocent", false, function(state) NAME_ESP_SETTINGS.Innocent = state end)
VisualsTab:AddToggle("Hero", false, function(state) NAME_ESP_SETTINGS.Hero = state end)

VisualsTab:AddSeparator()
VisualsTab:AddLabel("=== ESP Customization ===")
VisualsTab:AddToggle("2D Box", false, function(state) ESP_CUSTOMIZATION.Box2D = state end)
VisualsTab:AddToggle("Display Name", false, function(state)
    ESP_CUSTOMIZATION.DisplayName = state
    if state then ESP_CUSTOMIZATION.NormalName = false end
end)
VisualsTab:AddToggle("Normal Name", true, function(state)
    ESP_CUSTOMIZATION.NormalName = state
    if state then ESP_CUSTOMIZATION.DisplayName = false end
end)
VisualsTab:AddToggle("Avatar Display", false, function(state) ESP_CUSTOMIZATION.AvatarDisplay = state end)

local MiscTab = Window:AddTab("Misc")

MiscTab:AddToggle("Anti-Fling", false, function(state) f = state end)

MiscTab:AddSeparator()
MiscTab:AddLabel("=== Character Modifiers ===")
MiscTab:AddToggle("Custom WalkSpeed", false, function(state)
    customWalkSpeedEnabled = state
    if state then applyWalkSpeed()
    else
        if a.Character then
            local hum = a.Character:FindFirstChildOfClass('Humanoid')
            if hum then hum.WalkSpeed = 16 end
        end
    end
end)
MiscTab:AddSlider("WalkSpeed Value", 16, 200, 16, function(val)
    walkSpeedValue = val
    if customWalkSpeedEnabled then applyWalkSpeed() end
end)

MiscTab:AddToggle("Custom JumpPower", false, function(state)
    customJumpPowerEnabled = state
    if state then applyJumpPower()
    else
        if a.Character then
            local hum = a.Character:FindFirstChildOfClass('Humanoid')
            if hum then hum.JumpPower = 50 end
        end
    end
end)
MiscTab:AddSlider("JumpPower Value", 50, 200, 50, function(val)
    jumpPowerValue = val
    if customJumpPowerEnabled then applyJumpPower() end
end)

MiscTab:AddSeparator()
MiscTab:AddLabel("=== Camera Settings ===")
MiscTab:AddToggle("Custom FOV", false, function(state)
    customFOVEnabled = state
    if state then applyFOV()
    else
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = 70 end
    end
end)
MiscTab:AddSlider("FOV Value", 70, 120, 70, function(val)
    fovValue = val
    if customFOVEnabled then applyFOV() end
end)

MiscTab:AddSeparator()
MiscTab:AddLabel("=== Body Material ===")
MiscTab:AddToggle("Force Field Body", false, function(state)
    forceFieldEnabled = state
    if state then
        applyForceFieldMaterial()
        Window:Notify("ForceField", "Material changed", 2)
    else
        if a.Character then
            for _, part in pairs(a.Character:GetDescendants()) do
                if part:IsA('BasePart') or part:IsA('MeshPart') then
                    part.Material = Enum.Material.Plastic
                end
            end
        end
        Window:Notify("ForceField", "Material restored", 2)
    end
end)

MiscTab:AddSeparator()
MiscTab:AddLabel("=== Dances ===")
local danceOptions = {}
for k, _ in pairs(DANCE_IDS) do danceOptions[k] = k end
MiscTab:AddDropdown("Select Dance", danceOptions, function(selected)
    currentDanceId = DANCE_IDS[selected]
    if autoDanceEnabled then
        stopDance()
        task.wait(0.2)
        playDance()
        Window:Notify("Dance", "Changed", 2)
    end
end)
MiscTab:AddToggle("Auto Dance", false, function(state)
    autoDanceEnabled = state
    if state then
        playDance()
        Window:Notify("Dance", "Started", 2)
    else
        stopDance()
        Window:Notify("Dance", "Stopped", 2)
    end
end)
a.CharacterAdded:Connect(function(char)
    char:WaitForChild('Humanoid')
    task.wait(0.5)
    if autoDanceEnabled then playDance() end
end)

MiscTab:AddSeparator()
MiscTab:AddLabel("=== Player Fling ===")
local flingTargetName = ''
MiscTab:AddTextbox("Player Name", "Enter name...", function(text)
    local found = FindPlayerByPartialName(text)
    if found then
        p = found
        Window:Notify("Found", "Selected: " .. found.Name, 2)
    else
        p = nil
        if text ~= '' then
            Window:Notify("Not Found", "Player not found", 2)
        end
    end
end)

MiscTab:AddButton("Fling Murderer", function()
    if o then return end
    local murderer = findMurderer()
    if murderer then
        o = true
        Window:Notify("Fling", "Flinging murderer", 3)
        task.spawn(function()
            SkidFling(murderer)
            o = false
        end)
    else
        Window:Notify("Fling", "Murderer not found", 2)
    end
end)

MiscTab:AddButton("Fling Sheriff", function()
    if o then return end
    local getData = e:FindFirstChild('GetPlayerData', true)
    if not getData then return end
    local success, data = pcall(function() return getData:InvokeServer() end)
    if success and data then
        for _, plr in pairs(b:GetPlayers()) do
            if plr ~= a and plr:GetAttribute('Alive') == true then
                local info = data[plr.Name]
                if info and info.Role == 'Sheriff' then
                    o = true
                    Window:Notify("Fling", "Flinging sheriff", 3)
                    task.spawn(function()
                        SkidFling(plr)
                        o = false
                    end)
                    return
                end
            end
        end
    end
    Window:Notify("Fling", "Sheriff not found", 2)
end)

MiscTab:AddButton("Fling Selected", function()
    if o then return end
    if not p or not p.Parent then
        Window:Notify("Error", "Select a player first", 2)
        return
    end
    o = true
    Window:Notify("Fling", "Flinging " .. p.Name, 3)
    task.spawn(function()
        SkidFling(p)
        o = false
    end)
end)

MiscTab:AddButton("Stop Fling", function()
    if o then
        o = false
        Window:Notify("Fling", "Stopped", 2)
    else
        Window:Notify("Fling", "No active fling", 2)
    end
end)

MiscTab:AddSeparator()
MiscTab:AddLabel("=== Teleports ===")
MiscTab:AddButton("Map TP", function()
    if not a.Character then return end
    local map = findmap()
    if map and map:FindFirstChild('Spawns') then
        for _, spawn in pairs(map.Spawns:GetChildren()) do
            a.Character.HumanoidRootPart.CFrame = spawn.CFrame
            return
        end
    end
end)
MiscTab:AddButton("Lobby TP", function()
    if not a.Character then return end
    if workspace:FindFirstChild('Lobby') and workspace.Lobby:FindFirstChild('Spawns') then
        for _, spawn in pairs(workspace.Lobby.Spawns:GetChildren()) do
            a.Character.HumanoidRootPart.CFrame = spawn.CFrame
            return
        end
    end
end)
MiscTab:AddButton("Murderer TP", function()
    if not a.Character then return end
    local murderer = findMurderer()
    if murderer and murderer.Character then
        a.Character.HumanoidRootPart.CFrame = murderer.Character.HumanoidRootPart.CFrame
    end
end)
MiscTab:AddButton("Sheriff TP", function()
    if not a.Character then return end
    local getData = e:FindFirstChild('GetPlayerData', true)
    if not getData then return end
    local success, data = pcall(function() return getData:InvokeServer() end)
    if success and data then
        for _, plr in pairs(b:GetPlayers()) do
            if plr ~= a and plr:GetAttribute('Alive') == true then
                local info = data[plr.Name]
                if info and info.Role == 'Sheriff' and plr.Character then
                    a.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                    return
                end
            end
        end
    end
end)

local SpawnerTab = Window:AddTab("Spawner")

local ITEM_LIST = {
    { original = 'Harvester', custom = 'Harvester' },
    { original = 'Gingerscope', custom = 'Gingerscope' },
    { original = 'Snowcannon', custom = 'Snowcannon' },
    { original = 'Bauble', custom = 'Bauble' },
    { original = 'BaubleChroma', custom = 'BaubleChroma' },
    { original = 'Icepiercer', custom = 'Icepiercer' },
    { original = 'TreeGun2023', custom = 'Evergun' },
    { original = 'TreeKnife2023', custom = 'Evergreen' },
    { original = 'TreeGun2023Chroma', custom = 'Chroma Evergun' },
    { original = 'TreeKnife2023Chroma', custom = 'Chroma Evergreen' },
    { original = 'Bloom', custom = 'Bloom' },
    { original = 'Flora', custom = 'Flora' },
    { original = 'TravelerAxe', custom = 'Traveler Axe' },
    { original = 'TravelerGun', custom = 'Traveler Gun' },
    { original = 'TravelerAxeChroma', custom = 'Chroma Traveler Axe' },
    { original = 'TravelerGunChroma', custom = 'Chroma Traveler Gun' },
    { original = 'Celestial', custom = 'Celestial' },
    { original = 'Constellation', custom = 'Constellation' },
    { original = 'ConstellationChroma', custom = 'Chroma Constellation' },
    { original = 'Candy', custom = 'Candy' },
    { original = 'Sugar', custom = 'Sugar' },
    { original = 'Darksword', custom = 'Darksword' },
    { original = 'Darkshot', custom = 'Darkshot' },
    { original = 'VampireAxe', custom = 'Vampire Axe' },
    { original = 'VampireGun', custom = 'Vampire Gun' },
    { original = 'SwirlyAxe', custom = 'Swirly Axe' },
    { original = 'SwirlyGun', custom = 'Swirly Gun' },
    { original = 'Flowerwood', custom = 'Flowerwood' },
    { original = 'FlowerwoodGun', custom = 'Flowerwood Gun' },
    { original = 'VampireGunChroma', custom = 'Chroma Vampire Gun' },
    { original = 'WatergunChroma', custom = 'Chroma Watergun' },
    { original = 'Turkey2023', custom = 'Turkey' },
    { original = 'Sakura_K', custom = 'Sakura' },
    { original = 'Blossom_G', custom = 'Blossom' },
    { original = 'Makeshift', custom = 'Makeshift' },
    { original = 'Sorry', custom = 'Corrupt' },
    { original = 'HeartWand', custom = 'HeartWand' },
}

local spawnOptions = {}
for _, item in ipairs(ITEM_LIST) do
    spawnOptions[item.custom] = item.custom
end

local selectedItem = nil
SpawnerTab:AddLabel("=== Select Item ===")
SpawnerTab:AddDropdown("Item", spawnOptions, function(choice)
    selectedItem = choice
end)
SpawnerTab:AddButton("Spawn Selected", function()
    if not selectedItem then
        Window:Notify("Error", "Select an item", 2)
        return
    end
    local success = spawnItem(selectedItem)
    if success then
        Window:Notify("Spawn", selectedItem .. " added", 3)
    else
        Window:Notify("Error", "Failed to spawn", 2)
    end
end)

SpawnerTab:AddSeparator()
SpawnerTab:AddLabel("=== Quick Spawn ===")
local quickItems = { 'Harvester', 'Corrupt', 'Chroma Evergun', 'Chroma Evergreen' }
for _, item in ipairs(quickItems) do
    SpawnerTab:AddButton("Spawn " .. item, function()
        if spawnItem(item) then
            Window:Notify("Spawn", item .. " added", 2)
        else
            Window:Notify("Error", "Failed to spawn " .. item, 2)
        end
    end)
end

local SettingsTab = Window:AddTab("Settings")

SettingsTab:AddLabel("=== Theme ===")
SettingsTab:AddDropdown("Select Theme", { ["Overworld"] = "Overworld", ["Nether"] = "Nether", ["End"] = "End" }, function(theme)
    Window:SetTheme(theme)
end)

Window:Notify("IRY HUB", "Loaded! Press LeftAlt to toggle.", 5)
print("[IRY HUB] Script loaded")
