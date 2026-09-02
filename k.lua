local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════
--  ЗАГРУЗКА FIREBASE URL ИЗ ВНЕШНЕГО ФАЙЛА
-- ══════════════════════════════════════════
local FIREBASE_URL = nil

-- Функция загрузки конфига
local function loadConfig()
    local ok, result = pcall(function()
        local code = game:HttpGet("https://raw.githubusercontent.com/Mamaksimaaa/Roblox-script/refs/heads/main/h.txt")
        local cfg = loadstring(code)()
        if type(cfg) == "table" then
            return cfg.FIREBASE_URL or cfg.Url or cfg.url
        elseif type(cfg) == "string" then
            return cfg
        else
            return nil
        end
    end)
    if ok and result then
        return result
    else
        return nil
    end
end

-- Пытаемся загрузить URL
FIREBASE_URL = loadConfig()

-- Если не удалось, прекращаем выполнение
if not FIREBASE_URL then
    warn("Ошибка: не удалось загрузить Firebase URL из h.txt")
    return -- останавливаем скрипт
end

print("URL загружен:", FIREBASE_URL)

-- ══════════════════════════════════════════
--  ФУНКЦИЯ ПРОВЕРКИ КЛЮЧА
-- ══════════════════════════════════════════
local function checkKey(inputKey)
    -- Очистка и приведение к верхнему регистру
    inputKey = inputKey:upper():match("^%s*(.-)%s*$")

    if #inputKey < 4 then
        return false, "Слишком короткий ключ"
    end

    -- Кодируем ключ для безопасного URL
    local encodedKey = HttpService:UrlEncode(inputKey)

    -- Формируем полный URL
    local baseUrl = FIREBASE_URL:gsub("/$", "")
    local url = baseUrl .. "/keys/" .. encodedKey .. ".json"

    -- Выполняем GET-запрос (используем game:HttpGet, если доступен)
    local ok, res = pcall(function()
        if game.HttpGet then
            return game:HttpGet(url)
        else
            return HttpService:GetAsync(url)
        end
    end)

    if not ok then
        return false, "Ошибка подключения к серверу"
    end

    -- Firebase возвращает "null", если ключа нет
    if res == nil or res == "null" then
        return false, "Неверный ключ"
    end

    return true
end

