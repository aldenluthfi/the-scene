class_name LevelConfig
extends RefCounted
var title: String = ""
var panel_conditions: Array = []

static func red_handed() -> LevelConfig:
	var cfg := LevelConfig.new()
	cfg.title = "RED HANDED (Tertangkap Basah)"
	cfg.panel_conditions = [
		# Megan (nurse) holds the poison to poison the victim.
		[PanelCondition.has_role_and_char_holds("nurse", "poison", "megan")],
		# Daniel (dr. Dan) examines as the doctor.
		[PanelCondition.has_role("doctor", "daniel")],
		# Daniel switches to the detective.
		[PanelCondition.has_role("detective", "daniel")],
		# Detective Daniel handcuffs nurse Megan.
		[
			PanelCondition.has_role("detective", "daniel"),
			PanelCondition.has_role_and_char_holds("nurse", "handcuff", "megan"),
		],
	]
	return cfg