require.config(
  baseUrl: "./scripts"
  dir: "../dist"
  optimize: "uglify"
  optimizeCss: "standard.keepLines"
  removeCombined: true
  fileExclusionRegExp: /^\./
  # modules: [
  #   name: "app/dispatcher"
  # ,
  #   name: "app/in-storage"
  #   exclude: [ "jquery", "app/common", "pkg/DatePicker/app" ]
  #  ]
  paths:
    jquery: "lib/jquery"
    underscore: "lib/underscore"
    backbone: "lib/backbone"
    rivets: "lib/rivets"
    kinetic: "lib/kinetic"
    bootstrap: 'lib/bootstrap'

  shim:
    underscore:
      exports: "_"

    backbone:
      deps: [ "underscore", "jquery" ]
      exports: "Backbone"
    rivets:
      exports: "rivets"
    kinetic:
      exports: "Kinetic"
    bootstrap:
      deps: [ "jquery" ]
      exports: "Bootstrap"
)