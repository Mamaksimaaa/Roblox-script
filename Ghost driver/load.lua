--alpha version
--[[
    IRY HUB - Ghost Driver (AutoFarm / Traffic Magic)
    Адаптировано под MinecraftLib
    Создатель: @hodbush
    Discord: https://discord.gg/YvZaukBdu
]]

-- Загрузка библиотеки
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mamaksimaaa/Roblox-script/refs/heads/main/Lib/load.lua"))()

-- Создание окна
local Window = Library:CreateWindow("IRY HUB", {
    Theme = "Overworld" -- Overworld / Nether / End
})

-- ==================== СЕРВИСЫ ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ==================== ПЕРЕМЕННЫЕ СОСТОЯНИЯ ====================
local trafficMagicEnabled = false
local autoFarmEnabled = false
local antiAfkEnabled = false
local rendering3DEnabled = true

local forwardSpeed = 470
local targetRange = 500
local afkDelay = 20
local pauseInterval = 120
local pauseDuration = 10

-- Служебные переменные для автофермы
local currentVehicle = nil       -- модель машины
local vehiclePrimaryPart = nil   -- PrimaryPart машины
local flyAttachment = nil
local flyAngularVelocity = nil
local flyLinearVelocity = nil
local lastPauseTime = 0
local tempIgnoredVehicles = {}   -- временно игнорируемые машины

-- Соединения для очистки
local connections = {}
local cleanupFunctions = {}

-- ==================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ====================
local function findTrafficFolder()
    return Workspace:FindFirstChild("TrafficFolder")
end

local function findCoreHitbox(vehicle)
    if not vehicle then return nil end
    return vehicle:FindFirstChild("CoreHitbox") or vehicle:FindFirstChild("coreHitbox") or vehicle.PrimaryPart
end

local function clearFlyConstraints()
    if flyAttachment then
        flyAttachment:Destroy()
        flyAttachment = nil
    end
    if flyAngularVelocity then
        flyAngularVelocity:Destroy()
        flyAngularVelocity = nil
    end
    if flyLinearVelocity then
        flyLinearVelocity:Destroy()
        flyLinearVelocity = nil
    end
end

local function setupFlyConstraints(part)
    clearFlyConstraints()
    if not part then return end
    flyAttachment = Instance.new("Attachment")
    flyAttachment.Name = "AutoTurnAttachment"
    flyAttachment.Parent = part

    flyAngularVelocity = Instance.new("AngularVelocity")
    flyAngularVelocity.Name = "AutoTurnConstraint"
    flyAngularVelocity.Attachment0 = flyAttachment
    flyAngularVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyAngularVelocity.MaxTorque = math.huge
    flyAngularVelocity.AngularVelocity = Vector3.zero
    flyAngularVelocity.Parent = part

    flyLinearVelocity = Instance.new("LinearVelocity")
    flyLinearVelocity.Name = "AutoFlyVelocity"
    flyLinearVelocity.Attachment0 = flyAttachment
    flyLinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyLinearVelocity.MaxForce = math.huge
    flyLinearVelocity.VectorVelocity = Vector3.zero
    flyLinearVelocity.Parent = part
end

local function getCurrentVehicle()
    local character = LocalPlayer.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") then
        return humanoid.SeatPart.Parent
    end
    return nil
end

local function getVehiclePrimaryPart(vehicle)
    if not vehicle then return nil end
    return vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
end

local function getClosestTraffic(ignoreList, fromPosition)
    local trafficFolder = findTrafficFolder()
    if not trafficFolder then return nil end

    local closestVehicle = nil
    local closestHitbox = nil
    local closestDistance = math.huge

    for _, child in ipairs(trafficFolder:GetChildren()) do
        if not ignoreList[child] then
            local hitbox = findCoreHitbox(child)
            if hitbox then
                local direction = hitbox.Position - fromPosition
                if fromPosition and direction.Unit:Dot(fromPosition.LookVector) > 0 then
                    local distance = direction.Magnitude
                    if distance < closestDistance and distance <= targetRange then
                        closestVehicle = child
                        closestHitbox = hitbox
                        closestDistance = distance
                    end
                end
            end
        end
    end

    return closestVehicle, closestHitbox
