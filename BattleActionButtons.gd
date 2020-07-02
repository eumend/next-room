extends GridContainer

const ActionBattle = preload("res://ActionBattle.tres")
const BattleUnits = preload("res://BattleUnits.tres")
const DialogBox = preload("res://DialogBox.tres")

onready var chargeButton = $ChargeActionButton

func _ready():
	ActionBattle.MidPanel = self
	var playerStats = BattleUnits.PlayerStats
	playerStats.connect("level_changed", self, "on_playerStats_level_changed")
	chargeButton.connect("charge", self, "_on_chargeButton_charge")

func _on_chargeButton_charge(num = 1):
	var skills = get_children()
	for skill in skills:
		skill.recharge_by(num)
		skill.disabled = true

func on_playerStats_level_changed(level, old_level):
	if level > old_level:
		var skills = get_children()
		for skill in skills:
			if skill.level_required > old_level and skill.level_required <= level:
				DialogBox.show_timeout("LEARNED " + skill.text + "!")

func recharge_all(num = null):
	var skills = get_children()
	for skill in skills:
		skill.recharge_by(num if num != null else skill.recharge_turns)

func start_turn():
	var skills = get_children()
	for skill in skills:
		skill.recharge_by(1)
		skill.visible = skill.is_learned()
		skill.disabled = skill.is_disabled()
	self.show()
