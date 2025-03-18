extends Node

class_name WalkOnSortedSurface

var Face_Dict
#{ CurrentFace:[ [Face_OppTo_Edge0ofCurrentFace, EdgeofOppFace_OppTo_Edge0ofCurrentFace], 
#                [Face_OppTo_Edge1ofCurrentFace, EdgeofOppFace_OppTo_Edge1ofCurrentFace], 
#                [Face_OppTo_Edge2ofCurrentFace, EdgeofOppFace_OppTo_Edge2ofCurrentFace] ], .......................  }

func _init(CFG_location):
	Face_Dict=get_FaceDict_from_CFG(CFG_location)

func get_next_move(PlayerNode, Final_Dir, Starting_Face: int, Distance: float, Scale: Vector3, MDT: MeshDataTool):
	
	var Player_Pos=PlayerNode.global_position
	var TopDirection=PlayerNode.transform.basis.y
	var FrontDirection_Info=Get_PlayerDirectionPlane_W_PlayerDirection(Final_Dir, PlayerNode)
	
	var SideDirection=FrontDirection_Info["Direction"].cross(TopDirection)
	var SidePlane=Plane(Player_Pos, Player_Pos+SideDirection.normalized(), Player_Pos+TopDirection.normalized())
	var IntersectionsWPlane=get_First_Intersection_with_Plane(Starting_Face, MDT, FrontDirection_Info["Plane"], Scale)
	var First_pt
	for i in IntersectionsWPlane:
		if(SidePlane.is_point_over( i[0] )):
			First_pt=i
			break
	if(First_pt!=null):
		if(Player_Pos.distance_to(First_pt[0])==Distance):
			return {"Finalpt":[Starting_Face], "PointArr":[[Player_Pos, First_pt[0]]]}
		elif(Player_Pos.distance_to(First_pt[0])>Distance):
			var First_path_Dir=(First_pt[0]-Player_Pos).normalized()
			return {"Finalpt":[Starting_Face], "PointArr":[[Player_Pos, Player_Pos+(First_path_Dir*Distance)]]}
		else:
			var Final_pt=[]
			var point_arr=[]
			Final_pt.append(Starting_Face)
			point_arr.append([Player_Pos, First_pt[0]]) 
			while(true):
				if( ( Distance-( Player_Pos.distance_to(First_pt[0]) ) ) > 0):
					Distance=Distance-Player_Pos.distance_to(First_pt[0])
					Final_pt.append(Starting_Face)
					point_arr.append([Player_Pos, First_pt[0]])
					var opp_face=Face_Dict[Starting_Face][First_pt[1]][0]
					var opp_edge=Face_Dict[Starting_Face][First_pt[1]][1]
					var intersects=get_Intersections_with_Plane(opp_face, opp_edge, MDT, FrontDirection_Info["Plane"], Scale)
					
					if(intersects!=null):
						var Second_start=intersects[0][0]
						var Second_end=intersects[1][0]
						var Second_edge=intersects[1][1]
					
						Player_Pos=Second_start
						Starting_Face=opp_face
						First_pt=[Second_end, Second_edge]
					else:
						return intersects
					
				else:
					var final_direct=(First_pt[0]-Player_Pos).normalized()
					Final_pt.append(Starting_Face)
					point_arr.append([Player_Pos, Player_Pos+final_direct*Distance ])
					break
					
			return {"Finalpt":Final_pt, "PointArr":point_arr}
#Finalpt:  [            Face0,                       Face1,                     Face2,                      Face3,................... ]
#PointArr: [ [StartOnFace0, EndOnFace0], [StartOnFace1, EndOnFace1], [StartOnFace2, EndOnFace2], [StartOnFace3, EndOnFace3],......... ]




func get_FaceDict_from_CFG(CFG_location):
	var cfg=ConfigFile.new()
	var Err=cfg.load(CFG_location)
	if Err!=OK:
		print("ERROR WHILE RETRIVING FROM CFG")
	else:
		var face_dict=cfg.get_value("walking_surface", "Face_Dict", "Error")
		if(typeof(face_dict)!=TYPE_STRING && face_dict.size()>0):
			return face_dict

#=========================================================HELPER FUNCTIONS======================================================================

