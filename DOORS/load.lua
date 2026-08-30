local MinecraftLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mamaksimaaa/Roblox-script/refs/heads/main/Lib/load.lua"))()

local Window = MinecraftLib:CreateWindow("IRY HUB", {
    Theme = "Overworld",
    Size = UDim2.fromOffset(570, 370),
    Transparency = 0.2,
    Blurring = true,
    MinimizeKeybind = Enum.KeyCode.K
})

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

plr.CharacterAdded:Connect(function(newChar) char = newChar end)

local flags = {
    doorESP = false,
    espkeys = false,
    espitems = false,
    espbooks = false,
    esprush = false,
    esplocker = false,
    espchest = false,
    espgold = false,
    esphumans = false,
    hintrush = false,
    getcode = false,
    draweraura = false,
    espfigure = false,
}

local goldespvalue = 0
local esptable = {
    doors = {},
    keys = {},
    items = {},
    books = {},
    entity = {},
    lockers = {},
    chests = {},
    gold = {},
    people = {},
    figure = {},
}

local entitynames = {
    "RushMoving", "AmbushMoving", "ScreechMoving", "HideMoving",
    "TimothyMoving", "DupeMoving", "FloorMoving", "FigureMoving",
}

local doorScanInterval = 3

local function esp(target, color, labelPart, labelText)
    local highlights = {}
    local billboards = {}

    local function highlightInst(inst)
        if not inst or not inst.Parent then return end
        if inst:FindFirstChild("_IRYESP_H") then return end
        local h = Instance.new("Highlight")
        h.Name = "_IRYESP_H"
        h.Adornee = inst
        h.FillColor = color
        h.OutlineColor = color
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.Parent = inst
        table.insert(highlights, h)
    end

    if typeof(target) == "table" then
        for _, part in pairs(target) do highlightInst(part) end
    else
        highlightInst(target)
    end

    if labelPart and labelPart.Parent then
        if not labelPart:FindFirstChild("_IRYESP_BB") then
            local bb = Instance.new("BillboardGui")
            bb.Name = "_IRYESP_BB"
            bb.Adornee = labelPart
            bb.Size = UDim2.fromScale(5, 2)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.fromScale(1, 1)
            lbl.BackgroundTransparency = 1
            lbl.TextScaled = true
            lbl.Text = labelText or ""
            lbl.TextColor3 = color
            lbl.Font = Enum.Font.GothamBold
            lbl.Parent = bb
            bb.Parent = labelPart
            table.insert(billboards, bb)
        end
    end

    local handle = {}
    function handle.delete()
        for _, h in pairs(highlights) do
            if h and h.Parent then h:Destroy() end
        end
        for _, bb in pairs(billboards) do
            if bb and bb.Parent then bb:Destroy() end
        end
    end
    return handle
end

local doorTransparencyBackup = {}
local doorTextRefs = {}

local function removeAllDoorESP()
    for door, t in pairs(doorTransparencyBackup) do
        if door and door.Parent then door.Transparency = t end
        local h = door:FindFirstChild("_IRYESP_H")
        if h then h:Destroy() end
        local bb = door:FindFirstChild("_IRYESP_BB")
        if bb then bb:Destroy() end
    end
    table.clear(doorTransparencyBackup)
    table.clear(doorTextRefs)
end

