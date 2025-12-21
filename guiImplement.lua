-- LocalScript : Status Attribute Viewer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatusAttributesGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local attributeText = Instance.new("TextLabel")
attributeText.Size = UDim2.new(0, 300, 0, 200)
attributeText.Position = UDim2.new(0, 10, 1, -210) -- bottom left
attributeText.BackgroundTransparency = 1
attributeText.TextColor3 = Color3.fromRGB(0, 255, 170)
attributeText.TextScaled = true
attributeText.Font = Enum.Font.GothamBold
attributeText.TextXAlignment = Enum.TextXAlignment.Left
attributeText.TextYAlignment = Enum.TextYAlignment.Top
attributeText.Parent = screenGui

-- Function to get or wait for character
local function getCharacter()
	if not character or not character.Parent then
		character = player.Character or player.CharacterAdded:Wait()
	end
	return character
end

-- Main update loop
RunService.RenderStepped:Connect(function()
	local char = getCharacter()
	local status = char:FindFirstChild("status")
	if status then
		local textLines = {}
		for _, attrName in ipairs(status:GetAttributes()) do
			local value = status:GetAttribute(attrName)
			table.insert(textLines, string.format("%s : %s", attrName, tostring(value)))
		end

		attributeText.Text = table.concat(textLines, "\n")
	else
		-- If status value doesn't exist, clear text
		attributeText.Text = ""
	end
end)
