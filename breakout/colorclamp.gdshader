shader_type canvas_item;

uniform vec4 tint = vec4(1, 1, 1, 1);

void fragment() {
	COLOR.x = min(tint.x, COLOR.x);
	COLOR.y = min(tint.y, COLOR.y);
	COLOR.z = min(tint.z, COLOR.z);
	COLOR.w = min(tint.w, COLOR.w);
}
