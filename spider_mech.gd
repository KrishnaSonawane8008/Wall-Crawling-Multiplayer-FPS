extends Node3D

signal damaged(health_value)
signal Ehealth(enemy_health_val, AnyCount)

var initial_value: float=15
var diagonal: float=initial_value/(2**(0.5))

@export var turn_speed: float = 2
@export var ground_offset: float = 1.4

var Debug_Cube=preload("res://just_a_cube.tscn")
var Debug_cube_inst_list=[]


@onready var CamRay=$Camera3D/CamRay

@onready var Idle_pos=$Camera3D/Idle_marker
@onready  var self_hit_box=$Armature_Centre/StaticBody3D

@onready var Camera=$Camera3D
@onready var armature_cen=$Armature_Centre
@onready var PlayerRef=$SpiderMechBasisRef
@onready var Movable_Char=$"Movable Char"
@onready var anim_player=$AnimationPlayer
var transform_basisX=transform.basis.x
var transform_basisZ=transform.basis.z

var Bullet=preload("res://bullet.tscn")

@onready var barrel_raycast=$Armature_Centre/BulletSpawn
@onready var barrel_raycast_indic=$Armature_Centre/BulletSpawn/MeshInstance3D

@onready var barrel_raycast2=$Armature_Centre/BulletSpawn2
@onready var barrel_raycast_indic2=$Armature_Centre/BulletSpawn2/MeshInstance3D

@onready var harpoon_path=$Armature_Centre/harpoon_container
@onready var harpoon_hit_ray=$Armature_Centre/harpoon_container/Harpoon_target_ray
@onready var harpoon_StartPosRef=$Armature_Centre/Harpoon_Anchor
var harpoon_shot=preload("res://HarpoonAnchor.tscn")
var HitPoint=preload("res://HarpoonCenter.tscn")
var instance
var health=100
var enemy_health=100

@onready var main_mesh=$Armature_Centre/Armature/Skeleton3D2/MainBody
@onready var barrel_mesh2=$Armature_Centre/Armature/Skeleton3D2/ShortBarrel
@onready var barrel_mesh1=$Armature_Centre/Armature/Skeleton3D2/ShortBarrel/LongBarrel
@onready var GunHolder1=$Armature_Centre/Armature/Skeleton3D2/GunHolder1
@onready var GunHolder2=$Armature_Centre/Armature/Skeleton3D2/GunHolder2
@onready var HarpoonHolder=$Armature_Centre/Armature/Skeleton3D2/HarpoonHolder
@onready var MissileHolder1=$Armature_Centre/Armature/Skeleton3D2/MissileHolder1
@onready var MissileHolder2=$Armature_Centre/Armature/Skeleton3D2/MissileHolder2
var any_number=0

@onready var SpiderRaysContainer=$SpiderRays
@onready var fl_leg = $SpiderRays/FLSpiderLeg
@onready var fr_leg = $SpiderRays/FRSpiderLeg
@onready var bl_leg = $SpiderRays/BLSpiderLeg
@onready var br_leg = $SpiderRays/BRSpiderLeg



@onready var fl_leg_IK = $Armature_Centre/Armature/FrontLeft 
@onready var fr_leg_IK = $Armature_Centre/Armature/FrontRight
@onready var bl_leg_IK = $Armature_Centre/Armature/BackLeft
@onready var br_leg_IK = $Armature_Centre/Armature/BackRight

@onready var FLStepTarget_Marker=$StepTarget/FrontLeftStep
@onready var FRStepTarget_Marker=$StepTarget/FrontRightStep
@onready var BLStepTarget_Marker=$StepTarget/BackLeftStep
@onready var BRStepTarget_Marker=$StepTarget/BackRightStep


@onready var arm_marker=$Arm_Cen_pos #dont remove the Arm_Cen_pos node, it is controlling the armature position wrt spider mech node

@onready var spooder_mech=$"."

@onready var Any_Count

@onready var EG_HealthBG=$HealthBar_EG

var bullet_mat
var bullet_gpu_mat
var hit_indicator_list=[]

var harpoon
var harpoon_inst_list=[]

#===========================================Walking On Mesh===================================================
var MultiplayerMap
var WalkingAPI=WalkOnSortedSurface.new("res://MultiplayerMap_MeshSortingData.cfg")
var mdt = MeshDataTool.new()
#var HF=HelperFunctions.new(self)

var MainScale
var current_face=1208
#=============================================================================================================

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func set_ANYCOUNT(any_count):
	Any_Count=any_count-1

func Initialize_Player_Spawn(MM):
	MainScale=MM.scale
	
	mdt.create_from_surface(MM.mesh, 0)
	WalkingAPI.Put_Player_on_Centroid_of_Face( 1208, MainScale, self, mdt )
	global_position=global_position+transform.basis.y.normalized()*1.5
	armature_cen.global_position=arm_marker.global_position
	WalkingAPI.Put_Player_on_Centroid_of_Face( 1208, MainScale, PlayerRef, mdt )


