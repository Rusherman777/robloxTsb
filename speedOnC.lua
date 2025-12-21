-- LocalScript
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local speedEnabled = false
local desiredSpeed = 200

-- Toggle function
local function toggleSpeed()
    speedEnabled = not speedEnabled
    if speedEnabled then
        humanoid.WalkSpeed = desiredSpeed
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
game:GetService("RunService").RenderStepped:Connect(function()
    if speedEnabled then
        if humanoid.WalkSpeed ~= desiredSpeed then
            humanoid.WalkSpeed = desiredSpeed
        end
    end
end)
