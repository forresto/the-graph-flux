module.exports = ->
  # Project configuration
  pkg = @file.readJSON 'package.json'
  repo = pkg.repository.url.replace 'git://', 'https://'+process.env.GH_TOKEN+'@'

  @initConfig
    pkg: @file.readJSON 'package.json'

    # Updating the package manifest files
    noflo_manifest:
      update:
        files:
          'component.json': ['graphs/*', 'components/*']
          'package.json': ['graphs/*', 'components/*']

    # CoffeeScript compilation of tests
    # coffee:
    #   test:
    #     options:
    #       bare: true
    #     expand: true
    #     cwd: 'test'
    #     src: ['**.coffee']
    #     dest: 'test'
    #     ext: '.js'

    # Browser build of NoFlo
    noflo_browser:
      build:
        options:
          debug: true
          ide: 'http://localhost:8000/index.html'
        files:
          "browser/<%=pkg.name%>.js": ['component.json']

    # JavaScript minification for the browser
    uglify:
      options:
        report: 'min'
      noflo:
        files:
          "./browser/<%=pkg.name%>.min.js": ["./browser/<%=pkg.name%>.js"]

    # Automated recompilation and testing when developing
    watch:
      files: ['test/*.coffee', 'components/*.coffee']
      tasks: ['test']

    # Coding standards
    coffeelint:
      components: ['Gruntfile.coffee', 'test/*.coffee', 'components/*.coffee']
      options:
        'max_line_length':
          'level': 'ignore'

    'noflo_test':
      components:
        src: ['test/*.coffee']

    'gh-pages':
      options:
        base: 'browser'
        clone: 'gh-pages'
        message: 'Updating'
        repo: repo
        user:
          name: 'NoFlo bot'
          email: 'bot@noflo.org'
        silent: true
      src: '**/*'

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-noflo-manifest'
  @loadNpmTasks 'grunt-noflo-browser'
  @loadNpmTasks 'grunt-contrib-uglify'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-contrib-watch'
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-coffeelint'
  @loadNpmTasks 'noflo-test'

  # Grunt plugins used for deploying
  @loadNpmTasks 'grunt-gh-pages'

  # Our local tasks
  @registerTask 'build', 'Build NoFlo for the chosen target platform', (target = 'all') =>
    # @task.run 'coffee'
    @task.run 'noflo_manifest'
    if target is 'all' or target is 'browser'
      @task.run 'noflo_browser'
      @task.run 'uglify'

  @registerTask 'test', 'Build NoFlo and run automated tests', (target = 'all') =>
    @task.run 'coffeelint'
    # @task.run 'coffee'
    @task.run 'noflo_manifest'
    @task.run 'noflo_test'

  @registerTask 'default', ['test']
