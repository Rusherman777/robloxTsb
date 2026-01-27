-- LocalScript
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Variables for lock-on
local lockOn = false
local lockedTarget = nil

-- Notification function
local function notify(text)
    StarterGui:SetCore("SendNotification", {
        Title = "Lock-On",
        Text = text,
        Duration = 0.5
    })
end

-- Update character reference on respawn
local function onCharacterAdded(char)
    Character = char
end
Player.CharacterAdded:Connect(onCharacterAdded)

-- Get closest alive player
local function getClosestAlivePlayer()
    local closest = nil
    local shortestDist = math.huge
    local myHRP = Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= Player and other.Character then
            local hum = other.Character:FindFirstChildWhichIsA("Humanoid")
            local hrp = other.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dist < shortestDist then
                    closest = other
                    shortestDist = dist
                end
            end
        end
    end

    return closest
end

-- Update camera when locked-on
RunService.RenderStepped:Connect(function()
    if lockOn then
        if not lockedTarget
            or not lockedTarget.Character
            or not lockedTarget.Character:FindFirstChildWhichIsA("Humanoid")
            or lockedTarget.Character:FindFirstChildWhichIsA("Humanoid").Health <= 0
        then
            lockedTarget = getClosestAlivePlayer()
            if not lockedTarget then
                lockOn = false
                notify("Lock-On OFF")
                return
            end
        end

        local targetHRP = lockedTarget.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetHRP.Position)
        end
    end
end)

-- Teleport behind and follow for 1 second
local function teleportAndFollow(target)
    local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    local backOffset = targetHRP.CFrame.LookVector * 3
    local followTime = 0.5
    local start = tick()

    RunService.RenderStepped:Connect(function()
        if tick() - start > followTime then return end
        if targetHRP.Parent and Character and Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = Character:FindFirstChild("HumanoidRootPart")
            myHRP.CFrame = CFrame.new(targetHRP.Position - backOffset, targetHRP.Position)
        end
    end)
end

-- Input listeners
UIS.InputBegan:Connect(function(input, typing)
    if typing then return end

    if input.KeyCode == Enum.KeyCode.X then
        if not lockOn then
            local target = getClosestAlivePlayer()
            if target then
                lockedTarget = target
                lockOn = true
                notify("Lock-On ON")
            end
        else
            lockOn = false
            lockedTarget = nil
            notify("Lock-On OFF")
        end

    elseif input.KeyCode == Enum.KeyCode.R then
        local target = (lockOn and lockedTarget) or getClosestAlivePlayer()
        if target then
            teleportAndFollow(target)
        end
    end
end)
