shader_type spatial;
uniform sampler2D Noise;
uniform sampler2D displayNoise;
uniform float Height;
varying vec3 pos;
varying vec3 world_pos;
varying vec3 obj_pos;
varying float h;
uniform float Hlimit;
varying float vert_height;
uniform vec4 grass_color: source_color;
void vertex() {
	// Called for every vertex the material is visible on.
	//VERTEX+=vec3(0.0,1.0,0.0)*1.0;
	//world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	//obj_pos = (inverse(MODEL_MATRIX) * vec4(world_pos, 1.0)).xyz;
	//h=distance( vec3(VERTEX.x,0.0,VERTEX.z), VERTEX  );
	h=distance( NODE_POSITION_WORLD, vec3(0.0,0.0,0.0)  );
	VERTEX=vec3(VERTEX.x, VERTEX.y-(h/28.25), VERTEX.z);
	VERTEX+=NORMAL*(h/28.25)*1.5;
	vert_height=VERTEX.y;
}


float hash(uint n) {
				// integer hash copied from Hugo Elias
				n = (n << 13U) ^ n;
				n = n * (n * n * 15731U + 0x789221U) + 0x13763129U;
				return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
}


void fragment() {
	
	//h=distance( NODE_POSITION_WORLD, vec3(0.0,0.0,0.0)  );
	
	//NODE_POSITION_WORLD
	//float h=distance( vec3(VERTEX.x,0.0,VERTEX.z), VERTEX  );

	uvec2 tid=uvec2(UV);
	uint seed = tid.x + 100U * tid.y + 100U * 10U;
	
	float depth = FRAGCOORD.z;
	vec2 frag_ndc = ((FRAGCOORD.xy / VIEWPORT_SIZE) * 2.0) - 1.0; 
	vec4 frag_view_space_position = INV_PROJECTION_MATRIX * vec4(frag_ndc, depth, 1.0);
	frag_view_space_position /= frag_view_space_position.w;
	vec4 frag_world_space = INV_VIEW_MATRIX * frag_view_space_position;
	//
	//h=distance( vec3(frag_world_space.x, 0.0, frag_world_space.z), frag_world_space.xyz  );
	
	float noiseval=texture(Noise, UV*28.25).x;
	float display_noise=texture(displayNoise, UV).x;
	
	//if(noiseval>h*Hlimit*0.9 && display_noise>0.5){
			//ALBEDO=vec3((h*1.0), 2.0, (h*2.0))*(pow(h,1.0));
		//}else{
			//discard;
		//}
	
	if(distance( CAMERA_POSITION_WORLD, frag_world_space.xyz  )<50.0){
		if(noiseval>h*Hlimit*0.9 && display_noise>0.5){
			//ALBEDO=vec3((h*2.0), 4.0, (h*2.0))*(pow(h,1.0));
			ALBEDO=grass_color.xyz*(pow(h,0.6));
		}else{
			discard;
		}
	}
	else{
		discard;
	}
	
	//if(distance( CAMERA_POSITION_WORLD, frag_world_space.xyz  )>1.0){
		//discard;
	//}else if(noiseval>h*Hlimit){
		//ALBEDO=vec3((h*1.0), 7.0, (h*10.0))*(pow(h,1.0));
	//}else{
		//discard;
	//}
	//
	
}

