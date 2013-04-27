class @Keyboard
	constructor: (element) ->
		@element = element

		# how many frames the key has been pressed
		@pressed =
			up: false
			down: false
			left: false
			right: false

		# A "dropped" key is one that should be regarded
		# as not pressed, (even though it actually is),
		# until we receive a keyUp event.
		@dropped =
			up: false
			down: false
			left: false
			right: false

		@element.addEventListener 'keydown', @onKeyDown.bind(this)
		@element.addEventListener 'keyup', @onKeyUp.bind(this)

	# map keyboard event to key name
	map: (event) ->
		if event.ctrlKey or event.altKey
			return null

		code = event.keyCode
		if code == 65 or code == 97
			return 'left'
		else if code == 68 or code == 100
			return 'right'
		else if code == 87 or code == 119
			return 'up'
		else if code == 83 or code == 115
			return 'down'
		return null

	onKeyDown: (event) =>
		key = @map(event)
		if key and not @dropped[key]
			@pressed[key] = true

	onKeyUp: (event) =>
		key = @map(event)
		if key
			@pressed[key] = false
		@dropped[key] = false

	drop: (key) ->
		@dropped[key] = true
		@pressed[key] = false

	isPressed: (key) ->
		return @pressed[key]

	# Whether the key was pressed after the last call to animate
	isJustPressed: (key) ->
		return @pressed[key] == 1
