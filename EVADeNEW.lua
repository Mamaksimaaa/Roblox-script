--[[
    ===================================================
    Inlawry Universal Suite
    Developed by: inlawry
    All Rights Reserved © 2026 inlawry
    
    Unlawful distribution, unauthorized copying, or 
    re-branding of this source code without explicit 
    permission from the author is strictly prohibited.
    ===================================================
]]

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local Stats = cloneref(game:GetService("Stats"))
local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local HttpService = cloneref(game:GetService("HttpService"))

local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)

    if ok then
        WindUI = result
    else
        if RunService:IsStudio() then
            WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

-- Файл сохранения текущей темы
local themeConfigFile = "Inlawry_SelectedTheme.txt"
local selectedTheme = "Dark"

if isfile and readfile and isfile(themeConfigFile) then
    local savedTheme = readfile(themeConfigFile)
    if savedTheme and savedTheme ~= "" then
        selectedTheme = savedTheme
    end
end

-- Основные переменные
local autoFarmActive = false
local farmDelay = 0.5
local farmMethod = "Tween TP"
local tweenSpeed = 1.5

-- Переменные Avoid Bot
local avoidBotActive = false
local avoidRadius = 15
local avoidDistance = 25
local avoidMethod = "Tween"

-- Переменные Ping Stabilization
local pingStabilizerActive = false
local maxAllowedPing = 150

local function getPing()
    local pingValue = 0
    pcall(function()
        pingValue = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    return pingValue
end

-- Создание окна
local Window = WindUI:CreateWindow({
    Title = "Inlawry Hub  |  Universal",
    Author = "by inlawry",
    Folder = "Inlawry_Universal",
    Icon = "solar:rocket-bold",
    Theme = selectedTheme,
    OpenButton = {
        Title = "Open Inlawry UI",
        CornerRadius = UDim.new(1, 0),
        Enabled = true,
        Draggable = true,
    },
})

Window:Tag({
    Title = "© inlawry",
    Icon = "copyright",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true,
})

local MainTab = Window:Tab({
    Title = "Event Claim",
    Icon = "solar:star-bold",
})

local SettingsTab = Window:Tab({
    Title = "Settings & Configs",
    Icon = "solar:settings-bold",
})

-- Функция перезагрузки окна для смены темы
local function reloadUIWithTheme(newTheme)
    if writefile then
        writefile(themeConfigFile, newTheme)
    end
    
    WindUI:Notify({
        Title = "Inlawry Hub",
        Content = "Применение темы: " .. newTheme .. "...",
        Duration = 2,
    })
    
    task.wait(0.5)
    Window:Destroy()
    
    -- Перезапуск интерфейса
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
end

-- ===================================================
-- ПОСТОЯННЫЙ ЦИКЛ AVOID BOT
-- ===================================================
task.spawn(function()
    while true do
        if avoidBotActive then
            local player = Players.LocalPlayer
            local character = player and player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")

            if hrp then
                local playerCache = workspace:FindFirstChild("PlayerCache")
                local playersFolder = playerCache and playerCache:FindFirstChild("Players")

                if playersFolder then
                    for _, model in ipairs(playersFolder:GetChildren()) do
                        if model.Name ~= player.Name then
                            local modelPos = nil

                            if model:IsA("BasePart") then
                                modelPos = model.Position
                            elseif model:IsA("Model") then
                                modelPos = model:GetPivot().Position
                            end

                            if modelPos then
                                local dist = (hrp.Position - modelPos).Magnitude

                                if dist <= avoidRadius then
                                    local moveDirection = (hrp.Position - modelPos).Unit
                                    if moveDirection ~= moveDirection then
                                        moveDirection = Vector3.new(0, 1, 0)
                                    end

                                    local targetPos = hrp.Position + (moveDirection * avoidDistance) + Vector3.new(0, 10, 0)
                                    local targetCFrame = CFrame.new(targetPos, targetPos + hrp.CFrame.LookVector)

                                    if avoidMethod == "Tween" then
                                        local tween = TweenService:Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = targetCFrame})
                                        tween:Play()
                                        tween.Completed:Wait()
                                    else
                                        hrp.CFrame = targetCFrame
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- ===================================================
-- ЛОГИКА АВТОФАРМА
-- ===================================================
local function startAutoFarm()
    task.spawn(function()
        while autoFarmActive do
            if pingStabilizerActive then
                while autoFarmActive and getPing() > maxAllowedPing do
                    task.wait(0.5)
                end
            end

            local map = workspace:FindFirstChild("Map")
            local itemSpawns = map and map:FindFirstChild("ItemSpawns")

            if itemSpawns then
                local items = itemSpawns:GetChildren()

                for _, item in ipairs(items) do
                    if not autoFarmActive then break end

                    if pingStabilizerActive then
                        while autoFarmActive and getPing() > maxAllowedPing do
                            task.wait(0.5)
                        end
                    end

                    local player = Players.LocalPlayer
                    local character = player and player.Character

                    if character then
                        local hrp = character:FindFirstChild("HumanoidRootPart")

                        local targetCFrame = nil
                        if item:IsA("BasePart") then
                            targetCFrame = item.CFrame
                        elseif item:IsA("Model") then
                            targetCFrame = item:GetPivot()
                        end

                        if targetCFrame and hrp then
                            if farmMethod == "Instant TP" then
                                hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
                                task.wait(farmDelay)

                            elseif farmMethod == "Tween TP" then
                                local tween = TweenService:Create(hrp, TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame + Vector3.new(0, 3, 0)})
                                tween:Play()
                                tween.Completed:Wait()
                                task.wait(farmDelay)

                            elseif farmMethod == "Bring Spawns" then
                                local playerPos = hrp.CFrame
                                if item:IsA("BasePart") then
                                    item.CFrame = playerPos
                                elseif item:IsA("Model") then
                                    item:PivotTo(playerPos)
                                end
                                task.wait(farmDelay)

                            elseif farmMethod == "Limb Teleport" then
                                local limb = character:FindFirstChild("RightFoot") 
                                         or character:FindFirstChild("Right Leg") 
                                         or character:FindFirstChild("RightHand")

                                if limb then
                                    local originalCFrame = limb.CFrame
                                    limb.CFrame = targetCFrame
                                    task.wait(0.1)
                                    limb.CFrame = originalCFrame
                                    task.wait(farmDelay)
                                end
                            end
                        end
                    end
                end
            else
                WindUI:Notify({
                    Title = "Inlawry Universal",
                    Content = "Объект Workspace.Map.ItemSpawns не найден!",
                    Duration = 3,
                })
                autoFarmActive = false
                break
            end

            task.wait(0.1)
        end
    end)
