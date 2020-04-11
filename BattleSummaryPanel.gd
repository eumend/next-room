extends Panel

const BattleSummary = preload("res://BattleSummary.tres")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	BattleSummary.SummaryPanel = self
	BattleSummary.SummaryHeading = $BattleSummaryContainer/SummaryHeading
	BattleSummary.SummaryBody= $BattleSummaryContainer/SummaryBody
