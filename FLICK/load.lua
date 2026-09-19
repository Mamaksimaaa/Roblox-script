--!strict
-- LocalScript inside StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local MinecraftLib = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/Mamaksimaaa/Roblox-script/refs/heads/main/Lib/load.lua"
))()

local LOCAL_PLAYER = Players.LocalPlayer
local CAMERA = workspace.CurrentCamera

-- ============================================================
-- PLATFORM DETECTION
-- ============================================================

local IS_MOBILE = UserInputService.TouchEnabled
	and not UserInputService.MouseEnabled
	and not UserInputService.KeyboardEnabled

-- ============================================================
-- TYPES
-- ============================================================

type DrawingLine = {
	Visible: boolean,
	From: Vector2,
	To: Vector2,
	Color: Color3,
	Thickness: number,
	ZIndex: number,
	Remove: (DrawingLine) -> (),
}

type DrawingText = {
	Visible: boolean,
	Position: Vector2,
	Text: string,
	Color: Color3,
	Size: number,
	Font: number,
	Outline: boolean,
	OutlineColor: Color3,
	Center: boolean,
	ZIndex: number,
	Remove: (DrawingText) -> (),
}

type DrawingTriangle = {
	Visible: boolean,
	PointA: Vector2,
	PointB: Vector2,
	PointC: Vector2,
	Color: Color3,
	Transparency: number,
	ZIndex: number,
	Remove: (DrawingTriangle) -> (),
}

type DrawingCircle = {
	Visible: boolean,
	Position: Vector2,
	Radius: number,
	Color: Color3,
	Thickness: number,
	Filled: boolean,
	Transparency: number,
	NumSides: number,
	ZIndex: number,
	Remove: (DrawingCircle) -> (),
}

type EspBox = {
	top: DrawingLine,
	bottom: DrawingLine,
	left: DrawingLine,
	right: DrawingLine,
}

type OovIndicator = {
	triangleA: DrawingTriangle,
	triangleB: DrawingTriangle,
	text: DrawingText,
	halo: DrawingCircle,
}

type EspEntry = {
	player: Player,
	box: EspBox,
	nameLabel: DrawingText,
	oov: OovIndicator,
	humanoid: Humanoid?,
	charConnection: RBXScriptConnection?,
}

type PredictionState = {
	prevPos: Vector3,
	prevTime: number,
	velocity: Vector3,
}

type AimTarget = {
	worldPos: Vector3,
	screenPos: Vector2,
}

-- ============================================================
-- ESP SETTINGS
-- ============================================================

local espEnabled = false
local showNames = true
local espColor = Color3.fromRGB(255, 80, 80)
local espThick = 1

local oovEnabled = true
local oovShowDistance = true
local oovColor = Color3.fromRGB(255, 200, 60)
local OOV_SIZE = 20
local OOV_PADDING = 50
local OOV_PULSE_SPEED = 4.0
local OOV_PULSE_AMOUNT = 0.15

-- ============================================================
-- AIMBOT SETTINGS
-- ============================================================

local aimbotEnabled = false
local aimbotFov = 120.0
local aimbotSmooth = 5.0
local aimbotBone = "Head"
local showFovCircle = true
local aimbotTeamCheck = false
local aimbotWallCheck = true

-- ============================================================
-- SILENT AIM SETTINGS
-- ============================================================

local silentEnabled = false
local silentTeamCheck = false
local silentWallCheck = true
local silentBone = "Head"
local silentWallBang = true
local silentWallBangMultiplier = 1000.0

-- ============================================================
-- TRIGGERBOT SETTINGS
-- ============================================================

local triggerbotEnabled = false
local triggerbotDelay = 0.08
local triggerbotTeamCheck = false
local triggerbotHitChance = 100
local triggerbotRange = 500.0

local triggerbotLastShot = 0.0
local triggerbotBusy = false

-- ============================================================
-- NO COOLDOWN SETTINGS
-- ============================================================

local noCooldownEnabled = false
local noCooldownAlwaysFire = false   -- if true, spam runs without holding fire
local fireRate = 15.0                -- shots per second

local lastPlayerFireTime = 0.0
local lastBulletData: any = nil
local lastSpamShot = 0.0

-- ============================================================
-- PING / PREDICTION
-- ============================================================

local cachedPing = 0.0
local lastPingAt = 0.0
local PING_INTERVAL = 1.0

local predState: PredictionState? = nil
local VELOCITY_ALPHA = 0.4

-- ============================================================
-- BULLET HANDLER HOOK
-- ============================================================

local BulletHandler: any = nil
local originalBulletFire: any = nil

pcall(function()
	BulletHandler = require(ReplicatedStorage.ModuleScripts.GunModules.BulletHandler)
	originalBulletFire = BulletHandler.Fire
end)

-- ============================================================
-- FOV CIRCLE
-- ============================================================

local fovCircle = Drawing.new("Circle") :: any
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Filled = false
fovCircle.NumSides = 64
fovCircle.ZIndex = 10

