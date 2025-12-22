-- hidden fling (MAX POWER + 100% SAFE AFTER)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

local hiddenfling = false
local targetHRP
local oldCF
local busy = false

local FLING_VELOCITY_THRESHOLD = 250 -- when target counts as flung
local MAX_ATTACK_TIME = 3 -- failsafe seconds

-- detection junk
if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
	local d = Instance.new("Decal")
	d.Name = "juisdfj0i32i0eidsuf0iok"
	d.Parent = ReplicatedStorage
end

-- closest to mouse
local function getTarget()
	local cam = workspace.CurrentCamera
	local closest, dist = nil, math.huge

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = p.Character.HumanoidRootPart
			local pos, on = cam:WorldToViewportPoint(hrp.Position)
			if on then
				local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
				if d < dist then
					dist = d
					closest = hrp
				end
			end
		end
	end
	return closest
end

-- P key
UserInputService.InputBegan:Connect(function(input, gp)
	if gp or busy then return end
	if input.KeyCode ~= Enum.KeyCode.P then return end

	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	targetHRP = getTarget()
	if not targetHRP then return end

	busy = true
	oldCF = hrp.CFrame
	hiddenfling = true

	task.delay(1, function()
		local start = tick()
		local flung = false

		-- AGGRESSIVE ORBIT UNTIL TARGET FLUNG
		while hiddenfling and targetHRP and targetHRP.Parent do
			local t = tick() * 70
			local offset = Vector3.new(
				math.cos(t) * 1.5,
				math.sin(t * 2) * 1.0,
				math.sin(t) * 1.5
			)
			hrp.CFrame = targetHRP.CFrame * CFrame.new(offset)

			if targetHRP.AssemblyLinearVelocity.Magnitude > FLING_VELOCITY_THRESHOLD then
				flung = true
				break
			end

			if tick() - start > MAX_ATTACK_TIME then
				break
			end

			RunService.Heartbeat:Wait()
		end

		-- RETURN + SAFE
		if hrp then
			hiddenfling = false
			hrp.CFrame = oldCF
			hrp.Velocity = Vector3.new(0,0,0)
			hrp.Anchored = true -- anchor so you don’t get flung
			task.delay(1.5, function()
				if hrp then
					hrp.Anchored = false
				end
				busy = false
			end)
		end
	end)
end)

-- ===============================
-- === FLING CORE (MAX POWER) ===
-- ===============================
local function fling()
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
				hrp.Velocity = vel * 500000 + Vector3.new(0, 200000, 0) -- MAX POWER

				RunService.RenderStepped:Wait()
				if hrp and hrp.Parent then
					hrp.Velocity = vel
				end

				RunService.Stepped:Wait()
				if hrp and hrp.Parent then
					hrp.Velocity = vel + Vector3.new(0, movel, 0)
					movel = movel * -1
				end
			end
		end
	end
end

fling()
