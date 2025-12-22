-- FLING ALL PLAYERS LOCALSCRIPT (MAX POWER + SAFE AFTER + NOTIFICATION)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local lp = Players.LocalPlayer

local hiddenfling = false
local busy = false
local oldCF

local FLING_VELOCITY_THRESHOLD = 250 -- counts as flung
local MAX_ATTACK_TIME = 3 -- failsafe per player

-- detection junk
if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
	local d = Instance.new("Decal")
	d.Name = "juisdfj0i32i0eidsuf0iok"
	d.Parent = ReplicatedStorage
end

-- FLING CORE (MAX POWER)
local function flingCore()
	local hrp, c, vel, movel = nil, nil, nil, 0.1
	while true do
		RunService.Heartbeat:Wait()
		if hiddenfling then
			while hiddenfling and not (c and c.Parent and hrp and hrp.Parent) do
				RunService.Heartbeat:Wait()
				c = lp.Character
				hrp = c and c:FindFirstChild("HumanoidRootPart")
			end
			if hiddenfling and hrp then
				vel = hrp.Velocity
				hrp.Velocity = vel * 50000 + Vector3.new(0,20000,0)
				RunService.RenderStepped:Wait()
				if hrp and hrp.Parent then hrp.Velocity = vel end
				RunService.Stepped:Wait()
				if hrp and hrp.Parent then
					hrp.Velocity = vel + Vector3.new(0,movel,0)
					movel = movel * -1
				end
			end
		end
	end
end
task.spawn(flingCore)

-- closest player (unused for notification)
local function getTarget()
	local cam = workspace.CurrentCamera
	local closest, dist = nil, math.huge

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = p.Character.HumanoidRootPart
			local pos, on = cam:WorldToViewportPoint(hrp.Position)
			if on then
				local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)).Magnitude
				if d < dist then
					dist = d
					closest = hrp
				end
			end
		end
	end
	return closest
end

-- P KEYBIND
UserInputService.InputBegan:Connect(function(input, gp)
	if gp or busy then return end
	if input.KeyCode ~= Enum.KeyCode.P then return end

	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	oldCF = hrp.CFrame
	hiddenfling = true
	busy = true

	-- Send classic Roblox notification
	StarterGui:SetCore("SendNotification", {
		Title = "Fling Activated",
		Text = "Flinging all players!",
		Duration = 0.5
	})

	task.spawn(function()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local targetHRP = plr.Character.HumanoidRootPart
				local start = tick()
				local flung = false

				while hiddenfling and targetHRP and targetHRP.Parent do
					local t = tick() * 70
					local offset = Vector3.new(
						math.cos(t)*1.5,
						math.sin(t*2)*1.0,
						math.sin(t)*1.5
					)
					hrp.CFrame = targetHRP.CFrame * CFrame.new(offset)

					-- CHECK FLUNG
					if targetHRP.AssemblyLinearVelocity.Magnitude > FLING_VELOCITY_THRESHOLD then
						flung = true
						break
					end

					-- FAILSAFE
					if tick()-start > MAX_ATTACK_TIME then
						break
					end

					RunService.Heartbeat:Wait()
				end
			end
		end

		-- RETURN TO ORIGINAL POSITION + SAFE
		if hrp then
			hiddenfling = false
			hrp.CFrame = oldCF
			hrp.Velocity = Vector3.new(0,0,0)
			hrp.Anchored = true
			task.delay(1.5,function()
				if hrp then hrp.Anchored = false end
				busy = false
			end)
		end
	end)
end)
