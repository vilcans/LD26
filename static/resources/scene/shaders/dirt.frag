
precision mediump float;

uniform sampler2D diffuseMap;

varying vec3 normal;
varying vec3 lightDir;
varying vec3 eyeVec;
varying vec2 texCoord0;

void main(void)
{
	vec4 texCol = texture2D(diffuseMap, texCoord0);
	//float a = texCol.b;
	gl_FragColor = texCol; //vec4(texCol.rgb * a, a);
}
