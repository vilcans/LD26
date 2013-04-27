{
  "vshaderRef": "shaders/default.vert", 
  "attributes": {
    "vertexNormal": "NORMAL", 
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
    ]
  }, 
  "fshaderRef": "shaders/default.frag"
}