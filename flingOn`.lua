-- LocalScript (StarterPlayerScripts)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local lp = Players.LocalPlayer
local flingActive = false
local flingForce = 1e8 -- massive fling

-- Fling loop
local function flingLoop()
    while true do
        RunService.Heartbeat:Wait()
        if flingActive then
            local character = lp.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.Velocity
                hrp.Velocity = vel * 10000 + Vector3.new(0, flingForce, 0)
                RunService.RenderStepped:Wait()
                hrp.Velocity = vel -- reset briefly
            end
        end
    end
end

-- Notification function
local function notify(message)
    StarterGui:SetCore("SendNotification", {
        Title = "Fling",
        Text = message,
        Duration = 0.5
    })
end

-- Toggle fling by Backquote key (`) reliably
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Backquote then
        flingActive = not flingActive
        notify(flingActive and "ON" or "OFF")
    end
end)

-- Start fling loop
coroutine.wrap(flingLoop)()
