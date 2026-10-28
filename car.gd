extends RigidBody3D

@export var wheels: Array[RayCast3D]
@export var spring_strength := 100.0
@export var spring_damping := 2.0
@export var rest_dist := 0.5


func _physics_process(delta: float) -> void:
	for wheel in wheels:
		_do_single_wheel_suspension(wheel)

func _do_single_wheel_suspension(suspension_ray: RayCast3D) -> void:
	if suspension_ray.is_colliding():
		var contact := suspension_ray.get_collision_point()
		var springup_dir := suspension_ray.global_transform.basis.y
		var spring_length := suspension_ray.global_position.distance_to(contact)
		var offset := rest_dist - spring_length

		var spring_force = spring_strength * offset
		var force_vector = springup_dir * spring_force

		var force_pos_offset := contact - global_position
		apply_force(force_vector, force_pos_offset)
