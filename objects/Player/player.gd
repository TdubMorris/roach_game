extends CharacterBody2D

@export_category("Movement Parameters")
@export var jump_height : float = 20
@export var jump_time : float = 0.5
@export var accel : float = 30
@export var max_speed : float = 100
@export var max_fall_speed : float = 240
@export var extra_jumps : int = 1

@onready var sprite = %PlayerSprite
@onready var buffer = %BufferTimer
@onready var coyote = %CoyoteTimer

var jumps_remaining : int = 0
var jump_available : bool = false
var was_on_ground : bool = false

@onready var gravity : float = -1.0 * (-2.0 * jump_height)/(pow(0.5 * jump_time, 2.0))
@onready var jump_vel : float = -1.0 * ((4.0 * jump_height)/jump_time)

func _physics_process(delta: float) -> void:
	velocity.y = min(max_fall_speed, velocity.y + delta * gravity)
	velocity.x = move_toward(velocity.x, max_speed * Input.get_axis("left", "right"), accel)
	
	if Input.is_action_just_pressed("jump"):
		buffer.start()
		if !coyote.is_stopped():
			velocity.y = jump_vel
			coyote.stop()
			sprite.play("jump")
		elif !is_on_floor() and jumps_remaining > 0:
			velocity.y = jump_vel
			sprite.play("doublejump")
			jumps_remaining -= 1
	if is_on_floor():
		jumps_remaining = extra_jumps
		if !buffer.is_stopped():
			velocity.y = jump_vel
			sprite.play("jump")
			buffer.stop()
	
	was_on_ground = is_on_floor()
	move_and_slide()
	if was_on_ground and !is_on_floor() and !Input.is_action_just_pressed("jump"):
		coyote.start()
	
	#animations
	if Input.is_action_pressed("left"):
		sprite.flip_h = true
		if is_on_floor():
			sprite.play("walk")
	if Input.is_action_pressed("right"):
		sprite.flip_h = false
		if is_on_floor():
			sprite.play("walk")
	if Input.get_axis("left", "right") == 0 and is_on_floor():
		sprite.play("idle")
	if velocity.y > 0:
		sprite.play("fall")
	