#=======================================================FROM HELPER FUNCTIONS CLASS==================================================================
func get_Normal_Aligned_Basis(Normal, Instance):
	var rot_axis=((Instance.transform.basis.y.normalized()).cross(Normal.normalized())).normalized()
	if(Vector3(abs(rot_axis.x), abs(rot_axis.y), abs(rot_axis.z))!=Vector3(0,0,0) && !is_VecEqual_Approx(Instance.transform.basis.y, Normal, 5)):
		#print("Rotation Axis Addition: ",rot_axis.normalized().x+rot_axis.normalized().y+rot_axis.normalized().z)
		var angle= (Instance.transform.basis.y.normalized()).angle_to(Normal.normalized())
		var quat= Quaternion( rot_axis.normalized(), angle )
		var quat_mult=quat*Instance.transform.basis.get_rotation_quaternion()
		var result=Basis(quat_mult)

		result.x *= Instance.scale.x
		result.y *= Instance.scale.y
		result.z *= Instance.scale.z
		
		return result
	else:
		return Instance.transform.basis
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
func is_VecEqual_Approx(vec1, vec2, digits):
	if( round_to_dec(vec1.x, digits)==round_to_dec(vec2.x, digits) && round_to_dec(vec1.y, digits)==round_to_dec(vec2.y, digits) && round_to_dec(vec1.z, digits)==round_to_dec(vec2.z, digits) ):
		return true
	else:
		return false
		
		
func Get_PlayerDirectionPlane_W_PlayerDirection(Direction, Player_Node):
	if(Direction=="Front"):
		return {"Plane": Plane(Player_Node.transform.origin, 
					 		   Player_Node.transform.origin + Player_Node.transform.basis.y.normalized(), 
					 		   Player_Node.transform.origin - Player_Node.transform.basis.z.normalized()),
				"Direction": -Player_Node.transform.basis.z.normalized() 
				}
					
	elif(Direction=="Right"):
		return {"Plane": Plane(Player_Node.transform.origin,
				 	 		   Player_Node.transform.origin + Player_Node.transform.basis.y.normalized(), 
				 	 		   Player_Node.transform.origin + Player_Node.transform.basis.y.cross(Player_Node.transform.basis.z).normalized()),
				"Direction": Player_Node.transform.basis.y.cross(Player_Node.transform.basis.z).normalized() 
				}
					
	elif(Direction=="Left"):
		return {"Plane": Plane(Player_Node.transform.origin,
				 	 		   Player_Node.transform.origin + Player_Node.transform.basis.y.normalized(), 
				 	 		   Player_Node.transform.origin - Player_Node.transform.basis.y.cross(Player_Node.transform.basis.z).normalized()),
				"Direction": -Player_Node.transform.basis.y.cross(Player_Node.transform.basis.z).normalized() 
				}
					
	elif(Direction=="Back"):
		return {"Plane": Plane(Player_Node.transform.origin,
				 	 		   Player_Node.transform.origin + Player_Node.transform.basis.y.normalized(), 
				 	 		   Player_Node.transform.origin + Player_Node.transform.basis.z.normalized()),
				"Direction": Player_Node.transform.basis.z.normalized() 
				}
					
	elif(Direction=="Front-Right"):
		return {"Plane": Plane(Player_Node.transform.origin,
				 	 Player_Node.transform.origin + Player_Node.transform.basis.y.normalized(), 
				 	 Player_Node.transform.origin + (-Player_Node.basis.z+Player_Node.basis.x).normalized()),
				"Direction": (-Player_Node.basis.z+Player_Node.basis.x).normalized()
				}
					
	elif(Direction=="Front-Left"):
		return {"Plane": Plane(Player_Node.transform.origin,
				 	 Player_Node.transform.origin + Player_Node.transform.basis.y.normalized(), 
				 	 Player_Node.transform.origin + (-Player_Node.basis.z-Player_Node.basis.x).normalized()),
				"Direction": (-Player_Node.basis.z-Player_Node.basis.x).normalized()
				}
					
	elif(Direction=="Back-Right"):
		return {"Plane": Plane(Player_Node.transform.origin,
				 	 Player_Node.transform.origin + Player_Node.transform.basis.y.normalized(), 
				 	 Player_Node.transform.origin + (Player_Node.basis.z+Player_Node.basis.x).normalized()),
				"Direction": (Player_Node.basis.z+Player_Node.basis.x).normalized()
				}
					
	elif(Direction=="Back-Left"):
		return {"Plane": Plane(Player_Node.transform.origin,
				 	 Player_Node.transform.origin + Player_Node.transform.basis.y.normalized(), 
				 	 Player_Node.transform.origin + (Player_Node.basis.z-Player_Node.basis.x).normalized()),
				"Direction": (Player_Node.basis.z-Player_Node.basis.x).normalized()
				}

