extends RigidBody2D

class_name Car

const math = preload("res://assets/math.gd")

@onready var body = $RigidBody2D
@onready var wheel_fr: Wheel = $fr
@onready var wheel_fl: Wheel = $fl
@onready var wheel_br: Wheel = $br
@onready var wheel_bl: Wheel = $bl

#@onready var wheels = [wheel_fr, wheel_fl, wheel_br, wheel_bl]
@onready var wheels = [wheel_br, wheel_bl, wheel_fr, wheel_fl]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func weightOnWheel(wheel: Wheel):
	return mass / 4

func steeringPos():
	var t = Time.get_ticks_msec() / 1000.0
	#return 0.01 
	return sin(t * .5) * .005

func getSignedTurningRadius():
	return 1 / tan(steeringPos())
	
func rearAxisCenter():
	return (wheel_bl.global_position + wheel_br.global_position) / 2
	
func getCenterOfTurning():
	var c = rearAxisCenter()
	var axleDir = global_transform.y
	return c + axleDir * getSignedTurningRadius()

# Computes velocity of a point on the vehicle.
# Given `pos` and returned velocity are in global space.
func velocityAtPosition(pos: Vector2):
	var carPos = global_transform * center_of_mass
	var r = pos - carPos
	var v = linear_velocity
	var av = angular_velocity
	return Vector2(
		v.x - r.y * av,
		v.y + r.x * av,
	)

# The effective mass felt by a force pushing at `pos` in direction `dir`.
func effectiveMass(pos: Vector2, dir: Vector2):
	var offset = pos - global_position
	var r = math.cross2D(offset, dir)
	return 1 / ( 1 / mass + r ** 2 / inertia )

func setWheelRotations():
	var center = getCenterOfTurning()
	wheel_fr.faceCenterOfTurning(center)
	wheel_fl.faceCenterOfTurning(center)

func drawWheelState(wheel: Node2D):
	var wheelPos = wheel.global_position
	var turningCenter = getCenterOfTurning()
	var toWheel = wheelPos - turningCenter
	var toWheelRads = toWheel.angle()
	var radius = toWheel.length()
	var dTheta = 50 / radius
	draw_arc(
		turningCenter, radius,
		toWheelRads - dTheta,
		toWheelRads + dTheta,
		#0, PI * 2,
		100, Color.RED, 2.0, true
	)
	#draw_line(
	#	wheelPos,
	#	wheelPos + wheel.forwardDirection() * 50,
	#	Color.BLUE, 1.0, true
	#)
	#draw_line(
	#	wheelPos,
	#	wheelPos + wheel.normalDirection() * 25,
	#	Color.GREEN, 1.0, true
	#)

func _draw():
	var t = Time.get_ticks_msec() / 1000.0
	var s = sin(t); var c = cos(t)
	
	var center = getCenterOfTurning()
	
	draw_set_transform_matrix(global_transform.inverse())
	
	var cm = global_transform * center_of_mass
	draw_circle(cm, 4, Color.GREEN)
	
	draw_line(
		cm, cm + linear_velocity,
		Color.GREEN, 2.0, true
	)
	
	draw_circle(center, 4, Color.RED)
	
	for wheel in wheels:
		drawWheelState(wheel)
	
func _process(delta):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	setWheelRotations()
	
	apply_central_force(
		global_transform.x * mass * 2.0
	)
	
	for wheel in wheels:
		wheel.applyForce(delta)
	
	queue_redraw()
	pass

