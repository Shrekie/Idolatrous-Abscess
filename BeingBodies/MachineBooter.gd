extends Node

@export var mouse_activator : Node
@export var machine_sprite : AnimatedSprite2D

func _ready():
	if (mouse_activator):
		mouse_activator.turned_on.connect(commence_device)
		mouse_activator.turned_off.connect(conclude_device)

func _process(delta):
	pass

func commence_device():
	machine_sprite.play("working")

func conclude_device():
	machine_sprite.play("idle")