local function scaledFov(): number
	local vp = CAMERA.ViewportSize
	return aimbotFov * (vp.Y / 1080)
end

-- ============================================================
-- ESP HELPERS
-- ============================================================

local HALF_WIDTH = 1.5
local HALF_HEIGHT = 3.0

local function newLine(): DrawingLine
	local line = Drawing.new("Line") :: any
	line.Visible = false
	line.Thickness = espThick
	line.Color = espColor
	line.ZIndex = 5
	return line
end

local function newText(): DrawingText
	local text = Drawing.new("Text") :: any
	text.Visible = false
	text.Size = if IS_MOBILE then 18 else 14
	text.Font = Drawing.Fonts.UI
	text.Color = espColor
	text.Outline = true
	text.OutlineColor = Color3.new(0, 0, 0)
	text.Center = true
	text.ZIndex = 6
	return text
end

local function newOovTriangle(): DrawingTriangle
	local tri = Drawing.new("Triangle") :: any
	tri.Visible = false
	tri.Transparency = 0
	tri.Color = oovColor
	tri.ZIndex = 8
	return tri
end

local function newOovText(): DrawingText
	local text = Drawing.new("Text") :: any
	text.Visible = false
	text.Size = if IS_MOBILE then 18 else 15
	text.Font = Drawing.Fonts.UI
	text.Color = oovColor
	text.Outline = true
	text.OutlineColor = Color3.new(0, 0, 0)
	text.Center = true
	text.ZIndex = 10
	return text
end

local function newOovHalo(): DrawingCircle
	local halo = Drawing.new("Circle") :: any
	halo.Visible = false
	halo.Filled = false
	halo.Thickness = 3
	halo.Transparency = 0.4
	halo.NumSides = 32
	halo.Color = oovColor
	halo.ZIndex = 7
	return halo
end

-- ============================================================
-- ESP ENTRY
-- ============================================================

local entries: { [Player]: EspEntry } = {}

local function createEntry(player: Player): EspEntry
	return {
		player = player,
		box = {
			top = newLine(),
			bottom = newLine(),
			left = newLine(),
			right = newLine(),
		},
		nameLabel = newText(),
		oov = {
			triangleA = newOovTriangle(),
			triangleB = newOovTriangle(),
			text = newOovText(),
			halo = newOovHalo(),
		},
		humanoid = nil,
		charConnection = nil,
	}
end

local function hideEntry(entry: EspEntry)
	entry.box.top.Visible = false
	entry.box.bottom.Visible = false
	entry.box.left.Visible = false
	entry.box.right.Visible = false
	entry.nameLabel.Visible = false
end

local function hideOov(entry: EspEntry)
	entry.oov.triangleA.Visible = false
	entry.oov.triangleB.Visible = false
	entry.oov.text.Visible = false
	entry.oov.halo.Visible = false
end

local function destroyEntry(player: Player)
	local entry = entries[player]
	if entry == nil then
		return
	end

	entry.box.top:Remove()
	entry.box.bottom:Remove()
	entry.box.left:Remove()
	entry.box.right:Remove()
	entry.nameLabel:Remove()
	entry.oov.triangleA:Remove()
	entry.oov.triangleB:Remove()
	entry.oov.text:Remove()
	entry.oov.halo:Remove()

	if entry.charConnection ~= nil then
		entry.charConnection:Disconnect()
	end

	entries[player] = nil
end

local function getScreenBox(
	rootPos: Vector3
): (boolean, number, number, number, number)
	local points = {
		rootPos + Vector3.new(HALF_WIDTH, HALF_HEIGHT, 0),
		rootPos + Vector3.new(-HALF_WIDTH, HALF_HEIGHT, 0),
		rootPos + Vector3.new(HALF_WIDTH, -HALF_HEIGHT, 0),
		rootPos + Vector3.new(-HALF_WIDTH, -HALF_HEIGHT, 0),
	}

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local anyVisible = false

	for _, pt in points do
		local screen = CAMERA:WorldToViewportPoint(pt)
		if screen.Z <= 0 then
			continue
		end
		anyVisible = true
		if screen.X < minX then minX = screen.X end
		if screen.Y < minY then minY = screen.Y end
		if screen.X > maxX then maxX = screen.X end
		if screen.Y > maxY then maxY = screen.Y end
	end

	return anyVisible, minX, minY, maxX, maxY
end

