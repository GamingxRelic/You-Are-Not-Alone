extends Node2D

@onready var heartrate_monitor_anim : AnimationPlayer = $HeartMonitor/AnimationPlayer
@onready var hospital_door_collider : CollisionShape2D = $HospitalDoorBody/CollisionShape2D
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var player : Player = $Player

@onready var beeping_sfx : AudioStreamPlayer2D = $HeartMonitor/Beeping
@onready var flatline_sfx : AudioStreamPlayer2D = $HeartMonitor/Flatline

var entered_end_scene : bool = false

func _ready() -> void:
	var bg_color : Color = Color("dbdbdb")
	RenderingServer.set_default_clear_color(bg_color)

	player.movement_speed = player.walk_speed

	heartrate_monitor_anim.play("beeping")

func heartrate_glitch() -> void:
	heartrate_monitor_anim.play("glitched")
	flatline_sfx.play()
	beeping_sfx.stop()


func _on_hospital_bed_area_body_entered(_body: Node2D) -> void:
	if entered_end_scene:
		return

	anim.play("end_scene")
	entered_end_scene = true

func load_next_level() -> void:
	var next_level : Node2D = preload("res://scenes/levels/level_02.tscn").instantiate()
	get_tree().root.add_child(next_level)
	queue_free()
