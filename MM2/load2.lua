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
local HAT_STYLES = {
    "Wireframe", "Web", "Rings", "Spiral", "Solid", "Halo", "Diamond", "Fan",
    "Crown", "Orbit", "Starburst", "DoubleCone", "DevilHorns", "RamHorns",
    "Antlers", "CatEars", "AngelWings", "BatWings", "Trident", "UFO",
}
local HAT_COLOR_MODES = {
    "Teal", "Pink", "Purple", "Red", "Orange", "Yellow", "Green", "Lime",
    "Cyan", "Blue", "Navy", "White", "Black", "Gold", "Silver", "Rose",
    "Mint", "Lavender", "Coral", "Amber", "Turquoise", "Burgundy", "Ivory", "Violet",
    "Gradient", "Rainbow", "Wave", "Pulse", "Sunset", "Ocean", "Aurora",
    "Fire", "Ice", "Candy", "Galaxy", "Matrix", "Lava", "Electric", "Disco",
    "NeonShift", "Toxic", "Sakura", "Solar",
}
local HAT_SIZE_LABELS = {"0.75x", "1x", "1.25x", "1.5x"}
local HAT_SPEED_LABELS= {"0.5x", "1x", "2x", "3x"}
local HAT_SIZE_MAP    = {["0.75x"]=0.75, ["1x"]=1, ["1.25x"]=1.25, ["1.5x"]=1.5}
local HAT_SPEED_MAP   = {["0.5x"]=0.5,  ["1x"]=1, ["2x"]=2, ["3x"]=3}

