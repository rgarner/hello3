class Roller
	numberOfThings = 30
	numberOfStars  = 2000
	rotateBy = 0.04
	cubeSize = 10

	constructor: ->
		@scene    = new THREE.Scene()
		@camera   = new THREE.PerspectiveCamera(90, window.innerWidth / window.innerHeight, 0.1, 1000)
		@renderer = new THREE.WebGLRenderer()
		@controls = new THREE.OrbitControls( @camera ) 

		@renderer.setSize(window.innerWidth, window.innerHeight)
		document.body.appendChild(@renderer.domElement)

		@things = generateThings()
		@scene.add thing for thing in @things

		@stars = generateStars()
		@scene.add(@stars)

		@camera.position.z = 200
		@scene.add light for light in generateLights()

		window.addEventListener( 'resize', @onWindowResize, false )

	onWindowResize: =>
		console.log 'foo'
		@camera.aspect = window.innerWidth / window.innerHeight
		@camera.updateProjectionMatrix()

		@renderer.setSize( window.innerWidth, window.innerHeight )
		console.log 'bar'

	generateLights = ->
		ambientLight = new THREE.AmbientLight( 0x332222 )
		
		redLight = new THREE.PointLight( 0xaa2322, 1, 1000 )
		redLight.position.set( 30, 20, 20 )		

		blueLight = new THREE.PointLight( 0x0000ff, 1, 1000 )
		blueLight.position.set( -30, -20, -20 )		

		whiteLight = new THREE.PointLight( 0xffffff, 1, 1000 )
		whiteLight.position.set( 30, 80, 20 )

		[ambientLight, redLight, blueLight, whiteLight]		


	generateThings = ->
		geometry = new THREE.BoxGeometry( cubeSize, cubeSize, cubeSize  )

		material = new THREE.MeshPhongMaterial
		  wireframe: true,
		  wireframeLinewidth: 4

		for r in [1..numberOfThings]			
			thing = new THREE.Mesh(geometry, material)
			thing.position.x = r * cubeSize - numberOfThings * 5
			thing.rotation.x = r / numberOfThings * Math.PI / 2
			
			thing

	generateStars = ->
		starGeo = new THREE.Geometry
		for i in [1..numberOfStars]
			xyz = (Math.random() * 500 - 250 for i in [1..3])
			star = new THREE.Vector3(xyz[0], xyz[1], xyz[2])
			starGeo.vertices.push(star)
		
		material = new THREE.PointCloudMaterial({size: 0.5, color: 0xffffff});
		stars = new THREE.PointCloud(starGeo, material);

		stars.rotation.x = Math.random() * 6;
		stars.rotation.y = Math.random() * 6;
		stars.rotation.z = Math.random() * 6;

		stars

	rotate = (thing) ->
		thing.rotation.x += rotateBy

	update: =>
		rotate(thing) for thing in @things
		@stars.rotation.y += 0.0005

	render: =>
		@renderer.render(@scene, @camera)

	renderLoop: (animate = true) =>
		@update()
		requestAnimationFrame(@renderLoop)

		@render()