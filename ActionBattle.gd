extends Resource
class_name ActionBattle

var UpperPanel = null
var MidPanel = null
var LowerPanel = null
var BattleField = null

func start_small_field(battle_field_node):
	if BattleField:
		BattleField.get_ref().queue_free()
	BattleField = weakref(battle_field_node)
	var battleField = BattleField.get_ref()
	if MidPanel != null and battleField:
		MidPanel.hide()
		MidPanel.get_tree().get_root().add_child(battleField)
		battleField.set_global_position(MidPanel.get_position())
		battleField.connect("done", self, "on_BattleField_done")

func force_end_of_battle():
	if BattleField:
		var battleField = BattleField.get_ref()
		if battleField:
			battleField.hide()
			battleField.disconnect("done", self, "on_BattleField_done")
			battleField.queue_free()
			BattleField = null

func on_BattleField_done():
	# TODO: Show Upper and Lower Panel when we are done. The MidPanel will be shows by the Battle.gd script.
	# We want to keep the get_ref here as battlefields clear up themselves and we want to check if they freed themselves
	pass # The battle code will show the action buttons/mid field when it needs to!
#	var battleField = BattleField.get_ref()
#	if MidPanel != null and battleField:
#		MidPanel.show()
