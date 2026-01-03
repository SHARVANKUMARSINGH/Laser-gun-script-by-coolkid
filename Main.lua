local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- This function makes the gun and gives it to the player
local function giveGun(player)
	-- 1. Create the Tool
	local tool = Instance.new("Tool")
	tool.Name = "Vanish Laser"
	tool.RequiresHandle = true
	tool.CanBeDropped = false

	-- 2. Create the Handle (The Gun visuals)
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.4, 0.4, 2)
	handle.BrickColor = BrickColor.new("Really red")
	handle.Material = Enum.Material.Neon
	handle.Parent = tool

	-- 3. The Logic (What happens when you click)
	tool.Activated:Connect(function()
		local char = tool.Parent
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		-- SHOOTING: Shoots straight where your character is facing
		local origin = handle.Position
		local direction = root.CFrame.LookVector * 500 -- 500 studs range

		-- Check what we hit
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {char} -- Don't hit yourself
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		local result = workspace:Raycast(origin, direction, rayParams)

		-- Calculate where the beam ends
		local endPos = result and result.Position or (origin + direction)

		-- VISUALS: Create the Laser Beam (Seen by everyone)
		local beam = Instance.new("Part")
		beam.Anchored = true
		beam.CanCollide = false
		beam.Material = Enum.Material.Neon
		beam.Color = Color3.fromRGB(255, 0, 0) -- Red Beam
		beam.Size = Vector3.new(0.2, 0.2, (origin - endPos).Magnitude)
		beam.CFrame = CFrame.lookAt(origin:Lerp(endPos, 0.5), endPos)
		beam.Parent = workspace
		
		-- Delete beam after 0.1 seconds
		Debris:AddItem(beam, 0.1)

		-- KILL LOGIC: If we hit a player, DESTROY them (Vanish)
		if result and result.Instance then
			local hitModel = result.Instance.Parent
			local humanoid = hitModel:FindFirstChild("Humanoid")
			
			if humanoid then
				-- This makes them disappear instantly
				hitModel:Destroy()
			end
		end
	end)

	tool.Parent = player.Backpack
end

-- Give the gun to everyone when they spawn
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		giveGun(player)
	end)
end)
