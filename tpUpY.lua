-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local DOUBLE_PRESS_TIME = 0.3
local TP_HEIGHT = 100

local lastPress = 0
local character
local hrp

-- Character handling (death / respawn safe)
local function onCharacterAdded(char)
	character = char
	hrp = nil

	task.spawn(function()
		hrp = char:WaitForChild("HumanoidRootPart", 10)
	end)
end

if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Input handling
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if input.KeyCode ~= Enum.KeyCode.Y then return end

	local now = tick()

	if now - lastPress <= DOUBLE_PRESS_TIME then
		if hrp and hrp.Parent then
			hrp.CFrame = hrp.CFrame + Vector3.new(0, TP_HEIGHT, 0)
		end
	end

	lastPress = now
end)
