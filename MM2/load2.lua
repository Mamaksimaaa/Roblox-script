-- ============================================================
--   MM2 Panel на MinecraftLib v3.5
--   ESP • Speed • Coins • Auto Gun • Auto Kill • China Hat
-- ============================================================
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local player             = Players.LocalPlayer

-- Firebase RTDB key gate. Проверка выполняется до запуска панели.
local HttpService = game:GetService("HttpService")
local KEY_DB = "https://key-base-9715e-default-rtdb.firebaseio.com/keys/"
local playerGui = player:WaitForChild("PlayerGui")
local oldGate = playerGui:FindFirstChild("BasaltMM2KeyGate")
if oldGate then oldGate:Destroy() end

local gate = Instance.new("ScreenGui")
gate.Name = "BasaltMM2KeyGate"
gate.ResetOnSpawn = false
gate.IgnoreGuiInset = true
gate.DisplayOrder = 1000
gate.Parent = playerGui

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
backdrop.BackgroundTransparency = 0.25
backdrop.Parent = gate

local card = Instance.new("Frame")
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.5)
card.Size = UDim2.new(0.9, 0, 0, 224)
card.ClipsDescendants = true
card.BackgroundColor3 = Color3.fromRGB(28, 31, 40)
card.Parent = backdrop
local maxSize = Instance.new("UISizeConstraint")
maxSize.MaxSize = Vector2.new(370, 224)
maxSize.Parent = card
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = card

local function label(text, y, height, size)
    local item = Instance.new("TextLabel")
    item.Position = UDim2.new(0, 16, 0, y)
    item.Size = UDim2.new(1, -32, 0, height)
    item.BackgroundTransparency = 1
    item.TextColor3 = Color3.fromRGB(240, 240, 245)
    item.Font = Enum.Font.Gotham
    item.TextSize = size
    item.TextWrapped = true
    item.Text = text
    item.Parent = card
    return item
end
local title = label("MM2 • Проверка ключа", 12, 32, 20)
title.Font = Enum.Font.GothamBold
local status = label("Введите ключ Firebase для запуска панели", 48, 36, 13)

local input = Instance.new("TextBox")
input.Position = UDim2.new(0, 16, 0, 91)
input.Size = UDim2.new(1, -32, 0, 39)
input.BackgroundColor3 = Color3.fromRGB(42, 46, 58)
input.TextColor3 = Color3.new(1, 1, 1)
input.PlaceholderColor3 = Color3.fromRGB(160, 165, 175)
input.PlaceholderText = "KEY-XXXXXXXX"
input.Text = ""
input.ClearTextOnFocus = false
input.Font = Enum.Font.Gotham
input.TextSize = 16
input.Parent = card
local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 7)
inputCorner.Parent = input

local check = Instance.new("TextButton")
check.Position = UDim2.new(0, 16, 0, 140)
check.Size = UDim2.new(1, -32, 0, 38)
check.BackgroundColor3 = Color3.fromRGB(46, 148, 110)
check.TextColor3 = Color3.new(1, 1, 1)
check.Text = "Проверить ключ"
check.Font = Enum.Font.GothamBold
check.TextSize = 15
check.Parent = card
local checkCorner = Instance.new("UICorner")
checkCorner.CornerRadius = UDim.new(0, 7)
checkCorner.Parent = check

local cancel = Instance.new("TextButton")
cancel.Position = UDim2.new(0, 16, 0, 185)
cancel.Size = UDim2.new(1, -32, 0, 27)
cancel.BackgroundTransparency = 1
cancel.TextColor3 = Color3.fromRGB(190, 195, 205)
cancel.Text = "Отмена"
cancel.Font = Enum.Font.Gotham
cancel.TextSize = 13
cancel.Parent = card

local approved, busy = false, false
local function verify()
    if busy or not gate.Parent then return end
    local key = input.Text:match("^%s*(.-)%s*$")
    if #key < 1 or #key > 128 or not key:match("^[%w_%-]+$") then
        status.Text = "Введите корректный ключ (буквы, цифры, - или _)"
        return
    end
    busy = true
    check.Text = "Проверка..."
    status.Text = "Соединение с Firebase..."
    task.spawn(function()
        local ok, result = pcall(function()
            local url = KEY_DB .. HttpService:UrlEncode(key) .. ".json"
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if not gate.Parent then return end
        if ok and result == true then
            approved = true
            gate:Destroy()
        else
            status.Text = ok and "Ключ не найден или отключён" or "Ошибка сети/Firebase. Попробуйте позже"
            check.Text = "Проверить ключ"
            busy = false
        end
    end)
end
check.MouseButton1Click:Connect(verify)
input.FocusLost:Connect(function(enterPressed)
    if enterPressed then verify() end
end)
cancel.MouseButton1Click:Connect(function() gate:Destroy() end)
while gate.Parent and not approved do task.wait(0.1) end
if not approved then return end

-- Чистим предыдущий запуск, если был
local previousCleanup = getgenv().BasaltMM2Cleanup
if type(previousCleanup) == "function" then previousCleanup() end

-- ============================================================
-- Загрузка библиотеки + окно
-- ============================================================
local MinecraftLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Mamaksimaaa/Roblox-script/refs/heads/main/Lib/load.lua"
))()

local Window = MinecraftLib:CreateWindow({
    Title        = "MM2 Panel",
    Theme        = "Nether",
    ToggleKey    = "RightShift",
    Size         = {X = 480, Y = 420},
    ConfigFolder = "BasaltMM2",
    AutoSave     = false,
    AutoLoad     = false,
    Scale        = 1.0,
})

Window:SetWatermark(true, "MM2 • Basalt")

