ZVox = ZVox or {}

ZVox.NewVoxelModel("logrot_x",[[
{
	"format_version": "1.21.6",
	"credit": "Made with Blockbench",
	"textures": {
		"0": "plus_x",
		"1": "plus_y",
		"2": "plus_z",
		"3": "minus_x",
		"4": "minus_y",
		"5": "minus_z",
		"particle": "plus_x"
	},
	"elements": [
		{
			"from": [0, 0, 0],
			"to": [16, 16, 16],
			"faces": {
				"north": {"uv": [0, 0, 16, 16], "rotation": 90, "texture": "#5"},
				"east": {"uv": [0, 0, 16, 16], "rotation": 270, "texture": "#4"},
				"south": {"uv": [0, 0, 16, 16], "rotation": 0, "texture": "#2"},
				"west": {"uv": [0, 0, 16, 16], "rotation": 90, "texture": "#1"},
				"up": {"uv": [0, 0, 16, 16], "rotation": 180, "texture": "#0"},
				"down": {"uv": [0, 0, 16, 16], "rotation": 90, "texture": "#3"}
			}
		}
	]
}
]])