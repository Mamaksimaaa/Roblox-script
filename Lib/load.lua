-- MinecraftLib v3.3
local MinecraftLib = {}
MinecraftLib.__index = MinecraftLib
MinecraftLib.Version = "3.3"

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer

-- ================================================================
-- TEXTURES / FILESYSTEM
-- ================================================================
local TextureURLs = {
    Dirt        = "https://i.pinimg.com/564x/2a/b1/c3/2ab1c37cfdff720c6de2ddb07328f145.jpg",
    OakPlanks   = "https://art.pixilart.com/thumb/sr26db5fe648aaws3.png",
    GrassBlock  = "https://i.postimg.cc/wv2hpwyM/Bez-nazvania8-20260824103816.png",
    OverworldBg = "https://i.postimg.cc/Zn9sHbmG/RDT-20260822-0904335470895445160711381.png",
    NetherBg    = "https://i.postimg.cc/fTJg89px/RDT-20260824-1051291490594943564732101.png",
    EndBg       = "https://i.postimg.cc/nzF1RH4G/RDT-20260822-0900332847624353464382258.png",
}

local FOLDER        = "MinecraftUI"
local CONFIG_FOLDER = FOLDER .. "/configs"

local HasFS    = (isfolder and makefolder and isfile and writefile and readfile and listfiles) and true or false
local HasAsset = (getcustomasset ~= nil)

local function EnsureFolder(path)
    if HasFS and not isfolder(path) then makefolder(path) end
end

local function LoadTexture(url, filename, onReady)
    if not (HasFS and HasAsset) then return "" end
    EnsureFolder(FOLDER)
    local path = FOLDER .. "/" .. filename
    if isfile(path) then
        local ok, id = pcall(getcustomasset, path)
        if ok and type(id) == "string" then return id end
    end
    task.spawn(function()
        local ok, data = pcall(game.HttpGet, game, url, true)
        if ok and type(data) == "string" and #data > 100 then
            pcall(writefile, path, data)
            local ok2, id = pcall(getcustomasset, path)
            if ok2 and type(id) == "string" and onReady then onReady(id) end
        else
            warn("[MinecraftLib] Failed to download texture: " .. tostring(url))
        end
    end)
    return ""
end

-- ================================================================
-- THEMES
-- ================================================================
local Themes = {
    Overworld = {
        BackgroundImage = "OverworldBg", TitleBarImage = "OakPlanks",
        Background = Color3.fromRGB(50, 40, 28), SecondaryBG = Color3.fromRGB(68, 54, 38), TertiaryBG = Color3.fromRGB(52, 43, 30),
        Accent = Color3.fromRGB(80, 140, 45), AccentHover = Color3.fromRGB(105, 175, 60), AccentPress = Color3.fromRGB(60, 110, 35),
        TabActive = Color3.fromRGB(90, 130, 50), TabInactive = Color3.fromRGB(68, 54, 38),
        TextPrimary = Color3.fromRGB(255, 255, 255), TextSecondary = Color3.fromRGB(210, 210, 210),
        TextDisabled = Color3.fromRGB(130, 130, 130), TextHover = Color3.fromRGB(255, 255, 85),
        Border = Color3.fromRGB(12, 10, 7), BevelLight = Color3.fromRGB(220, 220, 220), BevelDark = Color3.fromRGB(35, 28, 20),
        SliderFill = Color3.fromRGB(80, 140, 45), SliderBG = Color3.fromRGB(25, 20, 15),
        ToggleOn = Color3.fromRGB(80, 140, 45), ToggleOff = Color3.fromRGB(80, 60, 45),
        Scrollbar = Color3.fromRGB(125, 100, 62), Shadow = Color3.fromRGB(4, 3, 2), Title = Color3.fromRGB(255, 255, 255),
        CloseBtn = Color3.fromRGB(170, 40, 35), Notification = Color3.fromRGB(35, 28, 20), NotifAccent = Color3.fromRGB(195, 165, 50),
        Separator = Color3.fromRGB(125, 100, 62), Glass = Color3.fromRGB(40, 32, 22),
    },
    Nether = {
        BackgroundImage = "NetherBg", TitleBarImage = "OakPlanks",
        Background = Color3.fromRGB(36, 12, 10), SecondaryBG = Color3.fromRGB(56, 22, 17), TertiaryBG = Color3.fromRGB(48, 17, 14),
        Accent = Color3.fromRGB(185, 35, 35), AccentHover = Color3.fromRGB(215, 55, 45), AccentPress = Color3.fromRGB(145, 25, 25),
        TabActive = Color3.fromRGB(140, 35, 30), TabInactive = Color3.fromRGB(56, 22, 17),
        TextPrimary = Color3.fromRGB(255, 230, 215), TextSecondary = Color3.fromRGB(215, 170, 155),
        TextDisabled = Color3.fromRGB(120, 80, 70), TextHover = Color3.fromRGB(255, 255, 85),
        Border = Color3.fromRGB(8, 3, 2), BevelLight = Color3.fromRGB(210, 120, 100), BevelDark = Color3.fromRGB(24, 8, 6),
        SliderFill = Color3.fromRGB(185, 35, 35), SliderBG = Color3.fromRGB(20, 7, 5),
        ToggleOn = Color3.fromRGB(185, 35, 35), ToggleOff = Color3.fromRGB(65, 25, 20),
        Scrollbar = Color3.fromRGB(85, 30, 20), Shadow = Color3.fromRGB(2, 1, 1), Title = Color3.fromRGB(255, 200, 180),
        CloseBtn = Color3.fromRGB(210, 50, 40), Notification = Color3.fromRGB(24, 8, 6), NotifAccent = Color3.fromRGB(210, 90, 35),
        Separator = Color3.fromRGB(85, 30, 20), Glass = Color3.fromRGB(42, 16, 13),
    },
    End = {
        BackgroundImage = "EndBg", TitleBarImage = "OakPlanks",
        Background = Color3.fromRGB(31, 26, 38), SecondaryBG = Color3.fromRGB(52, 45, 34), TertiaryBG = Color3.fromRGB(43, 37, 52),
        Accent = Color3.fromRGB(120, 80, 170), AccentHover = Color3.fromRGB(150, 110, 200), AccentPress = Color3.fromRGB(90, 58, 135),
        TabActive = Color3.fromRGB(105, 72, 145), TabInactive = Color3.fromRGB(52, 45, 34),
        TextPrimary = Color3.fromRGB(235, 230, 220), TextSecondary = Color3.fromRGB(195, 185, 205),
        TextDisabled = Color3.fromRGB(110, 100, 120), TextHover = Color3.fromRGB(255, 255, 85),
        Border = Color3.fromRGB(10, 9, 7), BevelLight = Color3.fromRGB(205, 195, 220), BevelDark = Color3.fromRGB(28, 23, 18),
        SliderFill = Color3.fromRGB(120, 80, 170), SliderBG = Color3.fromRGB(18, 15, 12),
        ToggleOn = Color3.fromRGB(120, 80, 170), ToggleOff = Color3.fromRGB(68, 60, 52),
        Scrollbar = Color3.fromRGB(82, 72, 52), Shadow = Color3.fromRGB(3, 3, 2), Title = Color3.fromRGB(225, 205, 240),
        CloseBtn = Color3.fromRGB(170, 40, 35), Notification = Color3.fromRGB(28, 23, 18), NotifAccent = Color3.fromRGB(120, 80, 170),
        Separator = Color3.fromRGB(82, 72, 52), Glass = Color3.fromRGB(40, 35, 28),
    },
    Sea = {
        BackgroundImage = false, TitleBarImage = false,
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 70, 92)),
            ColorSequenceKeypoint.new(0.55, Color3.fromRGB(10, 46, 64)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 24, 36)),
        }),
        GradientRotation = 90,
        Background = Color3.fromRGB(12, 45, 60), SecondaryBG = Color3.fromRGB(18, 65, 80), TertiaryBG = Color3.fromRGB(14, 55, 70),
        Accent = Color3.fromRGB(40, 170, 160), AccentHover = Color3.fromRGB(70, 200, 190), AccentPress = Color3.fromRGB(25, 130, 120),
        TabActive = Color3.fromRGB(30, 140, 135), TabInactive = Color3.fromRGB(18, 65, 80),
        TextPrimary = Color3.fromRGB(225, 245, 245), TextSecondary = Color3.fromRGB(170, 210, 210),
        TextDisabled = Color3.fromRGB(90, 130, 130), TextHover = Color3.fromRGB(255, 255, 85),
        Border = Color3.fromRGB(5, 20, 28), BevelLight = Color3.fromRGB(140, 220, 215), BevelDark = Color3.fromRGB(8, 32, 42),
        SliderFill = Color3.fromRGB(40, 170, 160), SliderBG = Color3.fromRGB(6, 25, 32),
        ToggleOn = Color3.fromRGB(40, 170, 160), ToggleOff = Color3.fromRGB(30, 70, 80),
        Scrollbar = Color3.fromRGB(60, 140, 140), Shadow = Color3.fromRGB(2, 6, 8), Title = Color3.fromRGB(200, 240, 235),
        CloseBtn = Color3.fromRGB(190, 60, 60), Notification = Color3.fromRGB(10, 38, 50), NotifAccent = Color3.fromRGB(80, 220, 200),
        Separator = Color3.fromRGB(60, 140, 140), Glass = Color3.fromRGB(15, 50, 65),
    },
    Sky = {
        BackgroundImage = false, TitleBarImage = false,
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(215, 235, 255)),
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(150, 200, 245)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 160, 230)),
        }),
        GradientRotation = 90,
        Background = Color3.fromRGB(135, 190, 240), SecondaryBG = Color3.fromRGB(150, 200, 245), TertiaryBG = Color3.fromRGB(115, 170, 230),
        Accent = Color3.fromRGB(255, 200, 70), AccentHover = Color3.fromRGB(255, 220, 110), AccentPress = Color3.fromRGB(215, 165, 40),
        TabActive = Color3.fromRGB(85, 145, 220), TabInactive = Color3.fromRGB(150, 200, 245),
        TextPrimary = Color3.fromRGB(255, 255, 255), TextSecondary = Color3.fromRGB(235, 245, 255),
        TextDisabled = Color3.fromRGB(190, 210, 230), TextHover = Color3.fromRGB(255, 255, 85),
        Border = Color3.fromRGB(40, 80, 130), BevelLight = Color3.fromRGB(245, 250, 255), BevelDark = Color3.fromRGB(80, 130, 190),
        SliderFill = Color3.fromRGB(255, 200, 70), SliderBG = Color3.fromRGB(85, 135, 200),
        ToggleOn = Color3.fromRGB(255, 200, 70), ToggleOff = Color3.fromRGB(105, 155, 215),
        Scrollbar = Color3.fromRGB(70, 120, 190), Shadow = Color3.fromRGB(30, 60, 100), Title = Color3.fromRGB(255, 255, 255),
        CloseBtn = Color3.fromRGB(220, 80, 70), Notification = Color3.fromRGB(95, 155, 225), NotifAccent = Color3.fromRGB(255, 220, 110),
        Separator = Color3.fromRGB(70, 120, 190), Glass = Color3.fromRGB(140, 195, 245),
    },
}
MinecraftLib.Themes = Themes

function MinecraftLib:AddTheme(name, tbl)
    local t = {}
    for k, v in pairs(Themes.Overworld) do t[k] = v end
    for k, v in pairs(tbl or {}) do t[k] = v end
    Themes[name] = t
    return t
end

-- ================================================================
-- HELPERS
-- ================================================================
local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, child in ipairs(children or {}) do child.Parent = inst end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Tween(inst, props, time, style, direction)
    if not inst or not inst.Parent then return end
    local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
    local tw = TweenService:Create(inst, info, props)
    tw:Play()
    return tw
end

local function Invoke(callback, ...)
    if type(callback) == "function" then
        local ok, err = pcall(callback, ...)
        if not ok then warn("[MinecraftLib] Callback error: " .. tostring(err)) end
    end
end

local function Opts(first, keys, ...)
    if type(first) == "table" then
        first.Name = first.Name or first.Title or first.Text or first[1]
        return first
    end
    local o = {}
    local args = table.pack(first, ...)
    for i, key in ipairs(keys) do o[key] = args[i] end
    return o
end

local function PointInside(gui, pos)
    if not gui or not gui.Parent then return false end
    local ap, as = gui.AbsolutePosition, gui.AbsoluteSize
    return pos.X >= ap.X and pos.X <= ap.X + as.X and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
end

local function IsPress(inp) return inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch end
local function IsMove(inp)  return inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch end

local function ToKeyCode(v)
    if typeof(v) == "EnumItem" then return v end
    if type(v) == "string" then
        local ok, k = pcall(function() return Enum.KeyCode[v] end)
        if ok then return k end
    end
    return nil
end

local function R255(x) return math.floor(x * 255 + 0.5) end
local function ToHex(c) return string.format("#%02X%02X%02X", R255(c.R), R255(c.G), R255(c.B)) end
local function FromHex(str)
    if type(str) ~= "string" then return nil end
    local hex = str:gsub("^%s*#?", ""):gsub("%s+$", "")
    if #hex == 3 then hex = hex:gsub(".", "%0%0") end
    if #hex ~= 6 or not hex:match("^%x+$") then return nil end
    return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
end

