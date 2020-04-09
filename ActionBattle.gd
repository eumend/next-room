extends Resource
class_name ActionBattle

var UpperPanel = null
var MidPanel = null
var LowerPanel = null
var BattleField = null

func start_small_field(battle_field_node):
	BattleField = battle_field_node
	if MidPanel and BattleField:
		MidPanel.hide()
		BattleField.set_global_position(MidPanel.get_position())
		BattleField.connect("done", self, "on_BattleField_done")

func force_end_of_battle():
	if BattleField:
		BattleField.disconnect("done", self, "on_BattleField_done")
		BattleField.queue_free()

func on_BattleField_done():
	if MidPanel and BattleField:
		MidPanel.show()
