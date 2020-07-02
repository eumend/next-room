extends Panel

onready var hpLabel = $StatsContainer/HP
onready var lvLabel = $StatsContainer/LV
onready var powLabel = $StatsContainer/POW
onready var statusContainer = $StatsContainer/Status
onready var sfxMiss = $SFXMiss

const PoisonIcon = preload("res://Images/UI/skull_icon.png")
const ShieldIcon = preload("res://Images/UI/shield_icon.png")
const SwordIcon = preload("res://Images/UI/sword_icon.png")
const NumberAnimation = preload("res://Animations/NumberAnimation.tscn")
const BattleUnits = preload("res://BattleUnits.tres")

func _ready():
	var player = BattleUnits.PlayerStats
	if player:
		update_hp()
		update_pow()
		update_level()

func update_hp():
	var player = BattleUnits.PlayerStats
	hpLabel.text = "HP\n" + str(player.hp) + "/" + str(player.max_hp)

func update_pow():
	var player = BattleUnits.PlayerStats
	powLabel.text = "POW\n" + str(player.power)

func update_level():
	var player = BattleUnits.PlayerStats
	lvLabel.text = "LV\n" + str(player.level)

func _on_PlayerStats_hp_changed(_value):
	update_hp()

func _on_PlayerStats_max_hp_changed(_value):
	update_hp()

func _on_PlayerStats_level_changed(_value, _old_value):
	update_level()

func _on_PlayerStats_power_changed(_value):
	update_pow()

func _on_PlayerStats_status_changed(statuses):
	if statuses.size() > 0:
		display_status(statuses)
		lvLabel.hide()
		statusContainer.show()
	else:
		statusContainer.hide()
		lvLabel.show()
		display_status(statuses)

func _on_PlayerStats_status_healed(statuses):
	_on_PlayerStats_status_changed(statuses)
	var numberAnimation = NumberAnimation.instance()
	lvLabel.add_child(numberAnimation)
	numberAnimation.play_heal(null, "+++")

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
		GameConstants.STATUS.BOOST: return SwordIcon
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
