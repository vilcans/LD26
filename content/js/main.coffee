require [
	'goo/loaders/Loader'
	'goo/loaders/SceneLoader'
	'goo/entities/GooRunner'
	'goo/math/Vector3'
	'goo/entities/components/ScriptComponent'
], (
	Loader
	SceneLoader
	GooRunner
	Vector3
	ScriptComponent
) ->
	'use strict'

	keyboard = new Keyboard(document.body)

	config =
		acceleration: .2
		retardation: .2
		turnAcceleration: 20 / 180 * Math.PI

		# After 1 second, angular velocity will have decreased to this fraction of original
		angularFriction: .01
		friction: .1 #1 #.0001

	class Car
		constructor: ->
			@position = new Vector3(0, 0, 0)
			@velocity = new Vector3(0, 0, 0)
			@rotation = Math.PI / 2  # 0 is to the right
			@angularVelocity = 0
			@entity = null

		animate: (time) ->
			speed = Math.sqrt(@velocity.lengthSquared())
			if keyboard.isPressed('up')
				@velocity[0] += time * config.acceleration * Math.cos(@rotation)
				@velocity[1] += time * config.acceleration * Math.sin(@rotation)
			if keyboard.isPressed('down')
				@velocity[0] -= time * config.retardation * Math.cos(@rotation)
				@velocity[1] -= time * config.retardation * Math.sin(@rotation)
			if keyboard.isPressed('right')
				@angularVelocity -= time * config.turnAcceleration
			if keyboard.isPressed('left')
				@angularVelocity += time * config.turnAcceleration

			@position.add @velocity
			@rotation += @angularVelocity

			@angularVelocity *= Math.pow(config.angularFriction, time)
			@velocity.mul Math.pow(config.friction, time)

	car = new Car()

	init = ->
		goo = new GooRunner(
			#showStats : true
		)
		document.body.appendChild(goo.renderer.domElement);

		loader = new Loader(rootPath: 'resources/scene/')
		sceneLoader = new SceneLoader(loader: loader, world: goo.world)
		sceneLoader.load('default.scene').then((entities) ->
			for entity in entities
				console.log 'Adding entity', entity.ref
				entity.addToWorld()
				if entity.ref == 'entities/Car.entity'
					car.entity = entity
					car.position.set(entity.transformComponent.transform.translation)
			start()
		).then(null, ->
			alert 'Failed to load scene: ' + e
		)

		start = ->
			console.log 'start!'
			car.entity.setComponent new ScriptComponent(
				run : (entity) ->
					car.animate 1 / 60
					# Subtract 90 degrees as model is designed to point in the Y direction
					entity.transformComponent.transform.setRotationXYZ 0, 0, car.rotation - Math.PI / 2
					entity.transformComponent.transform.translation.set car.position
					entity.transformComponent.setUpdated()
			)


	init()
