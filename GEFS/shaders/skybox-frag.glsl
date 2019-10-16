#version 330 core
out vec4 outColor;

in vec3 texCoords;

uniform bool constColor;
uniform vec3 skyColor;

uniform samplerCube skybox;

void main()
{
    if (constColor)
    {
        outColor = vec4(skyColor,1);

        // TODO: let the user define custom gradient colors.
        float y = texCoords.y;
        y = y*0.5 + 0.5;
        vec3 lower = 0.71 * vec3(1,1,1);
        vec3 upper = 0.85 * vec3(1,1,1);
        outColor = vec4(mix(lower, upper, clamp(y, 0, 1)), 1);
    }
    else
    {
        vec4 envColor = texture(skybox, texCoords);
        outColor = envColor;
        // NOTE: is this an attempt to turn a non-hdr texture into an hdr one?
        // outColor = 5 * pow(envColor, vec4(5, 5, 5, 1));
    }
}
