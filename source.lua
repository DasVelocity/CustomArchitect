local COLOR_PRESETS = {
	Red = Color3.fromRGB(255, 0, 0),
	Orange = Color3.fromRGB(255, 165, 0),
	Yellow = Color3.fromRGB(255, 255, 0),
	Green = Color3.fromRGB(0, 255, 0),
	Lime = Color3.fromRGB(50, 205, 50),
	Cyan = Color3.fromRGB(0, 255, 255),
	Blue = Color3.fromRGB(0, 162, 255),
	Purple = Color3.fromRGB(128, 0, 128),
	Violet = Color3.fromRGB(238, 130, 238),
	Pink = Color3.fromRGB(255, 192, 203),
	Magenta = Color3.fromRGB(255, 0, 255),
	Brown = Color3.fromRGB(139, 69, 19),
	White = Color3.fromRGB(255, 255, 255),
	Gray = Color3.fromRGB(128, 128, 128),
	Black = Color3.fromRGB(10, 10, 10),
	Crimson = Color3.fromRGB(220, 20, 60),
	Coral = Color3.fromRGB(255, 127, 80),
	Teal = Color3.fromRGB(0, 128, 128),
	Indigo = Color3.fromRGB(75, 0, 130),
	Rose = Color3.fromRGB(255, 0, 127),
	Mint = Color3.fromRGB(152, 255, 152),
	Sky = Color3.fromRGB(135, 206, 235),
	Gold = Color3.fromRGB(255, 215, 0),
	Silver = Color3.fromRGB(192, 192, 192),
	Navy = Color3.fromRGB(0, 0, 128),
	Lavender = Color3.fromRGB(230, 230, 250),
	Periwinkle = Color3.fromRGB(204, 204, 255),
	Azure = Color3.fromRGB(0, 127, 255),
	Emerald = Color3.fromRGB(80, 200, 120),
	Olive = Color3.fromRGB(128, 128, 0),
	Chartreuse = Color3.fromRGB(127, 255, 0),
	Saffron = Color3.fromRGB(244, 196, 48),
	Maroon = Color3.fromRGB(128, 0, 0),
	Brick = Color3.fromRGB(178, 34, 34),
	Copper = Color3.fromRGB(184, 115, 51),
	Bronze = Color3.fromRGB(205, 127, 50),
	Charcoal = Color3.fromRGB(54, 69, 79),
	Lilac = Color3.fromRGB(200, 162, 200),
	Plum = Color3.fromRGB(142, 69, 133),
	Wheat = Color3.fromRGB(245, 222, 179),
	Seashell = Color3.fromRGB(255, 245, 238),
	Turquoise = Color3.fromRGB(64, 224, 208),
	Cerulean = Color3.fromRGB(42, 82, 190),
	Scarlet = Color3.fromRGB(255, 36, 0),
	Ochre = Color3.fromRGB(204, 119, 34)
}

