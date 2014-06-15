define [
  "jquery"
  "underscore"
  "backbone"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/missions/show.html"
], ($, _, Backbone, MissionsIndexView) ->
  # ###### rivets adapter configure, below ######
  # rivets.adapters[":"] =
  #   subscribe: (obj, keypath, callback) ->
  #     # console.log("1.subscribe:\t #{obj} ||\t #{keypath}")
  #     obj.on "change:" + keypath, callback
  #     return

  #   unsubscribe: (obj, keypath, callback) ->
  #     # console.log("2.unsubscribe:\t #{obj} ||\t #{keypath}")
  #     obj.off "change:" + keypath, callback
  #     return

  #   read: (obj, keypath) ->
  #     # console.log("3.read:\t\t\t #{obj} ||\t #{keypath}")
  #     # if((obj.get keypath) == undefined)
  #     #   console.log("3.read:++ #{obj[keypath]()} \t #{(obj.get keypath)}")
  #     #   obj[keypath]()
  #     # else
  #     #   obj.get keypath
  #     obj.get keypath

  #   publish: (obj, keypath, value) ->
  #     # console.log("4.publish:\t\t #{obj} ||\t #{keypath}")
  #     obj.set keypath, value
  #     return
  MissionsIndexTemplate = Backbone.View.extend(
    initialize: (options) ->
      options.app.debugInfo

    el: $("#right_board")

    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Current Mission"
        cells: ['Name', 'Creator', 'Company', 'Product', 'Code']
        buttons: ['SALVA', 'SACA', 'Save As', 'Reload']
      compiledTemplate = _.template(MissionsIndexView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  MissionsIndexTemplate
