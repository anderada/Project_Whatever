shader_type canvas_item;

uniform bool enabled = true;
uniform vec3 light_color = vec3(1.2,1,0.8);
uniform vec3 dark_color = vec3(0.2,0.5,0.7);

uniform sampler2D screen_texture : hint_screen_texture;


void fragment() {
	vec3 color = texture(screen_texture, SCREEN_UV).rgb;
	
	if (enabled) {
		vec2 screen_size = vec2(textureSize(screen_texture, 0));
		float luminance = (color.r + color.g + color.b) / 3.0;
		luminance = luminance * 1.5 - 0.25;
		luminance = clamp(luminance, 0, 1);
		
		vec3 light = vec3(min(color.r * light_color.r,1),min(color.g * light_color.g,1),min(color.b * light_color.b,1));
		vec3 dark = vec3(max(color.r * dark_color.r,0),max(color.g * dark_color.g,0),max(color.b * dark_color.b,0));
		//vec3 dark = vec3(luminance);
		
		vec3 colorMix = mix(dark, light, luminance);
		vec4 output = vec4(colorMix.r, colorMix.g, colorMix.b, 1.0);
		COLOR = output;
	}
	else {
		COLOR.rgb = color;
	}
}