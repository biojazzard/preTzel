"use strict"

module.exports = (grunt) ->

  ###
   # Functions
  ###

  generateHTMLConfig = (orig, dest, scripts, css, addThirdPartyLibs, addQunit) ->
    scripts = (if Array.isArray(scripts) then scripts else [scripts])
    css = (if Array.isArray(css) then css else [css])
    if addQunit
      scripts.unshift project.qunit_lib
      scripts.push '<config:lint.tests>'
      css.push project.qunit_css
    if addThirdPartyLibs
      scripts = grunt.utils._.union(project.third_party_libs, project.third_party_unminified_libs, scripts)
      css = grunt.utils._.union(css, project.third_party_css)
    config =
      src: orig
      dest: dest
      js: scripts
      css: css
      options:
        qunit: !!addQunit
        file: (file, data) ->
          content = grunt.file.read(file)
          ejs.render content, grunt.utils._.extend({}, config.options, (if data then data else {}))

        project: project

    config

  ###
   # VARS & DEFS
  ###

  ejs = require('ejs')
  fs = require('fs')
  brandingFile = './branding/config.js'
  branding = (if fs.existsSync(brandingFile) then require(brandingFile) else null)
  unless branding
    branding =
      initGruntConfig: (config) ->
        config

      initProject: (project) ->
        project

  project = branding.initProject JSON.parse grunt.file.read 'project.json'
  
  ###
   # INIT & CONFIG
  ###
  grunt.initConfig branding.initGruntConfig
    pkg: grunt.file.readJSON 'package.json'
    
    #pkg: '<json:package.json>',
    meta:
      banner: "/*! <%= pkg.name %> - v<%= pkg.version %> - " + "<%= grunt.template.today(\"yyyy-mm-dd\") %>\n" + "<%= pkg.homepage ? \"* \" + pkg.homepage + \"\n\" : \"\" %>" + "* Copyright (c) <%= grunt.template.today(\"yyyy\") %> <%= pkg.author.name %>;" + " Licensed <%= _.pluck(pkg.licenses, \"type\").join(\", \") %> */"

    copy:
      tests:
        files:
          '<%= pkg.dist %>tests/': 'tests/**'

      js:
        files:
          '<%= pkg.dist %>js/': 'src/js/**'

      assets:
        files:
          '<%= pkg.dist %>img/': 'src/img/**',
          '<%= pkg.dist %>fonts/': 'src/fonts/**'
          '<%= pkg.dist %>js/libs/bootstrap/': 'third_party/bootstrap/**'
          '<%= pkg.dist %>js/libs/modernizr/': 'third_party/modernizr/**'
          '<%= pkg.dist %>js/libs/jquery/': "third_party/jquery/**"

    concat:
      js:
        src: [project.third_party_libs, '<%= pkg.dist %>js/third_party.min.js', '<%= pkg.dist %>js/index.min.js']
        dest: '<%= pkg.dist %>js/<%= pkg.name %>.min.js'

      css:
        src: ['<%= pkg.dist %>css/third_party.min.css', '<%= pkg.dist %>css/style.min.css']
        dest: "<%= pkg.dist %>css/<%= pkg.name %>.min.css"

    csscss:
      options:
        colorize: true
        verbose: true
        outputJson: false
        minMatch: 2
        compass: false
        #ignoreProperties: "padding"
        #ignoreSelectors: ".rule-a"

      dist:
        src: ["css/style.css"]

    html:
      index_prod: generateHTMLConfig("index.html", "<%= pkg.dist %>index.html", "<config:concat.min_js.name>", "css/app.min.css", false)
      
      #index_prod_qunit: generateHTMLConfig('<%= pkg.dist %>index.qunit.html', '<config:concat.min_js.name>', 'css/app.min.css', false, true),
      index_programa: generateHTMLConfig("html_sections/programas.html", "<%= pkg.dist %>programas.html", "<config:concat.min_js.name>", "css/app.min.css", false)
      
      #index_actividades: generateHTMLConfig('<%= pkg.dist %>actividades.html', '<config:concat.min_js.name>', 'css/app.min.css', false)
      index_diseno: generateHTMLConfig("html_sections/diseno.html", "<%= pkg.dist %>diseno.html", "<config:concat.min_js.name>", "css/app.min.css", false)

    qunit:
      dev: 'http://localhost:9000/index.dev.qunit.html'
      concat: 'http://localhost:9000/index.concat.qunit.html'
      prod: 'http://localhost:9000/index.qunit.html'

    uglify:
      options:
        mangle: false
        banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - ' + '<%= grunt.template.today("yyyy-mm-dd") %> */'

      coffee:
        files:
          '<%= pkg.dist %>js/index.min.js': ['<%= pkg.dist %>js/index.max.js']

      third_party:
        files:
          '<%= pkg.dist %>js/third_party.min.js': project.third_party_unminified_libs

    lint:
      grunt: ['Gruntfile.js']
      tests: project.tests
      
      # Note that the order of loading the files is important. 
      all: project.scripts
    
    # html:
    #  files: ['*.html', 'html_sections/**/*.html', 'html/**/*.html']
    #  tasks: 'html'
    
    coffee:
      compile_simple:
        files:
          "<%= pkg.dist %>js/index.max.js": ["src/coffee/<%= pkg.namespace %>.coffee", "src/coffee/<%= pkg.namespace %>.*.coffee", "src/coffee/libs/*.coffee"] # compile and concat into single file

      compile:
        options:
          join: true
        files:
          "<%= pkg.dist %>js/index.max.js": ["src/coffee/*.coffee", "src/coffee/libs/*.coffee"] # compile and concat into single file

    less:
      max:
        src: ["src/less/index.less"]
        dest: "<%= pkg.dist %>css/style.css"
        options:
          compile: true

      min:
        src: ["src/less/index.less"]
        dest: "<%= pkg.dist %>css/style.min.css"
        options:
          compile: true
          compress: true

    sass:
      dev:
        options:
          style: "expanded"
          debugInfo: true
          lineNumbers: true
          trace: true

        files:
          "<%= pkg.dist %>css/app.dev.css": "style/app.scss"

      prod:
        options:
          
          # Using compact here, so that debugging is not a nightmare. We minify it later.
          style: "compact"

        files:
          "<%= pkg.dist %>css/app.concat.css": "src/scss/app.scss"

    jshint:
      options:
        asi: true
        curly: false
        eqeqeq: false
        immed: false
        latedef: true
        newcap: true
        noarg: true
        sub: true
        undef: true
        boss: true
        eqnull: true
        jquery: true
        browser: true
        devel: true

      globals:
        exports: true
        module: false
        Global: true
        filterConfigs: true
        CodeMirror: true

      grunt:
        options: {}
        globals:
          require: true

      tests:
        options: {}
        globals:
          module: true
          test: true
          ok: true
          equal: true
          deepEqual: true
          QUnit: true

    cssmin:
      options:
        banner: "/*! <%= pkg.name %> - v<%= pkg.version %> - " + "<%= grunt.template.today(\"yyyy-mm-dd\") %> */"

      css:
        src: "<%= pkg.dist %>css/style.css"
        dest: "<%= pkg.dist %>css/style.min.css"

      third_party:
        src: project.third_party_css
        dest: "<%= pkg.dist %>css/third_party.min.css"

    img:
      
      # using only dirs with output path
      all:
        src: "src/img"
        dest: "img"
      
      # recursive extension filter with output path
      png:
        src: ["src/img/**/*.png"]
        dest: "img"
      
      # recursive extension filter with output path
      jpg:
        src: ["src/img/**/*.jpg"]
        dest: "img"
      
      # file by file with output path
      task3:
        src: ["src/img/logo.png", "img/social.jpg"]
        dest: "img"
      
      # single path to optimize and replace all images
      task4:
        src: "img"
      
      # file by file to optimize and replace
      task5:
        src: ["src/img/concert.jpg, src/img/halestorm.png"]
      
      # filter extension to optimize and replace
      task6:
        src: ["src/img/*.png"]

    watch:
      js:
        files: '<config:lint.all>'
        tasks: ['copy:js', 'lint', 'concat:js', 'min', 'concat:min_js']

      coffee:
        files: ['src/coffee/*.coffee']
        tasks: ['scripts']

      less:
        files: ['src/less/*.less']
        tasks: ['styles']

    connect:
      server:
        port: 9001
        base: "<%= pkg.dist %>"

    reload:
      port: 9001
      proxy:
        port: 81
        host: 'localhost'

      #sass:
      #  files: ['src/scss/app.scss']
      #  tasks: ['sass', 'cssmin', 'concat:css']  
  
  ###
   # Deprecated Helpers

  grunt.registerHelper('scripts', function(scripts) {
    scripts = Array.isArray(scripts) ? scripts : [scripts];
    return grunt.utils._(scripts).chain().flatten().compact().map(function(script) { return "<script src=\"" + script + "\"></script>\n"; }).value().join("    ");
  });

  grunt.registerHelper('css', function(css) {
    css = Array.isArray(css) ? css : [css];
    return grunt.utils._(css).chain().flatten().compact().map(function(cssFile) { return "<link rel=\"stylesheet\" href=\"" + cssFile + "\">\n"; }).value().join("    ");
  });

  grunt.registerHelper('html', function(content, scripts, css, options) {
    var scriptsTags = grunt.template.process(grunt.helper("scripts", scripts)),
      cssTags = grunt.template.process(grunt.helper("css", css));
    options = options || {};
    return ejs.render(content, grunt.utils._.extend({}, options, {
      scripts: scriptsTags,
      css: cssTags
    }))
  });
  ###

  ###
   # TASKS
  ###

  grunt.registerMultiTask 'html', 'Generates the index.html file injecting the css and script tags.', ->
    fileContents = grunt.task.directive(@data.src, grunt.file.read)
    outpu = grunt.helper('html', fileContents, @data.js, @data.css, @data.options)
    grunt.file.write @data.dest, output

  ###
   #     require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);
  ###

  ###
   # CONTRIB 
  ###
  grunt.loadNpmTasks 'grunt-contrib'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify' 
  grunt.loadNpmTasks 'grunt-contrib-less' 
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  ###
   # CSS 
  ###
  grunt.loadNpmTasks 'grunt-recess'
  grunt.loadNpmTasks 'grunt-css'
  grunt.loadNpmTasks 'grunt-csscss'
  ###
   # IMG 
  ###
  grunt.loadNpmTasks 'grunt-img'

  ###
   # SERVER 
  ###
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-reload'

  ###
   # SASS SUPPORT

  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.registerTask('html-do', 'html lint sass');
  grunt.registerTask('minify-css', 'cssmin concat:css');
  grunt.registerTask('default', 'html-do copy minify-js minify-css');

  ###

  grunt.registerTask 'default',   ['uglify']
  grunt.registerTask 'html-do',   ['html', 'lint']

  grunt.registerTask 'styles',    ['less', 'cssmin', 'concat:css']
  grunt.registerTask 'scripts',   ['coffee', 'uglify:coffee', 'uglify:third_party', 'concat:js'] #Concatenar //Miniminzar //Concatenar minimizados
  grunt.registerTask 'images',    ['img:all'] #Concatenar //Miniminzar //Concatenar minimizados

  # Original
  #grunt.registerTask('default', 'copy styles scripts img csscss');
  grunt.registerTask 'test',        ['copy:tests', 'server', 'qunit:dev']
  grunt.registerTask 'test-concat', ['copy:tests', 'server', 'qunit:concat']
  grunt.registerTask 'test-prod',   ['copy:tests', 'server', 'qunit:prod']
  grunt.registerTask 'test-all',    ['copy:tests', 'server', 'qunit']