-- ════════════════════════════════════════
--           ROUND TIMER by IRY HUB
--         Enhanced Visual Edition
-- ════════════════════════════════════════

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local lp                = Players.LocalPlayer

local function SetupRoundTimer()
    local playerGui = lp:WaitForChild("PlayerGui", 15)
    if not playerGui then
        warn("[RoundTimer] PlayerGui не найден")
        return
    end

    local old = playerGui:FindFirstChild("IRY_RoundTimerGui")
    if old then old:Destroy() end

    -- ── ScreenGui ──────────────────────────────
    local timerGui = Instance.new("ScreenGui")
    timerGui.Name           = "IRY_RoundTimerGui"
    timerGui.ResetOnSpawn   = false
    timerGui.DisplayOrder   = 999
    timerGui.IgnoreGuiInset = true
    timerGui.Parent         = playerGui

    -- ── Фоновый BLUR эффект ────────────────────
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Size   = 0
    blurEffect.Parent = game:GetService("Lighting")

    -- ── Внешний контейнер (тень + свечение) ───
    local outerFrame = Instance.new("Frame")
    outerFrame.Name                  = "OuterGlow"
    outerFrame.Position              = UDim2.new(0.5, 0, 0.04, 0)
    outerFrame.AnchorPoint           = Vector2.new(0.5, 0)
    outerFrame.Size                  = UDim2.new(0, 180, 0, 58)
    outerFrame.BackgroundColor3      = Color3.fromRGB(120, 160, 255)
    outerFrame.BackgroundTransparency = 0.75
    outerFrame.BorderSizePixel       = 0
    outerFrame.ZIndex                = 8
    outerFrame.Parent                = timerGui

    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(0, 14)
    outerCorner.Parent       = outerFrame

    -- ── Основной фрейм (стекло) ────────────────
    local mainFrame = Instance.new("Frame")
    mainFrame.Name                   = "TimerFrame"
    mainFrame.Position               = UDim2.new(0.5, 0, 0.04, 0)
    mainFrame.AnchorPoint            = Vector2.new(0.5, 0)
    mainFrame.Size                   = UDim2.new(0, 176, 0, 54)
    mainFrame.BackgroundColor3       = Color3.fromRGB(8, 10, 20)
    mainFrame.BackgroundTransparency = 0.22
    mainFrame.BorderSizePixel        = 0
    mainFrame.ZIndex                 = 9
    mainFrame.Parent                 = timerGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent       = mainFrame

    -- ── Верхняя полоска акцента ────────────────
    local accentBar = Instance.new("Frame")
    accentBar.Name                   = "AccentBar"
    accentBar.Position               = UDim2.new(0.1, 0, 0, 0)
    accentBar.AnchorPoint            = Vector2.new(0, 0)
    accentBar.Size                   = UDim2.new(0.8, 0, 0, 2)
    accentBar.BackgroundColor3       = Color3.fromRGB(100, 160, 255)
    accentBar.BackgroundTransparency = 0
    accentBar.BorderSizePixel        = 0
    accentBar.ZIndex                 = 12
    accentBar.Parent                 = mainFrame

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent       = accentBar

    -- ── Внутренний градиент фона ───────────────
    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(20, 28, 55)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 16, 35)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(8,  12, 28)),
    })
    uiGradient.Rotation = 135
    uiGradient.Parent   = mainFrame

    -- ── Иконка часов (лейбл) ───────────────────
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name               = "Icon"
    iconLabel.Position           = UDim2.new(0, 10, 0.5, 0)
    iconLabel.AnchorPoint        = Vector2.new(0, 0.5)
    iconLabel.Size               = UDim2.new(0, 22, 0, 22)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text               = "⏱"
    iconLabel.TextColor3         = Color3.fromRGB(120, 170, 255)
    iconLabel.Font               = Enum.Font.GothamBold
    iconLabel.TextScaled         = true
    iconLabel.ZIndex             = 11
    iconLabel.Parent             = mainFrame

    -- ── Лейбл «ROUND» ─────────────────────────
    local roundLabel = Instance.new("TextLabel")
    roundLabel.Name               = "RoundTag"
    roundLabel.Position           = UDim2.new(0, 38, 0, 6)
    roundLabel.AnchorPoint        = Vector2.new(0, 0)
    roundLabel.Size               = UDim2.new(1, -48, 0, 14)
    roundLabel.BackgroundTransparency = 1
    roundLabel.Text               = "ROUND"
    roundLabel.TextColor3         = Color3.fromRGB(100, 140, 220)
    roundLabel.Font               = Enum.Font.Gotham
    roundLabel.TextSize           = 10
    roundLabel.TextXAlignment     = Enum.TextXAlignment.Left
    roundLabel.ZIndex             = 11
    roundLabel.Parent             = mainFrame

    -- ── Основной TextLabel таймера ─────────────
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name               = "RoundTimer"
    timerLabel.Position           = UDim2.new(0, 36, 0, 18)
    timerLabel.AnchorPoint        = Vector2.new(0, 0)
    timerLabel.Size               = UDim2.new(1, -46, 0, 28)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text               = "--:--"
    timerLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
    timerLabel.Font               = Enum.Font.GothamBold
    timerLabel.TextSize           = 22
    timerLabel.TextXAlignment     = Enum.TextXAlignment.Left
    timerLabel.ZIndex             = 11
    timerLabel.Parent             = mainFrame

    -- ── Пульсирующая точка (живой индикатор) ──
    local dot = Instance.new("Frame")
    dot.Name                   = "LiveDot"
    dot.Position               = UDim2.new(1, -14, 0.5, 0)
    dot.AnchorPoint            = Vector2.new(0.5, 0.5)
    dot.Size                   = UDim2.new(0, 7, 0, 7)
    dot.BackgroundColor3       = Color3.fromRGB(80, 220, 120)
    dot.BackgroundTransparency = 0
    dot.BorderSizePixel        = 0
    dot.ZIndex                 = 12
    dot.Parent                 = mainFrame

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent       = dot

    -- Анимация пульса точки
    local function PulseDot()
        while dot and dot.Parent do
            TweenService:Create(dot, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
                BackgroundTransparency = 0.7,
                Size = UDim2.new(0, 10, 0, 10),
            }):Play()
            task.wait(0.6)
            TweenService:Create(dot, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
                BackgroundTransparency = 0,
                Size = UDim2.new(0, 7, 0, 7),
            }):Play()
            task.wait(0.6)
        end
    end
    task.spawn(PulseDot)

    -- Анимация появления
    mainFrame.BackgroundTransparency = 1
    outerFrame.BackgroundTransparency = 1
    timerLabel.TextTransparency = 1
    roundLabel.TextTransparency = 1
    iconLabel.TextTransparency  = 1

    task.delay(0.1, function()
        TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.22,
        }):Play()
        TweenService:Create(outerFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
            BackgroundTransparency = 0.75,
        }):Play()
        TweenService:Create(timerLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            TextTransparency = 0,
        }):Play()
        TweenService:Create(roundLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            TextTransparency = 0,
        }):Play()
        TweenService:Create(iconLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            TextTransparency = 0,
        }):Play()
    end)

    -- ── Формат секунд → M:SS ───────────────────
    local function FormatTime(totalSeconds)
        totalSeconds = math.max(0, math.floor(totalSeconds))
        local minutes = math.floor(totalSeconds / 60)
        local secs    = totalSeconds % 60
        return string.format("%d:%02d", minutes, secs)
    end

    -- ── Текущее состояние цвета ────────────────
    local currentColorState = "white"

    local function UpdateColor(seconds)
        if seconds <= 30 and currentColorState ~= "red" then
            currentColorState = "red"
            -- Красный + усиленное свечение
            TweenService:Create(timerLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
                TextColor3 = Color3.fromRGB(255, 85, 85),
            }):Play()
            TweenService:Create(accentBar, TweenInfo.new(0.4), {
                BackgroundColor3 = Color3.fromRGB(255, 85, 85),
            }):Play()
            TweenService:Create(outerFrame, TweenInfo.new(0.4), {
                BackgroundColor3 = Color3.fromRGB(255, 80, 80),
            }):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(255, 80, 80),
            }):Play()

        elseif seconds > 30 and seconds <= 60 and currentColorState ~= "yellow" then
            currentColorState = "yellow"
            TweenService:Create(timerLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
                TextColor3 = Color3.fromRGB(255, 210, 60),
            }):Play()
            TweenService:Create(accentBar, TweenInfo.new(0.4), {
                BackgroundColor3 = Color3.fromRGB(255, 210, 60),
            }):Play()
            TweenService:Create(outerFrame, TweenInfo.new(0.4), {
                BackgroundColor3 = Color3.fromRGB(230, 180, 50),
            }):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(255, 210, 60),
            }):Play()

        elseif seconds > 60 and currentColorState ~= "white" then
            currentColorState = "white"
            TweenService:Create(timerLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
                TextColor3 = Color3.fromRGB(255, 255, 255),
            }):Play()
            TweenService:Create(accentBar, TweenInfo.new(0.4), {
                BackgroundColor3 = Color3.fromRGB(100, 160, 255),
            }):Play()
            TweenService:Create(outerFrame, TweenInfo.new(0.4), {
                BackgroundColor3 = Color3.fromRGB(120, 160, 255),
            }):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(80, 220, 120),
            }):Play()
        end
    end

    -- ── Ждём событие ───────────────────────────
    local eventsFolder = ReplicatedStorage:WaitForChild("Events", 15)
    if not eventsFolder then
        warn("[RoundTimer] ReplicatedStorage.Events не найден")
        return
    end

    local roundEvent = eventsFolder:WaitForChild("UpdateServerStateRegistryUnreliable", 15)
    if not roundEvent then
        warn("[RoundTimer] UpdateServerStateRegistryUnreliable не найден")
        return
    end

    local lastSecond = -1
    roundEvent.OnClientEvent:Connect(function(key, value)
        if key == "Time" and type(value) == "number" then
            local floored = math.floor(value)
            timerLabel.Text = FormatTime(value)
            UpdateColor(floored)

            -- Флэш анимация при каждой новой секунде
            if floored ~= lastSecond then
                lastSecond = floored
                TweenService:Create(timerLabel, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    TextTransparency = 0.35,
                }):Play()
                task.delay(0.05, function()
                    TweenService:Create(timerLabel, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                        TextTransparency = 0,
                    }):Play()
                end)
            end
        end
    end)

    print("[IRY HUB] Round Timer (Enhanced) активен ✓")
end

task.spawn(SetupRoundTimer)
