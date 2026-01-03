local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURATION
local MAIN_COLOR = Color3.fromRGB(130, 0, 255) -- Electric Purple
local SUB_COLOR = Color3.fromRGB(0, 255, 255)  -- Cyan
local GUN_COOLDOWN = 0.8 -- Slightly slower because the effect is heavy

-- HELPER: Create the Black Hole Consumption Effect
local function blackHoleDeath(targetModel, position)
	-- 1. Freeze the victim
	local root = targetModel:FindFirstChild("HumanoidRootPart")
	if root then 
		root.Anchored = true 
	end

	-- 2. Spawn Black Hole Sphere
	local hole = Instance.new("Part")
	hole.Shape = Enum.PartType.Ball
	hole.Color = Color3.new(0,0,0) -- Pitch Black
	hole.Material = Enum.Material.Neon
	hole.Size = Vector3.new(1,1,1)
	hole.Position = position
	hole.Anchored = true
	hole.CanCollide = false
	hole.Parent = workspace

	-- 3. Add Suck Particles
	local suck = Instance.new("ParticleEmitter")
	suck.Texture = "rbxassetid://243661804" -- Ring texture
	suck.Color = ColorSequence.new(MAIN_COLOR)
	suck.Size = NumberSequence.new(5, 0) -- Big to small
	suck.Rate = 50
	suck.Lifetime = NumberRange.new(0.5)
	suck.Speed = NumberRange.new(-10) -- Sucks INWARDS
	suck.Parent = hole

	-- 4. Sound: Implosion
	local sfx = Instance.new("Sound")
	sfx.SoundId = "rbxassetid://1358047020" -- Deep Sci-Fi Hum
	sfx.Volume = 3
	sfx.Parent = hole
	sfx:Play()

	-- 5. ANIMATION: Expand hole, then delete player, then shrink hole
	-- Grow Phase
	local growTween = TweenService:Create(hole, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = Vector3.new(8, 8, 8)})
	growTween:Play()
	wait(0.5)
	
	-- VANISH PLAYER
	targetModel:Destroy()
	
	-- Shrink Phase (Pop out of existence)
	local shrinkTween = TweenService:Create(hole, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = Vector3.new(0, 0, 0)})
	shrinkTween:Play()
	Debris:AddItem(hole, 0.2)
end

local function giveGun(player)
	-- 1. SETUP TOOL
	local tool = Instance.new("Tool")
	tool.Name = "Cosmic Eraser"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool.Grip = CFrame.new(0, -0.2, 0.8)

	-- 2. SETUP HANDLE
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1, 1, 3)
	handle.CanCollide = false
	handle.Transparency = 1 -- Hide the brick, show the mesh
	handle.Parent = tool
	
	-- COMPLEX MESH (Alien Weaponry)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshId = "http://www.roblox.com/asset/?id=94690081" -- Alien Gun
	mesh.TextureId = "http://www.roblox.com/asset/?id=94689539"
	mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
	mesh.Parent = handle
	
	-- IDLE PARTICLES (Orbiting Energy)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxassetid://242292318" -- Sparkle
	emitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, MAIN_COLOR),
		ColorSequenceKeypoint.new(1, SUB_COLOR)
	})
	emitter.Size = NumberSequence.new(0.5, 0)
	emitter.Lifetime = NumberRange.new(0.5)
	emitter.Rate = 10
	emitter.Speed = NumberRange.new(0)
	emitter.Parent = handle

	-- ATTACHMENTS FOR HELIX BEAM
	local att0 = Instance.new("Attachment")
	att0.Position = Vector3.new(0, 0.2, -1.5) -- Gun Tip
	att0.Parent = handle

	local debounce = false

	-- 3. SHOOTING LOGIC
	tool.Activated:Connect(function()
		if debounce then return end
		debounce = true

		local char = tool.Parent
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then debounce = false return end

		-- SOUND: Heavy Charge & Blast
		local blastSfx = Instance.new("Sound")
		blastSfx.SoundId = "rbxassetid://200632875" -- Futuristic Blast
		blastSfx.Volume = 2
		blastSfx.Pitch = 0.8 -- Deep sound
		blastSfx.Parent = handle
		blastSfx:Play()
		Debris:AddItem(blastSfx, 2)

		-- CALCULATION
		local origin = handle.Position
		local direction = root.CFrame.LookVector * 2000
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {char}
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		local result = workspace:Raycast(origin, direction, rayParams)
		local endPos = result and result.Position or (origin + direction)

		-- VISUALS: THE HELIX BEAM (Two beams wrapping)
		local beamTargetPart = Instance.new("Part")
		beamTargetPart.Transparency = 1
		beamTargetPart.Anchored = true
		beamTargetPart.CanCollide = false
		beamTargetPart.Position = endPos
		beamTargetPart.Parent = workspace
		Debris:AddItem(beamTargetPart, 0.5)
		
		local att1 = Instance.new("Attachment")
		att1.Parent = beamTargetPart

		-- Beam 1 (Purple Spiral)
		local beam1 = Instance.new("Beam")
		beam1.Texture = "rbxassetid://446111271"
		beam1.Color = ColorSequence.new(MAIN_COLOR)
		beam1.Width0 = 1
		beam1.Width1 = 1
		beam1.CurveSize0 = 5 -- This makes it curve/spiral
		beam1.CurveSize1 = -5
		beam1.FaceCamera = true
		beam1.Attachment0 = att0
		beam1.Attachment1 = att1
		beam1.TextureSpeed = 5
		beam1.Parent = beamTargetPart

		-- Beam 2 (Cyan Spiral - Reverse Curve)
		local beam2 = Instance.new("Beam")
		beam2.Texture = "rbxassetid://446111271"
		beam2.Color = ColorSequence.new(SUB_COLOR)
		beam2.Width0 = 1
		beam2.Width1 = 1
		beam2.CurveSize0 = -5 -- Reverse curve to create helix
		beam2.CurveSize1 = 5
		beam2.FaceCamera = true
		beam2.Attachment0 = att0
		beam2.Attachment1 = att1
		beam2.TextureSpeed = 5
		beam2.Parent = beamTargetPart
		
		-- ANIMATE BEAMS FADING
		game:GetService("TweenService"):Create(beam1, TweenInfo.new(0.5), {Width0 = 0, Width1 = 0}):Play()
		game:GetService("TweenService"):Create(beam2, TweenInfo.new(0.5), {Width0 = 0, Width1 = 0}):Play()

		-- IMPACT LOGIC
		if result and result.Instance then
			local hitModel = result.Instance.Parent
			local humanoid = hitModel:FindFirstChild("Humanoid")
			
			if humanoid then
				-- Trigger the Black Hole Effect
				blackHoleDeath(hitModel, endPos)
			else
				-- Just sparks if we hit a wall
				local spark = Instance.new("ParticleEmitter")
				spark.Parent = beamTargetPart
				spark.Texture = "rbxassetid://242292318"
				spark.Lifetime = NumberRange.new(0.5)
				spark.Rate = 0
				spark:Emit(20)
			end
		end

		wait(GUN_COOLDOWN)
		debounce = false
	end)

	tool.Parent = player.Backpack
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		giveGun(player)
	end)
end)