-- ============================================================
-- Константы China Hat
-- ============================================================
local HAT_STYLES      = {"Wireframe", "Web", "Rings", "Spiral", "Solid", "Halo", "Diamond", "Fan", "Crown", "Orbit", "Starburst", "DoubleCone"}
local HAT_COLOR_MODES = {"Teal", "Pink", "Purple", "Gradient", "Rainbow", "Wave", "Pulse"}
local HAT_SIZE_LABELS = {"0.75x", "1x", "1.25x", "1.5x"}
local HAT_SPEED_LABELS= {"0.5x", "1x", "2x", "3x"}
local HAT_SIZE_MAP    = {["0.75x"]=0.75, ["1x"]=1, ["1.25x"]=1.25, ["1.5x"]=1.5}
local HAT_SPEED_MAP   = {["0.5x"]=0.5,  ["1x"]=1, ["2x"]=2, ["3x"]=3}

local HAT_STATIC = {
    Teal   = Color3.fromRGB(0, 255, 170),
    Pink   = Color3.fromRGB(255, 90, 200),
    Purple = Color3.fromRGB(150, 90, 255),
}
local HAT_ANIMATED = {Gradient = true, Rainbow = true, Wave = true, Pulse = true}
local HAT_GRADIENT_A = Color3.fromRGB(0, 255, 170)
local HAT_GRADIENT_B = Color3.fromRGB(150, 80, 255)

local HAT_RADIUS = 1.75
local HAT_HEIGHT = 0.85
local HAT_LIFT   = 0.15

local hatEnabled   = false
local hatStyle     = "Wireframe"
local hatColorMode = "Teal"
local hatSize      = 1
local hatSpeed     = 1
local hatModel
local hatItems     = {}
local hatElapsed   = 0

-- ============================================================
-- Утилиты
-- ============================================================
local function hatColorAt(t, angle, now)
    local static = HAT_STATIC[hatColorMode]
    if static ~= nil then return static end

    if hatColorMode == "Gradient" then
        local k = 0.5 + 0.5 * math.sin(now * hatSpeed * 1.5 - t * 3)
        return HAT_GRADIENT_A:Lerp(HAT_GRADIENT_B, k)
    elseif hatColorMode == "Rainbow" then
        return Color3.fromHSV((now * 0.2 * hatSpeed + t * 0.25) % 1, 0.85, 1)
    elseif hatColorMode == "Wave" then
        return Color3.fromHSV((angle / (math.pi * 2) + now * 0.25 * hatSpeed) % 1, 0.85, 1)
    end
    local v = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(now * 3 * hatSpeed))
    return Color3.fromHSV(0.447, 1, v)
end

local function applyHatColors(now)
    for _, item in hatItems do
        local c0 = hatColorAt(item.t0, item.a0, now)
        if item.beam ~= nil then
            item.beam.Color = ColorSequence.new(c0, hatColorAt(item.t1, item.a1, now))
        elseif item.part ~= nil then
            item.part.Color = c0
        end
    end
end

local function removeHat()
    if hatModel ~= nil then
        hatModel:Destroy()
        hatModel = nil
    end
    table.clear(hatItems)
end

