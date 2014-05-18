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



# Load our app module and pass it to our definition function
require ['rivets', "app"], (rivets, App) ->
  
  # The "app" dependency is passed in as "App"
  # App.initialize()
  ###### rivets adapter configure, below ######
  rivets.adapters[":"] =
    subscribe: (obj, keypath, callback) ->
      # console.log("1.subscribe:\t #{obj} ||\t #{keypath}")
      obj.on "change:" + keypath, callback
      return

    unsubscribe: (obj, keypath, callback) ->
      # console.log("2.unsubscribe:\t #{obj} ||\t #{keypath}")
      obj.off "change:" + keypath, callback
      return

    read: (obj, keypath) ->
      # console.log("3.read:\t\t\t #{obj} ||\t #{keypath}")
      # if((obj.get keypath) == undefined)
      #   console.log("3.read:++ #{obj[keypath]()} \t #{(obj.get keypath)}")
      #   obj[keypath]()
      # else
      #   obj.get keypath
      obj.get keypath

    publish: (obj, keypath, value) ->
      # console.log("4.publish:\t\t #{obj} ||\t #{keypath}")
      obj.set keypath, value
      return

  ###### rivets adapter configure, above######

  return