func _ready():
	if not is_multiplayer_authority(): return
	if(MultiplayerMap!=null):
		MainScale=MultiplayerMap.scale
		
		mdt.create_from_surface(MultiplayerMap.mesh, 0)
		WalkingAPI.Put_Player_on_Centroid_of_Face( 1208, MainScale, self, mdt )
		global_position=global_position+transform.basis.y.normalized()*1.5
		armature_cen.global_position=arm_marker.global_position
		WalkingAPI.Put_Player_on_Centroid_of_Face( 1208, MainScale, PlayerRef, mdt )
	
	Camera.current=true
	#Movable_Char.Camera.current=true
	Movable_Char.global_position=Camera.global_position+Camera.transform.basis.z.normalized()*5
	CamRay.add_exception(self_hit_box)
	
	#Input.mouse_mode=Input.MOUSE_MODE_CAPTURED


func set_mat(mat1, mat2, Bullet_mat):
	main_mesh.set_surface_override_material(1,mat1)
	main_mesh.set_surface_override_material(0,mat2)
	barrel_mesh1.set_surface_override_material(0,mat2)
	barrel_mesh2.set_surface_override_material(0,mat2)
	GunHolder1.set_surface_override_material(0,mat2)
	GunHolder2.set_surface_override_material(0,mat2)
	HarpoonHolder.set_surface_override_material(0,mat2)
	MissileHolder1.set_surface_override_material(0,mat2)
	MissileHolder2.set_surface_override_material(0,mat2)
	bullet_mat=Bullet_mat
	bullet_gpu_mat=Bullet_mat