local HAT_STATIC = {
    Teal   = Color3.fromRGB(0, 255, 170),
    Pink   = Color3.fromRGB(255, 90, 200),
    Purple = Color3.fromRGB(150, 90, 255),
    Red    = Color3.fromRGB(255, 50, 65),
    Orange = Color3.fromRGB(255, 145, 35),
    Yellow = Color3.fromRGB(255, 235, 55),
    Green  = Color3.fromRGB(45, 210, 90),
    Lime   = Color3.fromRGB(165, 255, 40),
    Cyan   = Color3.fromRGB(35, 230, 255),
    Blue   = Color3.fromRGB(60, 125, 255),
    Navy   = Color3.fromRGB(35, 55, 145),
    White  = Color3.fromRGB(245, 245, 255),
    Black  = Color3.fromRGB(25, 25, 35),
    Gold   = Color3.fromRGB(255, 195, 40),
    Silver = Color3.fromRGB(180, 205, 220),
    Rose   = Color3.fromRGB(255, 125, 145),
    Mint = Color3.fromRGB(140, 255, 200),
    Lavender = Color3.fromRGB(195, 165, 255),
    Coral = Color3.fromRGB(255, 115, 105),
    Amber = Color3.fromRGB(255, 175, 35),
    Turquoise = Color3.fromRGB(45, 205, 195),
    Burgundy = Color3.fromRGB(145, 25, 75),
    Ivory = Color3.fromRGB(255, 250, 220),
    Violet = Color3.fromRGB(195, 55, 255),
}
local HAT_ANIMATED = {
    Gradient = true, Rainbow = true, Wave = true, Pulse = true,
    Sunset = true, Ocean = true, Aurora = true,
    Fire = true, Ice = true, Candy = true, Galaxy = true,
    Matrix = true, Lava = true, Electric = true, Disco = true,
    NeonShift = true, Toxic = true, Sakura = true, Solar = true,
}
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
local hatMotionPoints = {}
local hatMotionPhase = 0

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
    elseif hatColorMode == "Sunset" then
        local k = 0.5 + 0.5 * math.sin(now * hatSpeed * 1.2 - t * 3 - angle * 0.3)
        return Color3.fromRGB(255, 110, 45):Lerp(Color3.fromRGB(185, 45, 200), k)
    elseif hatColorMode == "Ocean" then
        local k = 0.5 + 0.5 * math.sin(now * hatSpeed * 1.5 - t * 4 + angle)
        return Color3.fromRGB(10, 80, 210):Lerp(Color3.fromRGB(30, 240, 220), k)
    elseif hatColorMode == "Aurora" then
        local k = 0.5 + 0.5 * math.sin(now * hatSpeed - t * 4 + angle * 0.5)
        return Color3.fromRGB(45, 255, 150):Lerp(Color3.fromRGB(155, 60, 255), k)
    elseif hatColorMode == "Fire" then
        local k = 0.5 + 0.5 * math.sin(now * 3 * hatSpeed - t * 8 + angle * 2)
        return Color3.fromRGB(220, 35, 15):Lerp(Color3.fromRGB(255, 220, 40), k)
    elseif hatColorMode == "Ice" then
        local k = 0.5 + 0.5 * math.sin(now * 1.8 * hatSpeed + t * 5 - angle)
        return Color3.fromRGB(30, 100, 220):Lerp(Color3.fromRGB(200, 255, 255), k)
    elseif hatColorMode == "Candy" then
        local k = 0.5 + 0.5 * math.sin(now * 2 * hatSpeed - t * 10 + angle * 3)
        return Color3.fromRGB(255, 80, 175):Lerp(Color3.fromRGB(100, 235, 255), k)
    elseif hatColorMode == "Galaxy" then
        local k = 0.5 + 0.5 * math.sin(now * hatSpeed + t * 7 + angle * 2)
        return Color3.fromRGB(40, 25, 105):Lerp(Color3.fromRGB(190, 90, 255), k)
    elseif hatColorMode == "Matrix" then
        local k = (now * 0.6 * hatSpeed - t * 2 + angle / (math.pi * 2)) % 1
        local glow = 0.18 + 0.82 * math.exp(-18 * k)
        return Color3.fromRGB(15, 255, 60):Lerp(Color3.fromRGB(3, 35, 12), 1 - glow)
    elseif hatColorMode == "Lava" then
        local k = 0.5 + 0.5 * math.sin(now * 1.4 * hatSpeed - t * 6 + angle * 1.5)
        return Color3.fromRGB(80, 12, 15):Lerp(Color3.fromRGB(255, 105, 12), k)
    elseif hatColorMode == "Electric" then
        local k = 0.5 + 0.5 * math.sin(now * 5 * hatSpeed - t * 9 - angle * 4)
        return Color3.fromRGB(25, 60, 170):Lerp(Color3.fromRGB(100, 245, 255), k)
    elseif hatColorMode == "Disco" then
        local step = math.floor(now * 2 * hatSpeed + t * 4 + angle / (math.pi * 2) * 6)
        return Color3.fromHSV((step * 0.19) % 1, 0.9, 1)
    elseif hatColorMode == "NeonShift" then
        local hue = (now * 0.12 * hatSpeed + t * 0.4 + angle / (math.pi * 4)) % 1
        return Color3.fromHSV(hue, 1, 1)
    elseif hatColorMode == "Toxic" then
        local k = 0.5 + 0.5 * math.sin(now * 2 * hatSpeed + angle * 3 - t * 7)
        return Color3.fromRGB(25, 85, 5):Lerp(Color3.fromRGB(200, 255, 20), k)
    elseif hatColorMode == "Sakura" then
        local k = 0.5 + 0.5 * math.sin(now * 1.3 * hatSpeed - t * 6 + angle * 2)
        return Color3.fromRGB(255, 110, 170):Lerp(Color3.fromRGB(255, 235, 245), k)
    elseif hatColorMode == "Solar" then
        local k = 0.5 + 0.5 * math.sin(now * 2.5 * hatSpeed + t * 5 - angle * 2)
        return Color3.fromRGB(240, 75, 10):Lerp(Color3.fromRGB(255, 245, 90), k)
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
    table.clear(hatMotionPoints)
    hatMotionPhase = 0
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

    -- Переиспользуем узлы сетки: меньше Attachment при той же детализации.
    local shapePoints = {}
    local motionGroup
    local function shapePoint(x, y, z)
        local key = string.format("%.4f:%.4f:%.4f", x, y, z)
        local cached = shapePoints[key]
        if cached then return cached end
        local a = Instance.new("Attachment")
        local origin = Vector3.new(x, y, z) * hatSize
        a.Position = origin
        a.Parent = base
        shapePoints[key] = a
        if motionGroup then
            table.insert(hatMotionPoints, {attachment = a, origin = origin,
                group = motionGroup})
        end
        return a
    end

    local function shapeBeam(a, b, width0, width1, t0, t1, angle)
        local beam = Instance.new("Beam")
        beam.Attachment0 = shapePoint(a.X, a.Y, a.Z)
        beam.Attachment1 = shapePoint(b.X, b.Y, b.Z)
        beam.Width0 = width0 * hatSize
        beam.Width1 = width1 * hatSize
        beam.FaceCamera = true
        beam.Segments = 1
        beam.LightEmission = 1
        beam.Parent = base
        table.insert(hatItems, {beam = beam, t0 = t0, t1 = t1,
            a0 = angle, a1 = angle})
    end

    local function shapeLine(a, b, t0, t1, angle)
        shapeBeam(a, b, 0.045, 0.045, t0, t1, angle)
    end

    local function shapePath(points, angle)
        for i = 1, #points - 1 do
            shapeLine(points[i], points[i + 1], (i - 1) / (#points - 1),
                i / (#points - 1), angle)
        end
    end

    -- Поперечные сечения повернуты перпендикулярно оси рога.
    local function tubeRing(centers, i, r, count)
        local tangent = (centers[math.min(i + 1, #centers)]
            - centers[math.max(i - 1, 1)]).Unit
        local reference = math.abs(tangent:Dot(Vector3.yAxis)) > 0.92
            and Vector3.xAxis or Vector3.yAxis
        local right = tangent:Cross(reference).Unit
        local forward = tangent:Cross(right).Unit
        local ring = {}
        for j = 1, count do
            local a = (j - 1) * math.pi * 2 / count
            ring[j] = centers[i] + (right * math.cos(a)
                + forward * math.sin(a)) * r
        end
        return ring
    end

    local function shapeTube(centers, radii, angle)
        local previous
        local sides = 6
        for i = 1, #centers do
            local ring = tubeRing(centers, i, radii[i], sides)
            for j = 1, sides do
                shapeLine(ring[j], ring[j % sides + 1], i / #centers,
                    i / #centers, angle + j * 0.2)
                if previous then
                    shapeLine(previous[j], ring[j], (i - 1) / #centers,
                        i / #centers, angle + j * 0.2)
                end
            end
            previous = ring
        end
    end

    local function detailRings(centers, radii, angle)
        for i = 2, #centers - 1 do
            local ring = tubeRing(centers, i, radii[i] * 1.1, 6)
            for j = 1, 6 do
                shapeBeam(ring[j], ring[j % 6 + 1], 0.027, 0.027,
                    i / #centers, i / #centers, angle + 0.5)
            end
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
    elseif hatStyle == "DevilHorns" then
        for _, side in ipairs({-1, 1}) do
            local curve = {Vector3.new(side * 0.48, 0, 0.05),
                Vector3.new(side * 0.64, 0.3, 0.02),
                Vector3.new(side * 0.82, 0.7, -0.06),
                Vector3.new(side * 0.94, 1.07, -0.18),
                Vector3.new(side * 0.91, 1.4, -0.3),
                Vector3.new(side * 0.76, 1.7, -0.42)}
            local radii = {0.21, 0.2, 0.17, 0.12, 0.065, 0.008}
            shapeTube(curve, radii, side)
            detailRings(curve, radii, side)
        end
    elseif hatStyle == "RamHorns" then
        for _, side in ipairs({-1, 1}) do
            local curl = {Vector3.new(side * 0.48, 0, 0),
                Vector3.new(side * 0.79, 0.2, 0),
                Vector3.new(side * 1.08, 0.52, 0.04),
                Vector3.new(side * 1.18, 0.94, 0.1),
                Vector3.new(side * 0.98, 1.25, 0.2),
                Vector3.new(side * 0.69, 1.18, 0.28),
                Vector3.new(side * 0.57, 0.87, 0.3)}
            local radii = {0.22, 0.27, 0.29, 0.25, 0.19, 0.11, 0.008}
            shapeTube(curl, radii, side)
            detailRings(curl, radii, side)
        end
    elseif hatStyle == "Antlers" then
        for _, side in ipairs({-1, 1}) do
            local trunk = {Vector3.new(side * 0.42, 0, 0),
                Vector3.new(side * 0.61, 0.4, -0.06),
                Vector3.new(side * 0.82, 0.83, -0.1),
                Vector3.new(side * 1.05, 1.26, -0.13),
                Vector3.new(side * 1.22, 1.74, -0.17)}
            shapeTube(trunk, {0.14, 0.14, 0.11, 0.075, 0.008}, side)
            shapeTube({trunk[2], Vector3.new(side * 0.4, 0.85, -0.08),
                Vector3.new(side * 0.35, 1.18, -0.1)}, {0.09, 0.06, 0.008}, side)
            shapeTube({trunk[3], Vector3.new(side * 0.95, 1.29, 0.08),
                Vector3.new(side * 0.89, 1.58, 0.16)}, {0.085, 0.05, 0.008}, side)
            shapeTube({trunk[4], Vector3.new(side * 1.42, 1.44, -0.16),
                Vector3.new(side * 1.63, 1.63, -0.17)}, {0.07, 0.045, 0.008}, side)
            shapeTube({trunk[3], Vector3.new(side * 0.55, 1.25, -0.2),
                Vector3.new(side * 0.48, 1.48, -0.22)},
                {0.065, 0.04, 0.008}, side)
            shapeBeam(trunk[1], trunk[3], 0.035, 0.015, 0, 0.65, side)
        end
    elseif hatStyle == "CatEars" then
        for _, side in ipairs({-1, 1}) do
            motionGroup = side
            local outerL = Vector3.new(side * 0.3, 0.06, 0.04)
            local tip = Vector3.new(side * 0.76, 1.18, 0.02)
            local outerR = Vector3.new(side * 1.1, 0.06, 0.04)
            shapePath({outerL, tip, outerR, outerL}, side)
            local innerL = Vector3.new(side * 0.49, 0.19, -0.055)
            local innerT = Vector3.new(side * 0.76, 0.85, -0.055)
            local innerR = Vector3.new(side * 0.91, 0.19, -0.055)
            shapePath({innerL, innerT, innerR, innerL}, side + 0.5)
            for i = 1, 4 do
                local f = i / 5
                local left = innerL:Lerp(innerT, f)
                local right = innerR:Lerp(innerT, f)
                shapeBeam(left, right, 0.075, 0.075, f, f, side + 1)
            end
            shapeLine(outerL, innerL, 0, 0.2, side)
            shapeLine(outerR, innerR, 0, 0.2, side)
            shapeBeam(outerL, outerR, 0.11, 0.11, 0, 0, side)
            shapeBeam(innerT, tip, 0.035, 0.012, 0.8, 1, side)
        end
    elseif hatStyle == "AngelWings" then
        for _, side in ipairs({-1, 1}) do
            local root = Vector3.new(side * 0.57, 0.15, -0.16)
            local elbow = Vector3.new(side * 1.14, 0.75, -0.24)
            local tip = Vector3.new(side * 2.36, 1.3, -0.32)
            shapePath({root, elbow, tip}, side)
            for i = 1, 9 do
                local f = i / 9
                local top = elbow:Lerp(tip, f)
                local bottom = Vector3.new(side * (1.0 + 1.32 * f),
                    0.1 + 0.46 * f - 0.18 * math.sin(f * math.pi), -0.34)
                shapeBeam(top, bottom, 0.18, 0.045, f, 1 - f, side + f)
                local shaft = top:Lerp(bottom, 0.7)
                shapeBeam(top, shaft, 0.026, 0.012, f, 1 - f, side + 0.3)
                if i > 1 then
                    local prevF = (i - 1) / 9
                    local prevTop = elbow:Lerp(tip, prevF)
                    local prevBottom = Vector3.new(side * (1.0 + 1.32 * prevF),
                        0.1 + 0.46 * prevF - 0.18 * math.sin(prevF * math.pi), -0.34)
                    shapeLine(prevTop:Lerp(prevBottom, 0.42),
                        top:Lerp(bottom, 0.42), prevF, f, side)
                end
            end
            for i = 1, 4 do
                local f = i / 5
                shapeBeam(root:Lerp(elbow, f),
                    Vector3.new(side * (0.66 + 0.48 * f), -0.1, -0.25),
                    0.16, 0.035, f, 1, side)
            end
        end
    elseif hatStyle == "BatWings" then
        for _, side in ipairs({-1, 1}) do
            local root = Vector3.new(side * 0.58, 0.11, -0.18)
            local tips = {Vector3.new(side * 1.02, 1.04, -0.22),
                Vector3.new(side * 1.6, 1.27, -0.28),
                Vector3.new(side * 2.33, 0.96, -0.35)}
            local scallops = {Vector3.new(side * 1.04, -0.25, -0.3),
                Vector3.new(side * 1.45, 0.13, -0.33),
                Vector3.new(side * 1.97, 0.12, -0.37)}
            shapePath({root, tips[1], tips[2], tips[3], scallops[3],
                scallops[2], scallops[1], root}, side)
            for i, tip in ipairs(tips) do
                shapeBeam(root, tip, 0.1, 0.035, 0, i / 3, side)
                local low = scallops[i]
                for j = 1, 4 do
                    local f = j / 5
                    shapeBeam(root:Lerp(tip, f), root:Lerp(low, f),
                        0.09, 0.09, f, f, side + i * 0.2)
                end
                shapeBeam(tip:Lerp(root, 0.25), low:Lerp(root, 0.25),
                    0.035, 0.035, i / 3, i / 3, side)
                shapeBeam(tip:Lerp(root, 0.6), low:Lerp(root, 0.6),
                    0.03, 0.03, i / 3, i / 3, side)
            end
        end
    elseif hatStyle == "Trident" then
        shapeTube({Vector3.new(0, -0.12, 0), Vector3.new(0, 0.36, 0),
            Vector3.new(0, 0.9, 0), Vector3.new(0, 1.48, 0),
            Vector3.new(0, 1.94, 0)}, {0.14, 0.13, 0.13, 0.1, 0.008}, 0)
        for _, side in ipairs({-1, 1}) do
            shapeTube({Vector3.new(0, 0.62, 0),
                Vector3.new(side * 0.4, 0.75, 0),
                Vector3.new(side * 0.68, 1.06, 0),
                Vector3.new(side * 0.72, 1.53, 0),
                Vector3.new(side * 0.72, 1.86, 0)},
                {0.11, 0.13, 0.115, 0.065, 0.008}, side)
        end
        for i = 1, 3 do
            local x = (i - 2) * 0.72
            shapePath({Vector3.new(x - 0.09, 1.46, -0.09),
                Vector3.new(x, 1.89, 0),
                Vector3.new(x + 0.09, 1.46, 0.09)}, i)
        end
        -- Крепёж вилки и кольца на рукояти.
        for _, y in ipairs({-0.04, 0.18, 0.4}) do
            for j = 0, 5 do
                local a, b = j * math.pi / 3, (j + 1) * math.pi / 3
                shapeBeam(Vector3.new(math.cos(a) * 0.16, y, math.sin(a) * 0.16),
                    Vector3.new(math.cos(b) * 0.16, y, math.sin(b) * 0.16),
                    0.035, 0.035, y, y, a)
            end
        end
        for _, side in ipairs({-1, 1}) do
            shapeBeam(Vector3.new(0, 0.66, -0.1),
                Vector3.new(side * 0.65, 1.01, -0.08), 0.045, 0.02, 0.3, 0.8, side)
        end
    elseif hatStyle == "UFO" then
        motionGroup = "UFO"
        local function ufoRing(r, y, count)
            local points = {}
            for i = 1, count do
                local a = i * math.pi * 2 / count
                points[i] = shapePoint(math.cos(a) * r, y, math.sin(a) * r)
            end
            for i = 1, count do
                local a = i * math.pi * 2 / count
                addLine(points[i], points[i % count + 1], y, y, a,
                    (i + 1) * math.pi * 2 / count)
            end
        end
        ufoRing(1.46, 0.23, 32)
        ufoRing(1.46, 0.36, 32)
        ufoRing(1.1, 0.48, 32)
        ufoRing(0.7, 0.79, 24)
        ufoRing(0.38, 1.01, 16)
        ufoRing(0.7, 0.12, 24)
        ufoRing(0.32, 0.05, 16)
        shapeBeam(Vector3.new(0, 1.02, 0), Vector3.new(0, 1.24, 0),
            0.055, 0.018, 0.8, 1, 0)
        for i = 1, 16 do
            local a = i * math.pi * 2 / 16
            local c, s = math.cos(a), math.sin(a)
            shapeBeam(Vector3.new(c * 1.46, 0.23, s * 1.46),
                Vector3.new(c * 1.46, 0.36, s * 1.46), 0.11, 0.11, 0, 1, a)
            shapeLine(Vector3.new(c * 1.1, 0.48, s * 1.1),
                Vector3.new(c * 0.7, 0.79, s * 0.7), 0.4, 0.8, a)
            shapeLine(Vector3.new(c * 0.7, 0.79, s * 0.7),
                Vector3.new(c * 0.38, 1.01, s * 0.38), 0.8, 1, a)
        end
        for i = 1, 12 do
            local a = i * math.pi * 2 / 12
            local c, s = math.cos(a), math.sin(a)
            shapeBeam(Vector3.new(c * 1.35, 0.29, s * 1.35),
                Vector3.new(c * 1.19, 0.38, s * 1.19),
                0.18, 0.18, i / 12, i / 12, a)
        end
        for i = 1, 8 do
            local a = i * math.pi / 4
            local c, s = math.cos(a), math.sin(a)
            shapeBeam(Vector3.new(c * 1.1, 0.24, s * 1.1),
                Vector3.new(c * 0.32, 0.05, s * 0.32),
                0.035, 0.02, 0.3, 0.7, a)
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
local pulledKnifeTargets = {}
local knifePullId = 0

local function restoreKnifeTargets()
    knifePullId += 1
    local targets = pulledKnifeTargets
    pulledKnifeTargets = {}
    for model, pivot in pairs(targets) do
        if model.Parent then
            pcall(function() model:PivotTo(pivot) end)
        end
    end
end

local function attackNearest()
    restoreKnifeTargets()
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

    local count = 0
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local target = other.Character
            local targetHumanoid = target and target:FindFirstChildOfClass("Humanoid")
            local targetRoot = target and target:FindFirstChild("HumanoidRootPart")
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                -- Меняем только локальное положение чужого персонажа, не своего.
                local original = target:GetPivot()
                local front = root.Position + root.CFrame.LookVector * 2.5
                local offset = root.CFrame.RightVector * ((count % 3 - 1) * 0.25)
                local destination = Vector3.new(front.X, root.Position.Y, front.Z) + offset
                local ok = pcall(function()
                    target:PivotTo(CFrame.new(destination) * original.Rotation)
                end)
                if ok then
                    pulledKnifeTargets[target] = original
                    count += 1
                end
            end
        end
    end
    if count == 0 then return false end
    local pullId = knifePullId
    knife:Activate()
    task.delay(0.2, function()
        if knifePullId == pullId then restoreKnifeTargets() end
    end)
    return true
end

-- Silent aim
local aimState = getgenv().BasaltMM2SilentAimState
if not aimState then
    aimState = {enabled = false}
    getgenv().BasaltMM2SilentAimState = aimState
end
aimState.enabled = false

-- Для мгновенного луча целимся в текущий хитбокс, без упреждения.
local function knifeTargetPosition(isVisible)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bestCharacter, bestCurrent, bestDistance = nil, nil, nil, math.huge
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local target = other.Character
            local humanoid = target and target:FindFirstChildOfClass("Humanoid")
            local head = target and target:FindFirstChild("Head")
            local targetRoot = target and target:FindFirstChild("HumanoidRootPart")
            local torso = target and (target:FindFirstChild("UpperTorso") or target:FindFirstChild("Torso") or targetRoot)
            local knife = findWeapon(other, "knife")
            if humanoid and humanoid.Health > 0 and head and knife then
                for _, hitPart in ipairs({torso or head, head}) do
                    local current = hitPart.Position
                    local distance = (root.Position - current).Magnitude
                    if distance < bestDistance and (not isVisible or isVisible(target, current)) then
                        bestDistance = distance
                        bestCurrent = current
                        best = current
                        bestCharacter = target
                    end
                end
            end
        end
    end
    return best, bestCharacter, bestCurrent
end

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
                local args = {...}
                local count = select("#", ...)
                -- Shoot передаёт точку выстрела первой, а CFrame ствола второй.
                -- Второй CFrame нельзя переписывать: сервер использует его как начало луча.
                local index
                if gunShoot then
                    local kind = typeof(args[1])
                    if kind == "Vector3" or kind == "CFrame" then index = 1 end
                else
                    for i = 1, count do
                        local kind = typeof(args[i])
                        if kind == "Vector3" or kind == "CFrame" then
                            index = i
                            break
                        end
                    end
                end
                if index then
                    local target = state.getTarget()
                    if target then
                        if typeof(args[index]) == "CFrame" then
                            args[index] = CFrame.new(target)
                        else
                            args[index] = target
                        end
                        state.lastShotRemote = os.clock()
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

local function visibleKnifeTarget()
    local character = player.Character
    if not character then return nil end
    return knifeTargetPosition(function(targetCharacter, position)
        return clearGunLine(character, targetCharacter, position)
    end)
end

aimState.getTarget = visibleKnifeTarget

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

    -- Без пистолета Auto Kill не перемещает персонажа к GunDrop.
    if not gun then return end

    -- Выбираем ближайшую цель с открытой линией огня, не двигая персонажа.
    local target, targetCharacter = visibleKnifeTarget()
    if not targetCharacter then return end

    if not gun.Enabled then return end

    local now = os.clock()
    if now - lastMurderShot < 0.8 then return end
    lastMurderShot = now

    local shotBefore = aimState.lastShotRemote or -math.huge
    -- Silent aim изменяет координаты в FireServer; камера остаётся неподвижной.
    gun:Activate()

    task.delay(0.12, function()
        if not autoMurder or gun.Parent ~= player.Character then return end
        if (aimState.lastShotRemote or -math.huge) > shotBefore then return end
        local current = player.Character
        local shoot = gun:FindFirstChild("Shoot")
        local attachment = current and current:FindFirstChild("GunRaycastAttachment", true)
        local currentTarget = visibleKnifeTarget()
        if not current or gun.Parent ~= current
            or not shoot or not shoot:IsA("RemoteEvent")
            or not attachment or not attachment:IsA("Attachment") or not currentTarget then
            return
        end
        pcall(function()
            shoot:FireServer(CFrame.new(currentTarget), attachment.WorldCFrame)
        end)
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
            restoreKnifeTargets()
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

local heartbeat = RunService.Heartbeat:Connect(function(dt)
    if hatEnabled and hatModel and hatModel.Parent then
        if #hatMotionPoints > 0 then hatMotionPhase += dt * hatSpeed end
        if HAT_ANIMATED[hatColorMode] or #hatMotionPoints > 0 then
            hatElapsed += dt
            if hatElapsed >= 1 / 30 then
                hatElapsed = 0
                if HAT_ANIMATED[hatColorMode] then applyHatColors(os.clock()) end
                local spin = CFrame.Angles(0, hatMotionPhase * 0.95, 0)
                for _, point in ipairs(hatMotionPoints) do
                    local attachment = point.attachment
                    if attachment.Parent then
                        if point.group == "UFO" then
                            attachment.Position = spin:PointToWorldSpace(point.origin)
                        else
                            local side = point.group
                            local pivot = Vector3.new(side * 0.76, 0.06, 0.04) * hatSize
                            local wave = math.sin(hatMotionPhase * 2.5 + side * 0.7)
                            local tilt = CFrame.Angles(wave * 0.11, 0, side * wave * 0.085)
                            attachment.Position = pivot + tilt:VectorToWorldSpace(point.origin - pivot)
                        end
                    end
                end
            end
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
            mode == "knife" and "Knife: pulling local hitboxes"
            or mode == "gun" and "Gun: looking for Knife user"
            or autoKill and "Auto Kill: waiting for Knife or Gun"
            or "Auto Kill: idle"
        )
    end
    autoMurder = mode == "gun"
    aimState.enabled = autoMurder

    if mode == "knife" then
        killElapsed += dt
    else
        if killMode ~= "knife" and next(pulledKnifeTargets) then restoreKnifeTargets() end
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
    restoreKnifeTargets()
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
    restoreKnifeTargets()
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
