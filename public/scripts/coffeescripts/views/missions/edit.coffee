define [
  "jquery"
  "underscore"
  "backbone"
  'jqueryMultiSelect'

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/missions/edit.html"
], ($, _, Backbone, JqueryMultiSelect, MissionsEditView) ->
  MissionsEditTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Edit Mission"
      compiledTemplate = _.template(MissionsEditView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
      return
  )
  
  # Our module now returns our view
  MissionsEditTemplate
