 /*
 / bullet modulator shader written by peachey2k2
 / please use this so i can sue you for money and buy fumos
 / 
 / this shader exists as a way to conveniently change the color of
 / a bullet easily, and only doing it in intended areas. we aren't
 / using CanvasItem.modulate because that'd mess with white parts
 / of the bullets, which we don't want to.
*/ 

// shader type is canvas_item since we're working with 2d here.
shader_type canvas_item;

// fuck lighting tbh
render_mode unshaded;

// uniform variables are exported. we also need to
// clarify the hint so we have a color picker in the editor.
// both colors and coords use vectors. keep that in mind.
uniform vec3 modulate : source_color = vec3(0.0);

// you probably already know what a constant is.
const vec3 GRAYSCALE_CONSTANT = vec3(0.2126, 0.7152, 0.0722);

// fragment shaders are ran for every pixel.
void fragment(){
	
	// deranged vector math to grayscale. below is the source:
	// https://stackoverflow.com/a/6895473
	COLOR.rgb = vec3(dot(COLOR.rgb, GRAYSCALE_CONSTANT));
	// if you don't get it, don't worry. i didn't either.
	
	// invert the image by subtracting the colors from 1
	COLOR.rgb = 1.0 - COLOR.rgb;
	// we inverted the colors because that keeps the
	// black part the same after a modulation

	// also speaking of modulation...
	COLOR.rgb = COLOR.rgb * (1.0 - modulate);
	// also note that we inverted the modulation color too

	// revert the inversion
	COLOR.rgb = 1.0 - COLOR.rgb;
	
}