local function Serialize(v)
    local tv = typeof(v)
    if tv == "Color3" then return {__t = "Color3", R255(v.R), R255(v.G), R255(v.B)}
    elseif tv == "EnumItem" then return {__t = "Enum", tostring(v.EnumType), v.Name} end
    return v
end

local function Deserialize(v)
    if type(v) == "table" and v.__t then
        if v.__t == "Color3" then
            return Color3.fromRGB(v[1] or 255, v[2] or 255, v[3] or 255)
        elseif v.__t == "Enum" then
            local ok, item = pcall(function() return Enum[v[1]][v[2]] end)
            return ok and item or nil
        end
    end
    return v
end

local function SafeName(n) return (tostring(n or "default"):gsub("[^%w_%- ]", "")) end

local function GetGuiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and typeof(hui) == "Instance" then return hui end
    if pcall(function() return CoreGui.Name end) then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function Viewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function ClampToViewport(pos, absSize)
    local vp = Viewport()
    local absX = pos.X.Scale * vp.X + pos.X.Offset
    local absY = pos.Y.Scale * vp.Y + pos.Y.Offset
    local minX, maxX = -absSize.X + 80, vp.X - 80
    local cx = math.clamp(absX, math.min(minX, maxX), math.max(minX, maxX))
    local cy = math.clamp(absY, 0, math.max(0, vp.Y - 40))
    return UDim2.new(pos.X.Scale, pos.X.Offset + (cx - absX), pos.Y.Scale, pos.Y.Offset + (cy - absY))
end

local function MakeDraggable(frame, handle, canDrag)
    handle = handle or frame
    local dragging, dragStart, startPos = false, nil, nil
    local began = handle.InputBegan:Connect(function(input)
        if IsPress(input) then
            if canDrag and not canDrag() then return end
            dragging, dragStart, startPos = true, input.Position, frame.Position
        end
    end)
    local changed = UserInputService.InputChanged:Connect(function(input)
        if dragging and IsMove(input) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            frame.Position = ClampToViewport(newPos, frame.AbsoluteSize)
        end
    end)
    local ended = UserInputService.InputEnded:Connect(function(input)
        if IsPress(input) then dragging = false end
    end)
    local function Disconnect() began:Disconnect(); changed:Disconnect(); ended:Disconnect() end
    frame.Destroying:Connect(Disconnect)
    return Disconnect
end

-- ================================================================
-- VISUAL PRIMITIVES
-- ================================================================
local function CreateDropShadow(parent, theme, offset, size)
    offset = offset or 6; size = size or 14
    local shadow = Create("ImageLabel", {
        Name = "DropShadow", Size = UDim2.new(1, size * 2, 1, size * 2), Position = UDim2.new(0, -size, 0, -size + offset),
        BackgroundTransparency = 1, Image = "rbxassetid://1316045217", ImageColor3 = theme.Shadow, ImageTransparency = 0.3,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(10, 10, 118, 118), ZIndex = 0, Parent = parent,
    })
    shadow:SetAttribute("BaseTransparency", 0.3)
    return shadow
end

local function CreateInsetShadow(parent, theme, thickness)
    thickness = thickness or 3
    local z = (parent.ZIndex or 1) + 1
    local function mk(name, role, tr, size, pos)
        local f = Create("Frame", {Name = name, BackgroundColor3 = theme[role], BackgroundTransparency = tr, BorderSizePixel = 0, Size = size, Position = pos, ZIndex = z, Parent = parent})
        f:SetAttribute("MC_Role", role)
    end
    mk("InsetTop",    "Shadow",     0.6, UDim2.new(1, 0, 0, thickness), UDim2.new(0, 0, 0, 0))
    mk("InsetLeft",   "Shadow",     0.6, UDim2.new(0, thickness, 1, 0), UDim2.new(0, 0, 0, 0))
    mk("InsetBottom", "BevelLight", 0.7, UDim2.new(1, 0, 0, 1),         UDim2.new(0, 0, 1, -1))
    mk("InsetRight",  "BevelLight", 0.7, UDim2.new(0, 1, 1, 0),         UDim2.new(1, -1, 0, 0))
end

local function PixelBevel(parent, theme, thickness, inset)
    thickness = thickness or 2
    local z = (parent.ZIndex or 1) + 1
    local lightRole = inset and "BevelDark" or "BevelLight"
    local darkRole  = inset and "BevelLight" or "BevelDark"
    local stroke = Create("UIStroke", {Color = theme.Border, Thickness = thickness, Parent = parent})
    stroke:SetAttribute("MC_Role", "Border")
    local function mk(name, role, size, pos)
        local f = Create("Frame", {Name = name, BackgroundColor3 = theme[role], BorderSizePixel = 0, Size = size, Position = pos, ZIndex = z, Parent = parent})
        f:SetAttribute("MC_Role", role)
    end
    mk("BevelTop",    lightRole, UDim2.new(1, -thickness * 2, 0, 1), UDim2.new(0, thickness, 0, thickness))
    mk("BevelLeft",   lightRole, UDim2.new(0, 1, 1, -thickness * 2), UDim2.new(0, thickness, 0, thickness))
    mk("BevelBottom", darkRole,  UDim2.new(1, -thickness * 2, 0, 1), UDim2.new(0, thickness, 1, -thickness - 1))
    mk("BevelRight",  darkRole,  UDim2.new(0, 1, 1, -thickness * 2), UDim2.new(1, -thickness - 1, 0, thickness))
end

local function PixelText(label, color)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(18, 16, 12)
    if color then label.TextColor3 = color end
end

local function AddPadding(frame, t, b, l, r)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, t or 6), PaddingBottom = UDim.new(0, b or 6),
        PaddingLeft = UDim.new(0, l or 8), PaddingRight = UDim.new(0, r or 8), Parent = frame,
    })
end

