shader_type canvas_item;

uniform vec4 custom_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	// Called for every pixel the material is visible on.
	if(COLOR.a != 0.0){
		COLOR = vec4(COLOR.r/2.0, COLOR.b/2.0, COLOR.g/2.0, 1.0);
	}


}
