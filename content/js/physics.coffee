carLength = .4
carWidth = .4

b2Vec2 = Box2D.Common.Math.b2Vec2
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2Body = Box2D.Dynamics.b2Body
b2FixtureDef = Box2D.Dynamics.b2FixtureDef
b2Fixture = Box2D.Dynamics.b2Fixture
b2World = Box2D.Dynamics.b2World
b2MassData = Box2D.Collision.Shapes.b2MassData
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
b2DebugDraw = Box2D.Dynamics.b2DebugDraw

class @Physics
	constructor: (@car) ->
		@world = world = new b2World(
			new b2Vec2(0, 0)  # gravity
			false  # sleep
		)

		@carForce = new b2Vec2
		@torque = 0

		fixDef = new b2FixtureDef
		fixDef.density = 1.0
		fixDef.friction = .1
		fixDef.restitution = 0.2

		bodyDef = new b2BodyDef

		# create walls
		bodyDef.type = b2Body.b2_staticBody
		#bodyDef.position.x = 0
		#bodyDef.position.y = -10.5
		#fixDef.shape = new b2PolygonShape;
		#fixDef.shape.SetAsBox 10, 0.5
		#world.CreateBody(bodyDef).CreateFixture(fixDef)

		bodyDef.type = b2Body.b2_staticBody
		bodyDef.position.x = 0
		bodyDef.position.y = 0
		fixDef.shape = new b2PolygonShape

		window.addCollisionData(b2Vec2, world, bodyDef, fixDef)
		#debugger
		#fixDef.shape.SetAsBox .5, (2 + 2.3) / 2
		#fixDef.shape.SetAsArray([
			#new b2Vec2(-8.5, -10)
			#new b2Vec2(9, -10)

		#	new b2Vec2(-9.5, -11)
		#	new b2Vec2(10, -11)
			#new b2Vec2(10, 8)
			#new b2Vec2(9, 8)
			#new b2Vec2(9, -10)
			#new b2Vec2(-8.5, -10)
		#])
		#world.CreateBody(bodyDef).CreateFixture(fixDef)

		# create some objects
		bodyDef.type = b2Body.b2_dynamicBody
		fixDef.density = 1 / 4
		fixDef.shape = new b2PolygonShape
		fixDef.shape.SetAsBox(carWidth / 2, carLength / 2)
		bodyDef.position.x = @car.startPosition.data[0]
		bodyDef.position.y = @car.startPosition.data[1]
		@carBody = world.CreateBody(bodyDef)
		@carBody.CreateFixture(fixDef)
		@carBody.SetLinearDamping 3
		@carBody.SetAngularDamping 10

		@bodyDef = bodyDef
		@fixDef = fixDef

		debugElement = document.getElementById('box2d-debug')
		if debugElement
			@debugDraw = new b2DebugDraw()
			@debugDraw.SetSprite(debugElement.getContext('2d'))
			@debugDraw.SetDrawScale(10.0)
			@debugDraw.SetFillAlpha(0.3)
			@debugDraw.SetLineThickness(1.0)
			@debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit)
			@world.SetDebugDraw(@debugDraw)

	update: (timestep) ->
		@performSimulation timestep
		@updateView()

	performSimulation: (timestep) ->
		@carBody.ApplyForce(
			@carForce
			@carBody.GetPosition()
		)
		@carBody.ApplyTorque @torque

		@world.Step(timestep, 10, 10)
		if @debugDraw
			@world.DrawDebugData()
		@world.ClearForces()

	updateView: ->
		carAngle = @carBody.GetAngle()
		carPos = @carBody.GetPosition()
		velocity = @carBody.GetLinearVelocity()

		@car.position.data[0] = carPos.x
		@car.position.data[1] = carPos.y
		@car.rotation = carAngle
		@car.velocity.data[0] = velocity.x
		@car.velocity.data[1] = velocity.y

	setThrottle: (force) ->
		rotation = @carBody.GetAngle()
		@carForce.x = Math.cos(rotation) * force
		@carForce.y = Math.sin(rotation) * force

	setTurn: (torque) ->
		@torque = torque
