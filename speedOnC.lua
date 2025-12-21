-- LocalScript : Speed Toggle (C)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-------------------------------------------------
-- GUI CONTAINER (SHARED)
-------------------------------------------------
local gui = player:WaitForChild("PlayerGui"):FindFirstChild("StatusGui")

if not gui then
	gui = Instance.new("ScreenGui")
	gui.Name = "StatusGui"
	gui.ResetOnSpawn = false
	gui.Parent = player.PlayerGui
end

-------------------------------------------------
-- SPEED VARS
-------------------------------------------------
local speedEnabled = false
local desiredSpeed = 150
local statusLabel -- this script's label only

-------------------------------------------------
-- FIND FREE SLOT (STACKING)
-------------------------------------------------
local function getNextYOffset()
	local count = 0
	for _, child in ipairs(gui:GetChildren()) do
		if child:IsA("TextLabel") then
			count += 1
		end
	end
	return -40 - (count * 34) -- move up for each existing label
end

-------------------------------------------------
-- SHOW / HIDE TEXT
-------------------------------------------------
local function showStatus()
	if statusLabel then return end

	statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(0, 220, 0, 30)
	statusLabel.Position = UDim2.new(0, 10, 1, getNextYOffset())
	statusLabel.BackgroundTransparency = 0.3
	statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	statusLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextScaled = true
	statusLabel.Text = "SPEED: ON"
	statusLabel.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = statusLabel
end

local function hideStatus()
	if statusLabel then
		statusLabel:Destroy()
		statusLabel = nil
	end
end

-------------------------------------------------
-- CHARACTER RESPAWN
-------------------------------------------------
local function onCharacterAdded(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")

	if speedEnabled then
		humanoid.WalkSpeed = desiredSpeed
	end
end

player.CharacterAdded:Connect(onCharacterAdded)

-------------------------------------------------
-- TOGGLE SPEED
-------------------------------------------------
local function toggleSpeed()
	speedEnabled = not speedEnabled

	if speedEnabled then
		if humanoid then
			humanoid.WalkSpeed = desiredSpeed
		end
		showStatus()
	else
		hideStatus()
	end
end

-------------------------------------------------
-- INPUT
-------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.C then
		toggleSpeed()
	end
end)

-------------------------------------------------
-- CONSTANT ENFORCE
-------------------------------------------------
RunService.RenderStepped:Connect(function()
	if speedEnabled and humanoid and humanoid.WalkSpeed ~= desiredSpeed then
		humanoid.WalkSpeed = desiredSpeed
	end
end)
