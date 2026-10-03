-- Футболисты: выбор типа, сбор через игровой ProximityPrompt, возврат в SafeZone.
local Players = game:GetService('Players')
local player = Players.LocalPlayer
local slimes = workspace:WaitForChild('Live'):WaitForChild('Slimes')
local safe = workspace:WaitForChild('Regions'):WaitForChild('SafeZone')
local env = getgenv()
if env.BasaltSoccerFarm then
    env.BasaltSoccerFarm.running = false
    env.BasaltSoccerFarm.autoSpeed = false
    if env.BasaltSoccerFarm.gui then env.BasaltSoccerFarm.gui:Destroy() end
end
local state = {running = false, autoSpeed = false, speedGeneration = 0, selected = 'Common Lucky Block', collapsed = false}
env.BasaltSoccerFarm = state
local gui = Instance.new('ScreenGui')
gui.Name = 'BasaltSoccerFarmGui'
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild('PlayerGui')
state.gui = gui

-- Главное окно
local frame = Instance.new('Frame')
frame.Size = UDim2.fromOffset(270, 144)
frame.Position = UDim2.new(0, 12, 0.5, -72)
frame.BackgroundColor3 = Color3.fromRGB(28, 31, 40)
frame.Parent = gui

-- Кнопка сворачивания/разворачивания (всегда видима)
local collapseButton = Instance.new('TextButton')
collapseButton.Name = 'Collapse'
collapseButton.Size = UDim2.fromOffset(26, 26)
collapseButton.Position = UDim2.new(0, 12, 0.5, -100) -- над окном
collapseButton.BackgroundColor3 = Color3.fromRGB(58, 65, 82)
collapseButton.TextColor3 = Color3.new(1, 1, 1)
collapseButton.TextScaled = true
collapseButton.Text = '—'
collapseButton.ZIndex = 5
collapseButton.Parent = gui

local function applyCollapse()
    if state.collapsed then
        frame.Visible = false
        collapseButton.Text = '+'
        collapseButton.BackgroundColor3 = Color3.fromRGB(40, 110, 60)
    else
        frame.Visible = true
        collapseButton.Text = '—'
        collapseButton.BackgroundColor3 = Color3.fromRGB(58, 65, 82)
    end
end
collapseButton.MouseButton1Click:Connect(function()
    state.collapsed = not state.collapsed
    applyCollapse()
end)
applyCollapse()

local function makeButton(name, text, size, pos)
    local b = Instance.new('TextButton')
    b.Name = name
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(58, 65, 82)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextScaled = true
    b.Text = text
    b.Parent = frame
    return b
end
local prev = makeButton('Previous', '<', UDim2.fromOffset(34, 39), UDim2.fromOffset(5, 5))
local label = makeButton('Type', '', UDim2.fromOffset(185, 39), UDim2.fromOffset(43, 5))
label.AutoButtonColor = false
local nextButton = makeButton('Next', '>', UDim2.fromOffset(34, 39), UDim2.fromOffset(231, 5))
local button = makeButton('Toggle', 'Фарм: СТАРТ', UDim2.fromOffset(260, 42), UDim2.fromOffset(5, 49))
local speedButton = makeButton('AutoSpeed', 'Авто Speed +1: ВЫКЛ', UDim2.fromOffset(260, 42), UDim2.fromOffset(5, 96))

local function types()
    local names, seen = {}, {}
    for _, model in ipairs(slimes:GetChildren()) do
        if model:FindFirstChild('StealPrompt', true) and not seen[model.Name] then
            seen[model.Name] = true
            table.insert(names, model.Name)
        end
    end
    table.sort(names)
    return names
end
local function showType()
    label.Text = state.selected
