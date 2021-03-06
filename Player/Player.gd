extends KinematicBody2D

const MAX_SPEED = 80
const ACCELERATION = 500
const FRICTION = 750
const ROLL_SPEED = 125
var velocity = Vector2.ZERO





enum {
	MOVE, ROLL, ATTACK
}
var state = MOVE
var roll_vector = Vector2.DOWN

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")



func _ready():
	animationTree.active = true
	
func _physics_process(delta):
	match state:
		MOVE:	
			move_state(delta)
		ATTACK:
			attack_state(delta)
		ROLL:
			roll_state(delta)
	

func attack_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel('Roll')
	move()


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		animationState.travel("Run")
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)

		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
	if Input.is_action_just_pressed("roll"):
		state = ROLL


func move():
	velocity = move_and_slide(velocity)
	
func roll_animation_finished():
	state = MOVE
	velocity = velocity/2

func attack_animation_finished():
	state = MOVE


func _on_Hitbox_area_entered(area):
	pass # Replace with function body.
