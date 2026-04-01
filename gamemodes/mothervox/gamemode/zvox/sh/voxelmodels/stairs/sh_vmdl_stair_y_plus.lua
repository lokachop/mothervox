ZVox = ZVox or {}
ZVox.NewVoxelModel("stair_y_plus",[[
{
	"format_version": "1.21.6",
	"credit": "Made with Blockbench",
	"elements": [
		{
			"from": [0, 0, 0],
			"to": [16, 8, 16],
			"rotation": {"angle": 0, "axis": "y", "origin": [0, 8, 16]},
			"faces": {
				"north": {"uv": [0, 8, 16, 16], "texture": "#1"},
				"east": {"uv": [0, 8, 16, 16], "texture": "#3"},
				"south": {"uv": [0, 8, 16, 16], "texture": "#4"},
				"west": {"uv": [0, 8, 16, 16], "texture": "#0"},
				"up": {"uv": [0, 0, 16, 16], "texture": "#2"},
				"down": {"uv": [0, 0, 16, 16], "texture": "#5"}
			}
		},
		{
			"from": [0, 8, 0],
			"to": [8, 16, 16],
			"rotation": {"angle": 0, "axis": "y", "origin": [0, 8, 16]},
			"faces": {
				"north": {"uv": [8, 0, 16, 8], "texture": "#1"},
				"east": {"uv": [0, 0, 16, 8], "texture": "#3"},
				"south": {"uv": [0, 0, 8, 8], "texture": "#4"},
				"west": {"uv": [0, 0, 16, 8], "texture": "#0"},
				"up": {"uv": [0, 0, 8, 16], "texture": "#2"}
			}
		}
	]
}
]])