task.spawn(function()
    while true do
        if flags.doorESP then
            local rooms = Workspace:FindFirstChild("CurrentRooms")
            if rooms then
                for _, room in pairs(rooms:GetChildren()) do
                    local door = room:FindFirstChild("RoomExit")
                    if door then
                        if not doorTransparencyBackup[door] then
                            doorTransparencyBackup[door] = door.Transparency
                        end
                        door.Transparency = 0
                        if not door:FindFirstChild("_IRYESP_H") then
                            local h = Instance.new("Highlight")
                            h.Name = "_IRYESP_H"
                            h.Adornee = door
                            h.FillColor = Color3.fromRGB(0, 255, 0)
                            h.OutlineColor = Color3.fromRGB(0, 255, 0)
                            h.FillTransparency = 0.5
                            h.OutlineTransparency = 0
                            h.Parent = door
                        end
                        if not doorTextRefs[door] then
                            local roomNum = tonumber(room.Name)
                            if roomNum then
                                local bb = Instance.new("BillboardGui")
                                bb.Name = "_IRYESP_BB"
                                bb.Adornee = door
                                bb.Size = UDim2.fromScale(4, 2)
                                bb.StudsOffset = Vector3.new(0, 3, 0)
                                bb.AlwaysOnTop = true
                                local lbl = Instance.new("TextLabel")
                                lbl.Size = UDim2.fromScale(1, 1)
                                lbl.BackgroundTransparency = 1
                                lbl.TextScaled = true
                                lbl.Text = tostring(roomNum + 1)
                                lbl.TextColor3 = Color3.fromRGB(0, 255, 0)
                                lbl.Font = Enum.Font.GothamBold
                                lbl.Parent = bb
                                bb.Parent = door
                                doorTextRefs[door] = bb
                            end
                        end
                    end
                end
            end
        else
            removeAllDoorESP()
        end
        task.wait(doorScanInterval)
    end
end)

local ESPTab = Window:AddTab("ESP")

ESPTab:AddToggle("ESP Doors", false, function(v)
    flags.doorESP = v
    if not v then removeAllDoorESP() end
end)

ESPTab:AddToggle("ESP Keys/Levers", false, function(Value)
    flags.espkeys = Value
    if not Value then return end
    local function check(v)
        if v:IsA("Model") and (v.Name == "LeverForGate" or v.Name == "KeyObtain") then
            task.wait(0.1)
            if v.Name == "KeyObtain" then
                local hitbox = v:WaitForChild("Hitbox")
                local parts = hitbox:GetChildren()
                local promptHitbox = hitbox:FindFirstChild("PromptHitbox")
                if promptHitbox then
                    table.remove(parts, table.find(parts, promptHitbox))
                end
                local h = esp(parts, Color3.fromRGB(90, 255, 40), hitbox, "Key")
                table.insert(esptable.keys, h)
            elseif v.Name == "LeverForGate" then
                local h = esp(v, Color3.fromRGB(90, 255, 40), v.PrimaryPart, "Lever")
                table.insert(esptable.keys, h)
                v.PrimaryPart:WaitForChild("SoundToPlay").Played:Connect(function() h.delete() end)
            end
        end
    end
    local function setup(room)
        local assets = room:WaitForChild("Assets")
        assets.DescendantAdded:Connect(function(v)
            if flags.espkeys then check(v) end
        end)
        for _, v in pairs(assets:GetDescendants()) do check(v) end
    end
    local addconnect
    addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
        if flags.espkeys then setup(room) end
    end)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        if room:FindFirstChild("Assets") then setup(room) end
    end
    repeat task.wait() until not flags.espkeys
    addconnect:Disconnect()
    for _, v in pairs(esptable.keys) do v.delete() end
    table.clear(esptable.keys)
end)

ESPTab:AddToggle("ESP Items", false, function(Value)
    flags.espitems = Value
    if not Value then return end
    local function check(v)
        if v:IsA("Model") and (v:GetAttribute("Pickup") or v:GetAttribute("PropType")) then
            task.wait(0.1)
            local part = v:FindFirstChild("Handle") or v:FindFirstChild("Prop")
            if not part then return end
            local h = esp(part, Color3.fromRGB(160, 190, 255), part, v.Name)
            table.insert(esptable.items, h)
        end
    end
    local function setup(room)
        local assets = room:WaitForChild("Assets")
        if assets then
            local subaddcon
            subaddcon = assets.DescendantAdded:Connect(function(v)
                if flags.espitems then check(v) end
            end)
            for _, v in pairs(assets:GetDescendants()) do check(v) end
            task.spawn(function()
                repeat task.wait() until not flags.espitems
                subaddcon:Disconnect()
            end)
        end
    end
    local addconnect
    addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
        if flags.espitems then setup(room) end
    end)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        if room:FindFirstChild("Assets") then setup(room) end
    end
    repeat task.wait() until not flags.espitems
    addconnect:Disconnect()
    for _, v in pairs(esptable.items) do v.delete() end
    table.clear(esptable.items)
