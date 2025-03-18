extends Node3D

@export var offset: float = 2

@onready var parent = get_parent_node_3d()
@onready var previous_position = parent.global_position

func _process(_delta):
	if not is_multiplayer_authority(): return
	#if Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		#if offset<=10:
			#offset+=1
		#else:
			#offset=0
	#else:
		##if offset>0:
		#offset=0
	var MoveDirection = (parent.global_position - previous_position).normalized()
	global_position = parent.global_position + MoveDirection * offset
	previous_position = parent.global_position
		
	
