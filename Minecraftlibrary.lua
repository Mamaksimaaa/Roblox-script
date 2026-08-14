--[[
    ███╗   ███╗██╗███╗   ██╗███████╗ ██████╗██████╗  █████╗ ███████╗████████╗
    ████╗ ████║██║████╗  ██║██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝
    ██╔████╔██║██║██╔██╗ ██║█████╗  ██║     ██████╔╝███████║█████╗     ██║
    ██║╚██╔╝██║██║██║╚██╗██║██╔══╝  ██║     ██╔══██╗██╔══██║██╔══╝     ██║
    ██║ ╚═╝ ██║██║██║ ╚████║███████╗╚██████╗██║  ██║██║  ██║██║        ██║
    ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝

    Minecraft UI Library v3.6 "Glass Voxel"
    • Прозрачные элементы — фон dirt/измерения виден сквозь UI
    • Реальные текстуры: dirt, oak_planks, grass_block, dimension bg
    • 3 измерения: Overworld / Nether / End
    • PC: RightShift | Mobile: кнопка M
]]

local MinecraftLib = {}
MinecraftLib.__index = MinecraftLib

-- ═══════════════════════════════════════════════════════
--                     TEXTURE URLs
-- ═══════════════════════════════════════════════════════
local TextureURLs = {
    Dirt        = "https://i.pinimg.com/564x/2a/b1/c3/2ab1c37cfdff720c6de2ddb07328f145.jpg",
    OakPlanks   = "https://art.pixilart.com/thumb/sr26db5fe648aaws3.png",
    GrassBlock  = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT822Jc6Q9s_l2j0pvLPuvieY_A14J9yDLz5RNBLAQtwwh02b3qr1YaVyh_&s=10",
    OverworldBg = "https://i.ibb.co/WvNMkCQ5/c072441fb834ae7d4f22ef963f0ed94b.jpg",
    NetherBg    = "https://i.ibb.co/PHVb9r7/c1956348a2b69da33a729aeeb6380573.jpg",
    EndBg       = "https://i.ibb.co/PGHx7vWh/0bc2e12262245ea4475113503d00f4d9.jpg",
}

-- ═══════════════════════════════════════════════════════
--                     SERVICES
-- ═══════════════════════════════════════════════════════
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local Camera            = workspace.CurrentCamera
local LocalPlayer       = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════
--                   TEXTURE LOADER
-- ═══════════════════════════════════════════════════════
local function EnsureFolder()
    if not isfolder("MinecraftUI") then makefolder("MinecraftUI") end
end

local function LoadTexture(url, filename)
    EnsureFolder()
    local path = "MinecraftUI/" .. filename
    if not isfile(path) then
        local succ, data = pcall(function() return game:HttpGet(url, true) end)
        if succ and data and #data > 100 then
            writefile(path, data)
        else
            warn("[MinecraftLib] Failed to download: " .. url)
            return ""
        end
    end
    return getcustomasset(path)
end

-- ═══════════════════════════════════════════════════════
--                     THEMES
-- ═══════════════════════════════════════════════════════
local Themes = {
    Overworld = {
        BackgroundImage  = "OverworldBg",
        TitleBarImage    = "OakPlanks",
        Accent           = Color3.fromRGB(80,  140, 45),
        AccentHover      = Color3.fromRGB(105, 175, 60),
        AccentPress      = Color3.fromRGB(60,  110, 35),
        TabActive        = Color3.fromRGB(90,  130, 50),
        TabInactive      = Color3.fromRGB(68,  54,  38),
        TextPrimary      = Color3.fromRGB(255, 255, 255),
        TextSecondary    = Color3.fromRGB(210, 210, 210),
        TextDisabled     = Color3.fromRGB(130, 130, 130),
        TextHover        = Color3.fromRGB(255, 255, 85),
        Border           = Color3.fromRGB(12,  10,  7),
        BevelLight       = Color3.fromRGB(220, 220, 220),
        BevelDark        = Color3.fromRGB(35,  28,  20),
        SliderFill       = Color3.fromRGB(80,  140, 45),
        SliderBG         = Color3.fromRGB(25,  20,  15),
        ToggleOn         = Color3.fromRGB(80,  140, 45),
        ToggleOff        = Color3.fromRGB(80,  60,  45),
        Scrollbar        = Color3.fromRGB(125, 100, 62),
        Shadow           = Color3.fromRGB(4,   3,   2),
        Title            = Color3.fromRGB(255, 255, 255),
        CloseBtn         = Color3.fromRGB(170, 40,  35),
        Notification     = Color3.fromRGB(35,  28,  20),
        NotifAccent      = Color3.fromRGB(195, 165, 50),
        Separator        = Color3.fromRGB(125, 100, 62),
        Glass            = Color3.fromRGB(40,  32,  22),
    },
    Nether = {
        BackgroundImage  = "NetherBg",
        TitleBarImage    = "OakPlanks",
        Accent           = Color3.fromRGB(185, 35,  35),
        AccentHover      = Color3.fromRGB(215, 55,  45),
        AccentPress      = Color3.fromRGB(145, 25,  25),
        TabActive        = Color3.fromRGB(140, 35,  30),
        TabInactive      = Color3.fromRGB(56,  22,  17),
        TextPrimary      = Color3.fromRGB(255, 230, 215),
        TextSecondary    = Color3.fromRGB(215, 170, 155),
        TextDisabled     = Color3.fromRGB(120, 80,  70),
        TextHover        = Color3.fromRGB(255, 255, 85),
        Border           = Color3.fromRGB(8,   3,   2),
        BevelLight       = Color3.fromRGB(210, 120, 100),
        BevelDark        = Color3.fromRGB(24,  8,   6),
        SliderFill       = Color3.fromRGB(185, 35,  35),
        SliderBG         = Color3.fromRGB(20,  7,   5),
        ToggleOn         = Color3.fromRGB(185, 35,  35),
        ToggleOff        = Color3.fromRGB(65,  25,  20),
        Scrollbar        = Color3.fromRGB(85,  30,  20),
        Shadow           = Color3.fromRGB(2,   1,   1),
        Title            = Color3.fromRGB(255, 200, 180),
        CloseBtn         = Color3.fromRGB(210, 50,  40),
        Notification     = Color3.fromRGB(24,  8,   6),
        NotifAccent      = Color3.fromRGB(210, 90,  35),
        Separator        = Color3.fromRGB(85,  30,  20),
        Glass            = Color3.fromRGB(42,  16,  13),
    },
    End = {
        BackgroundImage  = "EndBg",
        TitleBarImage    = "OakPlanks",
        Accent           = Color3.fromRGB(120, 80,  170),
        AccentHover      = Color3.fromRGB(150, 110, 200),
        AccentPress      = Color3.fromRGB(90,  58,  135),
        TabActive        = Color3.fromRGB(105, 72,  145),
        TabInactive      = Color3.fromRGB(52,  45,  34),
        TextPrimary      = Color3.fromRGB(235, 230, 220),
        TextSecondary    = Color3.fromRGB(195, 185, 205),
        TextDisabled     = Color3.fromRGB(110, 100, 120),
        TextHover        = Color3.fromRGB(255, 255, 85),
        Border           = Color3.fromRGB(10,  9,   7),
        BevelLight       = Color3.fromRGB(205, 195, 220),
        BevelDark        = Color3.fromRGB(28,  23,  18),
        SliderFill       = Color3.fromRGB(120, 80,  170),
        SliderBG         = Color3.fromRGB(18,  15,  12),
        ToggleOn         = Color3.fromRGB(120, 80,  170),
        ToggleOff        = Color3.fromRGB(68,  60,  52),
        Scrollbar        = Color3.fromRGB(82,  72,  52),
        Shadow           = Color3.fromRGB(3,   3,   2),
        Title            = Color3.fromRGB(225, 205, 240),
        CloseBtn         = Color3.fromRGB(170, 40,  35),
        Notification     = Color3.fromRGB(28,  23,  18),
        NotifAccent      = Color3.fromRGB(120, 80,  170),
        Separator        = Color3.fromRGB(82,  72,  52),
        Glass            = Color3.fromRGB(40,  35,  28),
    },
}

