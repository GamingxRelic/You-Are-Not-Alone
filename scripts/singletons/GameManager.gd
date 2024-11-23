extends Node

#var requested_scene := "res://scenes/levels/TestLevel.tscn"

var level : Node2D
var sounds : Node2D

var player_pos : Vector2
var player_facing : int = 1
var mouse_pos : Vector2

func play_sound_at_pos(stream : String, pos : Vector2) -> void:
	var sound_player : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	sound_player.stream = load(stream)
	sound_player.global_position = pos
	sound_player.max_distance = 512
	sounds.add_child(sound_player)
	sound_player.play()
	await sound_player.finished
	sound_player.queue_free()
