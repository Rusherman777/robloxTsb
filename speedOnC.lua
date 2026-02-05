-- LocalScript
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character
local humanoid

local speedEnabled = false
local desiredSpeed = 100 -- FORCE 100

local function notify(text)
	StarterGui:SetCore("SendNotification", {
		Title = "Speed",
		Text = text,
		Duration = 0.6
	})
end

local function applySpeed()
	if humanoid and speedEnabled then
		humanoid.WalkSpeed = desiredSpeed
	end
end

local function onCharacterAdded(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")

	-- Force speed immediately
	applySpeed()

	-- Re-apply speed whenever server changes it
	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if speedEnabled and humanoid.WalkSpeed ~= desiredSpeed then
			humanoid.WalkSpeed = desiredSpeed
		end
	end)
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
	onCharacterAdded(player.Character)
end

local function toggleSpeed()
	speedEnabled = not speedEnabled

	if speedEnabled then
		applySpeed()
		notify("Speed ON (100)")
	else
		if humanoid then
			humanoid.WalkSpeed = 16
		end
		notify("Speed OFF")
	end
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.C then
		toggleSpeed()
	end
end)

-- Frame-by-frame enforcement
RunService.Stepped:Connect(function()
	if speedEnabled then
		applySpeed()
	end
end)