local function addHat(character)
    removeHat()
    if not hatEnabled or character == nil then return end

    local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
    if head == nil or not hatEnabled or player.Character ~= character then return end

    local radius = HAT_RADIUS * hatSize
    local height = HAT_HEIGHT * hatSize

    local model = Instance.new("Model")
    model.Name = "BasaltChinaHat"
    model.Parent = character
    hatModel = model

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(0.2, 0.2, 0.2)
    base.Transparency = 1
    base.CanCollide = false
    base.CanTouch = false
    base.CanQuery = false
    base.Massless = true
    base.CFrame = head.CFrame * CFrame.new(0, head.Size.Y / 2 + HAT_LIFT, 0)
    base.Parent = model

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = head
    weld.Part1 = base
    weld.Parent = base

    local function attachmentAt(t, angle)
        local a = Instance.new("Attachment")
        a.Position = Vector3.new(
            math.cos(angle) * radius * t,
            height * (1 - t),
            math.sin(angle) * radius * t
        )
        a.Parent = base
        return a
    end

    local apex = attachmentAt(0, 0)

    local function addLine(a0, a1, t0, t1, angle0, angle1)
        local beam = Instance.new("Beam")
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.Transparency = NumberSequence.new(0)
        beam.LightEmission = 1
        beam.FaceCamera = true
        beam.Segments = 1
        beam.Width0 = 0.035
        beam.Width1 = 0.035
        beam.Parent = base
        table.insert(hatItems, {beam = beam, t0 = t0, t1 = t1, a0 = angle0, a1 = angle1})
    end

    local function addSpokes(count)
        for i = 1, count do
            local angle = (i / count) * math.pi * 2
            addLine(apex, attachmentAt(1, angle), 0, 1, angle, angle)
        end
    end

    local function addRing(t, segments)
        local points = {}
        for i = 1, segments do
            points[i] = attachmentAt(t, (i / segments) * math.pi * 2)
        end
        for i = 1, segments do
            addLine(
                points[i], points[i % segments + 1],
                t, t,
                (i / segments) * math.pi * 2,
                ((i + 1) / segments) * math.pi * 2
            )
        end
    end

    if hatStyle == "Wireframe" then
        addSpokes(64)
        addRing(1, 64)
    elseif hatStyle == "Web" then
        addSpokes(32)
        for k = 1, 5 do addRing(k / 5, 32) end
    elseif hatStyle == "Rings" then
        for k = 1, 7 do
            local t = k / 7
            addRing(t, math.max(8, math.floor(32 * t)))
        end
    elseif hatStyle == "Spiral" then
        local arms, steps, turns = 3, 36, 3
        for arm = 0, arms - 1 do
            local previous, previousAngle = apex, 0
            for s = 1, steps do
                local t = s / steps
                local angle = arm * (math.pi * 2 / arms) + t * turns * math.pi * 2
                local current = attachmentAt(t, angle)
                addLine(previous, current, (s - 1) / steps, t, previousAngle, angle)
                previous, previousAngle = current, angle
            end
        end
        addRing(1, 48)
    elseif hatStyle == "Solid" then
        local disks = 16
        for i = 1, disks do
            local t = i / disks
            local diameter = radius * 2 * t
            local part = Instance.new("Part")
            part.Name = "Disk" .. i
            part.Shape = Enum.PartType.Cylinder
            part.Size = Vector3.new(0.12, diameter, diameter)
            part.Material = Enum.Material.Neon
            part.Transparency = 0.35
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.Massless = true
            part.CFrame = base.CFrame
                * CFrame.new(0, height * (1 - t), 0)
                * CFrame.Angles(0, 0, math.pi / 2)
            part.Parent = model

            local diskWeld = Instance.new("WeldConstraint")
            diskWeld.Part0 = base
            diskWeld.Part1 = part
            diskWeld.Parent = part

            local angle = t * math.pi * 2
            table.insert(hatItems, {part = part, t0 = t, t1 = t, a0 = angle, a1 = angle})
        end
        addRing(1, 48)
    elseif hatStyle == "Halo" then
        -- Тонкое одинокое кольцо, парящее над головой, без конуса к вершине
        addRing(1, 64)
        addRing(0.97, 64)
    elseif hatStyle == "Diamond" then
        -- Гранёный конус: несколько вертикальных долек крест-накрест + один широкий пояс
        local facets = 8
        for i = 1, facets do
            local angle = (i / facets) * math.pi * 2
            addLine(apex, attachmentAt(1, angle), 0, 1, angle, angle)
        end
        addRing(0.55, facets)
        addRing(1, facets)
    elseif hatStyle == "Fan" then
        -- Веер спиц только на пол-оборота (открытая сторона)
        local count = 24
        local spanStart, spanEnd = -math.pi / 2, math.pi / 2
        for i = 0, count do
            local angle = spanStart + (i / count) * (spanEnd - spanStart)
            addLine(apex, attachmentAt(1, angle), 0, 1, angle, angle)
        end
        local ringPoints = {}
        for i = 0, count do
            local angle = spanStart + (i / count) * (spanEnd - spanStart)
            ringPoints[i + 1] = attachmentAt(1, angle)
        end
        for i = 1, count do
            addLine(ringPoints[i], ringPoints[i + 1], 1, 1,
                spanStart + ((i - 1) / count) * (spanEnd - spanStart),
                spanStart + (i / count) * (spanEnd - spanStart))
        end
    elseif hatStyle == "Crown" then
        -- Зубчатая корона: зигзаг между двумя радиусами по верхнему краю
        local teeth = 12
        local points = {}
        for i = 1, teeth * 2 do
            local angle = (i / (teeth * 2)) * math.pi * 2
            local t = (i % 2 == 1) and 1 or 0.7
            points[i] = attachmentAt(t, angle)
        end
        for i = 1, #points do
            local nextIndex = i % #points + 1
            local tA = (i % 2 == 1) and 1 or 0.7
            local tB = (nextIndex % 2 == 1) and 1 or 0.7
            addLine(points[i], points[nextIndex], tA, tB,
                (i / #points) * math.pi * 2, (nextIndex / #points) * math.pi * 2)
        end
        addRing(0.7, teeth * 2)
        for i = 1, teeth * 2, 2 do
            local angle = (i / (teeth * 2)) * math.pi * 2
            addLine(attachmentAt(0.7, angle), attachmentAt(1, angle), 0.7, 1, angle, angle)
        end
    elseif hatStyle == "Orbit" then
        -- Несколько тонких колец на разных высотах, читаются как орбиты
        for k = 1, 4 do
            local t = k / 4
            addRing(t, 40)
        end
        addSpokes(8)
    elseif hatStyle == "Starburst" then
        -- Длинные спицы, выходящие за пределы базового радиуса, звездой
        local rays = 16
        for i = 1, rays do
            local angle = (i / rays) * math.pi * 2
            addLine(apex, attachmentAt(1.3, angle), 0, 1.3, angle, angle)
        end
        addRing(1, rays)
        addRing(0.5, rays)
    elseif hatStyle == "DoubleCone" then
        -- Двойной конус: основной конус вверх + отражённый конус вниз (песочные часы)
        addSpokes(48)
        addRing(1, 48)
        local mirrorApex = Instance.new("Attachment")
        mirrorApex.Position = Vector3.new(0, -height * 0.6, 0)
        mirrorApex.Parent = base
        for i = 1, 48 do
            local angle = (i / 48) * math.pi * 2
            local rim = attachmentAt(1, angle)
            addLine(mirrorApex, rim, 0, 1, angle, angle)
        end
    end

    applyHatColors(os.clock())
end

local function rebuildHat()
    if hatEnabled then task.spawn(addHat, player.Character) end
end

-- ============================================================
-- Leg VFX (эффект на ноги)
-- ============================================================
local LEG_VFX_ASSET_ID = 73953105304513
local LEG_NAMES_R15 = {"LeftFoot", "RightFoot"}
local LEG_NAMES_R6  = {"Left Leg", "Right Leg"}

local legVfxEnabled = false
local legVfxModel
local legVfxEmitters = {}

local function findLegParts(character)
    local parts = {}
    for _, name in ipairs(LEG_NAMES_R15) do
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then table.insert(parts, part) end
    end
    if #parts == 0 then
        for _, name in ipairs(LEG_NAMES_R6) do
            local part = character:FindFirstChild(name)
            if part and part:IsA("BasePart") then table.insert(parts, part) end
        end
    end
    return parts
end

local function removeLegVfx()
    if legVfxModel ~= nil then
        legVfxModel:Destroy()
        legVfxModel = nil
    end
    table.clear(legVfxEmitters)
end

local function addLegVfx(character)
    removeLegVfx()
    if not legVfxEnabled or character == nil then return end

    local legs = findLegParts(character)
    if #legs == 0 or player.Character ~= character then return end

    local model = Instance.new("Model")
    model.Name = "BasaltLegVFX"
    model.Parent = character
    legVfxModel = model

    for _, leg in ipairs(legs) do
        local attachment = Instance.new("Attachment")
        attachment.Name = "LegVfxAttachment"
        attachment.Position = Vector3.new(0, -leg.Size.Y / 2, 0)
        attachment.Parent = leg
        attachment:SetAttribute("BasaltTemp", true)

        local ok, emitter = pcall(function()
            local e = Instance.new("ParticleEmitter")
            e.Texture = "rbxassetid://" .. tostring(LEG_VFX_ASSET_ID)
            e.Rate = 25
            e.Lifetime = NumberRange.new(0.4, 0.8)
            e.Speed = NumberRange.new(0, 1)
            e.Size = NumberSequence.new(0.8)
            e.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.1),
                NumberSequenceKeypoint.new(1, 1),
            })
            e.LightEmission = 0.6
            e.Parent = attachment
            return e
        end)
        if ok and emitter then
            table.insert(legVfxEmitters, emitter)
            table.insert(legVfxEmitters, attachment)
        end
    end
