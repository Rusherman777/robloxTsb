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

----------------------------------------------------
-- Notification
----------------------------------------------------
local function notify(text)
    StarterGui:SetCore("SendNotification", {
        Title = "Lock-On",
        Text = text,
        Duration = 0.5
    })
end

----------------------------------------------------
-- Character update
----------------------------------------------------
Player.CharacterAdded:Connect(function(char)
    Character = char
end)

----------------------------------------------------
-- TARGET SYSTEM (FINAL NPC + PLAYER SUPPORT)
----------------------------------------------------

local function isValidTarget(model)
    if not model or model == Character then return false end

    local hum = model:FindFirstChildWhichIsA("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")

    return hum and hrp and hum.Health > 0
end

local function tryRegisterFromDescendant(desc)
    local model = desc:FindFirstAncestorOfClass("Model")
    if not model then return end

    if model:FindFirstChildWhichIsA("Humanoid") then
        potentialTargets[model] = true
    end
end

local function unregisterModel(model)
    potentialTargets[model] = nil
end

-- Initial scan (safe one-time)
for _, desc in ipairs(workspace:GetDescendants()) do
    if desc:IsA("Humanoid") then
        local model = desc.Parent
        if model and model:IsA("Model") then
            potentialTargets[model] = true
        end
    end
end

-- Track future NPCs anywhere in workspace
workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("Humanoid") then
        tryRegisterFromDescendant(desc)
    end
end)

workspace.DescendantRemoving:Connect(function(desc)
    if desc:IsA("Humanoid") then
        local model = desc.Parent
        if model then
            unregisterModel(model)
        end
    end
end)

-- Track player respawns
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        potentialTargets[char] = true
    end)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr.Character then
        potentialTargets[plr.Character] = true
    end

    plr.CharacterAdded:Connect(function(char)
        potentialTargets[char] = true
    end)
end

-- Get closest target
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

    -- stop old follow
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

    elseif input.KeyCode == Enum.KeyCode.T then
        local target = (lockOn and lockedTarget) or getClosestAliveTarget()
        if target then
            teleportAndFollow(target)
        end
    end
end)
