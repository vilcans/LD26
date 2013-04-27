
attribute vec3 vertexPosition;
attribute vec3 vertexNormal;

uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 worldMatrix;
uniform vec3 cameraPosition;
uniform vec3 lightPosition;

varying vec3 normal;
varying vec3 lightDir;
varying vec3 eyeVec;

void main(void) {
	vec4 worldPos = worldMatrix * vec4(vertexPosition, 1.0);
	gl_Position = projectionMatrix * viewMatrix * worldPos;

	normal = (worldMatrix * vec4(vertexNormal, 0.0)).xyz;
	lightDir = lightPosition - worldPos.xyz;
	eyeVec = cameraPosition - worldPos.xyz;
}
