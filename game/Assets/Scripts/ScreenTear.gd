extends Node2D


onready var particle_emitter1 = $ParticleEmitter
onready var particle_emitter2 = $ParticleEmitter2

var lifetime = .7
var emit_stop = .5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lifetime -= delta
	
	if lifetime < emit_stop:
		particle_emitter1.emitting = false
		particle_emitter2.emitting = false
	
	if lifetime < 0:
		self.queue_free()
