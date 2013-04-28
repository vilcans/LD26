{
	"vshaderRef": "shaders/dirt.vert",
	"attributes": {
		"vertexNormal": "NORMAL",
		"vertexUV0": "TEXCOORD0",
		"vertexPosition": "POSITION"
	},
	"uniforms": {
		"viewMatrix": "VIEW_MATRIX",
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
	"fshaderRef": "shaders/dirt.frag"
}