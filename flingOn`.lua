-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local lp = Players.LocalPlayer

local flingActive = false
local flingForce = 1e8

local character = nil
local hrp = nil

-- Safe notification
local function notify(message)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Fling",
			Text = message,
			Duration = 0.5
		})
	end)
end

-- Character handler (runs on spawn & respawn)
local function onCharacterAdded(char)
	character = char
	hrp = nil

	-- wait for HRP safely
	task.spawn(function()
		local root = char:WaitForChild("HumanoidRootPart", 10)
		if root then
			hrp = root
		end
	end)
end

-- Bind existing & future characters
if lp.Character then
	onCharacterAdded(lp.Character)
end
lp.CharacterAdded:Connect(onCharacterAdded)

-- Fling loop (death-safe)
RunService.Heartbeat:Connect(function()
	if not flingActive then return end
	if not hrp or not hrp.Parent then return end

	local vel = hrp.AssemblyLinearVelocity
	hrp.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, flingForce, 0)

	RunService.RenderStepped:Wait()

	if hrp and hrp.Parent then
		hrp.AssemblyLinearVelocity = vel
	end
end)

-- Toggle fling with `
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard
		and input.KeyCode == Enum.KeyCode.Backquote then

		flingActive = not flingActive
		notify(flingActive and "ON" or "OFF")
	end
end)
