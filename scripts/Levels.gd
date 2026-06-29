class_name Levels
extends RefCounted

# Total number of level slots shown on the level-select screen.
const TOTAL := 10

# How many levels are currently unlocked (only the first for now).
static var unlocked_count := 1

# The level the player picked on the select screen; read by main.gd.
static var selected_index := 0


static func is_unlocked(index: int) -> bool:
	return index >= 0 and index < unlocked_count


static func level_name(index: int) -> String:
	match index:
		0:
			return "Red Handed"
		_:
			return "Level %d" % (index + 1)


# Returns the LevelConfig for a level. Only level 0 is authored so far;
# locked levels fall back to it and are never reachable from the UI.
static func get_config(index: int) -> LevelConfig:
	match index:
		0:
			return LevelConfig.red_handed()
		_:
			return LevelConfig.red_handed()