end
showType()
local function cycle(direction)
    local names = types()
    if #names == 0 then label.Text = 'Нет предметов'; return end
    local index = table.find(names, state.selected) or (direction > 0 and 0 or 1)
    state.selected = names[(index - 1 + direction) % #names + 1]
    showType()
end
prev.MouseButton1Click:Connect(function() cycle(-1) end)
nextButton.MouseButton1Click:Connect(function() cycle(1) end)

local function parseCashPrice(text)
    local raw = text:lower():gsub(',', ''):gsub('%s+', '')
    local number, suffix = raw:match('%$([%d%.]+)([kmb]?)')
    if not number then return nil end
    local multiplier = ({k = 1e3, m = 1e6, b = 1e9})[suffix] or 1
    local value = tonumber(number)
    return value and (value * multiplier + multiplier * 0.01) or nil
end
local function speedControls()
    local playerGui = player:FindFirstChild('PlayerGui')
    local screen = playerGui and playerGui:FindFirstChild('RunUpgrade')
    local main = screen and screen:FindFirstChild('Main')
    local container = main and main:FindFirstChild('Container')
    local row = container and container:FindFirstChild('1')
    local actions = row and row:FindFirstChild('Actions')
    local cashButton = actions and actions:FindFirstChild('Cash')
    local text = cashButton and cashButton:FindFirstChild('TextLabel')
    local summary = row and row:FindFirstChild('Summary')
    local details = summary and summary:FindFirstChild('Details')
    local values = details and details:FindFirstChild('ValueRow')
    local old = values and values:FindFirstChild('Old')
    return cashButton, text, old
end
speedButton.MouseButton1Click:Connect(function()
    state.autoSpeed = not state.autoSpeed
    state.speedGeneration += 1
    local generation = state.speedGeneration
    speedButton.Text = state.autoSpeed and 'Авто Speed +1: ВКЛ' or 'Авто Speed +1: ВЫКЛ'
    speedButton.BackgroundColor3 = state.autoSpeed and Color3.fromRGB(40, 110, 60) or Color3.fromRGB(58, 65, 82)
    if not state.autoSpeed then return end
    task.spawn(function()
        while state.autoSpeed and state.speedGeneration == generation and env.BasaltSoccerFarm == state do
            local cashValue = player:FindFirstChild('leaderstats')
            cashValue = cashValue and cashValue:FindFirstChild('Cash')
            local cashButton, text, level = speedControls()
            local price = text and parseCashPrice(text.Text)
            if cashValue and price and level and cashButton and cashValue.Value >= price then
                local beforeCash, beforeLevel = cashValue.Value, level.Text
                local ok, connections = pcall(getconnections, cashButton.MouseButton1Click)
                if ok and connections and connections[1] and connections[1].Enabled then
                    local sent, err = pcall(function() connections[1]:Fire() end)
                    if not sent then warn('[Speed] Ошибка кнопки Cash:', err); state.autoSpeed = false end
                    local elapsed = 0
                    repeat
                        task.wait(0.1)
                        elapsed += 0.1
                    until not state.autoSpeed or state.speedGeneration ~= generation or cashValue.Value ~= beforeCash or level.Text ~= beforeLevel or elapsed >= 2
                    if state.autoSpeed and state.speedGeneration == generation and cashValue.Value == beforeCash and level.Text == beforeLevel then
                        warn('[Speed] Покупка не подтверждена; автоулучшение остановлено.')
                        state.autoSpeed = false
                    end
                else
                    warn('[Speed] Обработчик Cash-кнопки недоступен.')
                    state.autoSpeed = false
                end
            else
                task.wait(0.1)
            end
        end
        if state.speedGeneration == generation and env.BasaltSoccerFarm == state then
            speedButton.Text = 'Авто Speed +1: ВЫКЛ'
            speedButton.BackgroundColor3 = Color3.fromRGB(58, 65, 82)
        end
    end)
end)
local function root()
    local c = player.Character
    local h = c and c:FindFirstChildOfClass('Humanoid')
    if h and h.Health > 0 then return c:FindFirstChild('HumanoidRootPart') end
end
local function moveNear(part)
    local r = root()
    if not r or not part or not part:IsA('BasePart') then return false end
    r.CFrame = part.CFrame * CFrame.new(0, 3, 5)
    task.wait(0.25)
    r = root()
    return state.running and r ~= nil and (r.Position - part.Position).Magnitude <= 10
end
local function goSafe()
    local r = root()
    if r then
        r.CFrame = safe.CFrame * CFrame.new(0, -safe.Size.Y / 2 + 5, 0)
    end
end
local function hold(prompt)
    if not state.running or not prompt or not prompt.Parent or not prompt.Enabled then return false end
    local ok, err = pcall(function()
        prompt:InputHoldBegin()
        task.wait(math.max(prompt.HoldDuration, 0) + 0.18)
        prompt:InputHoldEnd()
    end)
    if not ok then warn('[Фарм] Ошибка prompt:', err) end
    return ok
end
local function nearestSlime()
    local r = root()
    if not r then return end
    local best, distance
    for _, model in ipairs(slimes:GetChildren()) do
        if model.Name == state.selected then
            local part = model:FindFirstChild('RootPart')
            local prompt = part and part:FindFirstChild('StealPrompt')
            if prompt and prompt.Enabled then
                local d = (r.Position - part.Position).Magnitude
                if not distance or d < distance then best, distance = model, d end
            end
        end
    end
    return best
end
button.MouseButton1Click:Connect(function()
    state.running = not state.running
    button.Text = state.running and 'Фарм: СТОП' or 'Фарм: СТАРТ'
    button.BackgroundColor3 = state.running and Color3.fromRGB(160, 55, 55) or Color3.fromRGB(58, 65, 82)
    if not state.running then return end
    task.spawn(function()
        while state.running and env.BasaltSoccerFarm == state do
            local target = nearestSlime()
            if target then
                local part = target:FindFirstChild('RootPart')
                local prompt = part and part:FindFirstChild('StealPrompt')
                if prompt and moveNear(part) then
                    local attempted = hold(prompt)
                    if attempted then
                        task.wait(0.35)
                        if state.running then goSafe() end
                        task.wait(1)
                    end
                end
            end
            task.wait(0.6)
        end
    end)
end)
print('[Фарм] Тип — стрелки, СТАРТ/СТОП — сбор в SafeZone. Авто Speed +1 покупает только за Cash через игровую кнопку. Кнопка «—» сворачивает/разворачивает окно.')
