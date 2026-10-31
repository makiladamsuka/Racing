extends RigidBody3D

@export var wheels: Array[RayCast3D]
@export var spring_strength := 100.0
@export var spring_damping := 2.0
@export var rest_dist := 1

var wheel_radius = 0.4



func _physics_process(delta: float) -> void:
	for wheel in wheels:
		_do_single_wheel_suspension(wheel)


func _get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)
func _do_single_wheel_suspension(suspension_ray: RayCast3D) -> void:
	if suspension_ray.is_colliding():
		suspension_ray.target_position.y = -(rest_dist +wheel_radius)
		var contact := suspension_ray.get_collision_point()
		var springup_dir := suspension_ray.global_transform.basis.y
		var spring_length := suspension_ray.global_position.distance_to(contact)
		var offset := rest_dist - spring_length
		
		var wheel_visual := suspension_ray.get_child(0) as Node3D
		if wheel_visual == null:
			push_error("Each suspension ray must have a Node3D wheel visual child.")
			return

		wheel_visual.position.y = -spring_length

		var spring_force := spring_strength * offset


		var world_vel := _get_point_velocity(contact)
		var relative_vel := springup_dir.dot(world_vel)
		var spring_damping_force := spring_force * relative_vel
		
		
		var force_vector := springup_dir * (spring_force - spring_damping_force)
		var force_pos_offset := contact - global_position
		apply_force(force_vector, force_pos_offset)