end

local function rebuildLegVfx()
    if legVfxEnabled then task.spawn(addLegVfx, player.Character) end
end

-- ============================================================
-- Halo VFX (нимб над головой)
-- ============================================================
local HALO_VFX_ASSET_ID = 15990439439

local haloVfxEnabled = false
local haloVfxModel
local haloVfxEmitters = {}

local function removeHaloVfx()
    if haloVfxModel ~= nil then
        haloVfxModel:Destroy()
        haloVfxModel = nil
    end
    table.clear(haloVfxEmitters)
end

local function addHaloVfx(character)
    removeHaloVfx()
    if not haloVfxEnabled or character == nil then return end

    local head = character:FindFirstChild("Head")
    if head == nil or player.Character ~= character then return end

    local model = Instance.new("Model")
    model.Name = "BasaltHaloVFX"
    model.Parent = character
    haloVfxModel = model

    local base = Instance.new("Part")
    base.Name = "HaloBase"
    base.Size = Vector3.new(0.2, 0.2, 0.2)
    base.Transparency = 1
    base.CanCollide = false
    base.CanTouch = false
    base.CanQuery = false
    base.Massless = true
    base.CFrame = head.CFrame * CFrame.new(0, head.Size.Y / 2 + 0.6, 0)
    base.Parent = model

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = head
    weld.Part1 = base
    weld.Parent = base

    local attachment = Instance.new("Attachment")
    attachment.Name = "HaloVfxAttachment"
    attachment.Parent = base

    local ok, emitter = pcall(function()
        local e = Instance.new("ParticleEmitter")
        e.Texture = "rbxassetid://" .. tostring(HALO_VFX_ASSET_ID)
        e.Rate = 8
        e.Lifetime = NumberRange.new(1, 1.5)
        e.Speed = NumberRange.new(0, 0)
        e.Rotation = NumberRange.new(0, 360)
        e.RotSpeed = NumberRange.new(10, 20)
        e.Size = NumberSequence.new(1.6)
        e.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(0.85, 0.1),
            NumberSequenceKeypoint.new(1, 1),
        })
        e.LightEmission = 0.8
        e.Parent = attachment
        return e
    end)
    if ok and emitter then
        table.insert(haloVfxEmitters, emitter)
        table.insert(haloVfxEmitters, attachment)
    end
end

local function rebuildHaloVfx()
    if haloVfxEnabled then task.spawn(addHaloVfx, player.Character) end
end

