extends RigidBody3D

@export var wheels: Array[RayCastWheel]
@export var wheel_acceleration := 10.0
@export var deccelaration := 2.5

@export var max_speed := 20

var motor_input := 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("acc"):
		motor_input = 1.0
	elif event.is_action_released("acc"):
		motor_input = 0.0
	elif event.is_action_pressed("decc"):
		motor_input = -1.0
	elif event.is_action_released("decc"):
		motor_input = 0.0

func _physics_process(delta: float) -> void:
	for wheel in wheels:
		_do_single_wheel_suspension(wheel)
		_do_single_wheel_accelaration(wheel)


func _get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)

func _do_single_wheel_accelaration(ray: RayCastWheel) -> void:
	if ray.is_colliding():
		var forward_dir := -ray.global_transform.basis.z
		var contact := ray.wheel.global_position
		var velocity := forward_dir.dot(linear_velocity)
		
		ray.wheel.rotate_x(-velocity* get_process_delta_time() * 2 * PI * ray.wheel_radius)
		
		var force_vector := forward_dir * wheel_acceleration * motor_input
		if velocity > max_speed:
			force_vector * 0.1
		var force_pos := contact - global_position
		if motor_input:
			apply_force(force_vector, force_pos)
			
		force_vector = global_basis.z * deccelaration * sign(velocity)
		apply_force(force_vector, force_pos)



func _do_single_wheel_suspension(ray: RayCastWheel) -> void:
	ray.target_position.y = -(ray.rest_dist + ray.wheel_radius)

	var wheel_visual := ray.get_child(0) as Node3D
	if wheel_visual == null:
		push_error("Each suspension ray must have a Node3D wheel visual child.")
		return

	if ray.is_colliding():
		var contact := ray.get_collision_point()
		var springup_dir := ray.global_transform.basis.y
		var spring_length := ray.global_position.distance_to(contact)
		var offset := ray.rest_dist - spring_length

		wheel_visual.position.y = -spring_length + ray.wheel_radius

		var spring_force := ray.spring_strength * offset
		var world_vel := _get_point_velocity(contact)
		var relative_vel := springup_dir.dot(world_vel)
		var spring_damping_force := ray.spring_damping * relative_vel
		
		contact = ray.wheel.global_position
		var force_vector := springup_dir * (spring_force - spring_damping_force)
		var force_pos_offset := contact - global_position
		apply_force(force_vector, force_pos_offset)
		
	else:
		wheel_visual.position.y = -ray.rest_dist + ray.wheel_radius