local function drawBox(
	entry: EspEntry,
	x1: number,
	y1: number,
	x2: number,
	y2: number
)
	local color = espColor
	local thick = espThick

	entry.box.top.From = Vector2.new(x1, y1)
	entry.box.top.To = Vector2.new(x2, y1)
	entry.box.top.Color = color
	entry.box.top.Thickness = thick
	entry.box.top.Visible = true

	entry.box.bottom.From = Vector2.new(x1, y2)
	entry.box.bottom.To = Vector2.new(x2, y2)
	entry.box.bottom.Color = color
	entry.box.bottom.Thickness = thick
	entry.box.bottom.Visible = true

	entry.box.left.From = Vector2.new(x1, y1)
	entry.box.left.To = Vector2.new(x1, y2)
	entry.box.left.Color = color
	entry.box.left.Thickness = thick
	entry.box.left.Visible = true

	entry.box.right.From = Vector2.new(x2, y1)
	entry.box.right.To = Vector2.new(x2, y2)
	entry.box.right.Color = color
	entry.box.right.Thickness = thick
	entry.box.right.Visible = true

	entry.nameLabel.Position = Vector2.new((x1 + x2) / 2, y1 - 18)
	entry.nameLabel.Text = entry.player.Name
	entry.nameLabel.Color = color
	entry.nameLabel.Visible = showNames
end

-- ============================================================
-- OUT OF VIEW INDICATOR
-- ============================================================

local function drawOov(entry: EspEntry, worldPos: Vector3, now: number)
	local vp = CAMERA.ViewportSize
	local center = Vector2.new(vp.X / 2, vp.Y / 2)

	local screen, _ = CAMERA:WorldToViewportPoint(worldPos)
	local screenPos = Vector2.new(screen.X, screen.Y)

	if screen.Z < 0 then
		screenPos = center * 2 - screenPos
	end

	local dir = screenPos - center
	if dir.Magnitude < 0.001 then
		hideOov(entry)
		return
	end
	dir = dir.Unit

	local pad = OOV_PADDING
	local minX, maxX = pad, vp.X - pad
	local minY, maxY = pad, vp.Y - pad

	local tX = math.huge
	if dir.X > 0 then
		tX = (maxX - center.X) / dir.X
	elseif dir.X < 0 then
		tX = (minX - center.X) / dir.X
	end

	local tY = math.huge
	if dir.Y > 0 then
		tY = (maxY - center.Y) / dir.Y
	elseif dir.Y < 0 then
		tY = (minY - center.Y) / dir.Y
	end

	local t = math.min(tX, tY)
	local edgePos = center + dir * t

	local pulse = 1 + math.sin(now * OOV_PULSE_SPEED) * OOV_PULSE_AMOUNT
	local size = OOV_SIZE * pulse

	local perp = Vector2.new(-dir.Y, dir.X)

	local a = edgePos - perp * size
	local b = edgePos + dir * size * 1.9
	local m = edgePos + dir * size * 0.35 + perp * size * 0.35
	local d = edgePos + perp * size

	local triA = entry.oov.triangleA
	triA.PointA = a
	triA.PointB = b
	triA.PointC = m
	triA.Color = oovColor
	triA.Visible = true

	local triB = entry.oov.triangleB
	triB.PointA = a
	triB.PointB = m
	triB.PointC = d
	triB.Color = oovColor
	triB.Visible = true

	local halo = entry.oov.halo
	halo.Position = edgePos + dir * size * 0.7
	halo.Radius = size * 1.7
	halo.Thickness = 3
	halo.Transparency = 0.4
	halo.Color = oovColor
	halo.Visible = true

	local distance = (worldPos - CAMERA.CFrame.Position).Magnitude
	local text = entry.oov.text
	text.Position = edgePos - dir * (size + 24)
	text.Text = string.format("%d m", math.floor(distance + 0.5))
	text.Color = oovColor
	text.Visible = oovShowDistance
end

-- ============================================================
-- WALL CHECK (RAYCAST)
-- ============================================================

local function hasLineOfSight(origin: Vector3, targetPart: BasePart): boolean
	local filterList: { Instance } = {}

	local localChar = LOCAL_PLAYER.Character
	if localChar ~= nil then
		table.insert(filterList, localChar)
	end

	local targetChar = targetPart.Parent
	if targetChar ~= nil then
		table.insert(filterList, targetChar)
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = filterList
	params.IgnoreWater = true

	local direction = targetPart.Position - origin
	local result = workspace:Raycast(origin, direction, params)

	return result == nil
end

-- ============================================================
-- TARGET SELECTION HELPERS
-- ============================================================

local function getScreenCenter(): Vector2
	local vp = CAMERA.ViewportSize
	return Vector2.new(vp.X / 2, vp.Y / 2)
end

local function isPlayerValid(player: Player, teamCheck: boolean): boolean
	if player == LOCAL_PLAYER then
		return false
	end

	local character = player.Character
	if character == nil then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid?
	if humanoid == nil or humanoid.Health <= 0 then
		return false
	end

	if teamCheck and player.Team == LOCAL_PLAYER.Team then
		return false
	end

	return true
end

local function getBonePart(character: Model, bone: string): BasePart?
	local part = character:FindFirstChild(bone) :: BasePart?
	if part == nil and bone == "Head" then
		part = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	end
	return part
end

-- ============================================================
-- AIMBOT PREDICTION
-- ============================================================

