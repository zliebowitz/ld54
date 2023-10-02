extends Node

func stop_music():
	$"musicBGM".stop()
	$"musicTitle".stop()
	$"musicEndGame".stop()
	$"musicGameOver".stop()
	

func play_music(sound_name):
	var track = "music" + sound_name
	var player = get_node(track)
	if(player):
		if(!player.playing):
			stop_music()
			player.play()
			
func play_sfx(sound_name):
	var track = "sfx" + sound_name
	var player = get_node(track)
	if(player):
		player.play()


