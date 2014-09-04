define [
  "jquery"
  "underscore"
  "backbone"
  "jqueryEditable"

  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/linein/tools.html"
], ($, _, Backbone, JqueryEditable, ToolsView) ->
  ToolsTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      data =
        title: "Select Tool"


      compiledTemplate = _.template(ToolsView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate

      return
  )
  
  # Our module now returns our view
  ToolsTemplate
