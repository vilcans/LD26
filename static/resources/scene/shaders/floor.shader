{
	"vshaderRef": "shaders/floor.vert",
	"attributes": {
		"vertexNormal": "NORMAL",
		"vertexUV0": "TEXCOORD0",
		"vertexPosition": "POSITION"
	},
	"uniforms": {
		"materialSpecular": "SPECULAR",
		"viewMatrix": "VIEW_MATRIX",
		"lightPosition": "LIGHT0",
		"worldMatrix": "WORLD_MATRIX",
		"materialSpecularPower": "SPECULAR_POWER",
		"cameraPosition": "CAMERA",
		"projectionMatrix": "PROJECTION_MATRIX",
		"materialDiffuse": "DIFFUSE",
		"materialAmbient": [
			0.1,
			0.1,
			0.1,
			1
		],
		"diffuseMap": "TEXTURE0"
	},
	"fshaderRef": "shaders/floor.frag"
}