-- ═══════════════════════════════════════════════════════
--                   UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════
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
    local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
    TweenService:Create(inst, info, props):Play()
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Bevel: чёрный контур + свет/тень
local function PixelBevel(parent, theme, thickness, inset)
    thickness = thickness or 2; inset = inset or false
    local z = (parent.ZIndex or 1) + 1
    local light = inset and theme.BevelDark or theme.BevelLight
    local dark  = inset and theme.BevelLight or theme.BevelDark
    Create("UIStroke", {Color = theme.Border, Thickness = thickness, Parent = parent})
    Create("Frame", {Name="BevelTop", BackgroundColor3=light, BorderSizePixel=0, Size=UDim2.new(1,-thickness*2,0,1), Position=UDim2.new(0,thickness,0,thickness), ZIndex=z, Parent=parent})
    Create("Frame", {Name="BevelLeft", BackgroundColor3=light, BorderSizePixel=0, Size=UDim2.new(0,1,1,-thickness*2), Position=UDim2.new(0,thickness,0,thickness), ZIndex=z, Parent=parent})
    Create("Frame", {Name="BevelBottom", BackgroundColor3=dark, BorderSizePixel=0, Size=UDim2.new(1,-thickness*2,0,1), Position=UDim2.new(0,thickness,1,-thickness-1), ZIndex=z, Parent=parent})
    Create("Frame", {Name="BevelRight", BackgroundColor3=dark, BorderSizePixel=0, Size=UDim2.new(0,1,1,-thickness*2), Position=UDim2.new(1,-thickness-1,0,thickness), ZIndex=z, Parent=parent})
end

local function PixelText(label, color)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(18, 16, 12)
    if color then label.TextColor3 = color end
end

local function AddPadding(frame, t, b, l, r)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, t or 6), PaddingBottom = UDim.new(0, b or 6),
        PaddingLeft = UDim.new(0, l or 8), PaddingRight = UDim.new(0, r or 8),
        Parent = frame,
    })
end

-- ═══════════════════════════════════════════════════════
--                  NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════
local NotifContainer
local function EnsureNotifContainer()
    if NotifContainer and NotifContainer.Parent then return end
    local sg = Create("ScreenGui", {Name="MCNotifs_v3", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, Parent=CoreGui})
    NotifContainer = Create("Frame", {Name="Container", Size=UDim2.new(0,300,1,0), Position=UDim2.new(1,-315,0,0), BackgroundTransparency=1, Parent=sg})
    Create("UIListLayout", {VerticalAlignment=Enum.VerticalAlignment.Bottom, Padding=UDim.new(0,8), Parent=NotifContainer})
    Create("UIPadding", {PaddingBottom=UDim.new(0,14), Parent=NotifContainer})
end

