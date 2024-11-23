extends CharacterBody2D
class_name Player

# Abilities
var dash_unlocked : bool = false
var attack_unlocked : bool = true

# Animation
@onready var anim_tree : AnimationTree = $AnimationTree
@onready var anim_player : AnimationPlayer = $AnimationPlayer

# Attacking
var can_attack : bool = true
var attacking : bool = false
var attack_duration : float = 0.15
@onready var attack_box_collider : CollisionShape2D = $Area2Ds/AttackBox/CollisionShape2D
@export var attack_box_left_position : Vector2
@export var attack_box_right_position : Vector2

# Movement
var movement_speed : float = 200.0
var x_input : float
var y_input : float

enum facing {
	LEFT = -1,
	RIGHT = 1
}

# More predictable jumps
@export var jump_height : float = 55
@export var jump_time_to_peak : float = 0.32
@export var jump_time_to_descent : float = 0.23
@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

# For variable jump height
const cut_height : float = 0.85

# Max y velocity
const max_fall_velocity : float = 550.0

# Jumping variables
var can_jump := false
var jump_was_pressed := false
var is_jumping := false

# Dashing Variables
var dash_time : float = 0.15
@export var dashing : bool = false
var can_dash : bool = true
var dash_speed : float = 550.0

# Corner Correction variables
@onready var cc_raycasts : Array = $Raycasts/CornerCorrection.get_children()
@export var cc_push_amount := 3.0

# Sprite
@onready var sprite : Sprite2D = $Sprite

func _process(_delta : float) -> void: # This is only used for inputs
	if GameManager.player_facing == facing.LEFT:
		sprite.flip_h = true
		attack_box_collider.position = attack_box_left_position
	else:
		sprite.flip_h = false
		attack_box_collider.position = attack_box_right_position

	if Input.is_action_just_pressed("jump"):
		jump_was_pressed = true
		remember_jump_time()
		if can_jump:
			jump()

	if Input.is_action_just_released("jump") and velocity.y < 0 and is_jumping:
		velocity.y *= cut_height

func _physics_process(delta : float) -> void:
	GameManager.player_pos = global_position
	GameManager.mouse_pos = get_global_mouse_position()

	# Get the input directions
	x_input = Input.get_axis("move_left", "move_right")
	y_input = Input.get_axis("jump", "move_down")

	# Handle Jump
	handle_jump(delta)

	# Horizontal Movement
	horizontal_movement()

	# Corner Correction
	corner_correction()

	# For one way platforms
	if is_on_floor() and Input.is_action_just_pressed("move_down"):
		global_position.y += 1

	# Handle Dash
	if dash_unlocked:
		handle_dash()

	# Handle attack
	if attack_unlocked:
		handle_attack()

	move_and_slide()

func horizontal_movement() -> void:
	# If the player is dashing, they should not be able to change directions
	if dashing:
		return

	# Handle the movement/deceleration.

	if x_input < 0:
		GameManager.player_facing = facing.LEFT # Left
	elif x_input > 0:
		GameManager.player_facing = facing.RIGHT # Right

	if x_input:
		velocity.x = x_input * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)

func handle_dash() -> void:
	if is_on_floor() and not dashing and not can_dash:
		can_dash = true

	if not dashing and can_dash and Input.is_action_just_pressed("dash"):
		dash()

func handle_attack() -> void:
	if Input.is_action_just_pressed("attack") and can_attack and not attacking:
		attack()

func attack() -> void:
	# TODO: Play Animation!!

	attacking = true
	attack_box_collider.set_deferred("disabled", false)
	await get_tree().create_timer(attack_duration).timeout
	attack_box_collider.set_deferred("disabled", true)
	attacking = false

func handle_jump(delta : float) -> void:
	if dashing:
		return

	if is_on_floor():
		if Input.is_action_just_pressed("move_down"):
			global_position.y += 1

		is_jumping = false
		can_jump = true
		if jump_was_pressed:
			jump()

	# Add the gravity.
	if not is_on_floor() and not dashing:
		coyote_time()
		velocity.y += get_cust_gravity() * delta
		velocity.y = clampf(velocity.y, -max_fall_velocity, max_fall_velocity)

	if Input.is_action_just_pressed("jump"):
		jump_was_pressed = true
		remember_jump_time()
		if can_jump:
			jump()
#
	if Input.is_action_just_released("jump") and velocity.y < 0 and is_jumping:
		velocity.y *= cut_height

func get_cust_gravity() -> float:


	return jump_gravity if velocity.y < 0.0 else fall_gravity

func jump() -> void:
	is_jumping = true
	velocity.y = jump_velocity

func coyote_time() -> void:
	await get_tree().create_timer(0.1).timeout
	can_jump = false

func remember_jump_time() -> void:
	await get_tree().create_timer(0.08).timeout
	jump_was_pressed = false

func corner_correction() -> void:
	if velocity.y < 0:
		if cc_raycasts[0].get_collider() != null and cc_raycasts[1].get_collider() == null:
			position.x += cc_push_amount

		if cc_raycasts[2].get_collider() != null and cc_raycasts[3].get_collider() == null:
			position.x -= cc_push_amount

func _on_pickup_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("item") and !body.is_stalling():
		body.queue_free()

func _on_item_pull_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("item"):
		body.follow_player()

func _on_item_pull_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("item"):
		body.stop_following_player()

func dash() -> void:
	if is_zero_approx(abs(x_input)):
		return
	dashing = true
	can_dash = false
	velocity = Vector2(dash_speed * x_input, 0)
	await get_tree().create_timer(dash_time).timeout
	dashing = false
