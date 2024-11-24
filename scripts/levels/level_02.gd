extends Node2D

@onready var player : Player = $Player

func _ready() -> void:
	var bg_color : Color = Color("39001c")
	RenderingServer.set_default_clear_color(bg_color)

	player.movement_speed = player.run_speed
