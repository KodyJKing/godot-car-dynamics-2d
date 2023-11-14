extends RigidBody2D

class_name Car

@onready var body = $RigidBody2D
@onready var wheel_fr: Wheel = $fr
@onready var wheel_fl: Wheel = $fl
@onready var wheel_br: Wheel = $br
@onready var wheel_bl: Wheel = $bl

@onready var wheels = [wheel_fr, wheel_fl, wheel_br, wheel_bl]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func weightOnWheel(wheel: Wheel):
	return mass / 4

func getSignedTurningRadius():
	var t = Time.get_ticks_msec() / 1000.0
	return 100 + (1 + sin(t)) * 100
	#return 10000
	
func rearAxisCenter():
	return (wheel_bl.global_position + wheel_br.global_position) / 2
	
func getCenterOfTurning():
	var c = rearAxisCenter()
	var axleDir = global_rotation + PI / 2
	var axleDir2 = Vector2(cos(axleDir), sin(axleDir))
	return c + axleDir2 * getSignedTurningRadius()

# Computes velocity of a point on the vehicle.
# Given `pos` and returned velocity are in global space.
func velocityAtPosition(pos: Vector2):
	var carPos = global_position
	var r = pos - carPos
	var v = linear_velocity
	var av = angular_velocity
	return Vector2(
		v.x + r.y * av,
		v.y - r.x * av,
	)

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
	var dTheta = 100 / radius
	draw_arc(
		turningCenter, radius,
		toWheelRads - dTheta,
		toWheelRads + dTheta,
		#0, PI * 2,
		100, Color.RED, 2.0, true
	)
	draw_line(
		wheelPos,
		wheelPos + wheel.forwardDirection() * 50,
		Color.BLUE, 1.0, true
	)
	draw_line(
		wheelPos,
		wheelPos + wheel.normalDirection() * 25,
		Color.GREEN, 1.0, true
	)

func _draw():
	var t = Time.get_ticks_msec() / 1000.0
	var s = sin(t); var c = cos(t)
	
	var center = getCenterOfTurning()
	
	draw_set_transform_matrix(global_transform.inverse())
	draw_circle(center, 4, Color.RED)
	
	for wheel in wheels:
		drawWheelState(wheel)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	setWheelRotations()
	
	apply_force(
		global_transform.x * 10000,
		center_of_mass
	)
	
	queue_redraw()
	pass