end

-- ===================================================
-- ЭЛЕМЕНТЫ UI: EVENT CLAIM
-- ===================================================
MainTab:Section({ Title = "Farm Controls" })

MainTab:Dropdown({
    Title = "Метод Фарма",
    Values = { "Instant TP", "Tween TP", "Bring Spawns", "Limb Teleport" },
    Value = farmMethod,
    Callback = function(selectedValue) farmMethod = selectedValue end,
})

MainTab:Space()

MainTab:Toggle({
    Title = "Auto Claim Events",
    Value = false,
    Callback = function(state)
        autoFarmActive = state
        if autoFarmActive then startAutoFarm() end
    end,
})

MainTab:Space()

MainTab:Slider({
    Title = "Задержка (сек)",
    Step = 0.1,
    Value = { Min = 0.05, Max = 3, Default = 0.5 },
    Callback = function(value) farmDelay = value end,
})

MainTab:Space()

MainTab:Slider({
    Title = "Скорость Tween (сек)",
    Step = 0.1,
    Value = { Min = 0.1, Max = 5, Default = 1.5 },
    Callback = function(value) tweenSpeed = value end,
})

MainTab:Section({ Title = "Always-On Avoid Bot" })

MainTab:Toggle({
    Title = "Enable Always Avoid Bot",
    Desc = "Автоматически уклоняться от моделек игроков",
    Value = false,
    Callback = function(state) avoidBotActive = state end,
})

MainTab:Space()

MainTab:Dropdown({
    Title = "Метод Уклонения",
    Values = { "Tween", "CFrame" },
    Value = avoidMethod,
    Callback = function(val) avoidMethod = val end,
})

MainTab:Space()

MainTab:Slider({
    Title = "Радиус Детекта (Studs)",
    Step = 1,
    Value = { Min = 5, Max = 50, Default = 15 },
    Callback = function(value) avoidRadius = value end,
})

MainTab:Space()

MainTab:Slider({
    Title = "Дистанция Отскока (Studs)",
    Step = 5,
    Value = { Min = 10, Max = 100, Default = 25 },
    Callback = function(value) avoidDistance = value end,
})

