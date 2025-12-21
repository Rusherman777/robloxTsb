-- LocalScript
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local speedEnabled = false
local desiredSpeed = 150

-- Notification function
local function notify(text)
    StarterGui:SetCore("SendNotification", {
        Title = "Speed",
        Text = text,
        Duration = 0.5
    })
end

-- Function to update humanoid on respawn
local function onCharacterAdded(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	-- Immediately enforce speed if enabled
	if speedEnabled then
		humanoid.WalkSpeed = desiredSpeed
	end
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Toggle function
local function toggleSpeed()
	speedEnabled = not speedEnabled
	if speedEnabled and humanoid then
		humanoid.WalkSpeed = desiredSpeed
		notify("Speed ON")
	else
		-- Optionally reset to default speed (16)
		if humanoid then
			humanoid.WalkSpeed = 16
		end
		notify("Speed OFF")
	end
end

-- Listen for key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.C then
		toggleSpeed()
	end
end)

-- Constantly enforce speed if enabled
RunService.RenderStepped:Connect(function()
	if speedEnabled and humanoid then
		if humanoid.WalkSpeed ~= desiredSpeed then
			humanoid.WalkSpeed = desiredSpeed
		end
	end
end)
