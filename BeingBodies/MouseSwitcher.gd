extends Node

@export var flipperswitch_area : Area2D
@export var flipperswitch_sprite : AnimatedSprite2D

signal turned_on()
signal turned_off()
var flipperswitch_on = false

func _ready():
	flipperswitch_area.input_event.connect(_on_flipperswitch_area_input_event)

func _process(delta):
	pass

func _on_flipperswitch_area_input_event(_viewport: Node, event: InputEvent, \
_shape_idx: int):
	if event is InputEventMouseButton:
		if(event.button_index == 1 and event.pressed == true):
			if flipperswitch_on:
				flipperswitch_on = false
				flipperswitch_sprite.play("off")
				turned_off.emit()
			else:
				flipperswitch_on = true
				flipperswitch_sprite.play("on")
				turned_on.emit()
