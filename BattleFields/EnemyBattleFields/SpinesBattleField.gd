extends "res://BattleFields/BaseBattleField.gd"

onready var tSpike = $Field/TSpike
onready var trSpike = $Field/TRSpike
onready var rSpike = $Field/RSpike
onready var brSpike = $Field/BRSpike
onready var bSpike = $Field/BSpike
onready var blSpike = $Field/BLSpike
onready var lSpike = $Field/LSpike
onready var tlSpike = $Field/TLSpike

onready var spikeTimer = $Field/SpikeTimer
onready var cooldownTimer = $Field/CooldownTimer
onready var shieldTimer = $Field/ShieldTimer
onready var doneTimer = $Field/DoneTimer
onready var shieldAnimation = $Field/Player/ShieldAnimation

var ALL_SPIKES = []
var shielded = false
var cooldown = false

var total_spikes = 2
var fired_spikes = 0
var done_spikes = 0
var spikes_per_hit = {3: 100}

func _ready():
	ALL_SPIKES = [tSpike, trSpike, rSpike, brSpike, bSpike, blSpike, lSpike, tlSpike]
	tSpike.connect("fired", self, "on_spike_fired")
	trSpike.connect("fired", self, "on_spike_fired")
	rSpike.connect("fired", self, "on_spike_fired")
	brSpike.connect("fired", self, "on_spike_fired")
	bSpike.connect("fired", self, "on_spike_fired")
	blSpike.connect("fired", self, "on_spike_fired")
	lSpike.connect("fired", self, "on_spike_fired")
	tlSpike.connect("fired", self, "on_spike_fired")
	spikeTimer.connect("timeout", self, "on_spikeTimer_timeout")
	cooldownTimer.connect("timeout", self, "on_cooldownTimer_timeout")
	shieldTimer.connect("timeout", self, "on_shieldTimer_timeout")
	doneTimer.connect("timeout", self, "on_doneTimer_timeout")
	spikeTimer.start()

func on_spikeTimer_timeout():
	print("shooting spike?")
	if fired_spikes < total_spikes:
		var spike_qty = Utils.pick_from_weighted(spikes_per_hit)
		if spike_qty > 1:
			var spikes_list = ALL_SPIKES.duplicate()
			spikes_list.shuffle()
			print("spike_qty", spike_qty)
			for _i in range(0, spike_qty):
				var spike = spikes_list.pop_front() # TODO: Refractor this logid, we actually need to pop all the time so we arent reusing spikes on each timer loop
				spike.shoot()
		else:
			var spike = Utils.pick_from_list(ALL_SPIKES)
			spike.shoot()
		fired_spikes += 1

func on_cooldownTimer_timeout():
	cooldown = false

func on_shieldTimer_timeout():
	shielded = false
	shieldAnimation.hide()

func on_doneTimer_timeout():
	done()

func on_spike_fired():
	if shielded:
		miss()
	else:
		hit()
	done_spikes += 1
	if done_spikes >= total_spikes:
		doneTimer.start()

func on_pressed():
	if not cooldown:
		shieldAnimation.show()
		shieldTimer.start()
		shielded = true
		cooldown = true
		cooldownTimer.start()
