-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local TP_HEIGHT = 50

local character
local hrp

-- Handle spawn / respawn
local function onCharacterAdded(char)
	character = char
	hrp = char:WaitForChild("HumanoidRootPart")
end

-- Bind current + future characters
if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Keybind: single press Y
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if input.KeyCode ~= Enum.KeyCode.Y then return end
	if not hrp then return end

	hrp.CFrame = hrp.CFrame + Vector3.new(0, TP_HEIGHT, 0)
end)