var Arm_Cen_basis=transform.basis
var Grappling=false
var ShouldLerp=true
var prev_col1
var prev_col2
var prev_col3
var prev_col4
func _process(_delta):
	if not is_multiplayer_authority(): return
	#======================DESPAWNING_CUBES======================
	#Despawn_Debug_cube.rpc()
	#======================DESPAWNING_CUBES======================
	if Input.is_action_just_pressed("shift"):
		harpoon_path.visible=true
	if Input.is_action_just_released("shift"):
		harpoon_path.visible=false
	if Grappling:
		harpoon_path.visible=false
	

	
	Arm_Cen_basis=transform.basis

	if Input.is_action_pressed("up"):
		WalkingAPI.Add_input("Back")
	if Input.is_action_pressed("down"):
		WalkingAPI.Add_input("Front")
	if Input.is_action_pressed("left"):
		WalkingAPI.Add_input("Right")
	if Input.is_action_pressed("right"):
		WalkingAPI.Add_input("Left")
	var Final_Dir=WalkingAPI.Get_Final_Direction()
	
	var UPAxisAngle=0
	SpiderRaysContainer.global_transform.basis=transform.basis
	SpiderRaysContainer.global_position=global_position
	if(Final_Dir!="None" && !Grappling):
		var intersection_pt=WalkingAPI.get_next_move(PlayerRef, Final_Dir, current_face, 0.3, MainScale, mdt)
		if(intersection_pt!=null):
				current_face=intersection_pt["Finalpt"][-1]
				var NextMove=WalkingAPI.Get_next_Face_Pos_And_Basis( current_face, Final_Dir, intersection_pt, PlayerRef, mdt )
				
				#global_position=NextMove["NextPos"]+transform.basis.y.normalized()*1.5
				var prev_up=PlayerRef.transform.basis.y.normalized()
				var next_up=NextMove["NextBasis"].y.normalized()
				UPAxisAngle=rad_to_deg(prev_up.angle_to(next_up))
				PlayerRef.global_position=NextMove["NextPos"]
				PlayerRef.transform.basis=NextMove["NextBasis"]
				global_position=PlayerRef.global_position + (( PlayerRef.transform.basis.y.normalized() )*1.5)
				
		else:
			print("======================================================================")
			print("Null intersects")
			print("Intersects: ", intersection_pt)
			print("======================================================================")
	
	
	if(Final_Dir!="None" && !Grappling):
		var intersection_pt=WalkingAPI.get_next_move(PlayerRef, Final_Dir, current_face, 2, MainScale, mdt)
		if(intersection_pt!=null):
				var NextMove=WalkingAPI.Get_next_Face_Pos_And_Basis( current_face, Final_Dir, intersection_pt, PlayerRef, mdt )
				SpiderRaysContainer.global_transform.basis=NextMove["NextBasis"]
				SpiderRaysContainer.global_position=NextMove["NextPos"]+(SpiderRaysContainer.global_transform.basis.y.normalized()*1.5)
		else:
			print("======================================================================")
			print("Null intersects")
			print("Intersects: ", intersection_pt)
			print("======================================================================")
	if(fl_leg.collision_point && fr_leg.collision_point && bl_leg.collision_point && br_leg.collision_point ):
		FLStepTarget_Marker.global_position=fl_leg.collision_point
		FRStepTarget_Marker.global_position=fr_leg.collision_point
		BLStepTarget_Marker.global_position=bl_leg.collision_point
		BRStepTarget_Marker.global_position=br_leg.collision_point
	
	#print(UPAxisAngle/180)
	
	if ShouldLerp:
		UPAxisAngle=rad_to_deg((transform.basis.y.normalized()).angle_to(PlayerRef.transform.basis.y.normalized()))
		
		var LerpedBasis=lerp( transform.basis.orthonormalized(), PlayerRef.transform.basis.orthonormalized(), UPAxisAngle*0.8/180)
		LerpedBasis.x*=scale.x
		LerpedBasis.y*=scale.y
		LerpedBasis.z*=scale.z
		transform.basis=LerpedBasis
		Arm_Cen_basis=LerpedBasis
	
	
	if(harpoon_inst_list.size()==1 && harpoon!=null):
		if(harpoon.Anchored):
			Grappling=true
			#Spawn_Debug_cube(harpoon.Anchor.global_position)
			var Dir_towards_Anchor=(harpoon.Anchor.global_position-harpoon_StartPosRef.global_position).normalized()
			var DistanceFromAnchor=(harpoon.Anchor.global_position).distance_to(harpoon_StartPosRef.global_position )
			#print(DistanceFromAnchor)
			if DistanceFromAnchor>2:
				global_position=global_position+(Dir_towards_Anchor*0.5)
			else:
				ShouldLerp=true
				global_position=PlayerRef.global_position + (( PlayerRef.transform.basis.y.normalized() )*1.5)
				del_harpoon.rpc()
				Grappling=false
	#dont remove the Arm_Cen_pos node, it is controlling the armature position wrt spider mech node
	armature_cen.global_position=arm_marker.global_position
	
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if anim_player.current_animation!="shooting":
			if Input.is_action_pressed("shift") && !Grappling:
				if harpoon_path.visible:
					if harpoon_hit_ray.is_colliding():
						WalkingAPI.Put_Player_on_Face(harpoon_hit_ray.get_collision_point(),
													  harpoon_hit_ray.get_collision_face_index(),
													  PlayerRef, mdt)
						current_face=harpoon_hit_ray.get_collision_face_index()
						Grappling=true
						ShouldLerp=false
						#WalkingAPI.Put_Player_on_Centroid_of_Face( 1208, MainScale, PlayerRef, mdt )
						Shoot_Harpoon.rpc(harpoon_hit_ray.get_collision_point())
			else:
				Shoot.rpc()



	for i in hit_indicator_list:
		i.queue_free()
	hit_indicator_list.clear()
	if harpoon_path.visible:
		if harpoon_hit_ray.is_colliding():
			harpoon_path.get_child(1).get_active_material(0).set_emission( Color(0, 0.62, 0.81) )
			var hitpt=HitPoint.instantiate()
			get_parent().add_child(hitpt)
			hit_indicator_list.append(hitpt)
			hitpt.visible=true
			hitpt.global_position=harpoon_hit_ray.get_collision_point()
			var HitIndicatorDist=(harpoon_StartPosRef.global_position).distance_to(hitpt.global_position)
			hitpt.scale*=HitIndicatorDist*0.07
			hitpt.transform.basis=_basis_from_normal_specific(harpoon_hit_ray.get_collision_normal(), hitpt)
		else:
			harpoon_path.get_child(1).get_active_material(0).set_emission( Color.RED )
	
	change_rope.rpc()

@rpc("call_local")
func Spawn_Debug_cube(pos):
	var DCube= Debug_Cube.instantiate()
	get_parent().add_child(DCube)
	DCube.global_position=pos
	Debug_cube_inst_list.append(DCube)

@rpc("call_local")
func Despawn_Debug_cube():
	for i in Debug_cube_inst_list:
		i.queue_free()
	Debug_cube_inst_list.clear()

@rpc("call_local")
func change_rope():
	if(harpoon_inst_list.size()==1 && harpoon!=null):
		harpoon.Rope.global_position=harpoon_StartPosRef.global_position
		harpoon.start_pos=harpoon_StartPosRef.global_position
#func put_hit_indicator(hit_location, normal):

@rpc("call_local")
func del_harpoon():
	for i in harpoon_inst_list:
		i.queue_free()
	harpoon_inst_list.clear()