MainTab:Section({ Title = "Ping Stabilization Settings" })

MainTab:Toggle({
    Title = "Enable Ping Stabilization",
    Value = false,
    Callback = function(state) pingStabilizerActive = state end,
})

MainTab:Space()

MainTab:Slider({
    Title = "Max Allowed Ping (ms)",
    Step = 10,
    Value = { Min = 80, Max = 500, Default = 150 },
    Callback = function(value) maxAllowedPing = value end,
})

-- ===================================================
-- ЭЛЕМЕНТЫ UI: НАСТРОЙКИ, ТЕМЫ И КОНФИГИ
-- ===================================================

-- Быстрый пресет
SettingsTab:Section({ Title = "Quick Settings / Presets" })

SettingsTab:Button({
    Title = "Быстрый Фарм (Legit Presets)",
    Desc = "Метод Tween, безопасная задержка 1.2s",
    Callback = function()
        farmMethod = "Tween TP"
        farmDelay = 1.2
        tweenSpeed = 2.0
        avoidBotActive = true
        pingStabilizerActive = true
        WindUI:Notify({ Title = "Inlawry Hub", Content = "Применен легитный пресет!" })
    end,
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "Максимальная Скорость (Rage Presets)",
    Desc = "Метод Instant TP, задержка 0.05s",
    Callback = function()
        farmMethod = "Instant TP"
        farmDelay = 0.05
        avoidBotActive = false
        pingStabilizerActive = false
        WindUI:Notify({ Title = "Inlawry Hub", Content = "Применен Rage пресет!" })
    end,
})

-- Выбор темы с авто-перезагрузкой
SettingsTab:Section({ Title = "Color Themes (Auto-Reload)" })

SettingsTab:Dropdown({
    Title = "Выберите ТЕМУ",
    Desc = "Окно автоматически перезагрузится после выбора",
    Values = { "Dark", "Light", "Rose", "Aqua", "Emerald", "Midnight" },
    Value = selectedTheme,
    Callback = function(themeName)
        if themeName ~= selectedTheme then
            reloadUIWithTheme(themeName)
        end
    end,
})

-- Менеджер Конфигов
if not RunService:IsStudio() and writefile then
    SettingsTab:Section({ Title = "Config Manager" })

    local ConfigManager = Window.ConfigManager
    local currentConfigName = "default"

    local ConfigNameInput = SettingsTab:Input({
        Title = "Config Name",
        Placeholder = "Введите имя конфига...",
        Value = "default",
        Callback = function(value)
            currentConfigName = value
        end,
    })

    SettingsTab:Space()

    local AllConfigsDropdown = SettingsTab:Dropdown({
        Title = "Список Конфигов",
        Values = ConfigManager:AllConfigs(),
        Value = "default",
        Callback = function(value)
            currentConfigName = value
            ConfigNameInput:Set(value)
        end,
    })

    SettingsTab:Space()

    SettingsTab:Button({
        Title = "Сохранить Конфиг",
        Justify = "Center",
        Callback = function()
            Window.CurrentConfig = ConfigManager:Config(currentConfigName)
            if Window.CurrentConfig:Save() then
                WindUI:Notify({
                    Title = "Config Saved",
                    Content = "Конфиг '" .. currentConfigName .. "' сохранен!",
                })
                AllConfigsDropdown:Refresh(ConfigManager:AllConfigs())
            end
        end,
    })

    SettingsTab:Space()

    SettingsTab:Button({
        Title = "Загрузить Конфиг",
        Justify = "Center",
        Callback = function()
            Window.CurrentConfig = ConfigManager:CreateConfig(currentConfigName)
            if Window.CurrentConfig:Load() then
                WindUI:Notify({
                    Title = "Config Loaded",
                    Content = "Конфиг '" .. currentConfigName .. "' успешно загружен!",
                })
            end
        end,
    })
end

-- Вкладка Credits
local AboutTab = Window:Tab({ Title = "Credits", Icon = "solar:info-square-bold" })
AboutTab:Section({ Title = "Inlawry Universal Project", TextSize = 20, FontWeight = Enum.FontWeight.SemiBold })
AboutTab:Space()
AboutTab:Section({ Title = "Created and maintained by inlawry.\nAll rights reserved.", TextSize = 14, TextTransparency = 0.4 })