-- ============================================================
-- Поиск оружия
-- ============================================================
local function findWeapon(p, kind)
    local function scan(holder)
        if not holder then return nil end
        for _, item in ipairs(holder:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if (kind == "knife" and name == "knife")
                    or (kind == "gun" and (name == "gun" or name == "revolver")) then
                    return item
                end
            end
        end
        return nil
    end
    local equipped = scan(p.Character)
    if equipped then return equipped, "equipped" end
    local stored = scan(p:FindFirstChildOfClass("Backpack"))
    if stored then return stored, "backpack" end
    return nil, nil
end

-- ============================================================
-- ESP
-- ============================================================
local ROLE_COLORS = {
    KNIFE   = Color3.fromRGB(255, 70, 70),
    GUN     = Color3.fromRGB(70, 160, 255),
    unknown = Color3.fromRGB(120, 255, 150),
}

local marks = {}
local esp   = false

local function clearMark(p)
    local mark = marks[p]
    if mark == nil then return end
    mark.highlight:Destroy()
    mark.billboard:Destroy()
    marks[p] = nil
end

local function createMark(c, head)
    local highlight = Instance.new("Highlight")
    highlight.Name = "BasaltMM2Highlight"
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = c
    highlight.Parent = game:GetService("CoreGui")

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BasaltMM2Label"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(180, 40)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.8, 0)
    billboard.Adornee = head
    billboard.Parent = game:GetService("CoreGui")

    local function line(y, h, size)
        local t = Instance.new("TextLabel")
        t.Position = UDim2.fromScale(0, y)
        t.Size = UDim2.fromScale(1, h)
        t.BackgroundTransparency = 1
        t.TextStrokeTransparency = 0.3
        t.TextSize = size
        t.Font = Enum.Font.GothamBold
        t.Parent = billboard
        return t
    end

    return {
        character = c,
        role = nil,
        highlight = highlight,
        billboard = billboard,
        nameText = line(0, 0.55, 15),
        infoText = line(0.55, 0.45, 12),
    }
end

local function updateMarks()
    for p, mark in marks do
        if not esp or p.Parent ~= Players or p.Character ~= mark.character then
            clearMark(p)
        end
    end
    if not esp then return end

    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    for _, p in Players:GetPlayers() do
        local c = p.Character
        local head = c and c:FindFirstChild("Head")
        local humanoid = c and c:FindFirstChildOfClass("Humanoid")

        if p == player or c == nil or head == nil or humanoid == nil or humanoid.Health <= 0 then
            clearMark(p)
            continue
        end

        local mark = marks[p]
        if mark == nil then
            mark = createMark(c, head)
            marks[p] = mark
        end

        if findWeapon(p, "knife") ~= nil then
            mark.role = "KNIFE"
        elseif mark.role ~= "KNIFE" and findWeapon(p, "gun") ~= nil then
            mark.role = "GUN"
        end

        local color = ROLE_COLORS[mark.role or "unknown"]
        mark.highlight.FillColor = color
        mark.highlight.OutlineColor = color
        mark.nameText.TextColor3 = color
        mark.infoText.TextColor3 = Color3.new(1, 1, 1)

        mark.nameText.Text = if mark.role ~= nil
            then `{p.DisplayName} [{mark.role}]`
            else p.DisplayName

        local distance = if myRoot ~= nil
            then math.floor((myRoot.Position - head.Position).Magnitude)
            else 0
        mark.infoText.Text = `{distance}m • HP {math.floor(humanoid.Health)}`
    end
end

-- ============================================================
-- Speed
-- ============================================================
local fast = false
local defaultSpeed = 16
local function setSpeed()
    local c = player.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = fast and 24 or defaultSpeed end
end

-- ============================================================
-- Coins
-- ============================================================
local farming = false
local coinTimes = setmetatable({}, {__mode = "k"})
local lastContainer = nil

local function farmCoin()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end

    local container
    for _, map in ipairs(workspace:GetChildren()) do
        if map:IsA("Model") and map:FindFirstChild("CoinContainer") then
            container = map.CoinContainer
            break
        end
    end
    if not container then return end

    if container ~= lastContainer then
        coinTimes = setmetatable({}, {__mode = "k"})
        lastContainer = container
    end

    local now = os.clock()
    local nearest, shortest = nil, math.huge
    for _, coin in ipairs(container:GetChildren()) do
        if coin:IsA("BasePart") and coin.Name == "Coin_Server"
            and (not coinTimes[coin] or now - coinTimes[coin] > 12) then
            local distance = (root.Position - coin.Position).Magnitude
            if distance < shortest then
                shortest, nearest = distance, coin
            end
        end
    end
    if nearest and farming then
        coinTimes[nearest] = now
        root.CFrame = nearest.CFrame + Vector3.new(0, 1.5, 0)
    end
end

-- ============================================================
-- Auto Gun
-- ============================================================
local autoGun = false

local function hasGun(character)
    local backpack = player:FindFirstChildOfClass("Backpack")
    for _, holder in ipairs({character, backpack}) do
        if holder then
            for _, item in ipairs(holder:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if name:find("gun", 1, true) or name:find("revolver", 1, true) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function findDroppedGun(root)
    local nearest, distance = nil, math.huge
    for _, item in ipairs(workspace:GetDescendants()) do
        if item.Name == "GunDrop" and (item:IsA("BasePart") or item:IsA("Model")) then
            local parent = item.Parent
            local inCharacter = false
            while parent and parent ~= workspace do
                if parent:IsA("Model") and Players:GetPlayerFromCharacter(parent) then
                    inCharacter = true
                    break
                end
                parent = parent.Parent
            end
            if not inCharacter then
                local part = item:IsA("BasePart") and item
                    or item:FindFirstChild("Handle", true)
                    or item:FindFirstChildWhichIsA("BasePart", true)
                if part and part:IsA("BasePart") then
                    local d = (root.Position - part.Position).Magnitude
                    if d < distance then nearest, distance = part, d end
                end
            end
        end
    end
    return nearest
end

local function pickUpGun()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 or hasGun(character) then return false end
    local part = findDroppedGun(root)
    if not part then return false end
    root.CFrame = part.CFrame + Vector3.new(0, 1.5, 0)
    return true
end

-- ============================================================
-- Auto Kill (нож / пистолет)
-- ============================================================
local autoKill    = false
local autoMurder  = false
local killMode    = "none"
local killElapsed = 0
local chasingTarget = false

local function attackNearest()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return false end

    local knife = character:FindFirstChild("Knife")
    if not (knife and knife:IsA("Tool")) then
        local backpack = player:FindFirstChildOfClass("Backpack")
        knife = backpack and backpack:FindFirstChild("Knife")
        if not (knife and knife:IsA("Tool")) then return false end
        humanoid:EquipTool(knife)
        if knife.Parent ~= character then return false end
    end

    local targetRoot, shortest = nil, math.huge
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local target = other.Character
            local targetHumanoid = target and target:FindFirstChildOfClass("Humanoid")
            local part = target and target:FindFirstChild("HumanoidRootPart")
            if part and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (root.Position - part.Position).Magnitude
                if distance < shortest then
                    shortest, targetRoot = distance, part
                end
            end
        end
    end
    if not targetRoot then return false end
    root.CFrame = CFrame.lookAt(targetRoot.Position - targetRoot.CFrame.LookVector * 2, targetRoot.Position)
    knife:Activate()
    return true
end

-- Silent aim
local aimState = getgenv().BasaltMM2SilentAimState
if not aimState then
    aimState = {enabled = false}
    getgenv().BasaltMM2SilentAimState = aimState
end
aimState.enabled = false

local function knifeTargetPosition()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bestDistance = nil, math.huge
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local target = other.Character
            local humanoid = target and target:FindFirstChildOfClass("Humanoid")
            local head = target and target:FindFirstChild("Head")
            local knife = findWeapon(other, "knife")
            if humanoid and humanoid.Health > 0 and head and knife then
                local distance = (root.Position - head.Position).Magnitude
                if distance < bestDistance then
                    bestDistance, best = distance, head.Position
                end
            end
        end
    end
    return best
end

aimState.getTarget = knifeTargetPosition
aimState.player = player

if not aimState.hooked then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local state = getgenv().BasaltMM2SilentAimState
        if state and state.enabled and not checkcaller()
            and getnamecallmethod() == "FireServer"
            and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
            local gun = self.Parent
            local character = state.player.Character
            local backpack = state.player:FindFirstChildOfClass("Backpack")
            local equipped = character and character:FindFirstChild("Gun")
            local gunShoot = self.Name == "Shoot" and gun and gun:IsA("Tool")
                and gun.Name:lower() == "gun"
                and (gun.Parent == character or gun.Parent == backpack)
            local services = game:GetService("ReplicatedStorage"):FindFirstChild("ClientServices")
            local weaponService = services and services:FindFirstChild("WeaponService")
            local serviceShot = self.Name == "GunFired" and weaponService and self.Parent == weaponService
                and equipped and equipped:IsA("Tool")
            if gunShoot or serviceShot then
                state.lastShotRemote = os.clock()
                local args = {...}
                local count = select("#", ...)
                local index
                for i = 1, count do
                    local kind = typeof(args[i])
                    if kind == "Vector3" or kind == "CFrame" then
                        if index then index = nil; break end
                        index = i
                    end
                end
                if index then
                    local target = state.getTarget()
                    if target then
                        if typeof(args[index]) == "CFrame" then
                            args[index] = CFrame.new(target) * args[index].Rotation
                        else
                            args[index] = target
                        end
                        return oldNamecall(self, table.unpack(args, 1, count))
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end))
    aimState.hooked = true
