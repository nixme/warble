#= require Three
#= require Three.EffectComposer
#= require Three.RenderPass
#= require Three.ShaderPass
#= require Three.ShaderExtras

THREE.MaskPass = ->
THREE.ClearMaskPass = ->

class Warble.VisualizationView extends Backbone.View
  el: '#visualization'


  initialize: (options) ->
    @audioPlayer = options.audioPlayer
    @frequencyByteData = new Uint8Array(@audioPlayer.analyser.frequencyBinCount)

    @render()
    @audioPlayer.on 'start', @tick, this

  vertexShader: -> """
    attribute float size;
    attribute vec3  ca;

    varying vec3 vColor;

    void main() {
      vColor = ca;   // Pass color to fragment shader

      // float vertexRadius = sqrt(pow(float(position.x), 2.0) + pow(float(position.y), 2.0));
      // float bucket = floor(#{@frequencyByteData.length - 1}.0 * (vertexRadius / #{Math.sqrt(Math.pow(32, 2) * 2)}));

      //int index = int(bucket);
      //float height = 0.0;
      //if (index == 0) { height = frequency[0]; }

      // vec3 newPosition = position + vec3(0.0, 0.0, height);

      vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);

      gl_PointSize = size * (300.0 / length(mvPosition.xyz));
      gl_Position = projectionMatrix * mvPosition;
    }
  """
  # #{("else if (index == #{i}) { height = frequency[#{i}]; }" for i in [1...100]).join("\n")}


  fragmentShader: -> '''
    uniform vec3 color;
    uniform sampler2D texture;

    varying vec3 vColor;

    void main() {
      gl_FragColor = vec4(color * vColor, 1.0) * texture2D(texture, gl_PointCoord);
    }
  '''

  render: ->
    WIDTH = window.innerWidth
    HEIGHT = window.innerHeight
    VIEW_ANGLE = 45
    ASPECT = WIDTH / HEIGHT
    NEAR = 0.1
    FAR = 10000


    @camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)

    # HEIGHT = 3
    # WIDTH = HEIGHT / window.innerHeight * window.innerWidth
    # @camera = new THREE.OrthographicCamera(WIDTH / -2. WIDTH / 2, HEIGHT / 2, HEIGHT / -2, -10000, 10000)
    @scene = new THREE.Scene
    @scene.add @camera
    @camera.position.z = 60

    @geometry = new THREE.Geometry
    for i in [-32..32]
      for j in [-32..32]
        vertex = new THREE.Vector3
        vertex.x = i
        vertex.y = j
        vertex.z = 0
        @geometry.vertices.push vertex

    # material = new THREE.ParticleBasicMaterial
    #   color: 0xFFFFFF
    #   size: 5
    #   map: THREE.ImageUtils.loadTexture('/assets/particle.png')
    #   blending: THREE.AdditiveBlending
    #   transparent: true

    @uniforms =
      color:
        type: 'c'
        value: new THREE.Color(0xFFFFFF)
      texture:
        type: 't'
        value: 0
        texture: THREE.ImageUtils.loadTexture('/assets/particle.png')
      # frequency:
      #   type: 'fv1'
      #   value: @frequencyByteData

    @attributes =
      size:
        type: 'f'
        value: []
      ca:
        type: 'c'
        value: []

    material = new THREE.ShaderMaterial
      uniforms: @uniforms
      attributes: @attributes
      vertexShader: @vertexShader()
      fragmentShader: @fragmentShader()

    for vertex, i in @geometry.vertices
      @attributes.size.value[i] = 0
      @attributes.ca.value[i] = new THREE.Color(0xff0000)

    @particles = new THREE.ParticleSystem(@geometry, material)
    # @particles.sortParticles = true
    @scene.add @particles

    @scene.add new THREE.AmbientLight(Math.random() * 0xffffff)

    @renderer = new THREE.WebGLRenderer
      antialias: true
      canvas: @$el[0]
      # autoClear: false   # TODO: check this works as an option
    @renderer.setSize window.innerWidth, window.innerHeight
    # @renderer.setClearColor(new THREE.Color(0, 1))
    # Post-processing via blurring fragment shaders
    # @composer = new THREE.EffectComposer(@renderer)
    # passthrough = new THREE.RenderPass(@scene, @camera)
    # passthrough.renderToScreen = true
    # @composer.addPass passthrough
    # @composer.addPass new THREE.ShaderPass(THREE.ShaderExtras['horizontalBlur'])
    # vblurEffect = new THREE.ShaderPass(THREE.ShaderExtras['verticalBlur'])
    # vblurEffect.renderToScreen = true
    # @composer.addPass vblurEffect


  tick: =>
    requestAnimationFrame @tick if @audioPlayer.playing
    @audioPlayer.analyser.getByteFrequencyData @frequencyByteData

    # PLAN:
    #  - animate the background color or opacity by average freq spike, normalized. perhaps moving
    #    age

    maxRadius = Math.sqrt(Math.pow(31, 2) * 2)
    maxBucket = @frequencyByteData.length - 1

    SIZE_SCALE = 0.03

    for vertex, i in @geometry.vertices
      vertexRadius = Math.sqrt(Math.pow(vertex.x, 2.0) + Math.pow(vertex.y, 2.0));
      bucket = Math.floor(maxBucket * vertexRadius / maxRadius)

      @attributes.size.value[i] = Math.floor(@frequencyByteData[bucket] * SIZE_SCALE)

    @attributes.size.needsUpdate = true

    @renderer.render @scene, @camera
    # @renderer.clear()
    # @composer.render()