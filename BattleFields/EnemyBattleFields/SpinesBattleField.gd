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

export var total_spikes = 2
export var spikes_per_hit = {3: 100}
export var spike_time = 1
var fired_spikes = 0
var done_spikes = 0

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
	spikeTimer.wait_time = spike_time
	spikeTimer.start()

func on_spikeTimer_timeout():
	if fired_spikes < total_spikes:
		var spike_qty = Utils.pick_from_weighted(spikes_per_hit)
		var spikes_list = []
		for spike in ALL_SPIKES:
			if not spike.shooting:
				spikes_list.append(spike)
		spikes_list.shuffle()
		for _i in range(0, spike_qty):
			var spike = spikes_list.pop_front()
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
