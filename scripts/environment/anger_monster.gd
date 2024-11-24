extends Sprite2D

var health : int = 10
var i_frames : float = 0.5
var invinicible : bool = false
var i_frames_enabled : bool = false

var dead : bool = false

@onready var monster_anim : AnimationPlayer = $MonsterAnimation
@onready var position_anim : AnimationPlayer = $MonsterPosition

func _ready() -> void:
	monster_anim.play("idle")

func begin_sequence() -> void:
	print("begin seq")
	var delay : float = 5.0
	# actual jump is 1.6 sec in

	# Oh my goodness this code is awful... game jam moment.
	next_anim("start_pos_to_pos_1")
	await get_tree().create_timer(delay).timeout
	next_anim("pos1_to_pos2")
	await get_tree().create_timer(delay).timeout
	next_anim("pos2_to_pos3")
	await get_tree().create_timer(delay).timeout
	next_anim("pos3_to_pos4")
	await get_tree().create_timer(delay).timeout
	begin_sequence() # Awful.

func next_anim(anim_name : String) -> void:
	# Some of the worst code I've written in a very long time...
	if dead: return
	monster_anim.play("jump")
	await get_tree().create_timer(1.6).timeout
	if dead: return
	invinicible = true
	position_anim.play(anim_name)

func damage() -> void:
	if invinicible or i_frames_enabled:
		return

	print("ow")
	health -= 1

	if health == 0:
		death()

	modulate = Color.RED
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)

	i_frames_enabled = true
	await get_tree().create_timer(i_frames).timeout
	i_frames_enabled = false

func death() -> void:
	dead = true
	monster_anim.play("death")

func _on_monster_position_animation_finished(_anim_name: StringName) -> void:
	invinicible = false
	monster_anim.play("idle")

func _on_hurtbox_area_entered(_area: Area2D) -> void:
	damage()

func _on_attack_box_body_entered(body: Node2D) -> void:
	if body is Player:
		body.damage()
