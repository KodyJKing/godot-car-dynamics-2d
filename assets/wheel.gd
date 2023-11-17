extends Node2D

class_name Wheel

var car: Car

var radius = 35.0 
var mass = 26.0 # kg
var staticFrictionCoef = 10
var kineticFrictionCoef = 0.9
var rollingFrictionCoef = kineticFrictionCoef * .01
var isRightWheel = false

var angularMomentum = 0.0
var momentOfInertia = mass * radius ** 2

var lateralForceThisFrame = Vector2(0,0)

# The forward longitudinal direction
func forwardDirection():
	return -global_transform.y

# The normal to the hubcap
func normalDirection():
	var sign = 1 if isRightWheel else -1
	return global_transform.x * sign

func faceCenterOfTurning(c: Vector2):
	look_at(c)

# Called when the node enters the scene tree for the first time.
func _ready():
	car = get_parent()
	pass # Replace with function body.

func slipForce(angle):
	var limit = 4 * PI / 180
	var slope = 1 / limit
	if (absf(angle) > limit):
		angle = sign(angle) * limit
	return slope * angle

func applyForce(dt):
	var pos = global_position
	var vel: Vector2 = car.velocityAtPosition(pos)
	
	if vel.length() < 0.0001:
		return
	
	var normalDir = normalDirection().normalized()
	var sinSlip = vel.normalized().dot(normalDir)
	var slipAngle = -asin(sinSlip)
	
	var scalarForce = slipForce(slipAngle) * car.weightOnWheel(self) * .1
	var force = normalDir * scalarForce
	lateralForceThisFrame = force
	
	car.apply_force(force, pos)
	
func _draw():
	draw_set_transform_matrix(global_transform.inverse())
	var vel = car.velocityAtPosition(global_position)
	draw_line(
		global_position,
		global_position + lateralForceThisFrame * 5,
		Color.BLUE, 1.0, true
	)
	#draw_line(
	#	global_position,
	#	global_position + vel,
	#	Color.ORANGE, 1.0, true
	#)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	pass
