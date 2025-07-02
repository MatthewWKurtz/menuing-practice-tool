shader_type canvas_item;

uniform int state = 0; //0 == default, 1 == next, 2 == missed

void fragment() 
{
	if(state == 2)
	{
		COLOR.r = 1.0;
	}
	else if(state == 1)
	{
		COLOR.g = 1.0;
	}
	
	
}
