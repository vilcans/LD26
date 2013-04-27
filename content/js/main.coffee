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

	car = {
		entity: null
	}

	init = ->
		goo = new GooRunner(
			#showStats : true
		)
		document.body.appendChild(goo.renderer.domElement);

		loader = new Loader(rootPath: 'resources/car/')
		sceneLoader = new SceneLoader(loader: loader, world: goo.world)
		sceneLoader.load('default.scene').then((entities) ->
			for entity in entities
				console.log 'Adding entity', entity.ref
				entity.addToWorld()
				if entity.ref == 'entities/Car.entity'
					car.entity = entity
					#car.entity.transformComponent.transform.translation[0] -= 1
			return
		).then(null, ->
			alert 'Failed to load scene: ' + e
		)

	init()