-- ══════════════════════════════════════════
--  ИНТЕРФЕЙС В СТИЛЕ MINECRAFT
-- ══════════════════════════════════════════
local function buildKeySystem(onSuccess)
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeySystem"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Затемнение фона
    local dim = Instance.new("Frame", gui)
    dim.Size = UDim2.fromScale(1, 1)
    dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dim.BackgroundTransparency = 0.4
    dim.BorderSizePixel = 0
    dim.ZIndex = 1

    -- Основное окно
    local win = Instance.new("Frame", gui)
    win.Size = UDim2.new(0, 440, 0, 300)
    win.Position = UDim2.fromScale(0.5, 0.5)
    win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
    win.BorderColor3 = Color3.fromRGB(157, 157, 157)
    win.BorderSizePixel = 3
    win.ZIndex = 2

    -- Верхняя панель
    local bar = Instance.new("Frame", win)
    bar.Size = UDim2.new(1, 0, 0, 34)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bar.BorderColor3 = Color3.fromRGB(20, 20, 20)
    bar.BorderSizePixel = 2
    bar.ZIndex = 3

    local barTitle = Instance.new("TextLabel", bar)
    barTitle.Size = UDim2.fromScale(1, 1)
    barTitle.BackgroundTransparency = 1
    barTitle.Text = "⚔  KEY SYSTEM"
    barTitle.TextColor3 = Color3.new(1, 1, 1)
    barTitle.Font = Enum.Font.Code
    barTitle.TextSize = 20
    barTitle.TextStrokeTransparency = 0
    barTitle.ZIndex = 4

    -- Подпись
    local sub = Instance.new("TextLabel", win)
    sub.Size = UDim2.new(1, -40, 0, 22)
    sub.Position = UDim2.new(0, 20, 0, 42)
    sub.BackgroundTransparency = 1
    sub.Text = "Введите лицензионный ключ"
    sub.TextColor3 = Color3.fromRGB(170, 170, 170)
    sub.Font = Enum.Font.Code
    sub.TextSize = 16
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.ZIndex = 3

    -- Поле ввода
    local inputBG = Instance.new("Frame", win)
    inputBG.Size = UDim2.new(1, -40, 0, 44)
    inputBG.Position = UDim2.new(0, 20, 0, 68)
    inputBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    inputBG.BorderColor3 = Color3.fromRGB(20, 20, 20)
    inputBG.BorderSizePixel = 2
    inputBG.ZIndex = 3

    local inputBox = Instance.new("TextBox", inputBG)
    inputBox.Size = UDim2.fromScale(1, 1)
    inputBox.BackgroundTransparency = 1
    inputBox.PlaceholderText = "KEY-XXXXXXXX"
    inputBox.PlaceholderColor3 = Color3.fromRGB(60, 60, 60)
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.fromRGB(255, 215, 0)
    inputBox.Font = Enum.Font.Code
    inputBox.TextSize = 20
    inputBox.ClearTextOnFocus = false
    inputBox.ZIndex = 4

    -- Автопреобразование в верхний регистр
    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
        local upper = inputBox.Text:upper()
        if inputBox.Text ~= upper then
            inputBox.Text = upper
        end
    end)

    -- XP-бар (прогресс)
    local xpBG = Instance.new("Frame", win)
    xpBG.Size = UDim2.new(1, -40, 0, 10)
    xpBG.Position = UDim2.new(0, 20, 0, 118)
    xpBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    xpBG.BorderColor3 = Color3.fromRGB(20, 20, 20)
    xpBG.BorderSizePixel = 2
    xpBG.ZIndex = 3

    local xpFill = Instance.new("Frame", xpBG)
    xpFill.Size = UDim2.new(0, 0, 1, 0)
    xpFill.BackgroundColor3 = Color3.fromRGB(124, 252, 0)
    xpFill.BorderSizePixel = 0
    xpFill.ZIndex = 4

    -- Заполнение XP-бара при вводе
    local KEY_LENGTH = 12 -- длина стандартного ключа "KEY-XXXXXXXX"
    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
        local len = #inputBox.Text
        TweenService:Create(xpFill, TweenInfo.new(0.15), {
            Size = UDim2.new(math.min(1, len / KEY_LENGTH), 0, 1, 0)
        }):Play()
    end)

    -- Кнопка активации
    local btn = Instance.new("TextButton", win)
    btn.Size = UDim2.new(1, -40, 0, 46)
    btn.Position = UDim2.new(0, 20, 0, 136)
    btn.BackgroundColor3 = Color3.fromRGB(90, 124, 30)
    btn.BorderColor3 = Color3.fromRGB(141, 181, 46)
    btn.BorderSizePixel = 3
    btn.Text = "▶  ACTIVATE KEY"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Code
    btn.TextSize = 22
    btn.TextStrokeTransparency = 0
    btn.ZIndex = 3
    btn.AutoButtonColor = false

    -- Статусная строка
    local statusBG = Instance.new("Frame", win)
    statusBG.Size = UDim2.new(1, -40, 0, 36)
    statusBG.Position = UDim2.new(0, 20, 0, 190)
    statusBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    statusBG.BorderColor3 = Color3.fromRGB(20, 20, 20)
    statusBG.BorderSizePixel = 2
    statusBG.ZIndex = 3

    local statusDot = Instance.new("Frame", statusBG)
    statusDot.Size = UDim2.new(0, 10, 0, 10)
    statusDot.Position = UDim2.new(0, 10, 0.5, -5)
    statusDot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    statusDot.BorderColor3 = Color3.fromRGB(0, 0, 0)
    statusDot.BorderSizePixel = 2
    statusDot.ZIndex = 4

    local statusLbl = Instance.new("TextLabel", statusBG)
    statusLbl.Size = UDim2.new(1, -30, 1, 0)
    statusLbl.Position = UDim2.new(0, 26, 0, 0)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Ожидание ключа..."
    statusLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
    statusLbl.Font = Enum.Font.Code
    statusLbl.TextSize = 16
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.ZIndex = 4

    -- Нижние иконки (декоративные)
    local hotbarItems = {"🗝️","🌐","📋","💬","❌"}
    for i, icon in ipairs(hotbarItems) do
        local slot = Instance.new("TextButton", win)
        slot.Size = UDim2.new(0, 44, 0, 44)
        slot.Position = UDim2.new(0, 20 + (i-1)*48, 0, 238)
        slot.BackgroundColor3 = i==1 and Color3.fromRGB(100,100,100) or Color3.fromRGB(139,139,139)
        slot.BorderColor3 = i==1 and Color3.fromRGB(20,20,20) or Color3.fromRGB(200,200,200)
        slot.BorderSizePixel = 2
        slot.Text = icon
        slot.TextSize = 24
        slot.Font = Enum.Font.Code
        slot.AutoButtonColor = false
        slot.ZIndex = 3
    end

    -- Функция установки статуса
    local function setStatus(state, msg)
        local colors = {
            idle = Color3.fromRGB(100,100,100),
            wait = Color3.fromRGB(255,215,0),
            ok   = Color3.fromRGB(90,200,60),
            bad  = Color3.fromRGB(180,40,40),
        }
        statusDot.BackgroundColor3 = colors[state]
        statusLbl.Text = msg
        statusLbl.TextColor3 = colors[state]
    end

    -- Обработчик нажатия кнопки
    btn.MouseButton1Click:Connect(function()
        if not btn.Active then return end
        btn.Active = false

        local key = inputBox.Text:match("^%s*(.-)%s*$")
        if #key < 4 then
            setStatus("bad", "✘  Введите ключ!")
            btn.Active = true
            return
        end

        -- Имитация процесса проверки
        local msgs = {
            {0.25, "Подключение к серверу..."},
            {0.55, "Проверка ключа..."},
            {0.85, "Почти готово..."},
        }
        for _, s in ipairs(msgs) do
            TweenService:Create(xpFill, TweenInfo.new(0.25), {
                Size = UDim2.new(s[1], 0, 1, 0)
            }):Play()
            setStatus("wait", s[2])
            task.wait(0.35)
        end

        -- Реальная проверка
        local ok, err = checkKey(key)

        if ok then
            TweenService:Create(xpFill, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 1, 0)
            }):Play()
            xpFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
            setStatus("ok", "✔  Ключ принят! Загрузка...")
            btn.Text = "✔  АКТИВИРОВАНО"
            btn.BackgroundColor3 = Color3.fromRGB(30, 80, 160)
            task.wait(1.2)
            gui:Destroy()
            if onSuccess then onSuccess() end
        else
            TweenService:Create(xpFill, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 0, 1, 0)
            }):Play()
            xpFill.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            setStatus("bad", "✘  " .. tostring(err))
            task.wait(0.5)
            xpFill.BackgroundColor3 = Color3.fromRGB(124, 252, 0)
            btn.Active = true
        end
    end)

    setStatus("idle", "Ожидание ключа...")
end

-- ══════════════════════════════════════════
--  ЗАПУСК СИСТЕМЫ
-- ══════════════════════════════════════════
local success, err = pcall(function()
    buildKeySystem(function()
        print("Ключ принят, запускаем основной скрипт!")
        -- Здесь можно загрузить ваш основной скрипт:
        -- loadstring(game:HttpGet("URL_ВАШЕГО_СКРИПТА"))()
    end)
end)

if not success then
    warn("Ошибка при создании меню:", err)
end
