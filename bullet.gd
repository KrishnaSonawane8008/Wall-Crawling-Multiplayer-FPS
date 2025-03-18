extends Node3D

const SPEED=5
@onready var bullet_mesh=$MeshInstance3D
@onready var bullet_raycast=$MeshInstance3D/RayCast3D
@onready var bullet_raycast2=$MeshInstance3D/RayCast3D2
@onready var bullet_particles=$GPUParticles3D
# Called when the node enters the scene tree for the first time.
var mech_inst
var Is_Hit=false
var spm

func set_shooter(mech):
	spm=mech

func set_material(Bmat, GPUmat):
	bullet_mesh.set_surface_override_material(0, Bmat)
	bullet_particles.material_override=GPUmat

func _process(_delta):
	position+=transform.basis*Vector3(0,0,SPEED)
	if bullet_raycast.is_colliding():
		if bullet_raycast.get_collider().get_collision_mask()==2 && !Is_Hit:
			#print(get_multiplayer_authority())
			Is_Hit=true
			mech_inst=bullet_raycast.get_collider().get_parent().get_parent()
			mech_inst.receive_damage()
			#spm.change_enem_healthbar(mech_inst.healthval)
			#mech_inst.receive_damage.rpc_id(mech_inst.get_multiplayer_authority())
		bullet_particles.global_position=bullet_raycast.get_collision_point()
		bullet_particles.emitting=true
		bullet_mesh.visible=false
		await get_tree().create_timer(1.0).timeout
		queue_free()
	elif( bullet_raycast2.is_colliding()):
		if bullet_raycast2.get_collider().get_collision_mask()==2 && !Is_Hit:
			#print(get_multiplayer_authority())
			Is_Hit=true
			mech_inst=bullet_raycast2.get_collider().get_parent().get_parent()
			mech_inst.receive_damage()
			#spm.change_enem_healthbar(mech_inst.healthval)
			#mech_inst.receive_damage.rpc_id(mech_inst.get_multiplayer_authority())
		bullet_particles.global_position=bullet_raycast2.get_collision_point()
		bullet_particles.emitting=true
		bullet_mesh.visible=false
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout():
	queue_free()