local function updatePrediction(currentPos: Vector3, now: number): Vector3
	local state = predState

	if state == nil then
		predState = {
			prevPos = currentPos,
			prevTime = now,
			velocity = Vector3.zero,
		}
		return currentPos
	end

	local elapsed = now - state.prevTime
	if elapsed < 0.001 then
		return currentPos + state.velocity * cachedPing
	end

	local rawVelocity = (currentPos - state.prevPos) / elapsed
	local smoothVelocity = state.velocity:Lerp(rawVelocity, VELOCITY_ALPHA)

	state.prevPos = currentPos
	state.prevTime = now
	state.velocity = smoothVelocity

	return currentPos + smoothVelocity * cachedPing
end

local function resetPrediction()
	predState = nil
end

-- ============================================================
-- AIMBOT TARGET SELECTION
-- ============================================================

local function findClosestTarget(): AimTarget?
	local center = getScreenCenter()
	local fovLimit = scaledFov()
	local bestDist = fovLimit
	local best: AimTarget? = nil

	local origin = CAMERA.CFrame.Position

	for _, player in Players:GetPlayers() do
		if not isPlayerValid(player, aimbotTeamCheck) then
			continue
		end

		local character = player.Character :: Model
		local bonePart = getBonePart(character, aimbotBone)
		if bonePart == nil then
			continue
		end

		local screen = CAMERA:WorldToViewportPoint(bonePart.Position)
		if screen.Z <= 0 then
			continue
		end

		local screenPos = Vector2.new(screen.X, screen.Y)
		local dist = (screenPos - center).Magnitude
		if dist >= bestDist then
			continue
		end

		if aimbotWallCheck and not hasLineOfSight(origin, bonePart) then
			continue
		end

		bestDist = dist
		best = {
			worldPos = bonePart.Position,
			screenPos = screenPos,
		}
	end

	return best
end

-- ============================================================
-- SILENT AIM TARGET SELECTION (nearest by world distance)
-- ============================================================

local function findNearestPlayerSilent(): BasePart?
	local origin = CAMERA.CFrame.Position
	local bestPart: BasePart? = nil
	local bestDist = math.huge

	for _, player in Players:GetPlayers() do
		if not isPlayerValid(player, silentTeamCheck) then
			continue
		end

		local character = player.Character :: Model
		local bonePart = getBonePart(character, silentBone)
		if bonePart == nil then
			continue
		end

		if silentWallCheck and not silentWallBang then
			if not hasLineOfSight(origin, bonePart) then
				continue
			end
		end

		local dist = (bonePart.Position - origin).Magnitude
		if dist < bestDist then
			bestDist = dist
			bestPart = bonePart
		end
	end

	return bestPart
end

-- ============================================================
-- SILENT AIM / BULLET DATA MODIFICATION
-- ============================================================

local function applySilentAimToData(data: any)
	if not silentEnabled then
		return
	end
	if data == nil or data.Origin == nil then
		return
	end

	local targetPart = findNearestPlayerSilent()
	if targetPart == nil then
		return
	end

	-- Refresh origin to the current camera so spam shots do not fire from a
	-- stale position.
	local origin = CAMERA.CFrame.Position
	data.Origin = origin
	data.Direction = (targetPart.Position - origin).Unit

	if silentWallBang and data.Force ~= nil then
		data.Force = data.Force * silentWallBangMultiplier
	end

	if data.Misc ~= nil then
		data.Misc.CamCFrame = CFrame.new(origin, targetPart.Position)
	end
end

local function cloneBulletData(data: any): any
	local copy = table.clone(data)
	if type(copy.Misc) == "table" then
		copy.Misc = table.clone(copy.Misc)
	end
	return copy
end

-- ============================================================
-- BULLET HANDLER HOOK
-- ============================================================

local function setupSilentAimHook()
	if BulletHandler == nil or originalBulletFire == nil then
		return
	end
	if BulletHandler.Fire ~= originalBulletFire then
		return
	end

	BulletHandler.Fire = function(data: any, ...: any)
		lastPlayerFireTime = os.clock()
		if data ~= nil and data.Origin ~= nil then
			lastBulletData = cloneBulletData(data)
		end

		applySilentAimToData(data)
		return originalBulletFire(data, ...)
	end
end

setupSilentAimHook()

-- ============================================================
-- TRIGGERBOT - MOBILE-AWARE FIRE MECHANISM
-- ============================================================

local TRIGGER_BODY_PARTS: { [string]: boolean } = {
	Head = true,
	HumanoidRootPart = true,
	UpperTorso = true,
	LowerTorso = true,
	Torso = true,
	LeftUpperArm = true,
	RightUpperArm = true,
	LeftLowerArm = true,
	RightLowerArm = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	LeftHand = true,
	RightHand = true,
	LeftUpperLeg = true,
	RightUpperLeg = true,
	LeftLowerLeg = true,
	RightLowerLeg = true,
	["Left Leg"] = true,
	["Right Leg"] = true,
	LeftFoot = true,
	RightFoot = true,
}