end)

ESPTab:AddToggle("ESP Breakers/Books", false, function(Value)
    flags.espbooks = Value
    if not Value then return end
    local function check(v, room)
        if v:IsA("Model") and (v.Name == "LiveHintBook" or v.Name == "LiveBreakerPolePickup") then
            task.wait(0.1)
            local label = (v.Name == "LiveHintBook") and "Book" or "Breaker"
            local h = esp(v, Color3.fromRGB(160, 190, 255), v.PrimaryPart, label)
            table.insert(esptable.books, h)
            v.AncestryChanged:Connect(function()
                if not v:IsDescendantOf(room) then h.delete() end
            end)
        end
    end
    local function setup(room)
        if room.Name == "50" or room.Name == "100" then
            room.DescendantAdded:Connect(function(v)
                if flags.espbooks then check(v, room) end
            end)
            for _, v in pairs(room:GetDescendants()) do check(v, room) end
        end
    end
    local addconnect
    addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
        if flags.espbooks then setup(room) end
    end)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do setup(room) end
    repeat task.wait() until not flags.espbooks
    addconnect:Disconnect()
    for _, v in pairs(esptable.books) do v.delete() end
    table.clear(esptable.books)
end)

ESPTab:AddToggle("ESP Entities (Rush, Ambush..)", false, function(Value)
    flags.esprush = Value
    if not Value then return end
    local addconnect
    addconnect = workspace.ChildAdded:Connect(function(v)
        if table.find(entitynames, v.Name) then
            task.wait(0.1)
            local h = esp(v, Color3.fromRGB(255, 25, 25), v.PrimaryPart, v.Name:gsub("Moving", ""))
            table.insert(esptable.entity, h)
        end
    end)
    local function setup(room)
        if room.Name == "50" or room.Name == "100" then
            local figuresetup = room:WaitForChild("FigureSetup")
            if figuresetup then
                local fig = figuresetup:WaitForChild("FigureRagdoll")
                task.wait(0.1)
                local h = esp(fig, Color3.fromRGB(255, 25, 25), fig.PrimaryPart, "Figure")
                table.insert(esptable.entity, h)
            end
        else
            local assets = room:WaitForChild("Assets")
            local function check(v)
                if v:IsA("Model") and table.find(entitynames, v.Name) then
                    task.wait(0.1)
                    local base = v:WaitForChild("Base")
                    local h = esp(base, Color3.fromRGB(255, 25, 25), base, "Snare")
                    table.insert(esptable.entity, h)
                end
            end
            assets.DescendantAdded:Connect(function(v)
                if flags.esprush then check(v) end
            end)
            for _, v in pairs(assets:GetDescendants()) do check(v) end
        end
    end
    local roomconnect
    roomconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
        if flags.esprush then setup(room) end
    end)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do setup(room) end
    repeat task.wait() until not flags.esprush
    addconnect:Disconnect()
    roomconnect:Disconnect()
    for _, v in pairs(esptable.entity) do v.delete() end
    table.clear(esptable.entity)
end)

