-- LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Character = nil

-------------------------------------------------
-- CHARACTER HANDLING (SURVIVES DEATH)
-------------------------------------------------
local function onCharacterAdded(char)
	Character = char
end

Player.CharacterAdded:Connect(onCharacterAdded)
if Player.Character then
	onCharacterAdded(Player.Character)
end

-------------------------------------------------
-- GET CLOSEST ALIVE PLAYER (REAL-TIME)
-------------------------------------------------
local function getClosestAlivePlayer()
	if not Character then return nil end

	local myHRP = Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return nil end

	local closest = nil
	local shortestDist = math.huge

	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= Player and other.Character then
			local hum = other.Character:FindFirstChildWhichIsA("Humanoid")
			local hrp = other.Character:FindFirstChild("HumanoidRootPart")

			if hum and hrp and hum.Health > 0 then
				local dist = (hrp.Position - myHRP.Position).Magnitude
				if dist < shortestDist then
					shortestDist = dist
					closest = other
				end
			end
		end
	end

	return closest
end

-------------------------------------------------
-- CAMERA LOCK (ALWAYS CLOSEST)
-------------------------------------------------
RunService.RenderStepped:Connect(function()
	if not Character then return end

	local closest = getClosestAlivePlayer()
	if not closest then return end

	local targetHRP = closest.Character and closest.Character:FindFirstChild("HumanoidRootPart")
	if targetHRP then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position)
	end
end)
