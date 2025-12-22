-- LocalScript (StarterPlayerScripts)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimationTrackerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 550)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

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
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "Animations Tracker"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Parent = mainFrame

-- Search box
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 60)
searchBox.PlaceholderText = "Search players..."
searchBox.Text = ""
searchBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 18
searchBox.Parent = mainFrame
local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = searchBox

-- Scroll frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -110)
scrollFrame.Position = UDim2.new(0, 10, 0, 100)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.Parent = scrollFrame

-- Table to save detected animations
local detectedAnimations = {} -- {playerName = {animId = {Name = animName, Button = btn}}}

-- Function to copy to clipboard
local function copyToClipboard(text)
	pcall(function()
		setclipboard(text)
	end)
end

-- Update ScrollFrame CanvasSize
local function updateCanvasSize()
	local layout = scrollFrame:FindFirstChildWhichIsA("UIListLayout")
	if layout then
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end
end

-- Function to create animation button with player image
local function createAnimationButton(plr, animName, animId)
	detectedAnimations[plr.Name] = detectedAnimations[plr.Name] or {}
	if detectedAnimations[plr.Name][animId] then return end -- Prevent duplicates per player

	local btn = Instance.new("Frame")
	btn.Size = UDim2.new(1, 0, 0, 50)
	btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	btn.Parent = scrollFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	-- Player image
	local img = Instance.new("ImageLabel")
	img.Size = UDim2.new(0, 40, 0, 40)
	img.Position = UDim2.new(0, 5, 0.5, -20)
	img.BackgroundTransparency = 1
	img.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
	img.Parent = btn

	-- Animation text
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -55, 1, 0)
	textLabel.Position = UDim2.new(0, 50, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = animName.." | ID: "..animId
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextSize = 16
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = btn

	-- Hover effect
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(75, 75, 75)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
	end)

	-- Click to copy only numeric ID
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local id = animId
			if id:sub(1,12) == "rbxassetid://" then
				id = id:sub(13)
			end
			copyToClipboard(id)
			btn.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
			wait(0.3)
			btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		end
	end)

	detectedAnimations[plr.Name][animId] = {Name = animName, Button = btn}

	updateCanvasSize() -- Update canvas to allow scrolling
end

-- Function to scan all players' animations
local function scanAnimations()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character then
			local humanoid = plr.Character:FindFirstChildWhichIsA("Humanoid")
			if humanoid then
				local animator = humanoid:FindFirstChildWhichIsA("Animator")
				if animator then
					for _, track in pairs(animator:GetPlayingAnimationTracks()) do
						local animId = track.Animation.AnimationId
						local animName = track.Name
						createAnimationButton(plr, animName, animId)
					end
				end
			end
		end
	end
end

-- Infinite scanning
spawn(function()
	while true do
		scanAnimations()
		wait(1)
	end
end)

-- Search function
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local text = searchBox.Text:lower()
	for _, plrData in pairs(detectedAnimations) do
		for _, info in pairs(plrData) do
			local btn = info.Button
			if string.find(btn.TextLabel.Text:lower(), text) then
				btn.Visible = true
			else
				btn.Visible = false
			end
		end
	end
end)

-- ESC to toggle GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Escape then
		screenGui.Enabled = not screenGui.Enabled
	end
end)
