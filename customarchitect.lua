
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
	Title = "Custom Architect",
	Text = "Made By Velocity",
	Duration = 5
})


-- ====================================
-- COLOR DEFINITIONS
-- ====================================

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

local selectedColor = COLOR_PRESETS[CUSTOM_COLOR] or Color3.fromRGB(0, 162, 255)


-- ====================================
-- CORE VARIABLES
-- ====================================

local rs = game:GetService("ReplicatedStorage")
local plr = game:GetService("Players").LocalPlayer
local hum = (plr.Character or plr.CharacterAdded:Wait()):WaitForChild("Humanoid")
local event = rs.RemotesFolder.DeathHint


-- ====================================
-- DEATH HINT LOOP
-- ====================================

task.spawn(function()
	while task.wait(3) do
		firesignal(event.OnClientEvent, HINTS, HINTS_COLOR)
	end
end)


-- ====================================
-- UNIVERSAL MODEL KILL LOGIC
-- ====================================

local function connectPromptInstance(prompt)
	if not prompt or not prompt:IsA("ProximityPrompt") then return end
	if prompt:GetAttribute and prompt:GetAttribute("CA_Connected") then return end

	prompt.Triggered:Connect(function(playerWhoTriggered)
		if playerWhoTriggered == plr then
			hum.Health = 0
		end
	end)

	if prompt.SetAttribute then
		prompt:SetAttribute("CA_Connected", true)
	end
end

local function scanModelForPrompts(model)
	if not model or not model:IsA("Model") then return end
	if model.Name ~= KILL_MODEL_NAME then return end

	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("ProximityPrompt") then
			connectPromptInstance(desc)
		end
	end
end

for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("Model") and obj.Name == KILL_MODEL_NAME then
		scanModelForPrompts(obj)
	elseif obj:IsA("ProximityPrompt") then
		local anc = obj:FindFirstAncestorWhichIsA and obj:FindFirstAncestorWhichIsA("Model")
		if anc and anc.Name == KILL_MODEL_NAME then
			connectPromptInstance(obj)
		end
	end
end

workspace.DescendantAdded:Connect(function(desc)
	if desc:IsA("Model") then
		scanModelForPrompts(desc)
	elseif desc:IsA("ProximityPrompt") then
		local anc = desc:FindFirstAncestorWhichIsA and desc:FindFirstAncestorWhichIsA("Model")
		if anc and anc.Name == KILL_MODEL_NAME then
			connectPromptInstance(desc)
		end
	end
end)


-- ====================================
-- VISUAL RECOLOR FUNCTIONS
-- ====================================

local function recolorParticle(particle)
	if particle and particle:IsA("ParticleEmitter") then
		local bright = Color3.new(
			math.clamp(selectedColor.R * 1.2, 0, 1),
			math.clamp(selectedColor.G * 1.2, 0, 1),
			math.clamp(selectedColor.B * 1.2, 0, 1)
		)

		particle.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, selectedColor),
			ColorSequenceKeypoint.new(0.5, bright),
			ColorSequenceKeypoint.new(1, selectedColor)
		}

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
	if not bg then return end

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
			if spotlight then recolorLight(spotlight) end
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


-- ====================================
-- UI COLOR CUSTOMIZATION - HELPFUL DIALOGUE
-- ====================================

task.spawn(function()
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local RunService = game:GetService("RunService")

	local function lightenColor(color, factor)
		return Color3.new(
			color.R + (1 - color.R) * factor,
			color.G + (1 - color.G) * factor,
			color.B + (1 - color.B) * factor
		)
	end

	local function applyToHelpful(lbl)
		if not lbl or not lbl:IsA("TextLabel") then return end

		local lighter = lightenColor(selectedColor, HELPFUL_LIGHTEN_FACTOR)
		pcall(function()
			lbl.TextColor3 = lighter
			lbl.TextTransparency = 0
		end)

		local ug = lbl:FindFirstChildOfClass("UIGradient")
		if ug then
			pcall(function()
				ug.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, lighter), ColorSequenceKeypoint.new(1, lighter) })
			end)
		end

		local us = lbl:FindFirstChildOfClass("UIStroke")
		if us then
			pcall(function()
				us.Color = selectedColor
				us.Transparency = 0
				us.Thickness = us.Thickness or 1
			end)
		end
	end

	local function findAndApply()
		if not player or not player:FindFirstChild("PlayerGui") then return false end
		local pg = player.PlayerGui
		local mainUI = pg:FindFirstChild("MainUI")
		if not mainUI then return false end
		local deathUI = mainUI:FindFirstChild("Death")
		if not deathUI then return false end
		local helpful = deathUI:FindFirstChild("HelpfulDialogue")
		if helpful and helpful:IsA("TextLabel") then
			applyToHelpful(helpful)
			return true
		end
		return false
	end

	if findAndApply() then return end

	local function descendantListener(desc)
		if not desc or not desc:IsA("TextLabel") then return end
		if desc.Name == "HelpfulDialogue" then
			local anc = desc:FindFirstAncestor("Death")
			if anc and anc.Parent and anc.Parent.Name == "MainUI" then
				applyToHelpful(desc)
			end
		end
	end

	pcall(function()
		player.PlayerGui.DescendantAdded:Connect(descendantListener)
	end)

	task.spawn(function()
		for i = 1, 8 do
			task.wait(0.5)
			if findAndApply() then return end
		end
	end)
end)

print("Selected Color:", CUSTOM_COLOR)
print("Kill Model:", KILL_MODEL_NAME)
print("Moon Texture:", MOON_TEXTURE_ID)
print("Moon LightEmission:", MOON_LIGHT_EMISSION)
print("Helpful Light Factor:", HELPFUL_LIGHTEN_FACTOR)