local mouse1pressFn = rawget(getfenv(), "mouse1press") or (getgenv and getgenv().mouse1press)
local mouse1releaseFn = rawget(getfenv(), "mouse1release") or (getgenv and getgenv().mouse1release)
local mouse1clickFn = rawget(getfenv(), "mouse1click") or (getgenv and getgenv().mouse1click)

local FIRE_KEYWORDS = { "fire", "shoot", "attack", "trigger", "primary" }

local cachedFireButton: GuiButton? = nil
local lastFireButtonScan = 0.0
local FIRE_BUTTON_SCAN_INTERVAL = 1.0

local triggerRayParams: RaycastParams? = nil
local triggerRayOwner: Model? = nil

local function invalidateTriggerRayParams()
	triggerRayParams = nil
	triggerRayOwner = nil
end

local function getTriggerRayParams(): RaycastParams
	local localChar = LOCAL_PLAYER.Character
	if triggerRayParams == nil or triggerRayOwner ~= localChar then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.IgnoreWater = true
		params.FilterDescendantsInstances = if localChar ~= nil then { localChar } else {}
		triggerRayParams = params
		triggerRayOwner = localChar
	end
	return triggerRayParams :: RaycastParams
end

local function findFireButton(): GuiButton?
	local playerGui = LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")
	if playerGui == nil then
		return nil
	end

	local touchGui = playerGui:FindFirstChild("TouchGui")
	if touchGui ~= nil then
		local frame = touchGui:FindFirstChild("TouchControlFrame")
		if frame ~= nil then
			for _, child in frame:GetDescendants() do
				if child:IsA("GuiButton") and child.Visible then
					local name = child.Name:lower()
					for _, kw in FIRE_KEYWORDS do
						if name:find(kw, 1, true) ~= nil then
							return child
						end
					end
				end
			end
		end
	end

	local queue: { Instance } = { playerGui }
	local head = 1
	local visited = 0
	while head <= #queue and visited < 400 do
		local current = queue[head]
		head += 1
		visited += 1

		for _, child in current:GetChildren() do
			if child:IsA("GuiButton") and child.Visible then
				local name = child.Name:lower()
				for _, kw in FIRE_KEYWORDS do
					if name:find(kw, 1, true) ~= nil then
						return child
					end
				end
			end
			if child:IsA("GuiObject") then
				table.insert(queue, child)
			end
		end
	end

	return nil
end

local function getFireButton(): GuiButton?
	if cachedFireButton ~= nil then
		if cachedFireButton.Parent ~= nil and cachedFireButton.Visible then
			return cachedFireButton
		end
		cachedFireButton = nil
	end

	local now = os.clock()
	if now - lastFireButtonScan < FIRE_BUTTON_SCAN_INTERVAL then
		return nil
	end
	lastFireButtonScan = now

	local btn = findFireButton()
	cachedFireButton = btn
	return btn
end

local function tapButton(button: GuiButton)
	local abs = button.AbsolutePosition
	local size = button.AbsoluteSize
	local x = abs.X + size.X * 0.5
	local y = abs.Y + size.Y * 0.5

	pcall(function()
		VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
	end)
	task.delay(0.02, function()
		pcall(function()
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
		end)
	end)
end

local function fireTriggerShot()
	if triggerbotBusy then
		return
	end

	local now = os.clock()
	if now - triggerbotLastShot < triggerbotDelay then
		return
	end

	if triggerbotHitChance < 100 and math.random(1, 100) > triggerbotHitChance then
		return
	end

	triggerbotLastShot = now
	triggerbotBusy = true

	if IS_MOBILE then
		local btn = getFireButton()
		if btn ~= nil then
			tapButton(btn)
			task.delay(0.04, function()
				triggerbotBusy = false
			end)
			return
		end
	end

	if mouse1pressFn ~= nil and mouse1releaseFn ~= nil then
		pcall(mouse1pressFn)
		task.delay(0.02, function()
			pcall(mouse1releaseFn)
		end)
		task.delay(0.04, function()
			triggerbotBusy = false
		end)
		return
	end

	if mouse1clickFn ~= nil then
		pcall(mouse1clickFn)
		task.delay(0.04, function()
			triggerbotBusy = false
		end)
		return
	end

	triggerbotBusy = false
end

local function isValidTriggerPart(part: BasePart?): boolean
	if part == nil then
		return false
	end
	if not TRIGGER_BODY_PARTS[part.Name] then
		return false
	end

	local character = part:FindFirstAncestorOfClass("Model")
	if character == nil then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid?
	if humanoid == nil or humanoid.Health <= 0 then
		return false
	end

	local player = Players:GetPlayerFromCharacter(character)
	if player == nil or player == LOCAL_PLAYER then
		return false
	end

	if triggerbotTeamCheck and player.Team == LOCAL_PLAYER.Team then
		return false
	end

	return true