ESPTab:AddToggle("ESP Figure (Figure)", false, function(Value)
    flags.espfigure = Value
    if not Value then
        for _, v in pairs(esptable.figure) do v.delete() end
        table.clear(esptable.figure)
        return
    end
    task.spawn(function()
        while flags.espfigure do
            local CurrentRooms = Workspace:FindFirstChild("CurrentRooms")
            if CurrentRooms then
                for _, room in pairs(CurrentRooms:GetChildren()) do
                    if room.Name == "50" or room.Name == "100" then
                        local FigureSetup = room:FindFirstChild("FigureSetup")
                        if FigureSetup then
                            local FigureRig = FigureSetup:FindFirstChild("FigureRig")
                            if FigureRig then
                                if not FigureRig:FindFirstChild("_IRYESP_H") then
                                    local h = esp(FigureRig, Color3.fromRGB(255, 25, 25), FigureRig, "Figure")
                                    table.insert(esptable.figure, h)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end)

ESPTab:AddToggle("ESP Closets/Lockers", false, function(Value)
    flags.esplocker = Value
    if not Value then return end
    local function check(v)
        if v:IsA("Model") then
            task.wait(0.1)
            if v.Name == "Wardrobe" then
                local h = esp(v.PrimaryPart, Color3.fromRGB(145, 100, 25), v.PrimaryPart, "Closet")
                table.insert(esptable.lockers, h)
            elseif v.Name == "Rooms_Locker" or v.Name == "Rooms_Locker_Fridge" then
                local h = esp(v.PrimaryPart, Color3.fromRGB(145, 100, 25), v.PrimaryPart, "Locker")
                table.insert(esptable.lockers, h)
            end
        end
    end
    local function setup(room)
        local assets = room:WaitForChild("Assets")
        if assets then
            local subaddcon
            subaddcon = assets.DescendantAdded:Connect(function(v)
                if flags.esplocker then check(v) end
            end)
            for _, v in pairs(assets:GetDescendants()) do check(v) end
            task.spawn(function()
                repeat task.wait() until not flags.esplocker
                subaddcon:Disconnect()
            end)
        end
    end
    local addconnect
    addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
        if flags.esplocker then setup(room) end
    end)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        if room:FindFirstChild("Assets") then setup(room) end
    end
    repeat task.wait() until not flags.esplocker
    addconnect:Disconnect()
    for _, v in pairs(esptable.lockers) do v.delete() end
    table.clear(esptable.lockers)
end)

ESPTab:AddToggle("ESP Chests", false, function(Value)
    flags.espchest = Value
    if not Value then return end
    local function check(v)
        if v:IsA("Model") then
            task.wait(0.1)
            if v.Name == "ChestBox" then
                local h = esp(v, Color3.fromRGB(205, 120, 255), v.PrimaryPart, "Chest")
                table.insert(esptable.chests, h)
            elseif v.Name == "ChestBoxLocked" then
                local h = esp(v, Color3.fromRGB(255, 120, 205), v.PrimaryPart, "Locked Chest")
                table.insert(esptable.chests, h)
            end
        end
    end
    local function setup(room)
        local subaddcon
        subaddcon = room.DescendantAdded:Connect(function(v)
            if flags.espchest then check(v) end
        end)
        for _, v in pairs(room:GetDescendants()) do check(v) end
        task.spawn(function()
            repeat task.wait() until not flags.espchest
            subaddcon:Disconnect()
        end)
    end
    local addconnect
    addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
        if flags.espchest then setup(room) end
    end)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        if room:FindFirstChild("Assets") then setup(room) end
    end
    repeat task.wait() until not flags.espchest
    addconnect:Disconnect()
    for _, v in pairs(esptable.chests) do v.delete() end
    table.clear(esptable.chests)
end)

ESPTab:AddToggle("ESP Goldpiles", false, function(Value)
    flags.espgold = Value
    if not Value then return end
    local function check(v)
        if v:IsA("Model") then
            task.wait(0.1)
            local goldvalue = v:GetAttribute("GoldValue")
            if goldvalue and goldvalue >= goldespvalue then
                local hitbox = v:WaitForChild("Hitbox")
                local h = esp(hitbox:GetChildren(), Color3.fromRGB(255, 255, 0), hitbox, "GoldPile [" .. tostring(goldvalue) .. "]")
                table.insert(esptable.gold, h)
            end
        end
    end
    local function setup(room)
        local assets = room:WaitForChild("Assets")
        local subaddcon
        subaddcon = assets.DescendantAdded:Connect(function(v)
            if flags.espgold then check(v) end
        end)
        for _, v in pairs(assets:GetDescendants()) do check(v) end
        task.spawn(function()
            repeat task.wait() until not flags.espgold
            subaddcon:Disconnect()
        end)
    end
    local addconnect
    addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
        if flags.espgold then setup(room) end
    end)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        if room:FindFirstChild("Assets") then setup(room) end
    end
    repeat task.wait() until not flags.espgold
    addconnect:Disconnect()
    for _, v in pairs(esptable.gold) do v.delete() end
    table.clear(esptable.gold)
