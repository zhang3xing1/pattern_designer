define [
  "jquery"
  "underscore"
  "backbone"
  "jqueryEditable"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/missions/index.html"
], ($, _, Backbone, JqueryEditable, MissionsIndexView) ->
  MissionsIndexTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Load Mission"
        # cells: ['Name', 'Creator', 'Company', 'Product', 'Code']
        buttons: ['Update', 'Rename', 'Load', 'Delete', 'Info']
      compiledTemplate = _.template(MissionsIndexView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  MissionsIndexTemplate