end

local function getTargetUnderCrosshair(): BasePart?
	local vp = CAMERA.ViewportSize
	local ray = CAMERA:ViewportPointToRay(vp.X * 0.5, vp.Y * 0.5)

	local params = getTriggerRayParams()
	local result = workspace:Raycast(ray.Origin, ray.Direction * triggerbotRange, params)
	if result == nil then
		return nil
	end

	if not isValidTriggerPart(result.Instance) then
		return nil
	end

	return result.Instance
end

-- ============================================================
-- NO COOLDOWN - CONSTANT FIRE
-- ============================================================

-- Returns true when the game should be spamming shots this frame.
-- In "Always Fire" mode we ignore the mouse/input state entirely, which is
-- what makes the gun fire non-stop.
local function shouldSpamFire(): boolean
	if noCooldownAlwaysFire then
		return true
	end

	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
		return true
	end
	if os.clock() - lastPlayerFireTime < 0.2 then
		return true
	end
	return false
end

local function processNoCooldown(now: number)
	if not noCooldownEnabled then
		return
	end
	if BulletHandler == nil or originalBulletFire == nil then
		return
	end
	if lastBulletData == nil then
		return
	end
	if not shouldSpamFire() then
		return
	end

	local interval = 1.0 / math.max(fireRate, 0.1)
	if now - lastSpamShot < interval then
		return
	end
	lastSpamShot = now

	local payload = cloneBulletData(lastBulletData)
	applySilentAimToData(payload)

	pcall(originalBulletFire, payload)
end

-- ============================================================
-- AIMBOT CAMERA ROTATION
-- ============================================================

local function aimAtWorldPos(targetPos: Vector3, dt: number)
	local camCF = CAMERA.CFrame
	local camPos = camCF.Position

	local toTarget = targetPos - camPos
	if toTarget.Magnitude < 0.001 then
		return
	end

	local targetCF = CFrame.lookAt(camPos, camPos + toTarget)

	local targetRot = targetCF - targetCF.Position
	local camRot = camCF - camCF.Position

	local t = math.clamp((1 / aimbotSmooth) * dt * 60, 0, 1)

	local newRot = camRot:Lerp(targetRot, t)
	CAMERA.CFrame = CFrame.new(camPos) * newRot
end

-- ============================================================
-- MAIN LOOP
-- ============================================================

RunService.Heartbeat:Connect(function(dt: number)
	local now = os.clock()
	local center = getScreenCenter()
	local vp = CAMERA.ViewportSize

	if now - lastPingAt >= PING_INTERVAL then
		cachedPing = LOCAL_PLAYER:GetNetworkPing()
		lastPingAt = now
	end

	fovCircle.Position = center
	fovCircle.Radius = scaledFov()
	fovCircle.Visible = aimbotEnabled and showFovCircle

	for _, entry in entries do
		if entry.player == LOCAL_PLAYER then
			hideEntry(entry)
			hideOov(entry)
			continue
		end

		local humanoid = entry.humanoid
		local character = entry.player.Character

		local alive = character ~= nil
			and humanoid ~= nil
			and humanoid.Health > 0

		if not alive then
			hideEntry(entry)
			hideOov(entry)
			continue
		end

		local rootPart = (character :: Model):FindFirstChild("HumanoidRootPart") :: BasePart?
		if rootPart == nil then
			hideEntry(entry)
			hideOov(entry)
			continue
		end

		local visible, x1, y1, x2, y2 = getScreenBox(rootPart.Position)

		local onScreen = visible
			and x2 >= 0 and x1 <= vp.X
			and y2 >= 0 and y1 <= vp.Y

		if espEnabled and onScreen then
			drawBox(entry, x1, y1, x2, y2)
		else
			hideEntry(entry)
		end

		if oovEnabled and not onScreen then
			drawOov(entry, rootPart.Position, now)
		else
			hideOov(entry)
		end
	end

	processNoCooldown(now)

	if triggerbotEnabled and not triggerbotBusy then
		if getTargetUnderCrosshair() ~= nil then
			fireTriggerShot()
		end
	end

	if not aimbotEnabled then
		resetPrediction()
		return
	end

	local target = findClosestTarget()
	if target == nil then
		resetPrediction()
		return
	end

	local predicted = updatePrediction(target.worldPos, now)
	aimAtWorldPos(predicted, dt)
end)

-- ============================================================
-- PLAYER HANDLING
-- ============================================================

local function onCharacterAdded(entry: EspEntry, character: Model)
	entry.humanoid = nil
	local humanoid = character:WaitForChild("Humanoid", 5) :: Humanoid?
	entry.humanoid = humanoid

	if entry.player == LOCAL_PLAYER then
		invalidateTriggerRayParams()
	end
end

