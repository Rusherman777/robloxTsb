-- LocalScript
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Variables
local lockOn = false
local lockedTarget = nil
local potentialTargets = {}
local followConnection = nil

-- Notification
local function notify(text)
    StarterGui:SetCore("SendNotification", {
        Title = "Lock-On",
        Text = text,
        Duration = 0.5
    })
end

-- Update character reference on respawn
Player.CharacterAdded:Connect(function(char)
    Character = char
end)

----------------------------------------------------
-- TARGET SYSTEM (ANTI-LAG, CACHED)
----------------------------------------------------

local function isValidTarget(model)
    if not model or model == Character then return false end

    local hum = model:FindFirstChildWhichIsA("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")

    if hum and hrp and hum.Health > 0 then
        return true
    end

    return false
end

local function addTarget(model)
    if isValidTarget(model) then
        potentialTargets[model] = true
    end
end

local function removeTarget(model)
    potentialTargets[model] = nil
end

-- Initial scan (runs once)
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Model") and obj:FindFirstChildWhichIsA("Humanoid") then
        addTarget(obj)
    end
end

-- Track new NPCs / players
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        task.defer(function()
            addTarget(obj)
        end)
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("Model") then
        removeTarget(obj)
    end
end)

-- Get closest cached target
local function getClosestAliveTarget()
    local myHRP = Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local closest = nil
    local shortestDist = math.huge

    for model in pairs(potentialTargets) do
        if isValidTarget(model) then
            local hrp = model:FindFirstChild("HumanoidRootPart")
            local dist = (hrp.Position - myHRP.Position).Magnitude

            if dist < shortestDist then
                shortestDist = dist
                closest = model
            end
        else
            potentialTargets[model] = nil
        end
    end

    return closest
end

----------------------------------------------------
-- LOCK-ON CAMERA
----------------------------------------------------

RunService.RenderStepped:Connect(function()
    if not lockOn then return end

    if not isValidTarget(lockedTarget) then
        lockedTarget = getClosestAliveTarget()
        if not lockedTarget then
            lockOn = false
            notify("Lock-On OFF")
            return
        end
    end

    local targetHRP = lockedTarget:FindFirstChild("HumanoidRootPart")
    if targetHRP then
        workspace.CurrentCamera.CFrame =
            CFrame.new(workspace.CurrentCamera.CFrame.Position, targetHRP.Position)
    end
end)

----------------------------------------------------
-- TELEPORT + FOLLOW (NO MEMORY LEAK)
----------------------------------------------------

local function teleportAndFollow(target)
    if not isValidTarget(target) then return end

    local targetHRP = target:FindFirstChild("HumanoidRootPart")
    local myHRP = Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then return end

    local backOffset = targetHRP.CFrame.LookVector * 3
    local followTime = 0.5
    local start = tick()

    -- disconnect old connection if exists
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end

    followConnection = RunService.RenderStepped:Connect(function()
        if tick() - start > followTime then
            followConnection:Disconnect()
            followConnection = nil
            return
        end

        if isValidTarget(target) and Character:FindFirstChild("HumanoidRootPart") then
            myHRP.CFrame =
                CFrame.new(targetHRP.Position - backOffset, targetHRP.Position)
        end
    end)
end

----------------------------------------------------
-- INPUT
----------------------------------------------------

UIS.InputBegan:Connect(function(input, typing)
    if typing then return end

    if input.KeyCode == Enum.KeyCode.X then
        if not lockOn then
            local target = getClosestAliveTarget()
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
        local target = (lockOn and lockedTarget) or getClosestAliveTarget()
        if target then
            teleportAndFollow(target)
        end
    end
end)
