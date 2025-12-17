-- LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local liveFolder = workspace:WaitForChild("Live")

-------------------------------------------------
-- GUI SETUP
-------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AccessoryScreenGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local function createBox(position)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(0.26, 0.32)
	frame.Position = position
	frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	frame.BackgroundTransparency = 0.05
	frame.Parent = screenGui

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 18)

	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(0, 255, 170)
	stroke.Thickness = 1.2
	stroke.Transparency = 0.3

	local gradient = Instance.new("UIGradient", frame)
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(25,25,35)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,15))
	}

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -10, 0, 30)
	title.Position = UDim2.new(0, 5, 0, 5)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(255,255,255)
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.Text = "TITLE"
	title.Parent = frame

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1, -10, 0, 20)
	subtitle.Position = UDim2.new(0, 5, 0, 35)
	subtitle.BackgroundTransparency = 1
	subtitle.TextColor3 = Color3.fromRGB(0,255,170)
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextScaled = true
	subtitle.Text = ""
	subtitle.Parent = frame

	local list = Instance.new("Frame")
	list.Size = UDim2.new(1, -10, 1, -65)
	list.Position = UDim2.new(0, 5, 0, 60)
	list.BackgroundTransparency = 1
	list.Parent = frame

	local layout = Instance.new("UIListLayout", list)
	layout.Padding = UDim.new(0, 4)

	return frame, title, subtitle, list
end

-- LEFT (YOU)
local leftFrame, leftTitle, _, leftList =
	createBox(UDim2.fromScale(0.02, 0.66))

-- RIGHT (CLOSEST)
local rightFrame, rightTitle, rightSubtitle, rightList =
	createBox(UDim2.fromScale(0.72, 0.66))

-------------------------------------------------
-- ACCESSORY DISPLAY
-------------------------------------------------
local function updateAccessories(characterModel, listFrame)
	for _, c in ipairs(listFrame:GetChildren()) do
		if c:IsA("TextLabel") then
			c:Destroy()
		end
	end
	if not characterModel then return end

	for _, obj in ipairs(characterModel:GetChildren()) do
		if obj:IsA("Accessory") then
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -8, 0, 22)
			label.BackgroundTransparency = 1
			label.Text = "• "..obj.Name
			label.TextColor3 = Color3.fromRGB(0, 255, 170)
			label.Font = Enum.Font.GothamBold
			label.TextScaled = true
			label.Parent = listFrame
		end
	end
end

-------------------------------------------------
-- BEAM (LINE) SETUP
-------------------------------------------------
local att0 = Instance.new("Attachment")
local att1 = Instance.new("Attachment")

local beam = Instance.new("Beam")
beam.Attachment0 = att0
beam.Attachment1 = att1
beam.Width0 = 0.15
beam.Width1 = 0.15
beam.FaceCamera = true
beam.Color = ColorSequence.new(Color3.fromRGB(0,255,170))
beam.Transparency = NumberSequence.new(0.15)
beam.Parent = workspace

-------------------------------------------------
-- CLOSEST PLAYER
-------------------------------------------------
local function getClosestCharacter()
	local myChar = liveFolder:FindFirstChild(player.Name)
	if not myChar then return end

	local myHRP = myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end

	local closest, dist

	for _, model in ipairs(liveFolder:GetChildren()) do
		if model.Name ~= player.Name then
			local hrp = model:FindFirstChild("HumanoidRootPart")
			if hrp then
				local d = (hrp.Position - myHRP.Position).Magnitude
				if not dist or d < dist then
					dist = d
					closest = model
				end
			end
		end
	end

	return closest, dist
end

-------------------------------------------------
-- MAIN LOOP
-------------------------------------------------
RunService.RenderStepped:Connect(function()
	local myChar = liveFolder:FindFirstChild(player.Name)
	leftTitle.Text = player.Name.." (You)"
	updateAccessories(myChar, leftList)

	local closest, dist = getClosestCharacter()
	if closest and dist then
		rightTitle.Text = closest.Name.." (Closest)"
		rightSubtitle.Text = string.format("Distance: %.1f studs", dist)

		updateAccessories(closest, rightList)

		local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
		local otherHRP = closest:FindFirstChild("HumanoidRootPart")

		if myHRP and otherHRP then
			att0.Parent = myHRP
			att1.Parent = otherHRP
			beam.Enabled = true
		end
	else
		rightTitle.Text = "No Player Nearby"
		rightSubtitle.Text = ""
		updateAccessories(nil, rightList)
		beam.Enabled = false
	end
end)