end

-- ==================== ЛОГИКА АВТОФЕРМЫ ====================
local function autoFarmLoop()
    while autoFarmEnabled do
        task.wait()
        local vehicle = getCurrentVehicle()
        if vehicle then
            local primaryPart = getVehiclePrimaryPart(vehicle)
            if primaryPart then
                -- Разблокируем и отключаем коллизии
                primaryPart.Anchored = false
                for _, part in ipairs(vehicle:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end

                -- Создаём ограничители, если ещё не созданы или сменилась машина
                if not flyAttachment or flyAttachment.Parent ~= primaryPart then
                    setupFlyConstraints(primaryPart)
                end

                -- Проверка паузы
                if tick() - lastPauseTime >= pauseInterval then
                    -- Остановка
                    flyAngularVelocity.AngularVelocity = Vector3.zero
                    flyLinearVelocity.VectorVelocity = Vector3.zero
                    primaryPart.AssemblyLinearVelocity = Vector3.zero
                    primaryPart.AssemblyAngularVelocity = Vector3.zero

                    local pauseStart = tick()
                    while autoFarmEnabled and (tick() - pauseStart) < pauseDuration do
                        flyLinearVelocity.VectorVelocity = Vector3.zero
                        primaryPart.AssemblyLinearVelocity = Vector3.zero
                        primaryPart.AssemblyAngularVelocity = Vector3.zero
                        task.wait()
                    end
                    lastPauseTime = tick()
                    tempIgnoredVehicles = {}
                else
                    -- Поиск ближайшего трафика
                    local closestVehicle, closestHitbox = getClosestTraffic(tempIgnoredVehicles, primaryPart)
                    if not closestVehicle or not closestHitbox then
                        tempIgnoredVehicles = {}
                        flyAngularVelocity.AngularVelocity = Vector3.zero
                        flyLinearVelocity.VectorVelocity = Vector3.new(0, (primaryPart.Position.Y - primaryPart.Position.Y) * 5, 0)
                    else
                        local toTarget = closestHitbox.Position - primaryPart.Position
                        local flatDirection = Vector3.new(toTarget.X, 0, toTarget.Z)
                        local moveDirection = flatDirection.Magnitude > 0 and flatDirection.Unit or primaryPart.CFrame.LookVector

                        primaryPart.CFrame = CFrame.new(primaryPart.Position, primaryPart.Position + moveDirection)
                        flyLinearVelocity.VectorVelocity = moveDirection * forwardSpeed + Vector3.new(0, (closestHitbox.Position.Y - primaryPart.Position.Y) * 5, 0)

                        if (closestHitbox.Position - primaryPart.Position).Magnitude < 25 then
                            tempIgnoredVehicles[closestVehicle] = true
                        end
                    end
                end
            end
        else
            clearFlyConstraints()
        end
    end
    clearFlyConstraints()
end

-- ==================== ЛОГИКА ANTI AFK ====================
local function antiAfkLoop()
    local lastClick = tick()
    while antiAfkEnabled do
        task.wait(1)
        if antiAfkEnabled and (tick() - lastClick >= afkDelay) then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            lastClick = tick()
        end
    end
end

-- ==================== TRAFFIC MAGIC ====================
local function setupTrafficMagic()
    local folder = findTrafficFolder()
    if folder then
        folder.ChildAdded:Connect(function(child)
            if trafficMagicEnabled then
                local hitbox = findCoreHitbox(child)
                if hitbox then
                    hitbox.Size = Vector3.new(0.05, 0.05, 0.05)
                end
            end
        end)
    end
end

-- ==================== 3D RENDERING ====================
local function set3DRendering(enabled)
    pcall(function()
        RunService:Set3dRenderingEnabled(enabled)
    end)
end

-- ==================== ВКЛАДКИ ====================
local MainTab = Window:AddTab("Main")
local AutoFarmTab = Window:AddTab("Auto Farm")
local MiscTab = Window:AddTab("Misc")

-- ==================== MAIN TAB ====================
MainTab:AddLabel("IRY HUB - Ghost driver")
MainTab:AddSeparator("Информация")
MainTab:AddLabel("Создатель: @hodbush")
MainTab:AddLabel("Discord: IRY HUB (discord.gg/YvZaukBdu)")
MainTab:AddButton("Копировать Discord ссылку", function()
    local link = "https://discord.gg/YvZaukBdu"
    pcall(setclipboard, link)
    Window:Notify("Discord", "Ссылка скопирована: " .. link, 3)
end)

-- ==================== AUTO FARM TAB ====================
AutoFarmTab:AddLabel("Автоферма и магия трафика")
AutoFarmTab:AddSeparator("Основные")

AutoFarmTab:AddToggle("Traffic Magic", false, function(state)
    trafficMagicEnabled = state
    if state then
        setupTrafficMagic()
    end
end)

AutoFarmTab:AddToggle("AutoFarm Driving", false, function(state)
    autoFarmEnabled = state
    if state then
        lastPauseTime = tick()
        tempIgnoredVehicles = {}
        task.spawn(autoFarmLoop)
    else
        clearFlyConstraints()
    end
end)

AutoFarmTab:AddSeparator("Параметры")

AutoFarmTab:AddSlider("Forward Speed", 100, 470, 470, function(val)
    forwardSpeed = val
end)

AutoFarmTab:AddSlider("Target Range", 50, 2000, 500, function(val)
    targetRange = val
end)

AutoFarmTab:AddSlider("AFK Delay (s)", 20, 1200, 20, function(val)
    afkDelay = val
end)

AutoFarmTab:AddSlider("Pause Interval (s)", 10, 600, 120, function(val)
    pauseInterval = val
end)

AutoFarmTab:AddSlider("Pause Duration (s)", 5, 60, 10, function(val)
    pauseDuration = val
end)

-- ==================== MISC TAB ====================
MiscTab:AddLabel("Прочие функции")
MiscTab:AddSeparator("Утилиты")

MiscTab:AddToggle("Anti AFK", false, function(state)
    antiAfkEnabled = state
    if state then
        task.spawn(antiAfkLoop)
    end
end)

MiscTab:AddToggle("3D Rendering", true, function(state)
    rendering3DEnabled = state
    set3DRendering(state)
end)

MiscTab:AddKeybind("Скрыть/Показать окно", Enum.KeyCode.Insert, function()
    Window:ToggleVisible()
end)

-- ==================== ОЧИСТКА (CLEANUP) ====================
local function cleanup()
    -- Остановка циклов и отключение соединений
    autoFarmEnabled = false
    antiAfkEnabled = false
    trafficMagicEnabled = false

    -- Восстановление 3D рендеринга
    set3DRendering(true)

    -- Удаление ограничителей
    clearFlyConstraints()

    -- Восстановление физики для текущего транспорта
    local vehicle = getCurrentVehicle()
    if vehicle then
        local primaryPart = getVehiclePrimaryPart(vehicle)
        if primaryPart then
            primaryPart.Anchored = false
            for _, part in ipairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end

    -- Отключение всех слушателей, созданных скриптом (если мы их где-то сохраняли)
    for _, conn in ipairs(connections) do
        if conn then
            pcall(conn.Disconnect, conn)
        end
    end
    connections = {}

    -- Закрытие окна (если метод существует)
    pcall(function()
        if Window.Destroy then
            Window:Destroy()
        elseif Window.Close then
            Window:Close()
        end
    end)
end

-- Сохраняем cleanup глобально для возможного вызова извне
getgenv().IRY_HUB_Cleanup = cleanup

-- ==================== ЗАПУСК ====================
set3DRendering(rendering3DEnabled) -- устанавливаем начальное значение
Window:Notify("IRY HUB", "Скрипт загружен! Используйте вкладки для настройки.", 5)
print("[IRY HUB] Скрипт успешно запущен.")
