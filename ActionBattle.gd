extends Resource
class_name ActionBattle

var UpperPanel = null
var MidPanel = null
var LowerPanel = null
var BattleField = null

func start_small_field(battle_field_node):
	if MidPanel != null and battle_field_node:
		clear_current_battlefield()
		BattleField = battle_field_node
		MidPanel.hide()
		MidPanel.get_tree().get_root().add_child(BattleField)
		BattleField.set_global_position(MidPanel.get_position() + Vector2(2, 0))
		BattleField.connect("done", self, "on_BattleField_done", [BattleField])

func force_end_of_battle():
	clear_current_battlefield()

func clear_current_battlefield():
	if BattleField:
		BattleField.queue_free()
		BattleField = null

func on_BattleField_done(battle_field):
	# The field frees itself; only forget it if a newer one hasn't replaced it
	if BattleField == battle_field:
		BattleField = null