func _physics_process(_delta):
	
	var CR_hitPt=CamRay.get_collision_point()
	var New_Front_Dir
	if CamRay.get_collider()==null:
		New_Front_Dir=(Idle_pos.global_position-armature_cen.global_position).normalized()
		var new_basis=Basis()
		new_basis.z=New_Front_Dir
		new_basis.x=(Arm_Cen_basis.y.normalized()).cross(New_Front_Dir)
		new_basis.y=New_Front_Dir.cross( new_basis.x.normalized() ) 
		armature_cen.transform.basis=new_basis.orthonormalized()
	else:
		New_Front_Dir=(CR_hitPt-armature_cen.global_position).normalized()
		var new_basis=Basis()
		new_basis.z=New_Front_Dir
		new_basis.x=(Arm_Cen_basis.y.normalized()).cross(New_Front_Dir)
		new_basis.y=New_Front_Dir.cross( new_basis.x.normalized() ) 
		armature_cen.transform.basis=new_basis.orthonormalized()




func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	
	if Input.is_action_pressed("right_click"):
		if event is InputEventMouseMotion:
			rotate_object_local(Vector3.UP ,-event.relative.x*0.0025)
			PlayerRef.rotate_object_local(Vector3.UP ,-event.relative.x*0.0025)
			armature_cen.rotate_object_local(Vector3.UP ,-event.relative.x*0.0025)
			Camera.rotate_object_local(Vector3(1,0,0),event.relative.y*0.001)
			#Camera.global_position=Camera.global_position+(transform.basis.y.normalized()*(-event.relative.y*0.001))
			Camera.rotation.x=clamp(Camera.rotation.x, -PI/8.5,PI/5)
	
	if Input.is_key_pressed(KEY_CTRL):
		if Input.is_key_pressed(KEY_SHIFT):
			if Input.is_key_pressed(KEY_C):
				Movable_Char.Camera.current=true
	if Input.is_key_pressed(KEY_CTRL):
		if Input.is_key_pressed(KEY_SHIFT):
			if Input.is_key_pressed(KEY_Z):
				Movable_Char.Camera.current=false
			
	




func _basis_from_normal_specific(normal: Vector3, TheNode) -> Basis:
	#=====================================================================
	var result = Basis()
	#print(normal)
	result.x = normal.cross(TheNode.transform.basis.z)
	result.y = normal
	result.z = TheNode.transform.basis.x.cross(normal)

	result = result.orthonormalized()
	result.x *= TheNode.scale.x
	result.y *= TheNode.scale.y
	result.z *= TheNode.scale.z
	
	return result
	#=====================================================================
	

func receive_damage():
	health-=1
	if health<=0:
		health=100
		if(MainScale!=null):
			WalkingAPI.Put_Player_on_Centroid_of_Face( 1208, MainScale, self, mdt )
			global_position=global_position+transform.basis.y.normalized()*1.5
			armature_cen.global_position=arm_marker.global_position
			WalkingAPI.Put_Player_on_Centroid_of_Face( 1208, MainScale, PlayerRef, mdt )
			current_face=1208
	damaged.emit(health)
	
func display_enemy_health(health_val, any_Count):
	Ehealth.emit(health_val, any_Count)

@rpc("call_local")
func Shoot():
	anim_player.play("shooting")
	instance=Bullet.instantiate()
	get_parent().add_child(instance)
	instance.bullet_raycast.add_exception(self_hit_box)
	instance.bullet_raycast2.add_exception(self_hit_box)
	instance.global_position=barrel_raycast.global_position
	instance.global_transform.basis=barrel_raycast.global_transform.basis
	instance.set_shooter(spooder_mech)
	instance.set_material(bullet_mat, bullet_gpu_mat)
	
	#print(get_multiplayer_authority())
	instance=Bullet.instantiate()
	get_parent().add_child(instance)
	instance.bullet_raycast.add_exception(self_hit_box)
	instance.bullet_raycast2.add_exception(self_hit_box)
	instance.global_position=barrel_raycast2.global_position
	instance.global_transform.basis=barrel_raycast2.global_transform.basis
	instance.set_shooter(spooder_mech)
	instance.set_material(bullet_mat, bullet_gpu_mat)

@rpc("call_local")
func Shoot_Harpoon(collision_pt):
	anim_player.play("shooting")
	for i in harpoon_inst_list:
		i.queue_free()
	harpoon_inst_list.clear()
	harpoon=harpoon_shot.instantiate()
	var travel_dist=harpoon_StartPosRef.global_position.distance_to(collision_pt)
	harpoon.distance=travel_dist
	harpoon.start_pos=harpoon_StartPosRef.global_position
	get_parent().add_child(harpoon)
	
	harpoon_inst_list.append(harpoon)
	harpoon.Anchor.global_position=harpoon_StartPosRef.global_position
	harpoon.Rope.global_position=harpoon_StartPosRef.global_position
	harpoon.set_rope_material(bullet_mat)
	harpoon.Rope.visible=true
	harpoon.Anchor.global_transform.basis=harpoon_StartPosRef.global_transform.basis
