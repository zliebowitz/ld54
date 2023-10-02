extends Node

export(NodePath) onready var audio_stream

export(PackedScene) var next_scene

export(NodePath) var win_loss_label

export(NodePath) var item_count_label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	audio_stream = get_node(audio_stream) as AudioStreamPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if win_loss_label:
		var win_loss_label_instance : Label = get_node(win_loss_label)
		if Global.items_collected >= Global.item_win_count:
			win_loss_label_instance.set_text("You Win!")
		else:
			win_loss_label_instance.set_text("You Lost!")
	
	if item_count_label:
		var item_count_label_instance : Label = get_node(item_count_label)
		item_count_label_instance.set_text(str(Global.items_collected))	

	if(audio_stream):
		if(!audio_stream.playing): # end of stream going to next scene
			get_tree().change_scene_to(next_scene)
		


func _on_start_button_pressed():
	Global.items_collected = 0
	get_tree().change_scene_to(next_scene)
