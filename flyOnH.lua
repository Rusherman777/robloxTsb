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
local speed = 200
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

-- GUI notification function
local function showNotification(text)
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Create the frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 200, 0, 40)
	frame.Position = UDim2.new(1, -210, 1, -50) -- bottom-right
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.4
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0, 0)
	frame.Parent = playerGui

	-- Text label
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(0, 255, 170)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = text
	label.Parent = frame

	-- Tween to fade out after 2.5 seconds
	game:GetService("TweenService"):Create(
		frame,
		TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
		{BackgroundTransparency = 1, Position = frame.Position + UDim2.new(0, 0, 0, 20)}
	):Play()

	-- Remove frame after 3 seconds
	delay(3, function()
		if frame then frame:Destroy() end
	end)
end

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

	showNotification("Flight ON")

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

	showNotification("Flight OFF")
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