end

-- Gun branch
local murderElapsed     = 0
local lastMurderShot    = -math.huge
local lastMurderPickup  = -math.huge
local murderPath, murderWaypoints, murderWaypointIndex = nil, nil, 1
local murderPathTarget, murderPathTime = nil, -math.huge

local function clearGunLine(character, targetCharacter, targetPosition)
    local attachment = character:FindFirstChild("GunRaycastAttachment", true)
    if not (attachment and attachment:IsA("Attachment")) then return false end
    local origin = attachment.WorldPosition
    local direction = targetPosition - origin
    if direction.Magnitude < 0.1 then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    local hit = workspace:Raycast(origin, direction, params)
    return not hit or hit.Instance:IsDescendantOf(targetCharacter)
end

local function walkAroundWall(character, humanoid, targetCharacter)
    local root = character:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then return false end
    local now = os.clock()
    if murderPathTarget ~= targetCharacter or now - murderPathTime > 1.5 then
        murderPathTime, murderPathTarget = now, targetCharacter
        murderPath, murderWaypoints, murderWaypointIndex = nil, nil, 1
        local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
        local offset = root.Position - targetRoot.Position
        local destination = targetRoot.Position
        if offset.Magnitude > 7 then destination += offset.Unit * 7 end
        local ok = pcall(function() path:ComputeAsync(root.Position, destination) end)
        if ok and path.Status == Enum.PathStatus.Success then
            murderPath, murderWaypoints = path, path:GetWaypoints()
        end
    end
    if not murderWaypoints then return false end
    while murderWaypointIndex <= #murderWaypoints
        and (root.Position - murderWaypoints[murderWaypointIndex].Position).Magnitude < 3 do
        murderWaypointIndex += 1
    end
    local waypoint = murderWaypoints[murderWaypointIndex]
    if not waypoint then return false end
    if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
    humanoid:MoveTo(waypoint.Position)
    return true
end

local shootMurder  -- forward decl

local function shootMurderImpl()
    if not autoMurder then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local gun = findWeapon(player, "gun")
    if gun and gun.Parent ~= character then
        humanoid:EquipTool(gun)
        if gun.Parent ~= character then return end
    end

    if not gun then
        local now = os.clock()
        if now - lastMurderPickup < 0.3 then return end
        lastMurderPickup = now
        local root = character:FindFirstChild("HumanoidRootPart")
        local drop = root and findDroppedGun(root)
        if drop then pickUpGun() end
        return
    end

    local target = knifeTargetPosition()
    if not target then return end

    local targetCharacter
    for _, other in ipairs(Players:GetPlayers()) do
        local model = other.Character
        local head = model and model:FindFirstChild("Head")
        if other ~= player and head and (head.Position - target).Magnitude < 3 then
            targetCharacter = model
            break
        end
    end
    if not targetCharacter then return end

    if not clearGunLine(character, targetCharacter, target) then
        walkAroundWall(character, humanoid, targetCharacter)
        return
    end

    murderPath, murderWaypoints, murderPathTarget = nil, nil, nil
    local camera = workspace.CurrentCamera
    if not camera then return end
    if not gun.Enabled then return end

    local now = os.clock()
    if now - lastMurderShot < 0.8 then return end
    lastMurderShot = now

    local previous = camera.CFrame
    local shotBefore = aimState.lastShotRemote or -math.huge
    camera.CFrame = CFrame.lookAt(previous.Position, target)
    gun:Activate()

    task.delay(0.12, function()
        if not autoMurder or gun.Parent ~= player.Character then return end
        if (aimState.lastShotRemote or -math.huge) > shotBefore then return end
        local current = player.Character
        local shoot = gun:FindFirstChild("Shoot")
        local attachment = current and current:FindFirstChild("GunRaycastAttachment", true)
        local currentTarget = knifeTargetPosition()
        if not current or gun.Parent ~= current or not gun.Enabled
            or not shoot or not shoot:IsA("RemoteEvent")
            or not attachment or not attachment:IsA("Attachment") or not currentTarget then
            return
        end
        if not clearGunLine(current, targetCharacter, currentTarget) then return end
        pcall(function()
            shoot:FireServer(CFrame.new(currentTarget), attachment.WorldCFrame)
        end)
    end)
    task.delay(0.3, function()
        if camera.Parent and autoMurder then camera.CFrame = previous end
    end)
