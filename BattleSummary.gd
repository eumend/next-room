extends Resource
class_name BattleSummary

var SummaryPanel = null
var SummaryHeading = null
var SummaryBody = null

func show_summary(heading, body):
	if SummaryPanel:
		SummaryHeading.text = heading
		SummaryBody.text = body
		SummaryPanel.show()

func hide_summary():
	if SummaryPanel:
		SummaryHeading.text = ""
		SummaryBody.text = ""
		SummaryPanel.hide()


