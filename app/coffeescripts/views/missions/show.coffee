define [
  "jquery"
  "underscore"
  "backbone"
  "tinybox"
  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/missions/show.html"
], ($, _, Backbone, Tinybox, MissionsShowView) ->
  
  MissionsShowTemplate = Backbone.View.extend(
    initialize: (options) ->
      options.app.debugInfo

    el: $("#right_board")

    render: ->
      # Using Underscore we can compile our template with data
      data =
        title: "Current Mission"
        cells: ['Name', 'Creator', 'Company', 'Product', 'Code']
        buttons: ['SALVA', 'SACA', 'Save As', 'Reload']
      compiledTemplate = _.template(MissionsShowView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  MissionsShowTemplate