-- ═══════════════════════════════════════════════════════
--               WINDOW CONSTRUCTOR
-- ═══════════════════════════════════════════════════════
function MinecraftLib:CreateWindow(title, config)
    config = config or {}
    local self = setmetatable({}, MinecraftLib)
    self._themeName = config.Theme or "Overworld"
    self._theme     = Themes[self._themeName]
    self._tabs      = {}
    self._activeTab = nil
    self._visible   = true
    self._keybinds  = {}
    self._title     = title or "Minecraft UI"
    self._mobile    = IsMobile()

    local Textures = {
        Dirt        = LoadTexture(TextureURLs.Dirt, "dirt.jpg"),
        OakPlanks   = LoadTexture(TextureURLs.OakPlanks, "oak_planks.png"),
        GrassBlock  = LoadTexture(TextureURLs.GrassBlock, "grass.jpg"),
        OverworldBg = LoadTexture(TextureURLs.OverworldBg, "overworld_bg.jpg"),
        NetherBg    = LoadTexture(TextureURLs.NetherBg, "nether_bg.jpg"),
        EndBg       = LoadTexture(TextureURLs.EndBg, "end_bg.jpg"),
    }
    self._textures = Textures

    EnsureNotifContainer()

    local WIN_W = self._mobile and 340 or 600
    local WIN_H = self._mobile and 300 or 440
    local TAB_W = self._mobile and 90 or 140
    local FONT  = Enum.Font.Arcade
    local FONT_TITLE = self._mobile and 14 or 16
    local FONT_BODY  = self._mobile and 12 or 13

    self._winW, self._winH, self._tabW = WIN_W, WIN_H, TAB_W

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "MinecraftUI_v3", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = CoreGui,
    })
    self._gui = ScreenGui

    -- Shadow
    local Shadow = Create("Frame", {
        Size = UDim2.new(0, WIN_W + 12, 0, WIN_H + 12),
        Position = UDim2.new(0.5, -(WIN_W+12)/2, 0.5, -(WIN_H+12)/2),
        BackgroundColor3 = self._theme.Shadow, BackgroundTransparency = 0.4,
        BorderSizePixel = 0, ZIndex = 0, Parent = ScreenGui,
    })

    -- Main Window
    local Main = Create("Frame", {
        Size = UDim2.new(0, WIN_W, 0, WIN_H),
        Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
        BackgroundColor3 = Color3.fromRGB(50,40,28), BorderSizePixel = 0,
        ClipsDescendants = false, ZIndex = 1, Parent = ScreenGui,
    })
    PixelBevel(Main, self._theme, 2)
    self._main, self._shadow = Main, Shadow

    -- Фон окна (измерение)
    local MainBg = Create("ImageLabel", {
        Name = "BackgroundImage", Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1, Image = Textures[self._theme.BackgroundImage],
        ScaleType = Enum.ScaleType.Stretch, ZIndex = 0, Parent = Main,
    })

    local UIScaleInst = Create("UIScale", {Scale = 1, Parent = Main})
    self._uiScale = UIScaleInst

    -- ═════════════════════════════════════════════════
    -- TITLE BAR (деревянные доски)
    -- ═════════════════════════════════════════════════
    local TitleBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, self._mobile and 36 or 42),
        BackgroundColor3 = self._theme.TertiaryBG, BorderSizePixel = 0,
        ZIndex = 2, Parent = Main,
    })
    PixelBevel(TitleBar, self._theme, 2)

    Create("ImageLabel", {
        Name = "PlanksTexture", Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1, Image = Textures.OakPlanks,
        ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0,64,0,64),
        ZIndex = 2, Parent = TitleBar,
    })

    -- Гвозди
    for _, pos in ipairs({{0,4,0,4},{1,-8,0,4},{0,4,1,-8},{1,-8,1,-8}}) do
        Create("Frame", {Size=UDim2.new(0,4,0,4), Position=UDim2.new(pos[1],pos[2],pos[3],pos[4]), BackgroundColor3=Color3.fromRGB(60,50,35), BorderSizePixel=0, ZIndex=4, Parent=TitleBar})
    end

    -- Иконка травяного блока
    local IconSize = self._mobile and 20 or 24
    Create("ImageLabel", {
        Size = UDim2.new(0, IconSize, 0, IconSize),
        Position = UDim2.new(0, 10, 0.5, -IconSize/2),
        BackgroundTransparency = 1, Image = Textures.GrassBlock,
        ScaleType = Enum.ScaleType.Stretch, ZIndex = 4, Parent = TitleBar,
    })

    local TitleLabel = Create("TextLabel", {
        Name = "Title", Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, IconSize + 16, 0, 0),
        BackgroundTransparency = 1, Text = title or "Minecraft UI",
        TextColor3 = self._theme.Title, TextSize = FONT_TITLE,
        Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = TitleBar,
    })
    PixelText(TitleLabel)
    self._titleLabel = TitleLabel

    -- Close Button
    local BtnSize = self._mobile and 26 or 28
    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, BtnSize, 0, BtnSize),
        Position = UDim2.new(1, -BtnSize - 6, 0.5, -BtnSize/2),
        BackgroundColor3 = self._theme.CloseBtn, Text = "×",
        TextColor3 = Color3.fromRGB(255,255,255), TextSize = 14,
        Font = FONT, BorderSizePixel = 0, ZIndex = 5, Parent = TitleBar,
    })
    PixelText(CloseBtn)
    PixelBevel(CloseBtn, self._theme, 1)

    -- Theme Switcher
    local ThemeBtn = Create("TextButton", {
        Size = UDim2.new(0, self._mobile and 52 or 64, 0, self._mobile and 20 or 22),
        Position = UDim2.new(1, -BtnSize - (self._mobile and 64 or 78), 0.5, -(self._mobile and 10 or 11)),
        BackgroundColor3 = self._theme.SecondaryBG, Text = "OW",
        TextColor3 = self._theme.TextSecondary, TextSize = 10,
        Font = FONT, BorderSizePixel = 0, ZIndex = 5, Parent = TitleBar,
    })
    PixelText(ThemeBtn)
    PixelBevel(ThemeBtn, self._theme, 1)

    -- ═════════════════════════════════════════════════
    -- TAB BAR
    -- ═════════════════════════════════════════════════
    local TabBar = Create("Frame", {
        Size = UDim2.new(0, TAB_W, 1, -(self._mobile and 36 or 42)),
        Position = UDim2.new(0, 0, 0, self._mobile and 36 or 42),
        BackgroundColor3 = self._theme.SecondaryBG, BorderSizePixel = 0,
        ZIndex = 2, Parent = Main,
    })
    PixelBevel(TabBar, self._theme, 2)

    local TabList = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 3, Parent = TabBar,
    })
    Create("UIListLayout", {Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabList})
    AddPadding(TabList, 6, 6, 5, 5)
    self._tabList = TabList

    -- ═════════════════════════════════════════════════
    -- CONTENT AREA (полупрозрачный)
    -- ═════════════════════════════════════════════════
    local ContentArea = Create("Frame", {
        Size = UDim2.new(1, -TAB_W - 6, 1, -(self._mobile and 38 or 46)),
        Position = UDim2.new(0, TAB_W + 3, 0, (self._mobile and 38 or 44)),
        BackgroundColor3 = self._theme.Glass, BackgroundTransparency = 0.35,
        BorderSizePixel = 0, ZIndex = 2, Parent = Main,
    })
    PixelBevel(ContentArea, self._theme, 1, true)
    self._contentArea = ContentArea

    -- Разделитель
    Create("Frame", {
        Size = UDim2.new(0, 2, 1, -(self._mobile and 36 or 42)),
        Position = UDim2.new(0, TAB_W, 0, (self._mobile and 36 or 42)),
        BackgroundColor3 = self._theme.Border, BorderSizePixel = 0, ZIndex = 3, Parent = Main,
    })

    -- Bottom accent bar
    local BottomBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 5), Position = UDim2.new(0, 0, 1, -5),
        BackgroundColor3 = self._theme.Accent, BorderSizePixel = 0, ZIndex = 3, Parent = Main,
    })
    self._bottomBar = BottomBar

    -- ═════════════════════════════════════════════════
    -- DRAG & SHADOW SYNC
    -- ═════════════════════════════════════════════════
    MakeDraggable(Main, TitleBar)
    Main:GetPropertyChangedSignal("Position"):Connect(function()
        Shadow.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset + 6, Main.Position.Y.Scale, Main.Position.Y.Offset + 6)
    end)

    -- ═════════════════════════════════════════════════
    -- CLOSE
    -- ═════════════════════════════════════════════════
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(220,70,60)}, 0.15) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3 = self._theme.CloseBtn}, 0.15) end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset+WIN_W/2, Main.Position.Y.Scale, Main.Position.Y.Offset+WIN_H/2)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        Tween(Shadow, {BackgroundTransparency = 1}, 0.25)
        task.delay(0.32, function() ScreenGui:Destroy() end)
    end)

    -- ═════════════════════════════════════════════════
    -- THEME CYCLING
    -- ═════════════════════════════════════════════════
    local themeOrder = {"Overworld", "Nether", "End"}
    local themeShort = {Overworld="OW", Nether="NT", End="ED"}
    local themeIdx = 1
    for i,v in ipairs(themeOrder) do if v == self._themeName then themeIdx = i break end end

    ThemeBtn.MouseButton1Click:Connect(function()
        themeIdx = (themeIdx % #themeOrder) + 1
        local name = themeOrder[themeIdx]
        ThemeBtn.Text = themeShort[name]
        self:SetTheme(name)
    end)

    -- ═════════════════════════════════════════════════
    -- KEYBINDS
    -- ═════════════════════════════════════════════════
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        for _, kb in ipairs(self._keybinds) do
            if input.KeyCode == kb.key then pcall(kb.callback) end
        end
    end)

    -- ═════════════════════════════════════════════════
    -- TOGGLE VISIBILITY
    -- ═════════════════════════════════════════════════
    function self:ToggleVisible()
        self._visible = not self._visible
        if self._visible then
            Main.Visible, Shadow.Visible = true, true
            Main.Size = UDim2.new(0,0,0,0)
            Tween(Main, {Size = UDim2.new(0,WIN_W,0,WIN_H)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            Tween(Shadow, {BackgroundTransparency = 0.4}, 0.3)
        else
            Tween(Main, {Size = UDim2.new(0,0,0,0)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            Tween(Shadow, {BackgroundTransparency = 1}, 0.2)
            task.delay(0.24, function() if not self._visible then Main.Visible, Shadow.Visible = false, false end end)
        end
    end

    if not self._mobile then
        UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.RightShift then self:ToggleVisible() end
        end)
    else
        local ToggleBtn = Create("TextButton", {
            Name = "MC_MobileToggle", Size = UDim2.new(0, 48, 0, 48),
            Position = UDim2.new(1, -60, 1, -120),
            BackgroundColor3 = self._theme.TertiaryBG, Text = "M",
            TextColor3 = self._theme.TextPrimary, TextSize = 18,
            Font = FONT, BorderSizePixel = 0, ZIndex = 50, Parent = ScreenGui,
        })
        PixelText(ToggleBtn)
        PixelBevel(ToggleBtn, self._theme, 2)
        MakeDraggable(ToggleBtn, ToggleBtn)
        ToggleBtn.MouseButton1Click:Connect(function() self:ToggleVisible() end)
        self._mobileToggle = ToggleBtn
    end

    -- Viewport scale
    local function AdjustToViewport()
        local vp = Camera.ViewportSize
        local scale = math.clamp(math.min(vp.X/(WIN_W+50), vp.Y/(WIN_H+50), 1), 0.5, 1)
        Tween(UIScaleInst, {Scale = scale}, 0.15)
    end
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(AdjustToViewport)
    AdjustToViewport()

    -- ═════════════════════════════════════════════════
    -- SET THEME
    -- ═════════════════════════════════════════════════
    function self:SetTheme(name)
        local t = Themes[name]
        if not t then return end
        self._theme = t
        self._themeName = name

        MainBg.Image = Textures[t.BackgroundImage]
        TitleBar.BackgroundColor3 = t.TertiaryBG
        TabBar.BackgroundColor3 = t.SecondaryBG
        ContentArea.BackgroundColor3 = t.Glass
        BottomBar.BackgroundColor3 = t.Accent
        TitleLabel.TextColor3 = t.Title
        CloseBtn.BackgroundColor3 = t.CloseBtn
        ThemeBtn.BackgroundColor3 = t.SecondaryBG
        ThemeBtn.TextColor3 = t.TextSecondary
        Shadow.BackgroundColor3 = t.Shadow

        for _, tabInfo in ipairs(self._tabs) do
            local isActive = (tabInfo == self._activeTab)
            tabInfo.btn.BackgroundColor3 = isActive and t.TabActive or t.TabInactive
            tabInfo.btn.TextColor3 = isActive and t.TextPrimary or t.TextSecondary
            tabInfo.activeBar.BackgroundColor3 = t.Accent
            tabInfo.activeBar.Visible = isActive
        end
    end

    -- ═════════════════════════════════════════════════
    -- ADD TAB
    -- ═════════════════════════════════════════════════
    function self:AddTab(name)
        local t = self._theme
        local mobile = self._mobile

        local TabBtn = Create("TextButton", {
            Name = "Tab_" .. name, Size = UDim2.new(1, 0, 0, mobile and 36 or 32),
            BackgroundColor3 = t.TabInactive, Text = name,
            TextColor3 = t.TextSecondary, TextSize = FONT_BODY,
            Font = FONT, BorderSizePixel = 0,
            LayoutOrder = #self._tabs + 1, ZIndex = 4, Parent = self._tabList,
        })
        PixelText(TabBtn)
        PixelBevel(TabBtn, t, 1)

        local ActiveBar = Create("Frame", {
            Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = t.Accent,
            BorderSizePixel = 0, Visible = false, ZIndex = 6, Parent = TabBtn,
        })

        local ContentScroll = Create("ScrollingFrame", {
            Name = "TabContent_" .. name, Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = mobile and 5 or 4,
            ScrollBarImageColor3 = t.Scrollbar,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false, ZIndex = 3, Parent = self._contentArea,
        })
        Create("UIListLayout", {Padding = UDim.new(0, mobile and 6 or 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ContentScroll})
        AddPadding(ContentScroll, 8, 8, 8, 8)

        local tabInfo = {btn = TabBtn, content = ContentScroll, order = #self._tabs + 1, activeBar = ActiveBar}
        table.insert(self._tabs, tabInfo)

        local function SelectThis()
            for _, ti in ipairs(self._tabs) do
                Tween(ti.btn, {BackgroundColor3 = t.TabInactive}, 0.18)
                ti.btn.TextColor3 = t.TextSecondary
                ti.activeBar.Visible = false
                ti.content.Visible = false
            end
            Tween(TabBtn, {BackgroundColor3 = t.TabActive}, 0.18)
            TabBtn.TextColor3 = t.TextPrimary
            ActiveBar.Visible = true
            ContentScroll.Visible = true
            self._activeTab = tabInfo
        end

        TabBtn.MouseButton1Click:Connect(SelectThis)
        TabBtn.MouseEnter:Connect(function()
            if self._activeTab ~= tabInfo then
                Tween(TabBtn, {BackgroundColor3 = t.TertiaryBG}, 0.15)
                TabBtn.TextColor3 = t.TextHover
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if self._activeTab ~= tabInfo then
                Tween(TabBtn, {BackgroundColor3 = t.TabInactive}, 0.15)
                TabBtn.TextColor3 = t.TextSecondary
            end
        end)

        if #self._tabs == 1 then SelectThis() end

        -- ══════════════════════════════════════════════
        -- TAB API
        -- ══════════════════════════════════════════════
        local Tab = {}
        Tab._theme = t
        Tab._parent = ContentScroll
        local layoutOrder = 0
        local function NextOrder() layoutOrder = layoutOrder + 1; return layoutOrder end
        local rowH = mobile and 42 or 36
        local sliderH = mobile and 56 or 48
        local textboxH = mobile and 54 or 46

        -- "Слот" — полупрозрачная рамка, сквозь неё виден фон
        local function MakeSlot(height, customParent)
            local parent = customParent or Tab._parent
            local t2 = self._theme
            local row = Create("Frame", {
                Size = UDim2.new(1, 0, 0, height or rowH),
                BackgroundColor3 = t2.Glass, BackgroundTransparency = 0.25,
                BorderSizePixel = 0, LayoutOrder = NextOrder(), ZIndex = 4, Parent = parent,
            })
            PixelBevel(row, t2, 1, true)
            return row
        end

        -- BUTTON (прозрачный, сквозь него виден dirt)
        function Tab:AddButton(text, callback)
            local t2 = self._theme
            local row = MakeSlot(rowH)

            local Btn = Create("TextButton", {
                Name = "ActionBtn", Size = UDim2.new(1, -14, 1, -10),
                Position = UDim2.new(0, 7, 0.5, -(rowH - 10)/2),
                BackgroundColor3 = t2.Accent, BackgroundTransparency = 0.2,
                Text = "> " .. text, TextColor3 = t2.TextPrimary,
                TextSize = FONT_BODY, Font = FONT, BorderSizePixel = 0, ZIndex = 5, Parent = row,
            })
            PixelText(Btn)
            PixelBevel(Btn, t2, 1)

            Btn.MouseEnter:Connect(function()
                Tween(Btn, {BackgroundColor3 = t2.AccentHover}, 0.18)
                Btn.TextColor3 = t2.TextHover
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Btn, {BackgroundColor3 = t2.Accent}, 0.18)
                Btn.TextColor3 = t2.TextPrimary
            end)
            Btn.MouseButton1Down:Connect(function()
                Tween(Btn, {BackgroundColor3 = t2.AccentPress}, 0.1)
                Btn.Position = UDim2.new(0, 8, 0.5, -(rowH - 10)/2 + 1)
            end)
            Btn.MouseButton1Up:Connect(function()
                Tween(Btn, {BackgroundColor3 = t2.AccentHover}, 0.15)
                Btn.Position = UDim2.new(0, 7, 0.5, -(rowH - 10)/2)
                pcall(callback)
            end)
            return Btn
        end

        -- TOGGLE (прозрачный трек)
        function Tab:AddToggle(text, default, callback)
            local t2, row = self._theme, MakeSlot(rowH)
            local state = default or false

            local lbl = Create("TextLabel", {
                Name = "ItemLabel", Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, Text = text, TextColor3 = t2.TextPrimary,
                TextSize = FONT_BODY, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5, Parent = row,
            })
            PixelText(lbl)

            local trackW = mobile and 48 or 44
            local Track = Create("Frame", {
                Name = "ToggleTrack", Size = UDim2.new(0, trackW, 0, 20),
                Position = UDim2.new(1, -trackW - 10, 0.5, -10),
                BackgroundColor3 = state and t2.ToggleOn or t2.ToggleOff,
                BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 5, Parent = row,
            })
            PixelBevel(Track, t2, 1)

            local Knob = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = state and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3),
                BackgroundColor3 = Color3.fromRGB(240, 240, 240), BorderSizePixel = 0,
                ZIndex = 6, Parent = Track,
            })
            PixelBevel(Knob, t2, 1)

            local ToggleBtn = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 7, Parent = row})

            local function UpdateVisual()
                Tween(Track, {BackgroundColor3 = state and t2.ToggleOn or t2.ToggleOff}, 0.2, Enum.EasingStyle.Quad)
                Tween(Knob, {Position = state and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end

            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state; UpdateVisual(); pcall(callback, state)
            end)

            local toggle = {}
            function toggle:Set(v) state = v; UpdateVisual(); pcall(callback, state) end
            function toggle:Get() return state end
            return toggle
        end

        -- SLIDER (прозрачный)
        function Tab:AddSlider(text, min, max, default, callback)
            local t2, row = self._theme, MakeSlot(sliderH)
            local val = default or min

            local Header = Create("Frame", {Size = UDim2.new(1, 0, 0, mobile and 26 or 22), BackgroundTransparency = 1, ZIndex = 5, Parent = row})
            local hl = Create("TextLabel", {
                Name = "ItemLabel", Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1,
                Text = text, TextColor3 = t2.TextPrimary, TextSize = FONT_BODY,
                Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = Header,
            })
            PixelText(hl)
            AddPadding(Header, 0, 0, 10, 4)

            local ValLabel = Create("TextLabel", {
                Name = "ValueLabel", Size = UDim2.new(0.35, 0, 1, 0), Position = UDim2.new(0.65, 0, 0, 0),
                BackgroundTransparency = 1, Text = tostring(val), TextColor3 = t2.TextSecondary,
                TextSize = FONT_BODY, Font = FONT, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 6, Parent = Header,
            })
            PixelText(ValLabel)

            local sliderY = mobile and 32 or 28
            local SliderBG = Create("Frame", {
                Name = "SliderBG", Size = UDim2.new(1, -18, 0, mobile and 14 or 10), Position = UDim2.new(0, 9, 0, sliderY),
                BackgroundColor3 = t2.SliderBG, BackgroundTransparency = 0.5,
                BorderSizePixel = 0, ZIndex = 5, Parent = row,
            })
            PixelBevel(SliderBG, t2, 1, true)

            local pct = (val - min) / math.max(1, max - min)
            local SliderFill = Create("Frame", {
                Name = "SliderFill", Size = UDim2.new(pct, 0, 1, 0),
                BackgroundColor3 = t2.SliderFill, BackgroundTransparency = 0.2,
                BorderSizePixel = 0, ZIndex = 6, Parent = SliderBG,
            })

            local SliderKnob = Create("Frame", {
                Size = UDim2.new(0, mobile and 12 or 8, 0, mobile and 20 or 14),
                Position = UDim2.new(pct, mobile and -6 or -4, 0.5, mobile and -10 or -7),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 7, Parent = SliderBG,
            })
            PixelBevel(SliderKnob, t2, 1)

            local dragging = false
            local function SetFromInput(inp)
                local absPos, absSize = SliderBG.AbsolutePosition.X, SliderBG.AbsoluteSize.X
                local relative = math.clamp((inp.Position.X - absPos) / absSize, 0, 1)
                local newVal = math.round(min + relative * (max - min))
                val = newVal
                ValLabel.Text = tostring(newVal)
                SliderFill.Size = UDim2.new(relative, 0, 1, 0)
                SliderKnob.Position = UDim2.new(relative, mobile and -6 or -4, 0.5, mobile and -10 or -7)
                pcall(callback, newVal)
            end

            SliderBG.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; SetFromInput(inp)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    SetFromInput(inp)
                end
            end)

            local slider = {}
            function slider:Set(v)
                v = math.clamp(v, min, max); val = v
                local r = (v - min) / math.max(1, max - min)
                ValLabel.Text = tostring(v)
                SliderFill.Size = UDim2.new(r, 0, 1, 0)
                SliderKnob.Position = UDim2.new(r, mobile and -6 or -4, 0.5, mobile and -10 or -7)
                pcall(callback, v)
            end
            function slider:Get() return val end
            return slider
        end

        -- TEXTBOX (прозрачный)
        function Tab:AddTextbox(text, placeholder, callback)
            local t2, row = self._theme, MakeSlot(textboxH)
            local lbl = Create("TextLabel", {
                Name = "ItemLabel", Size = UDim2.new(1, -10, 0, mobile and 20 or 18), Position = UDim2.new(0, 10, 0, 4),
                BackgroundTransparency = 1, Text = text, TextColor3 = t2.TextSecondary,
                TextSize = FONT_BODY - 1, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = row,
            })
            PixelText(lbl)

            local Box = Create("TextBox", {
                Size = UDim2.new(1, -18, 0, mobile and 24 or 20), Position = UDim2.new(0, 9, 0, mobile and 26 or 24),
                BackgroundColor3 = t2.Background, BackgroundTransparency = 0.3,
                Text = "", PlaceholderText = placeholder or "Type here...",
                PlaceholderColor3 = t2.TextDisabled, TextColor3 = t2.TextPrimary, TextSize = FONT_BODY,
                Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0,
                ClearTextOnFocus = false, ZIndex = 5, Parent = row,
            })
            AddPadding(Box, 0, 0, 6, 6)
            PixelBevel(Box, t2, 1, true)

            Box.Focused:Connect(function() Tween(Box, {BackgroundColor3 = t2.SecondaryBG}, 0.15) end)
            Box.FocusLost:Connect(function(enter)
                Tween(Box, {BackgroundColor3 = t2.Background}, 0.15)
                if enter then pcall(callback, Box.Text) end
            end)

            local tb = {}
            function tb:Set(v) Box.Text = v end
            function tb:Get() return Box.Text end
            return tb
        end

        -- DROPDOWN (прозрачный)
        function Tab:AddDropdown(text, options, callback)
            local t2, open = self._theme, false
            local selected = options[1] or ""
            local row = MakeSlot(rowH)

            local lbl = Create("TextLabel", {
                Name = "ItemLabel", Size = UDim2.new(0.35, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, Text = text, TextColor3 = t2.TextPrimary,
                TextSize = FONT_BODY, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = row,
            })
            PixelText(lbl)

            local DropBtn = Create("TextButton", {
                Size = UDim2.new(0.6, 0, 0, rowH - 12), Position = UDim2.new(0.38, 0, 0.5, -(rowH - 12)/2),
                BackgroundColor3 = t2.Background, BackgroundTransparency = 0.3,
                Text = selected .. " ▼", TextColor3 = t2.TextPrimary,
                TextSize = FONT_BODY - 1, Font = FONT, BorderSizePixel = 0, ZIndex = 5, Parent = row,
            })
            PixelText(DropBtn)
            PixelBevel(DropBtn, t2, 1, true)

            local ListFrame = Create("Frame", {
                Size = UDim2.new(0.6, 0, 0, #options * (mobile and 30 or 24) + 4),
                Position = UDim2.new(0.38, 0, 1, 2),
                BackgroundColor3 = t2.SecondaryBG, BackgroundTransparency = 0.15,
                BorderSizePixel = 0, ZIndex = 12, Visible = false, Parent = row,
            })
            PixelBevel(ListFrame, t2, 1)
            Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = ListFrame})
            AddPadding(ListFrame, 2, 2, 2, 2)

            for i, opt in ipairs(options) do
                local OptBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, mobile and 26 or 22),
                    BackgroundColor3 = t2.Background, BackgroundTransparency = 0.25,
                    Text = opt, TextColor3 = t2.TextSecondary, TextSize = FONT_BODY - 1,
                    Font = FONT, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 13, Parent = ListFrame,
                })
                PixelText(OptBtn)
                OptBtn.MouseEnter:Connect(function()
                    Tween(OptBtn, {BackgroundColor3 = t2.Accent}, 0.14); OptBtn.TextColor3 = t2.TextHover
                end)
                OptBtn.MouseLeave:Connect(function()
                    Tween(OptBtn, {BackgroundColor3 = t2.Background}, 0.14); OptBtn.TextColor3 = t2.TextSecondary
                end)
                OptBtn.MouseButton1Click:Connect(function()
                    selected = opt; DropBtn.Text = opt .. " ▼"; open = false; ListFrame.Visible = false
                    pcall(callback, opt)
                end)
            end

            DropBtn.MouseButton1Click:Connect(function()
                open = not open; ListFrame.Visible = open
                DropBtn.Text = selected .. (open and " ▲" or " ▼")
            end)

            UserInputService.InputBegan:Connect(function(inp, gp)
                if gp then return end
                if open and inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    local pos = inp.Position
                    local ap, as = ListFrame.AbsolutePosition, ListFrame.AbsoluteSize
                    if pos.X < ap.X or pos.X > ap.X + as.X or pos.Y < ap.Y or pos.Y > ap.Y + as.Y then
                        if not (pos.X >= row.AbsolutePosition.X and pos.X <= row.AbsolutePosition.X + row.AbsoluteSize.X
                            and pos.Y >= row.AbsolutePosition.Y and pos.Y <= row.AbsolutePosition.Y + row.AbsoluteSize.Y) then
                            open = false; ListFrame.Visible = false; DropBtn.Text = selected .. " ▼"
                        end
                    end
                end
            end)

            local dd = {}
            function dd:Set(v) selected = v; DropBtn.Text = v .. " ▼"; pcall(callback, v) end
            function dd:Get() return selected end
            return dd
        end

        -- LABEL (прозрачный)
        function Tab:AddLabel(text)
            local t2, row = self._theme, MakeSlot(mobile and 32 or 28)
            row.BackgroundTransparency = 1
            for _, ch in ipairs(row:GetChildren()) do
                if ch.Name:sub(1,5) == "Bevel" or ch:IsA("UIStroke") then ch:Destroy() end
            end
            local lbl = Create("TextLabel", {
                Name = "ItemLabel", Size = UDim2.new(1, -18, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, Text = "» " .. text, TextColor3 = t2.TextSecondary,
                TextSize = FONT_BODY, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = row,
            })
            PixelText(lbl)
            local label = {}
            function label:Set(v) lbl.Text = "» " .. v end
            function label:Get() return lbl.Text end
            return label
        end

        -- SEPARATOR
        function Tab:AddSeparator(labelText)
            local t2 = self._theme
            local row = Create("Frame", {
                Size = UDim2.new(1, 0, 0, mobile and 22 or 20), BackgroundTransparency = 1,
                BorderSizePixel = 0, LayoutOrder = NextOrder(), ZIndex = 4, Parent = Tab._parent,
            })
            Create("Frame", {
                Name = "Separator", Size = UDim2.new(1, -18, 0, 2), Position = UDim2.new(0, 9, 0.5, 0),
                BackgroundColor3 = t2.Accent, BackgroundTransparency = 0.3,
                BorderSizePixel = 0, ZIndex = 5, Parent = row,
            })
            if labelText then
                local tw = #labelText * 8 + 14
                local bg = Create("Frame", {
                    Size = UDim2.new(0, tw, 0, 14), Position = UDim2.new(0.5, -tw/2, 0, -6),
                    BackgroundColor3 = t2.Glass, BackgroundTransparency = 0.2,
                    BorderSizePixel = 0, ZIndex = 6, Parent = row,
                })
                local lbl = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = labelText,
                    TextColor3 = t2.Accent, TextSize = 10, Font = FONT, ZIndex = 7, Parent = bg,
                })
                PixelText(lbl)
            end
        end

        -- KEYBIND (прозрачный)
        function Tab:AddKeybind(text, defaultKey, callback)
            local t2, row = self._theme, MakeSlot(rowH)
            local key, listening = defaultKey, false

            local lbl = Create("TextLabel", {
                Name = "ItemLabel", Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, Text = text, TextColor3 = t2.TextPrimary,
                TextSize = FONT_BODY, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = row,
            })
            PixelText(lbl)

            local KeyBtn = Create("TextButton", {
                Size = UDim2.new(0, mobile and 90 or 80, 0, rowH - 10), Position = UDim2.new(1, -(mobile and 102 or 92), 0.5, -(rowH - 10)/2),
                BackgroundColor3 = t2.Background, BackgroundTransparency = 0.3,
                Text = key and key.Name or "None", TextColor3 = t2.Accent,
                TextSize = FONT_BODY - 1, Font = FONT, BorderSizePixel = 0, ZIndex = 5, Parent = row,
            })
            PixelText(KeyBtn, t2.Accent)
            PixelBevel(KeyBtn, t2, 1, true)

            KeyBtn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true; KeyBtn.Text = "..."
                local con
                con = UserInputService.InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    if inp.UserInputType == Enum.UserInputType.Keyboard then
                        key = inp.KeyCode; KeyBtn.Text = inp.KeyCode.Name
                        listening = false; con:Disconnect()
                        for i, kb in ipairs(self._keybinds) do
                            if kb.id == text then table.remove(self._keybinds, i); break end
                        end
                        table.insert(self._keybinds, {id = text, key = key, callback = callback})
                    end
                end)
            end)

            if key then table.insert(self._keybinds, {id = text, key = key, callback = callback}) end

            local kb = {}
            function kb:Get() return key end
            return kb
        end

        -- COLOR PICKER (прозрачный)
        function Tab:AddColorPicker(text, default, callback)
            local t2, row = self._theme, MakeSlot(rowH)
            local col, open = default or Color3.fromRGB(255, 0, 0), false

            local lbl = Create("TextLabel", {
                Name = "ItemLabel", Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, Text = text, TextColor3 = t2.TextPrimary,
                TextSize = FONT_BODY, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = row,
            })
            PixelText(lbl)

            local Preview = Create("Frame", {
                Size = UDim2.new(0, 26, 0, 20), Position = UDim2.new(1, -36, 0.5, -10),
                BackgroundColor3 = col, BorderSizePixel = 0, ZIndex = 5, Parent = row,
            })
            PixelBevel(Preview, t2, 1)

            local Popup = Create("Frame", {
                Size = UDim2.new(0, mobile and 210 or 190, 0, 140), Position = UDim2.new(1, mobile and -215 or -195, 1, 4),
                BackgroundColor3 = t2.Glass, BackgroundTransparency = 0.2,
                BorderSizePixel = 0, ZIndex = 14, Visible = false, Parent = row,
            })
            PixelBevel(Popup, t2, 1)

            local presets = {
                Color3.fromRGB(255,0,0), Color3.fromRGB(255,128,0), Color3.fromRGB(255,255,0),
                Color3.fromRGB(0,255,0), Color3.fromRGB(0,255,255), Color3.fromRGB(0,0,255),
                Color3.fromRGB(128,0,255), Color3.fromRGB(255,0,255), Color3.fromRGB(255,255,255),
                Color3.fromRGB(0,0,0), Color3.fromRGB(128,128,128), t2.Accent,
            }
            for i, pc in ipairs(presets) do
                local col_x = ((i - 1) % 6) * 30 + 5
                local col_y = math.floor((i - 1) / 6) * 28 + 5
                local swatch = Create("TextButton", {
                    Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, col_x, 0, col_y),
                    BackgroundColor3 = pc, Text = "", BorderSizePixel = 0, ZIndex = 15, Parent = Popup,
                })
                PixelBevel(swatch, t2, 1)
                swatch.MouseButton1Click:Connect(function()
                    col = pc; Preview.BackgroundColor3 = col; Popup.Visible = false; open = false
                    pcall(callback, col)
                end)
            end

            local r, g, b = col.R, col.G, col.B
            local function makeRGBSlider(letter, posY, getVal, setVal)
                local ll = Create("TextLabel", {
                    Size = UDim2.new(0, 14, 0, 12), Position = UDim2.new(0, 6, 0, posY),
                    BackgroundTransparency = 1, Text = letter, TextColor3 = t2.TextSecondary,
                    TextSize = 9, Font = FONT, ZIndex = 15, Parent = Popup,
                })
                PixelText(ll)
                local bg = Create("Frame", {
                    Size = UDim2.new(0, mobile and 160 or 140, 0, 8), Position = UDim2.new(0, 22, 0, posY + 2),
                    BackgroundColor3 = t2.SliderBG, BackgroundTransparency = 0.5,
                    BorderSizePixel = 0, ZIndex = 15, Parent = Popup,
                })
                PixelBevel(bg, t2, 1, true)
                local fill = Create("Frame", {
                    Size = UDim2.new(getVal(), 0, 1, 0), BackgroundColor3 = t2.Accent,
                    BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 16, Parent = bg,
                })
                local draggingRGB = false
                local function apply(inp)
                    local rel = math.clamp((inp.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(rel, 0, 1, 0); setVal(rel)
                    Preview.BackgroundColor3 = col; pcall(callback, col)
                end
                bg.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        draggingRGB = true; apply(inp)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then draggingRGB = false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if draggingRGB and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then apply(inp) end
                end)
            end

            makeRGBSlider("R", 66, function() return r end, function(v) r = v; col = Color3.new(r, g, b) end)
            makeRGBSlider("G", 84, function() return g end, function(v) g = v; col = Color3.new(r, g, b) end)
            makeRGBSlider("B", 102, function() return b end, function(v) b = v; col = Color3.new(r, g, b) end)

            local OpenBtn = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 6, Parent = Preview})
            OpenBtn.MouseButton1Click:Connect(function() open = not open; Popup.Visible = open end)

            UserInputService.InputBegan:Connect(function(inp, gp)
                if gp or not open then return end
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    local pos = inp.Position
                    local ap, as = Popup.AbsolutePosition, Popup.AbsoluteSize
                    if pos.X < ap.X or pos.X > ap.X + as.X or pos.Y < ap.Y or pos.Y > ap.Y + as.Y then
                        if not (pos.X >= Preview.AbsolutePosition.X and pos.X <= Preview.AbsolutePosition.X + Preview.AbsoluteSize.X
                            and pos.Y >= Preview.AbsolutePosition.Y and pos.Y <= Preview.AbsolutePosition.Y + Preview.AbsoluteSize.Y) then
                            open = false; Popup.Visible = false
                        end
                    end
                end
            end)

            local cp = {}
            function cp:Set(c) col = c; Preview.BackgroundColor3 = c; pcall(callback, c) end
            function cp:Get() return col end
            return cp
        end

        -- SECTION (сворачиваемая группа)
        function Tab:AddSection(title)
            local t2 = self._theme
            local open = true

            local Header = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, mobile and 32 or 28),
                BackgroundColor3 = t2.TertiaryBG, BackgroundTransparency = 0.2,
                Text = "v " .. title, TextColor3 = t2.Accent, TextSize = FONT_BODY,
                Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0,
                LayoutOrder = NextOrder(), ZIndex = 4, Parent = Tab._parent,
            })
            PixelText(Header, t2.Accent)
            AddPadding(Header, 0, 0, 10, 10)
            PixelBevel(Header, t2, 1)

            local SectionFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, LayoutOrder = NextOrder(), ZIndex = 4, Parent = Tab._parent,
            })
            Create("UIListLayout", {Padding = UDim.new(0, mobile and 5 or 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = SectionFrame})
            AddPadding(SectionFrame, 0, 0, 10, 0)

            Header.MouseButton1Click:Connect(function()
                open = not open
                SectionFrame.Visible = open
                Header.Text = (open and "v " or "> ") .. title
                Tween(Header, {BackgroundColor3 = open and t2.TertiaryBG or t2.SecondaryBG}, 0.15)
            end)

            local Sec = {}
            setmetatable(Sec, {__index = Tab})
            Sec._parent = SectionFrame
            return Sec
        end

        -- NOTIFY из вкладки
        function Tab:AddNotify(title, msg, duration)
            self:Notify(title, msg, duration)
        end

        return Tab
    end

    -- ══════════════════════════════════════════════════
    -- ACHIEVEMENT TOAST (UI-стиль, без картинки)
    -- ══════════════════════════════════════════════════
    function self:Notify(title, message, duration)
        local t = self._theme
        duration = duration or 4

        local notif = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = t.Notification, BackgroundTransparency = 0.15,
            BorderSizePixel = 0, ZIndex = 25, Parent = NotifContainer,
        })
        PixelBevel(notif, t, 2)

        -- Золотая полоска слева
        Create("Frame", {
            Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = t.NotifAccent,
            BorderSizePixel = 0, ZIndex = 26, Parent = notif,
        })

        local Inner = Create("Frame", {
            Size = UDim2.new(1, -10, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, ZIndex = 26, Parent = notif,
        })
        AddPadding(Inner, 8, 8, 8, 8)

        local tl = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = title,
            TextColor3 = t.NotifAccent, TextSize = 13, Font = FONT,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 27, Parent = Inner,
        })
        PixelText(tl)

        local ml = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 0, 0, 20),
            BackgroundTransparency = 1, Text = message, TextColor3 = t.TextSecondary,
            TextSize = 11, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, ZIndex = 27, Parent = Inner,
        })
        PixelText(ml)

        -- Прогресс-бар
        local ProgBG = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = t.SliderBG, BackgroundTransparency = 0.5,
            BorderSizePixel = 0, ZIndex = 27, Parent = notif,
        })
        local Prog = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = t.NotifAccent,
            BorderSizePixel = 0, ZIndex = 28, Parent = ProgBG,
        })

        Tween(notif, {BackgroundTransparency = 0.15}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        Tween(Prog, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)

        task.delay(duration, function()
            Tween(notif, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.3)
            task.delay(0.35, function() if notif.Parent then notif:Destroy() end end)
        end)
    end

    -- ══════════════════════════════════════════════════
    -- DESTROY
    -- ══════════════════════════════════════════════════
    function self:Destroy()
        if self._gui then self._gui:Destroy() end
    end

    return self
end

return MinecraftLib
