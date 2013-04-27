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
		spotRadius: .4

		# How much the camera extrapolates the car's position from current velocity
		cameraAnticipationFactor: 25

	# Use Blender's convention where z is up
	UP = new Vector3(0, 0, 1)

	spotRadiusSquared = config.spotRadius * config.spotRadius

	distanceSquared = (a, b) ->
		dx = a.data[0] - b.data[0]
		dy = a.data[1] - b.data[1]
		return dx * dx + dy * dy

	class Car
		constructor: ->
			@position = new Vector3(0, 0, 0)
			@velocity = new Vector3(0, 0, 0)
			@rotation = Math.PI / 2  # 0 is to the right
			@angularVelocity = 0
			@entity = null

		animate: (time) ->
			#speed = Math.sqrt(@velocity.lengthSquared())
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

	class Camera
		constructor: ->
			@targetLookAt = new Vector3()
			@lookAt = new Vector3()

		animate: (time) ->
			@targetLookAt.set(car.velocity)
			@targetLookAt.mul(config.cameraAnticipationFactor)
			@targetLookAt.add(car.position)
			#@targetLookAt.set(car.position)
			@lookAt.lerp(@targetLookAt, 1 - Math.pow(.2, time))

			@entity.transformComponent.transform.lookAt(@lookAt, UP)
			@entity.transformComponent.setUpdated()

	# Maps ref to entity
	refToEntity = {}

	car = new Car()
	camera = new Camera()

	init = ->
		goo = new GooRunner(
			#showStats : true
		)
		document.body.appendChild(goo.renderer.domElement);

		loader = new Loader(rootPath: 'resources/scene/')
		sceneLoader = new SceneLoader(loader: loader, world: goo.world)
		sceneLoader.load('default.scene').then((entities) ->
			for entity in entities
				refToEntity[entity.ref] = entity
				entity.addToWorld()
			start()
		).then(null, ->
			alert 'Failed to load scene: ' + e
		)

		start = ->
			car.entity = refToEntity['entities/Car.entity']
			Vector3.add(
				refToEntity['entities/CarGroup.entity'].transformComponent.transform.translation,
				car.entity.transformComponent.transform.translation,
				car.position
			)

			camera.entity = refToEntity['entities/Camera.entity']

			spots = (spot for ref, spot of refToEntity when ref.match(/^entities\/spot/i))

			console.log 'start!', spots
			car.entity.setComponent new ScriptComponent(
				run : (entity) ->
					car.animate 1 / 60
					# Subtract 90 degrees as model is designed to point in the Y direction
					entity.transformComponent.transform.setRotationXYZ 0, 0, car.rotation - Math.PI / 2
					entity.transformComponent.transform.translation.set car.position
					entity.transformComponent.setUpdated()

					for spot in spots
						if distanceSquared(car.position, spot.transformComponent.transform.translation) < spotRadiusSquared
							spot.removeFromWorld()
							spots = _.without(spots, spot)
							break
			)

			camera.entity.setComponent new ScriptComponent(
				run: (entity) ->
					camera.animate(1 / 60)
			)


	init()
