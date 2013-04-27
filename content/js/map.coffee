pixelTypes =
	WALL: 0  # used as boolean: must be zero
	FREE: 1

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

			if v == 0
				t = pixelTypes.WALL
			else if v == 7
				t = pixelTypes.FREE
			else
				console.warn 'Unknown color:', v
				t = pixelTypes.WALL
			@collisionData[i] = t

	getType: (x, y) ->
		if x < 0 or x >= @width or y < 0 or y >= @height
			return pixelTypes.WALL
		@collisionData[(x + (@height - y - 1) * @width)]

	getIndex: (x, y) ->
		(x + (@height - y - 1) * @width)

Map.pixelTypes = pixelTypes