end)

ESPTab:AddToggle("ESP Players", false, function(Value)
    flags.esphumans = Value
    if not Value then return end
    local function personesp(v)
        v.CharacterAdded:Connect(function(vc)
            local torso = vc:WaitForChild("UpperTorso")
            task.wait(0.1)
            local h = esp(vc, Color3.fromRGB(255, 255, 255), torso, v.DisplayName)
            table.insert(esptable.people, h)
        end)
        if v.Character then
            local vc = v.Character
            local torso = vc:WaitForChild("UpperTorso")
            task.wait(0.1)
            local h = esp(vc, Color3.fromRGB(255, 255, 255), torso, v.DisplayName)
            table.insert(esptable.people, h)
        end
    end
    local addconnect
    addconnect = game.Players.PlayerAdded:Connect(function(v)
        if v ~= plr then personesp(v) end
    end)
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= plr then personesp(v) end
    end
    repeat task.wait() until not flags.esphumans
    addconnect:Disconnect()
    for _, v in pairs(esptable.people) do v.delete() end
    table.clear(esptable.people)
end)

local MiscTab = Window:AddTab("Misc")

local currentSpeed = 16
MiscTab:AddSlider("Movement Speed", 1, 21.5, 16, function(value)
    currentSpeed = value
end)

task.spawn(function()
    while true do
        if plr.Character then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.WalkSpeed ~= currentSpeed then
                humanoid.WalkSpeed = currentSpeed
            end
        end
        task.wait(0.1)
    end
end)

MiscTab:AddToggle("Auto Loot", false, function(Value)
    flags.draweraura = Value
    if not Value then return end
    local function check(v)
        if not v:IsA("Model") then return end
        local function tryLoot(prompt, posFunc)
            if prompt:GetAttribute("Interactions") then return end
            task.spawn(function()
                repeat
                    task.wait(0.1)
                    if plr:DistanceFromCharacter(posFunc()) <= 12 then
                        fireproximityprompt(prompt)
                    end
                until prompt:GetAttribute("Interactions") or not flags.draweraura
            end)
        end
        if v.Name == "DrawerContainer" then
            local knob = v:FindFirstChild("Knobs")
            if knob then
                local prompt = knob:FindFirstChild("ActivateEventPrompt")
                if prompt then
                    tryLoot(prompt, function() return knob.Position end)
                end
            end
        elseif v.Name == "GoldPile" then
            local prompt = v:FindFirstChild("LootPrompt")
            if prompt and v.PrimaryPart then
                tryLoot(prompt, function() return v.PrimaryPart.Position end)
            end
        elseif v.Name:sub(1, 8) == "ChestBox" then
            local prompt = v:FindFirstChild("ActivateEventPrompt")
            if prompt and v.PrimaryPart then
                tryLoot(prompt, function() return v.PrimaryPart.Position end)
            end
        elseif v.Name == "RolltopContainer" then
            local prompt = v:FindFirstChild("ActivateEventPrompt")
            if prompt and v.PrimaryPart then
                tryLoot(prompt, function() return v.PrimaryPart.Position end)
            end
        end
    end
    local function setup(room)
        local subaddcon
        subaddcon = room.DescendantAdded:Connect(function(v)
            if flags.draweraura then check(v) end
        end)
        for _, v in pairs(room:GetDescendants()) do check(v) end
        task.spawn(function()
            repeat task.wait() until not flags.draweraura
            subaddcon:Disconnect()
        end)
    end
    local addconnect
    addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
        if flags.draweraura then setup(room) end
    end)
    for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
        if room:FindFirstChild("Assets") then setup(room) end
    end
    repeat task.wait() until not flags.draweraura
    addconnect:Disconnect()
