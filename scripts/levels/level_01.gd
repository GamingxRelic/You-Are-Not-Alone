extends Node2D

@onready var heartrate_monitor_anim : AnimationPlayer = $HeartMonitor/AnimationPlayer
@onready var hospital_door_collider : CollisionShape2D = $HospitalDoorBody/CollisionShape2D
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var player : Player = $Player

var entered_end_scene : bool = false

func _ready() -> void:
	var bg_color : Color = Color("dbdbdb")
	RenderingServer.set_default_clear_color(bg_color)

	player.movement_speed = player.walk_speed

	heartrate_monitor_anim.play("beeping")

func heartrate_glitch() -> void:
	heartrate_monitor_anim.play("glitched")


func _on_hospital_bed_area_body_entered(_body: Node2D) -> void:
	if entered_end_scene:
		return

	anim.play("end_scene")
	entered_end_scene = true