return function(config)
	config = config or {}

	local CUSTOM_COLOR = config.CUSTOM_COLOR or "Blue"
	local KILL_MODEL_NAME = config.KILL_MODEL_NAME or "None"
	local MOON_TEXTURE_ID = config.MOON_TEXTURE_ID or "rbxassetid://10867606165"
	local MOON_LIGHT_EMISSION = config.MOON_LIGHT_EMISSION or 0.01
	local HELPFUL_LIGHTEN_FACTOR = config.HELPFUL_LIGHTEN_FACTOR or 0.5
	local HINTS = config.HINTS or {}
	local HINTS_COLOR = config.HINTS_COLOR or "Blue"

	local selectedColor = COLOR_PRESETS[CUSTOM_COLOR] or COLOR_PRESETS.Blue
	local rs = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local plr = Players.LocalPlayer
	local hum = (plr.Character or plr.CharacterAdded:Wait()):WaitForChild("Humanoid")
	local event = rs.RemotesFolder.DeathHint
	local connectedPrompts = {}

	plr.CharacterAdded:Connect(function(character)
		hum = character:WaitForChild("Humanoid")
	end)

	task.spawn(function()
		while task.wait(3) do
			firesignal(event.OnClientEvent, HINTS, HINTS_COLOR)
		end
	end)

	local function isInsideKillModel(instance)
		local current = instance
		while current and current ~= workspace do
			if current.Name == KILL_MODEL_NAME then
				return true
			end
			current = current.Parent
		end
		return false
	end

	local function connectPrompt(v)
		if v:IsA("ProximityPrompt") and not connectedPrompts[v] and isInsideKillModel(v) then
			local connection = v.Triggered:Connect(function(p)
				if p == plr and hum then
					hum.Health = 0
				end
			end)

			connectedPrompts[v] = connection

			v.Destroying:Connect(function()
				if connectedPrompts[v] then
					connectedPrompts[v]:Disconnect()
					connectedPrompts[v] = nil
				end
			end)
		end
	end

	for _, v in ipairs(workspace:GetDescendants()) do
		connectPrompt(v)
	end

	workspace.DescendantAdded:Connect(connectPrompt)

	workspace.ChildAdded:Connect(function(child)
		if child.Name == KILL_MODEL_NAME then
			for _, desc in ipairs(child:GetDescendants()) do
				connectPrompt(desc)
			end
		end
	end)

	local function recolorParticle(particle)
		if particle and particle:IsA("ParticleEmitter") then
			local bright = Color3.new(
				math.clamp(selectedColor.R * 1.2, 0, 1),
				math.clamp(selectedColor.G * 1.2, 0, 1),
				math.clamp(selectedColor.B * 1.2, 0, 1)
			)

			particle.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, selectedColor),
				ColorSequenceKeypoint.new(0.5, bright),
				ColorSequenceKeypoint.new(1, selectedColor)
			})

			if particle.Name == "Moon" then
				particle.Texture = MOON_TEXTURE_ID
				particle.LightEmission = MOON_LIGHT_EMISSION
			end
		end
	end

	local function recolorLight(light)
		if light and (light:IsA("SpotLight") or light:IsA("PointLight")) then
			light.Color = selectedColor
		end
	end

	local function processDeathBackground(bg)
		if not bg then
			return
		end

		local lights = bg:FindFirstChild("Lights")
		local water = bg:FindFirstChild("Water")
		local fog = bg:FindFirstChild("FogAndSmaller")

		if lights then
			local bigLight = lights:FindFirstChild("BigLight")
			if bigLight then
				recolorLight(bigLight:FindFirstChild("SpotLight"))
				local attachment = bigLight:FindFirstChild("Attachment")
				if attachment then
					for _, child in ipairs(attachment:GetChildren()) do
						recolorParticle(child)
					end
				end
			end

			for _, lightPart in ipairs(lights:GetChildren()) do
				local spotlight = lightPart:FindFirstChild("SpotLight")
				if spotlight then
					recolorLight(spotlight)
				end
			end
		end

		if water then
			recolorParticle(water:FindFirstChild("WaterRays"))
		end

		if fog then
			for _, p in ipairs(fog:GetChildren()) do
				recolorParticle(p)
			end
		end
	end

	task.spawn(function()
		while task.wait(1) do
			local cam = workspace:FindFirstChild("Camera")
			if cam then
				local bg = cam:FindFirstChild("DeathBackgroundBlue")
				if bg then
					processDeathBackground(bg)
				end
			end
		end
	end)

	task.spawn(function()
		task.wait(1)
		local misc = rs:FindFirstChild("Misc")
		if misc then
			local templateBg = misc:FindFirstChild("DeathBackgroundBlue")
			if templateBg then
				processDeathBackground(templateBg)
			end
		end
	end)

	task.spawn(function()
		local function lightenColor(color, factor)
			return Color3.new(
				color.R + (1 - color.R) * factor,
				color.G + (1 - color.G) * factor,
				color.B + (1 - color.B) * factor
			)
		end

		local function applyToHelpful(lbl)
			if not lbl or not lbl:IsA("TextLabel") then
				return
			end

			local lighter = lightenColor(selectedColor, HELPFUL_LIGHTEN_FACTOR)

			pcall(function()
				lbl.TextColor3 = lighter
				lbl.TextTransparency = 0
			end)

			local ug = lbl:FindFirstChildOfClass("UIGradient")
			if ug then
				pcall(function()
					ug.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, lighter),
						ColorSequenceKeypoint.new(1, lighter)
					})
				end)
			end

			local us = lbl:FindFirstChildOfClass("UIStroke")
			if us then
				pcall(function()
					us.Color = selectedColor
					us.Transparency = 0
				end)
			end

			local function enforce()
				if not lbl.Parent then
					return
				end

				pcall(function()
					if lbl.TextColor3 ~= lighter then
						lbl.TextColor3 = lighter
					end

					local ug2 = lbl:FindFirstChildOfClass("UIGradient")
					if ug2 then
						ug2.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, lighter),
							ColorSequenceKeypoint.new(1, lighter)
						})
					end

					local us2 = lbl:FindFirstChildOfClass("UIStroke")
					if us2 then
						us2.Color = selectedColor
					end
				end)
			end

			local ok, conn = pcall(function()
				return lbl:GetPropertyChangedSignal("TextColor3"):Connect(enforce)
			end)

			if ok and conn then
				lbl.ChildAdded:Connect(function(child)
					task.wait(0.02)
					if child:IsA("UIGradient") or child:IsA("UIStroke") then
						enforce()
					end
				end)
			end

			local t0 = tick()
			local heartbeatConn
			heartbeatConn = RunService.Heartbeat:Connect(function()
				if not lbl.Parent then
					heartbeatConn:Disconnect()
					return
				end

				if tick() - t0 > 1.2 then
					heartbeatConn:Disconnect()
					return
				end

				enforce()
			end)
		end

		local function findAndApply()
			if not plr or not plr:FindFirstChild("PlayerGui") then
				return false
			end

			local mainUI = plr.PlayerGui:FindFirstChild("MainUI")
			if not mainUI then
				return false
			end

			local deathUI = mainUI:FindFirstChild("Death")
			if not deathUI then
				return false
			end

			local helpful = deathUI:FindFirstChild("HelpfulDialogue")
			if helpful and helpful:IsA("TextLabel") then
				applyToHelpful(helpful)
				return true
			end

			return false
		end

		if findAndApply() then
			return
		end

		local function descendantListener(desc)
			if not desc or not desc:IsA("TextLabel") or desc.Name ~= "HelpfulDialogue" then
				return
			end

			local anc = desc:FindFirstAncestor("Death")
			if anc and anc.Parent and anc.Parent.Name == "MainUI" then
				applyToHelpful(desc)
			end
		end

		pcall(function()
			local playerGui = plr:FindFirstChild("PlayerGui") or plr:WaitForChild("PlayerGui")
			playerGui.DescendantAdded:Connect(descendantListener)
		end)

		task.spawn(function()
			for _ = 1, 8 do
				task.wait(0.5)
				if findAndApply() then
					return
				end
			end
		end)
	end)
end
