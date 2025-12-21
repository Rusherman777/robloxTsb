-- LocalScript : Flight (H toggle, E up, Ctrl down)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local character
local humanoid
local hrp

-------------------------------------------------
-- GUI (BOTTOM LEFT, CREATED ONLY WHEN NEEDED)
-------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "FlightStatusGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local statusLabel -- created only while flying

local function showStatus()
	if statusLabel then return end

	statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(0, 200, 0, 30)
	statusLabel.Position = UDim2.new(0, 10, 1, -40)
	statusLabel.BackgroundTransparency = 0.3
	statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	statusLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextScaled = true
	statusLabel.Text = "FLIGHT: ON"
	statusLabel.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = statusLabel
end

local function hideStatus()
	if statusLabel then
		statusLabel:Destroy()
		statusLabel = nil
	end
end

-------------------------------------------------
-- FLIGHT VARS
-------------------------------------------------
local flying = false
local speed = 200
local bodyVelocity
local bodyGyro
local flyConnection

-------------------------------------------------
-- CHARACTER SETUP (RESPAWN SAFE)
-------------------------------------------------
local function setupCharacter(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	hrp = character:WaitForChild("HumanoidRootPart")

	humanoid.Died:Connect(function()
		if flying then
			stopFlying()
		end
	end)
end

-------------------------------------------------
-- START FLYING
-------------------------------------------------
function startFlying()
	if flying or not hrp then return end
	flying = true

	showStatus()

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

-------------------------------------------------
-- STOP FLYING
-------------------------------------------------
function stopFlying()
	if not flying then return end
	flying = false

	hideStatus()

	if humanoid then
		humanoid.PlatformStand = false
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end

-------------------------------------------------
-- INIT
-------------------------------------------------
setupCharacter(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(setupCharacter)

-------------------------------------------------
-- TOGGLE WITH H
-------------------------------------------------
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
