define [
  "jquery"
  "underscore"
  "backbone"
  "rivets"
  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/missions/new.html"
], ($, _, Backbone, rivets, MissionsNewView) ->
  MissionsNewTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Create Mission"
        cells: ['Name', 'Creator', 'Company', 'Product', 'Code']
        buttons: ['Update', 'Rename', 'Load', 'Delete', 'Info']
      compiledTemplate = _.template(MissionsNewView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  MissionsNewTemplate