local function setupPlayer(player: Player)
	if player == LOCAL_PLAYER then
		return
	end
	if entries[player] ~= nil then
		return
	end

	local entry = createEntry(player)
	entries[player] = entry

	if player.Character ~= nil then
		task.spawn(onCharacterAdded, entry, player.Character)
	end

	entry.charConnection = player.CharacterAdded:Connect(function(character)
		task.spawn(onCharacterAdded, entry, character)
	end)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(destroyEntry)

for _, player in Players:GetPlayers() do
	setupPlayer(player)
end

LOCAL_PLAYER.CharacterAdded:Connect(function()
	invalidateTriggerRayParams()
	cachedFireButton = nil
	lastFireButtonScan = 0.0
	lastBulletData = nil
end)

-- ============================================================
-- GUI
-- ============================================================

local Window = MinecraftLib:CreateWindow({
	Title = "IRY HUB",
	Theme = "Nether",
	ToggleKey = "RightShift",
	Size = { X = 500, Y = 460 },
	ConfigFolder = "IRYHUB",
	AutoSave = true,
	AutoLoad = true,
})

Window:SetWatermark(true, "IRY HUB")

-- ESP

local espTab = Window:AddTab("ESP")
local espSec = espTab:AddSection("IRY HUB | ESP")

espSec:AddToggle({
	Name = "Enable ESP",
	Default = false,
	Flag = "esp_on",
	Callback = function(v: boolean) espEnabled = v end,
})

espSec:AddToggle({
	Name = "Player Names",
	Default = true,
	Flag = "esp_names",
	Callback = function(v: boolean) showNames = v end,
})

espSec:AddColorPicker({
	Name = "Box Color",
	Default = Color3.fromRGB(255, 80, 80),
	Flag = "esp_color",
	Callback = function(v: Color3) espColor = v end,
})

espSec:AddSlider({
	Name = "Line Thickness",
	Min = 1,
	Max = 5,
	Default = 1,
	Step = 1,
	Flag = "esp_thick",
	Callback = function(v: number) espThick = v end,
})

-- Out of View

local oovSec = espTab:AddSection("IRY HUB | Out of View")

oovSec:AddToggle({
	Name = "Enable OOV Indicator",
	Default = true,
	Flag = "oov_on",
	Tooltip = "Show an edge arrow toward off-screen players",
	Callback = function(v: boolean) oovEnabled = v end,
})

oovSec:AddToggle({
	Name = "Show Distance",
	Default = true,
	Flag = "oov_dist",
	Callback = function(v: boolean) oovShowDistance = v end,
})

oovSec:AddColorPicker({
	Name = "Indicator Color",
	Default = Color3.fromRGB(255, 200, 60),
	Flag = "oov_color",
	Callback = function(v: Color3)
		oovColor = v
		for _, entry in entries do
			entry.oov.triangleA.Color = v
			entry.oov.triangleB.Color = v
			entry.oov.text.Color = v
			entry.oov.halo.Color = v
		end
	end,
})

-- AIMBOT

local aimTab = Window:AddTab("Aimbot")
local aimSec = aimTab:AddSection("IRY HUB | Aimbot")

aimSec:AddToggle({
	Name = "Enable Aimbot",
	Default = false,
	Flag = "aim_on",
	Callback = function(v: boolean) aimbotEnabled = v end,
})

aimSec:AddToggle({
	Name = "Team Check",
	Default = false,
	Flag = "aim_team",
	Tooltip = "Do not target teammates",
	Callback = function(v: boolean) aimbotTeamCheck = v end,
})

aimSec:AddToggle({
	Name = "Wall Check",
	Default = true,
	Flag = "aim_wall",
	Tooltip = "Only target players with clear line of sight",
	Callback = function(v: boolean) aimbotWallCheck = v end,
})

aimSec:AddToggle({
	Name = "Show FOV Circle",
	Default = true,
	Flag = "aim_fov_vis",
	Callback = function(v: boolean) showFovCircle = v end,
})

aimSec:AddSlider({
	Name = "FOV",
	Min = 10,
	Max = 500,
	Default = 120,
	Step = 5,
	Suffix = " px",
	Flag = "aim_fov",
	Tooltip = "Target search radius (scales with screen)",
	Callback = function(v: number) aimbotFov = v end,
})

aimSec:AddSlider({
	Name = "Smoothness",
	Min = 1,
	Max = 20,
	Default = 5,
	Step = 1,
	Flag = "aim_smooth",
	Tooltip = "1 = instant, 20 = very smooth",
	Callback = function(v: number) aimbotSmooth = v end,
})

aimSec:AddDropdown({
	Name = "Aim Bone",
	Options = { "Head", "HumanoidRootPart" },
	Default = "Head",
	Flag = "aim_bone",
	Callback = function(v: string) aimbotBone = v end,
})

-- SILENT AIM

local silentTab = Window:AddTab("Silent")
local silentSec = silentTab:AddSection("IRY HUB | Silent Aim")

