extends Node

export(NodePath) onready var audio_stream

export(PackedScene) var next_scene

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	audio_stream = get_node(audio_stream) as AudioStreamPlayer
	var win_loss_label : Label = $KickableTitle/KinematicBody2D/Label
	if win_loss_label:
		if Global.items_collected >= Global.item_win_count:
			win_loss_label.set_text("You Win!")
		else:
			win_loss_label.set_text("You Lost!")
	
	var item_count_label = $KickableCounter/KinematicBody2D/ObjectCounter/Counter
	if item_count_label:
		item_count_label.set_text(str(Global.items_collected))	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(audio_stream):
		if(!audio_stream.playing): # end of stream going to next scene
			get_tree().change_scene_to(next_scene)
		


func _on_start_button_pressed():
	Global.items_collected = 0
	get_tree().change_scene_to(next_scene)
