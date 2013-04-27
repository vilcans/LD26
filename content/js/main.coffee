require [
	'goo/loaders/Loader'
	'goo/loaders/SceneLoader'
	'goo/entities/GooRunner'
], (
	Loader
	SceneLoader
	GooRunner
) ->
	'use strict'

	init = ->
		goo = new GooRunner(
			#showStats : true
		)
		document.body.appendChild(goo.renderer.domElement);

		loader = new Loader(rootPath: 'resources/scene/')
		sceneLoader = new SceneLoader(loader: loader, world: goo.world)
		sceneLoader.load('simple.scene').then((entities) ->
			for entity in entities
				console.log 'Adding entity', entity.name
				entity.addToWorld()
		).then(null, ->
			alert 'Failed to load scene: ' + e
		)

	init()
