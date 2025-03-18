extends Node3D


@onready var mainmenu=$CanvasLayer/MainMenu
@onready var address_entry=$CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var MultiplayerMapMesh=$MultiplayerMap


@onready var HealthBar=$CanvasLayer/Control/ProgressBar
@onready var EnemyHealthBar=$CanvasLayer/Control/EnemyHealth/HitPlayer_ProgressBar

@onready var HBBgNoComp=$CanvasLayer/Control/HmBackgroundNoComp
@onready var HBHbg=$CanvasLayer/Control/HmHealthBg
@onready var HBHbarCover=$CanvasLayer/Control/HmHealthbarCover

@onready var ENMHBHbg=$CanvasLayer/Control/EnemyHealth/HitPlayerHealthBG
@onready var ENMHBHbarCover=$CanvasLayer/Control/EnemyHealth/HitPlayerHealthCover

@onready var health_container=$CanvasLayer/Control
@onready var Enemy_health_Container=$CanvasLayer/Control/EnemyHealth

@onready var timer=$CanvasLayer/Control/EnemyHealth/Timer

var player_array=[]

var mdt=MeshDataTool.new()
var map_mesh_info={}

var any_count=0
var any_div=3

const BlueStyle=preload("res://HealthBar Styles/BlueHealth.stylebox")
const RedStyle=preload("res://HealthBar Styles/RedHealth.stylebox")
const GoldStyle=preload("res://HealthBar Styles/GoldHealth.stylebox")
var Healthbar_styles=[BlueStyle, RedStyle, GoldStyle]

var HBBG=[Color("#0000a2"), Color("#b20000"), Color("#5c2e00")]

var HBCover=[Color("#2864ff"), Color.RED, Color("#ff8a00")]

const Bluemat1=preload("res://Player Skins/BlueSkin.material")
const Redmat1=preload("res://Player Skins/RedSkin.material")
const Goldmat1=preload("res://Player Skins/GoldenSkin.material")
var mat_list1=[Bluemat1, Redmat1, Goldmat1]#main body material

const Bluemat2=preload("res://Player Skins/BlueSkin(2).material")
const Redmat2=preload("res://Player Skins/RedSkin(2).material")
const Goldmat2=preload("res://Player Skins/GoldenSkin(2).material")
var mat_list2=[Bluemat2, Redmat2, Goldmat2]#Gun & Leg body material

const BBlue=preload("res://Bullet Skins/BlueBullet.tres")
const BRed=preload("res://Bullet Skins/RedBullet.tres")
const BGold=preload("res://Bullet Skins/GoldenBullet.tres")
var Bmat_list=[BBlue, BRed, BGold]


var player_scene=0
const Player1=preload("res://spider_mech(2).tscn")
#const Player2=preload("res://spider_mech_red.tscn")
var player_types=[Player1]
const PORT=9999
var enet_peer=ENetMultiplayerPeer.new()


var temp_health=100



#func _ready():
	#var map_ArrayMesh=_convertToArrayMesh(map_mesh.mesh)
	#for surf in range(map_ArrayMesh.get_surface_count()):
		#mdt.create_from_surface(map_ArrayMesh, surf)
		#for face in range(mdt.get_face_count()):
			#print(mdt.get_face_normal(face))
	

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	



func _on_host_button_pressed():
	mainmenu.hide()
	health_container.show()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer=enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	

func _on_join_button_pressed():
	mainmenu.hide()
	health_container.show()
	enet_peer.create_client("localhost",PORT)
	multiplayer.multiplayer_peer=enet_peer
	
func add_player(peer_id):
	var player=Player1.instantiate()
	player_scene+=0
	player.name=str(peer_id)
	player.set_multiplayer_authority(peer_id)
	player.MultiplayerMap=MultiplayerMapMesh
	add_child(player)
	player_array.append(player)
	player.set_mat(mat_list1[any_count%any_div], mat_list2[any_count%any_div], Bmat_list[any_count%any_div])
	if player.is_multiplayer_authority():
		HBBgNoComp.self_modulate=HBBG[any_count%any_div]
		HBHbg.self_modulate=HBBG[any_count%any_div]
		HBHbarCover.self_modulate=HBCover[any_count%any_div]
		HealthBar.add_theme_stylebox_override("fill", Healthbar_styles[any_count%any_div])
		player.damaged.connect(change_healthbar)
		player.Ehealth.connect(print_enemy_health)
	any_count+=1
	player.set_ANYCOUNT(any_count)
	#print("peer_id=",peer_id,", multiplayer.get_unique_id()=",multiplayer.get_unique_id())

func _on_multiplayer_spawner_spawned(node):
	player_array.append(node)
	node.set_mat(mat_list1[any_count%any_div], mat_list2[any_count%any_div], Bmat_list[any_count%any_div])
	node.Initialize_Player_Spawn(MultiplayerMapMesh)
	if node.is_multiplayer_authority():
		HBBgNoComp.self_modulate=HBBG[any_count%any_div]
		HBHbg.self_modulate=HBBG[any_count%any_div]
		HBHbarCover.self_modulate=HBCover[any_count%any_div]
		HealthBar.add_theme_stylebox_override("fill", Healthbar_styles[any_count%any_div])
		node.damaged.connect(change_healthbar)
		node.Ehealth.connect(print_enemy_health)
	any_count+=1
	node.set_ANYCOUNT(any_count)

func change_healthbar(health_value):
	HealthBar.value=health_value
	#spm.PB.value=HealthBar.value
	#spm.set_enem_health(HealthBar.value, spm)
	#spm.set_enem_health(health_value, spm)

func print_enemy_health(enemy_health, AnyCount):

	EnemyHealthBar.value=enemy_health
		#timer.stop()
	ENMHBHbg.self_modulate=HBBG[AnyCount%any_div]
	ENMHBHbarCover.self_modulate=HBCover[AnyCount%any_div]
	EnemyHealthBar.add_theme_stylebox_override("fill", Healthbar_styles[AnyCount%any_div])
	Enemy_health_Container.show()
	timer.start()

func _on_timer_timeout():
	Enemy_health_Container.hide()


func remove_player(peer_id):
	var player=get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _convertToArrayMesh(mesh: Mesh):
	var surface_tool := SurfaceTool.new()
	var new_mesh = ArrayMesh.new()

	# Loop through the surfaces of the input mesh and create an array-based mesh.
	for i in range(mesh.get_surface_count()):
		surface_tool.create_from(mesh, i)
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_tool.commit().surface_get_arrays(0))
		new_mesh.surface_set_material(i, mesh.surface_get_material(i))

	return new_mesh



