extends Resource
class_name ActionBattle

var UpperPanel = null
var MidPanel = null
var LowerPanel = null

func start_small_field(battle_field_node):
	if MidPanel:
		MidPanel.hide()
		battle_field_node.set_global_position(MidPanel.get_position())
		battle_field_node.connect("done", self, "on_BattleField_done")

func on_BattleField_done():
	if MidPanel:
		MidPanel.show()