silentSec:AddToggle({
	Name = "Enable Silent Aim",
	Default = false,
	Flag = "silent_on",
	Tooltip = "Redirects your shots to the nearest player by distance",
	Callback = function(v: boolean) silentEnabled = v end,
})

silentSec:AddToggle({
	Name = "Team Check",
	Default = false,
	Flag = "silent_team",
	Tooltip = "Do not target teammates",
	Callback = function(v: boolean) silentTeamCheck = v end,
})

silentSec:AddToggle({
	Name = "Wall Check",
	Default = true,
	Flag = "silent_wall",
	Tooltip = "Only target players with clear line of sight (ignored when Wall Bang is on)",
	Callback = function(v: boolean) silentWallCheck = v end,
})

silentSec:AddToggle({
	Name = "Wall Bang",
	Default = true,
	Flag = "silent_wallbang",
	Tooltip = "Bullets ignore walls by boosting their speed massively",
	Callback = function(v: boolean) silentWallBang = v end,
})

silentSec:AddSlider({
	Name = "Wall Bang Strength",
	Min = 10,
	Max = 5000,
	Default = 1000,
	Step = 10,
	Suffix = "x",
	Flag = "silent_wallbang_str",
	Tooltip = "Higher = more force. 1000x works for most games",
	Callback = function(v: number) silentWallBangMultiplier = v end,
})

silentSec:AddDropdown({
	Name = "Aim Bone",
	Options = { "Head", "HumanoidRootPart" },
	Default = "Head",
	Flag = "silent_bone",
	Callback = function(v: string) silentBone = v end,
})

if BulletHandler == nil then
	silentSec:AddLabel("BulletHandler not found - silent aim inactive")
end

-- TRIGGERBOT

local triggerTab = Window:AddTab("Trigger")
local triggerSec = triggerTab:AddSection("IRY HUB | Triggerbot")

triggerSec:AddToggle({
	Name = "Enable Triggerbot",
	Default = false,
	Flag = "trigger_on",
	Tooltip = "Automatically shoots when the crosshair is on an enemy",
	Callback = function(v: boolean) triggerbotEnabled = v end,
})

triggerSec:AddToggle({
	Name = "Team Check",
	Default = false,
	Flag = "trigger_team",
	Tooltip = "Do not shoot teammates",
	Callback = function(v: boolean) triggerbotTeamCheck = v end,
})

triggerSec:AddSlider({
	Name = "Shot Delay",
	Min = 0.01,
	Max = 0.5,
	Default = 0.08,
	Step = 0.01,
	Suffix = " s",
	Flag = "trigger_delay",
	Tooltip = "Minimum time between shots",
	Callback = function(v: number) triggerbotDelay = v end,
})

triggerSec:AddSlider({
	Name = "Hit Chance",
	Min = 10,
	Max = 100,
	Default = 100,
	Step = 5,
	Suffix = " %",
	Flag = "trigger_chance",
	Tooltip = "Chance to fire when a target is detected",
	Callback = function(v: number) triggerbotHitChance = v end,
})

triggerSec:AddSlider({
	Name = "Scan Range",
	Min = 50,
	Max = 2000,
	Default = 500,
	Step = 50,
	Suffix = " st",
	Flag = "trigger_range",
	Tooltip = "How far the crosshair ray reaches",
	Callback = function(v: number) triggerbotRange = v end,
})

if IS_MOBILE then
	triggerSec:AddLabel("Mobile mode: auto-detects the on-screen fire button")
elseif mouse1pressFn == nil and mouse1clickFn == nil then
	triggerSec:AddLabel("mouse1 globals unavailable - triggerbot inactive")
end

-- NO COOLDOWN

local cdTab = Window:AddTab("Cooldown")
local cdSec = cdTab:AddSection("IRY HUB | No Cooldown")

cdSec:AddToggle({
	Name = "Enable No Cooldown",
	Default = false,
	Flag = "cd_on",
	Tooltip = "Bypass the weapon's fire rate",
	Callback = function(v: boolean) noCooldownEnabled = v end,
})

cdSec:AddToggle({
	Name = "Constant Fire",
	Default = false,
	Flag = "cd_always",
	Tooltip = "Fire non-stop without holding the button",
	Callback = function(v: boolean) noCooldownAlwaysFire = v end,
})

cdSec:AddSlider({
	Name = "Fire Rate",
	Min = 1,
	Max = 50,
	Default = 15,
	Step = 1,
	Suffix = " /s",
	Flag = "cd_rate",
	Tooltip = "How many shots per second to inject",
	Callback = function(v: number) fireRate = v end,
})

if BulletHandler == nil then
	cdSec:AddLabel("BulletHandler not found - no cooldown inactive")
else
	cdSec:AddLabel("Fire once to capture the payload, then it fires on its own")
end

Window:AddSettingsTab("Settings")

Window:Notify({
	Title = "IRY HUB",
	Content = "Loaded successfully! RightShift - menu",
	Type = "Success",
	Duration = 5,
})
