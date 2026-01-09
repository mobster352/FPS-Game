shader_type canvas_item;

// Uniforms (adjustable in the Inspector)
uniform vec4 tint_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Red tint
uniform float tint_strength : hint_range(0.0, 1.0) = 0.25;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 original_color = texture(TEXTURE, UV); // Sample the pixel color

    // Mix original color with tint color based on strength
    vec4 final_color = mix(original_color, tint_color, tint_strength);

    COLOR = final_color; // Output the new color
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