#====================================================================================================================================================


func Put_Player_on_Centroid_of_Face(Face, Scale, Player_Node, MDT):
	var face_normal=MDT.get_face_normal(Face)
	var pos= ( ( (MDT.get_vertex(MDT.get_face_vertex(Face, 0)))*Scale)+( (MDT.get_vertex(MDT.get_face_vertex(Face, 1)))*Scale)+( (MDT.get_vertex(MDT.get_face_vertex(Face, 2)))*Scale) )/3
	Player_Node.global_position=pos
	var new_Basis = get_Normal_Aligned_Basis(face_normal, Player_Node)
	Player_Node.transform.basis=new_Basis

func Put_Player_on_Face(pos, Face, Player_Node, MDT):
	var face_normal=MDT.get_face_normal(Face)
	Player_Node.global_position=pos
	var new_Basis = get_Normal_Aligned_Basis(face_normal, Player_Node)
	Player_Node.transform.basis=new_Basis
	
func Get_next_Face_Pos_And_Basis( Face, Direction, NextMoveInfo, Player_Node, MDT ):
	var face_normal=MDT.get_face_normal(Face)
	var NextPos=NextMoveInfo["PointArr"][-1][1]
	var NextBasis = get_Normal_Aligned_Basis(face_normal, Player_Node)
	var Calculated_Dir=(NextMoveInfo["PointArr"][-1][1] - NextMoveInfo["PointArr"][-1][0]).normalized()
	var CorrectedBasis=Get_Direction_Corrected_Basis( Direction, Calculated_Dir, NextBasis.y, Player_Node.scale )
	
	return { "NextPos":NextPos, "NextBasis":CorrectedBasis  }
	

func Get_Direction_Corrected_Basis( Direction, Calculated_Dir, PlayerY, PlayerScale ):
	var NewX
	var NewY
	var NewZ
	if(Direction=="Front"):
		NewX=((PlayerY).cross(-Calculated_Dir)).normalized()#new x
		NewY=(((-Calculated_Dir).cross(PlayerY)).cross( -Calculated_Dir )).normalized()#new y
		NewZ=-Calculated_Dir
	elif(Direction=="Back"):
		NewX=((PlayerY).cross(Calculated_Dir)).normalized()#new x
		NewY=(((Calculated_Dir).cross(PlayerY)).cross( Calculated_Dir )).normalized()#new y
		NewZ=Calculated_Dir
	elif(Direction=="Left"):
		NewX= -Calculated_Dir
		NewZ=(( -Calculated_Dir ).cross( PlayerY.normalized() )).normalized()
		NewY=(NewZ.cross(NewX)).normalized()
	elif(Direction=="Right"):
		NewX= Calculated_Dir
		NewZ=(( Calculated_Dir ).cross( PlayerY.normalized() )).normalized()
		NewY=(NewZ.cross(NewX)).normalized()
	elif(Direction=="Front-Right"):
		NewZ=-(((( PlayerY.normalized() ).cross( Calculated_Dir )).normalized())+Calculated_Dir).normalized()
		NewX= -(NewZ.cross( PlayerY.normalized() )).normalized()
		NewY=(NewZ.cross(NewX)).normalized()
	elif(Direction=="Front-Left"):
		NewZ=-(((( Calculated_Dir ).cross( PlayerY.normalized() )).normalized())+Calculated_Dir).normalized()
		NewX= -(NewZ.cross( PlayerY.normalized() )).normalized()
		NewY=(NewZ.cross(NewX)).normalized()
	elif(Direction=="Back-Right"):
		NewZ=(((( Calculated_Dir ).cross( PlayerY.normalized() )).normalized())+Calculated_Dir).normalized()
		NewX= -(NewZ.cross( PlayerY.normalized() )).normalized()
		NewY=(NewZ.cross(NewX)).normalized()
	elif(Direction=="Back-Left"):
		NewZ=(((( PlayerY.normalized() ).cross( Calculated_Dir )).normalized())+Calculated_Dir).normalized()
		NewX= -(NewZ.cross( PlayerY.normalized() )).normalized()
		NewY=(NewZ.cross(NewX)).normalized()
		
	var NewBasis=Basis(NewX, NewY, NewZ)
	NewBasis.orthonormalized()
	NewBasis.x *= PlayerScale.x
	NewBasis.y *= PlayerScale.y
	NewBasis.z *= PlayerScale.z
	return NewBasis


