class Explody

	params = {	
		numberOfParticles: 2000
		speed: 5
		size: 5
		fadeDistance: 300
		random: false
		spherical: true
	}

	constructor: ->
		@scene    = new THREE.Scene()
		@camera   = new THREE.PerspectiveCamera(90, window.innerWidth / window.innerHeight, 0.1, 1000)
		@renderer = new THREE.WebGLRenderer()
		@controls = new THREE.OrbitControls( @camera ) 

		@renderer.setSize(window.innerWidth, window.innerHeight)
		document.body.appendChild(@renderer.domElement)

		@init()


	init: =>
		@camera.position.z = 200
		@camera.position.y = 200
		@camera.position.x = 200

		@camera.lookAt(new THREE.Vector3(0,0,0))

		@particles = generateParticles()
		@scene.add(@particles)

		@createGUI()
		window.addEventListener( 'resize', @onWindowResize, false )

	reInit: =>
		@scene.remove(@particles)
		@particles = null
		@init()

	onWindowResize: =>
		@camera.aspect = window.innerWidth / window.innerHeight
		@camera.updateProjectionMatrix()

		@renderer.setSize( window.innerWidth, window.innerHeight )

	createGUI: =>
		return if @gui
		@gui = new dat.GUI({
		    height : 5 * 32 - 1
		});
		@gui.add(params, 'numberOfParticles').min(100).max(30000).step(100).onFinishChange =>
			@reInit()
		@gui.add(params, 'size').min(0.5).max(10).step(0.3).onFinishChange =>
			@reInit()
		@gui.add(params, 'speed').min(0.5).max(50).step(0.5).onFinishChange =>
			@reInit()
		@gui.add(params, 'fadeDistance').min(50).max(1000).step(10)
		@gui.add(params, 'spherical').onFinishChange => @reInit()
		@gui.add(params, 'random').onFinishChange => @reInit()

	generateParticles = ->
		randomVectorComponent = -> Math.random() * 2 * params.speed - params.speed

		pointGeo = new THREE.Geometry
		pointGeo.vectors = []
		for i in [1..params.numberOfParticles]
			point = new THREE.Vector3(0,0,0)
			pointGeo.vertices.push(point)
			vector = new THREE.Vector3((randomVectorComponent() for i in [1..3])...)
			vector.setLength(params.speed * Math.random() * 3) if params.spherical
			pointGeo.vectors.push(vector)
			pointGeo.colors.push(new THREE.Color(0xffffff))
		
		material = new THREE.PointCloudMaterial
			size: params.size
			vertexColors: THREE.VertexColors

		new THREE.PointCloud(pointGeo, material);

	update: =>
		return unless @particles
		fadeDistance = params.fadeDistance
		for vertex, i in @particles.geometry.vertices
			vertex.add(@particles.geometry.vectors[i])			
			distance = (fadeDistance - Math.min(vertex.length(), fadeDistance)) / fadeDistance
			@particles.geometry.colors[i].setHSL((if params.random then Math.random() else 1.0), 1.0, distance)
		@particles.geometry.verticesNeedUpdate = true;
		@particles.geometry.colorsNeedUpdate = true;

	render: =>
		@renderer.render(@scene, @camera)

	renderLoop: =>
		@update()
		requestAnimationFrame(@renderLoop)

		@render()