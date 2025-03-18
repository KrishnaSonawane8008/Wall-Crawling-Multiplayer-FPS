shader_type spatial;
uniform sampler2D Initial_Noise;
uniform sampler2D RoundVoronoi_Noise;
uniform vec3 ground_color: source_color;
uniform vec3 grass_color: source_color;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	float depth = FRAGCOORD.z;
	vec2 frag_ndc = ((FRAGCOORD.xy / VIEWPORT_SIZE) * 2.0) - 1.0; 
	vec4 frag_view_space_position = INV_PROJECTION_MATRIX * vec4(frag_ndc, depth, 1.0);
	frag_view_space_position /= frag_view_space_position.w;
	vec4 frag_world_space = INV_VIEW_MATRIX * frag_view_space_position;
	
	float initial_noise_value=texture(Initial_Noise, UV).r;
	vec4 voronoi_color=texture(RoundVoronoi_Noise, UV*28.25);
	if(initial_noise_value<0.5){
		ALBEDO=ground_color;
	}else if(distance( CAMERA_POSITION_WORLD, frag_world_space.xyz  )>50.0){
		ALBEDO=voronoi_color.xyz;
	}else{
		ALBEDO=grass_color;
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
