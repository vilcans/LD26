class @Map
	constructor: (collisionImage) ->
		@canvas = document.createElement('canvas')
		@width = @canvas.width = collisionImage.width;
		@height = @canvas.height = collisionImage.height;
		@context = @canvas.getContext('2d')
		@createCollisionMap collisionImage

	createCollisionMap: (collisionImage) ->
		@context.clearRect 0, 0, @width, @height
		@context.drawImage collisionImage, 0, 0
		imageData = @context.getImageData(0, 0, @width, @height)
		buffer = new ArrayBuffer(@width * @height)
		@collisionData = new Uint8Array(buffer)
		for i in [0...@width * @height]
			r = imageData.data[i * 4]
			g = imageData.data[i * 4 + 1]
			b = imageData.data[i * 4 + 2]
			a = imageData.data[i * 4 + 3]

			v = 0
			if b > 200 then v += 1
			if r > 200 then v += 2
			if g > 200 then v += 4

			@collisionData[i] = v

	getType: (x, y) ->
		if x < 0 or x >= @width or y < 0 or y >= @height
			return 0
		@collisionData[(x + (@height - y - 1) * @width)]

	getIndex: (x, y) ->
		(x + (@height - y - 1) * @width)
