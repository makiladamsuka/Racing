extends RayCast3D

class_name RayCastWheel
@export var spring_strength := 100.0
@export var spring_damping := 3
@export var rest_dist := 1
@export var over_extend := 0.0
@export var wheel_radius = 0.4
@onready var wheel: Node3D = get_child(0)
