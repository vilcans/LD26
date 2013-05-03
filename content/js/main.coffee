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
		acceleration: .6
		retardation: .2
		turnTorque: .05

		# How much the camera extrapolates the car's position from current velocity
		cameraAnticipationFactor: 1

		leftEdge: -9.5
		bottomEdge: -11

		spotRadius: .4

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
		t = map.getType(x, y)
		#console.log position.data[0], position.data[1], x, y, t
		return t

	physics = null

	class Car
		constructor: ->
			@startPosition = new Vector3(0, 0, 0)
			@entity = null

			# Update from physics
			@velocity = new Vector3(0, 0, 0)
			@position = new Vector3(0, 0, 0)


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
	frameCount = 0

	init = ->
		goo = new GooRunner(
			#showStats : true
		)
		goo.renderer.domElement.id = 'goo'
		document.body.appendChild(goo.renderer.domElement);


		loader = new Loader(rootPath: 'resources/scene/')
		sceneLoader = new SceneLoader(loader: loader, world: goo.world)
		sceneLoader.load('default.scene').then((entities) ->
			for entity in entities
				refToEntity[entity.ref] = entity
				unless entity.ref.match('Collision')
					entity.addToWorld()
		).then(->
			return loadImage('resources/collision.png')
		).then((image) ->
			console.log 'got image', image
			map = new Map(image)
		).then(->
			Tracking.trackEvent 'init', 'loaded', nonInteraction: true
			waitForStart()
		).then(null, (e) ->
			Tracking.trackEvent 'init', 'error', label: "#{e}", nonInteraction: true
			alert 'Failed to load scene: ' + e
		)

		waitForStart = ->
			startButton = document.getElementById('start-button')
			startButton.style.display = 'block';
			startButton.addEventListener 'click', ->
				startButton.style.display = 'none'
				document.getElementById('instructions').style.display = 'none'
				start()

		start = ->
			Tracking.trackEvent 'game', 'start'
			document.getElementById('goo').style.display = 'block'
			console.log 'start'
			car.entity = refToEntity['entities/Car.entity']
			Vector3.add(
				refToEntity['entities/CarGroup.entity'].transformComponent.transform.translation,
				car.entity.transformComponent.transform.translation,
				car.startPosition
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
			do updateSpotsLeft = ->
				document.getElementById('spots-left').innerHTML = '' + spots.length

			physics = new Physics(car)

			car.entity.setComponent new ScriptComponent(
				run : (entity) ->
					if spots.length == 0
						return
					frameCount++
					if keyboard.isPressed('up')
						physics.setThrottle config.acceleration
					else if keyboard.isPressed('down')
						physics.setThrottle -config.retardation
					else
						physics.setThrottle 0

					if keyboard.isPressed('left')
						physics.setTurn config.turnTorque
					else if keyboard.isPressed('right')
						physics.setTurn -config.turnTorque
					else
						physics.setTurn 0

					physics.update 1 / 60

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
							if spots.length == 0
								Tracking.trackEvent 'game', 'success', value: frameCount
								document.getElementById('time-result').innerHTML = frameCount
								document.getElementById('spots-left').style.display = 'none'
								document.getElementById('success').style.display = 'block'
								document.getElementById('goo').style.display = 'none'
							else
								Tracking.trackEvent 'game', 'pickup', value: spots.length

							updateSpotsLeft()
							break
			)


	init()
