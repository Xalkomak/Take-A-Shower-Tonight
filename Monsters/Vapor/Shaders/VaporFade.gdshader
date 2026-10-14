shader_type canvas_item;

uniform float transparency: hint_range(0.0, 1.0, 0.01) = 1.0;

void fragment()
{
	COLOR.a = transparency;
}