-- ================================================================
-- WINDOW
-- ================================================================
function MinecraftLib:CreateWindow(title, config)
    if type(title) == "table" then
        config = title
        title = config.Title or config.Name
    end
    config = config or {}

    local self = setmetatable({}, MinecraftLib)
    self._themeName = Themes[config.Theme] and config.Theme or "Overworld"
    self._theme = Themes[self._themeName]
    self._tabs, self._themedRefreshers, self._flags, self._keybinds = {}, {}, {}, {}
    self._activeTab = nil
    self._visible = true
    self._title = title or "Minecraft UI"
    self._mobile = IsMobile()
    self._toggleKey = ToKeyCode(config.ToggleKey) or Enum.KeyCode.RightShift
    self._configName = SafeName(config.ConfigFolder or self._title)
    self._openPopup = nil
    self._autoSave = config.AutoSave == true
    self._viewportScale = 1
    self._userScale = math.clamp(tonumber(config.Scale) or 1, 0.5, 1.5)

    function self:RegisterThemed(refreshFn, watchInstance)
        table.insert(self._themedRefreshers, refreshFn)
        if watchInstance then
            watchInstance.Destroying:Connect(function()
                local idx = table.find(self._themedRefreshers, refreshFn)
                if idx then table.remove(self._themedRefreshers, idx) end
            end)
        end
    end
    function self:RegisterFlag(flag, element)
        if flag then self._flags[flag] = element end
    end

    -- ---------------- textures ----------------
    local Textures, textureWaiters = {}, {}
    local function loadTex(key, url, filename)
        Textures[key] = LoadTexture(url, filename, function(assetId)
            Textures[key] = assetId
            for _, fn in ipairs(textureWaiters[key] or {}) do pcall(fn, assetId) end
            textureWaiters[key] = nil
        end)
    end
    loadTex("Dirt", TextureURLs.Dirt, "dirt.jpg")
    loadTex("OakPlanks", TextureURLs.OakPlanks, "oak_planks.png")
    loadTex("GrassBlock", TextureURLs.GrassBlock, "grass.png")
    loadTex("OverworldBg", TextureURLs.OverworldBg, "overworld_bg.png")
    loadTex("NetherBg", TextureURLs.NetherBg, "nether_bg.png")
    loadTex("EndBg", TextureURLs.EndBg, "end_bg.png")
    self._textures = Textures

    local function OnTextureReady(key, callback)
        if Textures[key] and Textures[key] ~= "" then callback(Textures[key]) return end
        textureWaiters[key] = textureWaiters[key] or {}
        table.insert(textureWaiters[key], callback)
    end
    local function BindImage(img, key, condition)
        if not key then img.Image = "" return end
        img.Image = Textures[key] or ""
        OnTextureReady(key, function(id)
            if img.Parent and (not condition or condition()) then img.Image = id end
        end)
    end

    -- ---------------- constants ----------------
    local mobile = self._mobile
    local WIN_W = (config.Size and config.Size.X) or (mobile and 340 or 600)
    local WIN_H = (config.Size and config.Size.Y) or (mobile and 300 or 440)
    local TAB_W = mobile and 90 or 140
    local TITLE_H = mobile and 36 or 42
    local FONT = Enum.Font.Arcade
    local FONT_TITLE = mobile and 14 or 16
    local FONT_BODY = mobile and 12 or 13

    -- ---------------- gui root ----------------
    local guiParent = GetGuiParent()
    local old = guiParent:FindFirstChild("MinecraftUI_v3")
    if old then old:Destroy() end

    local ScreenGui = Create("ScreenGui", {Name = "MinecraftUI_v3", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = guiParent})
    self._gui = ScreenGui

    local NotifContainer = Create("Frame", {Name = "NotifContainer", Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(1, -315, 0, 0), BackgroundTransparency = 1, ZIndex = 500, Parent = ScreenGui})
    Create("UIListLayout", {VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = NotifContainer})
    Create("UIPadding", {PaddingBottom = UDim.new(0, 14), Parent = NotifContainer})
    self._notifContainer = NotifContainer

    -- Tooltip
    local Tooltip = Create("TextLabel", {
        Name = "Tooltip", AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = self._theme.Notification, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, Text = "", TextColor3 = self._theme.TextPrimary, TextSize = 11, Font = FONT, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, Visible = false, ZIndex = 3000, Parent = ScreenGui,
    })
    PixelText(Tooltip); AddPadding(Tooltip, 4, 4, 7, 7); PixelBevel(Tooltip, self._theme, 1)
    Create("UISizeConstraint", {MaxSize = Vector2.new(240, math.huge), Parent = Tooltip})

    local function PlaceTooltip(pos)
        local vp, s = Viewport(), Tooltip.AbsoluteSize
        Tooltip.Position = UDim2.fromOffset(math.clamp(pos.X + 14, 4, math.max(4, vp.X - s.X - 4)), math.clamp(pos.Y + 18, 4, math.max(4, vp.Y - s.Y - 4)))
    end
    function self:_AttachTooltip(gui, text)
        if not text or mobile then return end
        gui.MouseEnter:Connect(function()
            Tooltip.Text = tostring(text); Tooltip.Visible = true
            PlaceTooltip(UserInputService:GetMouseLocation())
        end)
        gui.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement and Tooltip.Visible then PlaceTooltip(inp.Position) end
        end)
        gui.MouseLeave:Connect(function() Tooltip.Visible = false end)
        gui.Destroying:Connect(function() Tooltip.Visible = false end)
    end

    -- ---------------- main frame ----------------
    local Main = Create("Frame", {
        Name = "Main", Size = UDim2.new(0, WIN_W, 0, WIN_H), Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2),
        BackgroundColor3 = self._theme.Background, BorderSizePixel = 0, ZIndex = 1, Parent = ScreenGui,
    })
    PixelBevel(Main, self._theme, 2)
    self._main = Main
    self._shadow = CreateDropShadow(Main, self._theme, 6, 14)
    local MainGradient = Create("UIGradient", {Enabled = false, Parent = Main})
    local MainBg = Create("ImageLabel", {Name = "BackgroundImage", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Stretch, ZIndex = 0, Parent = Main})
    local UIScaleInst = Create("UIScale", {Scale = 1, Parent = Main})
    self._uiScale = UIScaleInst

    -- ---------------- title bar ----------------
    local TitleBar = Create("Frame", {Name = "TitleBar", Size = UDim2.new(1, 0, 0, TITLE_H), BackgroundColor3 = self._theme.TertiaryBG, BorderSizePixel = 0, ZIndex = 2, Parent = Main})
    PixelBevel(TitleBar, self._theme, 2)
    local PlanksTexture = Create("ImageLabel", {Name = "PlanksTexture", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0, 64, 0, 64), ZIndex = 2, Parent = TitleBar})

    local function ApplyBackground(t, name)
        if t.Gradient then
            MainGradient.Color = t.Gradient
            MainGradient.Rotation = t.GradientRotation or 90
            MainGradient.Enabled = true
            Main.BackgroundColor3 = Color3.new(1, 1, 1)
        else
            MainGradient.Enabled = false
            Main.BackgroundColor3 = t.Background
        end
        BindImage(MainBg, t.BackgroundImage, function() return self._themeName == name end)
        BindImage(PlanksTexture, t.TitleBarImage, function() return self._themeName == name end)
    end
    ApplyBackground(self._theme, self._themeName)

    for _, pos in ipairs({{0, 4, 0, 4}, {1, -8, 0, 4}, {0, 4, 1, -8}, {1, -8, 1, -8}}) do
        local dot = Create("Frame", {Size = UDim2.new(0, 4, 0, 4), Position = UDim2.new(pos[1], pos[2], pos[3], pos[4]), BackgroundColor3 = self._theme.BevelDark, BorderSizePixel = 0, ZIndex = 4, Parent = TitleBar})
        dot:SetAttribute("MC_Role", "BevelDark")
    end

    local IconSize = mobile and 20 or 24
    local GrassIcon = Create("ImageLabel", {Size = UDim2.new(0, IconSize, 0, IconSize), Position = UDim2.new(0, 10, 0.5, -IconSize / 2), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Stretch, ZIndex = 4, Parent = TitleBar})
    BindImage(GrassIcon, "GrassBlock")

    local TitleLabel = Create("TextLabel", {
        Name = "Title", Size = UDim2.new(1, -200, 1, 0), Position = UDim2.new(0, IconSize + 16, 0, 0), BackgroundTransparency = 1,
        Text = self._title, TextColor3 = self._theme.Title, TextSize = FONT_TITLE, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4, Parent = TitleBar,
    })
    PixelText(TitleLabel)

    local BtnSize = mobile and 26 or 28
    local function TitleButton(name, text, x, color, w, h)
        local b = Create("TextButton", {
            Name = name, Size = UDim2.new(0, w or BtnSize, 0, h or BtnSize), Position = UDim2.new(1, x, 0.5, -(h or BtnSize) / 2),
            BackgroundColor3 = color, Text = text, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = h and 10 or 14,
            Font = FONT, BorderSizePixel = 0, ZIndex = 5, Parent = TitleBar,
        })
        PixelText(b); PixelBevel(b, self._theme, 1); CreateInsetShadow(b, self._theme, 2)
        return b
    end
    local CloseBtn    = TitleButton("Close", "×", -BtnSize - 6, self._theme.CloseBtn)
    local MinimizeBtn = TitleButton("Minimize", "–", -BtnSize * 2 - 10, self._theme.SecondaryBG)
    local ThemeBtn    = TitleButton("Theme", "OW", -BtnSize * 2 - (mobile and 76 or 90), self._theme.SecondaryBG, mobile and 52 or 64, mobile and 20 or 22)
    ThemeBtn.TextColor3 = self._theme.TextSecondary
    self:_AttachTooltip(ThemeBtn, "Сменить тему")
    self:_AttachTooltip(MinimizeBtn, "Свернуть (двойной клик по заголовку — развернуть)")

    -- ---------------- tab bar / content ----------------
    local TabBar = Create("Frame", {Name = "TabBar", Size = UDim2.new(0, TAB_W, 1, -TITLE_H), Position = UDim2.new(0, 0, 0, TITLE_H), BackgroundColor3 = self._theme.SecondaryBG, BorderSizePixel = 0, ZIndex = 2, Parent = Main})
    PixelBevel(TabBar, self._theme, 2)
    local TabList = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = mobile and 5 or 4,
        ScrollBarImageColor3 = self._theme.Scrollbar, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 3, Parent = TabBar,
    })
    Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabList})
    AddPadding(TabList, 6, 6, 5, 5)
    self._tabList = TabList

    local ContentArea = Create("Frame", {
        Name = "Content", Size = UDim2.new(1, -TAB_W - 6, 1, -(TITLE_H + 4)), Position = UDim2.new(0, TAB_W + 3, 0, TITLE_H + 2),
        BackgroundColor3 = self._theme.Glass, BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 2, Parent = Main,
    })
    PixelBevel(ContentArea, self._theme, 1, true)
    self._contentArea = ContentArea

    local Divider = Create("Frame", {Size = UDim2.new(0, 2, 1, -TITLE_H), Position = UDim2.new(0, TAB_W, 0, TITLE_H), BackgroundColor3 = self._theme.Border, BorderSizePixel = 0, ZIndex = 3, Parent = Main})
    Divider:SetAttribute("MC_Role", "Border")
    local BottomBar = Create("Frame", {Size = UDim2.new(1, 0, 0, 5), Position = UDim2.new(0, 0, 1, -5), BackgroundColor3 = self._theme.Accent, BorderSizePixel = 0, ZIndex = 3, Parent = Main})

    -- ---------------- window state ----------------
    local _minimized, _maximized = false, false
    local _savedSize, _savedPos = Main.Size, Main.Position
    MakeDraggable(Main, TitleBar, function() return not _maximized and Main.AnchorPoint.X == 0 end)

    -- ---------------- resize handle ----------------
    local RESIZE_SIZE, MIN_W, MIN_H = 18, 300, 200
    local ResizeHandle = Create("Frame", {
        Name = "ResizeHandle", Size = UDim2.new(0, RESIZE_SIZE, 0, RESIZE_SIZE), Position = UDim2.new(1, -RESIZE_SIZE, 1, -RESIZE_SIZE),
        BackgroundColor3 = self._theme.Accent, BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = 10, Parent = Main,
    })
    for i = 1, 3 do
        local off = i * 5
        local s = Create("Frame", {
            Size = UDim2.new(0, 2, 0, RESIZE_SIZE - off + 2), Position = UDim2.new(0, RESIZE_SIZE - off - 2, 1, -(RESIZE_SIZE - off + 2)),
            BackgroundColor3 = self._theme.BevelLight, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 11, Parent = ResizeHandle,
        })
        s:SetAttribute("MC_Role", "BevelLight")
    end
    do
        local resizing, resizeStart, originW, originH = false, nil, 0, 0
        local c1 = ResizeHandle.InputBegan:Connect(function(input)
            if _minimized or not IsPress(input) then return end
            resizing, resizeStart = true, input.Position
            originW, originH = Main.Size.X.Offset, Main.Size.Y.Offset
            Tween(ResizeHandle, {BackgroundTransparency = 0.1}, 0.1)
        end)
        local c2 = UserInputService.InputChanged:Connect(function(input)
            if not resizing or not IsMove(input) then return end
            local scale = math.max(UIScaleInst.Scale, 0.01)
            local delta = (input.Position - resizeStart) / scale
            local vp = Viewport()
            Main.Size = UDim2.new(0, math.clamp(originW + delta.X, MIN_W, vp.X / scale), 0, math.clamp(originH + delta.Y, MIN_H, vp.Y / scale))
            _maximized = false
        end)
        local c3 = UserInputService.InputEnded:Connect(function(input)
            if IsPress(input) and resizing then
                resizing = false
                Tween(ResizeHandle, {BackgroundTransparency = 0.45}, 0.1)
            end
        end)
        ResizeHandle.Destroying:Connect(function() c1:Disconnect(); c2:Disconnect(); c3:Disconnect() end)
        ResizeHandle.MouseEnter:Connect(function() Tween(ResizeHandle, {BackgroundTransparency = 0.2}, 0.1) end)
        ResizeHandle.MouseLeave:Connect(function() if not resizing then Tween(ResizeHandle, {BackgroundTransparency = 0.45}, 0.1) end end)
    end

    -- ---------------- popups ----------------
    local function ClosePopups()
        if self._openPopup then self._openPopup.Close() end
    end

    local function AttachPopup(anchor, popup, scrollFrame, computeSize, onOpen, onClose)
        local open, conns, ctrl = false, {}, {}
        local function Reposition()
            local w, h, align = computeSize()
            popup.Size = UDim2.fromOffset(w, h)
            local ap, as = anchor.AbsolutePosition, anchor.AbsoluteSize
            local vp = Viewport()
            local y = (ap.Y + as.Y + 2 + h <= vp.Y - 4) and (ap.Y + as.Y + 2) or (ap.Y - h - 2)
            local x = (align == "right") and (ap.X + as.X - w) or ap.X
            popup.Position = UDim2.fromOffset(math.clamp(x, 4, math.max(4, vp.X - w - 4)), math.clamp(y, 4, math.max(4, vp.Y - h - 4)))
        end
        function ctrl.Close()
            if not open then return end
            open = false
            popup.Visible = false
            for _, c in ipairs(conns) do c:Disconnect() end
            table.clear(conns)
            if self._openPopup == ctrl then self._openPopup = nil end
            if onClose then onClose() end
        end
        function ctrl.Open()
            if open then return end
            if self._openPopup and self._openPopup ~= ctrl then self._openPopup.Close() end
            open = true
            self._openPopup = ctrl
            Reposition()
            popup.Visible = true
            table.insert(conns, UserInputService.InputBegan:Connect(function(inp)
                if not IsPress(inp) then return end
                if not PointInside(popup, inp.Position) and not PointInside(anchor, inp.Position) then ctrl.Close() end
            end))
            if scrollFrame and scrollFrame:IsA("ScrollingFrame") then
                table.insert(conns, scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(ctrl.Close))
                table.insert(conns, scrollFrame:GetPropertyChangedSignal("Visible"):Connect(function() if not scrollFrame.Visible then ctrl.Close() end end))
            end
            table.insert(conns, Main:GetPropertyChangedSignal("AbsolutePosition"):Connect(Reposition))
            table.insert(conns, Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(Reposition))
            table.insert(conns, Main:GetPropertyChangedSignal("Visible"):Connect(ctrl.Close))
            if onOpen then onOpen() end
        end
        function ctrl.Toggle() if open then ctrl.Close() else ctrl.Open() end end
        function ctrl.IsOpen() return open end
        ctrl.Reposition = Reposition
        anchor.Destroying:Connect(function()
            ctrl.Close()
            if popup.Parent then popup:Destroy() end
        end)
        return ctrl
    end

    -- ---------------- minimize / maximize ----------------
    local function Minimize()
        ClosePopups()
        if _minimized then
            _minimized = false
            MinimizeBtn.Text = "–"
            Main.ClipsDescendants = false
            ResizeHandle.Visible = true
            Tween(Main, {Size = _savedSize}, 0.25, Enum.EasingStyle.Back)
        else
            _savedSize = Main.Size
            _minimized = true
            MinimizeBtn.Text = "□"
            ResizeHandle.Visible = false
            Tween(Main, {Size = UDim2.new(0, Main.Size.X.Offset, 0, TITLE_H)}, 0.22)
            task.delay(0.23, function() if _minimized and Main.Parent then Main.ClipsDescendants = true end end)
        end
    end

    local function Maximize()
        if not self._visible or Main.AnchorPoint.X ~= 0 then return end
        ClosePopups()
        if _minimized then Minimize() end
        local vp = Viewport()
        if _maximized then
            _maximized = false
            Tween(Main, {Size = _savedSize, Position = _savedPos}, 0.25, Enum.EasingStyle.Back)
        else
            _savedSize, _savedPos = Main.Size, Main.Position
            _maximized = true
            local scale, m = math.max(UIScaleInst.Scale, 0.01), 4
            Tween(Main, {Size = UDim2.new(0, (vp.X - m * 2) / scale, 0, (vp.Y - m * 2) / scale), Position = UDim2.new(0, m, 0, m)}, 0.25)
        end
    end

    local _lastTitleClick = 0
    TitleBar.InputBegan:Connect(function(input)
        if IsPress(input) then
            local now = os.clock()
            if now - _lastTitleClick < 0.35 then Maximize(); _lastTitleClick = 0 else _lastTitleClick = now end
        end
    end)

    MinimizeBtn.MouseEnter:Connect(function() Tween(MinimizeBtn, {BackgroundColor3 = Color3.fromRGB(180, 140, 40)}, 0.15) end)
    MinimizeBtn.MouseLeave:Connect(function() Tween(MinimizeBtn, {BackgroundColor3 = self._theme.SecondaryBG}, 0.15) end)
    MinimizeBtn.Activated:Connect(Minimize)
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(220, 70, 60)}, 0.15) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3 = self._theme.CloseBtn}, 0.15) end)
    CloseBtn.Activated:Connect(function()
        ClosePopups()
        self:Hide()
        task.delay(0.3, function() self:Destroy() end)
    end)

    -- ---------------- theme button ----------------
    local function ThemeOrder()
        local order = {"Overworld", "Nether", "End", "Sea", "Sky"}
        local extra = {}
        for name in pairs(Themes) do if not table.find(order, name) then table.insert(extra, name) end end
        table.sort(extra)
        for _, n in ipairs(extra) do table.insert(order, n) end
        return order
    end
    local themeShort = {Overworld = "OW", Nether = "NT", End = "ED", Sea = "SE", Sky = "SK"}
    local function ShortName(n) return themeShort[n] or n:sub(1, 2):upper() end
    ThemeBtn.Text = ShortName(self._themeName)
    ThemeBtn.Activated:Connect(function()
        local order = ThemeOrder()
        local idx = table.find(order, self._themeName) or 1
        self:SetTheme(order[(idx % #order) + 1])
    end)

    -- ---------------- global input ----------------
    self._inputConn = UserInputService.InputBegan:Connect(function(input, gp)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == Enum.KeyCode.Escape and self._openPopup then ClosePopups() return end
        if gp then return end
        if not mobile and input.KeyCode == self._toggleKey then self:ToggleVisible() return end
        for _, kb in ipairs(self._keybinds) do
            if kb.key == input.KeyCode and not kb.listening and not kb.cooldown then Invoke(kb.callback, true) end
        end
    end)
    self._inputEndConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for _, kb in ipairs(self._keybinds) do
            if kb.key == input.KeyCode and kb.mode == "Hold" then Invoke(kb.callback, false) end
        end
    end)

    -- ---------------- visibility / scale ----------------
    local function EffectiveScale() return self._viewportScale * self._userScale end
    local function ToCenterAnchor()
        if Main.AnchorPoint.X > 0 then return end
        local half = Main.AbsoluteSize / 2
        Main.AnchorPoint = Vector2.new(0.5, 0.5)
        Main.Position = Main.Position + UDim2.fromOffset(half.X, half.Y)
    end
    local function ToCornerAnchor()
        if Main.AnchorPoint.X == 0 then return end
        local half = Main.AbsoluteSize / 2
        Main.AnchorPoint = Vector2.zero
        Main.Position = Main.Position - UDim2.fromOffset(half.X, half.Y)
    end

    local visTween
    function self:Show()
        if self._visible then return end
        self._visible = true
        if visTween then visTween:Cancel() end
        Main.Visible = true
        self._shadow.Visible = true
        local tw = Tween(UIScaleInst, {Scale = EffectiveScale()}, 0.3, Enum.EasingStyle.Back)
        Tween(self._shadow, {ImageTransparency = self._shadow:GetAttribute("BaseTransparency") or 0.3}, 0.3)
        visTween = tw
        tw.Completed:Connect(function(state)
            if state == Enum.PlaybackState.Completed and self._visible and visTween == tw then ToCornerAnchor() end
        end)
    end
    function self:Hide()
        if not self._visible then return end
        self._visible = false
        ClosePopups()
        Tooltip.Visible = false
        if visTween then visTween:Cancel() end
        ToCenterAnchor()
        local tw = Tween(UIScaleInst, {Scale = 0}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        Tween(self._shadow, {ImageTransparency = 1}, 0.2)
        visTween = tw
        tw.Completed:Connect(function(state)
            if state == Enum.PlaybackState.Completed and not self._visible and visTween == tw then
                Main.Visible = false
                self._shadow.Visible = false
            end
        end)
    end
    function self:ToggleVisible() if self._visible then self:Hide() else self:Show() end end
    function self:SetToggleKey(key) self._toggleKey = ToKeyCode(key) or self._toggleKey end
    function self:SetTitle(text) self._title = tostring(text); TitleLabel.Text = self._title end
    function self:SetScale(mult)
        self._userScale = math.clamp(tonumber(mult) or 1, 0.5, 1.5)
        if self._visible and Main.AnchorPoint.X == 0 then Tween(UIScaleInst, {Scale = EffectiveScale()}, 0.15) end
    end

    if mobile then
        local ToggleBtn = Create("TextButton", {
            Name = "MobileToggle", Size = UDim2.new(0, 48, 0, 48), Position = UDim2.new(1, -60, 1, -120), BackgroundColor3 = self._theme.TertiaryBG,
            Text = "M", TextColor3 = self._theme.TextPrimary, TextSize = 18, Font = FONT, BorderSizePixel = 0, ZIndex = 50, Parent = ScreenGui,
        })
        PixelText(ToggleBtn); PixelBevel(ToggleBtn, self._theme, 2); CreateInsetShadow(ToggleBtn, self._theme, 2)
        MakeDraggable(ToggleBtn, ToggleBtn)
        ToggleBtn.Activated:Connect(function() self:ToggleVisible() end)
        self._mobileToggle = ToggleBtn
    end

    local viewportDebounce = false
    local function AdjustToViewport()
        if viewportDebounce then return end
        viewportDebounce = true
        task.delay(0.1, function()
            viewportDebounce = false
            local vp = Viewport()
            self._viewportScale = math.clamp(math.min(vp.X / (WIN_W + 50), vp.Y / (WIN_H + 50), 1), 0.5, 1)
            if self._visible and Main.AnchorPoint.X == 0 then Tween(UIScaleInst, {Scale = EffectiveScale()}, 0.15) end
        end)
    end
    local viewportConn
    local function WatchCamera()
        if viewportConn then viewportConn:Disconnect() end
        local camera = workspace.CurrentCamera
        if camera then viewportConn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(AdjustToViewport) end
        AdjustToViewport()
    end
    self._cameraWatchConn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(WatchCamera)
    self._getViewportConn = function() return viewportConn end
    WatchCamera()

    -- ---------------- watermark ----------------
    local Watermark = Create("Frame", {
        Name = "Watermark", AutomaticSize = Enum.AutomaticSize.XY, Position = UDim2.fromOffset(10, 10), BackgroundColor3 = self._theme.Notification,
        BackgroundTransparency = 0.1, BorderSizePixel = 0, Visible = false, ZIndex = 400, Parent = ScreenGui,
    })
    PixelBevel(Watermark, self._theme, 1); AddPadding(Watermark, 4, 4, 8, 8)
    local WMAccent = Create("Frame", {Size = UDim2.new(0, 3, 1, 0), Position = UDim2.new(0, -8, 0, 0), BackgroundColor3 = self._theme.Accent, BorderSizePixel = 0, ZIndex = 401, Parent = Watermark})
    local WMLabel = Create("TextLabel", {AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Text = "", TextColor3 = self._theme.TextPrimary, TextSize = 12, Font = FONT, ZIndex = 401, Parent = Watermark})
    PixelText(WMLabel)
    MakeDraggable(Watermark)
    self._wmText = self._title
    local wmConn, wmFrames, wmAccum = nil, 0, 0
    function self:SetWatermark(enabled, text)
        if text then self._wmText = tostring(text) end
        Watermark.Visible = enabled and true or false
        if enabled and not wmConn then
            wmConn = RunService.Heartbeat:Connect(function(dt)
                wmFrames += 1; wmAccum += dt
                if wmAccum >= 0.5 then
                    local fps = math.floor(wmFrames / wmAccum + 0.5)
                    wmFrames, wmAccum = 0, 0
                    local ok, ping = pcall(function() return LocalPlayer:GetNetworkPing() * 1000 end)
                    WMLabel.Text = string.format("%s  |  %d FPS  |  %d ms", self._wmText, fps, ok and math.floor(ping + 0.5) or 0)
                end
            end)
        elseif not enabled and wmConn then
            wmConn:Disconnect(); wmConn = nil
        end
    end
    self._stopWatermark = function() if wmConn then wmConn:Disconnect(); wmConn = nil end end

    -- ---------------- theme switching ----------------
    function self:SetTheme(name)
        local t = Themes[name]
        if not t then return end
        self._theme, self._themeName = t, name
        ThemeBtn.Text = ShortName(name)
        ApplyBackground(t, name)
        TitleBar.BackgroundColor3 = t.TertiaryBG
        TabBar.BackgroundColor3 = t.SecondaryBG
        ContentArea.BackgroundColor3 = t.Glass
        BottomBar.BackgroundColor3 = t.Accent
        TitleLabel.TextColor3 = t.Title
        CloseBtn.BackgroundColor3 = t.CloseBtn
        MinimizeBtn.BackgroundColor3 = t.SecondaryBG
        ThemeBtn.BackgroundColor3 = t.SecondaryBG
        ThemeBtn.TextColor3 = t.TextSecondary
        ResizeHandle.BackgroundColor3 = t.Accent
        Tooltip.BackgroundColor3 = t.Notification
        Tooltip.TextColor3 = t.TextPrimary
        Watermark.BackgroundColor3 = t.Notification
        WMAccent.BackgroundColor3 = t.Accent
        WMLabel.TextColor3 = t.TextPrimary
        self._shadow.ImageColor3 = t.Shadow
        if self._mobileToggle then
            self._mobileToggle.BackgroundColor3 = t.TertiaryBG
            self._mobileToggle.TextColor3 = t.TextPrimary
        end
        for _, inst in ipairs(ScreenGui:GetDescendants()) do
            local role = inst:GetAttribute("MC_Role")
            if role and t[role] then
                if inst:IsA("UIStroke") then inst.Color = t[role]
                elseif inst:IsA("GuiObject") then inst.BackgroundColor3 = t[role] end
            elseif inst:IsA("ScrollingFrame") then
                inst.ScrollBarImageColor3 = t.Scrollbar
            end
        end
        for _, tabInfo in ipairs(self._tabs) do
            local isActive = (tabInfo == self._activeTab)
            tabInfo.btn.BackgroundColor3 = isActive and t.TabActive or t.TabInactive
            tabInfo.btn.TextColor3 = isActive and t.TextPrimary or t.TextSecondary
            tabInfo.activeBar.BackgroundColor3 = t.Accent
        end
        for _, refresh in ipairs(self._themedRefreshers) do pcall(refresh, t) end
    end
    function self:GetTheme() return self._theme, self._themeName end
    function self:GetThemes() return ThemeOrder() end

    -- ---------------- config system ----------------
    local function ConfigDir() return CONFIG_FOLDER .. "/" .. self._configName end

    function self:SaveConfig(name)
        if not HasFS then return false, "No filesystem" end
        name = SafeName(name)
        EnsureFolder(FOLDER); EnsureFolder(CONFIG_FOLDER); EnsureFolder(ConfigDir())
        local data = {}
        for flag, element in pairs(self._flags) do
            if element._Save then
                local ok, v = pcall(element._Save)
                if ok then data[flag] = v end
            elseif element.Get then
                local ok, v = pcall(element.Get, element)
                if ok then data[flag] = Serialize(v) end
            end
        end
        local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
        if not ok then return false, json end
        return pcall(writefile, ConfigDir() .. "/" .. name .. ".json", json)
    end

    function self:LoadConfig(name)
        if not HasFS then return false, "No filesystem" end
        name = SafeName(name)
        local path = ConfigDir() .. "/" .. name .. ".json"
        if not isfile(path) then return false, "Config not found" end
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if not ok or type(data) ~= "table" then return false, "Bad JSON" end
        self._loading = true
        for flag, raw in pairs(data) do
            local element = self._flags[flag]
            if element then
                if element._Load then pcall(element._Load, raw)
                elseif element.Set then pcall(element.Set, element, Deserialize(raw)) end
            end
        end
        self._loading = false
        return true
    end

    function self:GetConfigs()
        local out = {}
        if not HasFS or not isfolder(ConfigDir()) then return out end
        for _, file in ipairs(listfiles(ConfigDir())) do
            local n = file:match("([^/\\]+)%.json$")
            if n then table.insert(out, n) end
        end
        table.sort(out)
        return out
    end

    function self:DeleteConfig(name)
        if not HasFS or not delfile then return false end
        local path = ConfigDir() .. "/" .. SafeName(name) .. ".json"
        if isfile(path) then pcall(delfile, path) return true end
        return false
    end

    local saveScheduled = false
    function self:_FlagChanged()
        if not self._autoSave or self._loading or saveScheduled then return end
        saveScheduled = true
        task.delay(1, function()
            saveScheduled = false
            if self._gui then self:SaveConfig("autosave") end
        end)
    end
    function self:LoadAutoSave() return self:LoadConfig("autosave") end
    if self._autoSave and config.AutoLoad ~= false then
        task.delay(1, function() if self._gui then self:LoadAutoSave() end end)
    end

    -- ================================================================
    -- DIALOG
    -- ================================================================
    function self:Dialog(o)
        o = o or {}
        local t = self._theme
        ClosePopups()
        local Overlay = Create("TextButton", {
            Name = "Dialog", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 2000, Parent = ScreenGui,
        })
        Tween(Overlay, {BackgroundTransparency = 0.45}, 0.2)
        local Box = Create("Frame", {
            Size = UDim2.fromOffset(mobile and 280 or 340, 0), AutomaticSize = Enum.AutomaticSize.Y, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = t.Background, BorderSizePixel = 0, ZIndex = 2001, Parent = Overlay,
        })
        PixelBevel(Box, t, 2)
        local scale = Create("UIScale", {Scale = 0.6, Parent = Box})
        Tween(scale, {Scale = 1}, 0.25, Enum.EasingStyle.Back)
        AddPadding(Box, 10, 10, 12, 12)
        Create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Box})

        local tl = Create("TextLabel", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = tostring(o.Title or "Dialog"), TextColor3 = t.Accent, TextSize = FONT_TITLE, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, ZIndex = 2002, Parent = Box})
        PixelText(tl)
        local cl = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = tostring(o.Content or ""), TextColor3 = t.TextSecondary,
            TextSize = FONT_BODY, Font = FONT, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, ZIndex = 2002, Parent = Box,
        })
        PixelText(cl)
        local Row = Create("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = 3, ZIndex = 2002, Parent = Box})
        Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Row})

        local closed = false
        local function Close()
            if closed then return end
            closed = true
            Tween(scale, {Scale = 0.6}, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            Tween(Overlay, {BackgroundTransparency = 1}, 0.15)
            task.delay(0.16, function() if Overlay.Parent then Overlay:Destroy() end end)
        end
        local buttons = o.Buttons or {{Text = "OK"}}
        for i, b in ipairs(buttons) do
            local btn = Create("TextButton", {
                Size = UDim2.fromOffset(math.max(70, #tostring(b.Text or "OK") * 9 + 20), 28), BackgroundColor3 = i == 1 and t.Accent or t.SecondaryBG,
                Text = tostring(b.Text or "OK"), TextColor3 = t.TextPrimary, TextSize = FONT_BODY, Font = FONT, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 2003, Parent = Row,
            })
            PixelText(btn); PixelBevel(btn, t, 1); CreateInsetShadow(btn, t, 2)
            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = t.AccentHover}, 0.12); btn.TextColor3 = t.TextHover end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = i == 1 and t.Accent or t.SecondaryBG}, 0.12); btn.TextColor3 = t.TextPrimary end)
            btn.Activated:Connect(function() Close(); Invoke(b.Callback) end)
        end
        return {Close = Close}
    end

    -- ================================================================
    -- TABS
    -- ================================================================
    function self:AddTab(name)
        local icon
        if type(name) == "table" then icon = name.Icon; name = name.Name or name.Title or name[1] end
        name = tostring(name or "Tab")
        local win = self
        local t = self._theme

        local TabBtn = Create("TextButton", {
            Name = "Tab_" .. name, Size = UDim2.new(1, 0, 0, mobile and 36 or 32), BackgroundColor3 = t.TabInactive, Text = name,
            TextColor3 = t.TextSecondary, TextSize = FONT_BODY, Font = FONT, BorderSizePixel = 0, LayoutOrder = #self._tabs + 1,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4, Parent = self._tabList,
        })
        PixelText(TabBtn); PixelBevel(TabBtn, t, 1); CreateInsetShadow(TabBtn, t, 2)
        if icon then
            Create("ImageLabel", {Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 7, 0.5, -8), BackgroundTransparency = 1, Image = icon, ZIndex = 6, Parent = TabBtn})
            AddPadding(TabBtn, 0, 0, 26, 4)
            TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        end
        local ActiveBar = Create("Frame", {Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = t.Accent, BorderSizePixel = 0, Visible = false, ZIndex = 6, Parent = TabBtn})

        local ContentScroll = Create("ScrollingFrame", {
            Name = "TabContent_" .. name, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = mobile and 5 or 4,
            ScrollBarImageColor3 = t.Scrollbar, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, ZIndex = 3, Parent = self._contentArea,
        })
        Create("UIListLayout", {Padding = UDim.new(0, mobile and 6 or 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ContentScroll})
        AddPadding(ContentScroll, 8, 8, 8, 8)

        local tabInfo = {name = name, btn = TabBtn, content = ContentScroll, activeBar = ActiveBar}
        table.insert(self._tabs, tabInfo)

        local function SelectThis()
            ClosePopups()
            local th = self._theme
            for _, ti in ipairs(self._tabs) do
                Tween(ti.btn, {BackgroundColor3 = th.TabInactive}, 0.18)
                ti.btn.TextColor3 = th.TextSecondary
                ti.activeBar.Visible = false
                ti.content.Visible = false
            end
            Tween(TabBtn, {BackgroundColor3 = th.TabActive}, 0.18)
            TabBtn.TextColor3 = th.TextPrimary
            ActiveBar.Visible = true
            ContentScroll.Visible = true
            self._activeTab = tabInfo
        end
        tabInfo.select = SelectThis
        TabBtn.Activated:Connect(SelectThis)
        TabBtn.MouseEnter:Connect(function()
            if self._activeTab ~= tabInfo then Tween(TabBtn, {BackgroundColor3 = self._theme.TertiaryBG}, 0.15); TabBtn.TextColor3 = self._theme.TextHover end
        end)
        TabBtn.MouseLeave:Connect(function()
            if self._activeTab ~= tabInfo then Tween(TabBtn, {BackgroundColor3 = self._theme.TabInactive}, 0.15); TabBtn.TextColor3 = self._theme.TextSecondary end
        end)
        if #self._tabs == 1 then SelectThis() end

        -- ------------------------------------------------------------
        local Tab = {}
        Tab.__index = Tab
        Tab._parent, Tab._scroll, Tab._window, Tab.Name = ContentScroll, ContentScroll, self, name

        local layoutOrder = 0
        local function NextOrder() layoutOrder += 1 return layoutOrder end
        local rowH, sliderH, textboxH = (mobile and 42 or 36), (mobile and 56 or 48), (mobile and 54 or 46)

        local function Fire(o, ...)
            Invoke(o.Callback, ...)
            if o.Flag then win:_FlagChanged(o.Flag) end
        end

        local function MakeSlot(height, parent)
            local th = win._theme
            local row = Create("Frame", {
                Size = UDim2.new(1, 0, 0, height or rowH), BackgroundColor3 = th.Glass, BackgroundTransparency = 0.25,
                BorderSizePixel = 0, LayoutOrder = NextOrder(), ZIndex = 4, Parent = parent,
            })
            PixelBevel(row, th, 1, true)
            return row
        end

        local function BaseElement(row)
            local el = {Instance = row, _enabled = true}
            local overlay
            function el:Destroy() if row.Parent then row:Destroy() end end
            function el:SetVisible(v) row.Visible = v and true or false end
            function el:SetEnabled(v)
                v = v and true or false
                el._enabled = v
                if not v and not overlay then
                    overlay = Create("TextButton", {
                        Name = "DisabledOverlay", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.55,
                        Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 20, Parent = row,
                    })
                end
                if overlay then overlay.Visible = not v end
            end
            function el:IsEnabled() return el._enabled end
            return el
        end

        local function Finish(el, o, row)
            win:_AttachTooltip(row, o.Tooltip)
            win:RegisterFlag(o.Flag, el)
            return el
        end

        local function MakeLabel(parent, text, size, pos, color, align)
            local l = Create("TextLabel", {
                Name = "ItemLabel", Size = size, Position = pos, BackgroundTransparency = 1, Text = tostring(text), TextColor3 = color, TextSize = FONT_BODY,
                Font = FONT, TextXAlignment = align or Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5, Parent = parent,
            })
            PixelText(l)
            return l
        end

        -- ============================ BUTTON ============================
        function Tab:AddButton(text, callback)
            local o = Opts(text, {"Name", "Callback"}, callback)
            local t2 = win._theme
            local row = MakeSlot(rowH, self._parent)
            local basePos = UDim2.new(0, 7, 0.5, -(rowH - 10) / 2)
            local Btn = Create("TextButton", {
                Name = "ActionBtn", Size = UDim2.new(1, -14, 1, -10), Position = basePos, BackgroundColor3 = t2.Accent, BackgroundTransparency = 0.2,
                Text = "> " .. tostring(o.Name), TextColor3 = t2.TextPrimary, TextSize = FONT_BODY, Font = FONT, BorderSizePixel = 0,
                TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5, Parent = row,
            })
            PixelText(Btn); PixelBevel(Btn, t2, 1); CreateInsetShadow(Btn, t2, 2)
            Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = t2.AccentHover}, 0.18); Btn.TextColor3 = t2.TextHover end)
            Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = t2.Accent}, 0.18); Btn.TextColor3 = t2.TextPrimary; Btn.Position = basePos end)
            Btn.MouseButton1Down:Connect(function() Tween(Btn, {BackgroundColor3 = t2.AccentPress}, 0.1); Btn.Position = basePos + UDim2.fromOffset(1, 1) end)
            Btn.MouseButton1Up:Connect(function() Tween(Btn, {BackgroundColor3 = t2.AccentHover}, 0.15); Btn.Position = basePos end)
            Btn.Activated:Connect(function() Invoke(o.Callback) end)
            win:RegisterThemed(function(nt) t2 = nt; row.BackgroundColor3 = t2.Glass; Btn.BackgroundColor3 = t2.Accent; Btn.TextColor3 = t2.TextPrimary end, row)

            local el = BaseElement(row)
            el.Button = Btn
            function el:SetText(v) Btn.Text = "> " .. tostring(v) end
            function el:SetCallback(fn) o.Callback = fn end
            return Finish(el, o, row)
        end

        -- ============================ TOGGLE ============================
        function Tab:AddToggle(text, default, callback)
            local o = Opts(text, {"Name", "Default", "Callback", "Flag"}, default, callback)
            local t2 = win._theme
            local row = MakeSlot(rowH, self._parent)
            local state = o.Default and true or false

            local lbl = MakeLabel(row, o.Name, UDim2.new(1, -110, 1, 0), UDim2.new(0, 10, 0, 0), t2.TextPrimary)
            local trackW = mobile and 48 or 44
            local Track = Create("Frame", {
                Name = "ToggleTrack", Size = UDim2.new(0, trackW, 0, 20), Position = UDim2.new(1, -trackW - 10, 0.5, -10),
                BackgroundColor3 = state and t2.ToggleOn or t2.ToggleOff, BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 5, Parent = row,
            })
            PixelBevel(Track, t2, 1)
            local Knob = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14), Position = state and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3),
                BackgroundColor3 = Color3.fromRGB(240, 240, 240), BorderSizePixel = 0, ZIndex = 6, Parent = Track,
            })
            PixelBevel(Knob, t2, 1)
            local Hit = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 7, Parent = row})

            local function UpdateVisual()
                Tween(Track, {BackgroundColor3 = state and t2.ToggleOn or t2.ToggleOff}, 0.2, Enum.EasingStyle.Quad)
                Tween(Knob, {Position = state and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3)}, 0.2, Enum.EasingStyle.Back)
            end

            local el = BaseElement(row)
            function el:Set(v, silent)
                state = v and true or false
                UpdateVisual()
                if not silent then Fire(o, state) end
            end
            function el:Get() return state end
            function el:Toggle() el:Set(not state) end
            function el:SetText(v) lbl.Text = tostring(v) end

            -- Привязанная клавиша
            local KeyLbl
            if o.Keybind then
                local binding = {key = ToKeyCode(o.Keybind), callback = function() el:Toggle() end, mode = "Press"}
                table.insert(win._keybinds, binding)
                KeyLbl = MakeLabel(row, "[" .. (binding.key and binding.key.Name or "?") .. "]", UDim2.new(0, 50, 1, 0), UDim2.new(1, -trackW - 62, 0, 0), t2.Accent, Enum.TextXAlignment.Right)
                KeyLbl.TextSize = FONT_BODY - 2
                row.Destroying:Connect(function()
                    local idx = table.find(win._keybinds, binding)
                    if idx then table.remove(win._keybinds, idx) end
                end)
                function el:SetKeybind(k)
                    binding.key = ToKeyCode(k)
                    KeyLbl.Text = "[" .. (binding.key and binding.key.Name or "?") .. "]"
                end
            end

            Hit.Activated:Connect(function() el:Set(not state) end)
            Hit.MouseEnter:Connect(function() lbl.TextColor3 = t2.TextHover end)
            Hit.MouseLeave:Connect(function() lbl.TextColor3 = t2.TextPrimary end)
            win:RegisterThemed(function(nt)
                t2 = nt; row.BackgroundColor3 = t2.Glass; lbl.TextColor3 = t2.TextPrimary
                if KeyLbl then KeyLbl.TextColor3 = t2.Accent end
                UpdateVisual()
            end, row)
            if state then Invoke(o.Callback, state) end
            return Finish(el, o, row)
        end

        -- ============================ SLIDER ============================
        function Tab:AddSlider(text, min, max, default, callback)
            local o = Opts(text, {"Name", "Min", "Max", "Default", "Callback", "Flag"}, min, max, default, callback)
            local t2 = win._theme
            local row = MakeSlot(sliderH, self._parent)
            local scroll = self._scroll

            local lo, hi = tonumber(o.Min) or 0, tonumber(o.Max) or 100
            if lo > hi then lo, hi = hi, lo end
            local step = tonumber(o.Step) or 1
            if step <= 0 then step = 1 end
            local decimals = 0
            do local s = tostring(step); local dot = s:find("%.") if dot then decimals = #s - dot end end
            local range = hi - lo
            local suffix = o.Suffix or ""

            local function Snap(v)
                v = math.clamp(tonumber(v) or lo, lo, hi)
                v = math.clamp(lo + math.floor((v - lo) / step + 0.5) * step, lo, hi)
                return tonumber(string.format("%." .. decimals .. "f", v))
            end
            local function Fmt(v) return string.format("%." .. decimals .. "f", v) .. suffix end
            local val = Snap(o.Default or lo)

            local Header = Create("Frame", {Size = UDim2.new(1, 0, 0, mobile and 26 or 22), BackgroundTransparency = 1, ZIndex = 5, Parent = row})
            AddPadding(Header, 0, 0, 10, 8)
            local hl = MakeLabel(Header, o.Name, UDim2.new(0.6, 0, 1, 0), UDim2.new(0, 0, 0, 0), t2.TextPrimary)
            -- значение можно ввести вручную
            local ValBox = Create("TextBox", {
                Name = "ValueBox", Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0.6, 0, 0, 0), BackgroundTransparency = 1, Text = Fmt(val),
                TextColor3 = t2.TextSecondary, TextSize = FONT_BODY, Font = FONT, TextXAlignment = Enum.TextXAlignment.Right, ClearTextOnFocus = false, ZIndex = 6, Parent = Header,
            })
            PixelText(ValBox)

            local knobW, knobH = mobile and 12 or 8, mobile and 20 or 14
            local SliderBG = Create("Frame", {
                Name = "SliderBG", Size = UDim2.new(1, -18, 0, mobile and 14 or 10), Position = UDim2.new(0, 9, 0, mobile and 32 or 28),
                BackgroundColor3 = t2.SliderBG, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 5, Parent = row,
            })
            PixelBevel(SliderBG, t2, 1, true)
            local function Pct(v) return range == 0 and 0 or (v - lo) / range end
            local SliderFill = Create("Frame", {Name = "SliderFill", Size = UDim2.new(Pct(val), 0, 1, 0), BackgroundColor3 = t2.SliderFill, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 6, Parent = SliderBG})
            local SliderKnob = Create("Frame", {Size = UDim2.new(0, knobW, 0, knobH), Position = UDim2.new(Pct(val), -knobW / 2, 0.5, -knobH / 2), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 7, Parent = SliderBG})
            PixelBevel(SliderKnob, t2, 1)

            local function Render()
                local p = Pct(val)
                if not ValBox:IsFocused() then ValBox.Text = Fmt(val) end
                SliderFill.Size = UDim2.new(p, 0, 1, 0)
                SliderKnob.Position = UDim2.new(p, -knobW / 2, 0.5, -knobH / 2)
            end

            local el = BaseElement(row)
            function el:Set(v, silent) val = Snap(v); Render(); if not silent then Fire(o, val) end end
            function el:Get() return val end
            function el:SetRange(nmin, nmax)
                lo, hi = tonumber(nmin) or lo, tonumber(nmax) or hi
                if lo > hi then lo, hi = hi, lo end
                range = hi - lo
                el:Set(val, true)
            end

            ValBox.Focused:Connect(function() ValBox.Text = tostring(val); ValBox.TextColor3 = t2.TextHover end)
            ValBox.FocusLost:Connect(function()
                ValBox.TextColor3 = t2.TextSecondary
                local n = tonumber(ValBox.Text)
                if n then el:Set(n) else Render() end
            end)

            local dragging = false
            local function SetFromInput(inp)
                local absPos, absSize = SliderBG.AbsolutePosition.X, SliderBG.AbsoluteSize.X
                if absSize <= 0 then return end
                local newVal = Snap(lo + math.clamp((inp.Position.X - absPos) / absSize, 0, 1) * range)
                if newVal ~= val then val = newVal; Render(); Fire(o, val) end
            end
            SliderBG.InputBegan:Connect(function(inp)
                if IsPress(inp) then dragging = true; scroll.ScrollingEnabled = false; SetFromInput(inp) end
            end)
            local endedConn = UserInputService.InputEnded:Connect(function(inp)
                if IsPress(inp) and dragging then dragging = false; scroll.ScrollingEnabled = true end
            end)
            local changedConn = UserInputService.InputChanged:Connect(function(inp)
                if dragging and IsMove(inp) then SetFromInput(inp) end
            end)
            row.Destroying:Connect(function() endedConn:Disconnect(); changedConn:Disconnect(); scroll.ScrollingEnabled = true end)

            win:RegisterThemed(function(nt)
                t2 = nt
                row.BackgroundColor3 = t2.Glass; hl.TextColor3 = t2.TextPrimary; ValBox.TextColor3 = t2.TextSecondary
                SliderBG.BackgroundColor3 = t2.SliderBG; SliderFill.BackgroundColor3 = t2.SliderFill
            end, row)
            return Finish(el, o, row)
        end

        -- ============================ TEXTBOX ============================
        function Tab:AddTextbox(text, placeholder, callback)
            local o = Opts(text, {"Name", "Placeholder", "Callback", "Flag"}, placeholder, callback)
            local t2 = win._theme
            local row = MakeSlot(textboxH, self._parent)
            local lbl = MakeLabel(row, o.Name, UDim2.new(1, -20, 0, mobile and 20 or 18), UDim2.new(0, 10, 0, 4), t2.TextSecondary)
            lbl.TextSize = FONT_BODY - 1
            local Box = Create("TextBox", {
                Size = UDim2.new(1, -18, 0, mobile and 24 or 20), Position = UDim2.new(0, 9, 0, mobile and 26 or 24), BackgroundColor3 = t2.Background, BackgroundTransparency = 0.3,
                Text = tostring(o.Default or ""), PlaceholderText = o.Placeholder or "Type here...", PlaceholderColor3 = t2.TextDisabled, TextColor3 = t2.TextPrimary,
                TextSize = FONT_BODY, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, ClearTextOnFocus = false, ClipsDescendants = true, ZIndex = 5, Parent = row,
            })
            AddPadding(Box, 0, 0, 6, 6); PixelBevel(Box, t2, 1, true)
            Box.Focused:Connect(function() Tween(Box, {BackgroundColor3 = t2.SecondaryBG}, 0.15) end)
            Box.FocusLost:Connect(function(enter)
                Tween(Box, {BackgroundColor3 = t2.Background}, 0.15)
                if o.Numeric and not tonumber(Box.Text) then Box.Text = "" return end
                if enter or o.CallbackOnFocusLost then Fire(o, Box.Text) end
            end)
            if o.OnChange then Box:GetPropertyChangedSignal("Text"):Connect(function() Invoke(o.OnChange, Box.Text) end) end

            local el = BaseElement(row)
            el.Box = Box
            function el:Set(v, silent) Box.Text = tostring(v); if not silent then Fire(o, Box.Text) end end
            function el:Get() return Box.Text end
            win:RegisterThemed(function(nt)
                t2 = nt; row.BackgroundColor3 = t2.Glass; lbl.TextColor3 = t2.TextSecondary
                Box.BackgroundColor3 = t2.Background; Box.PlaceholderColor3 = t2.TextDisabled; Box.TextColor3 = t2.TextPrimary
            end, row)
            return Finish(el, o, row)
        end

        -- ============================ DROPDOWN ============================
        function Tab:AddDropdown(text, options, callback)
            local o = Opts(text, {"Name", "Options", "Callback", "Flag"}, options, callback)
            local t2 = win._theme
            local list = type(o.Options) == "table" and table.clone(o.Options) or {}
            local multi = o.Multi == true
            local searchable = o.Searchable == true or (o.Searchable == nil and #list > 8)
            local row = MakeSlot(rowH, self._parent)
            local itemH = mobile and 28 or 24

            local selected
            if multi then
                selected = {}
                if type(o.Default) == "table" then
                    for _, v in ipairs(o.Default) do if table.find(list, v) then table.insert(selected, v) end end
                end
            else
                selected = (o.Default ~= nil and table.find(list, o.Default)) and o.Default or list[1] or ""
            end
            local function IsSel(opt) if multi then return table.find(selected, opt) ~= nil end return opt == selected end
            local function Display()
                if multi then
                    if #selected == 0 then return "None" end
                    if #selected <= 2 then return table.concat(selected, ", ") end
                    return #selected .. " selected"
                end
                if selected == "" then return "None" end
                return tostring(selected)
            end

            local lbl = MakeLabel(row, o.Name, UDim2.new(0.35, 0, 1, 0), UDim2.new(0, 10, 0, 0), t2.TextPrimary)
            local DropBtn = Create("TextButton", {
                Size = UDim2.new(0.6, 0, 0, rowH - 12), Position = UDim2.new(0.38, 0, 0.5, -(rowH - 12) / 2), BackgroundColor3 = t2.Background, BackgroundTransparency = 0.05,
                Text = Display() .. " ▼", TextColor3 = t2.TextPrimary, TextSize = FONT_BODY - 1, Font = FONT, BorderSizePixel = 0, ClipsDescendants = true,
                TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5, Parent = row,
            })
            PixelText(DropBtn); PixelBevel(DropBtn, t2, 1, true); CreateInsetShadow(DropBtn, t2, 2)
            local popup
            local function UpdateBtn() DropBtn.Text = Display() .. ((popup and popup.IsOpen()) and " ▲" or " ▼") end

            local ListFrame = Create("Frame", {
                Name = "Dropdown_" .. tostring(o.Name), BackgroundColor3 = t2.SecondaryBG, BackgroundTransparency = 0.02, BorderSizePixel = 0,
                ZIndex = 1000, Visible = false, ClipsDescendants = true, Parent = win._gui,
            })
            PixelBevel(ListFrame, t2, 2)

            local SearchBox, topOff = nil, 4
            if searchable then
                SearchBox = Create("TextBox", {
                    Size = UDim2.new(1, -8, 0, 20), Position = UDim2.fromOffset(4, 4), BackgroundColor3 = t2.Background, BackgroundTransparency = 0.1, Text = "",
                    PlaceholderText = "Search...", PlaceholderColor3 = t2.TextDisabled, TextColor3 = t2.TextPrimary, TextSize = FONT_BODY - 1, Font = FONT,
                    TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, BorderSizePixel = 0, ZIndex = 1002, Parent = ListFrame,
                })
                AddPadding(SearchBox, 0, 0, 6, 6); PixelBevel(SearchBox, t2, 1, true)
                topOff = 28
            end
            local ListScroll = Create("ScrollingFrame", {
                Size = UDim2.new(1, -4, 1, -(topOff + 2)), Position = UDim2.new(0, 2, 0, topOff), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
                ScrollBarImageColor3 = t2.Scrollbar, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
                ZIndex = 1001, Parent = ListFrame,
            })
            AddPadding(ListScroll, 2, 4, 4, 4)
            Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = ListScroll})

            local entries = {}
            local function Query() return SearchBox and SearchBox.Text:lower() or "" end
            local function Matches(opt) local q = Query() return q == "" or tostring(opt):lower():find(q, 1, true) ~= nil end
            local function VisibleCount() local n = 0 for _, opt in ipairs(list) do if Matches(opt) then n += 1 end end return n end
            local function ApplyFilter() for _, e in ipairs(entries) do e.btn.Visible = Matches(e.opt) end end
            local function StyleEntry(e)
                local sel = IsSel(e.opt)
                e.btn.BackgroundColor3 = sel and t2.Accent or t2.Background
                e.btn.TextColor3 = sel and t2.TextPrimary or t2.TextSecondary
                if e.mark then e.mark.Text = sel and "■" or "□" end
            end
            local function Rebuild()
                for _, e in ipairs(entries) do e.btn:Destroy() end
                table.clear(entries)
                for i, opt in ipairs(list) do
                    local btn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, itemH), BackgroundTransparency = 0.1, Text = tostring(opt), TextSize = FONT_BODY - 1, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
                        BorderSizePixel = 0, LayoutOrder = i, ClipsDescendants = true, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 1002, Parent = ListScroll,
                    })
                    PixelText(btn); AddPadding(btn, 0, 0, multi and 22 or 8, 8)
                    local e = {btn = btn, opt = opt}
                    if multi then
                        e.mark = Create("TextLabel", {Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(0, -16, 0, 0), BackgroundTransparency = 1, Text = "□", TextColor3 = t2.TextPrimary, TextSize = 12, Font = FONT, ZIndex = 1003, Parent = btn})
                    end
                    table.insert(entries, e)
                    StyleEntry(e)
                    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = t2.AccentHover}, 0.12); btn.TextColor3 = t2.TextHover end)
                    btn.MouseLeave:Connect(function() StyleEntry(e) end)
                    btn.Activated:Connect(function()
                        if multi then
                            local idx = table.find(selected, opt)
                            if idx then table.remove(selected, idx) else table.insert(selected, opt) end
                            StyleEntry(e); UpdateBtn()
                            Fire(o, table.clone(selected))
                        else
                            selected = opt
                            popup.Close()
                            for _, e2 in ipairs(entries) do StyleEntry(e2) end
                            UpdateBtn()
                            Fire(o, opt)
                        end
                    end)
                end
                ApplyFilter()
            end
            Rebuild()

            popup = AttachPopup(DropBtn, ListFrame, self._scroll, function()
                return DropBtn.AbsoluteSize.X, math.min(math.max(VisibleCount(), 1) * (itemH + 2) + 10 + topOff, 260), "left"
            end, function()
                if SearchBox then SearchBox.Text = "" end
                UpdateBtn()
            end, UpdateBtn)
            if SearchBox then
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function() ApplyFilter(); if popup.IsOpen() then popup.Reposition() end end)
            end
            DropBtn.Activated:Connect(popup.Toggle)

            local el = BaseElement(row)
            function el:Set(v, silent)
                if multi then
                    selected = {}
                    if type(v) == "table" then
                        for _, x in ipairs(v) do if table.find(list, x) then table.insert(selected, x) end end
                    elseif table.find(list, v) then selected = {v} end
                    for _, e in ipairs(entries) do StyleEntry(e) end
                    UpdateBtn()
                    if not silent then Fire(o, table.clone(selected)) end
                elseif table.find(list, v) then
                    selected = v
                    for _, e in ipairs(entries) do StyleEntry(e) end
                    UpdateBtn()
                    if not silent then Fire(o, v) end
                end
            end
            function el:Get() return multi and table.clone(selected) or selected end
            function el:Refresh(newOptions, keepSelection)
                list = type(newOptions) == "table" and table.clone(newOptions) or {}
                if multi then
                    local kept = {}
                    if keepSelection then for _, x in ipairs(selected) do if table.find(list, x) then table.insert(kept, x) end end end
                    selected = kept
                elseif not (keepSelection and table.find(list, selected)) then
                    selected = list[1] or ""
                end
                Rebuild(); UpdateBtn()
                if popup.IsOpen() then popup.Reposition() end
            end
            function el:Close() popup.Close() end
            function el:GetOptions() return table.clone(list) end

            win:RegisterThemed(function(nt)
                t2 = nt
                row.BackgroundColor3 = t2.Glass; lbl.TextColor3 = t2.TextPrimary
                DropBtn.BackgroundColor3 = t2.Background; DropBtn.TextColor3 = t2.TextPrimary
                ListFrame.BackgroundColor3 = t2.SecondaryBG
                if SearchBox then SearchBox.BackgroundColor3 = t2.Background; SearchBox.TextColor3 = t2.TextPrimary; SearchBox.PlaceholderColor3 = t2.TextDisabled end
                for _, e in ipairs(entries) do StyleEntry(e) end
            end, row)
            return Finish(el, o, row)
        end

        -- ============================ LABEL / PARAGRAPH / SEPARATOR ============================
        function Tab:AddLabel(text)
            local o = Opts(text, {"Name"})
            local t2 = win._theme
            local row = Create("Frame", {Size = UDim2.new(1, 0, 0, mobile and 32 or 28), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = NextOrder(), ZIndex = 4, Parent = self._parent})
            local lbl = MakeLabel(row, "» " .. tostring(o.Name), UDim2.new(1, -18, 1, 0), UDim2.new(0, 10, 0, 0), t2.TextSecondary)
            local el = BaseElement(row)
            el.Label = lbl
            function el:Set(v) lbl.Text = "» " .. tostring(v) end
            function el:Get() return lbl.Text:sub(5) end
            win:RegisterThemed(function(nt) t2 = nt; lbl.TextColor3 = t2.TextSecondary end, row)
            return Finish(el, o, row)
        end

        function Tab:AddParagraph(title, content)
            local o = Opts(title, {"Name", "Content"}, content)
            local t2 = win._theme
            local row = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = t2.Glass, BackgroundTransparency = 0.25, BorderSizePixel = 0, LayoutOrder = NextOrder(), ZIndex = 4, Parent = self._parent})
            PixelBevel(row, t2, 1, true); AddPadding(row, 8, 8, 10, 10)
            Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = row})
            local tl = Create("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = tostring(o.Name), TextColor3 = t2.Accent, TextSize = FONT_BODY, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, ZIndex = 5, Parent = row})
            PixelText(tl)
            local cl = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = tostring(o.Content or ""), TextColor3 = t2.TextSecondary, TextSize = FONT_BODY - 1,
                Font = FONT, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 2, ZIndex = 5, Parent = row,
            })
            PixelText(cl)
            local el = BaseElement(row)
            function el:Set(tt, c) if tt then tl.Text = tostring(tt) end if c then cl.Text = tostring(c) end end
            function el:SetContent(c) cl.Text = tostring(c) end
            win:RegisterThemed(function(nt) t2 = nt; row.BackgroundColor3 = t2.Glass; tl.TextColor3 = t2.Accent; cl.TextColor3 = t2.TextSecondary end, row)
            return Finish(el, o, row)
        end

        function Tab:AddSeparator(labelText)
            local t2 = win._theme
            local row = Create("Frame", {Size = UDim2.new(1, 0, 0, mobile and 22 or 20), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = NextOrder(), ZIndex = 4, Parent = self._parent})
            local sepLine = Create("Frame", {Size = UDim2.new(1, -18, 0, 2), Position = UDim2.new(0, 9, 0.5, 0), BackgroundColor3 = t2.Accent, BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 5, Parent = row})
            local sepBg, sepLbl
            if labelText then
                sepBg = Create("Frame", {Size = UDim2.new(0, 0, 0, 14), AutomaticSize = Enum.AutomaticSize.X, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -6), BackgroundColor3 = t2.Glass, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 6, Parent = row})
                AddPadding(sepBg, 0, 0, 7, 7)
                sepLbl = Create("TextLabel", {Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = tostring(labelText), TextColor3 = t2.Accent, TextSize = 10, Font = FONT, ZIndex = 7, Parent = sepBg})
                PixelText(sepLbl)
            end
            win:RegisterThemed(function(nt)
                t2 = nt; sepLine.BackgroundColor3 = t2.Accent
                if sepBg then sepBg.BackgroundColor3 = t2.Glass; sepLbl.TextColor3 = t2.Accent end
            end, row)
            return BaseElement(row)
        end

        -- ============================ KEYBIND ============================
        function Tab:AddKeybind(text, defaultKey, callback)
            local o = Opts(text, {"Name", "Default", "Callback", "Flag"}, defaultKey, callback)
            local t2 = win._theme
            local row = MakeSlot(rowH, self._parent)
            local keybinds = win._keybinds
            local binding = {key = ToKeyCode(o.Default), callback = o.Callback, mode = o.Mode or "Press", listening = false, cooldown = false}
            table.insert(keybinds, binding)

            local lbl = MakeLabel(row, o.Name, UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 10, 0, 0), t2.TextPrimary)
            local KeyBtn = Create("TextButton", {
                Size = UDim2.new(0, mobile and 90 or 80, 0, rowH - 10), Position = UDim2.new(1, -(mobile and 102 or 92), 0.5, -(rowH - 10) / 2), BackgroundColor3 = t2.Background,
                BackgroundTransparency = 0.3, Text = binding.key and binding.key.Name or "None", TextColor3 = t2.Accent, TextSize = FONT_BODY - 1, Font = FONT, BorderSizePixel = 0,
                TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5, Parent = row,
            })
            PixelText(KeyBtn, t2.Accent); PixelBevel(KeyBtn, t2, 1, true); CreateInsetShadow(KeyBtn, t2, 2)

            local listenConn
            local function StopListening()
                binding.listening = false
                if listenConn then listenConn:Disconnect(); listenConn = nil end
                KeyBtn.Text = binding.key and binding.key.Name or "None"
            end
            local function KeyChanged()
                Invoke(o.OnChanged, binding.key)
                if o.Flag then win:_FlagChanged(o.Flag) end
            end
            KeyBtn.Activated:Connect(function()
                if binding.listening then StopListening() return end
                binding.listening = true
                KeyBtn.Text = "..."
                listenConn = UserInputService.InputBegan:Connect(function(inp)
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if inp.KeyCode == Enum.KeyCode.Escape then
                        StopListening()
                    elseif inp.KeyCode == Enum.KeyCode.Backspace or inp.KeyCode == Enum.KeyCode.Delete then
                        binding.key = nil; StopListening(); KeyChanged()
                    else
                        binding.key = inp.KeyCode
                        binding.cooldown = true
                        task.delay(0.2, function() binding.cooldown = false end)
                        StopListening(); KeyChanged()
                    end
                end)
            end)
            row.Destroying:Connect(function()
                if listenConn then listenConn:Disconnect() end
                local idx = table.find(keybinds, binding)
                if idx then table.remove(keybinds, idx) end
            end)

            local el = BaseElement(row)
            function el:Get() return binding.key end
            function el:Set(k, silent)
                binding.key = ToKeyCode(k)
                KeyBtn.Text = binding.key and binding.key.Name or "None"
                if not silent then KeyChanged() end
            end
            function el:SetCallback(fn) binding.callback = fn end
            win:RegisterThemed(function(nt)
                t2 = nt; row.BackgroundColor3 = t2.Glass; lbl.TextColor3 = t2.TextPrimary
                KeyBtn.BackgroundColor3 = t2.Background; KeyBtn.TextColor3 = t2.Accent
            end, row)
            return Finish(el, o, row)
        end

        -- ============================ COLOR PICKER (HSV + alpha) ============================
        function Tab:AddColorPicker(text, default, callback)
            local o = Opts(text, {"Name", "Default", "Callback", "Flag"}, default, callback)
            local t2 = win._theme
            local row = MakeSlot(rowH, self._parent)
            local col = typeof(o.Default) == "Color3" and o.Default or Color3.fromRGB(255, 0, 0)
            local h, s, v = col:ToHSV()
            local useAlpha = o.Alpha == true
            local alpha = math.clamp(tonumber(o.DefaultTransparency) or 0, 0, 1) -- transparency (0 = непрозрачный)

            local lbl = MakeLabel(row, o.Name, UDim2.new(0.6, 0, 1, 0), UDim2.new(0, 10, 0, 0), t2.TextPrimary)
            local Preview = Create("TextButton", {Size = UDim2.new(0, 26, 0, 20), Position = UDim2.new(1, -36, 0.5, -10), BackgroundColor3 = col, Text = "", BorderSizePixel = 0, ZIndex = 5, Parent = row})
            PixelBevel(Preview, t2, 1)

            local PAD, HUE_W = 8, 16
            local POP_W = mobile and 232 or 212
            local SV_H = mobile and 124 or 112
            local SV_W = POP_W - PAD * 3 - HUE_W
            local ALPHA_Y = PAD + SV_H + 6
            local HEX_Y = ALPHA_Y + (useAlpha and 20 or 2)
            local PRESET_Y = HEX_Y + 20 + 8
            local POP_H = PRESET_Y + 16 + PAD

            local Popup = Create("Frame", {Name = "ColorPicker_" .. tostring(o.Name), BackgroundColor3 = t2.SecondaryBG, BackgroundTransparency = 0.02, BorderSizePixel = 0, ZIndex = 1000, Visible = false, Parent = win._gui})
            PixelBevel(Popup, t2, 2)

            local SV = Create("Frame", {Size = UDim2.fromOffset(SV_W, SV_H), Position = UDim2.fromOffset(PAD, PAD), BackgroundColor3 = Color3.fromHSV(h, 1, 1), BorderSizePixel = 0, ZIndex = 1002, Parent = Popup})
            Create("UIStroke", {Color = t2.Border, Thickness = 1, Parent = SV}):SetAttribute("MC_Role", "Border")
            Create("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 1003, Parent = SV}, {
                Create("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})}),
            })
            Create("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 1004, Parent = SV}, {
                Create("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})}),
            })
            local SVCursor = Create("Frame", {Size = UDim2.fromOffset(8, 8), BackgroundTransparency = 1, ZIndex = 1005, Parent = SV}, {Create("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 2})})
            Create("Frame", {Size = UDim2.fromOffset(2, 2), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 1006, Parent = SVCursor})
            local SVHit = Create("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 1007, Parent = SV})

            local Hue = Create("Frame", {Size = UDim2.fromOffset(HUE_W, SV_H), Position = UDim2.fromOffset(PAD * 2 + SV_W, PAD), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 1002, Parent = Popup}, {
                Create("UIGradient", {Rotation = 90, Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                })}),
            })
            Create("UIStroke", {Color = t2.Border, Thickness = 1, Parent = Hue}):SetAttribute("MC_Role", "Border")
            local HueCursor = Create("Frame", {Size = UDim2.new(1, 4, 0, 3), Position = UDim2.new(0, -2, h, -1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 1003, Parent = Hue}, {Create("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 1})})
            local HueHit = Create("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 1007, Parent = Hue})

            local AlphaBar, AlphaCursor, AlphaHit
            if useAlpha then
                local back = Create("Frame", {Size = UDim2.fromOffset(SV_W, 12), Position = UDim2.fromOffset(PAD, ALPHA_Y), BackgroundColor3 = Color3.fromRGB(60, 60, 60), BorderSizePixel = 0, ZIndex = 1002, Parent = Popup})
                Create("UIStroke", {Color = t2.Border, Thickness = 1, Parent = back}):SetAttribute("MC_Role", "Border")
                AlphaBar = Create("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = col, BorderSizePixel = 0, ZIndex = 1003, Parent = back}, {
                    Create("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})}),
                })
                AlphaCursor = Create("Frame", {Size = UDim2.new(0, 3, 1, 4), Position = UDim2.new(alpha, -1, 0, -2), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 1004, Parent = back}, {Create("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 1})})
                AlphaHit = Create("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 1007, Parent = back})
            end

            local HexBox = Create("TextBox", {
                Size = UDim2.fromOffset(84, 20), Position = UDim2.fromOffset(PAD, HEX_Y), BackgroundColor3 = t2.Background, BackgroundTransparency = 0.1, Text = ToHex(col), TextColor3 = t2.TextPrimary,
                TextSize = 11, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 1002, Parent = Popup,
            })
            AddPadding(HexBox, 0, 0, 6, 6); PixelBevel(HexBox, t2, 1, true)
            local RGBLabel = Create("TextLabel", {Size = UDim2.new(1, -(PAD * 2 + 84 + 6), 0, 20), Position = UDim2.fromOffset(PAD + 84 + 6, HEX_Y), BackgroundTransparency = 1, Text = "", TextColor3 = t2.TextSecondary, TextSize = 10, Font = FONT, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 1002, Parent = Popup})
            PixelText(RGBLabel)

            local function Emit() if useAlpha then Fire(o, col, alpha) else Fire(o, col) end end
            local function Render(fire)
                col = Color3.fromHSV(h, s, v)
                SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                SVCursor.Position = UDim2.new(s, -4, 1 - v, -4)
                HueCursor.Position = UDim2.new(0, -2, h, -1)
                Preview.BackgroundColor3 = col
                Preview.BackgroundTransparency = useAlpha and alpha * 0.8 or 0
                if AlphaBar then AlphaBar.BackgroundColor3 = col; AlphaCursor.Position = UDim2.new(alpha, -1, 0, -2) end
                if not HexBox:IsFocused() then HexBox.Text = ToHex(col) end
                RGBLabel.Text = useAlpha and string.format("%d, %d, %d  a:%d%%", R255(col.R), R255(col.G), R255(col.B), math.floor((1 - alpha) * 100 + 0.5))
                    or string.format("%d, %d, %d", R255(col.R), R255(col.G), R255(col.B))
                if fire then Emit() end
            end

            local presets = {
                Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 128, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 255),
                Color3.fromRGB(0, 0, 255), Color3.fromRGB(128, 0, 255), Color3.fromRGB(255, 0, 255), Color3.fromRGB(255, 255, 255),
            }
            local gap = (POP_W - PAD * 2 - #presets * 16) / (#presets - 1)
            for i, pc in ipairs(presets) do
                local sw = Create("TextButton", {Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(PAD + (i - 1) * (16 + gap), PRESET_Y), BackgroundColor3 = pc, Text = "", BorderSizePixel = 0, ZIndex = 1002, Parent = Popup})
                PixelBevel(sw, t2, 1)
                sw.Activated:Connect(function() h, s, v = pc:ToHSV(); Render(true) end)
            end
            HexBox.FocusLost:Connect(function()
                local c = FromHex(HexBox.Text)
                if c then h, s, v = c:ToHSV(); Render(true) else HexBox.Text = ToHex(col) end
            end)

            local dragSV, dragHue, dragA = false, false, false
            local function SVFrom(inp)
                local ap, as = SV.AbsolutePosition, SV.AbsoluteSize
                if as.X <= 0 or as.Y <= 0 then return end
                s = math.clamp((inp.Position.X - ap.X) / as.X, 0, 1)
                v = 1 - math.clamp((inp.Position.Y - ap.Y) / as.Y, 0, 1)
                Render(true)
            end
            local function HueFrom(inp)
                local ap, as = Hue.AbsolutePosition, Hue.AbsoluteSize
                if as.Y <= 0 then return end
                h = math.clamp((inp.Position.Y - ap.Y) / as.Y, 0, 1)
                Render(true)
            end
            local function AlphaFrom(inp)
                local ap, as = AlphaHit.AbsolutePosition, AlphaHit.AbsoluteSize
                if as.X <= 0 then return end
                alpha = math.clamp((inp.Position.X - ap.X) / as.X, 0, 1)
                Render(true)
            end
            SVHit.InputBegan:Connect(function(inp) if IsPress(inp) then dragSV = true; SVFrom(inp) end end)
            HueHit.InputBegan:Connect(function(inp) if IsPress(inp) then dragHue = true; HueFrom(inp) end end)
            if AlphaHit then AlphaHit.InputBegan:Connect(function(inp) if IsPress(inp) then dragA = true; AlphaFrom(inp) end end) end
            local conns = {
                UserInputService.InputEnded:Connect(function(inp) if IsPress(inp) then dragSV, dragHue, dragA = false, false, false end end),
                UserInputService.InputChanged:Connect(function(inp)
                    if not IsMove(inp) then return end
                    if dragSV then SVFrom(inp) elseif dragHue then HueFrom(inp) elseif dragA then AlphaFrom(inp) end
                end),
            }
            row.Destroying:Connect(function() for _, c in ipairs(conns) do c:Disconnect() end end)

            local popup = AttachPopup(Preview, Popup, self._scroll, function() return POP_W, POP_H, "right" end)
            Preview.Activated:Connect(popup.Toggle)
            Render(false)

            local el = BaseElement(row)
            function el:Set(c, silent) if typeof(c) ~= "Color3" then return end h, s, v = c:ToHSV(); Render(not silent) end
            function el:Get() return col end
            function el:GetHex() return ToHex(col) end
            function el:GetTransparency() return alpha end
            function el:SetTransparency(a, silent) alpha = math.clamp(tonumber(a) or 0, 0, 1); Render(not silent) end
            function el:Close() popup.Close() end
            if useAlpha then
                el._Save = function() local d = Serialize(col); d.a = alpha; return d end
                el._Load = function(raw)
                    local c = Deserialize(raw)
                    if typeof(c) == "Color3" then h, s, v = c:ToHSV() end
                    if type(raw) == "table" and tonumber(raw.a) then alpha = math.clamp(raw.a, 0, 1) end
                    Render(true)
                end
            end
            win:RegisterThemed(function(nt)
                t2 = nt; row.BackgroundColor3 = t2.Glass; lbl.TextColor3 = t2.TextPrimary
                Popup.BackgroundColor3 = t2.SecondaryBG; HexBox.BackgroundColor3 = t2.Background; HexBox.TextColor3 = t2.TextPrimary; RGBLabel.TextColor3 = t2.TextSecondary
            end, row)
            return Finish(el, o, row)
        end

        -- ============================ SECTION ============================
        function Tab:AddSection(title, defaultOpen)
            local o = Opts(title, {"Name", "Open"}, defaultOpen)
            local t2 = win._theme
            local open = (o.Open ~= false)
            local sname = tostring(o.Name)
            local Header = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, mobile and 32 or 28), BackgroundColor3 = t2.TertiaryBG, BackgroundTransparency = 0.2, Text = (open and "v " or "> ") .. sname, TextColor3 = t2.Accent,
                TextSize = FONT_BODY, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, LayoutOrder = NextOrder(), ZIndex = 4, Parent = self._parent,
            })
            PixelText(Header, t2.Accent); AddPadding(Header, 0, 0, 10, 10); PixelBevel(Header, t2, 1); CreateInsetShadow(Header, t2, 2)
            local SectionFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = NextOrder(), Visible = open, ZIndex = 4, Parent = self._parent})
            Create("UIListLayout", {Padding = UDim.new(0, mobile and 5 or 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = SectionFrame})
            AddPadding(SectionFrame, 0, 0, 10, 0)
            local function SetOpen(x)
                open = x
                SectionFrame.Visible = open
                Header.Text = (open and "v " or "> ") .. sname
                Tween(Header, {BackgroundColor3 = open and t2.TertiaryBG or t2.SecondaryBG}, 0.15)
            end
            Header.Activated:Connect(function() ClosePopups(); SetOpen(not open) end)
            win:_AttachTooltip(Header, o.Tooltip)
            win:RegisterThemed(function(nt) t2 = nt; Header.BackgroundColor3 = open and t2.TertiaryBG or t2.SecondaryBG; Header.TextColor3 = t2.Accent end, Header)

            local Sec = setmetatable({}, Tab)
            Sec._parent, Sec._scroll, Sec._window, Sec.Instance = SectionFrame, self._scroll, win, SectionFrame
            function Sec:SetOpen(x) SetOpen(x and true or false) end
            function Sec:Destroy() Header:Destroy(); SectionFrame:Destroy() end
            return Sec
        end

        function Tab:AddNotify(title, msg, duration) win:Notify(title, msg, duration) end
        function Tab:Select() SelectThis() end

        Tab.Button = Tab.AddButton; Tab.Toggle = Tab.AddToggle; Tab.Slider = Tab.AddSlider
        Tab.Textbox = Tab.AddTextbox; Tab.Input = Tab.AddTextbox; Tab.Dropdown = Tab.AddDropdown
        Tab.Label = Tab.AddLabel; Tab.Paragraph = Tab.AddParagraph; Tab.Keybind = Tab.AddKeybind
        Tab.ColorPicker = Tab.AddColorPicker; Tab.Section = Tab.AddSection; Tab.Separator = Tab.AddSeparator
        return Tab
    end

    function self:SelectTab(name)
        for _, ti in ipairs(self._tabs) do
            if ti.name == name then ti.select() return true end
        end
        return false
    end

    -- ================================================================
    -- SETTINGS TAB (готовая вкладка настроек)
    -- ================================================================
    function self:AddSettingsTab(name)
        local tab = self:AddTab(name or "Settings")

        local ui = tab:AddSection("Interface")
        local themeDD = ui:AddDropdown({Name = "Theme", Options = ThemeOrder(), Default = self._themeName, Flag = "_Theme",
            Callback = function(v) if v ~= self._themeName then self:SetTheme(v) end end})
        self:RegisterThemed(function() themeDD:Set(self._themeName, true) end, themeDD.Instance)

        if not mobile then
            ui:AddKeybind({Name = "Toggle UI key", Default = self._toggleKey, Flag = "_ToggleKey", Tooltip = "Клавиша показа/скрытия меню",
                OnChanged = function(k) if k then self:SetToggleKey(k) end end})
        end
        ui:AddSlider({Name = "UI Scale", Min = 50, Max = 150, Default = math.floor(self._userScale * 100 + 0.5), Suffix = "%", Flag = "_Scale",
            Callback = function(v) self:SetScale(v / 100) end})
        ui:AddToggle({Name = "Watermark (FPS / ping)", Default = false, Flag = "_Watermark", Callback = function(v) self:SetWatermark(v) end})

        local cfg = tab:AddSection("Configs")
        local nameBox = cfg:AddTextbox({Name = "Config name", Placeholder = "default"})
        local listDD = cfg:AddDropdown({Name = "Saved", Options = self:GetConfigs(), Callback = function(v) nameBox:Set(v, true) end})
        local function refresh() listDD:Refresh(self:GetConfigs(), true) end
        local function chosen()
            local n = nameBox:Get()
            if n == "" then n = listDD:Get() end
            if n == "" or n == "None" then n = "default" end
            return SafeName(n)
        end
        cfg:AddButton("Save", function()
            local ok, err = self:SaveConfig(chosen())
            self:Notify({Title = "Config", Content = ok and ("Saved '" .. chosen() .. "'") or ("Save failed: " .. tostring(err)), Type = ok and "Success" or "Error"})
            refresh()
        end)
        cfg:AddButton("Load", function()
            local ok, err = self:LoadConfig(chosen())
            self:Notify({Title = "Config", Content = ok and ("Loaded '" .. chosen() .. "'") or ("Load failed: " .. tostring(err)), Type = ok and "Success" or "Error"})
        end)
        cfg:AddButton("Delete", function()
            local n = chosen()
            self:Dialog({Title = "Delete config", Content = "Delete config '" .. n .. "'? This can't be undone.", Buttons = {
                {Text = "Delete", Callback = function()
                    local ok = self:DeleteConfig(n)
                    self:Notify({Title = "Config", Content = ok and ("Deleted '" .. n .. "'") or "Nothing to delete", Type = ok and "Warning" or "Error"})
                    refresh()
                end},
                {Text = "Cancel"},
            }})
        end)
        cfg:AddButton("Refresh list", refresh)
        cfg:AddToggle({Name = "Auto save", Default = self._autoSave, Tooltip = "Сохранять изменения в 'autosave' автоматически", Callback = function(v) self._autoSave = v end})
        return tab
    end

    -- ================================================================
    -- NOTIFICATIONS
    -- ================================================================
    local notifCounter = 0
    local notifTypeColors = {
        Success = Color3.fromRGB(85, 200, 90), Warning = Color3.fromRGB(240, 180, 50), Error = Color3.fromRGB(220, 70, 60),
    }
    function self:Notify(title, message, duration, ntype)
        if type(title) == "table" then
            local o = title
            title, message, duration, ntype = o.Title or o.Name, o.Content or o.Message or o.Text, o.Duration, o.Type
        end
        local t = self._theme
        local accent = notifTypeColors[ntype] or t.NotifAccent
        duration = tonumber(duration) or 4
        notifCounter += 1

        local existing = {}
        for _, c in ipairs(self._notifContainer:GetChildren()) do if c:IsA("Frame") then table.insert(existing, c) end end
        if #existing >= 6 then
            table.sort(existing, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
            existing[1]:Destroy()
        end

        local Wrapper = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = notifCounter, ZIndex = 25, Parent = self._notifContainer})
        local notif = Create("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(0, 320, 0, 0), BackgroundColor3 = t.Notification, BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 25, Parent = Wrapper})
        PixelBevel(notif, t, 2)
        Create("Frame", {Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = accent, BorderSizePixel = 0, ZIndex = 26, Parent = notif})
        local Inner = Create("Frame", {Size = UDim2.new(1, -10, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, ZIndex = 26, Parent = notif})
        AddPadding(Inner, 8, 10, 8, 8)
        Create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Inner})
        local tl = Create("TextLabel", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = tostring(title or "Notification"), TextColor3 = accent, TextSize = 13, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 1, ZIndex = 27, Parent = Inner})
        PixelText(tl)
        local ml = Create("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = tostring(message or ""), TextColor3 = t.TextSecondary, TextSize = 11, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, LayoutOrder = 2, ZIndex = 27, Parent = Inner})
        PixelText(ml)
        local ProgBG = Create("Frame", {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), BackgroundColor3 = t.SliderBG, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 27, Parent = notif})
        local Prog = Create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = accent, BorderSizePixel = 0, ZIndex = 28, Parent = ProgBG})

        Tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Back)
        Tween(Prog, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)

        local dismissed = false
        local function Dismiss()
            if dismissed or not Wrapper.Parent then return end
            dismissed = true
            Tween(notif, {Position = UDim2.new(0, 320, 0, 0)}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.delay(0.25, function()
                if not Wrapper.Parent then return end
                Wrapper.AutomaticSize = Enum.AutomaticSize.None
                Wrapper.Size = UDim2.new(1, 0, 0, Wrapper.AbsoluteSize.Y)
                Wrapper.ClipsDescendants = true
                Tween(Wrapper, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                task.delay(0.16, function() if Wrapper.Parent then Wrapper:Destroy() end end)
            end)
        end
        notif.InputBegan:Connect(function(inp) if IsPress(inp) then Dismiss() end end)
        task.delay(duration, Dismiss)
        return {Dismiss = Dismiss}
    end

    -- ================================================================
    -- DESTROY
    -- ================================================================
    function self:Destroy()
        for _, k in ipairs({"_inputConn", "_inputEndConn", "_cameraWatchConn"}) do
            if self[k] then self[k]:Disconnect(); self[k] = nil end
        end
        if self._getViewportConn then
            local vc = self._getViewportConn()
            if vc then vc:Disconnect() end
            self._getViewportConn = nil
        end
        if self._stopWatermark then self._stopWatermark() end
        table.clear(self._keybinds); table.clear(self._themedRefreshers); table.clear(self._flags)
        if self._gui then self._gui:Destroy(); self._gui = nil end
    end

    self.Tab = self.AddTab
    self.CreateTab = self.AddTab
    self.Notification = self.Notify
    return self
end

MinecraftLib.Window = MinecraftLib.CreateWindow
MinecraftLib.New = MinecraftLib.CreateWindow

return MinecraftLib
