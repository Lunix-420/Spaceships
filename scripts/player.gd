extends CharacterBody2D

@export var gui: Control

@onready var shooter = get_node("Shooter")
@onready var sprite = get_node("Sprite")
@onready var exhaustBackLeft = sprite.get_node("ExhaustBackLeft")
@onready var exhaustBackRight = sprite.get_node("ExhaustBackLeft")
@onready var exhaustSideLeft = sprite.get_node("ExhaustSideLeft")
@onready var exhaustSideRight = sprite.get_node("ExhaustSideRight")
@onready var exhaustFront = sprite.get_node("ExhaustFront")
@onready var healthBar: BaseBar = gui.get_node("Health")
@onready var energyBar: BaseBar = gui.get_node("Energy")

const MAX_SPEED = 500
const MAX_BACK_SPEED = 400
const MAX_STRAVE_SPEED = 400
const ACCELERATION = 2000.0
const STRAVE_ACCELERATION = 1500.0
const ROTATION_SPEED = 4.0
const FRICTION = 500
const ENERGY_LOSS = 1000
const IDLE_ENERGY_CONSUMPTION = 20

var speed = 0.0
var strave_speed = 0.0

func _physics_process(delta: float) -> void:
	handle_forward_backward_motion(delta)
	handle_sideward_motion(delta)
	handle_rotation(delta)
	handle_shooting(delta)
	handle_use_energ(IDLE_ENERGY_CONSUMPTION * delta)
	move_and_slide()

func loose_health():
	healthBar.set_current_value(healthBar.current_value - 200)

func collect_energy():
	energyBar.set_current_value(energyBar.current_value + 120)

func handle_use_energ(amount: float):
	energyBar.set_current_value(energyBar.current_value - amount)


func handle_forward_backward_motion(delta: float) -> void:
	if Input.is_action_pressed("move_forward") and not Input.is_action_pressed("move_backwards"):
		speed += ACCELERATION * delta
		speed = min(speed, MAX_SPEED)
		exhaustBackLeft.emitting = true
		exhaustBackRight.emitting = true
		exhaustFront.emitting = false
	elif Input.is_action_pressed("move_backwards") and not Input.is_action_pressed("move_forward"):
		exhaustBackLeft.emitting = false
		exhaustBackRight.emitting = false
		exhaustFront.emitting = true
		if speed > 0:
			speed = max(speed - ACCELERATION * delta, 0)
		else:
			speed -= ACCELERATION * delta
			speed = max(speed, -MAX_BACK_SPEED)
		speed = min(speed + FRICTION * delta, 0) if speed < 0 else speed
	else:
		exhaustBackLeft.emitting = false
		exhaustBackRight.emitting = false
		exhaustFront.emitting = false
		if speed > 0:
			speed = max(speed - FRICTION * delta, 0)
		elif speed < 0:
			speed = min(speed + FRICTION * delta, 0)

	var forward = sprite.global_transform.y.normalized()
	position += forward * speed * delta

func handle_sideward_motion(delta: float) -> void:
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		strave_speed += STRAVE_ACCELERATION * delta
		strave_speed = min(strave_speed, MAX_STRAVE_SPEED)
		exhaustSideRight.emitting = true
		exhaustSideLeft.emitting = false
	elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		strave_speed -= STRAVE_ACCELERATION * delta
		strave_speed = max(strave_speed, -MAX_STRAVE_SPEED)
		exhaustSideRight.emitting = false
		exhaustSideLeft.emitting = true
	else:
		exhaustSideLeft.emitting = false
		exhaustSideRight.emitting = false
		if strave_speed > 0:
			strave_speed = max(strave_speed - FRICTION * delta, 0)
		elif strave_speed < 0:
			strave_speed = min(strave_speed + FRICTION * delta, 0)

	var right = sprite.global_transform.x.normalized()
	position += right * strave_speed * delta

func handle_rotation(delta: float) -> void:
	if Input.is_action_pressed("move_turn_ccw"):
		sprite.rotation += ROTATION_SPEED * delta
	if Input.is_action_pressed("move_turn_cw"):
		sprite.rotation -= ROTATION_SPEED * delta

func handle_shooting(delta: float) -> void:
	if Input.is_action_just_pressed("action_shoot"):
		
		var plasma = preload("res://scenes/Plasma.tscn").instantiate()
		plasma.rotation = rotation
		plasma.position = shooter.global_position
		plasma.set("init_speed", speed)
		get_tree().current_scene.add_child(plasma)


	