end
shootMurder = shootMurderImpl

-- ============================================================
-- UI: вкладки и элементы
-- ============================================================
local MainTab = Window:AddTab("Main")
local HatTab  = Window:AddTab("China Hat")
local MiscTab = Window:AddTab("Misc")

-- ---------- Main / Combat ----------
local CombatSec = MainTab:AddSection("Combat", true)

CombatSec:AddToggle({
    Name = "Auto Kill (Knife / Gun)",
    Default = false,
    Flag = "auto_kill",
    Tooltip = "Сам определяет нож или пистолет в инвентаре",
    Callback = function(v)
        autoKill = v
        if not v then
            autoMurder = false
            killMode = "none"
            aimState.enabled = false
        end
    end,
})

CombatSec:AddToggle({
    Name = "Auto Gun (pickup GunDrop)",
    Default = false,
    Flag = "auto_gun",
    Tooltip = "Подбирает выпавший пистолет",
    Callback = function(v)
        autoGun = v
    end,
})

-- ---------- Main / Visuals ----------
local VisualsSec = MainTab:AddSection("Visuals", true)

VisualsSec:AddToggle({
    Name = "Players ESP",
    Default = false,
    Flag = "esp",
    Callback = function(v)
        esp = v
        updateMarks()
    end,
})

VisualsSec:AddToggle({
    Name = "Speed Boost (24)",
    Default = false,
    Flag = "speed",
    Callback = function(v)
        fast = v
        setSpeed()
    end,
})

-- ---------- Main / Farming ----------
local FarmSec = MainTab:AddSection("Farming", true)

FarmSec:AddToggle({
    Name = "Auto Coins",
    Default = false,
    Flag = "coins",
    Callback = function(v)
        farming = v
    end,
})

-- ---------- Main / Status ----------
local StatusSec = MainTab:AddSection("Status", true)
local StatusLabel = StatusSec:AddLabel("Auto Kill: idle")

-- ---------- China Hat ----------
local HatToggleSec = HatTab:AddSection("Hat", true)

HatToggleSec:AddToggle({
    Name = "Enable China Hat",
    Default = false,
    Flag = "hat_enabled",
    Callback = function(v)
        hatEnabled = v
        if hatEnabled then addHat(player.Character) else removeHat() end
    end,
})

HatToggleSec:AddDropdown({
    Name = "Style",
    Options = HAT_STYLES,
    Default = "Wireframe",
    Flag = "hat_style",
    Callback = function(v)
        hatStyle = v
        rebuildHat()
    end,
})

HatToggleSec:AddDropdown({
    Name = "Color Mode",
    Options = HAT_COLOR_MODES,
    Default = "Teal",
    Flag = "hat_color",
    Callback = function(v)
        hatColorMode = v
        applyHatColors(os.clock())
    end,
})

local HatShapeSec = HatTab:AddSection("Shape", true)

HatShapeSec:AddDropdown({
    Name = "Size",
    Options = HAT_SIZE_LABELS,
    Default = "1x",
    Flag = "hat_size",
    Callback = function(v)
        hatSize = HAT_SIZE_MAP[v] or 1
        rebuildHat()
    end,
})

HatShapeSec:AddDropdown({
    Name = "Animation Speed",
    Options = HAT_SPEED_LABELS,
    Default = "1x",
    Flag = "hat_speed",
    Callback = function(v)
        hatSpeed = HAT_SPEED_MAP[v] or 1
    end,
})

local LegVfxSec = HatTab:AddSection("Leg VFX", true)

LegVfxSec:AddToggle({
    Name = "Enable Leg VFX",
    Default = false,
    Flag = "leg_vfx_enabled",
    Tooltip = "Добавляет частицы (asset " .. tostring(LEG_VFX_ASSET_ID) .. ") к ногам персонажа",
    Callback = function(v)
        legVfxEnabled = v
        if legVfxEnabled then addLegVfx(player.Character) else removeLegVfx() end
    end,
})

local HaloVfxSec = HatTab:AddSection("Halo VFX", true)

HaloVfxSec:AddToggle({
    Name = "Enable Halo VFX",
    Default = false,
    Flag = "halo_vfx_enabled",
    Tooltip = "Добавляет нимб (asset " .. tostring(HALO_VFX_ASSET_ID) .. ") над головой персонажа",
    Callback = function(v)
        haloVfxEnabled = v
        if haloVfxEnabled then addHaloVfx(player.Character) else removeHaloVfx() end
    end,
})

