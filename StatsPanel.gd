extends Panel

onready var hpLabel = $StatsContainer/HP
onready var lvLabel = $StatsContainer/LV
onready var powLabel = $StatsContainer/POW
onready var statusContainer = $StatsContainer/Status
onready var sfxMiss = $SFXMiss

const PoisonIcon = preload("res://Images/UI/skull_icon.png")
const ShieldIcon = preload("res://Images/UI/shield_icon.png")
const NumberAnimation = preload("res://Animations/NumberAnimation.tscn")
const BattleUnits = preload("res://BattleUnits.tres")

func _ready():
	var player = BattleUnits.PlayerStats
	if player:
		update_hp(player.hp)
		update_pow(player.power)
		update_level(player.level)

func update_hp(value):
	var player = BattleUnits.PlayerStats
	hpLabel.text = "HP\n" + str(value) + "/" + str(player.max_hp)

func update_pow(value):
	powLabel.text = "POW\n" + str(value)

func update_level(value):
	lvLabel.text = "LV\n" + str(value)

func _on_PlayerStats_hp_changed(value):
	update_hp(value)

func _on_PlayerStats_level_changed(value, _old_value):
	update_level(value)

func _on_PlayerStats_power_changed(value):
	update_pow(value)

func _on_PlayerStats_status_changed(statuses):
	if statuses.size() > 0:
		display_status(statuses)
		lvLabel.hide()
		statusContainer.show()
	else:
		statusContainer.hide()
		lvLabel.show()
		display_status(statuses)

func display_status(statuses):
	if statuses.size() > 0:
		var last_status = statuses.back()
		var icon = get_status_icon(last_status)
		statusContainer.get_node("Icon").texture = icon
	else:
		statusContainer.get_node("Icon").texture = null

func get_status_icon(status):
	match(status):
		GameConstants.STATUS.POISON: return PoisonIcon
		GameConstants.STATUS.SHIELDED: return ShieldIcon
		_: return null




func _on_PlayerStats_heal_damage(amount):
	var numberAnimation = NumberAnimation.instance()
	hpLabel.add_child(numberAnimation)
	numberAnimation.play_heal(amount)


func _on_PlayerStats_took_damage(amount, hit_force):
	animate_panel(hit_force)
	var numberAnimation = NumberAnimation.instance()
	hpLabel.add_child(numberAnimation)
	if amount == 0:
		numberAnimation.play_miss()
		sfxMiss.play()
	else:
		var extra_text = get_hit_force_text(hit_force)
		numberAnimation.play_damage(amount, extra_text)

func animate_panel(hit_force):
	match(hit_force):
		GameConstants.HIT_FORCE.CRIT: return $AnimationPlayer.play("ShakeV2")
		GameConstants.HIT_FORCE.STRONG: return $AnimationPlayer.play("ShakeV")
		GameConstants.HIT_FORCE.NORMAL: return $AnimationPlayer.play("ShakeDown")
		_: return

func get_hit_force_text(hit_force):
	match(hit_force):
		GameConstants.HIT_FORCE.CRIT: return "!!"
		GameConstants.HIT_FORCE.STRONG: return "!"
		_: return ""
