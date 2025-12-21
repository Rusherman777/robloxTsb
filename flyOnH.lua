-- LocalScript : Flight (H toggle, E up, Ctrl down)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local character
local humanoid
local hrp

-- flight vars
local flying = false
local speed = 500
local bodyVelocity
local bodyGyro
local flyConnection

-- setup character (handles respawn)
local function setupCharacter(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
end

setupCharacter(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(setupCharacter)

-- start flying
local function startFlying()
    if flying or not hrp then return end
    flying = true

    humanoid.PlatformStand = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = hrp

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not hrp then return end

        local cam = workspace.CurrentCamera
        local moveDir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir += cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir -= cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir -= cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir += cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            moveDir += Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir -= Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            bodyVelocity.Velocity = moveDir.Unit * speed
            bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + moveDir)
        else
            bodyVelocity.Velocity = Vector3.zero
        end
    end)
end

-- stop flying
local function stopFlying()
    if not flying then return end
    flying = false

    humanoid.PlatformStand = false
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
end

-- toggle flight with H
UserInputService.InputBegan:Connect(function(input, typing)
    if typing then return end

    if input.KeyCode == Enum.KeyCode.H then
        if flying then
            stopFlying()
        else
            startFlying()
        end
    end
end)
