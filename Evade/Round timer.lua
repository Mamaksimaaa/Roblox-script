-- ════════════════════════════════════════
--           ROUND TIMER by IRY HUB
-- Самостоятельный скрипт — не требует evae.lua
-- ════════════════════════════════════════

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp                = Players.LocalPlayer

local function SetupRoundTimer()
    local playerGui = lp:WaitForChild("PlayerGui", 15)
    if not playerGui then
        warn("[RoundTimer] PlayerGui не найден")
        return
    end

    -- Убираем старый таймер если уже есть
    local old = playerGui:FindFirstChild("IRY_RoundTimerGui")
    if old then old:Destroy() end

    -- ── ScreenGui ──────────────────────────────
    local timerGui = Instance.new("ScreenGui")
    timerGui.Name           = "IRY_RoundTimerGui"
    timerGui.ResetOnSpawn   = false
    timerGui.DisplayOrder   = 999
    timerGui.IgnoreGuiInset = true
    timerGui.Parent         = playerGui

    -- ── TextLabel ──────────────────────────────
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name               = "RoundTimer"
    timerLabel.Position           = UDim2.new(0.5, 0, 0.0500000007, 0)
    timerLabel.AnchorPoint        = Vector2.new(0.5, 0)
    timerLabel.Size               = UDim2.new(0, 130, 0, 38)
    timerLabel.BackgroundColor3   = Color3.fromRGB(10, 10, 10)
    timerLabel.BackgroundTransparency = 0.35
    timerLabel.BorderSizePixel    = 0
    timerLabel.Text               = "--:--"
    timerLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
    timerLabel.Font               = Enum.Font.GothamBold
    timerLabel.TextScaled         = true
    timerLabel.ZIndex             = 10
    timerLabel.Parent             = timerGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent       = timerLabel

    local uiPad = Instance.new("UIPadding")
    uiPad.PaddingLeft  = UDim.new(0, 8)
    uiPad.PaddingRight = UDim.new(0, 8)
    uiPad.Parent       = timerLabel

    -- ── Формат секунд → M:SS ───────────────────
    local function FormatTime(totalSeconds)
        totalSeconds = math.max(0, math.floor(totalSeconds))
        local minutes = math.floor(totalSeconds / 60)
        local secs    = totalSeconds % 60
        return string.format("%d:%02d", minutes, secs)
    end

    -- ── Цвет по времени ────────────────────────
    local function UpdateColor(seconds)
        if seconds <= 30 then
            timerLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        elseif seconds <= 60 then
            timerLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        else
            timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
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

    roundEvent.OnClientEvent:Connect(function(key, value)
        if key == "Time" and type(value) == "number" then
            timerLabel.Text = FormatTime(value)
            UpdateColor(value)
        end
    end)

    print("[IRY HUB] Round Timer активен")
end

task.spawn(SetupRoundTimer)