func get_face_segment(Face, Seg_indx, MDT, Scale):
	return [ (MDT.get_vertex(MDT.get_edge_vertex(MDT.get_face_edge(Face, Seg_indx), 0)))*Scale, 
			 (MDT.get_vertex(MDT.get_edge_vertex(MDT.get_face_edge(Face, Seg_indx), 1)))*Scale]                                                                                           




func get_Intersections_with_Plane(Face, OppEdge, MDT, ThePlane, Scale):
	var intersections=[]
	var seg1=get_face_segment(Face, 0, MDT, Scale)
	var seg2=get_face_segment(Face, 1, MDT, Scale)
	var seg3=get_face_segment(Face, 2, MDT, Scale)
	var intersect1=ThePlane.intersects_segment(seg1[0], seg1[1])
	var intersect2=ThePlane.intersects_segment(seg2[0], seg2[1])
	var intersect3=ThePlane.intersects_segment(seg3[0], seg3[1])
	var Start_intersect
	if(intersect1!=null):
		intersections.append([intersect1,0])
		if(OppEdge==0):
			Start_intersect=intersect1
	if(intersect2!=null):
		intersections.append([intersect2,1])
		if(OppEdge==1):
			Start_intersect=intersect2
	if(intersect3!=null):
		intersections.append([intersect3,2])
		if(OppEdge==2):
			Start_intersect=intersect3
	if(intersections.size()==2 && Start_intersect!=null):
		if(intersections[0][1]==OppEdge):
			return [ [Start_intersect, OppEdge], [ intersections[1][0], intersections[1][1] ] ]
		else:
			return [ [Start_intersect, OppEdge], [ intersections[0][0], intersections[0][1] ] ]
	elif(intersections.size()==3 && Start_intersect!=null):
		var dist1=Start_intersect.distance_to(intersections[(OppEdge+1)%3][0])
		var dist2=Start_intersect.distance_to(intersections[(OppEdge+2)%3][0])
		if(dist1>dist2):
			return [ [Start_intersect, OppEdge], [intersections[(OppEdge+1)%3][0], intersections[(OppEdge+1)%3][1]] ]
		else:
			return [ [Start_intersect, OppEdge], [intersections[(OppEdge+2)%3][0], intersections[(OppEdge+2)%3][1]] ]
	else:
		return null
	
	#return intersections#[ [intersection_point1, IndexOfEdge_on_which_the_point_lies1], [intersection_point2, IndexOfEdge_on_which_the_point_lies2],... ]

func get_First_Intersection_with_Plane(Face, MDT, ThePlane, Scale):
	var intersections=[]
	var seg1=get_face_segment(Face, 0, MDT, Scale)
	var seg2=get_face_segment(Face, 1, MDT, Scale)
	var seg3=get_face_segment(Face, 2, MDT, Scale)
	var intersect1=ThePlane.intersects_segment(seg1[0], seg1[1])
	var intersect2=ThePlane.intersects_segment(seg2[0], seg2[1])
	var intersect3=ThePlane.intersects_segment(seg3[0], seg3[1])
	
	if(intersect1!=null):
		intersections.append([intersect1,0])
	if(intersect2!=null):
		intersections.append([intersect2,1])
	if(intersect3!=null):
		intersections.append([intersect3,2])
	return intersections
#===============================================================================================================================================


var Input_Keys={"Front":1, "Back":-1, "Right":2, "Left":-2}
var Input_Bools={"Front":false, "Back":false, "Right":false, "Left":false}
var final_addition=0
func Add_input(Direction):
	final_addition+=Input_Keys[Direction]
	Input_Bools[Direction]=true
	
func Get_Final_Direction():
	var FinalDirection="None"
	if(final_addition==1):
		if(Input_Bools["Back"] && Input_Bools["Right"]):
			FinalDirection="Back-Right"
		else:
			FinalDirection="Front"
	elif(final_addition==-1):
		if(Input_Bools["Front"] && Input_Bools["Left"]):
			FinalDirection="Front-Left"
		else:
			FinalDirection="Back"
	elif(final_addition==2):
		FinalDirection="Right"
	elif(final_addition==-2):
		FinalDirection="Left"
	elif(final_addition==3):
		FinalDirection="Front-Right"
	elif(final_addition==-3):
		FinalDirection="Back-Left"
	Input_Bools["Front"]=false
	Input_Bools["Back"]=false
	Input_Bools["Right"]=false
	Input_Bools["Left"]=false
	final_addition=0
	return FinalDirection






