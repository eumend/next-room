extends GridContainer

#const SlashAttack = preload("res://Attacks/SlashAttack.tscn")
const ActionBattle = preload("res://ActionBattle.tres")
const BattleUnits = preload("res://BattleUnits.tres")
const DialogBox = preload("res://DialogBox.tres")

func _ready():
	ActionBattle.MidPanel = self
	var playerStats = BattleUnits.PlayerStats
	playerStats.connect("level_changed", self, "on_playerStats_level_changed")

func on_playerStats_level_changed(level, old_level):
	if level > old_level:
		var skills = get_children()
		for skill in skills:
			if skill.level_required > old_level and skill.level_required <= level:
				DialogBox.show_timeout("LEARNED " + skill.text + "!")

func show_skills():
	var skills = get_children()
	for skill in skills:
		skill.visible = skill.is_learned()
		skill.disabled = skill.is_disabled()
	self.show()
