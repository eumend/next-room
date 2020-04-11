extends Resource
class_name ActionBattle

var UpperPanel = null
var MidPanel = null
var LowerPanel = null
var BattleField = null

func start_small_field(battle_field_node):
	BattleField = battle_field_node
	if MidPanel != null and BattleField != null:
		MidPanel.hide()
		MidPanel.get_tree().get_root().add_child(BattleField)
		BattleField.set_global_position(MidPanel.get_position())
		BattleField.connect("done", self, "on_BattleField_done")

func force_end_of_battle():
	if BattleField != null:
		BattleField.disconnect("done", self, "on_BattleField_done")
		BattleField.queue_free()

func on_BattleField_done():
	if MidPanel != null and BattleField != null:
		MidPanel.show()
