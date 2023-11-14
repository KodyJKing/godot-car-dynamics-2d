extends Node2D

class_name Wheel

var car: Car

@export var radius = 35.0 
@export var mass = 26.0 # kg
@export var momentOfInertia = mass * radius ** 2
@export var staticFrictionCoef = 0.9
#@export var kineticFrictionCoef = 0.68
@export var kineticFrictionCoef = 0.99
@export var rollingFrictionCoef = kineticFrictionCoef * .1

@export var isRightWheel = false

var angularMomentum = 0.0

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var pos = global_position
	var vel = car.velocityAtPosition(pos)
	var facingDir = forwardDirection()
	var normalDir = normalDirection()
	
	var forwardVel = facingDir.dot(vel)
	var normalVel = normalDir.dot(vel)
	
	var weightOnWheel = car.weightOnWheel(self)
	
	var forwardFriction = weightOnWheel * rollingFrictionCoef * sign(-forwardVel)
	var normalFriction = weightOnWheel * kineticFrictionCoef * sign(-normalVel)
	
	var friction = facingDir * forwardFriction + normalDir * normalFriction
	car.apply_force(friction * .1, pos)
	
	pass
