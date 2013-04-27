require [
	'goo/loaders/Loader'
	'goo/loaders/SceneLoader'
	'goo/entities/GooRunner'
	'goo/math/Vector3'
	'goo/entities/components/ScriptComponent'
	'goo/util/rsvp'
], (
	Loader
	SceneLoader
	GooRunner
	Vector3
	ScriptComponent
	RSVP
) ->
	'use strict'

	map = null
	cameraNumbers = [1..6]
	cameras = []

	loadImage = (url) ->
		console.log 'loading', url

		promise = new RSVP.Promise
		image = new Image()
		image.src = url
		image.onload = ->
			console.log 'collision map loaded', image
			promise.resolve(image)
		return promise

	keyboard = new Keyboard(document.body)

	# Length of the side of one collision square
	squareSize = .1  # 1 dm

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

		leftEdge: -9.5
		bottomEdge: -11

	# Use Blender's convention where z is up
	UP = new Vector3(0, 0, 1)

	spotRadiusSquared = config.spotRadius * config.spotRadius

	distanceSquared = (a, b) ->
		dx = a.data[0] - b.data[0]
		dy = a.data[1] - b.data[1]
		return dx * dx + dy * dy

	getTypeAtPosition = (position) ->
		x = Math.floor((position.data[0] - config.leftEdge) / squareSize)
		y = Math.floor((position.data[1] - config.bottomEdge) / squareSize)
		return map.getType(x, y)

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
		).then(->
			return loadImage('resources/collision.png')
		).then((image) ->
			console.log 'got image', image
			map = new Map(image)
		).then(->
			start()
		).then(null, ->
			alert 'Failed to load scene: ' + e
		)

		start = ->
			console.log 'start'
			car.entity = refToEntity['entities/Car.entity']
			Vector3.add(
				refToEntity['entities/CarGroup.entity'].transformComponent.transform.translation,
				car.entity.transformComponent.transform.translation,
				car.position
			)

			for i in cameraNumbers
				do (i) ->
					camera = new Camera()
					ref = "entities/Camera#{i}.entity"
					camera.entity = refToEntity[ref]
					console.assert camera.entity, 'Camera not found:', ref
					cameras[i] = camera
					camera.entity.setComponent new ScriptComponent(
						run: (entity) ->
							camera.animate(1 / 60)
					)

			spots = (spot for ref, spot of refToEntity when ref.match(/^entities\/spot/i))

			car.entity.setComponent new ScriptComponent(
				run : (entity) ->
					car.animate 1 / 60

					type = getTypeAtPosition(car.position)
					if type == 0
						console.log 'aw!'
					else if type != 7
						for i in cameraNumbers
							cameras[i].entity.cameraComponent.isMain = (i == type)
						goo.world.getSystem('CameraSystem').findMainCamera()

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

	init()
