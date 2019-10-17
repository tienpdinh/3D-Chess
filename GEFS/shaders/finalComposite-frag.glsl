#version 150 core

in vec3 Color;
in vec2 Texcoord;

out vec4 outColor;

uniform float bloomAmount;

uniform sampler2D texDim;
uniform sampler2D texBright;

// Provided by Prof. Guy.
vec3 rgbTonemapping(vec3 color, float gamma, float exposure)
{
    // Exposure tone mapping.
    vec3 mapped = vec3(1.0) - exp(-color.rgb * exposure);

    // Gamma correction.
    mapped = pow(mapped, vec3(1.0 / gamma));

    return mapped;
}

// Provided by Prof. Guy.
vec3 xyzTonemapping(vec3 color, float gamma, float exposure)
{
    // https://ninedegreesbelow.com/photography/xyz-rgb.html#XYZ
    // http://brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
    // http://www.brucelindbloom.com/index.html?Eqn_xyY_to_XYZ.html

    float X = .577*color.r + .186*color.g + .188*color.b;
    float Y = .297*color.r + .627*color.g + .075*color.b;
    float Z = .027*color.r + .071*color.g + .991*color.b;

    float x = X/(X+Y+Z);
    float y = Y/(X+Y+Z);

    Y = 1.0 - exp(-Y * exposure);

    float Xm = x*Y/y;
    float Ym = Y;
    float Zm = (1 - x - y)*Y/y;

    vec3 mapped;

    mapped.r = 2.041*Xm + -0.565*Ym - 0.345*Zm;
    mapped.g = -.963*Xm + 1.876*Ym + .04155*Zm;
    mapped.b = .0134*Xm + -0.118*Ym + 1.015*Zm;

    // Gamma correction.
    mapped = pow(mapped, vec3(1.0 / gamma));
    return mapped;
}

// https://github.com/armory3d/armory/blob/master/Shaders/std/tonemap.glsl
vec3 tonemapFilmic(const vec3 color) {
	vec3 x = max(vec3(0.0), color - 0.004);
	return (x * (6.2 * x + 0.5)) / (x * (6.2 * x + 1.7) + 0.06);
}

// https://github.com/armory3d/armory/blob/master/Shaders/std/tonemap.glsl
vec3 acesFilm(const vec3 x) {
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return clamp((x * (a * x + b)) / (x * (c * x + d ) + e), 0.0, 1.0);
}

// https://github.com/armory3d/armory/blob/master/Shaders/std/tonemap.glsl
vec3 tonemapReinhard(const vec3 color) {
	return color / (color + vec3(1.0));
}

void main()
{
    vec4 bright = texture(texBright, Texcoord);
    vec4 dim = texture(texDim, Texcoord);

    outColor = 1*dim + 1*bloomAmount*bright;

    // TODO: is this required? Original image should already be in 0-1 range unless
    // there are highlights from bloom or emissive materials...
}
