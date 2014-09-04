define [
  "jquery"
  "underscore"
  "backbone"
  "bootstrapSwitch"
  # Using the Require.js text! plugin, we are loaded raw text
  # which will be used as our views primary template
  "text!templates/linein/calculateTool.html"
], ($, _, Backbone, bootstrapSwitch, CalculateView) ->
  CalculateTemplate = Backbone.View.extend(
    el: $("#right_board")
    render: ->
      
      # Using Underscore we can compile our template with data
      data =
        title: "Calculate Tool"

      compiledTemplate = _.template(CalculateView, data)
      
      # Append our compiled template to this Views "el"
      @$el.append compiledTemplate
        
  )
  
  # Our module now returns our view
  CalculateTemplate
