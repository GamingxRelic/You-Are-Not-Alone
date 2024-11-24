extends Node2D

@onready var player : Player = $Player

@onready var boss : Sprite2D = $AngerMonster
var boss_battle_started : bool = false

func _ready() -> void:
	var bg_color : Color = Color("39001c")
	RenderingServer.set_default_clear_color(bg_color)

	player.respawn()
	await get_tree().create_timer(0.9).timeout
	$Player/AnimatableRespawnScreen.visible = false

func _on_boss_battle_area_body_entered(body: Node2D) -> void:
	if body is Player and not boss_battle_started:
		boss_battle_started = true
		boss.begin_sequence()