end)

MiscTab:AddToggle("Notify Entities", false, function(Value)
    flags.hintrush = Value
    if not Value then return end
    local addconnect
    addconnect = workspace.ChildAdded:Connect(function(v)
        if table.find(entitynames, v.Name) then
            repeat
                task.wait()
            until plr:DistanceFromCharacter(v:GetPivot().Position) < 1000 or not v:IsDescendantOf(workspace)
            if v:IsDescendantOf(workspace) then
                Window:Notify("Entity Warning", v.Name:gsub("Moving", ""):lower() .. " is coming, go hide!", 5)
            end
        end
    end)
    repeat task.wait() until not flags.hintrush
    addconnect:Disconnect()
end)

MiscTab:AddToggle("Auto Library Code", false, function(Value)
    flags.getcode = Value
    if not Value then return end
    local function deciphercode()
        local paper = char:FindFirstChild("LibraryHintPaper")
        local hints = plr.PlayerGui:WaitForChild("PermUI"):WaitForChild("Hints")
        local code = {[1]="_",[2]="_",[3]="_",[4]="_",[5]="_"}
        if paper then
            for _, v in pairs(paper:WaitForChild("UI"):GetChildren()) do
                if v:IsA("ImageLabel") and v.Name ~= "Image" then
                    for _, img in pairs(hints:GetChildren()) do
                        if img:IsA("ImageLabel") and img.Visible and v.ImageRectOffset == img.ImageRectOffset then
                            local num = img:FindFirstChild("TextLabel").Text
                            code[tonumber(v.Name)] = num
                        end
                    end
                end
            end
        end
        return code
    end
    local addconnect
    addconnect = char.ChildAdded:Connect(function(v)
        if v:IsA("Tool") and v.Name == "LibraryHintPaper" then
            task.wait()
            local code = table.concat(deciphercode())
            if code:find("_") then
                Window:Notify("Library Code", "Get all hints first!", 5)
            else
                Window:Notify("Library Code", "The code is: " .. code, 10)
            end
        end
    end)
    repeat task.wait() until not flags.getcode
    addconnect:Disconnect()
end)

local ConfigTab = Window:AddTab("Config")

ConfigTab:AddSlider("Door Scan Interval", 1, 15, 3, function(value)
    doorScanInterval = value
end)

ConfigTab:AddSlider("Min Gold Value (Goldpile ESP)", 0, 500, 0, function(value)
    goldespvalue = value
end)

local InfoTab = Window:AddTab("Info")

InfoTab:AddLabel("IRY HUB")
InfoTab:AddLabel("Hi.. I hope you're enjoying this Script I made.")
InfoTab:AddLabel("Join my Discord for updates: discord.gg/uG5wXsFHjk")
InfoTab:AddLabel("Give my GitHub Repo a star or contribute:")
InfoTab:AddLabel("https://github.com/nucax/IRY-HUB")
InfoTab:AddLabel("")
InfoTab:AddLabel("Last Updated: 24th July 2026")
InfoTab:AddLabel("")
InfoTab:AddLabel("I am aware about the two buttons; ESP Entites and ESP Figure.")
InfoTab:AddLabel("I will merge the two functions when i have time to do so.")
InfoTab:AddLabel("")
InfoTab:AddLabel("To Do List:")
InfoTab:AddLabel("Toolshed ESP: add highlight to Toolshed_Small in Room 89 ?")
InfoTab:AddLabel("Snare ESP: add highlight to each snare")

Window:Notify("IRY HUB", "Loaded! Press K to toggle.", 5)
print("[IRY HUB] Script loaded")