-- ---------- Misc ----------
local InfoSec = MiscTab:AddSection("Info", true)
InfoSec:AddParagraph({
    Name = "MM2 Panel",
    Content = "ESP, Speed, Coins, Auto Gun, Auto Kill и China Hat.\n"
           .. "Панель: RightShift — показать/скрыть.",
})

local ActionsSec = MiscTab:AddSection("Actions", true)

ActionsSec:AddKeybind({
    Name = "Unload Script",
    Default = "Delete",
    Mode = "Press",
    Flag = "unload_key",
    Callback = function()
        local fn = getgenv().BasaltMM2Cleanup
        if type(fn) == "function" then fn() end
    end,
})

ActionsSec:AddButton({
    Name = "Unload (click)",
    Callback = function()
        local fn = getgenv().BasaltMM2Cleanup
        if type(fn) == "function" then fn() end
    end,
})

-- ============================================================
-- Жизненный цикл
-- ============================================================
local timer = 0
local chasingGun = false

local function setStatus(text)
    StatusLabel:Set(text)
end

-- Слушатели оружия (для авто-подбора пистолета)
local function tryMurderSoon()
    if autoMurder then task.defer(shootMurder) end
end

local gunBagConnection, gunCharacterConnection
local function onLocalToolAdded(item)
    if item:IsA("Tool") then
        local name = item.Name:lower()
        if name == "gun" or name == "revolver" then tryMurderSoon() end
    end
end
local function bindGunListeners()
    if gunBagConnection then gunBagConnection:Disconnect() end
    if gunCharacterConnection then gunCharacterConnection:Disconnect() end
    local bag = player:FindFirstChildOfClass("Backpack")
    gunBagConnection = bag and bag.ChildAdded:Connect(onLocalToolAdded)
    local character = player.Character
    gunCharacterConnection = character and character.ChildAdded:Connect(onLocalToolAdded)
end
bindGunListeners()

local dropConnection = workspace.DescendantAdded:Connect(function(item)
    if item.Name == "GunDrop" then
        lastMurderPickup = -math.huge
        tryMurderSoon()
    end
end)

local heartbeat = RunService.Heartbeat:Connect(function(dt)
    if hatEnabled and HAT_ANIMATED[hatColorMode] then
        hatElapsed += dt
        if hatElapsed >= 1 / 30 then
            hatElapsed = 0
            applyHatColors(os.clock())
        end
    end

    timer += dt
    if timer >= 0.3 then
        timer = 0
        updateMarks()
        if fast then setSpeed() end
    end

    -- Auto Kill mode detection
    local mode = "none"
    if autoKill then
        if findWeapon(player, "knife") then
            mode = "knife"
        elseif findWeapon(player, "gun") then
            mode = "gun"
        end
    end
    if mode ~= killMode then
        killMode = mode
        setStatus(
            mode == "knife" and "Knife: attacking nearest player"
            or mode == "gun" and "Gun: looking for Knife user"
            or autoKill and "Auto Kill: waiting for Knife or Gun"
            or "Auto Kill: idle"
        )
        murderPath, murderWaypoints, murderPathTarget = nil, nil, nil
    end
    autoMurder = mode == "gun"
    aimState.enabled = autoMurder

    if mode == "knife" then
        killElapsed += dt
    else
        killElapsed = 0
        chasingTarget = false
    end
    if mode == "knife" and killElapsed >= 0.6 then
        killElapsed = 0
        chasingTarget = attackNearest()
    end

    if autoMurder then
        murderElapsed += dt
        if murderElapsed >= 0.15 then
            murderElapsed = 0
            shootMurder()
        end
    else
        murderElapsed = 0
    end

    if autoGun and not autoMurder and not chasingTarget then
        gunElapsed = (gunElapsed or 0) + dt
    else
        gunElapsed = 0
        chasingGun = false
    end
    if autoGun and not autoMurder and not chasingTarget and gunElapsed >= 0.35 then
        gunElapsed = 0
        chasingGun = pickUpGun()
    end

    if farming and not chasingGun and not chasingTarget and not autoMurder then
        coinElapsed = (coinElapsed or 0) + dt
        if coinElapsed >= 0.45 then
            coinElapsed = 0
            farmCoin()
        end
    else
        coinElapsed = 0
    end
end)

local respawn = player.CharacterAdded:Connect(function(character)
    if hatEnabled then task.spawn(addHat, character) end
    if legVfxEnabled then task.spawn(addLegVfx, character) end
    if haloVfxEnabled then task.spawn(addHaloVfx, character) end
    bindGunListeners()
    tryMurderSoon()
    if fast then task.wait(0.5); setSpeed() end
end)

-- ============================================================
-- Cleanup / Unload
-- ============================================================
local function cleanupPanel()
    autoMurder = false
    aimState.enabled = false
    autoKill = false
    autoGun = false
    hatEnabled = false
    removeHat()
    legVfxEnabled = false
    removeLegVfx()
    haloVfxEnabled = false
    removeHaloVfx()
    farming = false
    esp = false
    for p in pairs(marks) do clearMark(p) end
    fast = false
    setSpeed()

    if heartbeat then heartbeat:Disconnect() end
    if dropConnection then dropConnection:Disconnect() end
    if gunBagConnection then gunBagConnection:Disconnect() end
    if gunCharacterConnection then gunCharacterConnection:Disconnect() end
    if respawn then respawn:Disconnect() end

    pcall(function() Window:Destroy() end)

    if getgenv().BasaltMM2Cleanup == cleanupPanel then
        getgenv().BasaltMM2Cleanup = nil
    end
end
getgenv().BasaltMM2Cleanup = cleanupPanel

Window:Notify({
    Title = "MM2 Panel",
    Content = "Загружено. RightShift — показать/скрыть UI.",
    Type = "Success",
    Duration = 4,
})
