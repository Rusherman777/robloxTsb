-- LocalScript
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Reference to character and HumanoidRootPart
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Update character references when respawning
local function onCharacterAdded(char)
    character = char
    hrp = character:WaitForChild("HumanoidRootPart")
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Function to teleport to mouse position
local function teleportToMouse()
    if hrp then
        local mousePos = mouse.Hit.Position
        hrp.CFrame = CFrame.new(mousePos.X, mousePos.Y + 3, mousePos.Z) -- Raise 3 studs to avoid falling into ground
    end
end

-- Listen for key press
UserInputService.InputBegan:Connect(function(input, typing)
    if typing then return end
    if input.KeyCode == Enum.KeyCode.T then
        teleportToMouse()
    end
end)
