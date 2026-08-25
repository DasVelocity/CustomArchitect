# Custom Architect API

A small configurable loader for Custom Architect.

## Usage

Put `main.lua` in your executor, then fill in the configs to your liking:

```lua
local CustomArchitect = loadstring(game:HttpGet("YOUR_RAW_GITHUB_LINK"))()

CustomArchitect({
	CUSTOM_COLOR = "Violet",
	KILL_MODEL_NAME = "None",
	MOON_TEXTURE_ID = "rbxassetid://10867606165",
	MOON_LIGHT_EMISSION = 0.01,
	HELPFUL_LIGHTEN_FACTOR = 0.5,
	HINTS = {
		"You died to witherstorm",
		"you are actually trash bruh"
	},
	HINTS_COLOR = "Blue"
})
```

That's it. Change the values inside the table to customize it and execute it.

## Colors

Examples: `Blue`, `Violet`, `Pink`, `Red`, `Green`, `Cyan`, `Gold`, `Teal`, `White`, `Black`.

If an invalid color is used, it falls back to `Blue`.

Made by Velocity
