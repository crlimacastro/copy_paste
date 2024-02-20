extends CharacterBody3D

@onready var gunRay = $Head/Camera3d/RayCast3d as RayCast3D
@onready var copyPasteRay = $Head/Camera3d/CopyPasteRayCast3D as RayCast3D
@onready var Cam = $Head/Camera3d as Camera3D
@export var _bullet_scene : PackedScene
var mouseSensibility = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const COPYABLE_LAYER = 2
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _command_manager = CommandManager.new()

func _ready():
	#Captures mouse and stops rgun from hitting yourself
	gunRay.add_exception(self)
	copyPasteRay.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Handle Shooting
	if Input.is_action_just_pressed("Shoot"):
		shoot()
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if Input.is_action_just_pressed('copy'):
		if copyPasteRay.is_colliding() and copyPasteRay.get_collider() is RigidBody3D and (copyPasteRay.get_collider() as RigidBody3D).get_collision_layer_value(COPYABLE_LAYER):
			_command_manager.execute(CopyCommand.new()
			.with_node(copyPasteRay.get_collider())
			)
	if Input.is_action_just_pressed('paste'):
		if copyPasteRay.is_colliding():
			_command_manager.execute(PasteCommand.new()
				.with_parent_node(get_tree().current_scene)
				.with_position(copyPasteRay.get_collision_point()))
	if Input.is_action_just_pressed('undo'):
		_command_manager.undo()

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouseSensibility
		$Head/Camera3d.rotation.x -= event.relative.y / mouseSensibility
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

func shoot():
	if not gunRay.is_colliding():
		return
	var bulletInst := _bullet_scene.instantiate() as Node3D
	bulletInst.set_disable_scale(true)
	gunRay.get_collider().add_child(bulletInst)
	bulletInst.global_transform.origin = gunRay.get_collision_point() as Vector3
	bulletInst.look_at((gunRay.get_collision_point()+gunRay.get_collision_normal()),Vector3.BACK)
	print(gunRay.get_collision_point())
	print(gunRay.get_collision_point()+gunRay.get_collision_normal())