extends Node2D

class_name Wheel

var car: Car

var radius = 35.0 
var mass = 26.0 # kg
var staticFrictionCoef = 0.9
var kineticFrictionCoef = 0.68
var rollingFrictionCoef = kineticFrictionCoef * .01
var isRightWheel = false

var angularMomentum = 0.0
var momentOfInertia = mass * radius ** 2

var impulseAppliedThisFrame = Vector2(0,0)

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

func solverStartFrame():
	impulseAppliedThisFrame = Vector2(0,0)

func solveNormalImpulse(dt, scaleImpulse):
	var pos = global_position
	var vel = car.velocityAtPosition(pos)
	var normalDir = normalDirection()
	
	var normalVel = vel.dot(normalDir)
	
	var weightOnWheel = car.weightOnWheel(self)
	
	var maxForce = weightOnWheel * staticFrictionCoef
	var maxImpulse = maxForce * dt
	
	var impulse = -normalVel * car.effectiveMass(pos, normalDir) * scaleImpulse
	if impulse > maxImpulse:
		impulse = weightOnWheel * dt * kineticFrictionCoef * sign(impulse) * scaleImpulse
	
	var impulseVec = normalDir * impulse
	impulseAppliedThisFrame += impulseVec
	
	car.apply_impulse(impulseVec, pos)

func _draw():
	draw_set_transform_matrix(global_transform.inverse())
	draw_line(
		global_position,
		global_position + impulseAppliedThisFrame * 20,
		Color.BLUE, 1.0, true
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	pass
