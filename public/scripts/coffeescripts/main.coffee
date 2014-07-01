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
    backboneRoutefilter: "lib/backboneRoutefilter"
    rivets: "lib/rivets"
    kinetic: "lib/kinetic"
    bootstrap: 'lib/bootstrap'
    jqueryMultiSelect: 'lib/jqueryMultiSelect'
    bootstrapSwitch: 'lib/bootstrapSwitch'
    jqueryEditable: 'lib/jqueryEditable'
    tinybox: "lib/jqueryModal"

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
    jqueryMultiSelect:
      deps: ["jquery"]
      exports: "JqueryMultiSelect"
    jqueryEditable:
      deps: ["jquery"]
      exports: "JqueryEditable"     
    tinybox:
      deps: ["jquery"]
      exports: "Tinybox"     
)


# Load our app module and pass it to our definition function
require [ 'router', 'appController'], (Router, AppController) ->
  return
