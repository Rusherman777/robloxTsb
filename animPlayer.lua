-- LocalScript (StarterPlayerScripts)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildWhichIsA("Animator") or Instance.new("Animator", humanoid)

-- GUI setup
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CleanAnimationPlayerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 180)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Shadow effect
local shadow = Instance.new("UIStroke")
shadow.Color = Color3.fromRGB(50, 50, 50)
shadow.Thickness = 2
shadow.Parent = mainFrame

-- Draggable
local dragging, dragInput, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Animation Player"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.Parent = mainFrame

-- Animation ID Input Box
local animBox = Instance.new("TextBox")
animBox.Size = UDim2.new(1, -40, 0, 35)
animBox.Position = UDim2.new(0, 20, 0, 60)
animBox.PlaceholderText = "Enter Animation ID..."
animBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
animBox.TextColor3 = Color3.fromRGB(255, 255, 255)
animBox.Font = Enum.Font.Gotham
animBox.TextSize = 18
animBox.Parent = mainFrame

local animCorner = Instance.new("UICorner")
animCorner.CornerRadius = UDim.new(0, 8)
animCorner.Parent = animBox

-- Buttons container
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -40, 0, 50)
buttonContainer.Position = UDim2.new(0, 20, 0, 110)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

-- Play Button
local playBtn = Instance.new("TextButton")
playBtn.Size = UDim2.new(0.45, 0, 1, 0)
playBtn.Position = UDim2.new(0, 0, 0, 0)
playBtn.BackgroundColor3 = Color3.fromRGB(70, 170, 255)
playBtn.Text = "Play"
playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playBtn.Font = Enum.Font.GothamBold
playBtn.TextSize = 18
playBtn.Parent = buttonContainer

local playCorner = Instance.new("UICorner")
playCorner.CornerRadius = UDim.new(0, 8)
playCorner.Parent = playBtn

-- Stop Button
local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.45, 0, 1, 0)
stopBtn.Position = UDim2.new(0.55, 0, 0, 0)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopBtn.Text = "Stop"
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 18
stopBtn.Parent = buttonContainer

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 8)
stopCorner.Parent = stopBtn

-- Hover effects
for _, btn in pairs({playBtn, stopBtn}) do
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = btn.BackgroundColor3:lerp(Color3.fromRGB(255, 255, 255), 0.1)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = btn.BackgroundColor3:lerp(Color3.fromRGB(0,0,0),0)}):Play()
	end)
end

-- Current Animation Track
local currentTrack

-- Play animation
playBtn.MouseButton1Click:Connect(function()
	local animId = animBox.Text
	if animId ~= "" then
		if currentTrack then currentTrack:Stop() end
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://"..animId
		currentTrack = animator:LoadAnimation(anim)
		currentTrack:Play()
	end
end)

-- Stop animation
stopBtn.MouseButton1Click:Connect(function()
	if currentTrack then
		currentTrack:Stop()
		currentTrack = nil
	end
end)

-- ESC toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Escape then
		screenGui.Enabled = not screenGui.Enabled
	end
end)
