extends Node

@export var being_to_move : CharacterBody2D

@export var thrust_wheel_container : Node2D
@export var thrust_wheel : Area2D
@export var thrust_acceleration_splitter = 1.0
@export var thrust_max_speed = 300.0
@export var thrust_friction = 150.0
@export var thrust_threshold_distance = 15.0
var dragging_thruster = false

@export var rotator_wheel_container : Node2D
@export var rotator_wheel : Area2D
@export var rotation_acceleration_splitter = 30.0
@export var rotation_max_speed = 5.0
@export var rotation_threshold_distance = 15.0
var dragging_rotator = false

var max_drag_radius = 15.0

func _ready():
	rotator_wheel.input_event.connect(_on_rotating_area_input_event)
	thrust_wheel.input_event.connect(_on_thrust_area_input_event)
	
func _process(delta):
	
	if dragging_thruster or dragging_rotator:
		
		var thrust_wheel_drag : Vector2
		var rotator_wheel_drag : Vector2
		
		if dragging_thruster:
			thrust_wheel_drag = \
			mouse_between_wheel_threshold(thrust_wheel_container)
		if dragging_rotator:
			rotator_wheel_drag = \
			mouse_between_wheel_threshold(rotator_wheel_container)
			
		if dragging_thruster:
			thrust_wheel.position = tug_control_unrotated(thrust_wheel, \
			thrust_wheel_drag, delta)
		if dragging_rotator:
			rotator_wheel.position = tug_control_unrotated(rotator_wheel, \
			rotator_wheel_drag, delta)
			
		var rotator_direction_to_mouse = \
		mouse_between_wheel(rotator_wheel_container)
		var thrust_direction_to_mouse = \
		mouse_between_wheel(thrust_wheel_container)
		
		var being_rotation_vector = Vector2.from_angle(being_to_move.rotation)
		var rotator_angle_to_mouse = \
		being_rotation_vector.angle_to(rotator_direction_to_mouse.normalized())
		
		if dragging_rotator:
			if rotator_direction_to_mouse.length() > \
			rotation_threshold_distance:
				being_to_move.rotate(clamp(rotator_angle_to_mouse, \
				-damp_rotation_acceleration(rotator_direction_to_mouse) \
				 * delta, \
				damp_rotation_acceleration(rotator_direction_to_mouse) \
				 * delta))
		
		if dragging_thruster:
			if thrust_direction_to_mouse.length() > \
			thrust_threshold_distance:
				being_to_move.velocity = \
				thrust_direction_to_mouse.normalized() * \
				(thrust_direction_to_mouse.length()/ \
				thrust_acceleration_splitter)
			
	if not dragging_rotator:
		rotator_wheel.position = \
		rotator_wheel.position.lerp(Vector2.ZERO, delta * 50)
	
	if not dragging_thruster:
		thrust_wheel.position = \
		thrust_wheel.position.lerp(Vector2.ZERO, delta * 50)
		
	damp_being_acceleration(delta)
	being_to_move.move_and_slide()

func mouse_between_wheel_threshold(wheel_start: Node2D):
	var wheel_drag = mouse_between_wheel(wheel_start)
	
	if wheel_drag.length() > max_drag_radius:
		wheel_drag = wheel_drag.normalized() * max_drag_radius
		
	return wheel_drag
	
func mouse_between_wheel(wheel: Node2D):
	return wheel.get_global_mouse_position() - \
	wheel.global_position
	
func tug_control_unrotated(control: Node2D, tug : Vector2, delta: float):
	return control.position.lerp(\
	tug.rotated(-being_to_move.rotation), delta * 50)
	
func damp_rotation_acceleration(direction_to_mouse: Vector2):
	return clamp(direction_to_mouse.length()/rotation_acceleration_splitter, \
	 0, rotation_max_speed)

func damp_being_acceleration(delta):
	if being_to_move.velocity.length() > (thrust_friction * delta):
		being_to_move.velocity -= \
		being_to_move.velocity.normalized() * (thrust_friction * delta)
	else:
		being_to_move.velocity = Vector2.ZERO
	
	being_to_move.velocity = \
	being_to_move.velocity.limit_length(thrust_max_speed)

func _input(event):
	if event is InputEventMouseButton:
		if(event.button_index == 1 and event.pressed == false):
			dragging_rotator = false
			dragging_thruster = false

func _on_rotating_area_input_event(_viewport: Node, event: InputEvent, \
_shape_idx: int):
	if event is InputEventMouseButton:
		if(event.button_index == 1 and event.pressed == true):
			dragging_rotator = true

func _on_thrust_area_input_event(_viewport: Node, event: InputEvent, \
_shape_idx: int):
	if event is InputEventMouseButton:
		if(event.button_index == 1 and event.pressed == true):
			dragging_thruster = true
